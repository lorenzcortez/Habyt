Public Class OpportunityHandler{
    
    
    //added by Einsteam
    Public static void BeforeInsert(List<Opportunity> newOpps){
        list<Opportunity> RRList = new list<Opportunity>();
        list<Opportunity> ChangeList = new list<Opportunity>();
        list<Opportunity> moveinList = new list<Opportunity>();
        list<Opportunity> LeaseList = new list<Opportunity>();
        // String CommonLiving = [SELECT id from user where name = 'Common Living'][0].id;
        String CommonLiving = System.Label.CommonLivingUser;
        List<Account> accList = new List<Account>();

        for(Opportunity o : newOpps){

            if( o.Record_Type_Name__c.toLowercase().contains('common') ){
                if(o.stageName == 'Lease Application' && o.Leasing_Administrator__c != CommonLiving && o.Leasing_Administrator__c != null){
                    Account a = new Account();
                    a.id = o.accountid;
                    a.ownerid = o.Leasing_Administrator__c;
                    accList.add(a);
                }
            }
        }
        if(accList.size() > 0)
            update accList;
        
        
        
        for(Opportunity opp: newOpps){

            if( opp.Record_Type_Name__c.toLowercase().contains('common') ){

                if(opp.Home_Committed__c != null && opp.City_Lookup__c == null)
                    ChangeList.add(opp);
                
                if(opp.StageName == 'Member' && opp.Start_Date_Of_Occupancy__c >= system.Today())
                    moveinList.add(opp);
                
                if((opp.StageName == 'Lease Application' || opp.StageName == 'Member') && opp.Leasing_Administrator__c == null)
                    LeaseList.add(opp);
                
                if(opp.City_Lookup__c != null)
                    RRList.add(opp);

            }
        }
        
        
        if(ChangeList.size() > 0 )
            UpdateCityFromHomeCommitted(ChangeList);
        
        if(moveinList.size() > 0)
            UpdateMoveInMember(moveinList); 
        
        if(LeaseList.size() > 0){
            for(Opportunity o : LeaseList){
                o.leasing_administrator__c = CommonLiving;
            }
        }
        
        if(RRlist.size() > 0)
            RoundRobinHomeAssignment(RRlist);
        
    }
    
    //added by Einsteam
    Public static void BeforeUpdate(List<Opportunity> newOpps, Map<Id,Opportunity> oldMap){
        //holdover tenant close tasks
        List<Opportunity> HoldoverTenants = new List<Opportunity>();
        for(Opportunity o: newOpps){

            if( o.Record_Type_Name__c.toLowercase().contains('common') ){

                if(o.occupancy_status__c == 'Holdover Tenant' && o.Occupancy_Status__c != oldMap.get(o.id).occupancy_status__c)
                    holdoverTenants.add(o);
            
            }
        }
        
        if(holdoverTenants.size() > 0)
            CloseMoveOutTasksHoldover(holdoverTenants);
        
        
        List<Opportunity> HoldoverDateAdded = new List<Opportunity>();
        
        for(Opportunity o: newOpps){

            if( o.Record_Type_Name__c.toLowercase().contains('common') ){

                if(o.Holdover_Tenant_Move_Out_Date__c != null && oldMap.get(o.id).Holdover_Tenant_Move_Out_Date__c == null)
                    holdoverDateAdded.add(o);

            }
        }
        
        if(holdOverDateAdded.size() > 0)
            HoldoverTenantMoveOutDateAdded(holdoverDateAdded);
        
        //get common living id
        String CommonLiving = System.Label.CommonLivingUser;
        
        //if stage is lease Application and the leasing administrator is changed, update the account owner
        List<Account> accList = new List<Account>();
        for(Opportunity o : newOpps){

            if( o.Record_Type_Name__c.toLowercase().contains('common') ){

                if(o.stageName == 'Lease Application' && o.Leasing_Administrator__c != oldMap.get(o.id).leasing_administrator__c && o.Leasing_Administrator__c != CommonLiving){
                    Account a = new Account();
                    a.id = o.accountid;
                    a.ownerid = o.Leasing_Administrator__c;
                    accList.add(a);
                }

            }
        }
        
        if(accList.size() > 0)
            update accList;
        
        
        list<Opportunity> ChangeList = new list<Opportunity>();
        list<Opportunity> moveinList = new list<Opportunity>();
        list<Opportunity> LeaseList = new list<Opportunity>();
        
        Id RealEstateRcordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Common_Real_Estate').getRecordTypeId();
        
        for(Opportunity opp: newOpps){

            if( opp.Record_Type_Name__c.toLowercase().contains('common') ){

                if(opp.Home_Committed__c != oldMap.get(opp.id).Home_Committed__c && opp.City_Lookup__c == null)
                    ChangeList.add(opp);
                
                if(oldMap.get(opp.id).StageName != opp.StageName || oldMap.get(opp.id).Start_Date_Of_Occupancy__c != opp.Start_Date_Of_Occupancy__c)
                    moveinList.add(opp);
                
                if( ((opp.StageName == 'Lease Application' && oldMap.get(opp.id).StageName != 'Lease Application') || (opp.StageName == 'Member' && oldMap.get(opp.id).StageName != 'Member')) && opp.Leasing_Administrator__c == null)
                    LeaseList.add(opp);

            }
        }
        
        if(ChangeList.size() > 0 )
            UpdateCityFromHomeCommitted(ChangeList);
        
        if(moveinList.size() > 0)
            UpdateMoveInMember(moveinList);
        
        if(LeaseList.size() > 0){
            for(Opportunity o : LeaseList){
                o.leasing_administrator__c = CommonLiving;
            }
        }
    }
    
    //added by Einsteam
    Public static void AfterUpdate(List<Opportunity> newOpps, Map<Id,Opportunity> oldMap){
        
        list<Opportunity> OCCStatusChangedOppList = new list<Opportunity>();
        list<Opportunity> StageChangedOppList = new list<Opportunity>();
        list<Opportunity> OccStartDateChangedOppList = new list<Opportunity>();
        list<Opportunity> MostRecentActiveOppChangeList = new list<Opportunity>();
        set<Id> MostRecentOccupancyDateRoomIDs = new set<Id>();
        
        set<id> OppRoomIds = new set<id>();
        set<Id> OppSuiteIds = new set<Id>();
        
    
        for(Opportunity opp :  newOpps){

            if( opp.Record_Type_Name__c.toLowercase().contains('common') ){

                if(opp.Occupancy_Status__c != OldMap.get(opp.id).Occupancy_Status__c && opp.AccountID != null){
                    OCCStatusChangedOppList.add(opp);
                }
                
                if((opp.StageName != OldMap.get(opp.id).StageName || opp.Occupancy_Status__c != OldMap.get(opp.id).Occupancy_Status__c ) && opp.AccountID != null){
                    StageChangedOppList.add(opp);
                }
                
                if(opp.Start_Date_of_Occupancy__c != OldMap.get(opp.id).Start_Date_of_Occupancy__c && opp.AccountID != null){
                    OccStartDateChangedOppList.add(opp);
                }
                
                
                if(opp.Occupancy_Status__c != OldMap.get(Opp.id).Occupancy_Status__c && opp.AccountID != null){
                    MostRecentActiveOppChangeList.add(opp);
                }
                
                if(opp.Occupancy_Status__c != OldMap.get(Opp.id).Occupancy_Status__c || opp.Room_Selected__c != OldMap.get(Opp.id).Room_Selected__c || opp.Vacancy_Date__c != OldMap.get(Opp.id).Vacancy_Date__c || (opp.StageName == 'Member' && OldMap.get(opp.id).StageName != 'Member') ||  (opp.StageName != 'Member' && OldMap.get(opp.id).StageName == 'Member') ){
                    if(opp.Room_Selected__c != null) { OppRoomIds.add(opp.Room_Selected__c); }
                    if(OldMap.get(Opp.id).Room_Selected__c != null) { OppRoomIds.add(OldMap.get(Opp.id).Room_Selected__c); }
                }
                
                if(opp.Occupancy_Status__c != OldMap.get(Opp.id).Occupancy_Status__c || opp.ApartmentRef__c != OldMap.get(Opp.id).ApartmentRef__c || opp.Couple__c != OldMap.get(Opp.id).Couple__c || opp.Has_ESA__c != OldMap.get(Opp.id).Has_ESA__c){
                    if(opp.ApartmentRef__c  != null) { OppSuiteIds.add(opp.ApartmentRef__c); }
                    if(OldMap.get(Opp.id).ApartmentRef__c != null) { OppSuiteIds.add(OldMap.get(Opp.id).ApartmentRef__c); }
                }
                
                if(opp.Room_Selected__c != OldMap.get(Opp.id).Room_Selected__c || opp.End_Date_of_Occupancy__c != OldMap.get(Opp.id).End_Date_of_Occupancy__c || opp.Occupancy_Status__c != OldMap.get(Opp.id).Occupancy_Status__c){
                    if(opp.Room_Selected__c != null) { MostRecentOccupancyDateRoomIDs.add(opp.Room_Selected__c); }
                    if(OldMap.get(Opp.id).Room_Selected__c != null) { MostRecentOccupancyDateRoomIDs.add(OldMap.get(Opp.id).Room_Selected__c); }
                }

            }
            
        }
        
        if(OCCStatusChangedOppList.size() > 0)
            UpdateOccupancyStatusOnAccount(OCCStatusChangedOppList);
        
        if(StageChangedOppList.size() > 0)
            UpdateStagetoParentAccount(StageChangedOppList);
        
        if(OccStartDateChangedOppList.size() > 0)
            UpdateOccupancyStartDateOnAccountMemberSince(OccStartDateChangedOppList);    
        
        
        
        if(MostRecentActiveOppChangeList.size() > 0){
            UpdateMostRecentActiveOpponAccount(MostRecentActiveOppChangeList);
            UpdateMostRecentOpponAccount(MostRecentActiveOppChangeList);
        }
        
        if(OppRoomIds.size() > 0){
            UpdateStatusOnRoomBasedOnRelatedOpportunity(OppRoomIds);
        }
        
        if(OppSuiteIds.size() > 0){
            UpdateSuiteBasedOnRelatedOpportunity(OppSuiteIds);
        }
        
        if(MostRecentOccupancyDateRoomIDs.size() > 0){
            SetOccupancyDateOnRoomFromRecentOpp(MostRecentOccupancyDateRoomIDs);
        }
    }
    
    
    //added by Einsteam
    Public static void AfterInsert(List<Opportunity> newOpps){
        
        list<Opportunity> OCCStatusChangedOppList = new list<Opportunity>();
        list<Opportunity> StageChangedOppList = new list<Opportunity>();
        list<Opportunity> OccStartDateChangedOppList = new list<Opportunity>();
        list<Opportunity> MostRecentActiveOppChangeList = new list<Opportunity>();
        list<Opportunity> MostRecentOppChangeList = new list<Opportunity>();
        set<Id> MostRecentOccupancyDateRoomIDs = new set<Id>();
        
        set<id> OppRoomIds = new set<id>();
        
        for(Opportunity opp :  newOpps){

            if( opp.Record_Type_Name__c.toLowercase().contains('common') ){

                if(opp.Occupancy_Status__c != null && opp.AccountID != null){
                    OCCStatusChangedOppList.add(opp);
                }
                
                if(opp.AccountID != null){
                    StageChangedOppList.add(opp);
                }
                
                if(opp.Start_Date_of_Occupancy__c != null && opp.AccountID != null){
                    OccStartDateChangedOppList.add(opp);
                }
                
                
                if(opp.Occupancy_Status__c != null && opp.AccountID != null){
                    MostRecentActiveOppChangeList.add(opp);
                }
                
                if(opp.AccountID != null){
                    MostRecentOppChangeList.add(opp);
                }
                
                Integer dt1 = null;
                if(opp.Vacancy_Date__c != null)
                    dt1 = (system.today()).daysBetween(opp.Vacancy_Date__c);
                
                
                if(opp.Room_Selected__c != null && ( ( (opp.Occupancy_Status__c == 'Active' || opp.Occupancy_Status__c == 'Current month-to-month')   && ( opp.Vacancy_Date__c == null || (opp.Vacancy_Date__c != null && dt1 >= 60) ) ) || (opp.StageName == 'Member' && opp.Occupancy_Status__c == null)  || opp.Occupancy_Status__c == 'Moving In' )){
                    OppRoomIds.add(opp.Room_Selected__c);
                }
                
				System.debug('Room_Selected__c' + opp.Room_Selected__c);
                System.debug('End_Date_of_Occupancy__c' + opp.End_Date_of_Occupancy__c);
                System.debug('Occupancy_Status__c' + opp.Occupancy_Status__c);
                
                if(opp.Room_Selected__c != null && opp.End_Date_of_Occupancy__c != null && (opp.Occupancy_Status__c == 'Active'  || opp.Occupancy_Status__c == 'Current month-to-month') ){
                    MostRecentOccupancyDateRoomIDs.add(opp.Room_Selected__c);
                }
            
            }
        }
        
        if(OCCStatusChangedOppList.size() > 0)
            UpdateOccupancyStatusOnAccount(OCCStatusChangedOppList);
        
        if(StageChangedOppList.size() > 0)
            UpdateStagetoParentAccount(StageChangedOppList);
        
        if(OccStartDateChangedOppList.size() > 0)
            UpdateOccupancyStartDateOnAccountMemberSince(OccStartDateChangedOppList);
        
        
        if(MostRecentActiveOppChangeList.size() > 0){
            UpdateMostRecentActiveOpponAccount(MostRecentActiveOppChangeList);
        }
        
        if(MostRecentOppChangeList.size() > 0){
            UpdateMostRecentOpponAccount(MostRecentOppChangeList);
        }
        
        if(OppRoomIds.size() > 0){
            UpdateStatusOnRoomBasedOnRelatedOpportunity(OppRoomIds);
        }
        
        
        if(MostRecentOccupancyDateRoomIDs.size() > 0){
            SetOccupancyDateOnRoomFromRecentOpp(MostRecentOccupancyDateRoomIDs);
        }
        
        
    }
    
    public static void SetOccupancyDateOnRoomFromRecentOpp(set<ID> ids) {
        
        list<Room__c> Rooms = [select id,Most_Recent_Opportunity_Occupancy_Date__c,(select id,Occupancy_Status__c,End_Date_of_Occupancy__c from Opportunities__r where (Occupancy_Status__c = 'Active'  or Occupancy_Status__c = 'Current month-to-month') and End_Date_of_Occupancy__c != null order by createdDate Desc limit 1) from Room__c where id in:ids];
        list<Room__c> RoomsUpdatable = new list<Room__c>();
        
        for(Room__c r : rooms){
            if(r.Opportunities__r != null && r.Opportunities__r.size() > 0){
                r.Most_Recent_Opportunity_Occupancy_Date__c = r.Opportunities__r[0].End_Date_of_Occupancy__c;
                RoomsUpdatable.add(r);
            }
            else
            {
                r.Most_Recent_Opportunity_Occupancy_Date__c = null;
                RoomsUpdatable.add(r);
            }
        }
        
        if(RoomsUpdatable.size() > 0){
            update RoomsUpdatable;
        }
        
    }
    
    public static void UpdateMoveInMember(list<Opportunity> opps){
        for(Opportunity o : opps){

            if( o.Record_Type_Name__c.toLowercase().contains('common') ){

                if(o.StageName == 'Member' && o.Start_Date_Of_Occupancy__c >= system.Today()){
                    o.Occupancy_Status__c = 'Moving In';
                }

            }
        }
    }
    
    public static void UpdateStatusOnRoomBasedOnRelatedOpportunity(set<id> Roomids){
        
        list<Room__c> Rooms = [select id,Status__c,(select StageName, Occupancy_Status__c,Vacancy_Date__c, RecordTypeId, Record_Type_Name__c from Opportunities__r) from Room__c where id in:Roomids and status__c != 'Discontinued'];
        for(Room__c r: Rooms){
            Boolean IsOccupied = False;
            Boolean isApplicationPending = false;
            
            for(Opportunity o : r.Opportunities__r){
                
                if( o.Record_Type_Name__c.toLowercase().contains('common') ){

                    Integer dt1 = null;
                    
                    if(o.Vacancy_Date__c != null)
                        dt1 = (system.today()).daysBetween(o.Vacancy_Date__c);
                    
                    if( ( (o.Occupancy_Status__c == 'Active' || o.Occupancy_Status__c == 'Current month-to-month') && (o.Vacancy_Date__c == null || (o.Vacancy_Date__c != null && dt1 >= 60)) )  || (o.StageName == 'Member' && o.Occupancy_Status__c == null) || o.Occupancy_Status__c  == 'Moving In'){
                        IsOccupied = True;
                    }
                    
                    if(o.StageName == 'Lease Application'){
                        isApplicationPending = true;
                    }   

                }
            }
            
            If(IsOccupied){
                // r.Status__c = 'Occupied';    
                r.Status__c = 'Offboarded';
            }
            else if(isApplicationPending){
                // r.Status__c = 'Application Pending';
                r.Status__c = 'Onboarding';
            }
            else{
                // r.Status__c = 'Available';
                r.Status__c = 'Online';
            }
        }
        
        if(Rooms.size() > 0)
            update Rooms;
    }
    
    public static void UpdateSuiteBasedOnRelatedOpportunity(set<id> SuiteIds){
        
        list<Apartment__c> Suites = [SELECT Id, Apartment__c, (SELECT StageName, Couple__c, Has_ESA__c, Occupancy_Status__c, RecordTypeId, RecordType.Name FROM Opportunities__r) from Apartment__c WHERE Id in:SuiteIds];
        List<Apartment__c> SuitesToUpdate = new List<Apartment__c>();
        
        for(Apartment__c s: Suites){
            Boolean IsCoupleSuite = False;
            Boolean HasESA = false;
            
            for(Opportunity o : s.Opportunities__r){

                if( o.RecordType.Name.toLowercase().contains('common') ){
                
                    if(o.Couple__c && (o.Occupancy_Status__c == 'Active' || o.Occupancy_Status__c == 'Current month-to-month' || o.Occupancy_Status__c == 'Moving In')){
                        IsCoupleSuite = true;
                    }
                    
                    if(o.Has_ESA__c && (o.Occupancy_Status__c == 'Active'  || o.Occupancy_Status__c == 'Current month-to-month' || o.Occupancy_Status__c == 'Moving In')){
                        HasESA = true;
                    }

                }
            }
            /*
            If(IsCoupleSuite != s.Apartment__c || HasESA != s.ESA_in_Suite__c){
                Apartment__c suite = new Apartment__c();
                suite.Id = s.Id;
                suite.Apartment__c = IsCoupleSuite;
                suite.ESA_in_Suite__c = HasESA;
                SuitesToUpdate.add(suite);
            }*/
            If(IsCoupleSuite != s.Apartment__c){
                Apartment__c suite = new Apartment__c();
                suite.Id = s.Id;
                suite.Apartment__c = IsCoupleSuite;
                SuitesToUpdate.add(suite);
            }
        }
        
        if(SuitesToUpdate.size() > 0)
            update SuitesToUpdate;
    }
    
    Public static void UpdateMostRecentActiveOpponAccount(list<Opportunity> newOpps){
        set<id> accids = new set<id>();
        for(Opportunity o : newOpps){
            accids.add(o.AccountId);
        }
        
        list<Account> accs = [select id,(select id from Opportunities where Occupancy_Status__c = 'Active' or Occupancy_Status__c = 'Current month-to-month' order by CreatedDate Desc limit 1 ),Most_Recent_Active_Opportunity__c from Account where id in:accids];
        
        for(Account acc: accs){
            if(acc.Opportunities.size() > 0){
                Acc.Most_Recent_Active_Opportunity__c  = acc.Opportunities[0].id;
            }
            else
            {
                Acc.Most_Recent_Active_Opportunity__c  = null;
            }
        }
        
        update accs;
    }
    
    Public static void UpdateMostRecentOpponAccount(list<Opportunity> newOpps){
        
        set<id> accids = new set<id>();
        for(Opportunity o : newOpps){
            accids.add(o.AccountId);
        }
        
        list<Account> accs = [select id, (select id,Occupancy_Status__c, RecordTypeId, RecordType.Name from Opportunities order by CreatedDate ASC), Most_Recent_Opportunity__c from Account where id in:accids];
        
        
        list<Account> UpdateableAccounts = new list<Account>();
        map<id,id> activeoppmap = new map<id,id>();
        map<id,id> MovingInoppmap = new map<id,id>();
        map<id,id> nonmemberoppmap = new map<id,id>();
        
        for(Account acc: accs){
            if(acc.Opportunities.size() > 0){
                for(Opportunity o : acc.Opportunities){

                    if( o.RecordType.Name.toLowercase().contains('common') ){

                        if(o.Occupancy_Status__c == 'Active' || o.Occupancy_Status__c == 'Current month-to-month'){
                            activeoppmap.put(acc.id,o.id);
                        }
                        else if(o.Occupancy_Status__c == 'Moving In'){
                            MovingInoppmap.put(acc.id,o.id);
                        }
                        else{
                            nonmemberoppmap.put(acc.id,o.id);
                        }

                    }
                }
            }
        }
        
        for(Account acc : accs){
            if(activeoppmap.get(acc.id) != null){
                Acc.Most_Recent_Opportunity__c  = activeoppmap.get(acc.id);
                UpdateableAccounts.add(acc);
            }
            else if(MovingInoppmap.get(acc.id) != null){
                Acc.Most_Recent_Opportunity__c  = MovingInoppmap.get(acc.id);
                UpdateableAccounts.add(acc);
            }
            else if(nonmemberoppmap.get(acc.id) != null){
                Acc.Most_Recent_Opportunity__c  = nonmemberoppmap.get(acc.id);
                UpdateableAccounts.add(acc);
            }
            else{
                Acc.Most_Recent_Opportunity__c  = null;
                UpdateableAccounts.add(acc);
            }
        }
        
        
        if(UpdateableAccounts.size() > 0)
            update UpdateableAccounts;
    }
    
    Public static void UpdateCityFromHomeCommitted(list<Opportunity> newOpps){
        
        set<id> HomeIds = new set<id>();
        
        for(Opportunity opp: NewOpps){
            if( opp.Record_Type_Name__c.toLowercase().contains('common') ){
                HomeIds.add(opp.Home_Committed__c);
            }
        }
        
        Map<Id,Id> HomeCityMap = new Map<Id,Id>();
        
        list<Property__c> homes = [select id,City_object__c from Property__c where City_object__c != null and id in:HomeIds];
        for(Property__c h : homes){
            HomeCityMap.put(h.id,h.City_object__c);
        }
        
        for(Opportunity opp: NewOpps){

            if( opp.Record_Type_Name__c.toLowercase().contains('common') ){

                opp.City_Lookup__c = HomeCityMap.get(opp.Home_Committed__c);
            }
        }
        
    }
    
    //added by Einsteam
    public static void PopulateOpportunityName(list<Opportunity> NewOpps){
        
        set<Id> AccountIds = new set<Id>();
        for(Opportunity Opp : NewOpps){

            if( Opp.Record_Type_Name__c.toLowercase().contains('common') ){

                // if(opp.AccountId != null && 
                //     (Schema.getGlobalDescribe()?.get('Opportunity')?.getDescribe()?.getRecordTypeInfosById()?.get(opp.RecordTypeId).getDeveloperName() == 'Renewal' 
                //     || Schema.getGlobalDescribe()?.get('Opportunity')?.getDescribe()?.getRecordTypeInfosById()?.get(opp.RecordTypeId).getDeveloperName() == 'Transfer'
                //     || Schema.getGlobalDescribe()?.get('Opportunity')?.getDescribe()?.getRecordTypeInfosById()?.get(opp.RecordTypeId).getDeveloperName() == 'MTM'
                //     )){
                //     AccountIds.add(opp.AccountId);
                //     }


                if(opp.AccountId != null && 
                    (Schema.getGlobalDescribe()?.get('Opportunity')?.getDescribe()?.getRecordTypeInfosById()?.get(opp.RecordTypeId).getDeveloperName() == 'Common_Renewal' 
                    || Schema.getGlobalDescribe()?.get('Opportunity')?.getDescribe()?.getRecordTypeInfosById()?.get(opp.RecordTypeId).getDeveloperName() == 'Common_Transfer'
                    || Schema.getGlobalDescribe()?.get('Opportunity')?.getDescribe()?.getRecordTypeInfosById()?.get(opp.RecordTypeId).getDeveloperName() == 'Common_MTM'
                    )){
                    AccountIds.add(opp.AccountId);
                }

            }
        }
        system.debug('AccountIds::'+AccountIds);
        if(AccountIds.size() > 0){
            map<Id,Account> Accounts = new map<Id, Account>([Select Id,Name, (Select Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName from Opportunities) from Account Where Id IN :AccountIds]);
            
            for(Opportunity opp : NewOpps){

                if( opp.RecordType.Name.toLowercase().contains('common') ){

                    if(opp.AccountId != null && opp.RecordTypeId != null ){
                        Account acc = Accounts.get(opp.AccountId);
                        if(acc != null){
                            list<Opportunity> ExtOpps = acc.Opportunities;
                            integer SameRecordTypeCount = 1;
                            for(opportunity o : ExtOpps){
                                if(o.RecordTypeId == opp.RecordTypeId){
                                    SameRecordTypeCount++;
                                }
                            }

                            String NamePlaceholder = '';
                            if(Schema.getGlobalDescribe()?.get('Opportunity')?.getDescribe()?.getRecordTypeInfosById()?.get(opp.RecordTypeId).getDeveloperName() == 'Common_Renewal'){
                                NamePlaceholder = ' - Renewal ';
                            }else if(Schema.getGlobalDescribe()?.get('Opportunity')?.getDescribe()?.getRecordTypeInfosById()?.get(opp.RecordTypeId).getDeveloperName() == 'Common_Transfer'){
                                NamePlaceholder = ' - Transfer ';
                            }else if(Schema.getGlobalDescribe()?.get('Opportunity')?.getDescribe()?.getRecordTypeInfosById()?.get(opp.RecordTypeId).getDeveloperName() == 'Common_MTM'){
                                NamePlaceholder = ' - MTM ';
                            }
                            system.debug('Record Type::'+Schema.getGlobalDescribe()?.get('Opportunity')?.getDescribe()?.getRecordTypeInfosById()?.get(opp.RecordTypeId).getDeveloperName());
                            system.debug('NamePlaceholder ::'+NamePlaceholder);
                            opp.Name = acc.Name + NamePlaceholder + SameRecordTypeCount ;
                            system.debug('Check this:::'+opp.Name);
                        }
                    }

                }
            }
        }
    }
    //added by Einsteam
    /*
    public static void PopulateTransferOpportunityName(list<Opportunity> NewOpps){
        
        set<Id> AccountIds = new set<Id>();
        for(Opportunity Opp : NewOpps){
            if(opp.AccountId != null)
                AccountIds.add(opp.AccountId);
        }
        
        map<Id,Account> Accounts = new map<Id, Account>([Select Id,Name, (Select Id from Opportunities where Record_Type_Name__c = 'Transfer') from Account Where Id IN :AccountIds]);
        map<Id, RecordType> recordTypes = new map<Id, recordType>([Select id,Name from RecordType where sObjectType = 'Opportunity']);
        
        for(Opportunity opp : NewOpps){
            if(opp.AccountId != null && recordTypes.get(opp.RecordTypeId) != null && recordTypes.get(opp.RecordTypeId).Name == 'Transfer'){
                Account acc = Accounts.get(opp.AccountId);
                if(acc != null){
                    list<Opportunity> ExtOpps = acc.Opportunities;
                    integer renewalNumber = ExtOpps.size() + 1;
                    opp.Name = acc.Name + ' - Transfer ' +renewalNumber ;
                }
            }
        }
    }
    */
    
    //added by Einsteam
    /* public static void PopulateInitialOpportunityName(list<Opportunity> NewOpps){

set<Id> AccountIds = new set<Id>();
for(Opportunity Opp : NewOpps){
if(opp.AccountId != null)
AccountIds.add(opp.AccountId);
}

map<Id,Account> Accounts = new map<Id, Account>([Select Id,Name, (Select Id from Opportunities where Record_Type_Name__c = 'Initial') from Account Where Id IN :AccountIds]);
map<Id, RecordType> recordTypes = new map<Id, recordType>([Select id,Name from RecordType where sObjectType = 'Opportunity']);

for(Opportunity opp : NewOpps){
if(opp.AccountId != null && recordTypes.get(opp.RecordTypeId) != null && recordTypes.get(opp.RecordTypeId).Name == 'Initial'){
Account acc = Accounts.get(opp.AccountId);
if(acc != null){
list<Opportunity> ExtOpps = acc.Opportunities;
integer renewalNumber = ExtOpps.size() + 1;
opp.Name = acc.Name + ' - Initial ' +renewalNumber ;
}
}
}
}
*/
    
    //added by Einsteam
    public static void UpdateOccupancyStartDateOnAccountMemberSince(List<Opportunity> newOpps){
        
        set<ID> AccountID = new set<ID>();
        
        for(Opportunity opp: newOpps){
            AccountID.add(opp.AccountID);
        }
        
        list<Account> accs = [select Member_Since__c, (select Start_Date_of_Occupancy__c from Opportunities where Start_Date_of_Occupancy__c != null Order by createdDate asc limit 1) from Account where id in:AccountID and Member_Since__c = null];
        system.debug('accs::'+accs);
        list<Account> AccToUpdate = new list<Account>();
        
        for(Account acc: accs){
            if(acc.Opportunities != null && acc.Opportunities.size() > 0 && acc.Member_Since__c == null){
                acc.Member_Since__c = acc.Opportunities[0].Start_Date_of_Occupancy__c;
                AccToUpdate.add(acc);
            }
        }
        
        if(AccToUpdate.size() > 0){
            update AccToUpdate;
        }
        
    }
    
    public static Void RoundRobinHomeAssignment(list<Opportunity> newOpps){
        
        map<Decimal,Home_Committed_Round_Robin__c> RoundRobinMap = new map<Decimal,Home_Committed_Round_Robin__c>();
        map<string,ID> HomeMap = new map<string,ID>();
        map<ID,String> SummitHomeMap = new map<ID,String>();
        set<string> HomeNames = new set<string>();
        
        map<id,string> CityMap = new map<id,string>();
        list<City__c> cities = [select id,Name from City__c where Name = 'Seattle'];
        for(City__c c : cities){
            CityMap.put(c.id,c.Name);
        }
        
        list<Home_Committed_Round_Robin__c> Settings = [select id,Home_Name__c,In_Queue_Not_for_End_User__c,Queue_No__c from Home_Committed_Round_Robin__c];
        for(Home_Committed_Round_Robin__c setting : settings){
            HomeNames.add(setting.Home_Name__c);
        }
        
        list<Property__c> homes = [select id,Name from Property__c where Name in:HomeNames];
        
        for(Property__c h: homes){
            HomeMap.put(h.Name.Trim(),h.id);
        }
        
        list<Property__c> SummitHomes = [select id,Name from Property__c where Name = 'Summit'];
        for(Property__c h: SummitHomes){
            SummitHomeMap.put(h.id,h.Name);
        }
        
        if(Settings.size() > 0){
            
            Decimal CurrentQueueNo = 1;
            Decimal NextQueueNo = 1;
            
            for(Home_Committed_Round_Robin__c Hrr : Settings){
                
                if(hrr.In_Queue_Not_for_End_User__c){
                    CurrentQueueNo = hrr.Queue_No__c;
                    NextQueueNo = hrr.Queue_No__c;
                }
                
                RoundRobinMap.put(hrr.Queue_No__c,Hrr);
            }
            
            Boolean IsAnyRoundRobinProcessed = false;
            
            for(Opportunity opp: newOpps){

                if( opp.Record_Type_Name__c.toLowercase().contains('common') ){
                
                    if(HomeMap.get(RoundRobinMap.get(NextQueueNo).Home_Name__c) != null && (opp.Home_Committed__c == null || (opp.Home_Committed__c != null && SummitHomeMap.get(opp.Home_Committed__c) == 'Summit' ) ) && opp.City_Lookup__c != null && CityMap.get(opp.City_Lookup__c) == 'Seattle'){
                        opp.Home_Committed__c = HomeMap.get(RoundRobinMap.get(NextQueueNo).Home_Name__c.Trim());
                        opp.IsRoundRobinProcessed__c = True;
                        NextQueueNo++;
                        
                        boolean NexQueueFound = false;
                        
                        for(Home_Committed_Round_Robin__c Hrr : Settings){
                            if(hrr.Queue_No__c == NextQueueNo ){
                                NexQueueFound = true;
                            }
                        }
                        
                        if(NexQueueFound == false)
                            NextQueueNo = 1;  
                        
                        IsAnyRoundRobinProcessed = true;
                    }

                }
            }
            
            if(IsAnyRoundRobinProcessed)
            {
                Home_Committed_Round_Robin__c Currentsetting = RoundRobinMap.get(CurrentQueueNo);
                Currentsetting.In_Queue_Not_for_End_User__c = false;
                update Currentsetting;
                
                Home_Committed_Round_Robin__c Nextsetting = RoundRobinMap.get(NextQueueNo);
                Nextsetting.In_Queue_Not_for_End_User__c = True;
                update Nextsetting;
            }
            
        }
        
        
        
    }
    
    //added by Einsteam
    public static void UpdateStagetoParentAccount(List<Opportunity> newOpps){
        
        set<ID> AccountID = new set<ID>();
        for(Opportunity opp: newOpps){
            AccountID.add(opp.AccountID);
        }
        
        list<Account> accs = [select id,Most_Recent_Opportunity_Stage__c, Phone, (select id,StageName,Occupancy_status__c, Phone__c from Opportunities Order by createdDate desc) from Account where id in:AccountID];
        
        for(Account acc: accs){
            
            if(Acc.Opportunities != null && Acc.Opportunities.size() > 0){
                
                boolean IsMember = false;
                String PhoneNumber = '';
                
                for(Opportunity opp : Acc.Opportunities){
                    if(Opp.StageName == 'Member' && (Opp.Occupancy_status__c == 'Active' || opp.Occupancy_Status__c == 'Current month-to-month'))
                        IsMember = true;
                }
                
                
                if(IsMember)
                    acc.Most_Recent_Opportunity_Stage__c = 'Member';
                else
                    acc.Most_Recent_Opportunity_Stage__c = acc.Opportunities[0].StageName;
            }
        }
        
        if(accs.size() > 0){
            update accs;
        }
    }
    
    //added by Einsteam
    public static void UpdateOccupancyStatusOnAccount(List<Opportunity> newOpps){
        
        set<ID> AccountID = new set<ID>();
        for(Opportunity opp: newOpps){
            AccountID.add(opp.AccountID);
        }
        
        
        list<Account> accs = [select id,Occupancy_Status__c,(select id,Occupancy_status__c, RecordTypeId, RecordType.Name from Opportunities) from Account where id in:AccountID];
        
        for(Account acc: accs){
            
            Boolean IsActive = false;
            Boolean Ism2m = false;
            Boolean IsGhosted = false;   
            Boolean IsinActive = false;   
            Boolean IsHoldover = false;
            
            
            if(Acc.Opportunities != null && Acc.Opportunities.size() > 0){
                
                for(Opportunity opp: Acc.Opportunities){
                    

                    if( opp.RecordType.Name.toLowercase().contains('common') ){

                        system.debug('opp.Occupancy_Status__c::'+opp.Occupancy_Status__c+' '+opp.ID);
                        
                        if(opp.Occupancy_Status__c == 'Active')
                            IsActive = True;   
                        
                        if(opp.Occupancy_Status__c == 'Current month-to-month')    
                            Ism2m = true;
                        
                        if(opp.Occupancy_Status__c == 'Ghosted - No Longer Paying')
                            IsGhosted = True;     
                        
                        if(opp.Occupancy_Status__c == 'Inactive')
                            IsinActive = True;     
                        
                        if(opp.Occupancy_Status__c == 'Holdover Tenant')
                            IsHoldover = True;    
                        
                    }
                }
            }
            
            
            if(IsActive){
                acc.Occupancy_Status__c = 'Active';
            }
            else if(Ism2m){
                acc.Occupancy_Status__c = 'Current month-to-month';
            }
            else if(IsGhosted){
                acc.Occupancy_Status__c = 'Ghosted - No Longer Paying';
            }
            else if(IsinActive){
                acc.Occupancy_Status__c = 'Inactive';
            }
            else if(IsHoldover){
                acc.Occupancy_Status__c = 'Holdover Tenant';
            }
            else{
                acc.Occupancy_Status__c = '';
            }
        }
        
        if(accs.size() > 0)
            update accs;
    }
    
    
    
    Public static void OpportunityPhoneValidation(List<Opportunity> newOpps, Map<Id,Opportunity> oldMap){
        
        System.debug('OpportunityPhoneValidation' + newOpps );

        for(Opportunity opp : newOpps){        
        
            if( opp.Record_Type_Name__c.toLowercase().contains('common') ){

                if(opp.Phone__c <> null && (Trigger.isInsert || (Trigger.isUpdate && (opp.Phone__c != oldMap.get(opp.Id).Phone__c ) ) )){
                    String Phonenumber = '';
                    if(opp.Phone__c <> null){
                        Phonenumber = opp.Phone__c;
                    }     
                    System.debug('//'+Phonenumber); 
                    
                    if(Phonenumber != null && Phonenumber != ''){
                        String[] strarr = Phonenumber.split(' ');
                        System.debug('************* strarr '+strarr);
                        if(strarr.size() == 2){
                            if(strarr[0].length() == 5 && strarr[0].startsWith('(') && strarr[0].endsWith(')')){
                                String[] strArr1 = strarr[1].split('-');
                                System.debug('************* strarr1 '+strarr1);
                                if(strArr1.size() == 2){
                                    if(strArr1[0].length()== 3 && strArr1[1].length()== 4){
                                        opp.Phone__c = '+1'+ strarr[0].subString(1,4) + '' + strArr1[0] + '' + strArr1[1];
                                    }
                                }
                            }
                        }
                    }
                    
                    if(!Phonenumber.startsWith('+') && opp.Phone__c != null){
                        Phonenumber = opp.Phone__c.replaceAll('\\D','');
                        System.debug('!!!'+Phonenumber);
                        if(Phonenumber.length() == 10){
                            opp.Phone__c  = '+1' + Phonenumber;
                        }
                        else{
                            if((Phonenumber.length() == 11 && Phonenumber.startsWith('1'))  || (Phonenumber.length() == 12 && (Phonenumber.startsWith('33') || Phonenumber.startsWith('34') || Phonenumber.startsWith('39') || Phonenumber.startsWith('44')))){
                                opp.Phone__c  = '+' + Phonenumber;
                                System.debug('@@@'+Phonenumber);
                            }
                            else{
                                opp.Phone__c  = Phonenumber;
                                System.debug('###'+Phonenumber);
                            }
                        }    
                    }
                    
                    System.debug('#fffff#'+Phonenumber);
                } 
            }      
        }
        
        
    }
    
    //this version is for UPDATE
    public static void updateAccountFirstActiveOpp(List<Opportunity> opps, map<Id, Opportunity> oldOpps){
        Map<Id,Account> mapO_A = new Map<Id,Account>();
        //get the opportunities in a map
        Map<Id,Opportunity> mapOO = new Map<Id,Opportunity>(opps);
        
        //get the accountId
        Set<Id> accountId = new Set<Id>();
        for(Opportunity op : mapOO.values()){

            if( op.Record_Type_Name__c.toLowercase().contains('common') ){
                accountId.add(op.AccountId);
            }
        }
        
        // Get the account you want
        Map<Id,Account> mapAA = new Map<Id,Account>([SELECT Id, First_Active_Opportunity__c FROM Account WHERE Id IN :accountId]);
        
        // Put them together
        for(Id oppId : mapOO.keySet()){
            Id acctId = mapOO.get(oppId).AccountId;
            mapO_A.put(oppId,mapAA.get(acctId));
        }
        
        
        List<Account> accsToUpdate = new List<Account>();
        //loop through each opp, if the Occupancy status is changed to 'Active' get the account object associated with the opp
        for(Opportunity o : opps){

            if( o.Record_Type_Name__c.toLowercase().contains('common') ){

                if (o.Occupancy_status__c != oldOpps.get(o.Id).Occupancy_Status__c && (o.Occupancy_Status__c == 'Active' || o.Occupancy_Status__c == 'Current month-to-month')){
                    Account a = mapO_A.get(o.Id);
                    if(a.First_Active_Opportunity__c == null){
                        a.First_Active_Opportunity__c = o.Id;
                        accsToUpdate.add(a);
                    }
                }
            }
        }
        if(accsToUpdate != null){
            Update accsToUpdate;
        }
    }
    
    //this version is for INSERT
    public static void updateAccountFirstActiveOpp(List<Opportunity> opps){
        Map<Id,Account> mapO_A = new Map<Id,Account>();
        
        //get the opportunities in a map
        Map<Id,Opportunity> mapOO = new Map<Id,Opportunity>(opps);
        
        //get the accountId
        Set<Id> accountId = new Set<Id>();
        for(Opportunity op : mapOO.values()){
            accountId.add(op.AccountId);
        }
        
        // Get the account you want
        Map<Id,Account> mapAA = new Map<Id,Account>([SELECT Id, First_Active_Opportunity__c FROM Account WHERE Id IN :accountId]);
        
        // Put them together
        for(Id oppId : mapOO.keySet()){
            Id acctId = mapOO.get(oppId).AccountId;
            mapO_A.put(oppId,mapAA.get(acctId));
        }
        
        List<Account> accsToUpdate= new List<Account>();
        //loop through each opp, if the Occupancy status is 'Active' get the account object associated with the opp
        for(Opportunity o : opps){
            if (o.Occupancy_Status__c == 'Active' || o.Occupancy_Status__c == 'Current month-to-month'){
                Account a = mapO_A.get(o.Id);
                if(a.First_Active_Opportunity__c == null){
                    a.First_Active_Opportunity__c = o.Id;
                    accsToUpdate.add(a);
                }
            }
        }
        
        if(accsToUpdate != null){
            Update accsToUpdate;
        }
    }
    
    public static void CloseMoveOutTasksHoldover(List<Opportunity> opps){
        //when adding new record Types to here MAKE SURE TO ADD THEM TO THE FUNCTION BELOW AS WELL
        List<String> MoveOutTaskRecordTypeNames = new List<String>();
        MoveOutTaskRecordTypeNames.add('CSS_Edge_Move_Out_Task');
        MoveOutTaskRecordTypeNames.add('CSS_Individual_Move_Out_Task_Template');
        MoveOutTaskRecordTypeNames.add('CSS_Leasing_Specialist_Move_Out_Task');
        MoveOutTaskRecordTypeNames.add('CSS_Property_Services_Move_Out_Task_Template');
        MoveOutTaskRecordTypeNames.add('CSS_Source_Fit_Move_Out_Task_Template');
        MoveOutTaskRecordTypeNames.add('CSS_Systems_Inspection_Task');
        MoveOutTaskRecordTypeNames.add('Move_Out_Inspection_Task');
        
        List<id> oppIds = new List<id>();
        for(Opportunity o: opps){
            oppIds.add(o.id);
        }
        List<id> RenewaloppIds = new List<id>();
        for(Opportunity o: opps){
            RenewaloppIds.add(o.subsequent_opportunity__c);
        }
        //get move out tasks related to the subsequent opps, or the pre move out inspection stuff on the current opp
        List<Task> moveOutTasks = [Select id from Task where (whatid in : oppIds and status != 'Completed' AND recordType.developerName in: MoveOutTaskRecordTypeNames)];
        List<id> taskIds = new List<id>();
        for(task t: moveOutTasks){
            taskIds.add(t.id);
        }
        List<sub_task__c> subTasks = [Select id from sub_task__C where task_id__c in: taskIds];
        for(sub_Task__c sb : subTasks){
            sb.Is_Completed__c = true;
        }
        update subTasks;
        
        List<feedItem> feedItems = new List<feedItem>();
        for(Task T: MoveOutTasks){
            t.Status = 'Completed';
            t.charges_approved__c = true;
            t.Suggested_Damage_Charge__c = 0;
            feedITem f = new FeedItem();
            f.ParentId = t.Id;
            f.Body = 'This task is being auto closed because the related opportunity is a holdover tenant.';
            feedItems.add(f);
        }
        
        update MoveOutTasks;
        insert feedItems;
        
        List<id> roomIDs = new List<Id>();
        for(opportunity o: opps){
            roomIDs.add(o.Room_Selected__c);
        }
        
        List<Room__c> rooms = [Select id from room__c where id in:roomIDs];
        for(room__c r: rooms){
            r.Reason_Room_Cannot_be_Actioned__c = 'Holdover Tenant';
            r.Room_Cannot_be_Actioned__c = true;
        }
        
        update rooms;
    }
    
    
    public static void HoldoverTenantMoveOutDateAdded(List<Opportunity> opps){
        //when adding new record Types to here MAKE SURE TO ADD THEM TO THE FUNCTION ABOVE AS WELL
        List<String> MoveOutTaskRecordTypeNames = new List<String>();
        MoveOutTaskRecordTypeNames.add('CSS_Edge_Move_Out_Task');
        MoveOutTaskRecordTypeNames.add('CSS_Individual_Move_Out_Task_Template');
        MoveOutTaskRecordTypeNames.add('CSS_Leasing_Specialist_Move_Out_Task');
        MoveOutTaskRecordTypeNames.add('CSS_Property_Services_Move_Out_Task_Template');
        MoveOutTaskRecordTypeNames.add('CSS_Source_Fit_Move_Out_Task_Template');
        MoveOutTaskRecordTypeNames.add('CSS_Systems_Inspection_Task');
        MoveOutTaskRecordTypeNames.add('Move_Out_Inspection_Task');
        
        List<id> oppIds = new List<id>();

        Map<id, opportunity> oppMap = new Map<id, Opportunity>();
        for(Opportunity o: opps){
            o.Occupancy_Status__c = 'Inactive';
            oppIds.add(o.id);
            oppMap.put(o.id, o);
        }
        
        List<id> roomIDs = new List<Id>();
        for(opportunity o: opps){
            roomIDs.add(o.Room_Selected__c);
        }
        
        List<Room__c> rooms = [Select id from room__c where id in:roomIDs];
        for(room__c r: rooms){
            r.Reason_Room_Cannot_be_Actioned__c = null;
            r.Room_Cannot_be_Actioned__c = false;
        }
        
        update rooms;
        List<Task> tasks = [SELECT ID, activityDate, ownerId, opportunity__r.previous_opportunity__c, City__c, Home__c, Priority, Room__c, subject, whatId, RecordTypeId, opportunity__c from task where whatid in : OppIds AND recordType.developerName in :MoveOutTaskRecordTypeNames and (not subject like '%Pre-Move-Out%')];
        for(task t: tasks){
            t.id = null;
            t.Status = 'Open';
            t.ActivityDate = oppMap.get(t.opportunity__c).Holdover_Tenant_Move_Out_Date__c + 1;
        }
        insert tasks;
    }
    
    //this method is to delete the orders and order products associated with an opportunity when it is deleted.
    public static void BeforeDelete(List<Opportunity> opps){
        //delete orders and order products associated with this opportunity
        List<String> oppIds = new List<String>();
        for(Opportunity o: opps){
            oppIds.add(o.id);
        }
        List<Order> orders = [SELECT id from order where opportunityid in: oppIds];
        List<String> orderIds = new List<String>();
        for(Order o: orders){
            orderIds.add(o.id);
        }
        List<OrderItem> oi = [select id from orderItem where orderid in: orderIds];
        List<Order> activeOrders = [Select id from Order where id in : OrderIds];
        for(order o: activeOrders){
            o.status = 'Draft';
        }
        if(activeOrders.size() > 0)
            update activeOrders;
        
        if(oi.size() > 0)
            delete oi;
        
        if(orders.size() > 0)
            delete orders;
    }

}