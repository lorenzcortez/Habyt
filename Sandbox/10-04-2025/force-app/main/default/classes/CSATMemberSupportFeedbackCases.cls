public class CSATMemberSupportFeedbackCases implements Schedulable {
    
    public void execute(SchedulableContext ctx) {
        
        //System.schedule('CSAT Member Support Cases Feedback', '0 0 * * * ?', new CSATMemberSupportFeedbackCases() );
        
        //2 Hours After Closed Date/Time
        DateTime StartDt = Datetime.newInstance(System.Now().year(), System.Now().month(), System.Now().day(), System.Now().addHours(-3).hour(), 0, 0);
        DateTime EndDt = Datetime.newInstance(System.Now().year(), System.Now().month(), System.Now().day(), System.Now().addHours(-2).hour(), 0, 0);
        
        system.debug('System.Now::'+System.Now());
        system.debug('StartDt::'+StartDt);
        system.debug('EndDt::'+EndDt);
        
        string soqlString = 'SELECT Id, ClosedDate, AccountId, Account__c, Opportunity__c, Brand__c, OwnerId, SuppliedEmail, Opportunity__r.Brand__c, Opportunity__r.OwnerId, ContactEmail';
        soqlString += ' FROM Case ';
                            soqlString += ' WHERE ';
        
        if(!test.isRunningTest()){
            soqlString += ' ClosedDate >:StartDt AND ClosedDate <=:EndDt AND Opportunity__c != NULL AND';
        }
        soqlString += ' Status = \'Solved\' AND ContactId != NULL AND RecordTypeId != NULL AND';
        soqlString += ' (RecordType.Name like \'%CSS%\' OR RecordType.DeveloperName = \'NOAH_Lease_and_Billing_Inquiries\' ';
        soqlString += ' OR RecordType.DeveloperName = \'NOAH_Property_Issue\' OR RecordType.DeveloperName = \'KIN_Lease_and_Billing_Inquiries\' ';
        soqlString += ' OR RecordType.DeveloperName = \'KIN_Property_Issue\') AND ';
        soqlString += ' Send_CSAT_Survey__c = TRUE AND Sent_CSAT_Survey__c = FALSE ';
        
        system.debug('soqlString::'+soqlString);
        List<Case> Cases = database.query(soqlString);
        system.debug('Cases::'+Cases);
        
        
        Id FbCommonRTId = Schema.SObjectType.Feedback__c.getRecordTypeInfosByDeveloperName().get('Common').getRecordTypeId();
        Id FbNoahRTId = Schema.SObjectType.Feedback__c.getRecordTypeInfosByDeveloperName().get('Noah').getRecordTypeId();
        Id FbKinRTId = Schema.SObjectType.Feedback__c.getRecordTypeInfosByDeveloperName().get('Mily').getRecordTypeId();
        
        
        list<Feedback__c> FeedbacksToCreate = new list<Feedback__c>();
        list<Case> casesToUpdate = new list<Case>();
        
        for(Case c: Cases){
            boolean isInternalEmail = false;
            
            if(c.SuppliedEmail != null && (c.SuppliedEmail.ContainsIgnoreCase('@handybook.com') || c.SuppliedEmail.ContainsIgnoreCase('@emaidsinc.com') || c.SuppliedEmail.ContainsIgnoreCase('@common.com') || c.SuppliedEmail.ContainsIgnoreCase('@handy.com'))){
                isInternalEmail = true;
            }
            
            if(c.ContactEmail != NULL && (c.ContactEmail.ContainsIgnoreCase('@handybook.com') || c.ContactEmail.ContainsIgnoreCase('@emaidsinc.com') || c.ContactEmail.ContainsIgnoreCase('@common.com') || c.ContactEmail.ContainsIgnoreCase('@handy.com'))){
                isInternalEmail = true;
            }
            
            
            if(isInternalEmail == false){
            
                String brand = 'common';
                if(c.Opportunity__r.Brand__c  == 'noah')
                    brand = 'noah';
                if(c.Opportunity__r.Brand__c  == 'kin')
                    brand = 'kin';
                
                
                Feedback__c fb = new Feedback__c();
                fb.Account__c = c.Account__c != NULL ? c.Account__c : c.AccountID;
                fb.Brand__c = brand;
                fb.Case__c = c.Id;
                fb.Opportunity__c = c.Opportunity__c;
                fb.Email_Survey__c = TRUE;
                String FBRecordTypeId = FbCommonRTId;
                if(c.Opportunity__r.Brand__c == 'noah')
                    FBRecordTypeId = FbNoahRTId;
                else if(c.Opportunity__r.Brand__c == 'kin')
                    FBRecordTypeId = FbKinRTId;
                fb.RecordTypeId = FBRecordTypeId;               
                fb.Related_User__c = c.Opportunity__r.OwnerId;
                fb.Status__c = 'Sent';
                fb.Survey_Template__c = 'CSAT - Member Support Case';
                FeedbacksToCreate.add(fb);
                
                Case caseToUpdate = new Case();
                caseToUpdate.Id = c.Id;
                caseToUpdate.Sent_CSAT_Survey__c = TRUE;
                casesToUpdate.add(caseToUpdate);
                
            }
        }
        
        system.debug('FeedbacksToCreate::'+FeedbacksToCreate);        
        if(FeedbacksToCreate.size() > 0){
            insert FeedbacksToCreate;
        }
        system.debug('casesToUpdate::'+casesToUpdate);
        if(casesToUpdate.size() > 0){
            update casesToUpdate;
        }
    }
}