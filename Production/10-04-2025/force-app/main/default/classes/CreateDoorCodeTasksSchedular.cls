global class CreateDoorCodeTasksSchedular implements Schedulable {
   global void execute(SchedulableContext sc) {
      CreateDoorCodeTasks  b = new CreateDoorCodeTasks(); 
      database.executebatch(b, 10);
   }
   
   /*
    CreateDoorCodeTasksSchedular cls = new CreateDoorCodeTasksSchedular();
    String sch = '0 0 8 1 JAN,APR,JUL,OCT ? *'; //At 08:00 AM, on day 1 of the month, only in January, April, July, and October
    String jobID = System.schedule('Changing front door code recurring tasks', sch, cls);
    system.debug('Job Id:: '+JobID);
    */
    
}