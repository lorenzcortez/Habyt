@isTest
public class CreateTenantOnboardingFlowContTest {
    @TestSetup
    static void makeData(){
        Property__c prop = TestRecord_Factory.iProperty;
        prop.Stage__c = CustomerContractService.PROPERTTY_STAGE_LAUNCHED;
        update prop;
        
        Account account = TestRecord_Factory.iPersonAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc =  TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        contract.Property__c = prop.Id;
        insert contract;
    }
    
    @isTest
    static void getOnboardingStepsRecord(){
        List<Contract> contracts = [SELECT Id FROM Contract];

        CreateTenantOnboardingFlowCont.TenantOnboardingWrapper responseBody = new CreateTenantOnboardingFlowCont.TenantOnboardingWrapper();
        responseBody.statusCode = 200;
        responseBody.message = '';

        CreateTenantOnboardingFlowCont.DataWrapper data = new CreateTenantOnboardingFlowCont.DataWrapper();
        data.steps = new List<String>{'test'};
        data.stepsIncluded = new List<Boolean>{true};
        responseBody.data = data;

        TestHttpCalloutMock.setTestMockResponse(200, 'Success', JSON.serialize(responseBody));

        Test.startTest(); 
        CreateTenantOnboardingFlowCont.getOnboardingStepsRecord(contracts[0].Id);
        Test.stopTest();
    }

    @isTest
    static void createTenantOnboardingRecords(){
        List<Contract> contracts = [SELECT Id, Opportunity__c FROM Contract];
        CreateTenantOnboardingFlowCont.Response response = new CreateTenantOnboardingFlowCont.Response();
        response.contractId = contracts[0].Id;
        response.contractNumber = '2222';
        response.memberContractId = contracts[0].Id;
        response.memberContractNumber = '3333';
        response.oppId = contracts[0].Opportunity__c;
        CreateTenantOnboardingFlowCont.StepsWrapper step = new CreateTenantOnboardingFlowCont.StepsWrapper();
        step.row = 1;
        step.fieldName = 'Field';
        step.apiName = 'Test';
        step.value = true;
        response.stepsData = new List<CreateTenantOnboardingFlowCont.StepsWrapper>{step};
        TestHttpCalloutMock.setTestMockResponse(200, 'Success', '{}');
        Test.startTest(); 
        CreateTenantOnboardingFlowCont.createTenantOnboardingRecords(JSON.serialize(response));
        Test.stopTest();
    }

    @isTest
    static void getPicklistValues(){
        Test.startTest();
        CreateTenantOnboardingFlowCont.getPicklistValues('Opportunity', 'StageName');
        Test.stopTest();
    }
}