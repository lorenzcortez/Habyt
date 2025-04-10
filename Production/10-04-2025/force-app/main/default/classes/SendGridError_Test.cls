@IsTest
public class SendGridError_Test {
    
    static testMethod void testParse() {
        String json = '{\"errors\":[{\"message\":\"The provided authorization grant is invalid, expired, or revoked\",\"field\":\"identified1\",\"help\":null}]}';
        SendGridError obj = SendGridError.parse(json);
        System.assert(obj != null);
    }
}