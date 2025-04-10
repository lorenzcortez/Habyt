@IsTest
private class StripeService_Test {
    public static final String KEY = 'test_id_123'; // from StripeHttpMockResponse

    @TestSetup
    static void testSetup() {
    }

    @IsTest
    static void createPlan_UnitTest() {
        StripeModels.Plan stripePlan = new StripeModels.Plan();
        //stripePlan.oneOffDiscount = 0;
        stripePlan.amount = 100;
        stripePlan.contractNumber = '123';
        stripePlan.secretKey = '123';

        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();
        String keyId = StripeService.createPlan(stripePlan);
        Test.stopTest();

        System.assertEquals(KEY, keyId, 'Unexpected id key');
    }

    @IsTest
    static void upsertGetCreateSubscription_UnitTest() {
        String dummyString = 'string';

        StripeModels.Subscription subscription = new StripeModels.Subscription();
        subscription.customerId = dummyString;
        subscription.secretKey = dummyString;
        subscription.planId = dummyString;
        subscription.status = dummyString;
        subscription.startDate = Date.today();

        StripeModels.Coupon coupon = new StripeModels.Coupon();
        coupon.id = 'Test';
        coupon.object_x = 'Test';
        coupon.amount_off = '40';
        coupon.created = String.valueOf(Date.today());
        coupon.currency_x = 'Test';
        coupon.duration = 'Test';
        coupon.livemode = 'Test';
        coupon.max_redemptions = 'Test';
        coupon.name = 'Test';
        coupon.percent_off = 'Test';
        coupon.redeem_by = 'Test';
        coupon.times_redeemed = String.valueOf(Date.today());
        coupon.valid = 'Test';

        StripeModels.InvoiceItem invoiceItem = new StripeModels.InvoiceItem('Test', '10', 'Test', 'Test', 'USD');

        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();
        StripeModels.Subscription upsertResult = StripeService.upsertSubscription(subscription);
        StripeModels.Subscription getResult = StripeService.getSubscription(subscription);
        StripeService.createSubscription(subscription);
        StripeService.createCoupon(coupon, 'Secret');
        StripeService.createInvoiceItem(invoiceItem, 'Secret');
        StripeService.getInvoiceItemsRelatedToAnInvoice('Test', 'Secret');
        StripeService.deleteInStripe('delete', '1245', 'Secret');
        Test.stopTest();

        System.assertEquals(KEY, upsertResult.id, 'Unexpected subscription id');
        System.assertEquals(KEY, getResult.id, 'Unexpected subscription id');
    }

    @IsTest
    static void createInvoice_Exists_UnitTest() {
        String customerId = 'cus_io1zvbi';
        String contractId = 'con_jbizb1'; // taken from StripeHttpMockResponse.getInvoiceArrayResponse();
        String description = 'It is a test invoice'; // taken from StripeHttpMockResponse.getInvoiceArrayResponse();

        StripeModels.Invoice invoice = new StripeModels.Invoice();
        invoice.customerId = customerId;
        invoice.description = description;
        invoice.amount = 100;
        invoice.mdt_ContractId = contractid;

        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();
        StripeService.createInvoice(invoice);
        Test.stopTest();
    }

    @IsTest
    static void createInvoice_DontExists_UnitTest() {
        String customerId = 'cus_io1zvbi';

        StripeModels.Invoice invoice = new StripeModels.Invoice();
        invoice.customerId = customerId;
        invoice.amount = 100;

        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();
        StripeService.createInvoice(invoice);
        Test.stopTest();
    }

    @IsTest
    static void postAndGetStripe_UnitTest() {
        String requestType = 'plans';
        String payload = 'TestPayload';
        String key = 'Test key';
        String expectedId = 'test_id_123';

        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();
        String postResponse = StripeService.postToStripe(requestType, payload, key);
        String getResponse = StripeService.getFromStripe(requestType, payload, key);
        Test.stopTest();

        System.assert(postResponse.contains(expectedId));
        System.assert(getResponse.contains(expectedId));
    }

    @IsTest
    static void checkResponse_UnitTest() {
        Map<String, String> errorMap = new Map<String, String> {'message' => 'Test Error Message'};
        Map<String, Object> responseMap = new Map<String, Object>{'error' => errorMap};

        Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());
        Test.startTest();
        try {
            StripeService.CheckResponse(responseMap, new HttpRequest());
            System.assert(false, 'Exception is not thrown.');
        } catch (StripeService.StripeErrorException e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @IsTest
    static void sendStripeErrors_UnitTest() {
        String message = 'Test Message';
        Integer expectedEmailsSent = 1;

        Test.startTest();
        StripeService.sendStripeErrors(message);

        Integer actualEmailsSent = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(expectedEmailsSent, actualEmailsSent, 'Unexpected number of emails were sent.');
    }
}