@isTest
public class LWC_MassEmailControllerTest {
    @TestSetup
    static void makeData(){

        Brand__c brand = TestRecord_Factory.iBrand;
        brand.EmailDomain__c = 'habyt.com';
        update brand;

        Property__c property = TestRecord_Factory.createProperty();
        property.Name = 'Test Prop';
        insert property;

        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        room.Property__c = property.Id;
        update room;

        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;
    }

    @isTest
    static void scenario(){
        Contract contract = [SELECT Id, Room__r.Property__r.BrandRef__r.EmailDomain__c FROM Contract WHERE AccountId != null LIMIT 1];
        System.debug('contract contract contract' + contract);
        List<Id> lstRecipients = new List<Id>();
        lstRecipients.add(contract.Id);

        Test.startTest();
        LWC_MassEmailController.getActiveTenants(contract.Id);
        LWC_MassEmailController.sendMassEmail(lstRecipients, 'Test Subject', 'Test Body');
        Test.stopTest();
    }
}