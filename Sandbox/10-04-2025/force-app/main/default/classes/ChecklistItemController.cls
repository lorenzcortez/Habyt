public without sharing class ChecklistItemController {
 
    @AuraEnabled
    public static list < Sub_Task__c > fetchItems(string TaskID) {
        Return [SELECT Name, damage_charge__c, Is_Completed__c, Task_ID__c, Description__c, Due_Date__c, OwnerId, Owner.Name, Key_System__c, Key_System__r.Name, Is_Photo_Required__c From Sub_Task__c Where Task_ID__c =:TaskID ];
    }
    
    @AuraEnabled
    public static Task fetchTaskInfo(string TaskID) {
        Return [SELECT id, recordType.name, recordType.developerName, subject from task where id = : TaskId ];
    }
    
    @AuraEnabled
    public static sub_Task__c fetchSubTaskInfo(string subTaskID) {
        Return [SELECT id, name, damage_charge__c, description__c, Is_Photo_Required__c from sub_task__c where id = : subTaskId][0];
    }
    
    /*
    @AuraEnabled
    public static String fetchRecordTypeinfo(string TaskID) {
        list<Task> tasks =  [SELECT Id, Recordtype.DeveloperName, RecordTypeId FROM Task WHERE Id =:TaskID limit 1];
        if(tasks.size() > 0 && tasks[0].RecordTypeId != null){
            return tasks[0].RecordType.DeveloperName;
        }else{
            return '';
        }
    }
    */
    
    @AuraEnabled
    public static String SaveCompletedChecklist(String lstRecordId, String TaskID, Decimal damages, String damageDescription, boolean isCompleted) {
        system.debug('TaskID::'+TaskID);
        system.debug('lstRecordId::'+lstRecordId);
        System.debug('iscompleted: ' + isCompleted);
        System.debug('damages: ' + damages + ' Description: ' + damageDescription);
        try{
            Sub_Task__c CheckList = [SELECT Name, Is_Completed__c, Task_ID__c, Description__c, Due_Date__c, OwnerId, Owner.Name, Is_Photo_Required__c From Sub_Task__c Where ID =:lstRecordId];
            CheckList.Is_Completed__c = isCompleted;
            checkList.Damage_Charge__c = damages;
            checkList.Description__c = damageDescription;
            System.debug(damageDescription + ' ' + damages);

            update CheckList;    
            RecaculateParentTaskStatus(TaskID);
            return 'Sucessfully Updated Checklist';
        }catch(Exception e){
            system.debug('Exception::'+e.getMessage());
            system.debug('Cause::'+e.getCause());
            system.debug('Line Number::'+e.getLineNumber());
            system.debug('Type::'+e.getTypeName());
            throw new AuraHandledException('Error:'+e.getMessage());
        }

    }
    
    @AuraEnabled
    public static String SaveOpenChecklist(String lstRecordId, String TaskID) {
        system.debug('TaskID::'+TaskID);
        system.debug('lstRecordId::'+lstRecordId);
        try{
            Sub_Task__c CheckList = [SELECT Name, Is_Completed__c, Task_ID__c, Is_Photo_Required__c From Sub_Task__c Where ID =:lstRecordId];
            CheckList.Is_Completed__c = False;
            Update CheckList;    
            RecaculateParentTaskStatus(TaskID);
            return 'Sucessfully Updated Checklist';
        }catch(Exception e){
            system.debug('Exception::'+e.getMessage());
            system.debug('Cause::'+e.getCause());
            system.debug('Line Number::'+e.getLineNumber());
            system.debug('Type::'+e.getTypeName());
            throw new AuraHandledException('Error:'+e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String CloneFiletoParentTask(list<string> FileIds, String TaskID) {
       system.debug('TaskID::'+TaskID);
       system.debug('FileID::'+FileIds);
       
       list<ContentDocumentLink> files = [select id,LinkedEntityId,ContentDocumentId,ShareType,Visibility from ContentDocumentLink where ContentDocumentId in:FileIds];
       for(ContentDocumentLink f : files){
           if(!string.ValueOF(f.LinkedEntityId).StartsWith('005')){
               ContentDocumentLink nf = new ContentDocumentLink();
               nf.LinkedEntityId = TaskID;
               nf.ContentDocumentId = f.ContentDocumentId;
               nf.ShareType = f.ShareType;
               nf.Visibility  = f.Visibility;
               insert nf;
           }
       }
       
       return 'File uploaded succesfully';    
    }
    
    @AuraEnabled
    public static List<ContentDocument> getContentDocs(Id arecordId)
    {   
        List<ContentDocumentLink> CDLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :arecordId];
        if (CDLs.size() < 1) return new List<ContentDocument>(); 
    
        // Make a List of ContentDocument IDs
        List <Id> CDIdList = new List <Id> ();
        for (ContentDocumentLink nextCDL : CDLs) {
            CDIdList.add(nextCDL.ContentDocumentId); }        
    
        List<ContentDocument> entries = [SELECT Id, Title, FileType FROM ContentDocument WHERE ContentDocument.Id IN :CDIdList];
        return entries;
    }
    
    public static void RecaculateParentTaskStatus(String TaskID){
        
        //doesnt apply to move out inspection tasks
        Task ParentTask = [SELECT ID, recordType.developerName,Work_Order__c,Work_Order__r.Status FROM task where id =:TASKID];
        list<Sub_Task__c> subTaskList = [SELECT Name, Is_Completed__c, Task_ID__c, Is_Photo_Required__c From Sub_Task__c Where Task_ID__c =:TaskID];
        Boolean IsCompleted = True;
        if(ParentTask.recordtype.developerName != 'Move_Out_Inspection_Task'){
            for(Sub_Task__c s : subTaskList){
                if(s.Is_Completed__c == FALSE){
                    IsCompleted = FALSE;
                }
            }
        }
        else{
           IsCompleted = false;
        }
        
        
        
        Task t = new Task();
        t.id = TaskID;
        
        if(IsCompleted){
            t.Status = 'Completed';
            
            if(parentTask.Work_Order__c != null){
               if(parentTask.Work_Order__r.Status != 'Completed' && parentTask.Work_Order__r.Status != 'Cancelled') {
                   WorkOrder wo = new WorkOrder();
                   wo.Status = 'Completed';
                   wo.id = parentTask.Work_Order__c;
                   update wo;
               }
            }
        }
        else
        {
            t.Status = 'Open';
        }
            
        update t;
      
    }
 
}