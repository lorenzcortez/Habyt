@isTest
public class Test_EmailtoCaseForwarderEmailParser {
    
    public TestMethod Static Void TestMethod1(){
        Contact cn = new contact ();
        cn.LastName = 'test';
        cn.Email = 'development@einsteam.com';
        insert cn;
        
        Case c = new Case();
        c.subject = 'test';
        c.SuppliedEmail = 'members@common.com';
        c.Description = 'development@einsteam.com';
        insert c;
        
        list<id> caseids = new list<id>();
        caseids.add(c.id);
        EmailtoCaseForwarderEmailParser.ParseEmailfromCaseDescription(caseids); 
        
    }
}