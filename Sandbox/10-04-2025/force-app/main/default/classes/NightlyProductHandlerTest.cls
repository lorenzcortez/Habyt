@isTest
public class NightlyProductHandlerTest {
    @isTest(SeeAllData = true)
    public Static Void TestMethod1(){
        Test.startTest();
        NightlyProductHandler nph = new NightlyProductHandler();
        nph.execute(null);
        Test.stopTest();
    }
    
    @isTest(SeeAllData = true)
    public Static Void TestMethodFail(){
         RecordType personAccountRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true LIMIT 1];
        Account Testaccount = new Account(
            RecordTypeId = personAccountRecType.Id,
            LastName = 'THIS IS A TEST TO MAKE THE JOB FAIL',
            PersonEmail = 'test@test.com'
        );
        insert Testaccount;
        Test.startTest();
        NightlyProductHandler nph = new NightlyProductHandler();
        nph.execute(null);
        Test.stopTest();
    }
    
    
    @isTest(SeeAllData = true)
    public Static Void TestMethodFail2(){
        RecordType personAccountRecType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true LIMIT 1];
        job_last_run__c jbr = new Job_last_run__c();
        jbr.Name = 'NightlyProductHandler';
        insert jbr;
        Account Testaccount = new Account(
            RecordTypeId = personAccountRecType.Id,
            LastName = 'THIS IS A TEST TO MAKE THE JOB FAIL',
            PersonEmail = 'test@test.com'
        );
        insert Testaccount;
        Test.startTest();
        NightlyProductHandler nph = new NightlyProductHandler();
        nph.execute(null);
        Test.stopTest();
    }
    
}