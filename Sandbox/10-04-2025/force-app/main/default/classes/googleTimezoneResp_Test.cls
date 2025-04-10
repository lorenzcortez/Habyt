@IsTest
public class googleTimezoneResp_Test {
    
    static testMethod void testParse() {
        String json = '{'+
        '   \"dstOffset\" : 3600,'+
        '   \"rawOffset\" : -18000,'+
        '   \"status\" : \"OK\",'+
        '   \"timeZoneId\" : \"America/New_York\",'+
        '   \"timeZoneName\" : \"Eastern Daylight Time\"'+
        '}';
        googleTimezoneResp.GoogleTimezone obj = googleTimezoneResp.GoogleTimezone.parse(json);
        System.assert(obj != null);
    }
}