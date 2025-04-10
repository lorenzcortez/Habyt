public class googleTimezoneResp {

    public class GoogleTimezone {
        public Integer dstOffset;
        public Integer rawOffset;
        public String status;
        public String timeZoneId;
        public String timeZoneName;
    }

    
    public static googleTimezoneResp.GoogleTimezone parse(String json) {
        return (googleTimezoneResp.GoogleTimezone) System.JSON.deserialize(json, googleTimezoneResp.GoogleTimezone.class);
    }
}