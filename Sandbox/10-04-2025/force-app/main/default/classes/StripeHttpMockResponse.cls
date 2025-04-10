@IsTest
global class StripeHttpMockResponse implements HttpCalloutMock {

    public HTTPResponse respond(HttpRequest request) {
        String endpointString = request.getEndpoint();
        String responseString = '';

        if (endpointString.endsWith('/plans') || endpointString.contains('plans')) {
            responseString = getPlansResponse();
        } else if (endpointString.endsWith('/subscriptions')) {
            responseString = getSubscriptionsResponse();
        } else if(endpointString.contains('subscriptions')) {
            responseString = getSubscriptionsWithDataResponse();
        } else if (endpointString.endsWith('/invoiceitems')) {
            responseString = getInvoiceItemsResponse();
        } else if (endpointString.endsWith('/invoices')) {
            responseString = getInvoicesResponse();
        } else if (endpointString.endsWith('/invoiceitems_test')) {
            responseString = getInvoiceItems_Create();
        } else if(endpointString.contains('/invoices')) {
            responseString = getInvoiceArrayResponse();
        } else if (endpointString.contains('api.eversign.com/api/document')) {
            if (endpointString.contains('cancel=1')) {
                responseString = getEverSignSuccessResponse();
            } else {
                responseString = getEverSignDocumentResponse();
            }
        } else if (endpointString.endsWith('/invoiceitems/ii_1KVj0z2eZvKYlo2CObflX1s7')) {
            responseString = getInvoiceItemDeleteResponse();
        } else if (endpointString.endsWith('/coupons')) {
            responseString = getCoupon();
        } else if (endpointString.endsWith('/invoiceitems?invoice=Test')) {
            responseString = getStripeInvItems();
        } else if (endpointString.endsWith('/delete/1245')) {
            responseString = getDelete();
        }

        if (String.isNotBlank(responseString)) {
            HttpResponse response = new HttpResponse();
            response.setBody(responseString);
            response.setStatusCode(200);
            return response;
        } else {
            throw new CalloutException('Test data not defined for this URL' + endpointString);
        }
    }

    private String getInvoiceItemDeleteResponse() {
        String response = '{"id": "ii_1KVj0z2eZvKYlo2CObflX1s7","object": "invoiceitem","deleted": true }';
        return response;
    }

    private String getPlansResponse(){
        String response = '{"id":"test_id_123"}';
        return response;
    }

    private String getSubscriptionsResponse(){
        String response = '{"id":"test_id_123", "status":"ok"}';
        return response;
    }

    private String getSubscriptionsWithDataResponse() {
        String response = '{"id":"test_id_123", "status":"ok", "data":[{"id":"test_id_123"}]}';
        return response;
    }
 
    private String getCoupon() {
        String response = '{"id":"123", "name":"Test Name"}';
        return response;
    }

    private String getStripeInvItems() {
        String response = '{"url":"test.com", "object_Z" : "{}", "has_more":false}';
        return response;
    }

    private String getDelete() {
        String response = '{"id":"Test"}';
        return response;
    }

    private String getInvoiceItemsResponse(){
        StaticResource staticResource = [
            SELECT Id, Name, Body
            FROM StaticResource
            WHERE Name = 'InvoiceItemsResponse'
            LIMIT 1
        ];

        return staticResource.Body.toString();
    }

    private String getInvoicesResponse(){
        StaticResource staticResource = [
            SELECT Id, Name, Body
            FROM StaticResource
            WHERE Name = 'InvoiceResponse'
            LIMIT 1
        ];

        return staticResource.Body.toString();
    }

    /**
     * The example of the invoice response is taken from "List all invoices" section:
     * Link: https://stripe.com/docs/api/invoices/list
     *
     * @return invoice response as stated in Stripe API.
     * */
    private String getInvoiceArrayResponse() {
        String invoiceResponse =
            '{\n' +
                '"data": [{\n' +
                    '"id": "ii_1KQSvUI4AG1fjzDfets4TTk6",\n' +
                    '"description": "It is a test invoice",\n' +
                    '"metadata": {"contractId":"con_jbizb1"}\n' +
                '}]\n' +
            '}';

        return invoiceResponse;
    }

    private String getEmptyResponse(){
        String response = '{"status":"ok"}';
        return response;
    }

    private String getEverSignDocumentResponse(){
        String response = '{"document_hash":"doc_hash"}';
        return response;
    }

    private String getEverSignSuccessResponse(){
        String response = '{"success":true}';
        return response;
    }

    private String getInvoiceItems_Create() {
        String response = '' +
        '{' +
        '    "id": "ii_1KVzevI4AG1fjzDfH9Z3GIxA",' +
        '    "object": "invoiceitem",' +
        '    "amount": -9900,' +
        '    "currency": "eur",' +
        '    "customer": "cus_Kc0SKF3t43UORQ",' +
        '    "date": 1645541289,' +
        '    "description": null,' +
        '    "discountable": true,' +
        '    "discounts": [' +
        '        "di_1KVzevI4AG1fjzDfXz5PiSfY"' +
        '    ],' +
        '    "invoice": null,' +
        '    "livemode": false,' +
        '    "metadata": {},' +
        '    "period": {' +
        '        "end": 1645541289,' +
        '        "start": 1645541289' +
        '    },' +
        '    "plan": null,' +
        '    "price": {' +
        '        "id": "price_1KVzevI4AG1fjzDf6hYWXAtW",' +
        '        "object": "price",' +
        '        "active": false,' +
        '        "billing_scheme": "per_unit",' +
        '        "created": 1645541289,' +
        '        "currency": "eur",' +
        '        "livemode": false,' +
        '        "lookup_key": null,' +
        '        "metadata": {},' +
        '        "nickname": null,' +
        '        "product": "prod_LCORz4bQJV8JIG",' +
        '        "recurring": null,' +
        '        "tax_behavior": "unspecified",' +
        '        "tiers_mode": null,' +
        '        "transform_quantity": null,' +
        '        "type": "one_time",' +
        '        "unit_amount": -9900,' +
        '        "unit_amount_decimal": "-9900"' +
        '    },' +
        '    "proration": false,' +
        '    "quantity": 1,' +
        '    "subscription": null,' +
        '    "tax_rates": [],' +
        '    "unit_amount": -9900,' +
        '    "unit_amount_decimal": "-9900"' +
        '}';
        return response;
    }
}