public class SendGridEmailBody {

    public List<Personalizations> personalizations {get;set;} 
    public List<attachments> attachments {get;set;} 
    
    public To from_Z {get;set;}
    public To reply_to {get;set;} 
    public String template_id {get;set;}
    public map<string, string> custom_args {get;set;}
    public list<String> categories {get;set;}
    
    public class To {
        public String email {get;set;} 
        public String name {get;set;}
    }
    
    public class Personalizations {
        public List<To> to {get;set;} 
        public List<To> cc {get; set;}
        public List<To> bcc {get; set;}
        public map<string, string> dynamic_template_data {get;set;}
        public map<string, string> custom_args {get;set;}
        public Long send_at {get; set;}
    }
    
    public class attachments{
        public string content {get; set;}
        public string type {get; set;}
        public string filename {get; set;}
    }
}