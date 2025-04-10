//Developed by Einsteam
//Getting item replacement order history of current month
//This controller is the extension of the ItemReplacementOrderCountReport LWC Component.

public class ItemReplacementComponentController {
    
    
    @AuraEnabled(cacheable=true)
    public static list<OrderWrapper> GetSuiteOrders(String recordId) {
        list<OrderWrapper> ol = new list<OrderWrapper>();
        
        ID SuiteID = [select Opportunity.ApartmentRef__c from Order where id =:recordId limit 1].Opportunity.ApartmentRef__c;
        Date TodayMinus90 = system.today().addDays(-90);
        list<Order> suiteorders = [select id,Status,OrderNumber,TotalAmount,Opportunity.Accountid,Opportunity.Account.FirstName,Opportunity.Account.LastName,EffectiveDate,(select id,Product2.Name,Product2id from OrderItems) 
        from order where id !=:recordId and Opportunity.ApartmentRef__c =:SuiteID and recordtype.developername = 'Item_Replacement' and EffectiveDate >=:TodayMinus90 Order by EffectiveDate desc];
        for(Order o : SuiteOrders){
            OrderWrapper ow = new OrderWrapper();
            ow.AccountName = o.Opportunity.Account.FirstName +' '+o.Opportunity.Account.LastName;
            ow.AccountURL  = 'https://common.lightning.force.com/lightning/r/Account/'+o.Opportunity.Accountid+'/view';
            ow.OrderName  = o.OrderNumber;
            ow.OrderURL  = 'https://common.lightning.force.com/lightning/r/Order/'+o.Id+'/view';
            ow.StartDate = o.EffectiveDate;
            ow.TotalAmount = o.TotalAmount;
            ow.Status = o.Status;
            
            if(o.Orderitems.size() > 0){
                ow.ProductName = o.Orderitems[0].Product2.Name;
                ow.ProductURL = 'https://common.lightning.force.com/lightning/r/Product/'+o.Orderitems[0].Product2id+'/view';
            }
            ol.add(ow);
        }
        
        return ol;
    }
    
    @AuraEnabled(cacheable=true)
    public static ItemReplacementSummaryWrapper GetSummary(String recordId) {
       ItemReplacementSummaryWrapper res = new ItemReplacementSummaryWrapper();
       
       list<Order> orders = [select Id,Opportunity.Account.FirstName,Opportunity.Account.LastName,Status,Opportunity.Home_Committed__c,TotalAmount,Opportunity.Home_Committed__r.Item_Replacement_Budget__c,Opportunity.ApartmentRef__c,Opportunity.ApartmentRef__r.Name,Opportunity.Home_Committed__r.Name from order where id =:recordId];
       if(orders.size() > 0){
           res.HomeName = orders[0].Opportunity.Home_Committed__r.Name;
           res.SuiteName = orders[0].Opportunity.ApartmentRef__r.Name;
           res.AccountName = orders[0].Opportunity.Account.FirstName +' '+orders[0].Opportunity.Account.LastName;
           
           if(orders[0].Opportunity.Home_Committed__c != null){

                //Getting yearly orders for the home
                list<order> yealyhomeorders = [select id,TotalAmount from Order where CreatedDate = This_Year and Opportunity.Home_Committed__c =:orders[0].Opportunity.Home_Committed__c and (Status = 'Approved by MS' or Status = 'Shipped' or Status = 'Activated' or Status = 'Ordered') and recordtype.developername = 'Item_Replacement' and id !=:recordID];
                for(Order aor : yealyhomeorders){
                    if(aor.TotalAmount != null)
                        res.approvedhomeorderAmountthisyear += aor.TotalAmount;                 
                }
                
                //Getting monthly orders for the home
                list<order> monthlyhomeorders = [select id,TotalAmount from Order where CreatedDate = This_Month and Opportunity.Home_Committed__c =:orders[0].Opportunity.Home_Committed__c and (Status = 'Approved by MS' or Status = 'Shipped' or Status = 'Activated' or Status = 'Ordered') and recordtype.developername = 'Item_Replacement' and id !=:recordId];
                for(Order aor : yealyhomeorders){
                    if(aor.TotalAmount != null)
                        res.approvedhomeorderAmountthismonth += aor.TotalAmount;                 
                }
                
                 //Getting yearly orders for the suite
                list<order> yealysuiteorders = [select id,TotalAmount from Order where CreatedDate = This_Year and Opportunity.ApartmentRef__c =:orders[0].Opportunity.ApartmentRef__c and (Status = 'Approved by MS' or Status = 'Shipped' or Status = 'Activated' or Status = 'Ordered') and recordtype.developername = 'Item_Replacement' and id !=:recordId];
                for(Order aor : yealysuiteorders){
                    if(aor.TotalAmount != null){ res.approvedsuiteorderAmountthisyear += aor.TotalAmount; }                 
                }
                
                //Getting monthly orders for the suite
                list<order> monthlysuiteorders = [select id,TotalAmount from Order where CreatedDate = This_Month and Opportunity.ApartmentRef__c =:orders[0].Opportunity.ApartmentRef__c and (Status = 'Approved by MS' or Status = 'Shipped' or Status = 'Activated' or Status = 'Ordered') and recordtype.developername = 'Item_Replacement' and id !=:recordId];
                for(Order aor : monthlysuiteorders){
                    if(aor.TotalAmount != null){ res.approvedsuiteorderAmountthismonth += aor.TotalAmount; }
                                         
                }
                
                if(orders[0].TotalAmount != null){ res.newmonthlyhomeorderamount = res.approvedhomeorderAmountthismonth + orders[0].TotalAmount;
                    res.newyearlyhomeorderamount =  res.approvedhomeorderAmountthisyear + orders[0].TotalAmount;
                    res.newmonthlysuiteorderamount = res.approvedsuiteorderAmountthismonth + orders[0].TotalAmount;
                    res.newyearlysuiteorderamount = res.approvedsuiteorderAmountthisyear + orders[0].TotalAmount;    
                }
                
                if(orders[0].Opportunity.Home_Committed__r.Item_Replacement_Budget__c != null){ res.homebugetyearly = orders[0].Opportunity.Home_Committed__r.Item_Replacement_Budget__c;
                    res.homebugetmonthly = orders[0].Opportunity.Home_Committed__r.Item_Replacement_Budget__c/12; 
                }
           }
           
       }
       
       return res;
    }
    
    Public class OrderWrapper{
        @AuraEnabled public string AccountName {get;set;}
        @AuraEnabled public string AccountURL {get;set;}
        @AuraEnabled public string OrderName {get;set;}
        @AuraEnabled public string OrderURL {get;set;}
        @AuraEnabled public date StartDate {get;set;}
        @AuraEnabled public string ProductName {get;set;}
        @AuraEnabled public string ProductURL {get;set;}
        @AuraEnabled public Decimal TotalAmount {get;set;}
        @AuraEnabled public string Status {get;set;}
        
        
        public OrderWrapper(){
            AccountName = '';
            AccountURL = '';
            ProductName = '';
            ProductURL = '';
            TotalAmount = 0;
            Status = '';
        }
        
    }
    
    Public class ItemReplacementSummaryWrapper{
        @AuraEnabled public string HomeName {get;set;}
        @AuraEnabled public string SuiteName {get;set;}
        @AuraEnabled public string AccountName {get;set;}
        
        @AuraEnabled public decimal homebugetyearly {get;set;}
        @AuraEnabled public decimal homebugetmonthly {get;set;}
        @AuraEnabled public decimal approvedhomeorderAmountthismonth {get;set;}
        @AuraEnabled public decimal approvedhomeorderAmountthisyear {get;set;}
        @AuraEnabled public decimal newmonthlyhomeorderamount {get;set;}
        @AuraEnabled public decimal newyearlyhomeorderamount {get;set;}
        
        @AuraEnabled public decimal approvedsuiteorderAmountthismonth {get;set;}
        @AuraEnabled public decimal approvedsuiteorderAmountthisyear {get;set;}
        @AuraEnabled public decimal newmonthlysuiteorderamount{get;set;}
        @AuraEnabled public decimal newyearlysuiteorderamount{get;set;}
        
        public ItemReplacementSummaryWrapper(){
            HomeName = '';
            SuiteName = '';
            
            homebugetyearly = 0; 
            homebugetmonthly = 0; 
            approvedhomeorderAmountthismonth = 0; 
            approvedhomeorderAmountthisyear = 0; 
            newmonthlyhomeorderamount = 0; 
            newyearlyhomeorderamount = 0; 
            
            approvedsuiteorderAmountthismonth = 0; 
            approvedsuiteorderAmountthisyear = 0; 
            newmonthlysuiteorderamount = 0; 
            newyearlysuiteorderamount = 0; 
        }
        
    }
}