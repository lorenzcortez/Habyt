@isTest
public class NightlyOrderHandlerTest {
 	public TestMethod Static Void TestMethod1(){
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        insert acc;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Closed Lost';
        opp.CloseDate = system.today();
        opp.AccountID = acc.id;
        id initialRecordType = [select id from recordType where name = 'Common - Initial' limit 1].id;
        opp.RecordTypeId = initialRecordType;
        opp.Name = 'JT Test 1';
        insert opp;
        Product2 p = new Product2();
        p.name = '5';
        p.Family = 'Parking Spot';
        insert p;
 		Order o = new Order();
        o.OpportunityId = opp.id;
    	o.EffectiveDate = System.today();
        o.EndDate = System.today() + 10;
        o.Status = 'Draft';
        o.Product__c = p.Id;
        o.AccountId = acc.Id;
        o.Pricebook2Id = pricebookId;
        insert o;

        
       	Pricebook2 pb2 = new Pricebook2();
        pb2.name = 'Standard Price Book';
        insert pb2;
        //Pricebook2 standard = [select id, name from pricebook2 where name = 'Standard Price Book'];
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.UnitPrice = 0;
        pbe.Product2Id = p.id;
        pbe.Pricebook2Id = pricebookId;
        
		insert pbe;
        
        orderItem OI = new orderItem();
        OI.OrderId = o.Id;
        OI.Product2Id = p.Id;
        OI.UnitPrice = 0;
        OI.Quantity = 1;
        OI.PricebookEntryId = pbe.id;
        insert OI;
        
    	Test.startTest();
    	NightlyOrderHandler noh = new NightlyOrderHandler();
    	noh.execute(null);
    	Test.stopTest();
        
  	}
    
    public static testmethod void UnitTestFail() {
    	Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        insert acc;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Closed Lost';
        opp.CloseDate = system.today();
        opp.AccountID = acc.id;
        id initialRecordType = [select id from recordType where name = 'Common - Initial' limit 1].id;
        opp.RecordTypeId = initialRecordType;
        opp.Name = 'JT Test 1';
        insert opp;
        Product2 p = new Product2();
        p.name = '5';
        p.Family = 'Parking Spot';
        insert p;
 		Order o = new Order();
        o.OpportunityId = opp.id;
    	o.EffectiveDate = System.today();
        o.EndDate = System.today() + 10;
        o.Status = 'Draft';
        o.Product__c = p.Id;
        o.AccountId = acc.Id;
        o.Pricebook2Id = pricebookId;
        insert o;

        
       	Pricebook2 pb2 = new Pricebook2();
        pb2.name = 'Standard Price Book';
        insert pb2;
        //Pricebook2 standard = [select id, name from pricebook2 where name = 'Standard Price Book'];
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.UnitPrice = 0;
        pbe.Product2Id = p.id;
        pbe.Pricebook2Id = pricebookId;
        
		insert pbe;
        
        orderItem OI = new orderItem();
        OI.OrderId = o.Id;
        OI.Product2Id = p.Id;
        OI.UnitPrice = 0;
        OI.Quantity = 1;
        OI.PricebookEntryId = pbe.id;
        insert OI;
        RecordType personAccountRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true LIMIT 1];
        
        test.StartTest();
            NightlyOrderHandler bFail = new NightlyOrderHandler();
        
            Account Testaccount = new Account(
            RecordTypeId = personAccountRecType.Id,
            LastName = 'THIS IS A TEST TO MAKE THE JOB FAIL',
            PersonEmail = 'test@test.com'
        	);
        	insert Testaccount;
            bFail.execute(null);

        test.StopTest(); 
    }
    @isTest(seeAllData=true)
    public static void UnitTestFail2(){
    	Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        insert acc;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Closed Lost';
        opp.CloseDate = system.today();
        opp.AccountID = acc.id;
        id initialRecordType = [select id from recordType where name = 'Common - Initial' limit 1].id;
        opp.RecordTypeId = initialRecordType;
        opp.Name = 'JT Test 1';
        insert opp;
        Product2 p = new Product2();
        p.name = '5';
        p.Family = 'Parking Spot';
        insert p;
 		Order o = new Order();
        o.OpportunityId = opp.id;
    	o.EffectiveDate = System.today();
        o.EndDate = System.today() + 10;
        o.Status = 'Draft';
        o.Product__c = p.Id;
        o.AccountId = acc.Id;
        o.Pricebook2Id = pricebookId;
        insert o;

        
       	Pricebook2 pb2 = new Pricebook2();
        pb2.name = 'Standard Price Book';
        insert pb2;
        //Pricebook2 standard = [select id, name from pricebook2 where name = 'Standard Price Book'];
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.UnitPrice = 0;
        pbe.Product2Id = p.id;
        pbe.Pricebook2Id = pricebookId;
        
		insert pbe;
        
        job_last_run__c jbr = new Job_last_run__c();
        jbr.name = 'NightlyOrderHandler';
        insert jbr;
        
        orderItem OI = new orderItem();
        OI.OrderId = o.Id;
        OI.Product2Id = p.Id;
        OI.UnitPrice = 0;
        OI.Quantity = 1;
        OI.PricebookEntryId = pbe.id;
        insert OI;
        RecordType personAccountRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true LIMIT 1];
        
        test.StartTest();
            NightlyOrderHandler bFail = new NightlyOrderHandler();
        
            Account Testaccount = new Account(
            RecordTypeId = personAccountRecType.Id,
            LastName = 'THIS IS A TEST TO MAKE THE JOB FAIL',
            PersonEmail = 'test@test.com'
        	);
        	insert Testaccount;
            bFail.execute(null);

        test.StopTest(); 
    }
}