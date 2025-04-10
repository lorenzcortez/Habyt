@isTest
global class SyncStripeInvoiceItemsMockGenerator implements HttpCalloutMock{
    public static final String GOOD_INVOICE_ID_1 = 'in_testId001';
    public static final String GOOD_INVOICE_ID_2 = 'in_testId002';
    public static final String BAD_INVOICE_ID_1 = 'in_bad_invoice_id';

    public HTTPResponse respond(HttpRequest request){
        String endpointString = request.getEndpoint();
        String responseString = '';
        Integer statusCode = 200;

        if (endpointString.contains('invoiceitems?invoice=' + GOOD_INVOICE_ID_1)){
            responseString = getGoodData_1();
        } else if (endpointString.contains('invoiceitems?invoice=' + GOOD_INVOICE_ID_2)){
            responseString = getGoodData_2();
        } else if (endpointString.contains('invoiceitems?invoice=' + BAD_INVOICE_ID_1)){
            responseString = getError_1();
            statusCode = 400;
        } else {
            throw new CalloutException('Test data not defined for this URL' + endpointString);
        }

        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(responseString);
        response.setStatusCode(statusCode);
        return response;
    }

    private String getGoodData_1(){
        return '{"object": "list","data": [{"id": "ii_idtest_123123123","object": "invoiceitem","amount": -10050,"currency": "eur","customer": "cus_sf4f32a2334cf3","date": 1642668304,"description": "Test Discount","discountable": false,"discounts": [],"invoice": "' + GOOD_INVOICE_ID_1 + '","livemode": false,"metadata": {},"period": {"end": 1642668304,"start": 1642668304},"plan": null,"price": {"id": "price_1KJwGDfcelNoL97","object": "price","active": false,"billing_scheme": "per_unit","created": 1642668304,"currency": "eur","livemode": false,"lookup_key": null,"metadata": {},"nickname": null,"product": "prod_Kzw8oiuyEdAaw3X","recurring": null,"tax_behavior": "unspecified","tiers_mode": null,"transform_quantity": null,"type": "one_time","unit_amount": -10050,"unit_amount_decimal": "-10050"},"proration": false,"quantity": 1,"subscription": null,"tax_rates": [],"test_clock": null,"unit_amount": -10050,"unit_amount_decimal": "-10050"},{"id": "ii_idtest_456456456","object": "invoiceitem","amount": 12000,"currency": "eur","customer": "cus_KuhZ6vlIp0SCao","date": 1642507208,"description": "Holiday voucher","discountable": true,"discounts": [],"invoice": "' + GOOD_INVOICE_ID_1 + '","livemode": false,"metadata": {},"period": {"end": 1638662400,"start": 1638144000},"plan": null,"price": {"id": "price_g87iohAG1fjzDfej410T7F","object": "price","active": false,"billing_scheme": "per_unit","created": 1642507208,"currency": "eur","livemode": false,"lookup_key": null,"metadata": {},"nickname": null,"product": "prod_KzEpVhjs0jto1i","recurring": null,"tax_behavior": "unspecified","tiers_mode": null,"transform_quantity": null,"type": "one_time","unit_amount": 12000,"unit_amount_decimal": "12000"},"proration": false,"quantity": 1,"subscription": null,"tax_rates": [],"test_clock": null,"unit_amount": 12000,"unit_amount_decimal": "12000"},{"id": "ii_idtest_890890890","object": "invoiceitem","amount": 3200,"currency": "eur","customer": "cus_KuhZ6vlIp0SCao","date": 1642507207,"description": "Invoices are in test","discountable": true,"discounts": [],"invoice": "' + GOOD_INVOICE_ID_1 + '","livemode": false,"metadata": {},"period": {"end": 1641600000,"start": 1641254400},"plan": null,"price": {"id": "price_1KJGM7I4AG1ffgdfeOcrc","object": "price","active": false,"billing_scheme": "per_unit","created": 1642507207,"currency": "eur","livemode": false,"lookup_key": null,"metadata": {},"nickname": null,"product": "prod_KzEpcQjyhrewe3vVeb","recurring": null,"tax_behavior": "unspecified","tiers_mode": null,"transform_quantity": null,"type": "one_time","unit_amount": 3200,"unit_amount_decimal": "3200"},"proration": false,"quantity": 1,"subscription": null,"tax_rates": [],"test_clock": null,"unit_amount": 3200,"unit_amount_decimal": "3200"},{"id": "ii_idtest_123456789","object": "invoiceitem","amount": 4200,"currency": "eur","customer": "cus_KuhZ6vhm76SCao","date": 1642507206,"description": "Second super invoice item!","discountable": true,"discounts": [],"invoice": "' + GOOD_INVOICE_ID_1 + '","livemode": false,"metadata": {},"period": {"end": 1642809600,"start": 1642204800},"plan": null,"price": {"id": "price_1KJGM6I4AG1fjzDfl4NlC8d9","object": "price","active": false,"billing_scheme": "per_unit","created": 1642507206,"currency": "eur","livemode": false,"lookup_key": null,"metadata": {},"nickname": null,"product": "prod_KzEpkW9FlrqVWs","recurring": null,"tax_behavior": "unspecified","tiers_mode": null,"transform_quantity": null,"type": "one_time","unit_amount": 4200,"unit_amount_decimal": "4200"},"proration": false,"quantity": 1,"subscription": null,"tax_rates": [],"test_clock": null,"unit_amount": 4200,"unit_amount_decimal": "4200"}],"has_more": false,"url": "/v1/invoiceitems"}';
    }

    private String getGoodData_2(){
        return '{"object": "list","data": [{"id": "ii_idtest_123123123","object": "invoiceitem","amount": 39448,"currency": "eur","customer": "cus_sf4f32a2334cf3","date": 1636243242,"description": "Time on 00008329 after 07 Nov 2021","discountable": false,"discounts": [],"invoice": "' + GOOD_INVOICE_ID_2 + '","livemode": false,"metadata": {},"period": {"end": 1637794800,"start": 1636243200},"plan": {"id": "plan_KXBB49G2i32bpQ","object": "plan","active": true,"aggregate_usage": null,"amount": 65900,"amount_decimal": "65900","billing_scheme": "per_unit","created": 1636035683,"currency": "eur","interval": "month","interval_count": 1,"livemode": false,"metadata": {},"nickname": null,"product": "prod_KXBfB6wsd33zhv4","tiers": null,"tiers_mode": null,"transform_usage": null,"trial_period_days": null,"usage_type": "licensed"},"price": {"id": "plan_KXBB49G34fNWbpQ","object": "price","active": true,"billing_scheme": "per_unit","created": 1636035683,"currency": "eur","livemode": false,"lookup_key": null,"metadata": {},"nickname": null,"product": "prod_KXBB6wkqS5drhv4","recurring": {"aggregate_usage": null,"interval": "month","interval_count": 1,"trial_period_days": null,"usage_type": "licensed"},"tax_behavior": "unspecified","tiers_mode": null,"transform_quantity": null,"type": "recurring","unit_amount": 65900,"unit_amount_decimal": "65900"},"proration": true,"quantity": 1,"subscription": "sub_1Js6smEPXbtkjdzC4y0H","subscription_item": "si_KXBNkk8EwH6","tax_rates": [],"test_clock": null,"unit_amount": 39448,"unit_amount_decimal": "39448"}],"has_more": false,"url": "/v1/invoiceitems"}';
    }

    private String getError_1(){
        return '{"error": {"code": "resource_missing","doc_url": "https://stripe.com/docs/error-codes/resource-missing","message": "No such invoice: \' ' + BAD_INVOICE_ID_1 + ' \'","param": "invoice","type": "invalid_request_error"}}';
    }

}