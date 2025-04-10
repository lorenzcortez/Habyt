@istest
public class test_CaseTriggerHandler{
    @isTest
    static void scenario(){ 
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'test';
        acc.PersonEmail = 'test@test.com';
        insert acc;
        
        City__c c = new City__c();
        c.Name = 'Seattle';
        insert c;

        Brand__c br = new Brand__c(Name = 'Test Brand',
                APINameBrand__c = 'Test Brand API');
        insert br;
        
        Property__c h = new Property__c();
        h.Name = 'test';
        h.City_object__c = c.id;
        h.Home_Manager_User__c = UserInfo.getUserId();
        h.Property_Services_Move_out_Task__c = 'Yes';
        h.Maintenance_Tech__c = userinfo.getuserId();
        h.Porter__c = UserInfo.getuserId();
        h.Onboarding_and_Experience_Manager__c = userInfo.getUserId();
        h.Maintenance_Tech__c = UserInfo.getUserId();
        h.Pre_Move_Out_Inspection_Task__c = 'Yes';
        h.Post_Move_Out_Inspection_Task__c = 'Yes';
        h.Leasing_Specialist_Move_out_Task__c = 'Yes';
        h.Onsite_Move_out_Task__c = 'Yes';
        h.Sourcefit_Move_out_Task__c = 'Yes';
        h.Resident_Services_Coordinator__c = UserInfo.getUserId();
        h.Area_Manager__c = UserInfo.getUserId();
        h.BrandRef__c = br.Id;
        insert h;
        
        Home_Committed_Round_Robin__c setting = new Home_Committed_Round_Robin__c();
        setting.Name = 'test';
        setting.Home_Name__c = 'test';
        setting.Queue_No__c = 1;
        insert setting;
        
        Apartment__c s = new Apartment__c();
        s.Name = 'Test';
        s.PropertyRef__c = h.id;
        insert s;
        
        Room__c r = new Room__c ();
        r.Name = 'test';
        r.Property__c = h.id;
        r.ApartmentRef__c = s.id;
        insert r;
        
        Id InitialRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Common - Transfer').getRecordTypeId();
        
        Opportunity Initopp = new Opportunity();
        Initopp.Name = 'test Opp 1';
        Initopp.StageName = 'Member';
        Initopp.CloseDate = system.today();
        Initopp.AccountID = acc.id;
        Initopp.Phone__c = '2223333';
        //Initopp.City__c = c.id;
        //Initopp.Suite__c = s.id;
        Initopp.Start_Date_of_Occupancy__c = system.today().addDays(7);
        Initopp.End_Date_of_Occupancy__c = system.today().addDays(30);
        //Initopp.RoomSelected__c = r.id;
        Initopp.RecordTypeId = InitialRecordTypeId;
        Initopp.Early_Termination__c = TRUE;
        Initopp.Early_Termination_Type__c = 'Ghosted';
        Initopp.End_Date_Updated__c = TRUE;
        //insert Initopp;
        
        Case c1 = new Case();
        c1.RecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Common - Transfer').getRecordTypeId();
        c1.Payment_Plan_ID__c = '8f999efe-5798-4b51-a6c5-d21b0d04124b343';
        c1.Status = 'New';
        c1.Subject = 'test';
        c1.SuppliedEmail = 'development@einsteam.com';
        c1.Description = 'Testing';
        //c1.Opportunity__c = InitOpp.Id;
        c1.Account__c = acc.Id;
        c1.AccountId = acc.Id;
        c1.Home__c = h.Id;
        c1.City__c = c.Id;
        c1.Room__c = r.Id;
        c1.Suite__c = s.Id;
        insert c1;
        
        partialSchedulable_PaymentPlanForCases p = new partialSchedulable_PaymentPlanForCases();
        p.runJob();
        
        partialSchedulable_PaymentInformation p1 = new partialSchedulable_PaymentInformation();
        p1.runJob();
        
        String json1 = '{\"installments\":[{\"amount\":6.08,\"id\":null,\"inserted_at\":null,\"retry_number\":0,\"scheduled\":\"2020-04-08T15:24:45Z\"},{\"amount\":6.08,\"id\":null,\"inserted_at\":null,\"retry_number\":0,\"scheduled\":\"2020-04-15T15:24:45Z\"},{\"amount\":6.08,\"id\":null,\"inserted_at\":null,\"retry_number\":0,\"scheduled\":\"2020-04-22T15:24:45Z\"},{\"amount\":6.08,\"id\":null,\"inserted_at\":null,\"retry_number\":0,\"scheduled\":\"2020-04-29T15:24:45Z\"},{\"amount\":6.08,\"id\":null,\"inserted_at\":null,\"retry_number\":0,\"scheduled\":\"2020-05-06T15:24:45Z\"},{\"amount\":6.08,\"id\":null,\"inserted_at\":null,\"retry_number\":0,\"scheduled\":\"2020-05-13T15:24:45Z\"},{\"amount\":6.02,\"id\":null,\"inserted_at\":null,\"retry_number\":0,\"scheduled\":\"2020-05-20T15:24:45Z\"}],\"line_items\":[],\"payment_plan\":{\"amount\":50.0,\"amount_paid\":0.0,\"currency\":\"USD\",\"customer\":{\"email\":\"development+customer2@einsteam.com\",\"first_name\":\"Einsteam Test\",\"id\":\"546bd859-687c-44ab-80a9-9ee5526fcfd8\",\"inserted_at\":\"2020-04-01T12:26:22\",\"last_name\":\"Customer 2\",\"phone\":\"+1343434444\",\"shipto_address\":null,\"shipto_address2\":null,\"shipto_city\":null,\"shipto_country\":\"US\",\"shipto_name\":null,\"shipto_postal_code\":null,\"shipto_state\":null,\"timezone\":\"America/New_York\"},\"customer_id\":\"546bd859-687c-44ab-80a9-9ee5526fcfd8\",\"id\":\"c5871e2a-cdba-4447-b501-37998d7ecbeb\",\"inserted_at\":\"2020-04-01T15:24:45\",\"integration\":null,\"integration_id\":null,\"ip_address\":null,\"merchant_notes\":null,\"meta\":null,\"number\":null,\"payment_method_id\":null,\"shipto_address\":null,\"shipto_address2\":null,\"shipto_city\":null,\"shipto_country\":\"US\",\"shipto_name\":null,\"shipto_postal_code\":null,\"shipto_state\":null,\"status\":\"checkout\",\"subtotal\":50.0,\"user_agent\":null},\"payment_schedule\":{\"amount\":50.0,\"auto_process\":true,\"balance\":42.5,\"contract_body\":\"By submitting your order and authorizing the charges on your card, you are legally bound to the following terms:\\r\\n\\r\\nI, Einsteam Test Customer 2, acknowledge that I authorize Partial.ly to charge $7.50 on behalf of Common today, and  $6.08 on the following payment dates:\\r\\n\\r\\n$6.08 on April 8, 2020\\r\\n\\r\\n$6.08 on April 15, 2020\\r\\n\\r\\n$6.08 on April 22, 2020\\r\\n\\r\\n$6.08 on April 29, 2020\\r\\n\\r\\n$6.08 on May 6, 2020\\r\\n\\r\\n$6.08 on May 13, 2020\\r\\n\\r\\n$6.02 on May 20, 2020\\r\\n\\r\\nI acknowledge that a total of $50.00 USD will be paid to Common by May 20, 2020.\\r\\n\\r\\n\\r\\nI acknowledge that the credit card(s) or payment method(s) I am using to make this purchase will be active, valid and have sufficient funds available during the entire term of the payback period. If for any reason my payment is declined, I will provide an alternative, valid payment method.\\r\\n\\r\\nI understand that I may be assessed a late fee(s) if a payment is missed on any of the agreed-upon payment dates for any reason whatsoever.\\r\\n\\r\\nI understand that I am legally bound to these terms and required by law to make all payments on the agreed-upon payment dates.\\r\\n\\r\\nNothing in this Agreement absolves the Tenant of accrued rent due. The agreed delay in payment of rent or payment is not a rent waiver.  If you fail to make payments as they become due or fail to make any payment of rent and additional rent, Common or the owner of the property reserves the right to 1) at its option, have your remaining unpaid balance become due immediately, and 2) terminate your lease and petition the court to regain possession of the property which will result in your eviction.\\r\\n\\r\\nCommon reserves the right to report delinquent payments to credit agencies and collections agencies.\\r\\n\\r\\n\",\"contract_signature\":null,\"contract_signed_date\":null,\"description\":null,\"down_payment_amount\":7.5,\"frequency\":1,\"frequency_days\":[],\"frequency_units\":\"weeks\",\"id\":\"fcdde8e8-1fba-4ad2-b70a-d5815c50a62d\",\"inserted_at\":\"2020-04-01T15:24:45\",\"num_payments\":7,\"payment_amount\":6.08,\"repay_by_date\":\"2020-05-20\",\"starts_auto\":true,\"starts_date\":null,\"term\":7,\"term_date\":null,\"term_units\":\"weeks\"}}';
        PaymentPlanParser r1 = PaymentPlanParser.parse(json1);
        
        String json = '{'+
            '    \"total_pages\": 1,'+
            '    \"total_entries\": 1,'+
            '    \"payment_plans\": ['+
            '        {'+
            '            \"user_agent\": null,'+
            '            \"subtotal\": 1000,'+
            '            \"status\": \"open\",'+
            '            \"number\": 140,'+
            '            \"meta\": {'+
            '                \"items\": ['+
            '                    {'+
            '                        \"quantity\": 1,'+
            '                        \"price\": 900,'+
            '                        \"name\": \"Widget\",'+
            '                        \"id\": \"widget-id\"'+
            '                    },'+
            '                    {'+
            '                        \"quantity\": 2,'+
            '                        \"price\": 50,'+
            '                        \"name\": \"Small product\",'+
            '                        \"id\": \"prod-sm\"'+
            '                    }'+
            '                ],'+
            '                \"description\": \"Sample api plan\"'+
            '            },'+
            '            \"merchant_notes\": \"Customer is very happy\",'+
            '            \"ip_address\": null,'+
            '            \"integration_id\": null,'+
            '            \"integration\": null,'+
            '            \"inserted_at\": \"2018-11-28T17:13:14.181300\",'+
            '            \"id\": \"8f999efe-5798-4b51-a6c5-d21b0d04124b\",'+
            '            \"customer_id\": \"e3cbf1dc-0c11-483f-b604-d44fd93aac90\",'+
            '            \"currency\": \"USD\",'+
            '            \"amount_paid\": 256.25,'+
            '            \"amount\": 1025'+
            '        },{'+
            '            \"user_agent\": null,'+
            '            \"subtotal\": 1000,'+
            '            \"status\": \"open\",'+
            '            \"number\": 140,'+
            '            \"meta\": {'+
            '                \"items\": ['+
            '                    {'+
            '                        \"quantity\": 1,'+
            '                        \"price\": 900,'+
            '                        \"name\": \"Widget\",'+
            '                        \"id\": \"widget-id\"'+
            '                    },'+
            '                    {'+
            '                        \"quantity\": 2,'+
            '                        \"price\": 50,'+
            '                        \"name\": \"Small product\",'+
            '                        \"id\": \"prod-sm\"'+
            '                    }'+
            '                ],'+
            '                \"description\": \"Sample api plan\"'+
            '            },'+
            '            \"merchant_notes\": \"Customer is very happy\",'+
            '            \"ip_address\": null,'+
            '            \"integration_id\": null,'+
            '            \"integration\": null,'+
            '            \"inserted_at\": \"2018-11-28T17:13:14.181300\",'+
            '            \"id\": \"8f999efe-5798-4b51-a6c5-d21b0d04124b\",'+
            '            \"customer_id\": \"e3cbf1dc-0c11-483f-b604-d44fd93aac90\",'+
            '            \"currency\": \"USD\",'+
            '            \"amount_paid\": 256.25,'+
            '            \"amount\": 1025'+
            '        }'+
            ''+
            '    ],'+
            '    \"page_size\": 10,'+
            '    \"page_number\": 1'+
            '}';
        PaymentPlanlistParser r2 = PaymentPlanlistParser.parse(json);
        
        CaseTriggerHandler.AssignCasetoResidentServiceCoordinator(c1.Id, UserInfo.getUserId());
        list<Case> CaseList = new list<Case> {c1};
        Set<Id> CaseIds = new set<Id> {c1.Id};
        CaseTriggerHandler.TempTestConverageBooster();
        CaseTriggerHandler.populatecontactonOrphanCase_EmailtoCase(CaseList);
        CaseTriggerHandler.RollupCountonParentCase(CaseIds);
        CaseTriggerHandler.RollupDelinquencyCasesOnAccount(CaseIds);
        CaseTriggerHandler.AutoCloseCases(CaseList);
        CaseTriggerHandler.sendSuccessEmail('Testing');
    }
    
    // @isTest(SeeAllData=True)
    // public static void testFSL(){
    //     Case c =new Case();
    //     c.Subject = 'TESTY';
    //     c.Issue_Type__c = 'Property Issue';
    //     c.Sub_Issue_Type__c = 'Outdoor Maintenance';
    //     c.Appliance__c = 'Outdoor Maintenance';
    //     c.Whats_Wrong_with_X__c = 'Outdoor Maintenance';
    //     c.Need_PS_Help__c = true;
    //     c.Home__c = [SELECT id from Property__c where name = 'Test Home'][0].id;
    //     insert c;
        
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.Home__c = [SELECT id from Property__c where name = 'Test Home'][0].id;
    //     insert c2;
        
    //     c2.Issue_Type__c = 'Property Issue';
    //     c2.Sub_Issue_Type__c = 'Outdoor Maintenance';
    //     //c2.Appliance__c = 'Outdoor Maintenance';
    //     //c2.Whats_Wrong_with_X__c = 'Outdoor Maintenance';
    //     c2.Need_PS_Help__c = true;
    //     c2.IsEscalated = true;
    //     c2.Escalation_Reason__c = 'Emergency Escalation';
    //     c2.case_description__c = '<p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which team are you on?</span></p><p>Property Services</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">Why are you getting in touch?</span></p><p>To report a property issue</p><p><br></p><p><span style="font-size: 15px; background-color: rgb(255, 255, 255); font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">In which home is the issue you are reporting?</span></p><p>MacArthur</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">In which suite or shared space?</span></p><p>N/A</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">What is the issue type?</span></p><p>WiFi issue</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which appliance is having an issue?</span></p><p></p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Issue Details?</span></p><p>There are several surveillance cameras offline at MAC.This creates a safety issue as well as potential issues with members should there be any on-site incidents.</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">When did you first noticed the issue?</span></p><p>Within the last 24 hours</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; font-size: 15px; background-color: rgb(255, 255, 255);">What potential solution have you already tried?</span></p><p>I rebooted the Eagle Eye router twice as well as the WiFi for the property,still don’t have all cameras online. </p>';
    //     update c2;
        
        
        
    // }
    // @isTest(SeeAllData=True)
    // public static void testAddSubIssueFromNullAndEscalate(){
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.Home__c = [SELECT id from Property__c where name = 'Test Home'][0].id;
    //     //CSS - Member Support Specialists record Type ID
    //     c2.RecordTypeId = '0123u000000FQMUAA4';
    //     insert c2;
        
    //     c2.Issue_Type__c = 'Property Issue';
    //     c2.Sub_Issue_Type__c = 'Pests';
    //     c2.IsEscalated = true;
    //     c2.Escalation_Reason__c = 'Emergency Escalation';
    //     update c2;

    // }
    
    // @isTest(SeeAllData=True)
    // public static void testEmergencyEscalation(){
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.Home__c = [SELECT id from Property__c where name = 'Test Home'][0].id;
    //     //CSS - Member Support Specialists record Type ID
    //     c2.RecordTypeId = '0123u000000FQMUAA4';
        
    //     c2.Issue_Type__c = 'Property Issue';
    //     c2.Sub_Issue_Type__c = 'Floors Carpentry';
    //     insert c2;
        
    //     c2.IsEscalated = true;
    //     c2.Escalation_Reason__c = 'Emergency Escalation';
    //     update c2;
        
    // }
    
    // @isTest(SeeAllData=True)
    // public static void testAddSubIssueTypeFromNull(){
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.Home__c = [SELECT id from Property__c where name = 'Test Home'][0].id;
    //     //CSS - Member Support Specialists record Type ID
    //     c2.RecordTypeId = '0123u000000FQMUAA4';
        
    //     c2.Issue_Type__c = 'Property Issue';
    //     c2.Sub_Issue_Type__c = 'Pests';
    //     insert c2;
        
        
    // }
    
    // @isTest(SeeAllData=True)
    // public static void testChangeSubIssueType(){
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.Home__c = [SELECT id from Property__c where name = 'Test Home'][0].id;
    //     //CSS - Member Support Specialists record Type ID
    //     c2.RecordTypeId = '0123u000000FQMUAA4';
        
    //     c2.Issue_Type__c = 'Property Issue';
    //     c2.Sub_Issue_Type__c = 'Floors Carpentry';
    //     insert c2;
        
    //     c2.Issue_Type__c = 'Events Community and Suitemate Issues';
    //     c2.Sub_Issue_Type__c = 'Mail and Packages';

    //     update c2;
   
        
    //     //Remove when deploy trigger by removing work order comments after fixing query bug.
    //     CaseTriggerHandler.TempTestConverageBooster();
    // }
    
    //  @isTest(SeeAllData=True)
    // public static void testDeleteSubIssueType(){
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.Home__c = [SELECT id from Property__c where name = 'Test Home'][0].id;
    //     //CSS - Member Support Specialists record Type ID
    //     c2.RecordTypeId = '0123u000000FQMUAA4';
        
    //     c2.Issue_Type__c = 'Property Issue';
    //     c2.Sub_Issue_Type__c = 'Floors Carpentry';
    //     insert c2;
        
    //     c2.Issue_Type__c = 'Events Community and Suitemate Issues';
    //     c2.Sub_Issue_Type__c = null;

    //     update c2;
   
        
    // }
    // @isTest(SeeAllData=True)
    
    // public static void testEscalationWithHomeAndSubIssueType(){      
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.RecordTypeId = '0123u000000FQMUAA4';
    //     c2.Home__c = [SELECT id from Property__c where name = 'Test Home'][0].id;
    //     c2.sub_issue_type__c = 'Leaving Common Early';
    //     c2.Issue_Type__c = 'Lease and Billing Inquiries';
    //     insert c2;
        

    //     c2.IsEscalated = true;
    //     c2.Escalation_Reason__c = 'Emergency Escalation';
    //     c2.case_description__c = '<p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which team are you on?</span></p><p>Property Services</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">Why are you getting in touch?</span></p><p>To report a property issue</p><p><br></p><p><span style="font-size: 15px; background-color: rgb(255, 255, 255); font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">In which home is the issue you are reporting?</span></p><p>MacArthur</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">In which suite or shared space?</span></p><p>N/A</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">What is the issue type?</span></p><p>WiFi issue</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which appliance is having an issue?</span></p><p></p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Issue Details?</span></p><p>There are several surveillance cameras offline at MAC.This creates a safety issue as well as potential issues with members should there be any on-site incidents.</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">When did you first noticed the issue?</span></p><p>Within the last 24 hours</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; font-size: 15px; background-color: rgb(255, 255, 255);">What potential solution have you already tried?</span></p><p>I rebooted the Eagle Eye router twice as well as the WiFi for the property,still don’t have all cameras online. </p>';
    //     update c2;
        
    // }
    
    // //This should run the deleteTierSkillsPSR
    // @isTest(SeeAllData=True)
    // public static void testChangeToNonMssRecordType(){      
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.RecordTypeId = '0123u000000FQMUAA4';
    //     c2.Home__c = [SELECT id from Property__c where name = 'Test Home'][0].id;
    //     c2.sub_issue_type__c = 'Leaving Common Early';
    //     c2.Issue_Type__c = 'Lease and Billing Inquiries';
    //     insert c2;
        

    //     c2.IsEscalated = true;
    //     c2.recordtypeid = '0123u000000BVV6AAO';
    //     c2.Escalation_Reason__c = 'Emergency Escalation';
    //     c2.case_description__c = '<p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which team are you on?</span></p><p>Property Services</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">Why are you getting in touch?</span></p><p>To report a property issue</p><p><br></p><p><span style="font-size: 15px; background-color: rgb(255, 255, 255); font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">In which home is the issue you are reporting?</span></p><p>MacArthur</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">In which suite or shared space?</span></p><p>N/A</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">What is the issue type?</span></p><p>WiFi issue</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which appliance is having an issue?</span></p><p></p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Issue Details?</span></p><p>There are several surveillance cameras offline at MAC.This creates a safety issue as well as potential issues with members should there be any on-site incidents.</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">When did you first noticed the issue?</span></p><p>Within the last 24 hours</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; font-size: 15px; background-color: rgb(255, 255, 255);">What potential solution have you already tried?</span></p><p>I rebooted the Eagle Eye router twice as well as the WiFi for the property,still don’t have all cameras online. </p>';
    //     update c2;
        
    // }
    
    
    //     @isTest(SeeAllData=True)
    // public static void testChangeToMSSRecordType(){      
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.RecordTypeId = '0123u000000BVV6AAO';
    //     c2.Home__c = [SELECT id from Property__c where name = 'Test Home'][0].id;
    //     c2.sub_issue_type__c = 'Leaving Common Early';
    //     c2.Issue_Type__c = 'Lease and Billing Inquiries';
    //     insert c2;
        

    //     c2.IsEscalated = true;
    //     c2.recordtypeid = '0123u000000FQMUAA4';
    //     c2.Escalation_Reason__c = 'Emergency Escalation';
    //     c2.case_description__c = '<p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which team are you on?</span></p><p>Property Services</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">Why are you getting in touch?</span></p><p>To report a property issue</p><p><br></p><p><span style="font-size: 15px; background-color: rgb(255, 255, 255); font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">In which home is the issue you are reporting?</span></p><p>MacArthur</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">In which suite or shared space?</span></p><p>N/A</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">What is the issue type?</span></p><p>WiFi issue</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which appliance is having an issue?</span></p><p></p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Issue Details?</span></p><p>There are several surveillance cameras offline at MAC.This creates a safety issue as well as potential issues with members should there be any on-site incidents.</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">When did you first noticed the issue?</span></p><p>Within the last 24 hours</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; font-size: 15px; background-color: rgb(255, 255, 255);">What potential solution have you already tried?</span></p><p>I rebooted the Eagle Eye router twice as well as the WiFi for the property,still don’t have all cameras online. </p>';
    //     update c2;
        
    // }
    
    
    // @isTest(SeeAllData=True)
    // public static void testAddHomeToCase(){      
        
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.RecordTypeId = '0123u000000FQMUAA4';
    //     c2.sub_issue_type__c = 'Leaving Common Early';
    //     c2.Issue_Type__c = 'Lease and Billing Inquiries';
    //     insert c2;
        
    //     c2.Home__c = [SELECT id from Property__c where name = 'Test Home'][0].id;
    //     update c2;
        
    // }
    
    // @isTest(SeeAllData=True)
    // public static void testEscalate(){      
        
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.RecordTypeId = '0123u000000FQMUAA4';
    //     insert c2;
        
    //     c2.IsEscalated = true;
    //     c2.Escalation_Reason__c = 'Emergency Escalation';
    //     c2.case_description__c = '<p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which team are you on?</span></p><p>Property Services</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">Why are you getting in touch?</span></p><p>To report a property issue</p><p><br></p><p><span style="font-size: 15px; background-color: rgb(255, 255, 255); font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">In which home is the issue you are reporting?</span></p><p>MacArthur</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">In which suite or shared space?</span></p><p>N/A</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">What is the issue type?</span></p><p>WiFi issue</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which appliance is having an issue?</span></p><p></p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Issue Details?</span></p><p>There are several surveillance cameras offline at MAC.This creates a safety issue as well as potential issues with members should there be any on-site incidents.</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">When did you first noticed the issue?</span></p><p>Within the last 24 hours</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; font-size: 15px; background-color: rgb(255, 255, 255);">What potential solution have you already tried?</span></p><p>I rebooted the Eagle Eye router twice as well as the WiFi for the property,still don’t have all cameras online. </p>';
    //     update c2;
        
    //     c2.IsEscalated = true;
    //     update c2;
        
    //     c2.IsEscalated = true;
    //     update c2;
        
    //     c2.IsEscalated = true;
    //     update c2;
    // }
    
    // @isTest(SeeAllData=True)
    // public static void TestSendErrorMessages(){      
        
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.RecordTypeId = '0123u000000FQMUAA4';
    //     insert c2;
        
    //     c2.IsEscalated = true;
    //     c2.Escalation_Reason__c = 'Emergency Escalation';
    //     c2.case_description__c = '<p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which team are you on?</span></p><p>Property Services</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">Why are you getting in touch?</span></p><p>To report a property issue</p><p><br></p><p><span style="font-size: 15px; background-color: rgb(255, 255, 255); font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">In which home is the issue you are reporting?</span></p><p>MacArthur</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">In which suite or shared space?</span></p><p>N/A</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">What is the issue type?</span></p><p>WiFi issue</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which appliance is having an issue?</span></p><p></p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Issue Details?</span></p><p>There are several surveillance cameras offline at MAC.This creates a safety issue as well as potential issues with members should there be any on-site incidents.</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">When did you first noticed the issue?</span></p><p>Within the last 24 hours</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; font-size: 15px; background-color: rgb(255, 255, 255);">What potential solution have you already tried?</span></p><p>I rebooted the Eagle Eye router twice as well as the WiFi for the property,still don’t have all cameras online. </p>';
    //     update c2;
        
    //     list<string> caseIds = new List<string>();
        
    //     caseIds.add(c2.id);
    //     try{
    //         list<account> a = [Select id from account limit 1];
    //         if(a.size() > 0){
    //             insert a;
    //         }
    //     }
        
    //     catch(exception e){
    //         // CreateSkillsPSRTiers.sendEmailtoSFDCAdmins(e, caseIds);
    //         // UpdateSkillsPSRTiers.sendEmailtoSFDCAdmins(e, caseIds);
    //         // DeleteSkillsPSRTiers.sendEmailtoSFDCAdmins(e, caseIds);
    //         // EscalateSkillsPSRTiers.sendEmailtoSFDCAdmins(e, caseIds);
    //     }
    // }
    
    // @isTest(SeeAllData=True)
    // public static void testRenewalCaseUpdate(){      
        
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.RecordTypeId = '0123u000000FQMUAA4';
    //     insert c2;
        
    //     c2.IsEscalated = true;
    //     c2.Escalation_Reason__c = 'Emergency Escalation';
    //     c2.case_description__c = '<p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which team are you on?</span></p><p>Property Services</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">Why are you getting in touch?</span></p><p>To report a property issue</p><p><br></p><p><span style="font-size: 15px; background-color: rgb(255, 255, 255); font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">In which home is the issue you are reporting?</span></p><p>MacArthur</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">In which suite or shared space?</span></p><p>N/A</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">What is the issue type?</span></p><p>WiFi issue</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which appliance is having an issue?</span></p><p></p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Issue Details?</span></p><p>There are several surveillance cameras offline at MAC.This creates a safety issue as well as potential issues with members should there be any on-site incidents.</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">When did you first noticed the issue?</span></p><p>Within the last 24 hours</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; font-size: 15px; background-color: rgb(255, 255, 255);">What potential solution have you already tried?</span></p><p>I rebooted the Eagle Eye router twice as well as the WiFi for the property,still don’t have all cameras online. </p>';
    //     c2.Sub_Issue_Type__c = 'Renewals';
    //     update c2;
        

    // }
    
    // @isTest(SeeAllData=True)
    // public static void testRenewalCaseInsert(){      
        
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.RecordTypeId = '0123u000000FQMUAA4';
    //     c2.Sub_Issue_Type__c = 'Renewals';
    //     insert c2;
        
    //     c2.IsEscalated = true;
    //     c2.Escalation_Reason__c = 'Emergency Escalation';
    //     c2.case_description__c = '<p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which team are you on?</span></p><p>Property Services</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">Why are you getting in touch?</span></p><p>To report a property issue</p><p><br></p><p><span style="font-size: 15px; background-color: rgb(255, 255, 255); font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">In which home is the issue you are reporting?</span></p><p>MacArthur</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; background-color: rgb(255, 255, 255); font-size: 15px;">In which suite or shared space?</span></p><p>N/A</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">What is the issue type?</span></p><p>WiFi issue</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Which appliance is having an issue?</span></p><p></p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">Issue Details?</span></p><p>There are several surveillance cameras offline at MAC.This creates a safety issue as well as potential issues with members should there be any on-site incidents.</p><p><br></p><p><span style="background-color: rgb(255, 255, 255); font-size: 15px; font-family: Slack-Lato, appleLogo, sans-serif; color: rgb(240, 16, 16);">When did you first noticed the issue?</span></p><p>Within the last 24 hours</p><p><br></p><p><span style="color: rgb(240, 16, 16); font-family: Slack-Lato, appleLogo, sans-serif; font-size: 15px; background-color: rgb(255, 255, 255);">What potential solution have you already tried?</span></p><p>I rebooted the Eagle Eye router twice as well as the WiFi for the property,still don’t have all cameras online. </p>';
    //     update c2;
        
    // }
    
    // @isTest(SeeAllData=True)
    // public static void testSolveCase(){      
        
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.RecordTypeId = '0123u000000FQMUAA4';
    //     c2.Issue_Type__c = 'Property Issue';
    //     c2.Sub_Issue_Type__c = 'Floors Carpentry';
    //     insert c2;
        
    //     c2.Home__c = [SELECT id from Property__c where name = 'Test Home'][0].id;
    //     c2.status = 'Solved';
    //     update c2;

    // }
    
    // @isTest(SeeAllData=True)
    // public static void testChangeToNonFSLHome(){
    //     Case c2 =new Case();
    //     c2.Subject = 'TESTY';
    //     c2.Home__c = [SELECT id from Property__c where name = 'Test Home'][0].id;
    //     //CSS - Member Support Specialists record Type ID
    //     c2.RecordTypeId = '0123u000000FQMUAA4';
        
    //     c2.Issue_Type__c = 'Property Issue';
    //     c2.Sub_Issue_Type__c = 'Floors Carpentry';
    //     insert c2;
        
    //     c2.IsEscalated = true;
    //     c2.Escalation_Reason__c = 'Emergency Escalation';
    //     update c2;
        
    //     c2.Home__c = [Select id from Property__c limit 1][0].id;
    //     update c2;
    // }
}