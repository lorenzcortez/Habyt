public with sharing class SyncStripePaymentIntentsBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {

    public void execute(SchedulableContext sc){
        Database.executeBatch(new SyncStripePaymentIntentsBatch(), 10);
    }

    public Database.Querylocator start(Database.BatchableContext bc){
        return Database.getQuerylocator([
                SELECT Id, Invoice__r.Contract__r.Stripe_Account__r.secret_key__c, StripeId__c, Status__c
                FROM PaymentIntent__c
                WHERE Invoice__r.Contract__r.Stripe_Account__r.secret_key__c != NULL AND
                StripeId__c != NULL AND
                Status__c IN ('requires_payment_method', 'processing', 'requires_action')
        ]);
    }

    public void execute(Database.BatchableContext bc, List<PaymentIntent__c> paymentIntents){
        List<PaymentIntent__c> paymentIntentsToUpdate = new List<PaymentIntent__c>();
        for (PaymentIntent__c paymentIntent : paymentIntents) {
            String response = getPaymentIntentFromStripe('https://api.stripe.com/v1/payment_intents/'+paymentIntent.StripeId__c, paymentIntent.Invoice__r.Contract__r.Stripe_Account__r.secret_key__c);
            StripeModels.PaymentIntentData paymentIntentData = (StripeModels.PaymentIntentData) JSON.deserialize(
                    response, StripeModels.PaymentIntentData.class
            );

            if (paymentIntent.Status__c != paymentIntentData.status && paymentIntentData.status != null) {
                paymentIntent.Status__c = paymentIntentData.status;
                paymentIntentsToUpdate.add(paymentIntent);
            }
        }
        update paymentIntentsToUpdate;
    }

    public void finish(Database.BatchableContext bc){

    }

    private String getPaymentIntentFromStripe(String url, String key) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + key);
        req.setHeader('Stripe-Version', '2019-05-16 ');
        req.setTimeout(100000);
        if (!Test.isRunningTest()) {
            res = h.send(req);
        }
        return !Test.isRunningTest() ? res.getBody() : [
                SELECT Id, Name, Body
                FROM StaticResource
                WHERE Name = 'StripePaymentIntentSucceededJson'
                LIMIT 1
        ].Body.toString();
    }

}