@isTest
public class CreateStripeInvoiceControllerTest {
    @isTest
    static void scenario(){
        String jsonBody = '{"contractNumber": "00105008", "invoiceType": "Rent", "billingMethod": "send_invoice", "dueDate": "2024-11-10","lineItems": [{"amount": 100.10, "description": "October Rent"}]}';
        StripeHttpCalloutMock.setTestMockResponse(200, 'Success', '');
        Test.startTest();
        CreateStripeInvoiceController.createInvoice(jsonBody);
        Test.stopTest();
    }
}