@isTest
public class UpdateStripeMetadataTest {
    @isTest
    static void scenario(){
        String jsonBody = '{}';
        StripeHttpCalloutMock.setTestMockResponse(200, 'Success', '');
        Test.startTest();
        UpdateStripeMetadata.execute('1234', 'January', '2025');
        Test.stopTest();
    }
}