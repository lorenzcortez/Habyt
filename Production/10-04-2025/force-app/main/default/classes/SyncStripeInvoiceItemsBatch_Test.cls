@IsTest
public class SyncStripeInvoiceItemsBatch_Test{
    @TestSetup
    public static void makeData(){
        Stripe_Account__c mediciLivingTestAcc = new Stripe_Account__c(secret_key__c = 'mediciTest123');
        insert mediciLivingTestAcc;
    }

    @IsTest
    public static void syncStripeInvoiceItems_GoodTest_1(){
        Test.setMock(HttpCalloutMock.class, new SyncStripeInvoiceItemsMockGenerator());
        Decimal amount_invitem_1 = -100.50;
        Decimal amount_invitem_2 = 120.00;

        List<Stripe_Account__c> lstStrAcc = [SELECT Id FROM Stripe_Account__c];
        System.assertEquals(1, lstStrAcc.size(), 'There should be only one Stripe Account.');
        Stripe_Account__c mediciLivingTestAcc = lstStrAcc.get(0);

        Invoice__c inv = new Invoice__c(Stripe_Invoice_Id__c = SyncStripeInvoiceItemsMockGenerator.GOOD_INVOICE_ID_1, StripeAccount__c = mediciLivingTestAcc.Id);
        insert inv;

        Test.startTest();
        Id syncJobId = Database.executeBatch(new SyncStripeInvoiceItemsBatch(), 1);
        Test.stopTest();

        List<InvoiceItem__c> lstInvItems = [SELECT Id, Amount__c, Stripe_Id__c FROM InvoiceItem__c WHERE Invoice__c = :inv.Id];
        System.assertEquals(4, lstInvItems.size(), 'The Job should insert 4 Invoice Items.');

        for (InvoiceItem__c invItem : lstInvItems) {
            if (invItem.Stripe_Id__c == 'ii_idtest_123123123') {
                System.assertEquals(amount_invitem_1, invItem.Amount__c, 'The amount should be -100,50.');
            } else if (invItem.Stripe_Id__c == 'ii_idtest_456456456') {
                System.assertEquals(amount_invitem_2, invItem.Amount__c, 'The amount should be 120,00.');
            }
        }
    }

    @IsTest
    public static void syncStripeInvoiceItems_GoodTest_2(){
        Test.setMock(HttpCalloutMock.class, new SyncStripeInvoiceItemsMockGenerator());

        List<Stripe_Account__c> lstStrAcc = [SELECT Id FROM Stripe_Account__c];
        System.assertEquals(1, lstStrAcc.size(), 'There should be only one Stripe Account.');
        Stripe_Account__c mediciLivingTestAcc = lstStrAcc.get(0);

        Invoice__c inv = new Invoice__c(Stripe_Invoice_Id__c = SyncStripeInvoiceItemsMockGenerator.GOOD_INVOICE_ID_2, StripeAccount__c = mediciLivingTestAcc.Id);
        insert inv;

        Test.startTest();
        Id syncJobId = Database.executeBatch(new SyncStripeInvoiceItemsBatch(), 1);
        Test.stopTest();

        List<InvoiceItem__c> lstInvItems = [SELECT Id, Amount__c, Stripe_Id__c FROM InvoiceItem__c WHERE Invoice__c = :inv.Id];
        System.assertEquals(1, lstInvItems.size(), 'The Job should insert 1 Invoice Items.');
    }

    @IsTest
    public static void syncStripeInvoiceItems_ErrorTest_1(){
        Test.setMock(HttpCalloutMock.class, new SyncStripeInvoiceItemsMockGenerator());

        List<Stripe_Account__c> lstStrAcc = [SELECT Id FROM Stripe_Account__c];
        System.assertEquals(1, lstStrAcc.size(), 'There should be only one Stripe Account.');
        Stripe_Account__c mediciLivingTestAcc = lstStrAcc.get(0);

        Invoice__c inv = new Invoice__c(Stripe_Invoice_Id__c = SyncStripeInvoiceItemsMockGenerator.BAD_INVOICE_ID_1 , StripeAccount__c = mediciLivingTestAcc.Id);
        insert inv;

        List<StripeIntegrationLog__c> lstStripeIntegrationLogs = [SELECT Id FROM StripeIntegrationLog__c];
        System.assertEquals(0, lstStripeIntegrationLogs.size(), 'There shouldn\'t exist any Stripe Logs at this moment.');

        Test.startTest();
        Id syncJobId = Database.executeBatch(new SyncStripeInvoiceItemsBatch(), 1);
        Test.stopTest();

        lstStripeIntegrationLogs = [SELECT Id, ErrorMessage__c FROM StripeIntegrationLog__c];
        System.assertEquals(1, lstStripeIntegrationLogs.size(), 'There should exist one Stripe Logs at this moment.');
        System.assertEquals('No such invoice: \' ' + SyncStripeInvoiceItemsMockGenerator.BAD_INVOICE_ID_1 + ' \'', lstStripeIntegrationLogs.get(0).ErrorMessage__c, 'The Stripe Log error message is different than the expected.');
    }
}