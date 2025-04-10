global class GenerateStripePlanQueueable implements Queueable, Database.AllowsCallouts {

    Integer stripeAmount;
    Contract con;
	
    public GenerateStripePlanQueueable(Id recordId, Decimal amount){
        con = (Contract) Paua_SelectorHandler.getSelector(CustomerContractSelectors.Contracts.class)
            .setParameter('id', recordId)
            .query()
            .get(0);

        if (amount == null) {
            stripeAmount = (Integer)(con.Opportunity__r.Monthly_Price__c * 100);
        } else {
            stripeAmount = (Integer)(amount * 100);
        }
    }

    public void execute(QueueableContext context) {
        StripeModels.Plan stripePlan = new StripeModels.Plan(
            con.ContractNumber,
            con.Stripe_Account__r.secret_key__c,
            stripeAmount,
            con.CurrencyIsoCode
        );
        
        // Push plant to Stripe and update contract stripe plan Id
        // con.STRIPE_Plan_Id__c = StripeService.createPlan(stripePlan);
        update con;
    }
}