public class EmailMessageTriggerHandler
{
    public Static Void AfterInsert(list<EmailMessage> Ems ){
        
        set<id> ParentCaseIds = new set<id>();
        
        for(EmailMessage em : Ems){
            if(em.ParentId != null){
                if(em.ParentId.getSObjectType() == Case.sObjectType){
                    ParentCaseIds.add(em.ParentId);
                }
            }
        }
        
        Map<id,Case> MapCase = new Map<id,Case>();
        if(ParentCaseIds.size() > 0){
            list<Case> cs = [select Status,CreatedDate,IsClosed,Auto_Closed__c,RecordTypeid,RecordType.Name,RecordType.DeveloperName from Case where id in:ParentCaseIds];
            for(Case c: cs){
                MapCase.put(c.id, c);
            }
        }
        
        list<Case> UpdateableCases = new list<Case>();
        list<New_Case_Reopen__e> newcasesevents = new list<New_Case_Reopen__e>();
        set<id> duplicatecaseid = new set<id>();
        for(EmailMessage em : Ems){
            if(em.ParentId != null){
                if(em.ParentId.getSObjectType() == Case.sObjectType){
                    
                    if(duplicatecaseid.add(em.ParentId)){ //processing only unique cases.
                        
                        Case c = MapCase.get(em.ParentId);
                        if(c != null){
                            
                            if(em.Incoming){
                                
                                if(c.RecordTypeid != null && ( c.RecordType.Name.Contains('CSS') || c.recordType.DeveloperName  == 'KIN_Lease_and_Billing_Inquiries'
                                || c.recordType.DeveloperName  == 'KIN_Property_Issue' || c.recordType.DeveloperName  == 'NOAH_Lease_and_Billing_Inquiries'
                                || c.recordType.DeveloperName  == 'NOAH_Property_Issue' || c.RecordType.Name.Contains('Leasing Admin')) 
                                ){
                                
                                    if(c.Auto_Closed__c == false && c.Status != 'Merged'){ // && c.Status != 'Closed'
                                        c.Status = 'Open';
                                        UpdateableCases.add(c);
                                    }/*else if(c.Auto_Closed__c == false && c.Status != 'Merged' && c.Status == 'Closed'){
                                        New_Case_Reopen__e nc = new New_Case_Reopen__e();
                                        nc.CaseID__c = c.id;
                                        nc.EmailMessageID__c = em.id;
                                        newcasesevents.add(nc);
                                    }*/
                                }
                                else{
                                    if(c.Auto_Closed__c == false && c.Status != 'Merged'){
                                        c.Status = 'Open';
                                        UpdateableCases.add(c);
                                    }
                                }
                            }
                            else
                            {
                               if( c.RecordTypeid != null && ( c.RecordType.Name.Contains('Inside Sales') || c.RecordType.Name.Contains('Leasing Admin'))  ){
                                    c.Status = 'Pending';
                                    UpdateableCases.add(c);                            
                                }
                                else if(c.RecordTypeid != null && (c.RecordType.Name.Contains('CIS') || c.RecordType.DeveloperName == 'Finance_Collections')){
                                    c.Status = 'Awaiting Response';
                                    UpdateableCases.add(c);
                                }
                            }
                        }
                    
                    }
                }
            }
        }
        
        if(newcasesevents.size() > 0){
            EventBus.Publish(newcasesevents);
        }
        
        if(UpdateableCases.size() > 0) {
            update UpdateableCases;
        }
        
    }
}