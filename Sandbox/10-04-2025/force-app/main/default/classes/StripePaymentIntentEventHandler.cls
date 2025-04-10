public class StripePaymentIntentEventHandler extends StripeAbstractEventHandler {
    public static final Integer AMOUNT_DIVIDER = 100;
    public static final String PAYMENT_METHOD_SEPA_HEAD = 'sepa_debit';
    public static final String PAYMENT_METHOD_CARD_HEAD = 'card';
    public static final String DATE_UNIX_TAIL = '000';

    /**
     * This method parses the Payment Intent webhook message and inserts the Payment Intent record. 
     * This method is dynamically called from StripeEventHandler, which determinates which handler to call 
     * based on event type.
     *
     * Every time when we receive an updated or new payment intent we need to update the related status on the
     * invoice record, so we could see which invoices are paid.
     * 
     * @param eventData     JSON as string from the stripe webhook
     */
    public override void handle(String eventData) {
        String createdString = retrieveCreatedForEvent(eventData);

        eventData = preProcessJson(eventData);
        String dataObjectString = parseToEventDataString(eventData);
        StripeModels.PaymentIntentData paymentIntentData = (StripeModels.PaymentIntentData) JSON.deserialize(
            dataObjectString, StripeModels.PaymentIntentData.class
        );

        String balanceTransaction = getBalanceTransaction(dataObjectString);
        PaymentIntent__c paymentIntent = createPaymentIntent(paymentIntentData, balanceTransaction, createdString);
        Map<Boolean, PaymentIntent__c> createdMap = createdDateLatest(paymentIntent.StripeId__c, createdString);
        if(createdMap.containsKey(false)) {
            if (createdMap.get(false) != null) {
                update createdMap.get(false);
            }
            return;
        }
        if (createdMap.get(true) != null) {
            paymentIntent.StripeFirstCreatedDatetime__c = createdMap.get(true).StripeFirstCreatedDatetime__c;
        }

        upsert paymentIntent StripeId__c;

        Invoice__c invoiceToUpdate = getInvoiceToUpdate(paymentIntent, paymentIntentData.invoice);
        if(invoiceToUpdate != null) {
            updateInvoiceStatus(invoiceToUpdate);
        }
    }

    /**
     * This method is the main method for creating a payment intent record from the webhook parsed payload. The record
     * is then upserted later.
     *
     * @param paymentIntentData     Parsed payment intent payload from the webhook. Must contain stripe id. Can't be null.
     * @param balanceTransaction    Balance transaction id. Can be null.
     * @param createdString         String in UNIX time that represents the date when the event object was created.
     * @return                      The Payment intent record that will be upserted later.
     * */
    private PaymentIntent__c createPaymentIntent(
            StripeModels.PaymentIntentData paymentIntentData, String balanceTransaction, String createdString
    ) {
        String currency_x = paymentIntentData.currency_x != null ? paymentIntentData.currency_x.toUpperCase() : '';
        String lastPaymentErrorMessage = '';
        String lastPaymentErrorCode = '';
        if(paymentIntentData.last_payment_error != null) {
            lastPaymentErrorMessage = paymentIntentData.last_payment_error.message;
            lastPaymentErrorCode = paymentIntentData.last_payment_error.code;
        }


        String paymentMethod = retrievePaymentMethod(paymentIntentData);
        DateTime createdInStripe = DateTime.newInstance(Long.valueOf(
                createdString + StripeInvoiceEventHandler.DATE_UNIX_TAIL)
        );

        PaymentIntent__c paymentIntent = new PaymentIntent__c(
            Amount__c = (paymentIntentData.amount == null ? 0 : paymentIntentData.amount) / AMOUNT_DIVIDER,
            AmountCapturable__c = paymentIntentData.amount_capturable == null ? 0 : paymentIntentData.amount_capturable / AMOUNT_DIVIDER,
            AmountReceived__c = paymentIntentData.amount_received == null ? 0 : paymentIntentData.amount_received / AMOUNT_DIVIDER,
            Currency__c = currency_x,
            Description__c = paymentIntentData.description,
            //LastPaymentErrorMessage__c = lastPaymentErrorMessage.abbreviate(255),
            LastPaymentErrorMessage__c = lastPaymentErrorMessage, //Updated July-28-2024
            LastPaymentErrorCode__c = lastPaymentErrorCode,
            PaymentMethod__c = paymentMethod,
            Status__c = paymentIntentData.status,
            StripeId__c = paymentIntentData.id,
            StripeInvoiceId__c = paymentIntentData.invoice,
            BalanceTransaction__c = balanceTransaction,
            StripeCustomerId__c = paymentIntentData.customer,
            CreatedInStripe__c = createdInStripe
        );

        if(paymentIntentData.customer != null) {
            List<Account> accounts = findAccountsByCustomerId(paymentIntentData.customer);
            if (accounts != null && !accounts.isEmpty()) {
                paymentIntent.Account__c = accounts[0].Id;
            }
        }

        if(checkInvoiceExist(paymentIntentData.invoice)) {
            paymentIntent.Invoice__r = new Invoice__c(Stripe_Invoice_Id__c = paymentIntentData.invoice);
        }

        return paymentIntent;
    }

    /**
     * The reason for using SOSL instead of SOQL is that StripeCustomerJSONMap__c is a Long Text Area, which is not
     * supported by SOQL.
     *
     * @param customerId        Id of the searched customer. Can't be null, or exception will be thrown.
     * @return                  List of accounts, can be null if nothing the SOSL query is empty.
     */
    private List<Account> findAccountsByCustomerId(String customerId){
        List<List<Account>> searchList = [
                FIND :customerId
                IN ALL FIELDS
                RETURNING Account(StripeCustomerJSONMap__c)
        ];

        return searchList?.get(0);
    }

    /**
     * This method is part of creating a link between payment intent and invoice.
     *
     * @param invoiceStripeId   Can't be null.
     * @return                  True if invoice exists in the org. Never null.
     * */
    private Boolean checkInvoiceExist(String invoiceStripeId) {
        if(invoiceStripeId == null) {
            return false;
        }
        
        List<Invoice__c> invoices = queryInvoiceByStripeId(invoiceStripeId);

        return invoices.size() == 1;
    }

    /**
     * It is assumed that there is only one charge object in the list, otherwise the first charge object from the list
     * is taken.
     *
     * @param paymentIntentData     Payment intent paload from the webhook. Can't be null.
     * @return                      Payment method from the payload. Never null.
     */
    private String retrievePaymentMethod(StripeModels.PaymentIntentData paymentIntentData) {
        String paymentMethod = 'other';
        if(
            paymentIntentData.Charges == null || 
            paymentIntentData.Charges.data == null || 
            paymentIntentData.Charges.data.isEmpty()
        ) {
            return paymentMethod;
        }

        StripeModels.ChargeEventData chargeEvent = paymentIntentData.Charges.data.get(0);
        if(chargeEvent.payment_method_details != null && chargeEvent.payment_method_details.sepa_debit != null) {
            paymentMethod = PAYMENT_METHOD_SEPA_HEAD + ' ' + chargeEvent.payment_method_details.sepa_debit.last4;
        } else if(chargeEvent.payment_method_details != null && chargeEvent.payment_method_details.card != null) {
            paymentMethod = PAYMENT_METHOD_CARD_HEAD + ' ' + 
                            chargeEvent.payment_method_details.card.brand + ' ' +
                            chargeEvent.payment_method_details.card.last4;
        }

        return paymentMethod;
    }

    /**
     * It is assumed that balance_transaction is not an object but a string.
     *
     * @param dataObjectString      Charge payload from the webhook.
     * @return                      Balance transaction or null.
     * */
    private String getBalanceTransaction(String dataObjectString) {
        Map<String, Object> eventDataMap = (Map<String, Object>) JSON.deserializeUntyped(dataObjectString);

        Map<String, Object> charges = (Map<String, Object>) eventDataMap.get('charges');
        
        List<Object> data = new List<Object>();
        if(!charges.isEmpty()) {
            data = (List<Object>) charges.get('data');
        }

        if(!data.isEmpty() && data.get(0) != null) {
            Map<String, Object> dataObject = (Map<String, Object>) data.get(0);
            Object balanceTransaction = dataObject.get('balance_transaction');
            return balanceTransaction == null ? null : balanceTransaction.toString();
        } 
        
        return null;
    } 

    /**
     * this method is a part of process for updating a status of the related invoice. The stripe invoice id is rent
     * with a payment intent payload and is used to find a related invoice in Salesforce.
     *
     * To find out the correct status all related payment intents are searched and the most recent status is selected.
     *
     * @param incomingIntent    The payment intent record created from the payload of the received webhook data.
     * @param invoiceId         Stripe if of the invoice. Can be null.
     * @return                  Updated invoice record or null.
     * */
    private Invoice__c getInvoiceToUpdate(PaymentIntent__c incomingIntent, String invoiceId) {
        List<Invoice__c> invoices = queryInvoiceByStripeId(invoiceId);

        if(invoices.size() == 1) {
            Invoice__c invoice = invoices.get(0);
            invoice.PaymentIntentStatus__c = calculateInvoiceStatus(invoice.PaymentIntents__r, incomingIntent);
            //we don't want to update any other field on the invoice and prevent that we get conflicts from two events that are processed in the same second
            return new Invoice__c(Id = invoice.Id, PaymentIntentStatus__c = invoice.PaymentIntentStatus__c);
        } else {
            return null;
        }
    }

    /**
     * Important: Do not confuse this CreatedInStripe__c check with the another one that we have e.g. in the
     * @method createdDateLatest(). This check is part of the another process, so there is no need to check the created
     * date on the event. Here we just search for the lates payment intent among all related intents in order to set
     * the most recent status to the invoice.
     *
     * @param existingIntents       The payment intents that exists in the org. Can be null.
     * @param incomingIntent        The intent created from the webhook payload. Can't be null.
     * @return                      The most recent status among all payment intents or the status from the payload.
     * */
    private String calculateInvoiceStatus(List<PaymentIntent__c> existingIntents, PaymentIntent__c incomingIntent) {
        PaymentIntent__c intentToReturn = incomingIntent;
        if(existingIntents == null || existingIntents.isEmpty()) {
            return intentToReturn.Status__c;
        }

        for(PaymentIntent__c existingIntent : existingIntents) {
            if(
                existingIntent.CreatedInStripe__c != null && 
                existingIntent.CreatedInStripe__c > intentToReturn.CreatedInStripe__c
            ) {
                intentToReturn = existingIntent;
            }
        }

        return intentToReturn.Status__c;
    }

    /**
     * The method is used to ensure that only the latest data is stored on the payment intent from the webhook.
     *
     * @param intentStripeId     Payment intent to check. Can't be null.
     * @param createdString      String in UNIX time with a date from the new event.
     * @return                   True if there is no payment intent with such stripe id, or if the created date is
     *                           empty, or if the payment intent is not the latest one. Otherwise false. Never null.
     */
    private Map<Boolean, PaymentIntent__c> createdDateLatest(String intentStripeId, String createdString) {
        List<PaymentIntent__c> intents = queryPaymentIntentsByStripeId(new Set<String> {intentStripeId});
        DateTime createdNewEvent = DateTime.newInstance(Long.valueOf(createdString + DATE_UNIX_TAIL));

        if(intents.size() == 0) {
            return new Map<Boolean, PaymentIntent__c>{true => new PaymentIntent__c(StripeFirstCreatedDatetime__c = createdNewEvent)};
        }

        PaymentIntent__c existingIntent = intents.get(0);
        return new Map<Boolean, PaymentIntent__c>{createdNewEvent >= existingIntent.CreatedInStripe__c || existingIntent.CreatedInStripe__c == null => existingIntent.StripeFirstCreatedDatetime__c > createdNewEvent ? new PaymentIntent__c(Id = existingIntent.Id, StripeFirstCreatedDatetime__c = createdNewEvent) : null};
    }

    /**
     * The created date should be retrieved from the event object and not from the invoice payload. This "created" field
     * is not the date when the event was sent, but the date when the object of the event was created.
     *
     * For example: If the invoice was sent, then failed. After 1 hour Stripe resends the invoice. The created date on
     * the event object represents the time the invoice was sent fro the first time.
     *
     * @param eventData     The whole stripe event JSON.
     * @return              String in UNIX time that represents the date when the object were created.
     * */
    private String retrieveCreatedForEvent(String eventData) {
        Map<String, Object> eventDataMap = (Map<String, Object>) JSON.deserializeUntyped(eventData);
        return String.valueOf(eventDataMap.get('created'));
    }

    /**
     * The method is used to update a status on the invoice after the payment intent webhook is received.
     *
     * @param invoice   Invoice to update. Can't be null, otherwise exception.
     * */
    private void updateInvoiceStatus(Invoice__c invoice) {
        Paua_Transaction trans = new Paua_Transaction();
        trans.setPreferredOrder(new List<SObjectType>{Invoice__c.SObjectType});
        trans.addForUpdate(invoice);
        trans.commitRecords();
    }

    /**
     * This method is used to query payment intents and check that we save only the latest information from the webhook.
     *
     * @param ids               Payment Intent Id for query. Can't be null or exception is thrown.
     * @return                  One or zero payments intents, because they are queried based on unique Stripe Id. Never null.
     * */
    private List<PaymentIntent__c> queryPaymentIntentsByStripeId(Set<String> ids) {
        return (List<PaymentIntent__c>) Paua_SelectorHandler.getSelector(PaymentIntentSelectors.ByStripeId.class)
                        .setParameter('stripeIdSet', ids)
                        .query();
    }

    /**
     * @param invoiceStripeId   Stripe id for query. Can't be null.
     * @return                  One or zero invoices as a List.
     * */
    private List<Invoice__c> queryInvoiceByStripeId(String invoiceStripeId) {
        return (List<Invoice__c>) Paua_SelectorHandler.getSelector(InvoiceSelectors.ByStripeId.class)
                .setParameter('stripeInvoiceId', invoiceStripeId)
                .query();
    }
}