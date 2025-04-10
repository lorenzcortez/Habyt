@isTest
public without sharing class ContractAgreementController_Test {
    
    @isTest
    public static void getMembershipContract_test() {
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract rentContract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        rentContract.RecordTypeId = CustomerContractService.RT_ID_RENT;
        insert rentContract;

        Contract memberContract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        memberContract.RecordTypeId = CustomerContractService.RT_ID_MEMBERSHIP;
        insert memberContract;
      
        
        Test.startTest();

        Id membershipRetContract = ContractAgreementController.getMembershipContract(rentContract.Id).Id;
        Test.stopTest();

        System.assertEquals(memberContract.Id, membershipRetContract, 'Membership contract');

    }
    @isTest
    public static void activateContract_test() {
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract rentContract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        rentContract.RecordTypeId = CustomerContractService.RT_ID_RENT;
        rentContract.Status = 'Draft';
        rentContract.Community_Step__c = 0;
        insert rentContract;
        Contract contractBeforeAct = [SELECT Status, Community_Step__c
                                    FROM Contract
                                    WHERE Id =: rentContract.Id];

        Test.startTest();

        ContractAgreementController.activateContract(rentContract.Id);
        Test.stopTest();

        Contract contractAfterAct = [SELECT Status, Community_Step__c
                                    FROM Contract
                                    WHERE Id =: rentContract.Id];

        // System.assertNotEquals(contractBeforeAct.Status , contractAfterAct.Status, 'Different Status');
        // System.assertEquals(ContractAgreementController.ACTIVE_STATUS , contractAfterAct.Status, 'Actived Status');

        System.assertNotEquals(contractBeforeAct.Community_Step__c , contractAfterAct.Community_Step__c, 'Different Community Step');
        System.assertEquals(1 , contractAfterAct.Community_Step__c, 'Community Step');

    }

    @isTest
    public static void getURL_test() {
        Id entityId = UserInfo.getUserId();

        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract rentContract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        rentContract.RecordTypeId = CustomerContractService.RT_ID_RENT;
        insert rentContract;

        Contract memberContract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        memberContract.RecordTypeId = CustomerContractService.RT_ID_MEMBERSHIP;
        insert memberContract;
      
        memberContract = [
            SELECT RecordTypeId, Opportunity__r.BrandAuto__c
            FROM Contract
            WHERE Id = :memberContract.Id
        ];

        CustomerContractService contractService = new CustomerContractService();
        String contractDocName = contractService.getContractTitle(memberContract);
        ContentVersion cv = new ContentVersion(
            Title = contractDocName,
            PathOnClient ='test',
            VersionData=EncodingUtil.base64Decode('This is version data'),
            FirstPublishLocationId = entityId
        );
        insert cv;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        if(!documents.isEmpty()){
            ContentDocumentLink contentDocLink =  TestRecord_Factory.createContentDocumentLink(memberContract.Id, documents.get(0).Id);
            insert contentDocLink;
        }
        ContentService service = new ContentService();
        ContentDistribution distro = service.createContentDistribution(cv);
        insert distro;

        Test.startTest();

        ContentDistribution url = ContractAgreementController.getURL(rentContract.Id);
        Test.stopTest();

        System.assertNotEquals(null, url);

    }
}