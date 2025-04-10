@isTest
public class ReissueDisputedInvoiceTest {
    @isTest
    static void scenario(){
        String jsonBody = '{}';
        StripeHttpCalloutMock.setTestMockResponse(200, 'Success', '');
        Test.startTest();
        ReissueDisputedInvoice.duplicateInvoice('1234');
        Test.stopTest();
    }
}