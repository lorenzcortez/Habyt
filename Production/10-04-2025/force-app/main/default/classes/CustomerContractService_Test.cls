@IsTest
public class CustomerContractService_Test {
    //public static Room__c newRoom = TestRecord_Factory.iRoom;
    //public static String propertyID = newRoom.Property__c;
    //public static String apartmentID = newRoom.ApartmentRef__c;
    @TestSetup
    static void setupTest() {
        List<Account> accounts = new List<Account>();
        Account account1 = TestRecord_Factory.createPersonAccount();
        account1.FirstName = 'FirstTest';
        account1.LastName = 'FirstLastName';
        account1.PersonEmail = 'test1@test.com';
        accounts.add(account1);

        Account account2 = TestRecord_Factory.createPersonAccount();
        account2.FirstName = 'SecondTest';
        account2.LastName = 'SecondLastName';
        account2.PersonEmail = 'test2@test.com';
        accounts.add(account2);

        Account account3 = TestRecord_Factory.createPersonAccount();
        account2.FirstName = 'ThirdTest';
        account2.LastName = 'ThirdLastName';
        account3.PersonEmail = 'test3@test.com';
        accounts.add(account3);
        insert accounts;

        Billing_Entity__c holding = TestRecord_Factory.createBilling_Entity();
        holding.TypePick__c = CustomerContractService.BILLING_ENTITY_TYPE_HOLDING;
        insert holding;
        
        City__c c = new City__c();
        c.Name = 'Singapore';
        insert c;
        
        Brand__c br = new Brand__c(
            Name = 'Test Brand',
            APINameBrand__c = 'TestBrandAPI'
        );
        insert br;

        Property__c h = new Property__c();
        h.Name = 'test';
        h.City_object__c = c.id;
        h.Home_Manager_User__c = userInfo.getUserId();
        h.Accounts_Receivable_Coordinator__c = userInfo.getUserId();
        h.BrandRef__c = br.Id;
        insert h;
        
        Property__c h2 = new Property__c();
        h2.Name = 'test2';
        h2.City_object__c = c.id;
        h2.BrandRef__c = br.Id;
        h.Billing_Entity__c = holding.Id;
        insert h2;
        
        Apartment__c s = new Apartment__c();
        s.Name = 'Test';
        s.PropertyRef__c = h.id;
        insert s;

        //Room__c room = TestRecord_Factory.iRoom;
        Room__c room1 = new Room__c();
        room1.Name = 'Test room1';
        room1.Room_Number__c = 1;
        room1.Property__c = 'a011i00000GUqkNAAT';
        room1.ApartmentRef__c = s.Id;
        room1.Price__c = 600;
        room1.Status__c = 'Online';
        room1.CurrencyIsoCode = 'EUR';
        insert room1;

        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc = TestRecord_Factory.iStripe_Account;
        Brand__c brand = TestRecord_Factory.iBrand;
        Property__c property = TestRecord_Factory.iProperty;

        Billing_Entity__c holdingBillingEntity = TestRecord_Factory.createBilling_Entity(); 
        holdingBillingEntity.TypePick__c = CustomerContractService.BILLING_ENTITY_TYPE_HOLDING;
        insert holdingBillingEntity;

        List<Contract> contractsToInsert = new List<Contract>();
        Contract contract = TestRecord_Factory.createContract(account1.Id, opp.Id, room1.Id, stripeAcc.Id);
        contractsToInsert.add(contract);

        Contract contract2 = TestRecord_Factory.createContract(account2.Id, opp.Id, room1.Id, stripeAcc.Id);
        contractsToInsert.add(contract2);

        Contract contract3 = TestRecord_Factory.createContract(account3.Id, opp.Id, room1.Id, stripeAcc.Id);
        contract3.EverSign_Doc_Hash__c = 'Test';
        contractsToInsert.add(contract3);

        insert contractsToInsert;
    }


    @IsTest
    static void scenario(){
        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());

        Account acc = [
            SELECT FirstName, LastName, PersonEmail 
            FROM Account 
            WHERE PersonEmail = 'test.account@example.com' 
            LIMIT 1
        ];
        acc.PersonEmail = 'test' + acc.PersonEmail;
        update acc;

        Billing_Entity__c holding = TestRecord_Factory.createBilling_Entity();
        holding.TypePick__c = CustomerContractService.BILLING_ENTITY_TYPE_HOLDING;
        insert holding;
        
        City__c c = new City__c();
        c.Name = 'Frankfurt';
        insert c;
        
        Brand__c br = new Brand__c(
            Name = 'Test Brand',
            APINameBrand__c = 'TestBrandAPI',
            MoveEmailNotifications__c = 'Move-In'
        );
        insert br;

        Condition__c condition = TestRecord_Factory.iCondition;
        condition.MaximumStayUnitPick__c = 'Months';
        condition.MaximumStayNumber__c = 1;
        update condition;
        Id recordHabytPropertyTypeId =Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Habyt Property').getRecordTypeId();
        Property__c h = new Property__c();
        h.Name = 'test property 1';
        h.City_object__c = c.id;
        h.Home_Manager_User__c = userInfo.getUserId();
        h.Accounts_Receivable_Coordinator__c = userInfo.getUserId();
        h.BrandRef__c = br.Id;
        h.Billing_Entity__c = condition.BillingEntityRef__c;
        h.RecordTypeId = recordHabytPropertyTypeId;
        h.Stage__c = 'Handover';
        h.ConditionRef__c = condition.Id;
        insert h;
        
        Property__c h2 = new Property__c();
        h2.Name = 'test property 2';
        h2.City_object__c = c.id;
        h2.BrandRef__c = br.Id;
        insert h2;
        
        Apartment__c s = new Apartment__c();
        s.Name = 'Test';
        s.PropertyRef__c = h.id;
        insert s;

        Room__c room2 = new Room__c();
        room2.Name = 'Test room2';
        room2.Room_Number__c = 2;
        room2.Property__c = h.Id;
        room2.ApartmentRef__c = s.Id;
        room2.Price__c = 600;
        room2.Status__c = 'Online';
        room2.CurrencyIsoCode = 'EUR';
        insert room2;

        Opportunity opp = TestRecord_Factory.createOpportunity();
        // opp.Room__c = room2.Id;
        opp.City__c = 'Frankfurt';
        opp.Country__c = 'Germany';
        opp.ApartmentRef__c = s.Id;
        System.debug('Opportunity  -->' + opp);
        insert opp;

        Product2 rent_prod = TestRecord_Factory.createProduct2();
        rent_prod.RecordTypeId = CustomerContractService.PRODUCT_RT_ID_RENT;
        insert rent_prod;

        PricebookEntry pbe_1 = TestRecord_Factory.createPricebookEntry();
        pbe_1.Product2Id = rent_prod.Id;
        pbe_1.CurrencyIsoCode = 'EUR';
        insert pbe_1;

        OpportunityLineItem oli_1 = new OpportunityLineItem();
        oli_1.OpportunityId = opp.Id;
        oli_1.Quantity = 1;
        oli_1.TotalPrice = 100;
        oli_1.PricebookEntryId = pbe_1.Id;
        oli_1.Product2Id = rent_prod.Id;
        insert oli_1;

        Set<Id> setOppIds = new Set<Id>();
        setOppIds.add(opp.Id);

        List<Opportunity> lstOpps = (List<Opportunity>) Paua_SelectorHandler.getSelector(CustomerOpportunitySelectors.FromId.class)
        .setParameter('idSet',setOppIds)
        .query();
    
        Test.startTest();
        CustomerContractService customerContractService = new CustomerContractService();
        List<Contract> contracts = customerContractService.createContracts(setOppIds);
        Set<String> statuses = new Set<String>();
        statuses.add('Draft');
        customerContractService.getWithStartBeforeDate(contracts, Date.today().addDays(20));
        contracts[0].Contract_End_Date__c = Date.today().addDays(20);
        System.debug('contracts contracts contracts' + contracts);
        customerContractService.getWithEndBeforeDate(contracts, Date.today().addDays(21));
        customerContractService.getWithEndAfterDate(contracts, Date.today());
        customerContractService.getWithMoveInNotification(contracts);
        List<Contract> actual = customerContractService.getWithNewRelevantStatus(contracts, null, statuses);
        contracts[0].MoveOutEmailDatetime__c = Date.today().addDays(20);
        contracts[0].MoveInEmailDatetime__c = Date.today().addDays(10);
        customerContractService.getWithMoveOutNotification(contracts);
        customerContractService.notifyMoveInContracts(contracts);
        customerContractService.getWithPropertyStage('Handover',contracts);
        customerContractService.getWithoutMoveInDatetime(contracts);
        customerContractService.getWithoutMoveOutDatetime(contracts);
        customerContractService.createHousingConfirmation(contracts);
        CustomerOpportunityService customerOpportunityService = new CustomerOpportunityService();
        customerOpportunityService.removePieceAvailability(lstOpps);
        Test.stopTest();
    }

    @IsTest
    static void scenario2(){
        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());

        Account acc = [
            SELECT FirstName, LastName, PersonEmail 
            FROM Account 
            WHERE PersonEmail = 'test.account@example.com' 
            LIMIT 1
        ];
        acc.PersonEmail = 'test' + acc.PersonEmail;
        update acc;

        Billing_Entity__c holding = TestRecord_Factory.createBilling_Entity();
        holding.TypePick__c = CustomerContractService.BILLING_ENTITY_TYPE_HOLDING;
        insert holding;
        
        City__c c = new City__c();
        c.Name = 'Frankfurt';
        insert c;
        
        Brand__c br = new Brand__c(
            Name = 'Test Brand',
            APINameBrand__c = 'TestBrandAPI',
            MoveEmailNotifications__c = 'Move-In'
        );
        insert br;

        Condition__c condition = TestRecord_Factory.iCondition;
        condition.MaximumStayUnitPick__c = 'Months';
        condition.MaximumStayNumber__c = 1;
        update condition;
        Id recordHabytPropertyTypeId =Schema.SObjectType.Property__c.getRecordTypeInfosByName().get('Habyt Property').getRecordTypeId();
        Property__c h = new Property__c();
        h.Name = 'test property 1';
        h.City_object__c = c.id;
        h.Home_Manager_User__c = userInfo.getUserId();
        h.Accounts_Receivable_Coordinator__c = userInfo.getUserId();
        h.BrandRef__c = br.Id;
        h.Billing_Entity__c = condition.BillingEntityRef__c;
        h.RecordTypeId = recordHabytPropertyTypeId;
        h.Stage__c = 'Handover';
        h.ConditionRef__c = condition.Id;
        insert h;
        
        Property__c h2 = new Property__c();
        h2.Name = 'test property 2';
        h2.City_object__c = c.id;
        h2.BrandRef__c = br.Id;
        insert h2;
        
        Apartment__c s = new Apartment__c();
        s.Name = 'Test';
        s.PropertyRef__c = h.id;
        insert s;

        Room__c room2 = new Room__c();
        room2.Name = 'Test room2';
        room2.Room_Number__c = 2;
        room2.Property__c = h.Id;
        room2.ApartmentRef__c = s.Id;
        room2.Price__c = 600;
        room2.Status__c = 'Online';
        room2.CurrencyIsoCode = 'EUR';
        insert room2;

        Opportunity opp = TestRecord_Factory.createOpportunity();
        // opp.Room__c = room2.Id;
        opp.City__c = 'Frankfurt';
        opp.Country__c = 'Germany';
        opp.ApartmentRef__c = s.Id;
        System.debug('Opportunity  -->' + opp);
        insert opp;

        Product2 rent_prod = TestRecord_Factory.createProduct2();
        rent_prod.RecordTypeId = CustomerContractService.PRODUCT_RT_ID_RENT;
        insert rent_prod;

        PricebookEntry pbe_1 = TestRecord_Factory.createPricebookEntry();
        pbe_1.Product2Id = rent_prod.Id;
        pbe_1.CurrencyIsoCode = 'EUR';
        insert pbe_1;

        OpportunityLineItem oli_1 = new OpportunityLineItem();
        oli_1.OpportunityId = opp.Id;
        oli_1.Quantity = 1;
        oli_1.TotalPrice = 100;
        oli_1.PricebookEntryId = pbe_1.Id;
        oli_1.Product2Id = rent_prod.Id;
        insert oli_1;
        
        List<Contract> contracts = [SELECT Id FROM Contract];
        Set<Id> contractIds = new Set<Id>();
        if( contracts.size() > 0 ){
            for(Contract contract : contracts ){
                contractIds.add(contract.Id);
            }
        }
        Test.startTest();
            CustomerContractService.createDocuments(contractIds);
            CustomerContractService.deleteOldContract(contractIds);
            Set<Id> setOppIds = new Set<Id>();
            setOppIds.add(opp.Id);
            CustomerOpportunityService.setProductPriceBookError(setOppIds);
        Test.stopTest();
    }

    @IsTest
    static void getWithPiece_unitTest() {
        Integer expected = [SELECT COUNT() FROM Contract WHERE Room__c != null OR ApartmentRef__c != null];
        List<Contract> allContracts = [SELECT Id, Room__c, ApartmentRef__c FROM Contract];

        CustomerContractService service = new CustomerContractService();

        Test.startTest();

        List<Contract> actual = service.getWithPiece(allContracts);

        Test.stopTest();
        
        System.assertEquals(expected, actual.size(), 
            'Filtered incorrect results');
    }

    @IsTest
    static void updatePieceAvailability_Signed_unitTest() {
        Contract contract = [SELECT Id, Status, Room__c, Contract_End_Date__c FROM Contract WHERE Room__c != null LIMIT 1];
        contract.Status = CustomerContractService.STATUS_SIGNED;
        
        Room__c room = [SELECT Id, AvailableDateTrig__c FROM Room__c WHERE Id = :contract.Room__c];
        room.AvailableDateTrig__c = System.today();
        update room;

        CustomerContractService service = new CustomerContractService();

        Test.startTest();

        service.updatePieceAvailability(new List<Contract>{contract});

        Test.stopTest();
        
        room = [SELECT Id, AvailableDateTrig__c FROM Room__c WHERE Id = :room.Id];

        System.assertEquals(null, room.AvailableDateTrig__c, 
            'Available Date should be null');
    }

    @IsTest
    static void updatePieceAvailability_Terminated_unitTest() {
        Contract contract = [SELECT Id, Status, Room__c FROM Contract WHERE Room__c != null LIMIT 1];
        contract.Status = CustomerContractService.STATUS_TERMINATED;
        contract.Contract_End_Date__c = System.today();
        
        Room__c room = [SELECT Id, AvailableDateTrig__c FROM Room__c WHERE Id = :contract.Room__c];
        room.AvailableDateTrig__c = null;
        update room;

        CustomerContractService service = new CustomerContractService();

        Test.startTest();

        service.updatePieceAvailability(new List<Contract>{contract});

        Test.stopTest();
        
        room = [SELECT Id, AvailableDateTrig__c FROM Room__c WHERE Id = :room.Id];

        System.assertEquals(contract.Contract_End_Date__c.addDays(1), room.AvailableDateTrig__c, 
            'Available date must be the day after contract end');
    }

    @IsTest
    static void updatePieceAvailability_MultipleContracts_unitTest() {
        List<Contract> allContracts = [SELECT Id, Status, Room__c FROM Contract WHERE Room__c != null LIMIT 2];
        Integer daysToCancellation = 20;

        Contract contract = allContracts[0];
        contract.Status = CustomerContractService.STATUS_TERMINATED;
        contract.Contract_End_Date__c = System.today();

        Contract contract2 = allContracts[1];
        contract2.Status = CustomerContractService.STATUS_TERMINATED;
        contract2.Contract_End_Date__c = System.today().addDays(daysToCancellation);
        update contract2;

        Room__c room = [SELECT Id, AvailableDateTrig__c FROM Room__c WHERE Id = :contract.Room__c];
        room.AvailableDateTrig__c = null;
        update room;

        CustomerContractService service = new CustomerContractService();

        Test.startTest();

        service.updatePieceAvailability(new List<Contract>{contract});

        Test.stopTest();
        
        room = [SELECT Id, AvailableDateTrig__c FROM Room__c WHERE Id = :room.Id];

        System.assertEquals(
            System.today().addDays(daysToCancellation + 1), 
            room.AvailableDateTrig__c, 
            'Available date must be the day after contract end'
        );
    }

    @IsTest
    static void updateAccountMembership_AllTerminated_unitTest() {
        List<Contract> allContracts = [SELECT Id, Status, AccountId, RecordTypeId FROM Contract LIMIT 2];

        Contract contract = allContracts[0];
        contract.Status = CustomerContractService.STATUS_TERMINATED;
        contract.RecordTypeId = CustomerContractService.RT_ID_MEMBERSHIP;
        contract.Contract_End_Date__c = Date.today();
        update contract; // Both contracts must be updated separately, otherwise an exception is thrown.

        Contract contract2 = allContracts[1];
        contract2.Status = CustomerContractService.STATUS_TERMINATED;
        contract2.RecordTypeId =  CustomerContractService.RT_ID_MEMBERSHIP;
        contract.Contract_End_Date__c = Date.today().addMonths(1);
        update contract2;

        Account account = [SELECT Id, MembershipStatusPick__c FROM Account LIMIT 1];
        account.MembershipStatusPick__c = 'Member';
        update account;

        CustomerContractService service = new CustomerContractService();
        Test.startTest();

        service.updateAccountMembership(allContracts);

        Test.stopTest();

        account = [SELECT Id, MembershipStatusPick__c FROM Account LIMIT 1];
        
        System.assertEquals(null, account.MembershipStatusPick__c, 'Account membership status must be null');
    }

    @IsTest
    static void updateAccountMembership_ActiveMembership_unitTest() {
        Id membershipRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName()
                                                               .get('MembershipFee')
                                                               .getRecordTypeId();

        List<Contract> allContracts = [SELECT Id, Status, AccountId, RecordTypeId FROM Contract LIMIT 2];

        Contract contract = allContracts[0];
        contract.Status = CustomerContractService.STATUS_ACTIVATED;
        contract.RecordTypeId = membershipRecordTypeId;

        Contract contract2 = allContracts[1];
        contract2.Status = CustomerContractService.STATUS_TERMINATED;
        contract2.RecordTypeId = membershipRecordTypeId;
        update allContracts;

        Account account = [SELECT Id, MembershipStatusPick__c FROM Account LIMIT 1];
        account.MembershipStatusPick__c = 'Member';
        update account;

        CustomerContractService service = new CustomerContractService();
        Test.startTest();

        service.updateAccountMembership(allContracts);

        Test.stopTest();

        account = [SELECT Id, MembershipStatusPick__c FROM Account LIMIT 1];
        
        System.assertEquals('Member', account.MembershipStatusPick__c, 'Account membership status must be "Member"');
    }

    @IsTest
    static void getContractTitle_unitTest() {
        CustomerContractService contractService = new CustomerContractService();
        Contract contract = [
            SELECT Id, Status, Opportunity__r.BrandAuto__c, Room__c, RecordTypeId
            FROM Contract 
            WHERE Room__c != null AND Room__r.Property__r.BrandRef__r.Name = 'Habyt'
            LIMIT 1
        ];
        contract.RecordTypeId = CustomerContractService.RT_ID_MEMBERSHIP;
        update contract;

        Opportunity opp = [SELECT Id, BrandAuto__c, Room__c, ContractId FROM Opportunity LIMIT 1];
        opp.ContractId = contract.Id;
        opp.Room__c = contract.Room__c;
        update opp;

        contract = [
            SELECT Id, Status, Opportunity__r.BrandAuto__c, Room__c, RecordTypeId
            FROM Contract 
            WHERE Id = :contract.Id
            LIMIT 1
        ];
        String expectedTitle = 'Habyt Membership Contract.pdf';
        String contractTitle = '';
        Test.startTest();

        contractTitle = contractService.getContractTitle(contract);

        Test.stopTest();

        System.assertEquals(expectedTitle, contractTitle, 'Title mismatch');
    }

    @IsTest
    static void voidRelatedContracts_UnitTest() {
        CustomerContractService contractService = new CustomerContractService();
        String expectedStatus = 'Voided';
        List<Contract> contracts = [
            SELECT Id, Status, Room__c 
            FROM Contract 
            WHERE Status = :CustomerContractService.STATUS_DRAFT
            LIMIT 3
        ];

        Id roomId = contracts.get(0).Room__c;
        for(Contract contract : contracts) {
            contract.Room__c = roomId;
            contract.RecordTypeId = CustomerContractService.RT_ID_RENT;
            contract.EverSign_Doc_Hash__c = '123';
            contract.IsVoidContractTrig__c = false;
        }
        contracts.get(0).Status = CustomerContractService.STATUS_SIGNED; 
        update contracts;

        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();

        contractService.voidRelatedContracts(new List<Contract> {contracts.get(0)});

        Test.stopTest();

        contracts = [
            SELECT Id, Status 
            FROM Contract 
            WHERE Id = :contracts.get(1).Id OR Id = :contracts.get(2).Id
            LIMIT 2
        ];

        //System.assertEquals(expectedStatus, contracts.get(0).Status, 'Contract status mismatch');
        //System.assertEquals(expectedStatus, contracts.get(1).Status, 'Contract status mismatch');
    }

    /*@IsTest
    static void voidContractsWithFlow_UnitTest() {
        CustomerContractService contractService = new CustomerContractService();
        String expectedContractStatus = 'Voided';
        String expectedOpportunityStatus = 'Closed Lost';

        Contract contract = [
            SELECT Id, Status, EverSign_Doc_Hash__c, IsVoidContractTrig__c,Reason_for_voiding__c
            FROM Contract 
            WHERE Status = :CustomerContractService.STATUS_DRAFT
            LIMIT 1
        ];
        contract.RecordTypeId = CustomerContractService.RT_ID_RENT;
        contract.EverSign_Doc_Hash__c = '123';
        contract.IsVoidContractTrig__c = false;
        Contract.Reason_for_voiding__c = '';
        update contract;

        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();
        contractService.voidContractsWithFlow(new List<Contract> {contract});
        Test.stopTest();

        contract = [SELECT Id, Status, Opportunity__r.StageName FROM Contract WHERE Id = :contract.Id LIMIT 1];

        System.assertEquals(expectedContractStatus, contract.Status, 'Contract status mismatch');
        System.assertEquals(expectedOpportunityStatus, contract.Opportunity__r.StageName, 'Contract status mismatch');
   }*/

    @IsTest
    static void notifyMoveOutContracts_unitTest() {
        CustomerContractService contractService = new CustomerContractService();
        Integer expected = 2;
        Date endDate = System.today().addDays(CustomerContractService.MOVE_IN_DAYS);

        Brand__c brand = [SELECT Id, MoveEmailNotifications__c, MoveInTemplateName__c, MoveOutTemplateName__c FROM Brand__C LIMIT 1];
        System.debug('brand brand brand' + brand);
        List<EmailTemplate> templates = new List<EmailTemplate>();
        EmailTemplate emailTemplate1 = new EmailTemplate(
            DeveloperName = brand.MoveInTemplateName__c, 
            FolderId = UserInfo.getUserId(), 
            TemplateType='Text', 
            Name = brand.MoveInTemplateName__c,
            IsActive = true
        );
        templates.add(emailTemplate1);

        EmailTemplate emailTemplate2 = new EmailTemplate(
            DeveloperName = brand.MoveOutTemplateName__c, 
            FolderId = UserInfo.getUserId(), 
            TemplateType='Text', 
            Name = brand.MoveOutTemplateName__c,
            IsActive = true
        );
        templates.add(emailTemplate2);
        insert templates;

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(currentUser) {
            brand.MoveEmailNotifications__c = 'Move-In;Move-Out';
            update brand;

            Property__c property = [SELECT Id, BrandRef__c, BrandRef__r.MoveEmailNotifications__c FROM Property__c LIMIT 1];
            property.BrandRef__c = brand.Id;
            update property;

            Room__c room = [SELECT Id FROM Room__c LIMIT 1];
            room.Property__c = property.Id;
            update room;

            List<Account> accounts = [
                SELECT Id, PersonEmail, PersonContactId, FirstName, LastName 
                FROM Account 
                LIMIT 3
            ];

            List<Contract> contracts = [
                SELECT Id, Contract_End_Date__c, StartDate, Room__c, Room__r.Property__r.BrandRef__r.MoveEmailNotifications__c, 
                    Room__r.Property__r.BrandRef__r.MoveInTemplateName__c, Room__r.Property__r.BrandRef__r.MoveOutTemplateName__c,
                    AccountId, Account.PersonContactId, Account.FirstName, Account.LastName, Opportunity__r.BrandAuto__c, Room__r.ApartmentRef__c
                FROM Contract 
                LIMIT 3
            ];

            accounts[0].PersonEmail = 'test1@test.com';
            accounts[1].PersonEmail = 'test2@test.com';
            accounts[2].PersonEmail = 'test3@test.com';
            update accounts;
            
            // All contracts must be updated separately, otherwise an exception is thrown.
            // At this point contract & contract1 should have end date > contract3 end date. Because we are searching 
            // for contracts that are still active to that time
            Contract contract = contracts[0];
            contract.Room__c = room.Id;
            contract.Status = CustomerContractService.STATUS_SIGNED;
            contract.Contract_End_Date__c = endDate.addDays(CustomerContractService.MOVE_IN_DAYS); 
            contract.StartDate = System.today();
            contract.AccountId = accounts[0].Id;
            update contract; 

            Contract contract2 = contracts[1];
            contract2.Room__c = room.Id;
            contract2.Status = CustomerContractService.STATUS_SIGNED;
            contract2.Contract_End_Date__c = endDate.addDays(CustomerContractService.MOVE_IN_DAYS);
            contract2.StartDate = System.today();
            contract2.AccountId = accounts[1].Id;
            update contract2;

            Contract contract3 = contracts[2];
            contract3.Room__c = room.Id;
            contract3.Status = CustomerContractService.STATUS_SIGNED;
            contract3.Contract_End_Date__c = endDate;
            contract3.StartDate = System.today();
            contract3.AccountId = accounts[2].Id;
            update contract3;

            Test.startTest();
            CustomerContractService customerContractService = new CustomerContractService();
            //contractService.notifyMoveInContracts(new List<Contract>{contract});
            customerContractService.notifyMoveOutContracts(new List<Contract>{contract});
            //Integer invocations = Limits.getEmailInvocations();
            Test.stopTest();

            //System.assertEquals(expected, invocations, 'Number of emails unexpected');
        }
    }

    @IsTest
    static void cancelMembershipForContract_UnitTest() {
        CustomerContractService contractService = new CustomerContractService();
        String expectedStatus = CustomerContractService.STATUS_TERMINATED;
        Date expectedMoveOutDate = System.today().addDays(1);
        Date expectedEndDate = System.today().addDays(7);
        List<Contract> contracts = [
            SELECT Id, RecordTypeId, Stripe_Subscription_Id__c, Stripe_Account__r.Secret_key__c, Room__c, Status, 
                   AccountId, Contract_End_Date__c, Move_out_date__c
            FROM Contract
            LIMIT 2
        ];

        //Room__c newRoom = TestRecord_Factory.createRoom();
        //insert newRoom;
        Room__c room3 = new Room__c();
        room3.Name = 'Test room3';
        room3.Room_Number__c = 3;
        room3.Property__c = 'a011i00000GUqkNAAT';
        room3.ApartmentRef__c = 'a0N1i00000AyGexEAF';
        room3.Price__c = 600;
        room3.Status__c = 'Online';
        //room3.AvailableDateTrig__c = System.today();
        room3.CurrencyIsoCode = 'EUR';
        insert room3;


        Contract contract = contracts[0];
        contract.Status = CustomerContractService.STATUS_ACTIVATED;
        contract.RecordTypeId = CustomerContractService.RT_ID_MEMBERSHIP;
        contract.Contract_End_Date__c = null;
        contract.Move_out_date__c = null;
        contract.Room__c = room3.Id;

        Contract contract2 = contracts[1];
        contract2.AccountId = contract.AccountId;
        contract2.Contract_End_Date__c = expectedEndDate;
        contract2.Move_out_date__c = expectedMoveOutDate;
        contract2.RecordTypeId = CustomerContractService.RT_ID_RENT;
        update contracts;

        Test.startTest();
        contractService.cancelMembershipForContract(new List<Contract> {contract2}, contract2.Contract_End_Date__c, contract2.Move_out_date__c);
        Test.stopTest();

        contract = [
            SELECT Id, Status, Contract_End_Date__c, Move_out_date__c, Room__r.AvailableDateTrig__c
            FROM Contract
            WHERE Id = :contract.Id
            LIMIT 1
        ];
        contract.Room__r.AvailableDateTrig__c = System.today().addDays(8);

        System.assertEquals(expectedStatus, contract.Status, 'Status unexpected');
        System.assertEquals(expectedEndDate, contract.Contract_End_Date__c, 'End date unexpected');
        System.assertEquals(expectedMoveOutDate, contract.Move_out_date__c, 'Move-out date unexpected');
        System.assertEquals(expectedEndDate.addDays(1), contract.Room__r.AvailableDateTrig__c, 'Availability Date unexpected');
    }


    @IsTest
    static void getWithMoveInPeriod_UnitTest() {
        CustomerContractService contractService = new CustomerContractService();
        Integer expectedSize = 1;
        List<Contract> contracts = [
                SELECT Id, StartDate
                FROM Contract
                LIMIT 3
        ];

        Contract contract = contracts[0];
        contract.StartDate = System.today().addDays(CustomerContractService.MOVE_IN_DAYS).addDays(1);

        Contract contract2 = contracts[1];
        contract2.StartDate = System.today().addDays(-1);

        Contract contract3 = contracts[2];
        contract3.StartDate = System.today();

        update contracts;

        Test.startTest();
        List<Contract> relevantContracts = contractService.getWithMoveInPeriod(contracts);
        Test.stopTest();

        System.assertEquals(expectedSize, relevantContracts.size(), 'Contracts size unexpected');
    }

    // @IsTest
    // static void getWithEndBeforeDate_UnitTest() {
    //     CustomerContractService contractService = new CustomerContractService();
    //     Integer expectedSize = 1;
    //     List<Contract> contracts = [
    //         SELECT Id, Contract_End_Date__c
    //         FROM Contract
    //         LIMIT 3
    //     ];

    //     Contract contract = contracts[0];
    //     contract.Contract_End_Date__c = System.today().addDays(1);

    //     Contract contract2 = contracts[1];
    //     contract2.Contract_End_Date__c = System.today().addDays(-1);

    //     Contract contract3 = contracts[2];
    //     contract3.Contract_End_Date__c = System.today();

    //     update contracts;

    //     Test.startTest();
    //     List<Contract> relevantContracts = contractService.getWithEndBeforeDate(contracts, System.today());
    //     Test.stopTest();

    //     System.assertEquals(expectedSize, relevantContracts.size(), 'Contracts size unexpected');
    // }

    // @IsTest
    // static void getWithNewRelevantStatusSet_UnitTest() {
    //     CustomerContractService contractService = new CustomerContractService();
    //     Integer expectedSize = 2;
    //     List<Contract> contracts = [
    //         SELECT Id, Contract_End_Date__c
    //         FROM Contract
    //         LIMIT 3
    //     ];

    //     Contract contract = contracts[0];
    //     Contract contract2 = contracts[1];
    //     Contract contract3 = contracts[2];

    //     Map<Id, Contract> oldMap = new Map<Id, Contract>();
    //     oldMap.put(contract.Id, new Contract(Status=CustomerContractService.STATUS_DRAFT));
    //     oldMap.put(contract2.Id, new Contract(Status=CustomerContractService.STATUS_DRAFT));
    //     oldMap.put(contract3.Id, new Contract(Status=CustomerContractService.STATUS_DRAFT));

    //     Set<String> relevantStatuses = new Set<String> {
    //         CustomerContractService.STATUS_SIGNED, 
    //         CustomerContractService.STATUS_ACTIVATED
    //     };

    //     contract.Status = CustomerContractService.STATUS_SIGNED;
    //     contract2.Status = CustomerContractService.STATUS_VOIDED;
    //     contract3.Status = CustomerContractService.STATUS_ACTIVATED;

    //     update contracts;

    //     Test.startTest();
    //     List<Contract> relevantContracts = contractService.getWithNewRelevantStatusSet(
    //         contracts, oldMap, relevantStatuses
    //     );
    //     Test.stopTest();

    //     System.assertEquals(expectedSize, relevantContracts.size(), 'Filtered contracts size unexpected');
    // }

    // @IsTest
    // static void getWithDocHashNotNull_UnitTest() {
    //     CustomerContractService contractService = new CustomerContractService();
    //     Integer expectedSize = 2;
    //     List<Contract> contracts = [
    //         SELECT Id, EverSign_Doc_Hash__c
    //         FROM Contract
    //         LIMIT 3
    //     ];

    //     Contract contract = contracts[0];
    //     contract.EverSign_Doc_Hash__c = 'testhash';

    //     Contract contract2 = contracts[1];
    //     contract2.EverSign_Doc_Hash__c = 'testhash';

    //     Contract contract3 = contracts[2];

    //     update contracts;

    //     Map<Id, Contract> oldMap = new Map<Id, Contract>();
    //     oldMap.put(contract.Id, contract);
    //     oldMap.put(contract2.Id, contract2);
    //     oldMap.put(contract3.Id, contract3);

    //     Test.startTest();
    //     List<Contract> relevantContracts = contractService.getWithDocHashNotNull(contracts, oldMap);
    //     Test.stopTest();

    //     System.assertEquals(expectedSize, relevantContracts.size(), 'Filtered contracts size unexpected');
    // }

    // @IsTest
    // static void getNotTestContract_UnitTest() {
    //     CustomerContractService contractService = new CustomerContractService();
    //     Integer expectedSize = 0;

    //     Opportunity opp = [
    //         SELECT Id, IsTestOpportunity__c
    //         FROM Opportunity
    //         LIMIT 1
    //     ];
    //     opp.IsTestOpportunity__c = true;
    //     update opp;

    //     List<Contract> contracts = [
    //         SELECT Id, Opportunity__c, IsTestContract__c
    //         FROM Contract
    //         WHERE Opportunity__c = :opp.Id
    //         LIMIT 3
    //     ];

    //     Test.startTest();
    //     List<Contract> relevantContracts = contractService.getNotTestContract(contracts);
    //     Test.stopTest();

    //     System.assertEquals(expectedSize, relevantContracts.size(), 'Filtered contracts size unexpected');
    // }

    // @IsTest
    // static void voidContractsInEversign_UnitTest() {
    //     CustomerContractService contractService = new CustomerContractService();
    //     Integer expectedSize = 1;
    //     String className = 'ContractsVoidEversignQueueable';
    //     String expectedStatusQueued = 'Queued';
    //     String expectedStatusCompleted = 'Completed';
    //     List<Contract> contracts = [
    //         SELECT Id, EverSign_Doc_Hash__c
    //         FROM Contract
    //         LIMIT 2
    //     ];

    //     Contract contract = contracts[0];
    //     contract.EverSign_Doc_Hash__c = 'testhash';

    //     Contract contract2 = contracts[1];
    //     contract2.EverSign_Doc_Hash__c = 'testhash';
    //     update contracts;

    //     Map<Id, Contract> oldMap = new Map<Id, Contract>();
    //     oldMap.put(contract.Id, contract);
    //     oldMap.put(contract2.Id, contract2);

    //     Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
    //     Test.startTest();
    //     contractService.voidContractsInEversign(contracts, oldMap);
    //     List<AsyncApexJob> jobsQueued = [
    //         SELECT Id, ApexClass.Name, Status, JobType 
    //         FROM AsyncApexJob 
    //         WHERE JobType = 'Queueable'
    //     ];
    //     String statusInTest = jobsQueued[0].Status;
    //     Test.stopTest();

    //     jobsQueued = [
    //         SELECT Id, ApexClass.Name, Status, JobType 
    //         FROM AsyncApexJob 
    //         WHERE JobType = 'Queueable'
    //     ];
    //     System.assertEquals(expectedSize, jobsQueued.size(), 'Expecting one queueable job');
    //     System.assertEquals(className, jobsQueued[0].ApexClass.Name, 'Expecting specific scheduled job');
    //     System.assertEquals(expectedStatusCompleted, jobsQueued[0].Status, 'Job should be Completed');
    //     System.assertEquals(expectedStatusQueued, statusInTest, 'Job should be Queued');
    // }

    // @IsTest
    // static void getWithEndBeforeDateNotStrict_UnitTest() {
    //     CustomerContractService contractService = new CustomerContractService();
    //     Integer expectedSize = 2;
    //     List<Contract> contracts = [
    //         SELECT Id, Contract_End_Date__c
    //         FROM Contract
    //         LIMIT 3
    //     ];

    //     Contract contract = contracts[0];
    //     contract.Contract_End_Date__c = System.today().addDays(1);

    //     Contract contract2 = contracts[1];
    //     contract2.Contract_End_Date__c = System.today().addDays(-1);

    //     Contract contract3 = contracts[2];
    //     contract3.Contract_End_Date__c = System.today();

    //     update contracts;

    //     Test.startTest();
    //     List<Contract> relevantContracts = contractService.getWithEndAfterDate(contracts, System.today());
    //     Test.stopTest();

    //     System.assertEquals(expectedSize, relevantContracts.size(), 'Contracts size unexpected');
    // }

    // @IsTest
    // static void getWithoutMoveInDatetime_UnitTest() {
    //     CustomerContractService contractService = new CustomerContractService();
    //     Integer expectedSize = 1;
    //     List<Contract> contracts = [
    //         SELECT Id, Contract_End_Date__c, MoveInEmailDatetime__c
    //         FROM Contract
    //         LIMIT 2
    //     ];

    //     Contract contract = contracts[0];
    //     contract.MoveInEmailDatetime__c = Datetime.now();

    //     Contract contract2 = contracts[1];
    //     contract2.MoveInEmailDatetime__c = null;

    //     update contracts;

    //     Test.startTest();
    //     List<Contract> relevantContracts = contractService.getWithoutMoveInDatetime(contracts);
    //     Test.stopTest();

    //     System.assertEquals(expectedSize, relevantContracts.size(), 'Contracts size unexpected');
    // }

    // @IsTest
    // static void getWithoutMoveOutDatetime_UnitTest() {
    //     CustomerContractService contractService = new CustomerContractService();
    //     Integer expectedSize = 1;
    //     List<Contract> contracts = [
    //         SELECT Id, Contract_End_Date__c, MoveOutEmailDatetime__c
    //         FROM Contract
    //         LIMIT 2
    //     ];

    //     Contract contract = contracts[0];
    //     contract.MoveOutEmailDatetime__c = Datetime.now();

    //     Contract contract2 = contracts[1];
    //     contract2.MoveOutEmailDatetime__c = null;

    //     update contracts;

    //     Test.startTest();
    //     List<Contract> relevantContracts = contractService.getWithoutMoveOutDatetime(contracts);
    //     Test.stopTest();

    //     System.assertEquals(expectedSize, relevantContracts.size(), 'Contracts size unexpected');
    // }
}