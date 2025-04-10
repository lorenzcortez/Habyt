public class CreateCaseFromInspectionTask {
    public class Input{
        
        @invocableVariable (required=true)
        public id taskId;
        
    }
    @invocableMethod
    public static void createCase(List<Input> inputs){        
        
        List<id> taskIDs = new List<id>();
        //List<task> TaskList =[SELECT id from task where taskIDs];
        //put the task ids in a list
        for(Input i : inputs){
            if(i.taskId != null)
                taskIDs.add(i.taskId);
        }
        
        List<Task> TaskList = [SELECT id, whatid, subject, room__c, Suite__c, Account.personEmail, home__c, Home__r.Maintenance_tech__c, home__r.BrandRef__c, suggested_damage_charge__c, Home__r.Accounts_Receivable_Coordinator__c, description, home__r.Area_Manager__c from task where id in : taskIDs];
        
        List<sub_task__c> subTasks = [Select id, name, task_id__c, Damage_Charge__c, Description__c from sub_Task__c where Task_id__c in: TaskIDs];
        
        //create list of Task ID to Sub Task List
        Map <ID, List<Sub_task__c>> TaskIdToSubTasks = new Map<ID, List<Sub_task__c>>();
        
        for(Task t : TaskList){
            List<sub_task__c> subTaskList = new List<sub_Task__c>();
            TaskIdToSubTasks.put(t.id, subTaskList);
        }
        
        for(sub_task__c sb: subTasks){
            TaskIdToSubTasks.get(sb.Task_ID__c).add(sb);
        }
        
        Map<ID, List<ContentDocumentLink>> Task2CDL = new Map<ID, List<ContentDocumentLink>>();
        List<contentDocumentLink> cdlList = [SELECT Visibility, ShareType, IsDeleted, LinkedEntityId, ContentDocumentId from contentDocumentLink where linkedEntityId in :TaskIDs];
        for(id TaskID : taskIDs){
            Task2CDL.put(taskID, new List<contentDocumentLink>());
        }
        for(contentDocumentLink cdl : cdlList){
            Task2CDL.get(cdl.LinkedEntityId).add(cdl);
        }
        id financeAndInspections = [SELECT ID FROM RECORDType where name = 'Finance & MSS - Inspections'][0].id;
        List<Case> CaseList = new List<Case>();
        List<ContentDocumentLink> InsertCdlList = new List<ContentDocumentLink>();
        Map<Task, Case> t2c = new Map<Task, Case>();
        for(Task t : TaskList){
            Case c = new Case();
            //c.businessHoursID = '01m6A0000000KMOQA2'; 
            c.accountid = t.Accountid;
            c.Accounts_Receivable_Coordinator__c = t.Home__r.Accounts_Receivable_Coordinator__c;
            c.area_Manager__c = t.home__r.Area_Manager__c;
            c.CurrencyIsoCode = 'USD';
            c.home__c = t.home__c;
            c.Maintenance_Tech__c = t.Home__r.Maintenance_tech__c;
            c.Opportunity__c = t.Whatid;
            //this is where the case gets assigned to an omni channel queue, change this
            if(t.subject.contains('Post')){
                c.OwnerId = t.Home__r.Accounts_Receivable_Coordinator__c;
                c.Subject = 'Post-Move-Out Inspection Case';
            }
            if(t.subject.contains('Pre')){
                c.OwnerId = '00G3u000000Low4EAC';
                c.Subject = 'Pre-Move-Out Inspection Case';
            }
            c.RecordTypeId = financeAndInspections;
            c.Room__c = t.Room__c;
            c.Suite__c = t.Suite__c;
            c.SuppliedEmail = t.Account.personEmail;
            c.Origin = 'Internal';
            //loop through sub tasks and add damage charges
            c.Description_of_Damages__c = '';
            Decimal totalCharges = 0;
            for(sub_Task__c sb: TaskIdToSubTasks.get(T.Id)){
                if(sb.Damage_Charge__c > 0){
                    totalCharges += sb.Damage_Charge__c;
                    c.Description_of_Damages__c += (sb.name + ': $' + sb.Damage_Charge__c + ' \n');
                }
            }
            c.Inspection_Damage_Charges__c = totalCharges;
            t.Suggested_Damage_Charge__c = totalCharges;
            t.Description = c.description_of_damages__c;
            CaseList.add(c);
            System.debug('The id for the case is: ' + c.id);
            t2c.put(t, c);
        }
        insert CaseList;
        
        for(Task t : TaskList){
            case c = t2c.get(t);
            System.debug('The id for the case is: ' + c.id);
            List<contentDocumentLink> cdlListTemp = Task2CDL.get(t.id);
            for(contentDocumentLink cdlTemp : cdlListTemp){
                contentDocumentLink cdlTemp2 = new contentDocumentLink();
                cdlTemp2.LinkedEntityId = c.Id;
                cdlTemp2.ShareType = cdlTemp.shareType;
                cdlTemp2.Visibility = cdlTemp.Visibility;
                cdlTemp2.ContentDocumentId = cdlTemp.ContentDocumentId;
                InsertCdlList.add(cdlTemp2);
            }
        }
        
        
        if(InsertCdlList.size() > 0)
            insert InsertCdlList;
        if(TaskList.size()>0)
            update taskList;
    }
}