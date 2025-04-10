public class GenerateStripeDiscountBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts, Schedulable {

    public static final Id PRODUCT_ADD_ITEM_RT = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('AdditionalItem').getRecordTypeId();
    public List<String> errorLog = new List<String>();

    public void execute(SchedulableContext sc){
        Database.executeBatch(new GenerateStripeDiscountBatch(), 1);
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        Date today = Date.today();
        Boolean isLastDayOfMonth = today.day() == date.daysInMonth(today.year(), today.month());

        List<String> conditions     = new List<String>();
        // Exluded Id Storage
        List<String> excludedIds    = new List<String>();
        // Query excluded records
        List<Exclude_Generate_Stripe_Discount__mdt> excludeGenerateStripData = [SELECT Id, Billing_Entity_Id__c FROM Exclude_Generate_Stripe_Discount__mdt WHERE Billing_Entity_Id__c != null];
        // Store Ids 
        if( excludeGenerateStripData.size() > 0 ){
            for( Exclude_Generate_Stripe_Discount__mdt exclude : excludeGenerateStripData){
                excludedIds.add(exclude.Billing_Entity_Id__c);
            }   
        }

        // include only items that can and should be synced on this day
        conditions.add('IsSyncableItemAuto__c = TRUE');
        if (! isLastDayOfMonth) {
            conditions.add('(ContractRef__r.StartDate = TOMORROW OR (ContractRef__r.Contract_End_Date__c = TOMORROW AND ProductRef__r.FrequencyPick__c = \'One Off\'))');
        }
        // only include contracts that are "live" now
        conditions.add('ContractRef__r.StartDate <= TOMORROW');
        conditions.add('(ContractRef__r.Contract_End_Date__c >= TODAY OR ContractRef__r.Contract_End_Date__c = null)');
        conditions.add('(ContractRef__r.Status = \'Signed\' OR ContractRef__r.Status = \'Activated\' OR ContractRef__r.Status = \'Terminated\')');
        // only include contracts with stripe details
        conditions.add('ContractRef__r.Stripe_Subscription_Id__c != null');
        conditions.add('ContractRef__r.StripeCustomerId__c != null');


        System.debug('excludedIds' + excludedIds);
        //New condition for exluded contract items
        if( excludedIds.size() > 0 ){
            conditions.add('ContractRef__r.Billing_Entity__c NOT IN :excludedIds');
        }

		List<String> columns = new List<String> {
            'Id',
            'NumberOfMonths__c',
            'TimesRedeemed__c',
            'PriceTrig__c',
            'StripeInvoiceItemId__c',
            'ContractRef__r.StripeCustomerId__c',
            'ContractRef__r.Account.Stripe_Customer_Id__c',
            'Name',
            'ProductRef__r.FrequencyPick__c',
            'ContractRef__r.Stripe_Subscription_Id__c',
            'ContractRef__r.Stripe_Account__r.secret_key__c',
            'Description__c',
            'LastSuccessfulSync__c',
            'ContractRef__r.StartDate',
            'ContractRef__r.CurrencyIsoCode'
        };

        String query = 'SELECT ' + String.join(columns, ', ') + ' FROM ContractItem__c WHERE ' + String.join(conditions, ' AND ');

        System.debug('+++ query: ' + query);
        return Database.getQuerylocator(query);
    } 
    
    public void execute(Database.BatchableContext bc, List<ContractItem__c> scope){
        List<ContractItem__c> lstContractItems = new List<ContractItem__c>();
        for (ContractItem__c iRecord : scope) {
            StripeModels.InvoiceItem stripeInvItem = new StripeModels.InvoiceItem(
                // fallback to Stripe Customer Id on Account until we can get the right one on the Contract
                iRecord.ContractRef__r.StripeCustomerId__c != null ? iRecord.ContractRef__r.StripeCustomerId__c : iRecord.ContractRef__r.Account.Stripe_Customer_Id__c,
                String.valueOf(iRecord.PriceTrig__c),
                iRecord.Description__c,
                iRecord.ContractRef__r.Stripe_Subscription_Id__c,
                iRecord.ContractRef__r.CurrencyIsoCode
            );

            // Push Invoice Item to Stripe
            try {
                iRecord.StripeInvoiceItemId__c = StripeService.createInvoiceItem(stripeInvItem, iRecord.ContractRef__r.Stripe_Account__r.secret_key__c);
                iRecord.TimesRedeemed__c = iRecord.TimesRedeemed__c > 0 ? iRecord.TimesRedeemed__c + 1 : 1;
                iRecord.LastSuccessfulSync__c = Datetime.now();
                lstContractItems.add(iRecord);
                System.debug('+++ iRecord.StripeInvoiceItemId__c added: ' + iRecord.StripeInvoiceItemId__c);
            } catch (Exception e) {
                errorLog.add(e.getMessage() + '. Record: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + iRecord.Id);
                StripeLogHandler.insertStripeLog(e.getMessage(), JSON.serializePretty(stripeInvItem));
            }
        }

        update lstContractItems;
    }
    
    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :bc.getJobId()]; 
        System.debug('+++ GenerateStripeDiscountBatch finish: ' + job.Status);
        sendJobReportViaEmail(job);
    }

    private void sendJobReportViaEmail(AsyncApexJob job){
        String emails = Test.isRunningTest() ? 'test@test.test' : ContractItemBatchNotification__c.getOrgDefaults().Emails__c;
        String emailBody;
        String[] sendingTo = new String[]{};

        // Check emails is not empty
        if (String.isEmpty(emails)) {
            return;
        }
        List<String> lstEmails = emails.trim().split(',');
        for (String iEmail : lstEmails) {
            sendingTo.add(iEmail);
        }
        
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        semail.setToAddresses(sendingTo); 
        semail.setSubject('The contract items sync has been complete with status: ' + job.Status);
        if (errorLog.isEmpty()) {
            emailBody = 'The synchronization with Stripe was successful.'; 
        } else {
            emailBody = 'The synchronization with Stripe had errors.';
            emailBody += 'The synchronization with Stripe had errors.' + '\n';
            for (String iError : errorLog) {
                emailBody += iError + '\n';
            }
            emailBody += '\n';
            emailBody += 'Please contact your salesforce admin.';
        }
        semail.setPlainTextBody('The sync was successful.'); 
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
    }
}