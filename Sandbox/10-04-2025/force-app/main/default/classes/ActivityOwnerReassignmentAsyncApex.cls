Public class ActivityOwnerReassignmentAsyncApex{

    @future
    public static void AssignOwner(list<id> taskids){
        list<task> tasks = [select id,Assigned_Task_Owner__c from task where id in:taskids ];
        set<string> useremails = new set<string> ();
        
        for(task t : tasks){
            if(t.Assigned_Task_Owner__c != null){
                useremails.add(t.Assigned_Task_Owner__c);
            }
        }
        
        map<string,id> activeusermap = new map<string,id>();
        
        list<user> activeusers = [select id, email from user where email in:useremails and isactive = true and (profile.UserLicense.Name = 'Salesforce' OR profile.UserLicense.Name = 'Salesforce Platform')];
        for(user u : activeusers){
            activeusermap.put(u.email, u.id);
        }
        
        list<task> updateabletasks = new list<task>();
        for(task t : tasks){
            if(t.Assigned_Task_Owner__c != null){
                if(activeusermap.get(t.Assigned_Task_Owner__c) != null){
                    t.ownerid = activeusermap.get(t.Assigned_Task_Owner__c);
                    updateabletasks.add(t);
                }
                
                t.Assigned_Task_Owner__c = null;
            }
        }
        
        if(updateabletasks.size() > 0){
            update updateabletasks;
        }
        
    }
    
}