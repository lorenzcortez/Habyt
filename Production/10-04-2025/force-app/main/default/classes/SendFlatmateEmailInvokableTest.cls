@isTest
public with sharing class SendFlatmateEmailInvokableTest {
    @testSetup
    static void setupTestData() {
        Id emailFolderId = [SELECT Id, Name FROM Folder WHERE Type = 'Email' LIMIT 1].Id;
  
        EmailTemplate emailTemplate = new EmailTemplate(
            Name = 'TEST_Email',
            DeveloperName = 'TEST_EMAIL',
            Subject = 'Test Subject',
            HtmlValue = '<p>Hello {{{Contract.FirstNameRecipientAuto__c}}}, your start date is {{{Contract.StartDate}}}.</p>',
            Body = 'This is a test email template.',
            FolderId = emailFolderId,
            TemplateType = 'custom',
            TemplateStyle = 'none'
        );
        insert emailTemplate;
    }
    
    @isTest
    static void testSendFlatmateEmail() {
        Account testAccount = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract rentContract = new Contract(
            Name = 'Test Contract0',
            AccountId = testAccount.Id,
            Room__c = room.Id,
            Opportunity__c = opp.Id,
            Stripe_Account__c = stripeAcc.Id,
            CurrencyIsoCode = 'EUR',
            StartDate = Date.today()
        );
        rentContract.RecordTypeId = CustomerContractService.RT_ID_RENT;
        insert rentContract;

        Contract memberContract = new Contract(
            Name = 'Test Contract1',
            AccountId = testAccount.Id,
            Room__c = room.Id,
            Opportunity__c = opp.Id,
            Stripe_Account__c = stripeAcc.Id,
            CurrencyIsoCode = 'EUR',
            StartDate = Date.today()
        );
        memberContract.RecordTypeId = CustomerContractService.RT_ID_MEMBERSHIP;
        insert memberContract;

        Contract relatedContract = new Contract(
            Name = 'Test Contract2',
            AccountId = testAccount.Id,
            Room__c = room.Id,
            Opportunity__c = opp.Id,
            Stripe_Account__c = stripeAcc.Id,
            CurrencyIsoCode = 'EUR',
            StartDate = Date.today()
        );
        relatedContract.RecordTypeId = CustomerContractService.RT_ID_MEMBERSHIP;
        insert relatedContract;

        EmailTemplate testTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'TEST_Email' LIMIT 1];
        OrgWideEmailAddress orgWideEmail = [SELECT Id FROM  OrgWideEmailAddress WHERE Address = 'support@habyt.com' LIMIT 1];

        
        SendFlatmateEmailInvokable.RequestFlowParam requestParam = new SendFlatmateEmailInvokable.RequestFlowParam();
        requestParam.recordId = memberContract.Id;
        requestParam.contractList = new List<Id>{relatedContract.Id};
        requestParam.templateId = testTemplate.Id;
        requestParam.orgWideId = orgWideEmail.Id;
        
        Test.startTest();
            SendFlatmateEmailInvokable.sendFlatmateEmail(new List<SendFlatmateEmailInvokable.RequestFlowParam>{requestParam});
        Test.stopTest();
    }
}