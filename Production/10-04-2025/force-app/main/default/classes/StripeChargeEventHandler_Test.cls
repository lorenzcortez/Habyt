@IsTest
public with sharing class StripeChargeEventHandler_Test {
    public static final String EXPECTED_INTENT_ID = 'pi_3KVwCpI4AG1fjzDf0CLiGdNF';

    @TestSetup
    static void setupTest() {
        Invoice__c invoice = new Invoice__c(
            Stripe_Invoice_Id__c = StripeEventHandler_Test.INVOICE_TEST_ID,
            Name = StripeEventHandler_Test.INVOICE_TEST_NAME,
            PaymentStatus__c = StripeChargeEventHandler.INVOICE_SUCCESS_STATUS
        );
        insert invoice;

        Account account = TestRecord_Factory.iAccount;
        Room__c room = TestRecord_Factory.iRoom;
        Opportunity opp = TestRecord_Factory.iOpportunity;
        Stripe_Account__c stripeAcc = TestRecord_Factory.iStripe_Account;

        Contract contract = TestRecord_Factory.createContract(account.Id, opp.Id, room.Id, stripeAcc.Id);
        insert contract;

        PaymentIntent__c intent = new PaymentIntent__c(
                StripeId__c = EXPECTED_INTENT_ID,
                Invoice__c = invoice.Id
        );
        insert intent;
    }

    @IsTest
    public static void handle_old_UnitTest() {
        Date expectedDate = System.today();
        Invoice__c invoice = [SELECT Stripe_Invoice_Id__c FROM Invoice__c LIMIT 1];
        String eventData = '{"id":"evt_1CiPtv2eZvKYlo2CcUZsDcO6","object":"event","created": 1648033251,' +
                            '"data":{"object":{"id":"' + invoice.Stripe_Invoice_Id__c + '","status":"' + 
                            StripeChargeEventHandler.INVOICE_SUCCESS_STATUS + '"}},' + '"type": "charge.update"}';


        Test.startTest();
        new StripeChargeEventHandler().handle(eventData);
        Test.stopTest();

        invoice = [SELECT PaymentDate__c FROM Invoice__c LIMIT 1];

        System.assertEquals(expectedDate, invoice.PaymentDate__c, 'Date unexpected');
    }

    @IsTest
    public static void handleRefund_UnitTest() {
        String expectedStatus = 'succeeded';
        String expectedCurrency = 'EUR';
        List<String> stripeIds = new List<String> {'rf_id1', 'rf_id2'};
        Decimal expectedAmount = 123;
        Integer expectedSize = 2;
        String expectedReason = 'fraudulent';

        String eventData =
                '{' +
                '  "id": "evt_3KVwCpI4AG1fjzDf0oIyhy4v",' +
                '  "object": "event",' +
                '  "created": 1645528043,' +
                '  "data": {' +
                '    "object": {' +
                '      "id": "ch_3KVwCpI4AG1fjzDf07Q67zDz",' +
                '      "refunds": {' +
                '        "object": "list",' +
                '        "data": [' +
                '          {' +
                '            "id": "' + stripeIds.get(0) + '",' +
                '            "object": "refund",' +
                '            "amount": 12300,' +
                '            "created": 1645528043,' +
                '            "currency": "' + expectedCurrency + '",' +
                '            "payment_intent": "' + EXPECTED_INTENT_ID + '",' +
                '            "reason": "' + expectedReason + '",' +
                '            "receipt_number": null,' +
                '            "status": "' + expectedStatus + '"' +
                '          },' +
                '          {' +
                '            "id": "' + stripeIds.get(1) + '",' +
                '            "object": "refund",' +
                '            "amount": 12300,' +
                '            "created": 1645528043,' +
                '            "currency": "' + expectedCurrency + '",' +
                '            "payment_intent": "' + EXPECTED_INTENT_ID + '",' +
                '            "reason": "' + expectedReason + '",' +
                '            "receipt_number": null,' +
                '            "status": "' + expectedStatus + '"' +
                '          }' +
                '        ]' +
                '      }' +
                '    }' +
                '  },' +
                '  "type": "charge.refunded"\n' +
                '}';

        Test.startTest();
        new StripeChargeEventHandler().handle(eventData);
        Test.stopTest();

        List<Refund__c> refunds = [
                SELECT Id, Amount__c, Status__c, Currency__c, PaymentIntent__c, Invoice__c, ReceiptNumber__c, Reason__c,
                       StripeRefundId__c
                FROM Refund__c
        ];

        List<PaymentIntent__c> intents = [SELECT Id, StripeId__c FROM PaymentIntent__c];
        Set<Id> intentsIds = (new Map<Id,SObject>(intents)).keySet();

        System.assertEquals(expectedSize, refunds.size());

        for(Refund__c refund : refunds) {
            System.assertNotEquals(null, refund.Invoice__c);
            System.assert(intentsIds.contains(refund.PaymentIntent__c));
            System.assertEquals(expectedStatus, refund.Status__c);
            System.assertEquals(expectedAmount, refund.Amount__c);
            System.assertEquals(expectedCurrency, refund.Currency__c);
            System.assert(stripeIds.contains(refund.StripeRefundId__c));
            System.assertEquals(expectedReason, refund.Reason__c);
        }
    }

    @IsTest
    public static void handleDisputes_UnitTest() {
        String expectedStatus = 'succeeded';
        String expectedChargeId = 'ch_3KYSQrI4AG1fjzDf06D9gsIK';
        String expectedId = 'dp_1KYSQsI4AG1fjzDfl22fDudv';

        String eventData = '{' +
                '"id": "evt_1KYSQtI4AG1fjzDfgehXxtjJ",' +
                '"object": "event",'+
                '"created": 1646128550,' +
                '"data": {' +
                    '"object": {' +
                        '"id": "' + expectedId + '",' +
                        '"object": "dispute",' +
                        '"amount": 1200,' +
                        '"charge": "' + expectedChargeId + '",' +
                        '"created": 1646128550,' +
                        '"payment_intent": "' + EXPECTED_INTENT_ID + '",' +
                        '"status": "' + expectedStatus + '"' +
                    '}'+
                '},'+
                '"type": "charge.dispute.created"'+
        '}';

        Test.startTest();
        new StripeChargeEventHandler().handle(eventData);
        Test.stopTest();

        Dispute__c dispute = [
            SELECT Id, ChargeId__c, Invoice__c, PaymentIntent__c, Status__c, StripeDisputeId__c, 
                   PaymentIntent__r.StripeId__c
            FROM Dispute__c
            LIMIT 1
        ];

        System.assertNotEquals(null, dispute.Invoice__c);
        System.assertEquals(expectedStatus, dispute.Status__c);
        System.assertEquals(expectedChargeId, dispute.ChargeId__c);
        System.assertEquals(expectedId, dispute.StripeDisputeId__c);
        System.assertEquals(EXPECTED_INTENT_ID, dispute.PaymentIntent__r.StripeId__c);
    }
}