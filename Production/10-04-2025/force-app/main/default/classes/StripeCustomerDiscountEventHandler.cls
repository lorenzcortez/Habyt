public class StripeCustomerDiscountEventHandler extends StripeAbstractEventHandler {

    public static final Decimal AMOUNT_DIVIDER = -100;

    public static final String EVENT_TYPE_CREATED = 'created';
    public static final String EVENT_TYPE_UPDATED = 'updated';
    public static final String EVENT_TYPE_DELETED = 'deleted';

    // Values from Stripe
    public static final String COUPON_DURATION_FOREVER = 'forever';
    public static final String COUPON_DURATION_ONCE = 'once';
    public static final String COUPON_DURATION_REPEATING = 'repeating';

    public static final String PRODUCT_FREQUENCY_ONE_OFF = 'One Off';
    public static final String PRODUCT_FREQUENCY_RECURRING = 'Recurring';

    // Duration is used in Stripe while in this Org is user Frequency
    private static final Map<String, String> MAP_DURATION_TO_FREQUENCY = new Map<String, String>{
        COUPON_DURATION_FOREVER => PRODUCT_FREQUENCY_RECURRING, 
        COUPON_DURATION_ONCE => PRODUCT_FREQUENCY_ONE_OFF,
        COUPON_DURATION_REPEATING => PRODUCT_FREQUENCY_RECURRING
    };

    public static final String DATE_UNIX_TAIL = '000';

    /**
     * This method handles the stripe webhook message. This method is called dynamically from the StripeEventHandler, 
     * that dynamically determinates based on webhook type what handler should be instantiated.
     * 
     * This method and class handles the Customer Discount Payload and uses StripeModels.DiscountEventData for json parsing.
     * 
     * @param eventData     JSON as string from the stripe webhook
     */
    public override void handle(String eventData){
        eventData = preProcessJson(eventData);
        String eventType = getEventType(eventData);
        String dataObjectString = parseToEventDataString(eventData);
        StripeModels.DiscountEventData discountData = (StripeModels.DiscountEventData) JSON.deserialize(
            dataObjectString, StripeModels.DiscountEventData.class
        );

        if (eventType == EVENT_TYPE_CREATED) {
            upsertDiscount(discountData);
            upsertInvoiceItem(discountData);
        }
    }

    /**
     * upsertInvoiceItem: Upsert an Invoice Item given a Stripe Discount payload
     *
     * @param discountData (DiscountEventData): Payload of Discount event from Stripe
     * 
     */
    private void upsertInvoiceItem(StripeModels.DiscountEventData discountData) {
        InvoiceItem__c item = new InvoiceItem__c(
            Invoice__r = new Invoice__c(Stripe_Invoice_Id__c = discountData.invoice),
            Description__c = discountData?.coupon?.name,
            Stripe_Id__c = discountData.id,
            Amount__c = Decimal.valueOf(discountData.coupon.amount_off) / AMOUNT_DIVIDER,
            StripeCustomerId__c = discountData.customer,
            Currency__c = discountData.coupon.currency_x.toUpperCase()
        );
        if (discountData.start != null) {
            item.PeriodStart__c = Date.valueOf(DateTime.newInstance(Long.valueOf(discountData.start + DATE_UNIX_TAIL)));
        }
        if (discountData.end_x != null) {
            item.PeriodEnd__c = Date.valueOf(DateTime.newInstance(Long.valueOf(discountData.end_x + DATE_UNIX_TAIL)));
        }
        upsert item Stripe_Id__c;
    }

    /**
     * upsertDiscount: Upsert a Contract Item and relates it to the Contract
     *                 based on the subscription Id, given an Stripe Discount payload
     *
     * @param discountData (DiscountEventData): Payload of Discount event from Stripe
     *
     *
     * @throws HandledException
     */
    private void upsertDiscount(StripeModels.DiscountEventData discountData){
        if (String.isBlank(discountData.subscription)) {
            throw new HandledException('No subscription Id on the payload.');
        }
        
        // Get contract to insert the discount
        Contract contract = searchForContract(discountData.subscription);
        if (contract == null) {
            throw new HandledException('Any contract match the subscription Id on the payload.');
        }

        // Check if discount (ContracItem) already exist
        ContractItem__c discount = fetchDiscountByCouponId(discountData.coupon.id);
        if (discount != null) {
            // TODO: Update only if it is not recurrent - forever to keep tracking of how many times it has been used
        } else {
            // Create new discount
            discount = createDiscount(discountData, contract.Id);
        }
        upsert discount;
    }

    /**
     * fetchDiscountByCouponId: Fetch a Contract Item given the Stripe Coupon Id
     *
     * @param couponId (String): The stripe coupon Id
     *
     * @return ContractItem__c: The contract element or NULL otherwise
     */
    private ContractItem__c fetchDiscountByCouponId(String couponId) {
        ContractItem__c discount;
        List<ContractItem__c> lstContractItems = [SELECT Id, StripeCouponId__c FROM ContractItem__c WHERE StripeCouponId__c = :couponId];
        if (!lstContractItems.isEmpty()) {
            discount = lstContractItems.get(0);
        }
        return discount;
    }

    /**
     * createDiscount: Create Contract Item given an Stripe Discount payload and the Contract Id
     *
     * @param discountData (DiscountEventData): The discount data from Stripe
     * @param contractId (Id): The subscription Id from Stripe
     *
     * @return ContractItem__c: The discount
     *
     * @throws HandledException
     */
    private ContractItem__c createDiscount(StripeModels.DiscountEventData discountData, Id contractId) {
        // Get Product
        Product2 discountProduct = searchForProduct(discountData.coupon.duration);
        if (discountProduct == null) {
            throw new HandledException('Default Product2 with frecuency: ' + discountData.coupon.duration + ', not found.');
        }

        ContractItem__c discount = new ContractItem__c (
            ContractRef__c = contractId,
            StripeCouponId__c = discountData.coupon.id,
            ProductRef__c = discountProduct.Id,
            PriceTrig__c = Decimal.valueOf(discountData.coupon.amount_off) / AMOUNT_DIVIDER,
            TimesRedeemed__c = Integer.valueOf(discountData.coupon.times_redeemed)
        );
        
        return discount;
    }

    /**
     * searchForProduct: Search for a Product2 based on the frecuency
     *
     * @param frecuency (String): Product2 frecuency
     *
     * @return Product2: The product or NULL
     */
    private Product2 searchForProduct(String frecuency) {
        List<Product2> searchList = findDiscountProductsByFrecuency(frecuency);
        return searchList.size() > 0 ? searchList.get(0) : null;
    }

    /**
     * findDiscountProductsByFrecuency: Search all Product2 based on the frecuency
     *
     * @param frecuency (String): Product2 frecuency
     *
     * @return List<Product2>: The list with the Products or an empty list
     *
     * @throws HandledException
     */
    private List<Product2> findDiscountProductsByFrecuency(String frecuency){  
        List<Pricebook2> PriceBookList = [Select Id From Pricebook2 WHERE isStandard = true LIMIT 1];
        
        Id discountRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Discount').getRecordTypeId();
        if (discountRecordTypeId == null) {
            throw new HandledException('Default Product2 with record type: Discount, not found.');
        }

        List<Product2> products = (List<Product2>) Paua_SelectorHandler.getSelector(Product2Selectors.ProductsByFrecuencyAndRecordType.class)
            .setParameter('frequency', MAP_DURATION_TO_FREQUENCY.get(frecuency))
            .setParameter('recordTypeId', discountRecordTypeId)
            .setParameter('pricebookId', PriceBookList.get(0).Id)
            .query();

        return products;
    }

    /**
     * searchForContract: Search for a contract based on the Stripe subscription Id
     *
     * @param frecuency (String): Stripe subscription Id
     *
     * @return Contract: The contract or NULL
     */
    private Contract searchForContract(String subscriptionId) {
        List<Contract> searchList = findContractsBySubscriptionId(subscriptionId);
        return searchList.size() > 0 ? searchList.get(0) : null;
    }

    /**
     * findContractsBySubscriptionId: Search all contract based on the Stripe subscription Id
     *
     * @param frecuency (String): The Stripe subscription Id
     *
     * @return List<Contract>: The list with the contracts or an empty list
     */
    private List<Contract> findContractsBySubscriptionId(String subscriptionId){    
        List<Contract> contracts = (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.BySubscriptionId.class)
            .setParameter('subscriptionId', subscriptionId)
            .query();

        return contracts;
    }  

    /**
     * getEventType: Get the event type from a Stripe Event
     *
     * @param eventData (String): The Stripe Event
     *
     * @return String: the event or NULL
     */
    private String getEventType(String eventData) {
        Map<String, Object> event = (Map<String, Object>) JSON.deserializeUntyped(eventData);
		String eventType = String.valueOf(event.get('type'));
        String[] eventTypeParts = eventType?.split('\\.');
        String result;

        if(eventTypeParts != null && eventTypeParts.size() > 0) {
            result = eventTypeParts[eventTypeParts.size() - 1];
        }

        return result;
    }
}