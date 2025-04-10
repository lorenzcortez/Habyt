@isTest
private class CreateInternalInvoiceControllerTest {
    
    @isTest
    static void testCreateInvoice() {

        Stripe_Account__c stripeAccount = new Stripe_Account__c(secret_key__c = 'test_key');
        insert stripeAccount;

        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        City__c c = new City__c();
        c.Name = 'Seattle';
        insert c;
        
        Brand__c br = new Brand__c(
            Name = 'Test Brand',
            APINameBrand__c = 'Test Brand API'
        );
        insert br;
        
        Property__c prop = new Property__c();
        prop.Name = 'test';
        prop.City_object__c = c.id;
        prop.Home_Manager_User__c = userinfo.getUserId();
        prop.BrandRef__c = br.Id;
        insert prop;

        Contract con = new Contract(
            AccountId = acc.Id,
            Status = 'Draft',
            StartDate = Date.today(),
            Property__c = prop.Id,
            ContractTerm = 6,
            Stripe_Subscription_Id__c = 'sub_TEST',
            Stripe_Account__c = stripeAccount.Id
        );
        insert con;
         

        // Create JSON body
        String jsonBody = JSON.serialize(new Map<String, Object>{
            'invoiceType' => 'Deposit',
            'billingMonth' => 'January',
            'billingYear' => '2025',
            'billingMethod' => 'send_invoice',
            'dueDate' => String.valueOf(Date.today().addDays(10)),
            'lineItems' => new List<Object>{
                new Map<String, Object>{
                    'amount' => 100.50,
                    'description' => 'Test Line Item 1'
                },
                new Map<String, Object>{
                    'amount' => 250.00,
                    'description' => 'Test Line Item 2'
                }
            }
        });

        List<Contract> contracts = [SELECT Id,  Property__c FROM Contract WHERE Id =: con.Id ];
        System.debug('contracts contracts contracts' + contracts);

        Test.startTest();
        CreateInternalInvoiceController.createInvoice(con.Id, jsonBody);
        Test.stopTest();
    }
}