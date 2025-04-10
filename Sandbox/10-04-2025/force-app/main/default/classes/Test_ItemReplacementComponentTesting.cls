@isTest
public class Test_ItemReplacementComponentTesting
{
    @isTest
    public Static Void TestMethod1(){
        test.startTest();
        test.isRunningTest();
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.PersonEmail = 'test@test.com';
        insert acc;
        
        City__c c = new City__c();
        c.Name = 'Seattle';
        insert c;

        //START
        Brand__c br = new Brand__c(Name = 'Test Brand',
                                    APINameBrand__c = 'Test Brand API');
        insert br;
        //END

        Property__c h = new Property__c();
        h.Name = 'test';
        h.City_object__c = c.id;
        //h.Home_Manager_User__c = [SELECT id from User where name = 'JT Holden'][0].id;
        h.Home_Manager_User__c = userInfo.getUserId();
        h.Item_Replacement_Budget__c = 3;
        h.BrandRef__c = br.Id;
        insert h;
        
        
        Apartment__c s = new Apartment__c();
        s.Name = 'Test';
        s.PropertyRef__c = h.id;
        insert s;
        
        Room__c r = new Room__c ();
        r.Name = 'test';
        r.Property__c = h.id;
        r.ApartmentRef__c = s.id;
        insert r;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Closed Lost';
        opp.CloseDate = system.today();
        opp.AccountID = acc.id;
        opp.Phone__c = '2223333';
        opp.City_Lookup__c = c.id;
        opp.ApartmentRef__c = s.id;
        opp.End_Date_of_Occupancy__c = system.today();
        opp.Room_Selected__c = r.id;
        opp.Home_Committed__c = h.id;
        insert opp;
        
        list<RecordTYpe> rtlist = [select id from RecordType Where SobjectType = 'Order' and DeveloperName = 'Item_Replacement'];
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Order o = new Order();
        o.OpportunityID = opp.id;
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.AccountID = acc.id;
        o.OpportunityID = opp.id;
        o.EndDate = System.today();
        o.RecordTypeID = rtlist[0].ID;
        o.Home__c = h.id;
        o.PriceBook2id = pricebookId;
        insert o;
        
        Order o2 = new Order();
        o2.OpportunityID = opp.id;
        o2.Status = 'Submitted';
        o2.EffectiveDate = system.today();
        o2.AccountID = acc.id;
        o2.OpportunityID = opp.id;
        o2.EndDate = System.today();
        o2.RecordTypeID = rtlist[0].ID;
        o2.Home__c = h.id;
        o2.PriceBook2id = pricebookId;
        insert o2;
        
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware', isActive = True);
        insert prod;
        
        
        
        PricebookEntry standardPricee = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPricee;
        
        OrderItem i = new OrderItem();
        i.OrderId = o.id;
        i.Quantity = 24;
        i.UnitPrice = 240;
        i.Product2id = prod.id;
        i.PricebookEntryId= standardPricee.id;
        insert i;
        
        OrderItem i2 = new OrderItem();
        i2.OrderId = o2.id;
        i2.Quantity = 24;
        i2.UnitPrice = 240;
        i2.Product2id = prod.id;
        i2.PricebookEntryId= standardPricee.id;
        insert i2;
        
        o.Status = 'Shipped';
        update o;
        
        
        ItemReplacementComponentController.GetSummary(o.id); 
        ItemReplacementComponentController.GetSuiteOrders(o.id); 
        
        o2.Status = 'Shipped';
        update o2;
        
        ItemReplacementComponentController.GetSummary(o.id); 
        test.stopTest();
        
    }
    
}