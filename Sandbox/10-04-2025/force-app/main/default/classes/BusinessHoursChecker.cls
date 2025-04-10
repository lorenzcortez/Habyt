/**
 * @description       : 
 * @author            : Bon Karlo Pacante
 * @group             : 
 * @last modified on  : 11-10-2023
 * @last modified by  : Bon Karlo Pacante
**/
public with sharing class BusinessHoursChecker {
    @InvocableMethod
    public static List<Results> execute (List<Requests> requestList) {
        List<Results> results = new List<Results>();
        for (Requests request : requestList) {

            Results result = new Results();
            result.isWithin = BusinessHours.isWithin(request.bhId, system.Now());
            
            results.add(result);
        }
        return results;
    }

    public class Requests {
    @InvocableVariable(label='Record Id' description='yourDescription' required=true)
    public Id bhId;
    }

    public class Results {
        @InvocableVariable(label='Records for Output' description='yourDescription' required=true)
        public Boolean isWithin;
    }
}