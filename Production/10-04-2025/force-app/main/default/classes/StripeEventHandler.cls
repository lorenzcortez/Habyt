public class StripeEventHandler {
    public virtual class StripeEventHandlerException extends Exception {}
    public class UnknownHandlerNameException extends StripeEventHandlerException {}
    public class CustomerNotFoundException extends StripeEventHandlerException {}
    public class UnknownCustomerIdException extends StripeEventHandlerException {}
    public class NoSuchStripeAccountException extends StripeEventHandlerException {}
    public class ContractNotFoundException extends StripeEventHandlerException {}

    public static final String EVENT_NAME_HEAD = 'Stripe';
    public static final String EVENT_NAME_TAIL = 'EventHandler';

    /**
     * This class dynamically decides which handler should be called. It is used in IcxStripeWebhook for handling 
     * Stripe messages to the /swh/v1/* url.
     * 
     * Convention for name: StripeEventNameEventHandler. If the name contains underscore, they are removed.
     * For example for if the event name is Payment_Intent: StripePaymentIntentEventHandler 
     */
    public static void handle(String eventData) {
        String eventType = getEventType(eventData);
        String className = createClassName(eventType);

        if(className == null) {
            throw new UnknownHandlerNameException('Event Name was not found.');
        }

        StripeAbstractEventHandler handler = (StripeAbstractEventHandler) Type.forName(className).newInstance();
        handler.handle(eventData);
    }

	private static String getEventType(String eventData){
        Map<String, Object> event = (Map<String, Object>) JSON.deserializeUntyped(eventData);
		return String.valueOf(event.get('type'));
	}   

	private static String createClassName(String eventType){
        String[] eventParts = eventType?.split('\\.');

        String className = null;
        if(eventParts != null && eventParts.size() > 0) {
            eventParts.remove(eventParts.size() - 1);
            className = EVENT_NAME_HEAD + String.join(eventParts,'') + EVENT_NAME_TAIL;
            
            /* This is a workaround so the method still works with the Customer Subscription event. 
            This patch should be removed after the StripeCustomerEventHandler gets renamed to StripeCustomerSubscriptionEventHandler*/
            //className = EVENT_NAME_HEAD + eventParts[0] + EVENT_NAME_TAIL;
            /*if (className.contains('customersubscription')) {
                className = className.remove('subscription');
            } else */if(className.contains('dispute')) {
                className = className.remove('dispute');
            } else if(className.contains('refund')) {
                className = className.remove('refund');
            }
        }

        className = className.remove('_');
        return className;
	} 

}