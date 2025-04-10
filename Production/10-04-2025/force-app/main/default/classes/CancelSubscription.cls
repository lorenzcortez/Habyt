global class CancelSubscription {
    
    /*private	static	String	API_URL = 'https://api.stripe.com/v1/';
    private	static	String	API_PUBLISHABLEKEY = External_API_Key__c.getOrgDefaults().STRIPE_Publishable_Key__c;
    private	static	String	API_SECRETKEY= External_API_Key__c.getOrgDefaults().STRIPE_Secret_Key__c;*/
    
    @AuraEnabled
    global static String CancelSubscription(String contractId, Date cancelDate, Date moveoutDate) {
        try {
            Contract con = [SELECT Id, Stripe_Subscription_Id__c,Move_out_date__c FROM Contract WHERE Id = : contractId];
            con.contract_end_date__c = cancelDate;
            con.Move_out_date__c = moveoutDate;
            if(con.Stripe_Subscription_Id__c != null) {
                DateTime cancelDateTime = DateTime.newInstanceGmt(cancelDate.year(), cancelDate.month(), cancelDate.day());
                Long cancelDateTimestamp = cancelDateTime.getTime() / 1000; //pass from milliseconds to seconds
                
                Long DTNTimeStamp = Datetime.now().getTime() / 1000;
                String payload = 'cancel_at=' + cancelDateTimestamp;

                System.debug('subscriptions' + payload);

                StripeService.postToStripe('subscriptions/'+con.Stripe_Subscription_Id__c, payload, con.Stripe_Account__r.secret_key__c);
            }
            update con;
            return 'OK';
        }catch (Exception e) {
            return e.getMessage();
        }
    }
}