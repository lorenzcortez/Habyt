@isTest
private class Scheduled_DeleteSendGridTrackerLogsTest {
    
    
    public static testmethod void UnitTest1() {
        
        test.StartTest();
            
            // batch_HardDeleteSendGridTrackerLogs bat = new batch_HardDeleteSendGridTrackerLogs();
            // database.executebatch(bat,200);
            Scheduled_DeleteSendGridTrackerLogs   b = new Scheduled_DeleteSendGridTrackerLogs();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test Set Batch', sch, b);
        test.StopTest();
        
        
    }

    
    
}