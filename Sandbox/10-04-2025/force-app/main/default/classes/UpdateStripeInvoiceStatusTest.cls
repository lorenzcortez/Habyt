@isTest
public class UpdateStripeInvoiceStatusTest {
    @isTest
    static void scenario(){
        String jsonBody = '{}';
        StripeHttpCalloutMock.setTestMockResponse(200, 'Success', '');
        Test.startTest();
        UpdateStripeInvoiceStatus.updateInvoiceStatus('1234', 'void');
        Test.stopTest();
    }
}