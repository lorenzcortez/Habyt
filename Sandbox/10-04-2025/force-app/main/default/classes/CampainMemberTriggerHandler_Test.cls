@istest
public class CampainMemberTriggerHandler_Test{
    
    public TestMethod Static void test1(){
        
        Contact testContact = new Contact(FirstName = 'TestContactF', LastName = 'TestContactL', Email = 'none@navinet.net');
        insert testContact;
        
        Campaign parentc = new Campaign(Name='Lincoln 455 - Suite 1U & 1L');
        insert parentc;
        
        Campaign child1 = new Campaign(Name='Lincoln 455 - Suite 1L');
        insert child1;
        
        Campaign child2 = new Campaign(Name='Lincoln 455 - Suite 1U');
        insert child2;
        
        CampaignMember newMember = new CampaignMember(CampaignID = child1.id, ContactID = testContact.ID);
        insert newMember;
        
        newMember.Occupancy_Status__c = 'Active';
        update newMember;
        
        delete newMember;
    
    
    }


}