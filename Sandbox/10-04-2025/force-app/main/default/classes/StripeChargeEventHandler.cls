public class StripeChargeEventHandler extends StripeAbstractEventHandler {

    public static final String INVOICE_SUCCESS_STATUS = 'succeeded';
    public static final String INVOICE_REFUNDED_STATUS = 'refunded';

    public static final Integer AMOUNT_DIVIDER = 100;
    public static final String DATE_UNIX_TAIL = '000';
    public static final String DISPUTE_OBJECT_NAME = 'dispute';

    public static final String REFUND_OBJECT_NAME = 'refund';
    public static final String REFUND_FAILED_STATUS = 'failed';
    public static final String REFUND_PENDING_STATUS = 'pending';

    /**
     * This method is dynamically called from StripeEventHandler, which determinates which handler to call based on event type.
     * The method is part of 3 processes:
     *      1. Updating PaymentStatus__c on the invoice on every charge
     *      2. Saving related refunds
     *      3. Saving related disputes
     *
     * @param eventData     JSON as string from the stripe webhook
     */
    public override void handle(String eventData){
        String createdString = retrieveCreatedForEvent(eventData);

        eventData = preProcessJson(eventData);
        String dataObjectString = parseToEventDataString(eventData);
        StripeModels.ChargeEventData chargeEventData = (StripeModels.ChargeEventData) JSON.deserialize(
            dataObjectString, StripeModels.ChargeEventData.class
        );

        Boolean isRefund = chargeEventData.object_x == REFUND_OBJECT_NAME;
        Boolean chargeHasRefunds = chargeEventData.refunds != null &&
                                   chargeEventData.refunds.data != null &&
                                   chargeEventData.refunds.data.size() > 0;
        Boolean isDispute = chargeEventData.object_x == DISPUTE_OBJECT_NAME;

        if(isRefund || chargeHasRefunds) {
            saveRefunds(chargeEventData, createdString);
        } else if(isDispute) {
            saveDispute(chargeEventData, createdString);
        } else {
            updateRelatedInvoice(chargeEventData);
        }
    }

    private List<StripeModels.Refund> extractRefunds(StripeModels.ChargeEventData chargeEventData) {
        List<StripeModels.Refund> refunds = new List<StripeModels.Refund>();

        if(chargeEventData.object_x == REFUND_OBJECT_NAME) {
            StripeModels.Refund refund = (StripeModels.Refund) JSON.deserialize(
                JSON.serialize(chargeEventData), StripeModels.Refund.class
            );
            refunds.add(refund);
        } else {
            refunds.addAll(chargeEventData.refunds.data);
        }

        return refunds;
    }

    /**
     * This method is used to save parsed JSON from Webhook on Charge.Refund object from Stripe. Refund is usually related
     * to a payment intent, but the parameter is not required by Stripe and therefore not required in Salesforce.
     *
     * Multiple refunds are possible in case of partial refunds. For example, if first the customer was refunded with a
     * half of the amount, and then with a full amount.
     *
     * @param chargeEventData   Parsed payload. Can't be null.
     * @param createdString     String in UNIX time that represents the date when the event object was created.
     */
    private void saveRefunds(StripeModels.ChargeEventData chargeEventData, String createdString) {
        List<StripeModels.Refund> refunds = extractRefunds(chargeEventData);
        Map<String, PaymentIntent__c> stripeIntentIdToIntentMap = createIntentsMap(refunds); 

        Set<Id> invoicesWithFailedRefunds = new Set<Id>();
        Set<Id> invoiceIds = new Set<Id>();
        List<Refund__c> refundsToUpsert = new List<Refund__c>();

        for(StripeModels.Refund refundPayload : refunds) {
            PaymentIntent__c paymentIntent = stripeIntentIdToIntentMap.get(refundPayload.payment_intent);
            Id paymentIntentId = paymentIntent != null ? paymentIntent.Id : null;
            Id invoiceId = paymentIntent != null ? paymentIntent.Invoice__c : null;

            refundsToUpsert.add(createRefundObject(refundPayload, paymentIntentId, invoiceId, createdString));

            if(invoiceId != null) {
                invoiceIds.add(invoiceId); 

                if(refundPayload.status == REFUND_FAILED_STATUS || refundPayload.status == REFUND_PENDING_STATUS) {
                    invoicesWithFailedRefunds.add(invoiceId);
                }
            }           
        }

        List<Invoice__c> invoicesToUpdate = updateRelatedRefundInvoice(invoiceIds, invoicesWithFailedRefunds);
        updateInvoices(invoicesToUpdate);
        if (refundsToUpsert.isEmpty()) {
            return;
        }
        Map<Boolean, Refund__c> createdMap = createdDateLatest(refundsToUpsert, createdString);
        if(createdMap.containsKey(false)) {
            if (createdMap.get(false) != null) {
                update createdMap.get(false);
            }
            return;
        }
        if (createdMap.get(true) != null) {
            for (Refund__c refund : refundsToUpsert) {
                refund.StripeFirstCreatedDatetime__c = createdMap.get(true).StripeFirstCreatedDatetime__c;
            }
        }

        upsert refundsToUpsert StripeRefundId__c;
    }

    /**
     * The method is part of saving refund process and the returned map is used to check if there is a related invoice
     * to the payment intent.
     *
     * @param refunds       List of refunds with payment intent stripe id. Can't be null.
     * @return              Map with key = Payment Intent Stripe Id and Value = Payment Intent sObject
     * */
    private Map<String, PaymentIntent__c> createIntentsMap(List<StripeModels.Refund> refunds) {
        Map<String, PaymentIntent__c> stripeIntentIdToIntentMap = new Map<String, PaymentIntent__c>();
        Set<String> stripeIntentIds = new Set<String>();

        for(StripeModels.Refund refund : refunds) {
            stripeIntentIds.add(refund.payment_intent);
        }

        List<PaymentIntent__c> intents = queryPaymentIntentsByStripeId(stripeIntentIds);

        for(PaymentIntent__c intent : intents) {
            stripeIntentIdToIntentMap.put(intent.StripeId__c, intent);
        }

        return stripeIntentIdToIntentMap;
    }

    /**
     * The method is used as a part of the process for saving disputes from the stripe webhook.
     * 
     * @param chargeEventData       Payload of the charge object. Can't be null.
     * @param createdString               String in UNIX time that represents the date when the event object was created.
     */
    private void saveDispute(StripeModels.ChargeEventData chargeEventData, String createdString) {
        String intentStripeId = chargeEventData.payment_intent;
        PaymentIntent__c intent = queryPaymentIntentsByStripeId(new Set<String> {intentStripeId}).get(0);
        Dispute__c dispute = createDisputeFromPayload(chargeEventData, intent, createdString);
        Map<Boolean, Dispute__c> createdMap = createdDateLatest(dispute, createdString);
        if(createdMap.containsKey(false)) {
            if (createdMap.get(false) != null) {
                update createdMap.get(false);
            }
            return;
        }
        if (createdMap.get(true) != null) {
            dispute.StripeFirstCreatedDatetime__c = createdMap.get(true).StripeFirstCreatedDatetime__c;
        }

        upsert dispute StripeDisputeId__c;
    }

    /**
     * This method is used to create an actual Salesforce record from parsed payload from webhook.
     * 
     * @param chargeEventData           Charge payload. Must contain stripe id. Can't be null.
     * @param intent                    Payment intent for connection with a dispute.
     * @param createdString             String in UNIX time that represents the date when the event object was created.
     * @return                          Dispute record ready to insert.
     */
    private Dispute__c createDisputeFromPayload(
            StripeModels.ChargeEventData chargeEventData, PaymentIntent__c intent, String createdString
    ) {
        DateTime stripeCreatedDate = DateTime.newInstance(Long.valueOf(createdString + DATE_UNIX_TAIL));
        Id invoiceId = intent != null ? intent.Invoice__c : null;
        Id intentId = intent != null ? intent.Id : null;

        Dispute__c dispute = new Dispute__c(
            PaymentIntent__c = intentId,
            Invoice__c = invoiceId,
            Status__c = chargeEventData.status,
            StripeDisputeId__c = chargeEventData.id,
            ChargeId__c = chargeEventData.charge,
            PaymentType__c = chargeEventData.payment_method_details?.type,
            CreatedInStripe__c = stripeCreatedDate
        );

        return dispute;
    }

    /**
     * The method is used as a part of the process for ensuring that only the latest webhook information stored and
     * the retry mechanism of stripe doesn't overwrite relevant data.
     *
     * @param createdDispute    Dispute record that was created from the webhook payload.
     * @param createdString     String in UNIX time that represents the date when the event object was created.
     * @return                  True if the date on received dispute is later then in a saved dispute.
     */
    private Map<Boolean, Dispute__c> createdDateLatest(Dispute__c createdDispute, String createdString) {
        DateTime createdNewEvent = DateTime.newInstance(Long.valueOf(createdString + DATE_UNIX_TAIL));
        List<Dispute__c> disputes = queryDisputeByStripeId(new Set<String>{createdDispute.StripeDisputeId__c});

        if(disputes.size() == 0) {
            return new Map<Boolean, Dispute__c>{true => new Dispute__c(StripeFirstCreatedDatetime__c = createdNewEvent)};
        }

        Dispute__c existingDispute = disputes.get(0);
        return new Map<Boolean, Dispute__c>{createdNewEvent >= existingDispute.CreatedInStripe__c ||
               existingDispute.CreatedInStripe__c == null => existingDispute.StripeFirstCreatedDatetime__c > createdNewEvent ? new Dispute__c(Id = existingDispute.Id, StripeFirstCreatedDatetime__c = createdNewEvent) : null};
    }

    /**
     * The method is used as a part of the process for ensuring that only the latest webhook information stored and
     * the retry mechanism of stripe doesn't overwrite relevant data.
     *
     * All refunds that are sent in one payload have the same created time stamp. Therefore it is enough to check just
     * one of the refunds.
     *
     * @param createdRefunds        Can't be null, but can be empty.
     * @param createdString         String in UNIX time that represents the date when the object was created.
     * @return                      False if one of the refund has a greater date as in payload.
     */
    private Map<Boolean, Refund__c> createdDateLatest(List<Refund__c> createdRefunds, String createdString) {
        DateTime createdNewEvent = DateTime.newInstance(Long.valueOf(createdString + DATE_UNIX_TAIL));
        List<Refund__c> existingRefunds = queryRefundsByStripeId(new Set<String>{createdRefunds.get(0).StripeRefundId__c});

        if(existingRefunds.size() == 0) {
            return new Map<Boolean, Refund__c>{true => new Refund__c(StripeFirstCreatedDatetime__c = createdNewEvent)};
        }

        Refund__c existingRefund = existingRefunds.get(0);

        return new Map<Boolean, Refund__c>{createdNewEvent >= existingRefund.CreatedInStripe__c ||
               existingRefund.CreatedInStripe__c == null => existingRefund.StripeFirstCreatedDatetime__c > createdNewEvent ? new Refund__c(Id = existingRefund.Id, StripeFirstCreatedDatetime__c = createdNewEvent) : null};
    }

    /**
     * The created date should be retrieved from the event object and not from the charge payload. This "created" field
     * is not the date when the event was sent, but the date when the object of the event was created.
     *
     * @param eventData     The whole stripe event JSON.
     * @return              String in UNIX time that represents the date when the object was created.
     * */
    private String retrieveCreatedForEvent(String eventData) {
        Map<String, Object> eventDataMap = (Map<String, Object>) JSON.deserializeUntyped(eventData);
        return String.valueOf(eventDataMap.get('created'));
    }

    /**
     * The method is used to create a refund sObject for upsert.
     *
     * @param refundPayload         Refund payload. Can't be null.
     * @param intentId              Related payment intent salesforce id. Can be null.
     * @param invoiceId             Related invoice salesforce id. Can be null.
     * @param createdString         String in UNIX time that represents the date when the object was created.
     * @return                      Refund sObject to upsert. Never null.
     * */
    private Refund__c createRefundObject(StripeModels.Refund refundPayload, Id intentId, Id invoiceId, String createdString) {
        Decimal amount = (refundPayload.amount == null ? 0 : Decimal.valueOf(refundPayload.amount)) / AMOUNT_DIVIDER;
        DateTime stripeCreatedDate = DateTime.newInstance(Long.valueOf(createdString + DATE_UNIX_TAIL));

        return new Refund__c(
                PaymentIntent__c = intentId,
                Invoice__c = invoiceId,
                Amount__c = amount,
                StripeRefundId__c = refundPayload.id,
                Reason__c = refundPayload.reason,
                ReceiptNumber__c = refundPayload.receipt_number,
                Status__c = refundPayload.status,
                CreatedInStripe__c = stripeCreatedDate
        );
    }

    /**
     * This method is called to update the status of all relevant invoices.
     *
     * @param invoiceIds                    Can't be null, otherwise NUllPointerException.
     * @param invoicesWithFailedRefunds     Can't be null, otherwise NullPointerException.
     * @return                              List of updated invoices.
     * */
    private List<Invoice__c> updateRelatedRefundInvoice(Set<Id> invoiceIds, Set<Id> invoicesWithFailedRefunds) {
        List<Invoice__c> invoices = queryInvoicesById(invoiceIds);

        for(Invoice__c invoice : invoices) {
            if(invoicesWithFailedRefunds.contains(invoice.Id)) {
                invoice.PaymentStatus__c = INVOICE_SUCCESS_STATUS;
            } else {
                invoice.PaymentStatus__c = INVOICE_REFUNDED_STATUS;
            }
        }

        return invoices;
    }

    /**
    * This method is used to update Payment status and date on the related invoice.
    *
    * @param chargeEventData   Parsed payload. Can't be null.
    * */
    private void updateRelatedInvoice(StripeModels.ChargeEventData chargeEventData) {
        List<Invoice__c> invoices = (List<Invoice__c>) Paua_SelectorHandler.getSelector(InvoiceSelectors.ByStripeId.class)
                .setParameter('stripeInvoiceIdSet', new Set<String>{chargeEventData.id})
                .query();
        Invoice__c invoice = invoices.size() == 0 ? new Invoice__c() : invoices.get(0);

        invoice.PaymentStatus__c = chargeEventData.status;
        if(invoice.PaymentStatus__c == INVOICE_SUCCESS_STATUS) {
            invoice.PaymentDate__c = Date.today();
        }

        upsertInvoice(invoice);
    }

    /**
     * @param ids       Can't be null
     * @return          List of one or zero refunds. Never null.
    */
    private List<Refund__c> queryRefundsByStripeId(Set<String> ids) {
        return (List<Refund__c>) Paua_SelectorHandler.getSelector(RefundSelectors.ByStripeId.class)
                    .setParameter('idSet', ids)
                    .query();
    }

    /**
     * @param ids       Can't be null
     * @return          List of disputes, never null.
    */
    private List<Dispute__c> queryDisputeByStripeId(Set<String> ids) {
        return (List<Dispute__c>) Paua_SelectorHandler.getSelector(DisputeSelectors.ByStripeId.class)
                    .setParameter('idSet', ids)
                    .query();
    }

    /**
     * The situation where there are multiple Payment Intents store is highly unlikely, because they are stored based
     * on Stripe Id, which is unique. Therefore it is assumed that there is only one or none Payment Intents in the org.
     *
     * @param ids               Payment Intent Id for query. Can't be null or exception is thrown.
     * @return                  List of relevant payment intents.
     * */
    private List<PaymentIntent__c> queryPaymentIntentsByStripeId(Set<String> ids) {
        return (List<PaymentIntent__c>) Paua_SelectorHandler.getSelector(PaymentIntentSelectors.ByStripeId.class)
                        .setParameter('stripeIdSet', ids)
                        .query();
    }

    /**
     * @param ids               Can't be null, otherwise exception.
     * @return                  Never null.
     * */
    private List<Invoice__c> queryInvoicesById(Set<Id> ids) {
        return (List<Invoice__c>) Paua_SelectorHandler.getSelector(InvoiceSelectors.ById.class)
                .setParameter('idSet', ids)
                .query();
    }

    /**
     * @param invoice   Invoice to upsert. Can't be null.
     * */
    private void upsertInvoice(Invoice__c invoice) {
        Paua_Transaction trans = new Paua_Transaction();
        trans.addForUpsert(invoice);
        trans.setPreferredOrder(new List<SObjectType>{Invoice__c.getSObjectType()});
        trans.commitRecords();
    }

    /**
     * @param invoices    Invoice to update. Can't be null.
     * */
    private void updateInvoices(List<Invoice__c> invoices) {
        Paua_Transaction trans = new Paua_Transaction();
        trans.addForUpsert(invoices);
        trans.setPreferredOrder(new List<SObjectType>{Invoice__c.getSObjectType()});
        trans.commitRecords();
    }
}