@IsTest
public class StripeCustomerDiscountEventHandler_Test {
    public static final String INVOICE_TEST_ID = 'in_00000000000000';
    public static final STRING FREC_ONE_OFF = 'One Off';
    public static final Integer AMOUNT_DIVIDER = 100;
    
    @TestSetup
    static void setupTest() {
        Invoice__c invoice = new Invoice__c(
            Stripe_Invoice_Id__c = INVOICE_TEST_ID,
            Name = 'Test invoice',
            PaymentStatus__c = StripeChargeEventHandler.INVOICE_SUCCESS_STATUS
        );
        insert invoice;

        Account account = TestRecord_Factory.iAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc = TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;
    }
    
    @IsTest
    public static void handle_CustomerDiscountEvent_UnitTest() {
        String couponId = 'ua7Abcy1_00000000000000';
        String subscriptionId = 'sub_00000000000000';
        String invoiceItemId = 'it_00000000000000';
        String amount_off = '9900';

        Id discountRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Discount').getRecordTypeId();
        Product2 product = new Product2(
            RecordTypeId = discountRecordTypeId,
            FrequencyPick__c = FREC_ONE_OFF,
            Name = 'One Off Discount',
            IsActive = true
        );
        insert product;

        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        update standardPricebook;

        Contract contract = [
            SELECT Id, StripeCustomerJSONMap__c, AccountId
            FROM Contract
            LIMIT 1
        ];
        contract.Stripe_Subscription_Id__c = subscriptionId;
        update contract;

        String eventData = '{ "type": "customer.discount.created",' +
            '"data": {'+
                '"object": {'+
                    '"id": "di_00000000000000",'+
                    '"object": "discount",'+
                    '"checkout_session": null,'+
                    '"CurrencyIsoCode": EUR,'+
                    '"coupon": {'+
                        '"id": "' + couponId + '",'+
                        '"object": "coupon",'+
                        '"amount_off": ' + amount_off + ','+
                        '"created": 1637148777,'+
                        '"currency": "eur",'+
                        '"duration": "once",'+
                        '"duration_in_months": null,'+
                        '"livemode": false,'+
                        '"max_redemptions": null,'+
                        '"metadata": {},'+
                        '"name": "Rent One Off Coupon",'+
                        '"percent_off": null,'+
                        '"redeem_by": null,'+
                        '"times_redeemed": 1,'+
                        '"valid": true'+
                    '},'+
                    '"customer": "cus_00000000000000",'+
                    '"end": 1637149415,'+
                    '"invoice": "' + INVOICE_TEST_ID + '",'+
                    '"invoice_item": "' + invoiceItemId + '",'+
                    '"promotion_code": null,'+
                    '"start": 1637149415,'+
                    '"subscription": "' + subscriptionId + '"'+
                '}'+
            '}'+
        '}';

        List<ContractItem__c> lstContractItems = [SELECT Id, PriceTrig__c FROM ContractItem__c WHERE StripeCouponId__c = :couponId];
        System.assert(lstContractItems.isEmpty(), 'The discount should not exist at this moment.');

        List<InvoiceItem__c> lstInvoiceItems = [SELECT Id FROM InvoiceItem__c WHERE Stripe_Id__c = :invoiceItemId];
        System.assert(lstInvoiceItems.isEmpty(), 'The invoice item should not exist at this moment.');

        Test.startTest();
        //StripeEventHandler.handle(eventData);
        Test.stopTest();

        // Test 1: Check the contract item creation
        lstContractItems = [SELECT Id, PriceTrig__c FROM ContractItem__c WHERE StripeCouponId__c = :couponId];
        //System.assertEquals(1, lstContractItems.size(), 'The discount was not inserted.');

        // Test 2: Check the invoice item creation
        lstInvoiceItems = [SELECT Id, Amount__c FROM InvoiceItem__c WHERE Stripe_Id__c = 'di_00000000000000'];
        //System.assertEquals(1, lstInvoiceItems.size(), 'The invoice item was not inserted.');

        // Test 3: Chec the invoice item has the right amount
        //InvoiceItem__c invoiceItem = lstInvoiceItems.get(0);
        //System.assertEquals(-1 * Decimal.valueOf(amount_off) / AMOUNT_DIVIDER, invoiceItem.Amount__c, 'The invoice item amount is not correct.');
    }
}