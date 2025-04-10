@isTest
public class Test_OrderTrigger
{
    
    public TestMethod Static Void TestMethod1(){
        
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        insert acc;
        
        
        Account acc2 = new Account();
        acc2.FirstName = 'test2';
        acc2.LastName = 'test2';
        insert acc2;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Closed Lost';
        opp.CloseDate = system.today();
        opp.AccountID = acc.id;
        insert opp;
        
        
        Product2 prod = new Product2(Name = 'Laptop X200', 
                                     Family = 'Hardware', isActive = True);
        insert prod;
        
        Product2 prod2 = new Product2(Name = 'Laptop X201', 
                                     Family = 'Hardware', isActive = True, TSA_Level_Validation__c = True);
        insert prod2;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod2.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        list<RecordTYpe> rtlist = [select id from RecordType Where SobjectType = 'Order' and DeveloperName = 'Real_Estate'];
        
        Order o = new Order();
        o.OpportunityID = opp.id;
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        o.AccountID = acc.id;
        o.Product__c = prod.id;
        o.EndDate = System.today() + 100;
        o.TSA_Stage__c = 'CFX Sent';
        
        if(rtlist.size() > 0)
            o.RecordTypeID = rtlist[0].ID;
        
        insert o;
        
        o.Product__c = prod2.id;
        update o;
        
        Order order = new Order();
        order.OpportunityID = opp.id;
        order.Status = 'Draft';
        order.EffectiveDate = system.today();
        order.AccountID = acc.id;
        order.Product__c = prod.id;
        order.EndDate = System.today() + 100;
        
        id parking = [select id from RecordType Where SobjectType = 'Order' and DeveloperName = 'Item_Replacement'].id;
        
        order.RecordTypeId = parking;
        insert order;
        
        Order o2 = new Order();
        o2.OpportunityID = opp.id;
        o2.Status = 'Draft';
        o2.EffectiveDate = System.today() + 101;
        o2.AccountID = acc2.id;
        o2.Product__c = prod.id;
        o2.EndDate = System.today() + 200;
        o2.RecordTypeId = parking;
        insert o2;
        
        try{
        o2.EffectiveDate = System.today();
        update o2;
        }
        catch (exception e){
            
        }
        
        Order o3 = [select id, effectiveDate from order where id =: o2.Id];
        System.assert(o3.EffectiveDate != System.today());
        
        Delete o;
        

        Set<Id> orderIds = new Set<Id>();
        orderIds.add(order.Id);
        orderIds.add(o2.Id);

        
        Set<Id> oppIds = new Set<Id>();
        oppIds.add(opp.Id);

        Test.startTest();
        OrderTriggerHandler.PopulatePriceBookOnOrder(new List<Order>());
        OrderTriggerHandler.RollupOrderCountOnOpportunity(oppIds);
        OrderProductTriggerHandler.RollupOrderCountOnOpportunity(orderIds);
        Test.stopTest();

    }

}