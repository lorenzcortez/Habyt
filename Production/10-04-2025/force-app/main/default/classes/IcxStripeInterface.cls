public without sharing class IcxStripeInterface{
	private static String API_URL = 'https://api.stripe.com/v1/';
	private static String CONTRACT_STATUS_TERMINATED = 'Terminated';

	public class stripeErrorException extends Exception{
	}

	@AuraEnabled
	public static void updateContactInfo(Id accId, String ContactName, String ContactEmail){
		update new Account(Id = accId, Contact_Name__c = ContactName, PersonEmail = ContactEmail);
	}

	@AuraEnabled
	public static String getMyProfileUserInfo(){
		User u = [
			SELECT AccountId
			FROM User
			WHERE Id = :UserInfo.getUserId()
		];

		List<Contract> contracts = [
			SELECT Id, EverSign_Doc_Status__c, EverSign_Doc_Hash__c, Community_Step__c, AccountId,
					Stripe_Subscription_Id__c, Opportunity__c
			FROM Contract
		    WHERE AccountId = :u.AccountId
				AND RecordTypeId = :CustomerContractService.RT_ID_RENT
		    ORDER BY CreatedDate DESC
			LIMIT 1
		];

		if (contracts.size() > 0){
			return JSON.serialize(contracts[0]);
		} else{
			throw new stripeErrorException('no contract');
		}
	}

	@AuraEnabled
	public static void createSourceAndCustomer(String contractJson, String sourcePayload){
		try {
            Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
			List<Contract> contractsToUpdate = new List<Contract>();
	        Contract contract = (Contract) JSON.deserialize(contractJson, Contract.class);
			//First we need to find all contracts for the same opportunity 
			for(Contract iCont: [ SELECT  AccountId, Account.Name, Account.PersonEmail, Account.Stripe_Customer_Id__c, Stripe_Account__r.secret_key__c, Account.StripeCustomerJSONMap__c, RecordType.DeveloperName
                                    FROM Contract
                                    WHERE Opportunity__c =: contract.Opportunity__c]){

                if (accountsToUpdate.containsKey(iCont.AccountId)) {
                    iCont.Account.Stripe_Customer_Id__c = accountsToUpdate.get(iCont.AccountId).Stripe_Customer_Id__c;
                    iCont.Account.StripeCustomerJSONMap__c = accountsToUpdate.get(iCont.AccountId).StripeCustomerJSONMap__c;
                }
				Account tmp = doCreateSourceAndCustomer(iCont, sourcePayload);
                if (tmp != null) {
					iCont.StripeCustomerJSONMap__c = tmp.StripeCustomerJSONMap__c;
					iCont.StripeCustomerId__c = tmp.Stripe_Customer_Id__c;
					contractsToUpdate.add(iCont);
					if (!accountsToUpdate.containsKey(tmp.Id) || iCont.RecordType.DeveloperName == 'Rent') {
						accountsToUpdate.put(tmp.Id, tmp);
					} else {
						accountsToUpdate.get(tmp.Id).StripeCustomerJSONMap__c = tmp.StripeCustomerJSONMap__c;
					}
                }
			}
            if (! accountsToUpdate.isEmpty()) {
				update contractsToUpdate;
                update accountsToUpdate.values();
            }
		} catch (Exception e){
			System.debug('+++ createSourceAndCustomer: ' + e.getStackTraceString());
			throw new stripeErrorException(e.getMessage());
		}
	}

	@AuraEnabled
	public static Account doCreateSourceAndCustomer(Contract con, String sourcePayload){
		try{
			Map<String, Object> source = (Map<String, Object>)JSON.deserializeUntyped(StripeService.postToStripe('sources', sourcePayload, con.Stripe_Account__r.secret_key__c));
            Map<String,Object> mapStripeSecretKey_CustomerId = String.isNotEmpty(con.Account.StripeCustomerJSONMap__c) ? 
                (Map<String,Object>) JSON.deserializeUntyped(con.Account.StripeCustomerJSONMap__c) : new Map<String,String>();

            if (mapStripeSecretKey_CustomerId.containsKey(con.Stripe_Account__r.secret_key__c)) {
                StripeService.postToStripe('customers/' + (String) mapStripeSecretKey_CustomerId.get(con.Stripe_Account__r.secret_key__c), 'source=' + (String)source.get('id'), con.Stripe_Account__r.secret_key__c);
            } else {
                String payload = 'name=' + con.Account.Name + '&email=' + con.Account.PersonEmail + '&source=' + (String)source.get('id');
				Map<String, Object> customerPayload = (Map<String, Object>)JSON.deserializeUntyped(StripeService.postToStripe('customers', payload, con.Stripe_Account__r.secret_key__c));
                
                // Update map with the secret key and the new Customer Id
                mapStripeSecretKey_CustomerId.put(con.Stripe_Account__r.secret_key__c, (String)customerPayload.get('id'));
                // Update Account
				return new Account(Id = con.AccountId, 
                                    Stripe_Customer_Id__c = (String)customerPayload.get('id'), 
                                    StripeCustomerJSONMap__c = JSON.serialize(mapStripeSecretKey_CustomerId)
                                    );
            }

		} catch (Exception e){
			System.debug('*** createSourceAndCustomer' + e.getStackTraceString());
			throw new stripeErrorException(e.getMessage());
		}
        return null;
	}

	@AuraEnabled
	public static void createDepositAndSubscription(Id opportunityId){
        TenantContractService tenantContractService = new TenantContractService();
        Paua_Transaction trans = new Paua_Transaction();
        List<Contract> lstUpdatedContracts = new List<Contract>();
        try {
            lstUpdatedContracts = tenantContractService.createDepositAndSubscription(opportunityId);
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            throw new stripeErrorException(e.getMessage());
        }
        
        if (!lstUpdatedContracts.isEmpty()) {
            trans.addForUpdate(lstUpdatedContracts);
            trans.setPreferredOrder(new List<SObjectType>{Contract.getSObjectType()});
            trans.commitRecords();
        }
	}

	public static void CheckResponse(Map<String, Object> response){
		if (response.get('error') != null){
			Map<String, Object> error = (Map<String, Object>)response.get('error');
			throw new stripeErrorException((String)error.get('message'));
		}
	}

	@AuraEnabled
	public static void updateContract(Contract con){
		update con;
	}

	@AuraEnabled
	public static Account getAccount(Id ContractId){
		return [SELECT Name, PersonEmail, Contact_Name__c, BillingStreet, BillingPostalCode, BillingCity, BillingCountry, Stripe_Customer_Id__c
		        FROM Account
		        WHERE Id IN (SELECT AccountId
		                     FROM Contract
		                     WHERE Id = :ContractId)];
	}

	@AuraEnabled
	public static String submitTransaction(String recordId){

		List<Stripe_Transaction_User__mdt> stripeTransactionUsers = [ SELECT User_Id__c FROM Stripe_Transaction_User__mdt];
		if( stripeTransactionUsers.size() > 0 ){
			Set<Id> userTranIds = new Set<Id>();

			for( Stripe_Transaction_User__mdt stripeTransactionUser : stripeTransactionUsers ){
				if( String.isNotEmpty(stripeTransactionUser.User_Id__c) ){
					userTranIds.add(stripeTransactionUser.User_Id__c);
				}
			}

			//added Finance profile GSD - 4413 
			if( ! userTranIds.contains( UserInfo.getProfileId() ) ) {
				return 'Error: only admins and finance agents can send to stripe';
			} else {
				try{
					Transaction__c txn = [SELECT Id, Account__r.Stripe_Customer_Id__c, Amount__c, Description__c, Status__c, Stripe_Id__c, Type__c, Contract__r.Stripe_Account__r.secret_key__c
										FROM Transaction__c
										WHERE Id = :recordId];
					if (txn.Stripe_Id__c != null)
						return 'Error: Transaction already sent';
					if (txn.Contract__r.Stripe_Account__r.secret_key__c == null)
						return 'Error: No contract or contract has no stripe account';
					if (txn.Account__r.Stripe_Customer_Id__c != null){
						String payload = 'currency=eur';
						payload += '&description=' + txn.Description__c;
	
						payload += '&amount=';
						if (txn.type__c == 'Credit')
							payload += '-';
						payload += (Integer)Math.abs(txn.Amount__c * 100);
	
						Map<String, Object> stripeTxn = (Map<String, Object>)JSON.deserializeUntyped(StripeService.postToStripe('customers/' + txn.Account__r.Stripe_Customer_Id__c + '/balance_transactions', payload, txn.Contract__r.Stripe_Account__r.secret_key__c));
	
						txn.status__c = 'Sent to Stripe';
						txn.Stripe_Id__c = (String)stripeTxn.get('id');
						update txn;
	
						return 'OK';
					} else
						return 'Error: customer not in stripe';
				} catch (Exception e){
					return e.getMessage();
				}
			}
			
		} else {
			return 'Error: custom metadata named Stripe Transaction User cannot be emtpy.';
		}
	}

	@AuraEnabled
	public static String CancelSubscription(String contractId, Date cancelDate, Date moveoutDate, Boolean cancelMembership){
		try{
			Contract con = [
				SELECT Id, Stripe_Subscription_Id__c, Move_out_date__c, Stripe_Account__r.secret_key__c, Room__c, AccountId
				FROM Contract
				WHERE Id = :contractId
			];
			con.contract_end_date__c = cancelDate;
			con.Move_out_date__c = moveoutDate;
			con.Status = CONTRACT_STATUS_TERMINATED;
			if (con.Stripe_Subscription_Id__c != null){
				DateTime cancelDateTime = Datetime.newInstanceGmt(cancelDate.year(), cancelDate.month(), cancelDate.day());
				Long cancelDateTimestamp = cancelDateTime.getTime() / 1000; //pass from milliseconds to seconds

				Long DTNTimeStamp = Datetime.now().getTime() / 1000;
				String payload = 'cancel_at=' + cancelDateTimestamp;
				StripeService.postToStripe('subscriptions/' + con.Stripe_Subscription_Id__c, payload, con.Stripe_Account__r.secret_key__c);
			}
			if(cancelMembership != null && cancelMembership) {
				CustomerContractService contractService = new CustomerContractService();
				contractService.cancelMembershipForContract(new List<Contract> {con}, cancelDate, moveoutDate);
			}
			update con;
			return 'OK';
		} catch (Exception e){
			return e.getMessage();
		}
	}

	//@AuraEnabled
	//public static String CancelSubscription(String contractId, Date cancelDate, Date moveoutDate){
		//return CancelSubscription(contractId, cancelDate, moveoutDate, false);
	//}

	@TestVisible 
	private static void setRoomAvailability(Id roomId, Id contractId, Date contractEndDate) {
		if (roomId == null || [SELECT COUNT() FROM Contract WHERE Room__c = :roomId AND Id != :contractId AND Status = 'Activated'] > 0) {
			return;
		}
		update new Room__c(Id = roomId, AvailableDateTrig__c = contractEndDate.addDays(1));
	}
}