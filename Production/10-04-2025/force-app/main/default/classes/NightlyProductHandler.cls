global class NightlyProductHandler implements Schedulable {
    global void execute(SchedulableContext ctx) {
        try{
            List<Account> a = [SELECT ID, lastName from account where lastname = 'THIS IS A TEST TO MAKE THE JOB FAIL'];
            if(a.size() > 0){
                a[0].addError('Test Error');
                insert a;
            }
            
            //get orders that are not real Estate and today is between the start and end date
            // and make sure they're not cancelled
            List<Order> activeOrders = [SELECT id, effectiveDate, endDate, product__c from order where effectiveDate <= Today and endDate >= Today and status != 'Cancelled' and recordType.Name != 'Real Estate'];
            //create a list of ids of the products from the above orders
            List<id> occupiedProductIds = new List<id>();
            for (Order o : activeOrders){
                occupiedProductIds.add(o.Product__c);
            }
            //get the products from that list (these are all the occupied products)
            List<Product2> occupiedProducts =[select id, status__C from product2 where id in : occupiedProductIds];
            //loop through and set status to occupied
            for(product2 p : occupiedProducts){
                p.Status__c = 'Occupied';
            }
            update occupiedProducts;
            //get the products that are of family evault, bike, parking, or storage whose IDs were NOT in the occupied product list
            List<Product2> availableProducts = [select id, status__C from product2 where id not in : occupiedProductIds and family in ('eVault', 'Parking Spot', 'Storage', 'Bicycle Spot')];
            for(product2 p : availableProducts){
                p.Status__c = 'Available';
            }
            update availableProducts;
            list<Job_Last_Run__c> jbrList = [SELECT id, name from Job_last_run__c where name = 'NightlyProductHandler'];
            Job_last_run__c jbr = new Job_last_run__c();
            if(jbrList.size() == 0){
                jbr.Name = 'NightlyProductHandler';
                jbr.Last_Run_DateTime__c = System.now();
                insert jbr;
            }
            else{
                jbr = jbrList[0];
                jbr.Last_Run_DateTime__c = System.now();
                update jbr;
            }
            system.debug('2');
        }
        catch (Exception e) { 
            list<Job_Last_Run__c> jbrList = [SELECT id, name from Job_last_run__c where name = 'NightlyProductHandler'];
            Job_last_run__c jbr = new Job_last_run__c();
            if(jbrList.size() == 0){
                jbr.Name = 'NightlyProductHandler';
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
                jbr.fail_reason__c = 'Line Number: ' + e.getLineNumber() + '\n' +
                    'cause: ' + e.getCause() + '\n' + 
                    'StackTrace: ' + e.getStackTraceString() + '\n' + 
                    'message: ' + e.getMessage();
                update jbr;
            }
        }
    }
}