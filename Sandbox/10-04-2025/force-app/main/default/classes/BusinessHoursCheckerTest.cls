/**
 * @description       : 
 * @author            : Bon Karlo Pacante
 * @group             : 
 * @last modified on  : 11-10-2023
 * @last modified by  : Bon Karlo Pacante
**/

@isTest
public class BusinessHoursCheckerTest {
    
    @isTest
    static void scenario(){

        List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];

        System.debug('BusinessHours' + bhs);

        List<BusinessHoursChecker.Requests> requestList = new List<BusinessHoursChecker.Requests>();
        BusinessHoursChecker.Requests request = new BusinessHoursChecker.Requests();
        request.bhId = bhs[0].Id;

        requestList.add(request);

        Test.startTest();
        BusinessHoursChecker.execute(requestList);
        Test.stopTest();
    }
}