public with sharing class SyncStripeInvoicesBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    Map<String, String> privateKeys;

    public SyncStripeInvoicesBatch() {
        privateKeys = new Map<String, String>();
        for (Stripe_Account__c stripeAccount : [SELECT Id, secret_key__c, Name FROM Stripe_Account__c WHERE secret_key__c != NULL]) {
            privateKeys.put(stripeAccount.Name, stripeAccount.secret_key__c);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQuerylocator([
                SELECT Id, Stripe_Invoice_Id__c, SubscriptionId__c, ContractId__c FROM Invoice__c WHERE SubscriptionId__c = NULL AND ContractId__c = NULL AND Stripe_Invoice_Id__c != NULL
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Invoice__c> invoices){
        List<Invoice__c> invoicesToUpdate = new List<Invoice__c>();
        for (Invoice__c invoice : invoices) {
            for (String privateKey : privateKeys.values()) {
                String invoiceResponse = getFromStripe('https://api.stripe.com/v1/invoices/'+invoice.Stripe_Invoice_Id__c, privateKey);
                if (invoiceResponse.contains('error') && invoiceResponse.contains('message')) {
                    continue;
                }
                InvoiceData invoiceData = (InvoiceData) JSON.deserialize(
                        invoiceResponse, InvoiceData.class
                );
                System.debug(invoiceData);
                invoice.SubscriptionId__c = invoiceData?.subscription != null ? invoiceData.subscription : invoice.SubscriptionId__c;
                invoice.ContractId__c = invoiceData?.metadata?.ContractId != null ? invoiceData.metadata.ContractId : invoice.ContractId__c;
                System.debug(invoice);
                invoicesToUpdate.add(invoice);
                break;
            }
        }
        update invoicesToUpdate;
    }

    public void finish(Database.BatchableContext bc){

    }

    private String getFromStripe(String url, String key) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + key);
        req.setHeader('Stripe-Version', '2020-08-27 ');
        req.setTimeout(100000);
        if (!Test.isRunningTest()) {
            res = h.send(req);
        }
        return !Test.isRunningTest() ? res.getBody() : getInvoiceTestData();
    }

    private String getInvoiceTestData() {
        MetaData metaData = new MetaData('1234');
        InvoiceData invoiceData = new InvoiceData('24243423432', metaData);
        return JSON.serialize(invoiceData);
    }

    class InvoiceData {
        public String subscription;
        public MetaData metadata;

        public InvoiceData (String subscription, MetaData metadata) {
            this.subscription = subscription;
            this.metadata = metadata;
        }
    }

    class MetaData {
        public String ContractId;

        public MetaData(String ContractId) {
            this.ContractId = ContractId;
        }
    }

}