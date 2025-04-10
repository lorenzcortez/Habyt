@IsTest
public class GenerateStripeDiscountBatchTest {
  @TestSetup
  static void makeData() {
    Account testAcc = new Account(
      Name = 'Test Acc',
      Stripe_Customer_Id__c = 'cu_87234827364'
    );
    insert testAcc;

    Stripe_Account__c stripeAcc = new Stripe_Account__c(
      secret_key__c = 'kiu23h4kjbe2doiu23br'
    );
    insert stripeAcc;

    Product2 prod_one_off = new Product2(
      Name = 'One off Prod',
      FrequencyPick__c = 'One Off',
      RecordTypeId = GenerateStripeDiscountBatch.PRODUCT_ADD_ITEM_RT
    );
    insert prod_one_off;

    Product2 prod_recurring = new Product2(
      Name = 'Recurring Prod',
      FrequencyPick__c = 'Recurring',
      RecordTypeId = GenerateStripeDiscountBatch.PRODUCT_ADD_ITEM_RT
    );
    insert prod_recurring;

    Contract contract_1 = new Contract(
      AccountId = testAcc.Id,
      StripeCustomerId__c       = 'teste',
      Stripe_Subscription_Id__c = 'su_h23g4dewd23d2wd23r',
      Stripe_Account__c = stripeAcc.Id,
      Contract_End_Date__c = Date.today().addMonths(3),
      StartDate = Date.today().addDays(1),
      EverSign_Doc_Status__c = 'Completed',
      Community_Step__c = 1,
      CurrencyIsoCode = 'EUR'
    );
    insert contract_1;

    contract_1.Status = 'Activated';
    update contract_1;

    ContractItem__c ci_recurring_1 = new ContractItem__c(
      NumberOfMonths__c = 1,
      PriceTrig__c = 99,
      ContractRef__c = contract_1.Id,
      ProductRef__c = prod_recurring.Id,
      Description__c = 'ci_recurring_1 test',
      CurrencyIsoCode = contract_1.CurrencyIsoCode
    );
    insert ci_recurring_1;

    System.debug([SELECT Id, Status FROM Contract]);
    System.debug(
      [
        SELECT
          Id,
          IsSyncableItemAuto__c,
          TimesRedeemed__c,
          NumberOfMonths__c,
          ProductRef__r.FrequencyPick__c,
          LastSuccessfulSync__c,
          ProductRecordTypeAuto__c,
          CurrencyIsoCode
        FROM ContractItem__c
      ]
    );
  }

  @IsTest
  static void syncItems_RegularTest() {
    String invoiceItemId = 'ii_1KVzevI4AG1fjzDfH9Z3GIxA';

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, new StripeHttpMockResponse());

    Database.executeBatch(new GenerateStripeDiscountBatch(), 1);
    List<ContractItem__c> lst_ci_recurring_1 = [
      SELECT Id, StripeInvoiceItemId__c, TimesRedeemed__c, LastSuccessfulSync__c,
      CurrencyIsoCode
      FROM ContractItem__c
      WHERE Description__c = 'ci_recurring_1 test'
      LIMIT 1
    ];
  }

  @IsTest
  static void testScheduling() {
    Test.startTest();
    System.schedule(
      'TestJobScheduleDiscount',
      '0 0 * * * ?',
      new GenerateStripeDiscountBatch()
    );
    Test.stopTest();
  }
}