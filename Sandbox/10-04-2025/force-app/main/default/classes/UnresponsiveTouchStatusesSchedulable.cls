public class UnresponsiveTouchStatusesSchedulable implements Schedulable {
    public void execute(SchedulableContext ctx) {
        
        UnresponsiveTouchStatusesBatch b = new UnresponsiveTouchStatusesBatch ();
        database.executeBatch(b, 1);
    }
}