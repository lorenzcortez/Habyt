public class ContractGeneratorController{
	private static String HMACSECRETKEY = 'HMACKEY';
	@AuraEnabled
	public static string saveContract(Id recordId){
		//Insert Contract
		Opportunity opp = [SELECT Id, AccountId, Description, Start_Date__c, Room__c, Name, Room__r.Property__r.Billing_Entity__c, Room__r.Property__r.Billing_Entity__r.Stripe_Account__c,Room__r.ApartmentRef__c
		                   FROM Opportunity
		                   WHERE Id = :recordId];
		Contract con = new Contract();
		con.AccountId = opp.AccountId;
		con.Billing_Entity__c = opp.Room__r.Property__r.Billing_Entity__c;
		con.Stripe_Account__c = opp.Room__r.Property__r.Billing_Entity__r.Stripe_Account__c;
		con.Room__c = opp.Room__c;
		con.Description = opp.Description;
		con.StartDate = opp.Start_Date__c;
		con.ContractTerm = 6;
		con.Opportunity__c = recordId;
        con.ApartmentRef__c = opp.Room__r.ApartmentRef__c;
		insert con;

		//Create attachment
		PageReference pdfPage = Page.ContractPDF;
		Datetime dt = Datetime.now();
		pdfPage.getParameters().put('Id', opp.Id);
		Blob pdfBlob;

		if (Test.isRunningTest())
			pdfBlob = Blob.valueOf('Unit Test');
		else
			pdfBlob = pdfPage.getContent();
		String name = [select ContractNumber
		               from contract
		               where id = :con.Id].ContractNumber + dt.format('dd/MM/yyyy HH:mm:ss');

		ContentVersion conVer = new ContentVersion();
		conVer.ContentLocation = 'S';
		conVer.Title = name;
		conVer.PathOnClient = name + '.pdf';

		conVer.VersionData = pdfBlob; // converting your binary string to Blog
		insert conVer;

		// Link to opp & contract
		Id conDoc = [SELECT ContentDocumentId
		             FROM ContentVersion
		             WHERE Id = :conVer.Id].ContentDocumentId;

		//Create ContentDocumentLink for Opportunity
		ContentDocumentLink oppcDe = new ContentDocumentLink();
		oppcDe.ContentDocumentId = conDoc;
		oppcDe.LinkedEntityId = opp.Id;
		oppcDe.ShareType = 'I'; // Inferred permission
		oppcDe.Visibility = 'AllUsers'; // 'SharedUsers'; //
		insert oppcDe;

		//Create ContentDocumentLink for Contract
		ContentDocumentLink cDe = new ContentDocumentLink();
		cDe.ContentDocumentId = conDoc;
		cDe.LinkedEntityId = con.Id;
		cDe.ShareType = 'I'; // Inferred permission
		cDe.Visibility = 'AllUsers'; // 'SharedUsers'; //
		insert cDe;

		return con.Id;
	}

	@AuraEnabled
	public static void generateStripePlan(Id recordId){
        CustomerContractService.generatePlan_Stripe(recordId);
	}

	@AuraEnabled
	public static void handleManualContract(Id recordId){

		generateStripePlan(recordId);

		Contract con = new Contract(Id = recordId);
		con.EverSign_Doc_Hash__c = '-';

		//init community url
		Blob hmacData = Crypto.generateMac('HmacSHA256', Blob.valueOf(recordId + '.-'), Blob.valueOf(HMACSECRETKEY));
		String Hmac = EncodingUtil.convertToHex(hmacData);
		String communityURL = External_API_Key__c.getOrgDefaults().Community_BaseURL__c;//'https://icxdev-weareproject.cs88.force.com/s/notconnected?';
		communityURL += 'contractId=' + recordId;
		communityURL += '&signature=' + Hmac;
		con.Community_Step__c = 2;
		con.Community_URL__c = communityURL;

		update con;
	}

	@AuraEnabled
	public static void pushToEversign(Id recordId){
		Contract con = [
			SELECT Id, Account.Name, Account.PersonEmail, Opportunity__c, EverSign_Doc_Hash__c, 
				   Room__r.Property__r.BrandRef__r.APINameBrand__c, RecordTypeId, Opportunity__r.BrandAuto__c
		    FROM contract
		    WHERE id = :recordId
		];

		PageReference pdfPage = Page.ContractPDF;
		pdfPage.getParameters().put('Id', con.Opportunity__c);

		CustomerContractService contractService = new CustomerContractService();
		String contractName = contractService.getContractTitle(con);

		EverSignModels.payloadEverSign payload;
		if (Test.isRunningTest())
			payload = EverSignService.getPayloadEverSign(
				con.Account.Name, 
				con.Account.PersonEmail, 
				Blob.valueOf('Unit Test'), 
				con.Room__r.Property__r.BrandRef__r.APINameBrand__c,
				contractName
			);
		else
			payload = EverSignService.getPayloadEverSign(
				con.Account.Name, 
				con.Account.PersonEmail, 
				pdfPage.getContent(), 
				con.Room__r.Property__r.BrandRef__r.APINameBrand__c,
				contractName
			);
		String evesignHash = IcxEverSignInterface.CreateDocument(JSON.serialize(payload));

		if (evesignHash == null)
			throw new AuraHandledException('pushToEversign failed');
		con.EverSign_Doc_Hash__c = evesignHash;

		//init community url
		Blob hmacData = Crypto.generateMac('HmacSHA256', Blob.valueOf(recordId + '.' + evesignHash), Blob.valueOf(HMACSECRETKEY));
		String Hmac = EncodingUtil.convertToHex(hmacData);
		String communityURL = External_API_Key__c.getOrgDefaults().Community_BaseURL__c;//'https://icxdev-weareproject.cs88.force.com/s/notconnected?';
		communityURL += 'contractId=' + recordId;
		communityURL += '&signature=' + Hmac;

		update new Opportunity(Id = con.Opportunity__c, Community_URL__c = communityURL, StageName = 'Contract Out');

		update con;
	}

	@AuraEnabled
	public static Map<String, String> getEmailData(String tplId, String recordId){
		Opportunity opp = [SELECT Id, Account.PersonEmail
		                   FROM Opportunity
		                   WHERE Id = :recordId];
		emailtemplate tpl = [select subject, HtmlValue
		                     from emailtemplate
		                     where id = :tplId];
		Map<String, String> result = new Map<String, String>();
		result.put('email', opp.Account.PersonEmail);
		result.put('subject', tpl.Subject);
		result.put('HtmlValue', tpl.HtmlValue);
		return result;
	}
}