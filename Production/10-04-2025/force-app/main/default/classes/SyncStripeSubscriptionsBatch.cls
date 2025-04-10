public with sharing class SyncStripeSubscriptionsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    Map<String, String> privateKeys;

    public SyncStripeSubscriptionsBatch() {
        privateKeys = new Map<String, String>();
        for (Stripe_Account__c stripeAccount : [SELECT Id, secret_key__c, Name FROM Stripe_Account__c WHERE secret_key__c != NULL]) {
            privateKeys.put(stripeAccount.Name, stripeAccount.secret_key__c);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQuerylocator([
                SELECT Id, StripeCustomerId__c, StripeAccountName__c FROM StripeCustomer__c WHERE IsProcessed__c = FALSE
        ]);
    }

    public void execute(Database.BatchableContext bc, List<StripeCustomer__c> stripeCustomers){
        Map<String, StripeSubscription__c> subscriptionByStripeId = new Map<String, StripeSubscription__c>();
        Map<String, List<String>> productNameToSubscriptions = new Map<String, List<String>>();
        Map<String, String> subscriptionIdToCustomerId = new Map<String, String>();
        List<Contract> contractsToUpdate = new List<Contract>();
        for (StripeCustomer__c stripeCustomer : stripeCustomers) {
            if (!privateKeys.containsKey(stripeCustomer.StripeAccountName__c)) {
                continue;
            }
            String privateKey = privateKeys.get(stripeCustomer.StripeAccountName__c);
            String subscriptionResponse = getFromStripe('https://api.stripe.com/v1/subscriptions?status=all&customer='+stripeCustomer.StripeCustomerId__c, privateKey);
            System.debug('subscriptionResponse ' + subscriptionResponse);
            if (subscriptionResponse.contains('error') && subscriptionResponse.contains('message')) {
                continue;
            }
            SubscriptionResults subscriptionResults = (SubscriptionResults) JSON.deserialize(
                    subscriptionResponse, SubscriptionResults.class
            );
            if (subscriptionResults.data != null && !subscriptionResults.data.isEmpty()) {
                for (SubscriptionData subscriptionData : subscriptionResults.data) {
                    StripeSubscription__c stripeSubscription = new StripeSubscription__c(
                            SubscriptionId__c = subscriptionData.Id,
                            SubscriptionStatus__c = subscriptionData.status,
                            StripeCustomerRef__c = stripeCustomer.Id
                    );
                    if (subscriptionData?.plan?.product != null) {
                        String productResponse = getFromStripe('https://api.stripe.com/v1/products/'+subscriptionData.plan.product, privateKey);
                        ProductData productData = (ProductData) JSON.deserialize(
                                productResponse, ProductData.class
                        );
                        if (productData?.name != null) {
                            stripeSubscription.Product__c = productData.name;
                            if (!productNameToSubscriptions.containsKey(productData.name)) {
                                productNameToSubscriptions.put(productData.name, new List<String>());
                            }
                            productNameToSubscriptions.get(productData.name).add(subscriptionData.id);
                        }
                    }
                    subscriptionByStripeId.put(stripeSubscription.SubscriptionId__c, stripeSubscription);
                    subscriptionIdToCustomerId.put(stripeSubscription.SubscriptionId__c, stripeCustomer.StripeCustomerId__c);
                }
            }
            stripeCustomer.IsProcessed__c = true;
        }
        if (!productNameToSubscriptions.isEmpty()) {
            for (Contract contract : [SELECT Id, ContractNumber, StripeCustomerIdTemp__c FROM Contract WHERE ContractNumber IN :productNameToSubscriptions.keySet()]) {
                Set<String> customerIds = new Set<String>();
                if (productNameToSubscriptions.containsKey(contract.ContractNumber)) {
                    for (String subscriptionId : productNameToSubscriptions.get(contract.ContractNumber)) {
                        if (subscriptionByStripeId.containsKey(subscriptionId)) {
                            subscriptionByStripeId.get(subscriptionId).ContractRef__c = contract.Id;
                            if (subscriptionIdToCustomerId.containsKey(subscriptionId)) {
                                customerIds.add(subscriptionIdToCustomerId.get(subscriptionId));
                            }
                        }
                    }
                }
                contract.SubscriptionIdTemp__c = String.join(productNameToSubscriptions.get(contract.ContractNumber),',');
                if (contract.StripeCustomerIdTemp__c != null) {
                    customerIds.addAll(contract.StripeCustomerIdTemp__c.split(','));
                }
                contract.StripeCustomerIdTemp__c = String.join(new List<String>(customerIds), ',');
                contractsToUpdate.add(contract);
            }
        }
        update contractsToUpdate;
        update stripeCustomers;
        upsert subscriptionByStripeId.values() SubscriptionId__c;
    }

    public void finish(Database.BatchableContext bc){

    }

    private String getFromStripe(String url, String key) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + key);
        req.setHeader('Stripe-Version', '2020-08-27 ');
        req.setTimeout(100000);
        if (!Test.isRunningTest()) {
            res = h.send(req);
        }
        return !Test.isRunningTest() ? res.getBody() : url.contains('subscriptions') ? getSubscriptionResultTest() : getProductTest();
    }

    private String getSubscriptionResultTest() {
        List<SubscriptionData> subscriptionData = new List<SubscriptionData>();
        Contract contract = [SELECT Id, ContractNumber FROM Contract LIMIT 1];
        PlanData planData = new PlanData(contract.ContractNumber);
        subscriptionData.add(new SubscriptionData('123','active', planData));
        SubscriptionResults subscriptionResults = new SubscriptionResults(subscriptionData);
        return JSON.serialize(subscriptionResults);
    }

    private String getProductTest() {
        Contract contract = [SELECT Id, ContractNumber FROM Contract LIMIT 1];
        return JSON.serialize(new ProductData('123', contract.ContractNumber));
    }

    class ProductData {
        public String id;
        public String name;

        public ProductData (String id, String name) {
            this.id = id;
            this.name = name;
        }
    }

    class SubscriptionResults {
        List<SubscriptionData> data;

        public SubscriptionResults(List<SubscriptionData> data) {
            this.data = data;
        }
    }

    class SubscriptionData {
        String id;
        String status;
        PlanData plan;

        public SubscriptionData(String id, String status, PlanData plan) {
            this.id = id;
            this.status = status;
            this.plan = plan;
        }
    }

    class PlanData {
        String product;

        public PlanData(String product) {
            this.product = product;
        }
    }
}