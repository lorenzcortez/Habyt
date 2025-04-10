@isTest
public with sharing class UpdateMITPriortyBatchTest {
    @TestSetup
    static void makeData(){
        Account account             = TestRecord_Factory.iPersonAccount;
        Room__c room                = TestRecord_Factory.iRoom;
        Opportunity opp             = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc = TestRecord_Factory.iStripe_Account;

        Contract contract   = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        contract.StartDate  = Date.today().addDays(-10);
        insert contract;

        Move_In_Tracker__c mit = new Move_In_Tracker__c(
            Contract__c = contract.Id
        );
        insert mit;
        
        Task testTask = new Task(
            Subject = 'Follow up call',
            WhatId  = account.Id,
            OwnerId = UserInfo.getUserId(),
            Status  = 'Not Started',
            Priority = 'Normal',
            ActivityDate = Date.today().addDays(7),
            Move_In_Tracker__c = mit.Id
        );
        insert testTask;
       
    }

    @isTest
    static void scenario(){
        UpdateMITPriortyBatch schedulableJob  = new UpdateMITPriortyBatch();
        String cronExp = '0 0 23 * * ?';
        Test.startTest();
        System.schedule('Test Schedulable Job', cronExp, schedulableJob);
        Test.stopTest();
    }
}