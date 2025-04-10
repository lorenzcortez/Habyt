@isTest
class IcxEverSignInterfaceTest {
    
    Public	Static	Contract	con;
    
    Static
    {
        Map<String,sObject> testData = TestUtils.getTestData();
        con = (Contract)testData.get('Contract');
    }
    
    /*Static	testmethod	void	testGetDocuments() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        IcxEverSignInterface.GetDocuments();
        Test.stopTest();
    }*/
    
    
    Static	testmethod	void	testGetDocumentUrl() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        IcxEverSignInterface.GetDocumentUrl(con.Id);
        Test.stopTest();
    }
    
    Static	testmethod	void	testGetDocumentSign() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        IcxEverSignInterface.GetDocumentSign(con.Id);
        Test.stopTest();
    }
    
    Static	testmethod	void	testGetContract(){
        IcxEverSignInterface.GetContract(con.Id);
    }
}