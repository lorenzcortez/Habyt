@isTest public class PropertyAfterInsertTest {
    
    @isTest
    private static void roomsInsertTest(){
        Property__c p = TestRecord_Factory.createProperty();
        p.Number_of_Beds__c = 0;
        
        Insert(p);
        
        list<Room__c> newRooms = [SELECT ID FROM Room__c WHERE Name LIKE :p.Name+'%'];
        
        
        System.assertEquals(0, newRooms.size());
    }
}