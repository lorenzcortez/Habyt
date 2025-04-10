@IsTest
public class Queable_ApexRetryDML_Test {

     public static testmethod void TestQueable(){
         Account a = new Account();
         a.Name = 'test';
         
         list<Sobject> failedSObjects = new list<SObject>();
         failedSObjects.add(a);
         
         Queable_ApexRetryDML updateJob = new Queable_ApexRetryDML(failedSObjects);
         System.enqueueJob(updateJob);
     }

     
}