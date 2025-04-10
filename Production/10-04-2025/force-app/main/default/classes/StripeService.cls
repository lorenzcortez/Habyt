public without sharing class StripeService { 

    public static final STRING KEY_ID = 'id';
    public static final STRING KEY_STATUS = 'status';

    public static final String DURATION_REPEATING = 'repeating';
    public static final String DURATION_FOREVER = 'forever';
    public static final String DURATION_ONCE = 'once';

    public static final String DATA = 'data'; 

    private static String API_URL = 'https://api.stripe.com/v1/';
  
    public static final String REQ_TYPE_INVOICE_ITEMS = 'invoiceitems';

    public static String createPlan(StripeModels.Plan stripePlan){
        // Generate payload
        String payload = 'interval=month&currency=eur';
        payload += '&amount=' + stripePlan.amount;
        payload += '&product[name]=' + stripePlan.contractNumber;
        payload += '&currency=' + stripePlan.currencyIsoCode;

        Map<String, Object> plan = (Map<String, Object>)JSON.deserializeUntyped(postToStripe('plans', payload, stripePlan.secretKey));

        return (String)plan.get(KEY_ID);
    }

    /**
     * upsertSubscription Update or insert a subscription, depending on if it exists on Stripe or not
     *
     */
    public static StripeModels.Subscription upsertSubscription(StripeModels.Subscription inputSub){
        StripeModels.Subscription subscription = getSubscription(inputSub);
        
        if (subscription.Id == null) {
            subscription = createSubscription(inputSub);
        }
        return subscription;
    }

    /**
     * getSubscription Retrieves the subscription with the given Customer Id and Plan Id
     * 
     */
    public static StripeModels.Subscription getSubscription(StripeModels.Subscription subscription){
        String parameters = 'customer=' + subscription.customerId;
        parameters += '&plan=' + subscription.planId;

        StripeModels.SubscriptionResponse response = (StripeModels.SubscriptionResponse) JSON.deserialize(
            getFromStripe('subscriptions', parameters, subscription.secretKey), 
            StripeModels.SubscriptionResponse.class
        ); 

        // Check if the subscription already exist in Stripe
        if (!response.data.isEmpty()) {
            subscription.id = response.data[0].id;
            subscription.status = response.data[0].status;
            System.debug('+++ Subscription found in Stripe: ' + subscription);
        }

        return subscription;
    }

    /**
     * createSubscription Creates a new subscription on an existing customer
     * Each customer can have up to 500 active or scheduled subscriptions
     *
     */
    public static StripeModels.Subscription createSubscription(StripeModels.Subscription subscription){
        
        DateTime startDateTime = DateTime.newInstanceGmt(subscription.startDate.year(), subscription.startDate.month(), subscription.startDate.day());
        System.debug('startDateTime' + startDateTime);
        DateTime billingCycleAnchorDate;
        Long startDatetimestamp = startDateTime.getTime() / 1000; // Pass from milliseconds to seconds
        Long billingCycleAnchorTimestamp;
        String payload = 'customer=' + subscription.customerId + '&items[0][plan]=' + subscription.planId;

        if (startDateTime > datetime.now()){
            payload += '&trial_end=' + startDatetimestamp;
            billingCycleAnchorDate = subscription.startDate.addMonths(1).toStartOfMonth();
        } else{
            billingCycleAnchorDate = Date.today().addMonths(1).toStartOfMonth();
        }

        if (String.isNotEmpty(subscription.coupon)) {
            payload += '&coupon=' + subscription.coupon;
        }

        DateTime billingCycleAnchorDateUTC = Datetime.newInstanceGmt(billingCycleAnchorDate.year(), billingCycleAnchorDate.month(), billingCycleAnchorDate.day(), billingCycleAnchorDate.hour(), billingCycleAnchorDate.minute(), billingCycleAnchorDate.second());
        System.debug('billingCycleAnchorDateUTC' + billingCycleAnchorDateUTC);
        billingCycleAnchorTimestamp = billingCycleAnchorDateUTC.getTime() / 1000;
        payload += '&billing_cycle_anchor=' + billingCycleAnchorTimestamp;
        payload += '&payment_behavior=allow_incomplete';
        Map<String, Object> stripeSubResponse = (Map<String, Object>)JSON.deserializeUntyped(
            postToStripe('subscriptions', payload, subscription.secretKey)
        );
        
        subscription.id = (String) stripeSubResponse.get(KEY_ID);
        subscription.status = (String) stripeSubResponse.get(KEY_STATUS);
        return subscription;
    }

    /**
     * createCoupon Creates a Coupon in Stripe
     *
     * @param coupon (Coupon): The coupon data
     * @param secretKey (String): The secret key
     *
     * @return String: Coupon Id
     */
    public static String createCoupon(StripeModels.Coupon coupon, String secretKey){
        String payload = 'currency=eur';
        payload += '&amount_off=' + Integer.valueOf(Double.valueOf(coupon.amount_off) * 100);
        payload += '&duration=' + coupon.duration;
        if (coupon.duration == DURATION_REPEATING) {
            payload += '&duration_in_months=' + coupon.duration_in_months;
        }

        Map<String, Object> stripeCoupon = (Map<String, Object>)JSON.deserializeUntyped(
            postToStripe('coupons', payload, secretKey)
        );
        return (String)stripeCoupon.get(KEY_ID);
    }

    /**
     * createInvoiceItem Creates an InvoiceItem in Stripe
     *
     * @param invoiceItem (StripeModels.InvoiceItem): The invoice item data
     * @param secretKey (String): The secret key
     *
     * @return String: The InvoiceItem Id
     */
    public static String createInvoiceItem(StripeModels.InvoiceItem invoiceItem, String secretKey){
        String req_type = Test.isRunningTest() ? REQ_TYPE_INVOICE_ITEMS + '_test' : REQ_TYPE_INVOICE_ITEMS;
        String currency_x = String.isEmpty(invoiceItem.currencyIsoCode) ? 'eur' : invoiceItem.currencyIsoCode;
        String payload = 'currency=' + currency_x;
        payload += '&amount=' + Integer.valueOf(Double.valueOf(invoiceItem.amount) * 100);
        payload += '&customer=' + invoiceItem.customer;
        payload += '&subscription=' + invoiceItem.subscription;
        payload += '&description=' + (String.isEmpty(invoiceItem.description) ? '' : EncodingUtil.urlEncode(invoiceItem.description,'UTF-8'));

        Map<String, Object> stripeInvoiceItem = (Map<String, Object>)JSON.deserializeUntyped(
            postToStripe(req_type, payload, secretKey)
        );
        return (String)stripeInvoiceItem.get(KEY_ID);
    }

    /**
     * @param invoice   invoice payload for stripe
     * 
     * Makes a post request with invoice and invoice item payload for the given customer. The reason for check is to 
     * prevent users from creating multiple deposits if something fails in the org.
     *
     * Note: Although we use "StripeModels.Invoice", we save in this object invoice items fields as well. For example,
     * the field "description" isn't sent for invoice, only for the invoice item.
     * 
     * @param invoice   invoice payload for stripe. Can't be null, otherwise NullPointerException.
     */
    public static void createInvoice(StripeModels.Invoice invoice){
        if(!invoiceExistInStripe(invoice)) {
            String invoiceItemPayload = 'customer=' + invoice.customerId;
            invoiceItemPayload += '&currency=eur';
            invoiceItemPayload += '&description=' + (String.isEmpty(invoice.description) ? '' : EncodingUtil.urlEncode(invoice.description,'UTF-8'));
            invoiceItemPayload += '&amount=' + Integer.valueOf(invoice.amount * 100);
            postToStripe(REQ_TYPE_INVOICE_ITEMS, invoiceItemPayload, invoice.secretKey);

            String invoicePayload = 'customer=' + invoice.customerId;
            invoicePayload += '&collection_method=charge_automatically';
            invoicePayload += '&auto_advance=true';
            invoicePayload += '&metadata[ContractId]=' + invoice.mdt_ContractId;
            invoicePayload += '&metadata[invoiceType]=' + invoice.invoiceType;
            postToStripe('invoices', invoicePayload, invoice.secretKey);
        }
    }

    /**
     * This method is used to prevent user from creating multiple invoices if something goes wrong in the system.
     * Invoice item description is usually a product name, so we can differentiate between Rent and Deposit invoice items.
     *
     * The method returns true if there is an invoice with the same contract id and if this invoice has an invoice line
     * item which matches our description.
     *
     * If there is at least one invoice that match, the user won't be able to create an invoice. Therefore it is assumed
     * that maximum one invoice per contract is allowed.
     *
     * @param createdInvoice    Invoice and invoice item payload that should be send to stripe.
     * @return                  Ture or false. Never null.
     * */
    private static Boolean invoiceExistInStripe(StripeModels.Invoice createdInvoice) {
        List<StripeModels.InvoiceEventData> invoices = getInvoicesForCustomer(createdInvoice.customerId, createdInvoice.secretKey);
        for(StripeModels.InvoiceEventData stripeInvoice : invoices) {
            if(stripeInvoice.metadata.ContractId == createdInvoice.mdt_ContractId && stripeInvoice.lines != null) {
                for(StripeModels.InvoiceItemData item : stripeInvoice.lines.data) {
                    if(item.description == createdInvoice.description) {
                        return true;
                    }
                }
            }
        }

        return false;
    }

    private static List<StripeModels.InvoiceEventData> getInvoicesForCustomer(String customerId, String secretKey) {
        String parameters = 'customer=' + customerId;
        String stripeResponse = getFromStripe('invoices', parameters, secretKey);
        String invoicesString = retrieveInvoicesString(stripeResponse);

        return (List<StripeModels.InvoiceEventData>) JSON.deserialize(invoicesString, List<StripeModels.InvoiceEventData>.class);
    }

    private static String retrieveInvoicesString(String stripeResponse) {
        Map<String, Object> eventDataMap = (Map<String, Object>) JSON.deserializeUntyped(stripeResponse);
        List<Object> invoicesAsObjects = (List<Object>) eventDataMap.get(DATA);
        String invoicesAsObjectsString = JSON.serialize(invoicesAsObjects);

        return invoicesAsObjectsString;
    }

    /**
     * getSubscription Retrieves the subscription with the given Customer Id and Plan Id
     * 
     */
    public static SyncStripeInvItemsJSONResponse getInvoiceItemsRelatedToAnInvoice(String invoiceStripeId, String secretKey){
        String parameters = 'invoice=' + invoiceStripeId;
        String response = getFromStripe(REQ_TYPE_INVOICE_ITEMS, parameters, secretKey);
        System.debug('+++ getInvoiceItemsRelatedToAnInvoice response: ' + response);
        SyncStripeInvItemsJSONResponse stripeInvoiceItemResponse;
        try {
            stripeInvoiceItemResponse = SyncStripeInvItemsJSONResponse.parse(response);
        } catch (Exception e) {
            StripeLogHandler.insertStripeLog(e.getMessage(), response);
            throw new StripeErrorException(e.getMessage());
        }

        return stripeInvoiceItemResponse;
    }

    public static String postToStripe(String reqType, String payLoad, String key){
        String url = API_URL + reqType;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + key);
        req.setHeader('Stripe-Version', '2019-05-16 ');

        req.setBody(payLoad);
        req.setTimeout(100000);
        res = h.send(req);
        checkResponse((Map<String, Object>)JSON.deserializeUntyped(res.getBody()), req);
        return res.getBody();
    }

    public static String getFromStripe(String reqType, String parameters, String key){
        String url = API_URL + reqType + '?' + parameters;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + key);
        req.setHeader('Stripe-Version', '2019-05-16 ');
        req.setTimeout(100000);

        res = h.send(req);
        checkResponse((Map<String, Object>)JSON.deserializeUntyped(res.getBody()), req);
        return res.getBody();
    }

    public static String deleteInStripe(String reqType, String id, String key){
        String url = API_URL + reqType + '/' + id;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(url);
        req.setMethod('DELETE');
        req.setHeader('Authorization', 'Bearer ' + key);
        req.setHeader('Stripe-Version', '2019-05-16 ');
        req.setTimeout(100000);

        res = h.send(req);
        checkResponse((Map<String, Object>)JSON.deserializeUntyped(res.getBody()), req);
        return res.getBody();
    }

    public static void checkResponse(Map<String, Object> response, HttpRequest req){
        if (response.get('error') != null){
            Map<String, Object> error = (Map<String, Object>)response.get('error');
            StripeLogHandler.insertStripeLog((String)error.get('message'), 'Endpoint: ' + req.getEndpoint() + '. Method: ' + req.getMethod() + '. Body: ' +req.getBody());
            throw new StripeErrorException((String)error.get('message'));
        }
    }

    public static void sendStripeErrors(String message) {
        EmailService service = new EmailService();

        List<EmailService.EmailServiceParameterWrapper> wrappers = new List<EmailService.EmailServiceParameterWrapper>();
        EmailService.EmailServiceParameterWrapper wrapper = new EmailService.EmailServiceParameterWrapper();
        wrapper.toAddresses = new List<String>{ (String) External_API_Key__c.getOrgDefaults().get('STRIPE_Send_Errors__c') };
        wrapper.htmlBody = message;
        wrapper.subject = 'swh';
        wrapper.saveAsActivity = false;
        wrappers.add(wrapper);

        service.sendEmails(wrappers, false);
    }

    public class StripeErrorException extends Exception {}
}