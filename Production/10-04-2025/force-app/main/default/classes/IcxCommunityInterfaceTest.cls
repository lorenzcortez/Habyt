@isTest
 class IcxCommunityInterfaceTest {
    @TestSetup
    static void makeData(){
        TestUtils.getTestData();
    }
    
    @isTest
    static void testretrievedContract(){   
        List<Contract> contracts = [SELECT Id FROM Contract];
        System.debug('contracts contracts contracts' + contracts);
        try {
            IcxCommunityInterface.retrievedContract('blabla', contracts[0].Id);
        } catch(exception e) {
            system.debug(e.getMessage());
        }
    }

    @isTest
    static void testretrievedContract2(){   
        List<Contract> contracts = [SELECT Id FROM Contract];
        contracts[0].StartDate = null;
        update contracts[0];
        
        System.debug('contracts contracts contracts' + contracts);
        try {
            IcxCommunityInterface.retrievedContract('blabla', contracts[0].Id);
        } catch(exception e) {
            system.debug(e.getMessage());
        }
    }

    @isTest
    static void voidtestGetEversignDocument(){  
        
        List<Contract> contracts = [SELECT Id FROM Contract];
        System.debug('contracts contracts contracts' + contracts);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IcxMockHttpResponse());
        IcxCommunityInterface.getEversignDocument('test');    
        IcxCommunityInterface.updateContract(JSON.serialize(contracts[0]));
        Test.stopTest();
    }
}