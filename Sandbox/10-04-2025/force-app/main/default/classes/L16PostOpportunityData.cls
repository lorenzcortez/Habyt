public without sharing class L16PostOpportunityData {
    
    public class Requests {
        
        @InvocableVariable(label='Opportunity Id' required=true)
        public string RecordId;
    }
    
    @InvocableMethod(label='L16 - Post Opportunity Information' iconName='slds:standard:opportunity')
    public static void execute (List<Requests> requestList) {
        
        for(Requests req : requestList){
            PostDataToL16(req.RecordId);
        }
    }
    
    
    @future(Callout=true)
    public static void PostDataToL16(String RecordId){
        
        Opportunity opp = [SELECT Id, Home_Committed__c, Home_Committed__r.Home_ID__c, Converted_Lead__c, Preferred_Move_Date__c, Min_Budget__c, Max_Budget__c,
        Account.FirstName, Account.LastName, Account.Phone, Account.PersonEmail, Account.PersonLeadSource
        FROM Opportunity WHERE Id = :RecordId limit 1];
        
        
        L16MemberApplication.Applicants applicant = new L16MemberApplication.Applicants();
        applicant.first_name = opp.Account.FirstName == NULL ? '' : opp.Account.FirstName;
        applicant.last_name = opp.Account.LastName;
        applicant.email = opp.Account.PersonEmail == NULL ? '' : opp.Account.PersonEmail;
        applicant.phone = opp.Account.Phone == NULL ? '' : opp.Account.Phone;
        applicant.lead_applicant = true;

        list<L16MemberApplication.Applicants> MemberApplicants = new list<L16MemberApplication.Applicants>();
        MemberApplicants.add(applicant);

        
        L16MemberApplication.Variables var = new L16MemberApplication.Variables();
        string homeId = '';
        if(opp.Home_Committed__c != NULL && opp.Home_Committed__r.Home_ID__c != NULL)
            homeId = opp.Home_Committed__r.Home_ID__c;
        var.property_id = homeId;
        var.originating_source_lead_id = opp.Account.PersonLeadSource;
        var.leasing_agent_id = '';
        var.applicants = MemberApplicants;        
        string formattedMoveInDate = opp.Preferred_Move_Date__c == NULL? '' : DateTime.newInstance(opp.Preferred_Move_Date__c.year(), opp.Preferred_Move_Date__c.month(), opp.Preferred_Move_Date__c.day()).format('yyyy/MM/dd');
        var.move_in_date = formattedMoveInDate;
        var.max_budget = opp.Max_Budget__c == NULL ? 0 : opp.Max_Budget__c;
        var.min_budget = opp.Min_Budget__c == NULL ? 0 : opp.Min_Budget__c;
        

        L16MemberApplication memberApp = new L16MemberApplication();
        memberApp.operation = 'member_application/sfdc/create_lead_and_email_app';
        memberApp.variables = var;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Common_Louis');
        req.setMethod('POST');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('X-SFDC-SECRET-TOKEN', '{!$Credential.Password}');
        req.setTimeout(120000);
        system.debug(JSON.serialize(memberApp));
        req.setBody(JSON.serialize(memberApp));

        Http http = new Http();
        
        if(!test.isRunningTest()){
            HTTPResponse res = http.send(req);
            System.debug(res.getStatusCode());
            System.debug(res.getBody());
            
            
            if(String.isNotBlank(RecordId) && RecordId.StartsWith('006')){
                Opportunity OppToUpdate = new Opportunity();
                OppToUpdate.Id = RecordId;
                OppToUpdate.L16_Entrata_API_Response__c = res.getBody();
                update OppToUpdate;
            }
        }
        
    }
    
}