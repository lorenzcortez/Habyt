public class SyncStripeInvoiceItemsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    public Database.Querylocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Stripe_Invoice_Id__c, StripeAccount__r.secret_key__c FROM Invoice__c ' +
            'WHERE Stripe_Invoice_Id__c != null ' +
            'AND StripeAccount__r.secret_key__c != null';
        return Database.getQuerylocator(query);
    } 
    
    public void execute(Database.BatchableContext bc, List<Invoice__c> scope){
        
        for (Invoice__c iInvoice : scope) {
            SyncStripeInvItemsJSONResponse response;
            try {
                response = StripeService.getInvoiceItemsRelatedToAnInvoice(iInvoice.Stripe_Invoice_Id__c, iInvoice.StripeAccount__r.secret_key__c);
                System.debug('+++ response: ' + response);
            } catch (StripeService.StripeErrorException e) {
                System.debug('+++ Error with Invoice: ' + iInvoice.Id + '. Error: ' + e.getMessage());
                continue;
            }

            // Check if the response has invoice items
            if(response.data != null && response.data.isEmpty()){
                continue;
            }

            List<InvoiceItem__c> lstInvoiceItems = createInvoiceItems(response.data);
            if (!lstInvoiceItems.isEmpty()) {
                upsert lstInvoiceItems Stripe_Id__c;
                System.debug('+++ lstInvoiceItems: ' + lstInvoiceItems);
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
        System.debug('+++ SyncStripeInvoiceItemsBatch finish: ' + job.Status);
    }

    private List<InvoiceItem__c> createInvoiceItems(List<SyncStripeInvItemsJSONResponse.InvoiceItem> invoiceData) {
        List<InvoiceItem__c> items = new List<InvoiceItem__c>();
        
        for (SyncStripeInvItemsJSONResponse.InvoiceItem line : invoiceData) {
            System.debug('+++ ii: ' + line);

            InvoiceItem__c newInvItem = new InvoiceItem__c();
            newInvItem.Invoice__r = new Invoice__c(Stripe_Invoice_Id__c = line.invoice);
            newInvItem.Description__c = line.description;
            newInvItem.Stripe_Id__c = line.id; 
            newInvItem.Quantity__c = line.quantity;
            newInvItem.StripeCustomerId__c = line.customer;
            newInvItem.PeriodStart__c = Date.valueOf(DateTime.newInstance(Long.valueOf(line.period.start + StripeInvoiceEventHandler.DATE_UNIX_TAIL)));
            if (line.currency_Z != null) {
                newInvItem.Currency__c = line.currency_Z.toUpperCase();
            }
            if (line.amount != null) {
                newInvItem.Amount__c = line.amount / StripeInvoiceEventHandler.AMOUNT_DIVIDER;
            }
            if (line.period.end_Z != null) {
                newInvItem.PeriodEnd__c = Date.valueOf(DateTime.newInstance(Long.valueOf(line.period.end_Z + StripeInvoiceEventHandler.DATE_UNIX_TAIL)));
            }
            items.add(newInvItem);
        }

        return items;
    }
}