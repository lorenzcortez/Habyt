public class TourTriggerHandler {
    
    public static void AfterInsert(list<Tour__c> newTours){
        
        for(Tour__c t: newTours){
            if(t.Tour_Scheduled_Date_Time__c != NULL && t.Home__c != NULL){
                ConverteDateTimeUsingGoogleAPI(t.Id);
            }
        }
    }
    public static void AfterUpdate(list<Tour__c> tours, Map<id,Tour__c> oldTours){
        
        for(Tour__c t: tours){
            if(oldTours.get(t.id).Tour_Scheduled_Date_Time__c != t.Tour_Scheduled_Date_Time__c || oldTours.get(t.id).Home__c != t.Home__c){
                if(t.Tour_Scheduled_Date_Time__c != NULL && t.Home__c != NULL){
                    ConverteDateTimeUsingGoogleAPI(t.Id);
                }
            }
        }
    }
    
    
    @future(callout=true)
    public static void ConverteDateTimeUsingGoogleAPI(Id TourId){
        
        list<Tour__c> Tour = new list<Tour__c>([SELECT Tour_Scheduled_Date_Time__c, Home__c, Home__r.PropertyLocation__latitude__s, Home__r.PropertyLocation__longitude__s FROM Tour__c WHERE Id = :TourId]);
        Tour__c TourToUpdate = new Tour__c();
        if(Tour?.size() > 0 && Tour[0].Home__r.PropertyLocation__latitude__s != NULL && Tour[0].Home__r.PropertyLocation__longitude__s != NULL){
            String api_key = system.label.google_timezone_api_key;
            
            Long dt1Long = datetime.newInstance(1970, 1, 1, 0, 0, 0).getTime();
            Long dt2Long = Tour[0].Tour_Scheduled_Date_Time__c.getTime();
            //The desired time as seconds since midnight, January 1, 1970 UTC. 
            Long timestamp = (dt2Long - dt1Long) / 1000;
            //Long TourDateTimeLong = Tour[0].Tour_Scheduled_Date_Time__c.getTime();
            system.debug(timestamp);
            String location = Tour[0].Home__r.PropertyLocation__latitude__s+','+Tour[0].Home__r.PropertyLocation__longitude__s;
            
            String end_point_url = 'callout:google_timezone_api?location='+location+'&timestamp='+timestamp+'&key='+api_key;
            system.debug('end_point_url::'+end_point_url);
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req.setEndpoint(end_point_url);
            req.setMethod('GET');
            req.setTimeout(12000);
            req.setHeader('Content-Type', 'application/json');
            
            Http h = new Http();
            
            String APIResponse = '';
            Integer ResponseCode = 0;
            
            if(test.isRunningTest()){
                APIResponse = '{'+
                    '   \"dstOffset\" : 3600,'+
                    '   \"rawOffset\" : -18000,'+
                    '   \"status\" : \"OK\",'+
                    '   \"timeZoneId\" : \"America/New_York\",'+
                    '   \"timeZoneName\" : \"Eastern Daylight Time\"'+
                    '}';
                ResponseCode = 200;
            }else{
                res = h.send(req);
                system.debug(res.getStatusCode());
                system.debug(res.getBody());
                APIResponse = res.getBody();
                ResponseCode = res.getStatusCode();
            }
            
            if(ResponseCode == 200){
                googleTimezoneResp.GoogleTimezone TimezoneResp = googleTimezoneResp.parse(APIResponse);
                system.debug(TimezoneResp);
                if(TimezoneResp?.status.equalsIgnoreCase('ok')){
                    datetime ConvertedDateTime = ConvertdatetimetoTimezone(Tour[0].Tour_Scheduled_Date_Time__c, TimezoneResp.dstOffset, TimezoneResp.rawOffset);
                    system.debug('ConvertedDateTime::'+ConvertedDateTime);
                    TourToUpdate.Id = Tour[0].Id;
                    TourToUpdate.Tour_Date_Time_with_Timezone__c = ConvertedDateTime;
                    //TourToUpdate.Tour_Date_Time_with_Timezone_MC__c = Tour[0].Tour_Scheduled_Date_Time__c.addHours(-6);
                    update TourToUpdate;
                }
                
            }
        }
    }
    
    
    public static datetime ConvertdatetimetoTimezone(datetime dateTimeToConvert, integer dstOffSet, integer rawOffset){
        if(dateTimeToConvert != NULL){
            
            Datetime convertedDateTime = dateTimeToConvert;
            
            //Adding the offset from UTC (in seconds) from the google API
            if(rawOffset != NULL)
            convertedDateTime = convertedDateTime.addSeconds(rawOffset);
            //Adding DST Offset from UTC (in seconds) from the google API
            if(dstOffSet != NULL)
                convertedDateTime = convertedDateTime.addSeconds(dstOffSet);
            
            return datetime.newInstance(dateTimeToConvert.Date(), convertedDateTime.Time());
        }else{
            return dateTimeToConvert;
        }
    }
}