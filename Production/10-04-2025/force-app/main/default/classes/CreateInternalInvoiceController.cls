public with sharing class CreateInternalInvoiceController {
   @AuraEnabled
   public static String createInvoice(String recordId, String jsonBody){
    try {
        String invoiceId = '';
        List<Contract> contracts = [SELECT Id, Name, ContractNumber,Property__c, AccountId, CurrencyIsoCode FROM Contract WHERE Id = :recordId];

        if(contracts.size() > 0){
            Contract contract = contracts[0];

            String propertiesQuery = 'Select Id,CurrencyIsoCode FROM Property__c';
            if(!Test.isRunningTest()){
                 propertiesQuery += ' WHERE Id = \'' + contract.Property__c + '\'';
            }

            List<Property__c> properties = Database.query(propertiesQuery);
            Property__c property = properties[0];
            Map<String, Object> mapOfData = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
            System.debug('mapOfData'  + mapOfData);

            Invoice__c invoice = new Invoice__c();
            invoice.Name = contract.ContractNumber;
            invoice.Type__c = (String) mapOfData.get('invoiceType');
            
            invoice.Billing_Month__c = String.valueOf(mapOfData.get('billingMonth'));
            invoice.Billing_Year__c =  String.valueOf(mapOfData.get('billingYear'));

            if((String) mapOfData.get('invoiceType') == 'Deposit'){
                invoice.Billing_Month__c = (String) mapOfData.get('billingMonth');
                invoice.Billing_Year__c = (String) mapOfData.get('billingYear');
            }
            if((String) mapOfData.get('billingMethod') == 'send_invoice'){
                invoice.DueDate__c = Date.valueOf((String) mapOfData.get('dueDate'));
            }
            invoice.CollectionMethod__c = 'send_invoice';
            invoice.Status__c = 'Open';
            invoice.Currency__c = property.CurrencyIsoCode;
            invoice.CurrencyIsoCode =    property.CurrencyIsoCode;
            invoice.Account__c = contract.AccountId;
            invoice.Contract__c = contract.Id;
			System.debug('***** '+invoice);
            insert invoice;
            //invoice.Stripe_Invoice_Id__c = invoice.Id;
            invoice.External_Id__c = invoice.Id;
            update invoice;
            invoiceId = invoice.Id;

            List<InvoiceItem__c> listOfInvoiceLineItems = new List<InvoiceItem__c>();   
            List<Object> lineItems = (List<Object>) mapOfData.get('lineItems');
            if (lineItems.size() > 0) {
                for(Object obj : lineItems){
                    Map<String, Object> mapOfLineItems = (Map<String, Object>) obj;
                    InvoiceItem__c invLineItm = new InvoiceItem__c();
                    //invLineItm.StripeInvoiceId__c = invoiceId;
                    invLineItm.External_Id__c = invoiceId;
                    invLineItm.Invoice__c  = invoiceId;
                    invLineItm.Amount__c = (Decimal) mapOfLineItems.get('amount');
                    invLineItm.Description__c = (String) mapOfLineItems.get('description');
                    invLineItm.Currency__c = property.CurrencyIsoCode;
                    invLineItm.CurrencyIsoCode = property.CurrencyIsoCode;
                    listOfInvoiceLineItems.add(invLineItm);
                }
            }

            System.debug('listOfInvoiceLineItems' + listOfInvoiceLineItems);
            if (listOfInvoiceLineItems.size() > 0) {
                insert listOfInvoiceLineItems;
            }
        }

        return invoiceId;

    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
   }
}