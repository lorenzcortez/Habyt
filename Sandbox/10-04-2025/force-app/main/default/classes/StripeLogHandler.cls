/**
 * StripeLogHandler Class to handle the Stripe Integration Logs object
 *
 * @author jorge.valdes@empaua.com
 * 
 */
public class StripeLogHandler {

    public static void insertStripeLog(String errorMsg, String payload) {
        StripeIntegrationLog__c stripeLog = new StripeIntegrationLog__c(
            ErrorMessage__c = errorMsg,
            Payload__c = payload
        );

        insert stripeLog;
    }
}