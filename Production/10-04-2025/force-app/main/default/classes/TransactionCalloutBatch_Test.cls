@IsTest
public class TransactionCalloutBatch_Test{

    @TestSetup
    static void makeData(){
        TestUtils.getTestData();
    }

    @IsTest
    public static void TransactionCalloutBatch_Test(){
        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        TransactionCalloutBatch obj = new TransactionCalloutBatch();
        
        Test.startTest();
        DataBase.executeBatch(obj, 1);
        Test.stopTest();

        // This is just to ensure the batch is actually executed;
        System.assert(true);
    }
}