@istest
public class AircallExtractDataFromSubjectTest {

    static testMethod void doTest() {

        String subject = 'Missed Call from +18554580787 Aircall new lead on Common - General (Capitol) - Apts.com';

        Test.startTest();

            AircallExtractDataFromSubject.Requests r = new AircallExtractDataFromSubject.Requests();
            r.subject = subject;

            List<AircallExtractDataFromSubject.Results> result = AircallExtractDataFromSubject.execute( 
                new AircallExtractDataFromSubject.Requests[]{r}
            );

            system.assertNotEquals( null, result[0].leadSource);
            system.assertEquals('Capitol', result[0].property);

        Test.stopTest();
    }

}