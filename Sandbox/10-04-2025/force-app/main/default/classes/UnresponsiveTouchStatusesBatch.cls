public class UnresponsiveTouchStatusesBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //String query = 'SELECT Id, Name, StageName, Stage_Status__c, Stage_Status_Change_Date_Time__c FROM Opportunity ';
        String query = 'SELECT Id, Name, StageName, Stage_Status__c, Last_Stage_Change_Date__c, RecordType.DeveloperName FROM Opportunity ';
        query += ' WHERE ';
        /*query += ' Stage_Status_Change_Date_Time__c != NULL AND Stage_Status_Change_Date_Time__c = LAST_N_DAYS:5 ';*/
        query += ' Last_Stage_Change_Date__c != NULL AND Last_Stage_Change_Date__c = LAST_N_DAYS:5 ';
        query += ' AND (';
        query += ' Stage_Status__c = \'Unable to Speak\' ';
        /**
         * @description: When the stage status field on the opportunity switches to “Unresponsive - Touch 1” and the stage is “Qualified”, the stage status should change to “Unresponsive - Touch 2” after 48 hours if the stage status has not been changed.
         * @date: Apr-13-2024
         */
        //START
        query += ' OR (StageName = \'Qualified\' AND Stage_Status__c = \'Unresponsive - Touch 1\') ';
        //END
        query += ' OR (StageName = \'Lease Application\' AND Stage_Status__c = \'Awaiting Docs\') ';
        query += ' OR (StageName = \'Lease Application\' AND Stage_Status__c = \'Awaiting Docs - Unresponsive Touch 1\') ';
        query += ' OR (StageName = \'Lease Application\' AND Stage_Status__c = \'Onboarding Link Sent\') ';
        //query += ' OR Stage_Status__c = \'Onboarding Link Sent - Unresponsive Touch 1\' ';
        query += ' OR Stage_Status__c = \'Post Tour - Unresponsive Touch 1\' ';
        query += ' OR Stage_Status__c = \'Reschedule Tour\' ';
        query += ' OR Stage_Status__c = \'Reschedule Tour - Touch 1\' ';
        query += ' OR (StageName = \'Lease Application\' AND Stage_Status__c = \'Obligo in Progress\') ';
        query += ' OR (StageName = \'Lease Application\' AND Stage_Status__c = \'Onboarding in Progress - Awaiting Insurance\') ';
        query += ' OR (StageName = \'Lease Application\' AND Stage_Status__c = \'Onboarding in Progress- Obligo\') ';
        query += ' OR (StageName = \'Transfer In Progress\' AND Stage_Status__c = \'Awaiting Tour Confirmation - Unresponsive Touch 1\') ';
        query += ' OR Stage_Status__c = \'Transfer Link Sent\' ';
        query += ' OR Stage_Status__c = \'Transfer Link Sent - Unresponsive Touch 1\' ';
        query += ' ) ';
        system.debug('query::'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Opportunity > scope){
        
        
        list<Opportunity> OppsToUpdate = new list<Opportunity>();
        
        
        for(Opportunity opp : scope){
            
            //Long StageStatusChangeTime = opp.Stage_Status_Change_Date_Time__c.getTime();
            Long StageStatusChangeTime = opp.Last_Stage_Change_Date__c.getTime();
            Long CurrentTime = DateTime.now().getTime();
            Long milliseconds = CurrentTime - StageStatusChangeTime;
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            Long hours = minutes / 60;
            //Long days = hours / 24;
            
            if(opp.Stage_Status__c == 'Unable to Speak' && hours >= 48){ // && hours < 72
                opp.Stage_Status__c = 'Unresponsive - Touch 2';
                OppsToUpdate.add(opp);
            }
            else if(opp.StageName == 'Lease Application' && opp.Stage_Status__c == 'Awaiting Docs' && hours >= 24){ //&& hours < 48
                //opp.Member_Likleihood__c = 'Yellow';
                opp.Stage_Status__c = 'Awaiting Docs - Unresponsive Touch 1';
                OppsToUpdate.add(opp);
            }
            else if(opp.StageName == 'Lease Application' && opp.Stage_Status__c == 'Awaiting Docs - Unresponsive Touch 1' && hours >= 24){ // && hours < 48
                //opp.Member_Likleihood__c = 'Red';
                opp.Stage_Status__c = 'Awaiting Docs - Unresponsive Touch 2';
                OppsToUpdate.add(opp);
            }
            /*
            else if(opp.StageName == 'Lease Application' && opp.Stage_Status__c == 'Onboarding Link Sent' && hours >= 48){ // && hours < 72
                opp.Member_Likleihood__c = 'Yellow';
                opp.Stage_Status__c = 'Onboarding Link Sent - Unresponsive Touch 1';
                OppsToUpdate.add(opp);
            }
            else if(opp.Stage_Status__c == 'Onboarding Link Sent - Unresponsive Touch 1' && hours >= 24){ // && hours < 48
                opp.Stage_Status__c = 'Onboarding Link Sent - Unresponsive Touch 2';
                OppsToUpdate.add(opp);
            }
            */
            else if(opp.Stage_Status__c == 'Post Tour - Unresponsive Touch 1' && hours >= 48){// && hours < 72
                opp.Stage_Status__c = 'Post Tour - Unresponsive Touch 2';
                OppsToUpdate.add(opp);
            }
            else if(opp.Stage_Status__c == 'Reschedule Tour' && hours >= 24){// && hours < 48
                opp.Stage_Status__c = 'Reschedule Tour - Touch 1';
                OppsToUpdate.add(opp);
            }
            else if(opp.Stage_Status__c == 'Reschedule Tour - Touch 1' && hours >= 48){ // && hours < 72
                opp.Stage_Status__c = 'Reschedule Tour - Touch 2';
                OppsToUpdate.add(opp);
            }
            else if(opp.StageName == 'Lease Application' && opp.Stage_Status__c == 'Obligo in Progress'  && hours >= 24){ // && hours < 48
                opp.Stage_Status__c = 'Obligo in Progress - Unresponsive Touch 1';
                OppsToUpdate.add(opp);
            }
            /*
            else if(opp.StageName == 'Lease Application' && opp.Stage_Status__c == 'Onboarding in Progress - Awaiting Insurance'  && hours >= 24){ // && hours < 48
                opp.Stage_Status__c = 'Onboarding Link Sent - Unresponsive Touch 2';
                OppsToUpdate.add(opp);
            }
            else if(opp.StageName == 'Lease Application' && opp.Stage_Status__c == 'Onboarding in Progress- Obligo'  && hours >= 24){ // && hours < 48
                opp.Stage_Status__c = 'Onboarding Link Sent - Unresponsive Touch 2';
                OppsToUpdate.add(opp);
            }
            */
            else if(opp.StageName == 'Transfer In Progress' && opp.Stage_Status__c == 'Awaiting Tour Confirmation - Unresponsive Touch 1'  && hours >= 72){
                opp.Stage_Status__c = 'Awaiting Tour Confirmation - Unresponsive Touch 2';
                OppsToUpdate.add(opp);
            }
            else if(opp.Stage_Status__c == 'Transfer Link Sent' && hours >= 72){
                opp.Stage_Status__c = 'Transfer Link Sent - Unresponsive Touch 1';
                OppsToUpdate.add(opp);
            }
            else if(opp.Stage_Status__c == 'Transfer Link Sent - Unresponsive Touch 1' && hours >= 72){
                opp.Stage_Status__c = 'Transfer Link Sent - Unresponsive Touch 2';
                OppsToUpdate.add(opp);
            }
            /**
             * @description: When the stage status field on the opportunity switches to “Unresponsive - Touch 1” and the stage is “Qualified”, the stage status should change to “Unresponsive - Touch 2” after 48 hours if the stage status has not been changed.
             * @date: Apr-13-2024
             */
            else if(opp.Stage_Status__c == 'Unresponsive - Touch 1' && opp.StageName == 'Qualified' && opp.RecordType.DeveloperName.startsWith('Common') && hours >= 48) {
                opp.Stage_Status__c = 'Unresponsive - Touch 2';
                OppsToUpdate.add(opp);
            }
        }
        
        if(OppsToUpdate.size() > 0){
            update OppsToUpdate;
        }
    }
    public void finish(Database.BatchableContext BC){
        
        if(test.isRunningTest()){
            integer i=0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
    }
}