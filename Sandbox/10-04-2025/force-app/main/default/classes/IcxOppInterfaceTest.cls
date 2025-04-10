@isTest
class IcxOppInterfaceTest {
    
    Public	Static	Account		acc; 
    Public	Static	Opportunity	opp;
    Public	Static	Property__c	p;
    Public	Static	Room__c		room1, room2;
    
    Static
    {
        Map<String, Object> testData = TestUtils.getTestData();
        acc = (Account) testData.get('Account');
        opp = (Opportunity) testData.get('Opportunity');
        room1 = (Room__c) testData.get('Room__c');
    }
    
    Static	testmethod	void	testGetRoomsWithStatus(){
        IcxOppInterface.getRoomsWithStatus(opp.Id);
    }
    
    Static	testmethod	void	testSetRoomOnOpp(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        
        IcxOppInterface.setRoomOnOpp(opp.Id, room1.Id);
        
        Test.stopTest();
        System.assertEquals(room1.Id, [SELECT Room__c FROM Opportunity WHERE Id = :opp.Id].Room__c);
    }
    
    Static	testmethod	void	testGetAccountEmail() {
        System.assertEquals(acc.PersonEmail, IcxOppInterface.getAccountEmail(opp.Id));
        
    }
    
    Static	testmethod	void	testGetOppsOnThisRoom() {
        IcxOppInterface.getOppsOnThisRoom(room1.Id, opp.Id);
    }
    
    
}