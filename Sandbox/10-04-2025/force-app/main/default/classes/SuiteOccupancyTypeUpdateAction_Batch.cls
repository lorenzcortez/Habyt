public class SuiteOccupancyTypeUpdateAction_Batch implements Database.Batchable<sObject> {
    
    private list<Id> SuiteIds;
    public SuiteOccupancyTypeUpdateAction_Batch (list<Id> SuiteIdsParam){
        SuiteIds = SuiteIdsParam;
    }
    
    @InvocableMethod(description='Update Related Opps on Suite Occupancy Type change') 
    public static String[] executeInvocableMethod(List<Id> suiteIds) {
    
        SuiteOccupancyTypeUpdateAction_Batch cls = new SuiteOccupancyTypeUpdateAction_Batch(suiteIds);
        Database.executeBatch(cls, 3);
        return suiteIds;
    }
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id, ApartmentRef__r.Product_Type__c, OBL_Status__c, Onboarding_Link__c, Lease_Id__c, Lease_Interval_Id__c, Customer_Id__c FROM Opportunity WHERE ApartmentRef__c IN :SuiteIds AND ApartmentRef__c != NULL AND StageName IN ('Lease Application', 'Renewal In Progress', 'Transfer In Progress')]);
    }
    public void execute(Database.BatchableContext context, Opportunity[] scope) {
        
        System.debug('Opportunity' + scope);

        List<Opportunity> OppsToUpdate = new List<Opportunity>();
        for(Opportunity opp : scope){
            
            String OBL_Status = NULL;
            String Onboarding_Link = NULL;

            if(String.isNotBlank(opp.ApartmentRef__r.Product_Type__c) && opp.ApartmentRef__r.Product_Type__c.equalsIgnoreCase('Co-living')){
                OBL_Status = 'Awaiting Agreement Generation';

                if(opp.OBL_Status__c != NULL && opp.OBL_Status__c != 'Awaiting Agreement Generation'){
                    String LeaseId = opp.Lease_Id__c == NULL ? '' : opp.Lease_Id__c.replaceAll('e','');
                    String LeaseIntervalId = opp.Lease_Interval_Id__c == NULL ? '' : opp.Lease_Interval_Id__c.replaceAll('e','');
                    String CustomerId = opp.Customer_Id__c == NULL ? '' : opp.Customer_Id__c.replaceAll('e','');
    
                    Onboarding_Link = 'https://leasing.common.com/coliving/'+LeaseId+'/'+LeaseIntervalId+'/'+CustomerId;
                }
            }

            
            if(opp.Onboarding_Link__c != Onboarding_Link || opp.OBL_Status__c != OBL_Status){
                opp.Onboarding_Link__c = Onboarding_Link;
                opp.OBL_Status__c = OBL_Status;
                OppsToUpdate.add(opp);
            }

            if(OppsToUpdate.size() > 0){
                update OppsToUpdate;
            }

        }
    }
    public void finish(Database.BatchableContext context) {
        
    }
}