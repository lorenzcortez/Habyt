public class StripeInvoiceEventHandler extends StripeAbstractEventHandler {

    public static final String DEPOSIT_INVOICE_TYPE = 'Deposit';
    public static final String RENT_INVOICE_TYPE = 'Rent';
    public static final Integer AMOUNT_DIVIDER = 100;
    public static final String DATE_UNIX_TAIL = '000';
    public static final String TYPE_UPDATED_WEBHOOK = 'invoice.updated';
    public static final String INVOICE_PAID_STATUS = 'paid';
    public static final String INVOICE_OPEN_STATUS = 'open';
    public static final Set<String> ALLOWED_METADATA_POSITIVE_ANSWERS = new Set<String> {'yes', 'true', 'ja'};
    public static final String DEPOSIT_PRODUCT_NAME = 'Deposit';
    
    /**
     * This method handles the stripe webhook message. This method is called dynamically from the StripeEventHandler, 
     * that dynamically determinates based on webhook type what handler should be instantiated.
     * 
     * This method and class handles the Invoice Payload and uses StripeModels.InvoiceEventData for json parsing.
     * 
     * @param eventData     JSON as string from the stripe webhook
     */
    public override void handle(String eventData){
        if(! shouldHandleEvent(eventData)) {
            return;
        }

        String createdString = retrieveCreatedForEvent(eventData);
        eventData = preProcessJson(eventData);
        String dataObjectString = parseToEventDataString(eventData);
        StripeModels.InvoiceEventData invoiceData = (StripeModels.InvoiceEventData) JSON.deserialize(
            dataObjectString, StripeModels.InvoiceEventData.class
        );

        Invoice__c invoice = constructInvoice(invoiceData, createdString);
        List<Invoice__c> invoices = queryInvoiceByStripeId(invoice.Stripe_Invoice_Id__c);
        Map<Boolean, Datetime> createdMap = createdDateLatest(createdString, invoices);
        if(createdMap.containsKey(false)) {
            if (createdMap.get(false) != null) {
                update new Invoice__c(Id = invoices[0].Id, StripeFirstCreatedDatetime__c = createdMap.get(false));
            }
            return;
        }
        if (createdMap.get(true) != null) {
            invoice.StripeFirstCreatedDatetime__c = createdMap.get(true);
        }
        if(invoiceData.subscription != null) {
            addContractToInvoice(invoice, invoiceData.subscription);
        }

        if(invoice.Account__c == null) {
            updateInvoiceAccount(invoice, invoiceData);
        }

        List<InvoiceItem__c> invoiceItems = createInvoiceItems(invoiceData);
        if(invoice.Stripe_Invoice_Id__c == null) {
            insert invoice;
            addInvoiceToInvoiceItems(invoiceItems, invoice.Id);
        } else {
            Database.upsert(new List<Invoice__c> {invoice}, Invoice__c.Stripe_Invoice_Id__c, true);
        }

        upsert invoiceItems InvoiceItem__c.Stripe_Id__c;
    }

    /**
     * This method is used to associate received invoice items from Stripe with the invoice. As response invoice items
     * are always part of the invoice payload and are stored under "lines".
     * 
     * @param invoiceItems      List of items from webhook.
     * @param invoiceId         Can be null.
     */
    private void addInvoiceToInvoiceItems(List<InvoiceItem__c> invoiceItems, Id invoiceId) {
        for(InvoiceItem__c item : invoiceItems) {
            item.Invoice__r = null;
            item.Invoice__c = invoiceId;
        }
    }

    /**
     * This method is used to find the right contract for the invoice. Every Invoice must be associated with a contract
     * in Salesforce. 
     *  
     * @param invoice           Received invoice object from Stripe.
     * @param subscription      Is usually stored Stripe_Subscription_Id__c field of the contract. Can't be null.
     */
    private void addContractToInvoice(Invoice__c invoice, String subscription) {
        Contract contract =  searchForContract(subscription);

        if(contract != null) {
            invoice.Contract__c = contract.Id;
            invoice.Account__c = contract.AccountId;
        }
    }

    /**
     * The method is used to create invoice items from the invoice payload that was received from stripe. Invoice items
     * are upserted based on Stripe_Id__c later, therefore either line.id or line.invoice_item must be defined.
     *
     * @param invoiceData       Must have id or invoice_item defined. Can't be null.
     * @return                  List of invoice items records to insert.
     * */
    private List<InvoiceItem__c> createInvoiceItems(StripeModels.InvoiceEventData invoiceData) {
        List<InvoiceItem__c> items = new List<InvoiceItem__c>();
        
        for (StripeModels.InvoiceItemData line : invoiceData.lines.data) {
            items.add(
                new InvoiceItem__c(
                    Invoice__r = new Invoice__c(Stripe_Invoice_Id__c = invoiceData.id), 
                    Description__c = line.description, 
                    Stripe_Id__c = line.invoice_item == null ? line.id : line.invoice_item, 
                    Amount__c = (line.amount == null ? 0 : line.amount) / AMOUNT_DIVIDER,
                    StripeCustomerId__c = invoiceData.customer,
                    Currency__c = line.currency_x.toUpperCase(),
                    PeriodStart__c = Date.valueOf(DateTime.newInstance(Long.valueOf(line.period.start + DATE_UNIX_TAIL))),
                    PeriodEnd__c = Date.valueOf(DateTime.newInstance(Long.valueOf(line.period.end_x + DATE_UNIX_TAIL))),
                    Quantity__c = line.quantity
                )
            );
        }

        return items;
    }

    /**
     * The method is used to update an invoice with the account relationship. As every invoice is related to a customer in
     * stripe, we also enforce this behavior in Salesforce. For this reason, if either customer id or email is not found
     * in Salesforce, an exception is thrown. In contrast to Contracts we only search in StripeCustomerJSONMap__c field
     * for customer id.
     *
     * @param invoice       Invoice that will be related to an account.
     * @param invoiceData   Stripe invoice payload. Must have a customer or customer_email. Can't be null.
     * */
    private void updateInvoiceAccount(Invoice__c invoice, StripeModels.InvoiceEventData invoiceData) {
        List<Account> accounts = findAccountsByCustomerId(invoiceData.customer);
        String customerIdMap = constructCustomerJsonString(invoiceData.id, invoiceData.customer);

        if (accounts.isEmpty()) {
            accounts = Paua_SelectorHandler.getSelector(AccountIntegrationSelectors.ByPersonEmail.class)
                                            .setParameter('personEmail', invoiceData.customer_email)
                                            .query();
        }

        if (accounts.isEmpty()) {
            throw new StripeEventHandler.CustomerNotFoundException(
                'Customer Not Found:' + invoiceData.customer_email + ' / ' + invoiceData.customer
            );
        } 

        invoice.Account__c = accounts[0].Id;
        accounts[0].StripeCustomerJSONMap__c = customerIdMap;
    }

    private String constructCustomerJsonString(String invoiceId, String invoiceDataCustomer) {
        return invoiceId == null ? '' : JSON.serialize(new Map<String, String> {invoiceId => invoiceDataCustomer});
    }

    /**
     * This method is used as part of the process for parsing stripe webhooks. The dates are sent as Unix timestamp,
     * therefore we need to add DATE_UNIX_TAIL to parse them.
     *
     * @param invoiceData       Payload from Stripe Invoice Event.
     * @param createdString      String in UNIX time with a date from the new event.
     * @return                  Invoice record created from payload.
     * */
    private Invoice__c constructInvoice(StripeModels.InvoiceEventData invoiceData, String createdString) {
        String invoiceDateString = (invoiceData.due_date != null ? invoiceData.due_date : invoiceData.created) + DATE_UNIX_TAIL;
        Date invoiceDate = Date.valueOf(DateTime.valueOf(Long.valueOf(invoiceDateString)));
        Date paymentDate = null;
        if(invoiceData.status_transitions?.paid_at != null) {
            paymentDate = Date.valueOf(DateTime.valueOf(Long.valueOf(invoiceData.status_transitions.paid_at + DATE_UNIX_TAIL)));
        }
        Decimal amountDue = (invoiceData.amount_due == null ? 0 : invoiceData.amount_due) / AMOUNT_DIVIDER;
        Decimal amountPaid = (invoiceData.amount_paid == null ? 0 : invoiceData.amount_paid) / AMOUNT_DIVIDER;

        String invoiceType = invoiceData.metadata.invoiceType != null ? invoiceData.metadata.invoiceType : RENT_INVOICE_TYPE;

        Id contractId = invoiceData.metadata.ContractId;

        Date periodStart = Date.valueOf(DateTime.newInstance(Long.valueOf(invoiceData.period_start + DATE_UNIX_TAIL)));
        Date periodEnd = Date.valueOf(DateTime.newInstance(Long.valueOf(invoiceData.period_end + DATE_UNIX_TAIL)));
        DateTime stripeCreatedDate = DateTime.newInstance(Long.valueOf(createdString + DATE_UNIX_TAIL));

        Invoice__c invoice = new Invoice__c(
            Stripe_Invoice_Id__c = invoiceData.id,
            Name = invoiceData.number_x, 
            Invoice_Date__c = invoiceDate, 
            Amount_Due__c = amountDue, 
            Amount_Paid__c = amountPaid, 
            PaymentStatus__c = invoiceData.status, 
            PaymentDate__c = paymentDate, 
            Type__c = invoiceType, 
            Manual_Payment_URL__c = invoiceData.hosted_invoice_url, 
            PDF__c = invoiceData.invoice_pdf,
            PeriodEnd__c = periodEnd,
            PeriodStart__c = periodStart,
            BillingMethod__c = invoiceData.billing_reason,
            SubscriptionId__c = invoiceData.subscription,
            CreatedInStripe__c = stripeCreatedDate,
            ContractId__c = contractId
        );

        if (contractId != null) {
            invoice.Contract__c = contractId;
        }

        return invoice;
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
     * This method is used to check if the invoice has a related contract with the subscription id from invoice webhook
     * event.
     *
     * @param subscriptionId    Can't be null.
     * @return                  Single contract or null if nothing found.
     * */
    private Contract searchForContract(String subscriptionId) {
        List<Contract> searchList = findContractsBySubscriptionId(subscriptionId);
        return searchList.size() > 0 ? searchList.get(0) : null;
    }

    /**
     * This method is called as part of searching for related contract to an invoice from stripe webhook.
     *
     * @param subscriptionId    Can't be null.
     * @return                  List of contracts with matching subscription id.
     * */
    private List<Contract> findContractsBySubscriptionId(String subscriptionId){    
        List<Contract> contracts = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.BySubscriptionId.class)
            .setParameter('subscriptionId', subscriptionId)
            .query();

        return contracts;
    }

    /**
     * It's enough to handle only the `invoice.updated` events as we parse all the invoice data
     * from the payload every time and update the invoice record in our system with the new data.
     * This will also filter out `invoice.upcoming` events which don't have an invoice ID in the payload.
     * 
     * @param eventData     Can't be null.
     * @return              True if the invoice was sent.
     */
    private Boolean shouldHandleEvent(String eventData) {
        return eventData.contains(TYPE_UPDATED_WEBHOOK);
    }

    /**
     * The method is used to ensure that only the latest data is stored on the invoice from webhook.
     * 
     * @param createdString      String in UNIX time with a date from the new event.
     * @param invoices           One or zero invoices as a list.
     * @return                   True if there is no invoice with such invoice with a stripe id, or if the created date is
     *                           empty, or if the invoice is not the latest one. Otherwise false.
     */
    private Map<Boolean, Datetime> createdDateLatest(String createdString, List<Invoice__c> invoices) {
        DateTime createdNewEvent = DateTime.newInstance(Long.valueOf(createdString + DATE_UNIX_TAIL));

        if(invoices.size() == 0) {
            return new Map<Boolean, Datetime>{true => createdNewEvent};
        }

        Invoice__c existingInvoice = invoices.get(0);

        return new Map<Boolean, Datetime>{createdNewEvent >= existingInvoice.CreatedInStripe__c || existingInvoice.CreatedInStripe__c == null => existingInvoice.StripeFirstCreatedDatetime__c > createdNewEvent ? createdNewEvent : null};
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
     * This method is used to update the invoices that are reparented to the new deposit object.
     * 
     * @param invoices   Can't be null, otherwise exception.
     * */
    private void updateInvoices(List<Invoice__c> invoices) {
        Paua_Transaction trans = new Paua_Transaction();
        trans.setPreferredOrder(new List<SObjectType> {Invoice__c.SObjectType});
        trans.addForUpdate(invoices);
        trans.commitRecords();
    }

    /**
     * This method is part of the process for checking if we save only the most recent webhooks.
     * 
     * @param invoiceStripeId       Can't be null, otherwise Exception in Paua-Framework.
     * @return                      List of invoices. Never null. Should contain one or zero invoices.
     */
    private List<Invoice__c> queryInvoiceByStripeId(String invoiceStripeId) {
        return (List<Invoice__c>) Paua_SelectorHandler.getSelector(InvoiceSelectors.ByStripeId.class)
                                                      .setParameter('stripeInvoiceId', invoiceStripeId)
                                                      .query();
    }
    
    /**
     * This method is part of the process for checking if we save only the most recent webhooks.
     * 
     * @param ids          Can't be null, otherwise Exception in Paua-Framework.
     * @return             List of invoices. Never null.
     */
    private List<Invoice__c> queryInvoicesById(Set<Id> idSet) {
        return (List<Invoice__c>) Paua_SelectorHandler.getSelector(InvoiceSelectors.ById.class)
                                                      .setParameter('idSet', idSet)
                                                      .query();
    }

    /**
     * This method is used in a process of creating a deposit record on arrival of the invoice.
     *
     * @param contractId    Can't be null.
     * @return              One or zero contracts. Never null.
     * */
    private List<Contract> queryContractById(Id contractId) {
        return (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ById.class)
                                                    .setParameter('id', contractId)
                                                    .query();
    }
}