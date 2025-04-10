@isTest
public class CancelSubscriptionTest {

    
    Static	testmethod	void	testCancelSubscription(){
        Stripe_Account__c stripeAccount = new Stripe_Account__c(secret_key__c = 'test_key');
        insert stripeAccount;
        Account acc = new Account(LastName = 'TestAcc');
        insert	acc;
        Contract con = new Contract(AccountId = acc.Id, Status = 'Draft', StartDate = Date.today(), ContractTerm = 6, Stripe_Subscription_Id__c = 'sub_TEST', Stripe_Account__c = stripeAccount.Id);
		insert con;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        CancelSubscription.CancelSubscription(con.Id, date.today(), date.today());
        Test.stopTest();
    }
}