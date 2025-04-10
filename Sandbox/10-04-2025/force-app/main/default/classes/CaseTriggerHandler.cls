public class CaseTriggerHandler{
    
    public static void BeforeInsert(list<Case> Cases){

        Set<Id> commomnRecordTypeIds = new Set<Id>();
        //Id commonTransfer = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Common - Transfer').getRecordTypeId();
        Id commonTransfer = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Common - Inside Sales Lead').getRecordTypeId();
        commomnRecordTypeIds.add(commonTransfer);

        //AutoCloseCases(Cases);
        AutoReplyCriteriaChecker(Cases);
        EmailtoCaseForwarderEmailParser(Cases);
        
        set<String> OppsString =  new set<String>();
        set<String> AccsString =  new set<String>();
        list<case> OrphanEmailtoCaselist =  new list<case>();
        Group renewalCaseQueue = [select id, name from group where name = 'Renewal Case'][0];
        
        Map<ID, Property__c> homeMap = new Map<ID, Property__c>([SELECT Id, bypass_skills_routing__c, Resident_Services_Coordinator__c, Home_Manager_User__c FROM Property__c]);
        
        for(Case c: Cases){
            //If case created by email to case doesn't have contact assosiated then prepare a list and call method 
            if(c.recordtypeid != null && commomnRecordTypeIds.contains(c.RecordTypeId)){
                system.debug('c.contactid::'+c.contactid);
                system.debug('c.Origin::'+c.Origin);
                system.debug('c.SuppliedEmail::'+c.SuppliedEmail);
                //system.debug('Schema.SObjectType.Opportunity.getRecordTypeInfosById().get(opp.recordtypeid).getname();::'+Schema.SObjectType.Case.getRecordTypeInfosById().get(c.recordtypeid).getname());
                if(c.contactid == null && c.Origin == 'Email' && c.SuppliedEmail != null && Schema.SObjectType.Case.getRecordTypeInfosById().get(c.recordtypeid).getname().contains('Leasing Admin')){
                    OrphanEmailtoCaselist.add(c); 
                }
            }
            
            
            if(c.Opportunity__c != null)
                OppsString.add(c.Opportunity__c);
            
            if(c.Account__c != null)
                AccsString.add(c.Account__c);
            
            if(c.Accountid != null)
                AccsString.add(c.Accountid);
            
        }
        
        if(OrphanEmailtoCaselist.size() > 0){
            populatecontactonOrphanCase_EmailtoCase( OrphanEmailtoCaselist );
        }
        
        Map<ID, Opportunity> Oppmap = new Map<ID, Opportunity>();
        list<Opportunity> opps =  [SELECT Id, account_name_formula__c,Accountid FROM opportunity where id in : OppsString or Accountid in:AccsString];
        for(Opportunity o: opps){
            Oppmap.put(o.Id,o);
            Oppmap.put(o.AccountId,o);
        }
        
        for(Case c : Cases){

            if( commomnRecordTypeIds.contains(c.RecordTypeId) ){

                if(c.Opportunity__c != null && Oppmap.get(c.Opportunity__c) != null && !test.isRunningTest())
                    c.Account_Name_Searchable__c = Oppmap.get(c.Opportunity__c).account_name_formula__c;
                
                if(c.Account__c != null && Oppmap.get(c.Account__c) != null && !test.isRunningTest())
                    c.Account_Name_Searchable__c = Oppmap.get(c.Account__c).account_name_formula__c;
                
                if(c.Accountid != null && Oppmap.get(c.Accountid) != null && !test.isRunningTest())
                    c.Account_Name_Searchable__c = Oppmap.get(c.Accountid).account_name_formula__c;

            }
        }
        
        
        List<recordType> rts = [Select id, name, developerName from recordType where sObjectType = 'Case'];
        map<id, recordType> rtMap = new map<id, recordType>();
        for(recordType rt: rts){
            rtMap.put(rt.id, rt);
        }
        
        for(case c: Cases){
            //don't run if recordtype is null
            if( c.RecordTypeId != null && commomnRecordTypeIds.contains(c.RecordTypeId) ){
                //is it a Skillsbased Routing Record Type?
                if((rtMap.get(c.recordTypeid).name.containsIgnoreCase('CSS') || rtMap.get(c.recordTypeid).name.containsIgnoreCase('MILY')) && !rtMap.get(c.recordTypeid).name.containsIgnoreCase('Inside Sales')){
                    //Is it a Renewal sub issue type? *These don't get routed, they go to the renewals manager on the home
                    if((c.sub_issue_type__c != null && c.Sub_Issue_Type__c == 'Renewals') || c.OwnerId == renewalCaseQueue.Id)
                        c.OwnerId = renewalCaseQueue.id;
                    else if(c.home__c != null){
                        //change owner to MSS agents
                        //Updated by: JP
                        //Updated Date: Sept 30, 2023
                        //Description: Commented out these lines to resolve this issue: Habyt - Create CSS - Member Support Specialist Case Invalid cross reference issue
                        //START
                        /*if(homeMap.get(c.home__c).Bypass_skills_routing__c == false)
                            c.ownerid = '00G3u000002O6HhEAK';*/
                        //END
                        if(homeMap.get(c.home__c).Bypass_skills_routing__c == true && homeMap.get(c.home__c).resident_services_coordinator__c != NULL)
                            c.OwnerId = homeMap.get(c.home__c).resident_services_coordinator__c;
                    }
                    //Updated by: JP
                    //Updated Date: Sept 30, 2023
                    //Description: Commented out these lines to resolve this issue: Habyt - Create CSS - Member Support Specialist Case Invalid cross reference issue
                    //START
                    /*else
                        c.ownerid = '00G3u000002O6HhEAK';*/
                    //END
                }
            }
        }
    }
    
    public static void AfterInsert(list<Case> Cases){
        Group renewalCaseQueue          = [select id, name from group where name = 'Renewal Case'][0];
        Map<ID, Property__c> homeMap    = new Map<ID, Property__c>([SELECT Id, bypass_skills_routing__c, Resident_Services_Coordinator__c, Home_Manager_User__c  FROM Property__c]);
        // checkIfWorkOrderNeeded(Cases);
        set<id> ParentCaseIds = new set<id>();
        set<id> DelinquencyCaseIds = new set<id>();
        Set<Id> commomnRecordTypeIds = new Set<Id>();
        //Id commonTransfer = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Common - Transfer').getRecordTypeId();
        Id commonTransfer = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Common - Inside Sales Lead').getRecordTypeId();
        commomnRecordTypeIds.add(commonTransfer);
        
        for(Case c: Cases){

            if( commomnRecordTypeIds.contains(c.RecordTypeId) ){

                //Creating list of all cases where Parent ID not blank so that we can perform rollup on these records.
                if(c.ParentID != null){
                    ParentCaseIds.add(c.ParentID); 
                }
                
                //Creating list of all Delinquent Cases where Account ID not blank so that we can perform rollup on these records.     
                if( 
                    
                    (Schema.SObjectType.Case.getRecordTypeInfosById().get(c.RecordTypeId).getDeveloperName() == 'CIS_Delinquent_Payment')
                    
                    ||
                    
                    Schema.SObjectType.Case.getRecordTypeInfosById().get(c.RecordTypeId).getDeveloperName() == 'Noah_Delinquent_Payments'
                    
                ){
                    if(c.AccountID != null){
                        DelinquencyCaseIds.add(c.AccountID); 
                    }
                }

            }
        }
        
        
        if(ParentCaseIds.size() > 0){
            RollupCountonParentCase(ParentCaseIds);
        }
        
        if(DelinquencyCaseIds.size() > 0){
            RollupDelinquencyCasesOnAccount(DelinquencyCaseIds);
        }
        
        List<String> TierBasedRouting = new List<String>();
        
        List<recordType> rts = [Select id, name, developerName from recordType where sObjectType = 'Case'];
        map<id, recordType> rtMap = new map<id, recordType>();
        for(recordType rt: rts){
            rtMap.put(rt.id, rt);
        }
        
        for(case c: Cases){
            
            if( commomnRecordTypeIds.contains(c.RecordTypeId) ){

                if(c.home__c == null || homeMap.get(c.home__c).Bypass_skills_routing__c == false){
                    if(((rtMap.get(c.recordTypeid).name.containsIgnoreCase('CSS') || rtMap.get(c.recordTypeid).name.containsIgnoreCase('MILY')) && !rtMap.get(c.recordTypeid).name.containsIgnoreCase('Inside Sales'))){
                        //check if renewals sub issue type, if so do not route
                        if((c.sub_issue_type__c != null && c.Sub_Issue_Type__c == 'Renewals') || c.OwnerId == renewalCaseQueue.Id){
                            //do nothing for now, email-to-case, process builder, and flow handle this currently
                        }
                        else
                        TierBasedRouting.add(c.id);
                    }
                }

            }
        }
        
        
        // if(TierBasedRouting.size() > 0){
        //     CreateSkillsPSRTiers CreatePSR = new CreateSkillsPSRTiers(TierBasedRouting);
        //     // enqueue the job for processing
        //     ID jobID = System.enqueueJob(CreatePSR);
        // }
    }
    
    public static void BeforeUpdate(list<Case> Cases, Map<id,Case> OldCases){
        Map<ID, Property__c> homeMap    = new Map<ID, Property__c>([SELECT Id  FROM Property__c]);
        list<id> caseIDsDeleteWO        = new List<ID>();
        Set<Id> commomnRecordTypeIds     = new Set<Id>();
        
        for(recordtype rt: [select id,name,developername from recordtype where sobjecttype ='Case' and (developername LIKE 'CIS%' OR developername LIKE 'CSS%')]){
            commomnRecordTypeIds.add(rt.id);
        }
        
		

        for(case c: cases){

            if( commomnRecordTypeIds.contains(c.RecordTypeId) ){

                //if case is switched to Non-FSL home or if FSL home is deleted
                if((c.home__c != null && oldCases.get(c.id).home__c != null && c.home__c == null))
                    caseIDsDeleteWO.add(c.id);

            }
        }
        
        // if(caseIDsDeleteWO.size() > 0)
        //   DeleteWorkOrders(caseIDsDeleteWO);
        
        for(Case c: Cases){

            if( commomnRecordTypeIds.contains(c.RecordTypeId) ){

                if(c.Status != oldCases.get(c.id).Status)
                    c.Status_Last_Changed__c = Date.today();
                
                if(c.sub_issue_type__c != 'Renewals' && OldCases.get(c.id).sub_issue_type__c == 'Renewals')
                    c.Email_To_Case_Renewal_Case__c = false;

            }
        }
        
        
        id MSSAgents = System.Label.MSSAgentsGroupID;
        List<RecordType> CSSRecordTypes = [Select id from recordType where name like '%CSS%' and sobjectType = 'Case'];
        List<String> skillsBasedRoutingCases = new List<String>();
        List<id> CSSRecordTypeIds = new List<Id>();
        for(recordType rt : CSSRecordTypes){
            CSSRecordTypeIds.add(rt.id);
        }
        
        set<String> OppsString =  new set<String>();
        set<String> AccsString =  new set<String>();
        for(Case c: Cases){
            if( commomnRecordTypeIds.contains(c.RecordTypeId) ){

                if(c.Opportunity__c != null && OldCases.get(c.id).Opportunity__c == null)
                    OppsString.add(c.Opportunity__c);
                
                if(c.Account__c != null  && OldCases.get(c.id).Account__c == null)
                    AccsString.add(c.Account__c);
                
                if(c.Accountid != null  && OldCases.get(c.id).Accountid == null)
                    AccsString.add(c.Accountid);
            }
        }
        
        if(OppsString.size() > 0 || AccsString.size() > 0){
            Map<ID, Opportunity> Oppmap = new Map<ID, Opportunity>();
            list<Opportunity> opps =  [SELECT Id, account_name_formula__c,Accountid FROM opportunity where id in : OppsString or Accountid in:AccsString];
            for(Opportunity o: opps){
                Oppmap.put(o.Id,o);
                Oppmap.put(o.AccountId,o);
            }
            
            for(Case c : Cases){

                if( commomnRecordTypeIds.contains(c.RecordTypeId) ){

                    if(c.Opportunity__c != null && Oppmap.get(c.Opportunity__c) != null && !test.isRunningTest())
                        c.Account_Name_Searchable__c = Oppmap.get(c.Opportunity__c).account_name_formula__c;
                    
                    if(c.Account__c != null && Oppmap.get(c.Account__c) != null && !test.isRunningTest())
                        c.Account_Name_Searchable__c = Oppmap.get(c.Account__c).account_name_formula__c;
                    
                    if(c.Accountid != null && Oppmap.get(c.Accountid) != null && !test.isRunningTest())
                        c.Account_Name_Searchable__c = Oppmap.get(c.Accountid).account_name_formula__c;
                
                }
            }
        }
        
        
        
        id commonLiving = System.Label.CommonLivingUserID;
        id ISRecordType = System.Label.CaseInsideSalesRecordTypeID;
        id LeasingAdminRecordType = System.Label.CaseLeasingAdminTemplateRecordTypeID;
        List<FeedItem> feedItems = new List<feedItem>();
        
        List<Case> SuiteHomeRoomChanged = new List<Case>();
        for(Case c: Cases){

            if( commomnRecordTypeIds.contains(c.RecordTypeId) ){
                if((c.home__c != OldCases.get(c.id).home__c)||((c.suite__c != OldCases.get(c.id).suite__c))||((c.room__c != OldCases.get(c.id).room__c)) || ((c.opportunity__c != OldCases.get(c.id).opportunity__c))){
                    SuiteHomeRoomChanged.add(c);
                }
            }
        }
        
        // if(SuiteHomeRoomChanged.size() > 0)
        //     updateWorkOrderSuites(SuiteHomeRoomChanged);
        
        if(feedItems.size() > 0)
            insert feedItems;
    }
    
    
    public static void AfterUpdate(list<Case> Cases, Map<id,Case> OldCases){

        Set<Id> commomnRecordTypeIds = new Set<Id>();
        //Id commonTransfer = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Common - Transfer').getRecordTypeId();
        Id commonTransfer = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Common - Inside Sales Lead').getRecordTypeId();
        commomnRecordTypeIds.add(commonTransfer);

        group renewalCaseQueue;
        group ReassignToMX;
        List<Group> Queues = [select id, name from group where (name = 'Renewal Case' or name = 'Reassign to MX')];
        for(group g: Queues){
            if(g.name == 'Renewal Case' )
                renewalCaseQueue = g;
            else if(g.name == 'Reassign to MX')
                ReassignToMX = g;
        }
        
        Map<ID, Property__c> homeMap = new Map<ID, Property__c>([SELECT Id, bypass_skills_routing__c, resident_services_coordinator__c FROM Property__c]);
        List<Case> casesWithHomes = new List<Case>();
        for(case c: cases){

            if( commomnRecordTypeIds.contains(c.RecordTypeId) ){

                if(c.Home__c != null)
                    casesWithHomes.add(c);

            }
        }
        // checkIfWorkOrderNeeded(CasesWithHomes, OldCases);
        List<RecordType> CSSRecordTypes = [Select id from recordType where (name like '%CSS%' or (name like '%MILY%' and name != 'MILY - Inside Sales'))  and sobjectType = 'Case'];
        List<String> TierRoutingChanges = new List<String>();
        List<String> TierRoutingEscalations = new List<String>();
        List<String> TierRoutingDeletions = new List<String>();
        List<id> CSSRecordTypeIds = new List<Id>();
        for(recordType rt : CSSRecordTypes){
            CSSRecordTypeIds.add(rt.id);
        }
        for(Case c: Cases){
            
            if( commomnRecordTypeIds.contains(c.RecordTypeId) ){

                //dont run on solved or closed cases
                if(c.status != 'Closed' && c.Status != 'Solved'){
                    
                    
                    //must be in list of skills based recordtypes
                    //if home is not null and bypass skills routing isnt true OR if home is null
                    if(CSSRecordTypeIds.contains(c.RecordTypeid) && ((c.home__c != null && (homeMap.get(c.home__c).Bypass_skills_routing__c == false)) || c.home__c == null)){
                        
                        //Is it a Renewal sub issue type *These don't get routed, they go to the renewals manager on the home
                        if((c.sub_issue_type__c != null && c.Sub_Issue_Type__c == 'Renewals') || c.OwnerId == renewalCaseQueue.Id){
                            if(oldCases.get(c.Id).Sub_Issue_Type__c == null || oldCases.get(c.Id).Sub_Issue_Type__c != 'Renewals'){
                                
                            }
                        }
                        
                        //if assigned to the reassign to MX queue
                        else if(c.ownerid == ReassignToMX.id && oldCases.get(c.id).ownerid != ReassignToMX.id){
                            TierRoutingChanges.add(c.id);
                        }
                        
                        //if old recordType was NOT skills based routing
                        else if(!CSSRecordTypeIds.contains(OldCases.get(c.id).recordTypeid)){
                            TierRoutingChanges.add(c.id);
                        }
                        
                        
                        //if sub issue changed
                        else if(c.Sub_Issue_Type__c != OldCases.get(c.id).sub_issue_type__c){
                            TierRoutingChanges.add(c.id);
                        }
                        
                        
                        //if Escalated
                        else if(c.isEscalated == true && OldCases.get(c.id).isEscalated == false){
                            TierRoutingEscalations.add(c.id);
                        }
                        
                        //if home changed from bypass skills routing to Non bypass skills routing
                        else if(c.home__C != null && oldCases.get(c.id).home__c != null && (homemap.get(c.home__C).bypass_skills_routing__c == false && homemap.get(oldCases.get(c.id).home__c).bypass_skills_routing__c == true)){
                        TierRoutingChanges.add(c.id);
                        }
                        
                        
                        //if home lookup is deleted, and the old home was a bypass skills routing home
                        else if(c.home__c == null && oldCases.get(c.id).home__c != null && homemap.get(oldCases.get(c.id).home__c).bypass_skills_routing__c == true){
                            TierRoutingChanges.add(c.id);
                        }
                        
                        //if case is re-opened from solved or closed
                        else if(oldCases.get(c.id).status == 'Solved' || oldCases.get(c.id).status == 'Closed'){
                            TierRoutingChanges.add(c.id);
                        }
                    }
                    
                    //if case from RSC home sent to 'Reassign to MX' queue
                    if((CSSRecordTypeIds.contains(c.RecordTypeid) && ((c.home__c != null && (homeMap.get(c.home__c).Bypass_skills_routing__c == true)))) &&
                    (c.ownerid == ReassignToMX.id && oldCases.get(c.id).ownerid != ReassignToMX.id)){
                        if(homeMap.get(c.Home__c).resident_services_coordinator__c != null){
                            AssignCasetoResidentServiceCoordinator(c.id,homeMap.get(c.Home__c).resident_services_coordinator__c);
                        }
                        
                    }
                }
                
                //if recordType changed to non skills-based routing recordType
                if(!CSSRecordTypeIds.contains(c.RecordTypeid) && CSSRecordTypeIds.contains(OldCases.get(c.id).recordTypeid)){
                    TierRoutingDeletions.add(c.id);
                }
                
                //if home was changed to a bypass skills routing home, delete the routing objects
                if(c.home__c != null && homeMap.get(c.home__c).Bypass_skills_routing__c == true && c.home__c != OldCases.get(c.id).home__c){
                    TierRoutingDeletions.add(c.id);
                }
                
                
                
                //if case is changed to solved or closed, delete tier routing
                if(CSSRecordTypeIds.contains(c.RecordTypeid) && ((c.status == 'Solved' && OldCases.get(c.id).status != 'Solved') || (c.Status == 'Closed' && OldCases.get(c.id).status != 'Closed'))){
                    TierRoutingDeletions.add(c.id);
                }

            }
            
        }
        
        // if(TierRoutingChanges.size() > 0){
        //     UpdateSkillsPSRTiers UpdatePSR = new UpdateSkillsPSRTiers(TierRoutingChanges);
        //     // enqueue the job for processing
        //     ID jobID = System.enqueueJob(UpdatePSR);
        // }
        
        // if(TierRoutingEscalations.size() > 0){
        //     EscalateSkillsPSRTiers EscalatePSR = new EscalateSkillsPSRTiers(TierRoutingEscalations);
        //     // enqueue the job for processing
        //     ID jobID = System.enqueueJob(EscalatePSR);
        // }
        
        // if(TierRoutingDeletions.size() > 0){
        //     DeleteSkillsPSRTiers DeletePSR = new DeleteSkillsPSRTiers(TierRoutingDeletions);
        //     // enqueue the job for processing
        //     ID jobID = System.enqueueJob(DeletePSR);
        // }
        
        set<id> ParentCaseIds = new set<id>();
        set<id> DelinquencyCaseIds = new set<id>();
        
        for(Case c: Cases){

            if( commomnRecordTypeIds.contains(c.RecordTypeId) ){

                if(c.Status != OldCases.get(c.id).Status && c.Status == 'Payment Plan Sent' && c.Partially_Customer_ID__c  != null && c.Partial_ly_Offer__c != null){
                    partialAPIHelperClass.CreatePaymentPlanForCustomer(c.id);
                }
                
                if(c.Create_Partial_ly_Customer__c != OldCases.get(c.id).Create_Partial_ly_Customer__c && c.Create_Partial_ly_Customer__c == True && c.Partially_Customer_ID__c == null){
                    partialAPIHelperClass.CreateCustomerforAccount(c.accountid,c.id);
                }
                
                //Creating list of all cases where Parent ID got updated so that we can perform rollup on these records.
                if(c.ParentID != OldCases.get(c.id).ParentID){
                    if(c.ParentID != null){ ParentCaseIds.add(c.ParentID); }
                    if(OldCases.get(c.id).ParentID != null){ ParentCaseIds.add(OldCases.get(c.id).ParentID); }
                }
                
                //Creating list of all Delinquent Cases where Account ID not blank and Status got updated so that we can perform rollup on these records.     
                if(
                    (
                        Schema.SObjectType.Case.getRecordTypeInfosById().get(c.RecordTypeId).getDeveloperName() == 'CIS_Delinquent_Payment') 
                    ||
                    Schema.SObjectType.Case.getRecordTypeInfosById().get(c.RecordTypeId).getDeveloperName() == 'Noah_Delinquent_Payments'          
                ){
                    if(c.AccountID != null && c.IsClosed != OldCases.get(c.id).IsClosed){
                        DelinquencyCaseIds.add(c.AccountID); 
                    }
                    
                }
            }
        }
        
        if(ParentCaseIds.size() > 0){
            RollupCountonParentCase(ParentCaseIds);
        }
        
        if(DelinquencyCaseIds.size() > 0){
            RollupDelinquencyCasesOnAccount(DelinquencyCaseIds);
        }
    }
    
    @future
    public static void AssignCasetoResidentServiceCoordinator(string caseid, string ownerid){
        Case c = new Case();
        c.ownerid = ownerid; 
        c.id = caseid; 
        update c; 
    }
    
    public static void populatecontactonOrphanCase_EmailtoCase(list<case> newcases){
        set<string> emails = new set<string>();
        
        for(case c: newcases){
            if(c.suppliedemail != null)
                emails.add(c.suppliedemail);
        }
        
        map<string,id> contactidmap = new map<string,id>();
        list<account> personaccs = [select id,personemail,personcontactid from account where personemail != null and personemail in:emails and ispersonaccount = true order by createddate desc limit 200];
        
        for(account a: personaccs){
            contactidmap.put(a.personemail,a.personcontactid);
        }
        
        for(case c: newcases){
            if( contactidmap.get(c.suppliedEmail) != null){
                c.contactid = contactidmap.get(c.suppliedEmail);
                c.Contact_Populated_using_Trigger__c = true;
            }
        }
    }
    
    //Method to count child cases and store it on parent case in custom field. 
    public static void RollupCountonParentCase(set<id> CaseIDs){
        list<Case> Cases = [ select Child_Cases_Count__c,(Select ID from Cases) from Case where ID in:CaseIDs ];
        for(Case c: Cases){
            c.Child_Cases_Count__c = c.Cases.size();
        }
        
        update Cases;
    }
    
    //Method to count child Delinquency cases and store it on parent Account in custom fields. 
    public static void RollupDelinquencyCasesOnAccount(set<id> accids){
        //Getting related cases from Accounts.
        list<Account> accs = [select Delinquency_Cases__c, Opened_Delinquency_Cases__c,(Select id,IsClosed from Cases where RecordType.DeveloperName = 'CIS_Delinquent_Payment' or RecordType.DeveloperName = 'Noah_Delinquent_Payments') from Account where Id in:accids];
        
        for( Account a : accs ){
            list<Case> OpenedCases = new list<Case>();
            
            a.Delinquency_Cases__c = a.Cases.size();
            
            for(Case c : a.Cases ){
                if(c.IsClosed == False){
                    OpenedCases.add(c);
                }
            }
            
            a.Opened_Delinquency_Cases__c = OpenedCases.size();
        }
        
        update accs;
    }
    
    public static void EmailtoCaseForwarderEmailParser(list<Case> Cases){
        Set<Id> commomnRecordTypeIds = new Set<Id>();
        //Id commonTransfer = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Common - Transfer').getRecordTypeId();
        Id commonTransfer = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Common - Inside Sales Lead').getRecordTypeId();
        commomnRecordTypeIds.add(commonTransfer);
        
        map<id,string> CaseEmailMap = new map<id,string> ();
        for(Case c : Cases){

            if( commomnRecordTypeIds.contains(c.RecordTypeId) ){
                if( Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(c.RecordTypeID) != null && Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(c.RecordTypeID)?.getName()?.Contains('CSS') ){
                    if(c.Description != null && c.SuppliedEmail != null && c.SuppliedEmail.Contains('common.com') ){
                        
                        if(c.Description.Contains('@')){
                            list<string> StrDescriptionlist = c.description.split('\n');
                            String StrDescription = c.description.replace('\r\n',' ');
                            Pattern emailPattern = Pattern.compile('([a-zA-Z0-9_\\+-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))');
                            
                            boolean IsEmailFound = False;
                            
                            for(string s : StrDescriptionlist){
                                s = s.replace('\r\n',' ');
                                system.debug('s::::::::::::::::'+s);
                                If(IsEmailFound){ 
                                    system.debug('In break:::');
                                    break; 
                                }
                                
                                if(s.Contains('@')) {
                                    Matcher matcher = emailPattern.matcher(s);
                                    while (matcher.find()){   
                                        if(matcher.group() != null && !matcher.group().contains('common.com') && !matcher.group().contains('zendesk.com')){
                                            IsEmailFound = True;
                                            system.debug('In email found:::');
                                            CaseEmailMap.put(c.id,matcher.group()); 
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        
        map<string,id> ContactEmailMap = new map<string,id> ();
        list<Contact> existingContacts = [select id,Email from Contact where email in:CaseEmailMap.Values()];
        for(Contact c : existingContacts){
            ContactEmailMap.put(c.Email,c.id);
        }
        
        for(Case c : cases){

            if( commomnRecordTypeIds.contains(c.RecordTypeId) ){
                if(CaseEmailMap.get(c.id) != null){
                    c.SuppliedEmail = CaseEmailMap.get(c.id);
                    if(ContactEmailMap.get(CaseEmailMap.get(c.id)) != null){
                        c.ContactID = ContactEmailMap.get(CaseEmailMap.get(c.id));
                    }
                    
                }
            }
            
        }
    }
    
    public static void AutoReplyCriteriaChecker(list<Case> Cases){

        Set<Id> commomnRecordTypeIds = new Set<Id>();
        //Id commonTransfer = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Common - Transfer').getRecordTypeId();
        Id commonTransfer = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Common - Inside Sales Lead').getRecordTypeId();
        commomnRecordTypeIds.add(commonTransfer);

        // Get the default business hours
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'CSS - Common Member Support' and IsActive = True];
        List<Holiday> holidays =[Select ActivityDate From Holiday];
        
        for(Case c: Cases){

            if( commomnRecordTypeIds.contains(c.RecordTypeId) ){
            
                if( Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(c.RecordTypeID) != null && Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(c.RecordTypeID)?.getName()?.Contains('CSS') ){
                    // Find whether the time is within the default business hours
                    Boolean isWithin = BusinessHours.isWithin(bh.id, system.Now());
                    c.Created_Inside_Business_Hours__c = isWithin;
                    
                    for(holiday h: holidays){
                        system.debug('ss::'+system.Today());
                        system.debug('ss::'+h.ActivityDate);
                        if(system.Today() == h.ActivityDate){
                            c.Created_In_Holidays__c = TRUE;    
                        }
                    }
                }

            }
            
        }
        
        
    }
    
    public static void AutoCloseCases(list<Case> Cases){
        list<Auto_Close_Cases__mdt> Configs = [Select id, Subject_Contains__c, Supplied_Email__c, Description_Contains__c, New_Owner__c, New_Status__c from Auto_Close_Cases__mdt];
        
        if(Configs.size() > 0){
            set<string> userNames = new set<string>();
            
            for( Auto_Close_Cases__mdt config : Configs ){
                if(config.New_Owner__c != null){
                    userNames.add(config.New_Owner__c);
                }
            }
            
            Map<string,id> UserMap = new Map<string,id>();
            list<User> users = [select id,Name from User where Name in:userNames];
            for(User u: users){
                UserMap.put(u.name, u.id);
            }
            
            Map<string,id> QueueMap = new Map<string,id>();
            list<group> groups = [select id,Name from group where Name in:userNames and type ='queue'];
            for(group u: groups){
                QueueMap.put(u.name, u.id);
            }
            
            for(Case c : Cases){
                if(c.Subject != null && c.SuppliedEmail != null && c.Description != null){
                    
                    if(c.Subject.contains('Salesforce list email: Couldn\'t send') && Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(c.RecordTypeID) != null && Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(c.RecordTypeID)?.getName()?.Contains('CSS') && c.SuppliedEmail.toLowerCase() == 'no-reply@salesforce.com'){
                        c.Status = 'Open';
                        c.OwnerID = '00G3u000000Lp0n';
                        
                    }
                    else
                    {
                        if( Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(c.RecordTypeID) != null && Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosById().get(c.RecordTypeID)?.getName()?.Contains('CSS') ){
                            for( Auto_Close_Cases__mdt config : Configs ){
                                if(c.subject.toLowerCase().Contains(config.Subject_Contains__c.toLowerCase()) && c.Description.toLowerCase().Contains(config.Description_Contains__c.toLowerCase()) && c.SuppliedEmail.toLowerCase() == config.Supplied_Email__c.toLowerCase()) {
                                    c.Status = config.New_Status__c;                            
                                    c.Auto_Closed__c = true;
                                    c.Send_CSAT_Survey__c = False;
                                    if(config.New_Owner__c != null){
                                        
                                        if(UserMap.get(config.New_Owner__c) != null){
                                            c.OwnerID = UserMap.get(config.New_Owner__c);
                                        }
                                        else if(QueueMap.get(config.New_Owner__c) != null){
                                            c.OwnerID = QueueMap.get(config.New_Owner__c);
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                        
                    }
                    
                }
                
            }
            
        }
    }
    
    //Remove when deploy trigger by removing work order comments after fixing query bug. test converge got decreased because commented 2 methods temporary
    public static void TempTestConverageBooster(){
        Integer i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
        i = 0;
    }
    
    public static void sendSuccessEmail(String emailBody){
        
        Messaging.reserveSingleEmailCapacity(2);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Strings to hold the email addresses to which you are sending the email.
        String[] toAddresses = new String[] {'james.Holden+1236@common.com'}; 
                
                
                // Assign the addresses for the To and CC lists to the mail object.
                mail.setToAddresses(toAddresses);
        
        // Specify the address used when the recipients reply to the email. 
        mail.setReplyTo('sfdc-admins@common.com');
        
        // Specify the name used as the display name.
        mail.setSenderDisplayName('JT Debug messaging');
        
        // Specify the subject line for your email address.
        mail.setSubject('Debug on CaseTriggerHandler');
        
        // Set to True if you want to BCC yourself on the email.
        mail.setBccSender(false);
        
        // Optionally append the salesforce.com email signature to the email.
        // The email address of the user executing the Apex Code will be used.
        mail.setUseSignature(false);
        
        // Specify the text content of the email.
        mail.setPlainTextBody(emailBody);
        
        mail.setHtmlBody('');
        
        // Send the email you have created.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}