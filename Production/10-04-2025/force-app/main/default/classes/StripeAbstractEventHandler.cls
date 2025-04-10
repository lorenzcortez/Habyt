public abstract class StripeAbstractEventHandler {
    public abstract void handle(String eventData);

    protected String parseToEventDataString(String eventData) {
        Map<String, Object> eventDataMap = (Map<String, Object>) JSON.deserializeUntyped(eventData);
        Map<String, Object> eventObjectMap = (Map<String, Object>) eventDataMap.get('data');
        return JSON.serialize(eventObjectMap.get('object_x'));
    }

    protected String preProcessJson(String eventData) {
        return eventData.replace('number', 'number_x')
                        .replace('object', 'object_x')
                        .replace('currency', 'currency_x')
                        .replace('end', 'end_x')
                        .replace('period_end_x', 'period_end');
    } 
}