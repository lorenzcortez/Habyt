public class StripeCustomerSubscriptionEventHandler extends StripeAbstractEventHandler {
    /**
     * This method parses the subscription webhook message and inserts the contract record. 
     * This method is dynamically called from StripeEventHandler, which determinates which handler to call 
     * based on event type.
     * 
     * @param eventData     JSON as string from the stripe webhook
     */
    public override void handle(String eventData) {
        eventData = preProcessJson(eventData);
        String dataObjectString = parseToEventDataString(eventData);
        StripeModels.SubscriptionData subscriptionData = (StripeModels.SubscriptionData) JSON.deserialize(
            dataObjectString, StripeModels.SubscriptionData.class
        );
        Contract contract = searchForContract(subscriptionData.customer, subscriptionData.id);
        contract.Stripe_Subscription_Status__c = subscriptionData.status;

        updateContract(contract);
    }

    private Contract searchForContract(String customerId, String subscriptionId) {
        String searchTerm = constructSearchTerm(customerId, subscriptionId);
        List<List<Contract>> searchList = [
            FIND :searchTerm
            IN ALL FIELDS 
            RETURNING Contract(Id, StripeCustomerJSONMap__c, Stripe_Subscription_Id__c)
        ];
        Contract contract;
        if(searchList.size() == 1 && searchList.get(0).size() > 0) {
            for (Contract currentContract : (List<Contract>) searchList.get(0)) {
                if (subscriptionId != null && currentContract.Stripe_Subscription_Id__c == subscriptionId) {
                    contract = currentContract;
                    break;
                } else if (contract == null && customerId != null && currentContract.StripeCustomerJSONMap__c != null && currentContract.StripeCustomerJSONMap__c.contains(customerId)) {
                    contract = currentContract;
                }
            }
        }

        if (contract != null) {
            return contract;
        } else {
            throw new StripeEventHandler.UnknownCustomerIdException();
        }
    }

    private String constructSearchTerm(String customerId, String subscriptionId) {
        String searchTerm = customerId;

        if(subscriptionId != null) {
            searchTerm = '"' + customerId + '" OR "' + subscriptionId + '"';
        } 

        return searchTerm;
    }

    private static void updateContract(Contract contract) {
        Paua_Transaction trans = new Paua_Transaction();
        trans.addForUpsert(contract);
        trans.setPreferredOrder(new List<SObjectType>{Contract.getSObjectType()});
        trans.commitRecords();
    }  
}