public class AircallExtractDataFromSubject {

    /*
    * invocable method
    */
    @InvocableMethod
    public static List<Results> execute(List<Requests> requestList) {
        List<Results> results = new List<Results>();
        for (Requests request : requestList) {
            
            //grab subject from flow
            String subject = request.subject;

            // construct result 
            Results r = new Results();
            r.leadSource = getLeadSource(subject);
            r.property = getPropertyName(subject);
            results.add(r);
        }
        return results;
    }
    
    /*
    * extract property name from open/close parentheses
    *
    * @param String task subject
    * @return String property name
    */
    private static String getPropertyName(String subject) {
        String property;
        // make sure subject contains parentheses 
        if (subject != null &&subject.contains('(') && subject.contains(')')) {
            // extract string between parentheses
            property = subject.substringBetween('(', ')');
        }
        return property;
    }

    /*
    * extract property name from open/close parentheses
    * 
    * @param String task subject
    * @return String lead source
    */
    private static String getLeadSource(String subject) {
        String leadSource;
        if (subject != null) {

            // split subject base on "-"
            List<String> splitStr = subject.split( '-' );

            // ensure split string has 3 items in array
            // assumption - last item is the lead source
            if (splitStr.size() > 2 ) {

                // get lead source mapping from custom metadata set up
                Map<String, String> leadSourceMapping = getLeadSourceMapping();

                // get lead source from subject
                String taskSource = splitStr[2].trim();
                if (leadSourceMapping.get(taskSource) != null) {
                    leadSource = leadSourceMapping.get(taskSource);
                }
            }
        }
        return leadSource;
    }

    /*
    * extract property name from open/close parentheses
    * 
    * @param
    * @return Map<String, String> custom metadata lead source mapping
    */
    public static Map<String, String> getLeadSourceMapping() {
        Map<String, String> leadSourceMap = new  Map<String, String>();
        List<Aircall_Lead_Source_Mapping__mdt> leadSourceMapping = [
            SELECT
                Id,
                Lead_Source__c,
                Task_Source__c
            FROM Aircall_Lead_Source_Mapping__mdt 
        ];

        for (Aircall_Lead_Source_Mapping__mdt lsMapping : leadSourceMapping) {
            leadSourceMap.put(lsMapping.Task_Source__c, lsMapping.Lead_Source__c);
        }
        return leadSourceMap;
    }

    public class Requests {
        @InvocableVariable(label='Subject' description='Aircall Task Subject' required=true)
        public String subject;
    }

    public class Results {
        @InvocableVariable(label='Property Name' description='Property name from Subject')
        public String property;

        @InvocableVariable(label='Lead Source' description='Lead Sourcec from Subject')
        public String leadSource;
  }
}