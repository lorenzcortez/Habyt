global class NightlyOrderHandler implements Schedulable {
	global void execute(SchedulableContext ctx) {
        try{
        List<Account> acc = [SELECT ID, lastName from account where lastname = 'THIS IS A TEST TO MAKE THE JOB FAIL'];
        //System.debug('THE NAME IS ' + a[0].LastName);
        if(acc.size() > 0){
            acc[0].addError('Test Error');
            insert acc;
            }
        //get draft orders that are not of type real estate
        List<order> orders = [select id, opportunity.Name, endDate, status, effectiveDate, recordtype.Name from order where status != 'Cancelled' and status != 'Activated' and recordType.Name != 'Real Estate' and effectiveDate <= Today and endDate != null and product__C != null];
        for(order o : orders){
            o.status = 'Activated';
        }
        update orders;
            
        list<Job_Last_Run__c> jbrList = [SELECT id, name from Job_last_run__c where name = 'NightlyOrderHandler'];
         Job_last_run__c jbr = new Job_last_run__c();
         if(jbrList.size() == 0){
            jbr.Name = 'NightlyOrderHandler';
            jbr.Last_Run_DateTime__c = System.now();
            insert jbr;
        }
        else{
            jbr = jbrList[0];
            jbr.Last_Run_DateTime__c = System.now();
            update jbr;
        }
            
      }
	catch (Exception e) { 
		list<Job_Last_Run__c> jbrList = [SELECT id, name from Job_last_run__c where name = 'NightlyOrderHandler'];
        Job_last_run__c jbr = new Job_last_run__c();
        if(jbrList.size() == 0){
            jbr.Name = 'NightlyOrderHandler';
            jbr.Last_Failed_DateTime__c = System.now();
            jbr.fail_reason__c = 'Line Number: ' + e.getLineNumber() + '\n' +
                    'cause: ' + e.getCause() + '\n' + 
                    'StackTrace: ' + e.getStackTraceString() + '\n' + 
                    'message: ' + e.getMessage();
            insert jbr;
        }
        else{
            jbr = jbrList[0];
            jbr.Last_Failed_DateTime__c = System.now();
            jbr.fail_reason__c = 'Line Number: ' + e.getLineNumber() + '\n' + 'cause: ' + e.getCause() + '\n' + 'StackTrace: ' + e.getStackTraceString() + '\n' + 'message: ' + e.getMessage();
            update jbr;
        }
    }
	}
}