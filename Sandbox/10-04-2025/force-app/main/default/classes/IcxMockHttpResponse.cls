@isTest
global class IcxMockHttpResponse implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":true,"result":"Mock", "id":"1234", "subscriptions":{"total_count":0}, "document_hash" : "xxxx"}');
        res.setStatusCode(200);
        return res;
    }
}