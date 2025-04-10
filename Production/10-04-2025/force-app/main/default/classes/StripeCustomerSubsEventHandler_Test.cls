@IsTest
public with sharing class StripeCustomerSubsEventHandler_Test {
    @TestSetup
    static void setupTest() {
        Account account = TestRecord_Factory.iAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc = TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;
    }

    @IsTest
    public static void customerId_UnitTest() {
        String customerId = 'cus_qocgzfaSoC14jv';
        String subscriptionId = 'sub_1J5AnUI4AG1fjzDfxcIQcclH';
        String expectedStatus = 'active';

        Contract contract = [
            SELECT Id, StripeCustomerJSONMap__c, AccountId
            FROM Contract
            LIMIT 1
        ];
        contract.StripeCustomerJSONMap__c = customerId;
        update contract;

        String eventData = '{"id":"evt_1CiPtv2eZvKYlo2CcUZsDcO6","object":"event",' +
                            '"data":{"object":{"id":"' + subscriptionId + '","status":"' + expectedStatus +
                            '", "customer": "' + customerId + '"}}, "type": "customer.subscription.updated"}';

        
        Test.setFixedSearchResults(new List<String>{contract.Id, contract.AccountId});
        Test.startTest();
        StripeEventHandler.handle(eventData);
        Test.stopTest();

        contract = [
            SELECT Id, Stripe_Subscription_Status__c, StripeCustomerJSONMap__c
            FROM Contract
            WHERE Id = :contract.Id
            LIMIT 1
        ];
        System.assertEquals(expectedStatus, contract.Stripe_Subscription_Status__c); 
    }

    @IsTest
    public static void subscriptionId_UnitTest() {
        String subscriptionId = 'sub_1J5AnUI4AG1fjzDfxcIQcclH';
        String customerId = 'cus_qocgzfaSoC14jv';
        String expectedStatus = 'active';

        Contract contract = [
            SELECT Id, StripeCustomerJSONMap__c, AccountId, Stripe_Subscription_Id__c
            FROM Contract
            LIMIT 1
        ];
        contract.Stripe_Subscription_Id__c = subscriptionId;
        update contract;

        String eventData = '{"id":"evt_1CiPtv2eZvKYlo2CcUZsDcO6","object":"event",' +
                            '"data":{"object":{"id":"' + subscriptionId + '","status":"' + expectedStatus + 
                            '", "customer": "' + customerId + '"}}, "type": "customer.subscription.active"}';

        
        Test.setFixedSearchResults(new List<Id>{contract.Id, contract.AccountId});
        Test.startTest();
        StripeEventHandler.handle(eventData);
        Test.stopTest();

        contract = [
            SELECT Id, Stripe_Subscription_Status__c, StripeCustomerJSONMap__c
            FROM Contract
            WHERE Id = :contract.Id
            LIMIT 1
        ];
        System.assertEquals(expectedStatus, contract.Stripe_Subscription_Status__c); 
    }

    @IsTest
    public static void exception_UnitTest() {
        String subscriptionId = 'sub_1J5AnUI4AG1fjzDfxcIQcclH';
        String customerId = 'cus_qocgzfaSoC14jv';
        String expectedStatus = 'active';

        Contract contract = [
            SELECT Id, StripeCustomerJSONMap__c, AccountId, Stripe_Subscription_Id__c
            FROM Contract
            LIMIT 1
        ];
        System.debug(contract);
        String eventData = '{"id":"evt_1CiPtv2eZvKYlo2CcUZsDcO6","object":"event",' +
                            '"data":{"object":{"id":"' + subscriptionId + '","status":"' + expectedStatus + 
                            '", "customer": "' + customerId + '"}}, "type": "customer.subscription.active"}';

        
        Test.setFixedSearchResults(new List<Id>{contract.Id, contract.AccountId});
        Test.startTest();
        try {
            StripeEventHandler.handle(eventData);
            System.assert(false);
        } catch(StripeEventHandler.UnknownCustomerIdException e) {
            System.assert(true);
        }
        Test.stopTest();
    }
}