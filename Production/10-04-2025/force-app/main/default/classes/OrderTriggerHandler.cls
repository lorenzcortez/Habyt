public class OrderTriggerHandler{ 
    
    public static void BeforeInsert(list<Order> orders,Map<id,Schema.RecordTypeInfo> OrderRecTypeMap){
        
    }
    
    public static void checkOrderInterference(list<Order> orders){
    	//create a map of the order being updated to the orders already on that product
        Map<Order, List<Order>> O2Orders = new Map<Order, List<Order>>();
		List<id> OrderIds = new List<id>();
        for(order o : orders){
            OrderIds.add(o.id);
        }
        //put product ids into list of type ID
        List<id> ProductIds = new List<id>();
        for(order o : orders){
            ProductIds.add(o.product__c);
        }
        //Select all orders on the products in the list
        List<Order> relevantOrders = [Select id, accountid, product__c, effectiveDate, opportunity.Name, endDate, status from order where product__c in : ProductIds and status != 'Cancelled'];
        
        // loop through the new Orders, Then in the loop, loop through the relevant orders list. Creates Lists of Orders that share
        // a productid, and adds them to a map of new Order to list of orders.
        for(Order o: orders){
            List<Order> orderListForProductId = new List<Order>();
            for(Order o2: relevantOrders){
                if(o2.Product__c == o.product__c && o.id != o2.id)
                    orderListForProductId.add(o2);
            }
            O2Orders.put(o, orderListForProductId);
        }
        //loop through the set we just created
        for(Order key : O2Orders.keySet()){
            List<Order> os = O2Orders.get(key);
            for(Order existingOrder: os){
                			//new startdate is between old start and end date
                if( existingOrder.accountid != key.AccountId && ((existingOrder.EffectiveDate <= key.EffectiveDate && existingOrder.EndDate >= key.EffectiveDate)
                			//new end date is between old start and end date
               		|| (existingOrder.EffectiveDate <= key.EndDate && existingOrder.EndDate >= key.EndDate)
                  			//New order encompasses old order
               		|| (existingOrder.EffectiveDate >= key.EffectiveDate && existingOrder.EndDate <= key.EndDate)
                    		//old order encompasses new order
              		|| (existingOrder.EffectiveDate <= key.EffectiveDate && existingOrder.EndDate >= key.EndDate)
                )){
                    key.addError('You cannot save this order because it interferes with an order on the Opportunity: ' + existingOrder.opportunity.Name);
                }
            }
        }
        
    }
    public static void BeforeUpdate(list<Order> orders, map<id,Order> OldMap, Map<id,Schema.RecordTypeInfo> OrderRecTypeMap){

        Set<Id> commomnRecordTypeIds = new Set<Id>();

        List<Order> cancelledOrders = new List<Order>();
        List<Id> cancelledOrderOppIds = new List<ID>();
        List<id> cancelledProducts = new List<id>();
        
        for(order o : orders){

            if( commomnRecordTypeIds.contains(o.RecordTypeId) ){

                if(o.Status == 'Cancelled' && OldMap.get(o.id).status != 'Cancelled'){
                    
                    if(o.OpportunityId != null){
                        cancelledOrders.Add(o);
                        cancelledOrderOppIds.add(o.OpportunityId);
                        cancelledProducts.add(o.Product__c);
                    }
                }
            }
        }
        List<Opportunity> cancelledOrderOpps = [Select id, subsequent_opportunity__c from opportunity where id in: cancelledOrderOppIds and subsequent_opportunity__C != null];
        List<ID> subsequentOppIDs = new List<Id>();
        for(Opportunity o : cancelledOrderOpps){
            subsequentOppIDs.add(o.subsequent_opportunity__c);
        }
     	list<Order> renewalOrders = [SELECT id, product__c, status from order where Opportunityid in: subsequentOppIds and product__c in: cancelledProducts];
        for(order o: renewalOrders){
            o.status = 'Cancelled';
        }
        if(renewalOrders.size() > 0)
        	update renewalOrders;
        
        
        
    }
    
    public static void PopulatePriceBookOnOrder(list<Order> orders){
        
    }
    
    public static void AfterInsert(list<Order> orders, Map<id,Schema.RecordTypeInfo> OrderRecTypeMap){
    }
    
    public static void AfterUpdate(list<Order> orders, map<id,Order> OldMap, Map<id,Schema.RecordTypeInfo> OrderRecTypeMap){
    }
    
    public static void AfterDelete(list<Order> Orders, Map<id,Schema.RecordTypeInfo> OrderRecTypeMap){

        Set<Id> commomnRecordTypeIds = new Set<Id>();
        set<id> OppIds = new set<id>();
        
        for(Order o : Orders){

            if( commomnRecordTypeIds.contains(o.RecordTypeId) ){
                if(o.OpportunityID != null && OrderRecTypeMap.get(o.RecordTypeId).getDeveloperName() == 'Real_Estate'){
                    OppIds.add(o.OpportunityID);
                }
            }
        }
        
        if(OppIds.size() > 0){
            RollupOrderCountOnOpportunity(OppIds);
        }
    }
    
    public static void RollupOrderCountOnOpportunity(set<id> Oppids){
        
        Map<ID,Integer> TSAOrderMap = new Map<ID,Integer>();
        set<ID> OrderIds = new set<ID>();
        list<Opportunity> opps = [select id, Number_of_Related_Orders__c,(Select id from Orders) from Opportunity where id in:Oppids ];
        for(Opportunity o : opps){
            for(Order ord : o.Orders){
                OrderIds.add(ord.ID);
            }
        }
        
        list<Order> orders = [Select ID, OpportunityID,(Select id,Product2.Name from OrderItems where Product2.TSA_Level_Validation__c = True) from Order where Id in:OrderIds];
        for(Order o : Orders){
            Integer i = TSAOrderMap.get(o.OpportunityID);
            if(i == null){i=0;}
            i += o.OrderItems.Size();
            TSAOrderMap.put(o.OpportunityID,i);
            Oppids.add(o.OpportunityID);
        }
        
        
        
        for(Opportunity opp : opps){
            opp.Number_of_Related_Orders__c = TSAOrderMap.get(opp.id);
        }
        
        update opps;
    }
    
}