@IsTest
public class CustomerOpportunityService_Test {
    @IsTest
    static void createForAccountAndPiece_Illegal_UnitTest(){
        Account account = TestRecord_Factory.iPersonAccount;
        Property__c piece = TestRecord_Factory.iProperty;

        CustomerOpportunityService service = new CustomerOpportunityService();
        Boolean illegalException = false;

        Test.startTest();

        try {
            Opportunity opp = service.createForAccountAndPiece(account, piece, System.today().addMonths(1), null, 'API');
        } catch (IllegalArgumentException e) {
            illegalException = true;
        } catch (Exception e) {
            System.assert(false, 'Unexpected exception catched: ' + e.getMessage());
        }

        Test.stopTest();
        
        System.assert(illegalException, 'IllegalArgumentException not caught');
    }

    @IsTest
    static void createForAccountAndPiece_Success_UnitTest(){
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c piece = TestRecord_Factory.iRoom;

        CustomerOpportunityService service = new CustomerOpportunityService();
        Boolean illegalException = false;

        Test.startTest();

        Opportunity opp;
        try {
            opp = service.createForAccountAndPiece(account, piece, System.today().addMonths(1), null, 'API');
        } catch (IllegalArgumentException e) {
            illegalException = true;
        }

        Test.stopTest();
        
        System.assert(! illegalException, 'IllegalArgumentException caught');
        System.assertNotEquals(null, opp, 'Opportunity not created');
        System.assertEquals(piece.Id, opp.Room__c, 'Room__c not properly set');
        System.assertEquals(null, opp.ApartmentRef__c, 'ApartmentRef__c not properly set');
    }
}