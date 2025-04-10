@isTest
public class GeneraricAPIInvokableTest {
    @isTest
    static void scenario(  ){

        HttpMockFactory mock = new HttpMockFactory(200, 'OK', '{"contract_item_id" : "test"}', new Map<String,String>());
        Test.setMock(HttpCalloutMock.class, mock);

        SubscriptionsSettings__c setting = new SubscriptionsSettings__c();
        setting.SFDC_Insert_URL__c = 'testinsert.com';
        setting.SFDC_Update__c = 'testupdate.com';
        insert setting;

        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        contract.StartDate = System.today().addDays(15);
        insert contract;
        Product2 prod = TestRecord_Factory.iProduct;
        prod.CurrencyIsoCode = 'EUR';
        update prod;
        
        Product2 prod2 = TestRecord_Factory.createProduct();
        prod2.Name = ContractPDFFromContractController.DEPOSIT_PROD;
        prod2.CurrencyIsoCode = 'EUR';
        insert prod2;

        Product2 prod3 = TestRecord_Factory.createProduct();
        prod3.Name = ContractPDFFromContractController.DISCOUNT_PROD;
        prod3.CurrencyIsoCode = 'EUR';
        insert prod3;

        List<ContractItem__c> contractItems = new List<ContractItem__c> ();
        ContractItem__c item1 = TestRecord_Factory.createContractItem(contract, prod.Id, room.Id);
        ContractItem__c item2 = TestRecord_Factory.createContractItem(contract, prod2.Id, room.Id);
        ContractItem__c item3 = TestRecord_Factory.createContractItem(contract, prod3.Id, room.Id);
        contractItems.add(item1);
        contractItems.add(item2);
        contractItems.add(item3);

        insert contractItems;
    }
}