public class OrderProductTriggerHandler
{
    public static void ProcessforRollUp(list<OrderItem> OrderItems){
        Map<Id,Schema.RecordTypeInfo> rtMap = Order.sobjectType.getDescribe().getRecordTypeInfosById();
        Map<id,Product2> ProMap = new Map<id,Product2>([Select id,name,TSA_Level_Validation__c from Product2]);
        set<id> OrderIds = new set<id> ();
        for(OrderItem oi : OrderItems){
            if(ProMap.get(oi.Product2Id) != null && ProMap.get(oi.Product2Id).TSA_Level_Validation__c){
                OrderIds.add(oi.OrderID);
            }
        }
        
        Map<Id,Id> OrderRecTypeMap = new Map<Id,Id>();
        list<Order> Orders = [select id,RecordTypeId from Order where Id in: OrderIds];
        for(Order o : Orders){
            OrderRecTypeMap.put(o.Id, o.RecordTypeId);
        }
        
        set<Id> FilteredOrderIds = new set<Id>();
        for(ID i : OrderIds){
            if(rtMap.get(OrderRecTypeMap.get(i)).getDeveloperName() == 'Real_Estate'){
                FilteredOrderIds.add(i);
            }
        }
        
        if(FilteredOrderIds.size() > 0){
            RollupOrderCountOnOpportunity(FilteredOrderIds);
        }
    }
    
    
    public static void RollupOrderCountOnOpportunity(set<id> orderids){
        
        Map<ID,Integer> TSAOrderMap = new Map<ID,Integer>();
        set<Id> Oppids = new set<Id>();
        list<Order> orders = [Select ID, OpportunityID,(Select id,Product2.Name from OrderItems where Product2.TSA_Level_Validation__c = True) from Order where ID in:orderids];
        for(Order o : Orders){
            Integer i = TSAOrderMap.get(o.OpportunityID);
            if(i == null){i=0;}
            i += o.OrderItems.Size();
            TSAOrderMap.put(o.OpportunityID,i);
            Oppids.add(o.OpportunityID);
        }
        
        list<Opportunity> opps = [select id, Number_of_Related_Orders__c from Opportunity where id in:TSAOrderMap.KeySet() ];
        
        for(Opportunity opp : opps){
            opp.Number_of_Related_Orders__c = TSAOrderMap.get(opp.id);
        }
        
        update opps;
    }
}