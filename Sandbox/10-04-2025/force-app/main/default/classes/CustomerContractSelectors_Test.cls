@IsTest
public class CustomerContractSelectors_Test {
    @IsTest
    static void ContractItems_UnitTest() {
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;

        Product2 prod = TestRecord_Factory.iProduct;
        ContractItem__c contractItem = TestRecord_Factory.createContractItem(contract, prod.Id, room.Id);
        insert contractItem;
        
        Integer expected = [SELECT COUNT() FROM ContractItem__c WHERE ContractRef__c =: contract.Id];

        Test.startTest();
        
        List<SObject> queried = Paua_SelectorHandler.getSelector(CustomerContractSelectors.ContractItems.class)
            .setParameter('id', contract.Id)
            .query();
        Test.stopTest();
        
        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
    }

    @IsTest
    static void ContractsByOpportunityAndRecordType_UnitTest() {
        Id recordTypeId = Contract.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Rent').getRecordTypeId();
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;
        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        contract.RecordTypeId = recordTypeId;
        insert contract;

        Integer expected = [SELECT COUNT() FROM Contract WHERE Opportunity__c = :opp.Id AND RecordTypeId = :recordTypeId];

        Test.startTest();
        
        List<SObject> queried = Paua_SelectorHandler.getSelector(CustomerContractSelectors.ContractsByOpportunityAndRecordType.class)
            .setParameter('id', opp.Id)
            .setParameter('rtId', recordTypeId)
            .query();

        Test.stopTest();
        
        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
    }

    @IsTest
    static void ContractsByOpportunity_UnitTest() {
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;
        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;

        Set<Id> idSet = new Set<Id>{opp.Id};

        Integer expected = [SELECT COUNT() FROM Contract WHERE Opportunity__c IN :idSet];

        Test.startTest();
        
        List<SObject> queried = Paua_SelectorHandler.getSelector(CustomerContractSelectors.ContractsByOpportunity.class)
            .setParameter('oppIdSet', idSet)
            .query();

        Test.stopTest();
        
        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
    }

    @IsTest
    static void Contracts_UnitTest() {
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;
        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;

        Integer expected = [SELECT COUNT() FROM Contract];

        Test.startTest();
        
        List<SObject> queried = Paua_SelectorHandler.getSelector(CustomerContractSelectors.Contracts.class)
            .setParameter('idSet', new Set<Id>{contract.Id})
            .query();

        Test.stopTest();
        
        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
    }

    @IsTest
    static void ByEndDateAndStatus_UnitTest() {
        Account account = TestRecord_Factory.iPersonAccount;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Room__c room = TestRecord_Factory.iRoom;
        room.TypePick__c = 'Shared Room (2 beds)';
        update room;
        
        Date endDate = System.today().addDays(CustomerContractService.MOVE_IN_DAYS);

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        contract.Contract_End_Date__c = endDate;
        insert contract;

        Set<String> relevantStatuses = new Set<String>{CustomerContractService.STATUS_DRAFT};

        Integer expected = [
            SELECT COUNT() 
            FROM Contract 
            WHERE Contract_End_Date__c = :endDate AND 
                Status in :relevantStatuses AND 
                Room__r.TypePick__c != 'Private Room'
        ];

        Test.startTest();
        List<Contract> queried = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ByEndDateAndStatus.class)
            .setParameter('dateValue', endDate)
            .setParameter('relevantStatuses', relevantStatuses)
            .query(); 

        Test.stopTest();

        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
    }

    @IsTest
    static void ByStartDateAndStatus_UnitTest() {
        Account account = TestRecord_Factory.iPersonAccount;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Room__c room = TestRecord_Factory.iRoom;
        room.TypePick__c = 'Shared Room (2 beds)';
        update room;
        
        Date startDate = System.today();

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        contract.StartDate = startDate;
        insert contract;

        Set<String> relevantStatuses = new Set<String>{CustomerContractService.STATUS_DRAFT};

        Integer expected = [
            SELECT COUNT() 
            FROM Contract 
            WHERE StartDate = :startDate AND 
                Status in :relevantStatuses AND 
                Room__r.TypePick__c != 'Private Room'
        ];

        Test.startTest();
        List<Contract> queried = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ByStartDateAndStatus.class)
            .setParameter('dateValue', startDate)
            .setParameter('relevantStatuses', relevantStatuses)
            .query(); 

        Test.stopTest();

        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
    }

    @IsTest
    static void ByAccountId_UnitTest() {
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;
        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;

        Integer expected = [SELECT COUNT() FROM Contract WHERE AccountId = :account.Id];

        Test.startTest();
        List<Contract> queried = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ByAccountId.class)
            .setParameter('id', account.Id)
            .query(); 

        Test.stopTest();

        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
    }

    @IsTest
    static void ByStartDateStatusAndCountry_UnitTest() {
        Integer expected = 1;
        Set<String> forbiddenStatuses = new Set<String> {
            CustomerContractService.STATUS_CANCELLED, 
            CustomerContractService.STATUS_VOIDED
        };
        Set<String> countries = CustomerContractService.HOUSING_CONFIRMATION_COUNTRIES;

        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        contract.StartDate = System.today();
        insert contract;

        Test.startTest();
        List<Contract> queried = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ByStartDateStatusAndCountry.class)
            .setParameter('forbiddenStatuses', forbiddenStatuses)
            .setParameter('dateValue', System.today())
            .setParameter('countries', countries)
            .query();

        Test.stopTest();

        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
    }

    
    @IsTest
    static void ContractsBySubscriptionId_UnitTest() {
        String subscriptionId = 'sub_00000000000000';
        Integer expected = 1;

        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        contract.Stripe_Subscription_Id__c = subscriptionId;
        insert contract;

        Test.startTest();
        List<Contract> queried = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.BySubscriptionId.class)
                                                                        .setParameter('subscriptionId', subscriptionId)
                                                                        .query();

        Test.stopTest();

        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
        System.assertEquals(subscriptionId, queried.get(0).Stripe_Subscription_Id__c, 'Unexpected number of results');
    }

    @IsTest
    static void byId_UnitTest() {
        Integer expected = 1;

        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;

        Test.startTest();
        List<Contract> queried = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ById.class)
                .setParameter('id', contract.Id)
                .query();
        Test.stopTest();

        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
    }

    @IsTest
    static void ActiveTodayByPropertyOrApartment_UnitTest() {
        Integer expected = 1;

        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Id recordTypeId = Contract.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Rent').getRecordTypeId();
        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        contract.RecordTypeId = recordTypeId;
        insert contract;

        contract.Contract_End_Date__c = null;
        contract.StartDate = System.today();
        contract.Status = CustomerContractService.STATUS_ACTIVATED;
        update contract;

        room = [SELECT Id, Property__c FROM Room__c];

        Test.startTest();
        List<Contract> queried = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ActiveTodayByPropertyOrApartment.class)
                .setParameter('propertyId', room.Property__c)
                .query();
        Test.stopTest();

        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
    }

    @IsTest
    static void ContractItemsNotAdditionalItems_UnitTest() {
        Id rentRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Rent').getRecordTypeId();

        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;

        Product2 product = TestRecord_Factory.createProduct();
        insert product;

        ContractItem__c item1 = TestRecord_Factory.createContractItem(contract, product.Id, room.Id);
        ContractItem__c item2 = TestRecord_Factory.createContractItem(contract, product.Id, room.Id);

        List<ContractItem__c> items = new List<ContractItem__c> {item1, item2};
        insert items;

        Set<Id> idSet = new Set<Id> {items.get(0).Id, items.get(1).Id};
        Integer expected = idSet.size();

        System.debug(items.get(0).ProductRef__r.RecordType.DeveloperName);

        List<ContractItem__c> itemsQ = [
            SELECT Id 
            FROM ContractItem__c
            WHERE ContractRef__c IN :idSet AND ProductRef__r.RecordType.DeveloperName != 'AdditionalItem' 
            ORDER BY ProductRef__r.Name DESC
        ];

        Test.startTest();
        List<ContractItem__c> queried = (List<ContractItem__c>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ContractItemsNotAdditionalItems.class)
                .setParameter('id', contract.Id)
                .query();
        Test.stopTest();

        System.assertEquals(expected, queried.size(), 'Unexpected number of results');
    }
}