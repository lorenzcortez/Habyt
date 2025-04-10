public class TwilioUtility {

    public static string FormatPhoneNumber(String PhoneNumber){
        
        if(String.isNotBlank(phoneNumber)){
        
            phoneNumber = phoneNumber.replaceAll('(?!^\\+)[^\\d]','');
            //phoneNumber = phoneNumber.replaceAll('[^\\+|\\d]','');
            //phoneNumber = phoneNumber.replaceAll('/|-| ','');
            
            if(!phoneNumber.StartsWith('+')){
                if(phoneNumber.StartsWith('1')){
                    phoneNumber = '+'+phoneNumber;
                }else {
                    phoneNumber = '+1'+phoneNumber;
                }
            }
            
            phoneNumber = phoneNumber.trim();
        }
        
        return phoneNumber;
    }
}