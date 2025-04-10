/*
 * @who     : Jorge Valdes <jorge.valdes@empaua.com>
 * @when    : 26 May 2021
 * @what    : This class implements a Batch to push Transactions to Stripe
 */
global class TransactionCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
	public String query;
	public static final String STATUS_0_OK = 'Ready_for_processing';
	public static final String STATUS_1_OK = 'Sent_to_Stripe';
	public static final String STATUS_1_KO = 'Error: Transaction already sent';
	public static final String STATUS_2_KO = 'Error: No contract or contract has no stripe account';
	public static final String STATUS_3_KO = 'Error: customer not in stripe';

	global TransactionCalloutBatch(){
		query = 'SELECT Id, Account__r.Stripe_Customer_Id__c, Amount__c, Description__c, Status__c, Stripe_Id__c, Type__c, Contract__r.Stripe_Account__r.secret_key__c, ScriptStatus__c ';
		query += 'FROM Transaction__c ';
		query += 'WHERE ScriptStatus__c = \'' + STATUS_0_OK + '\' ';
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Transaction__c> scope){
		// Push Transsaction data to Stripe
		Transaction__c txn = scope.get(0);

		if (txn.Stripe_Id__c != null){
			txn.ScriptStatus__c = STATUS_1_KO;
		} else if (txn.Contract__r.Stripe_Account__r.secret_key__c == null){
			txn.ScriptStatus__c = STATUS_2_KO;
		} else if (txn.Account__r.Stripe_Customer_Id__c != null){
			String payload = 'currency=eur';
			payload += '&description=' + txn.Description__c;
			payload += '&amount=';
			if (txn.type__c == 'Credit')
				payload += '-';
			payload += (Integer)Math.abs(txn.Amount__c * 100);

			Map<String, Object> stripeTxn = (Map<String, Object>)JSON.deserializeUntyped(StripeService.postToStripe('customers/' + txn.Account__r.Stripe_Customer_Id__c + '/balance_transactions', payload, txn.Contract__r.Stripe_Account__r.secret_key__c));

			txn.status__c = 'Sent to Stripe';
			txn.ScriptStatus__c = STATUS_1_OK;
			txn.Stripe_Id__c = (String)stripeTxn.get('id');
		} else{
			txn.ScriptStatus__c = STATUS_3_KO;
		}
		update txn;
	}


    global void finish(Database.BatchableContext BC){
    }
}