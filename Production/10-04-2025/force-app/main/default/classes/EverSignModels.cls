public with sharing class EverSignModels {
    
    public class hashEverSign {
        public String document_hash;
        public Integer is_draft;
        public Integer is_completed;
        public Integer is_archived;
        public Integer is_deleted;
        public Integer is_trashed;
        public Integer is_cancelled;
        public List<signersEverSign> signers;
    }
    
    public class payloadEverSign {
        public Integer sandbox;
        public Integer is_draft;
        public Integer embedded;
        public String title;
        public String message;
        public Integer use_signer_order;
        public Integer reminders;
        public Integer require_all_signers;
        public String custom_requester_name;
        public String custom_requester_email;
        public String redirect;
        public String redirect_decline;
        public String client;
        public Integer expires;
        public Integer embedded_signing_enabled;
        public Integer flexible_signing;
        public Integer use_hidden_tags;
        public List<fileEverSign> files;
        public List<signersEverSign> signers;
        public List<Object> fields;
    }
    
    public class signersEverSign {
        public Integer id;
        public String name;
        public String email;
        public Integer order;
        public Integer pin;
        public String message;
        public String  deliver_email;
        public String language;
        public String embedded_signing_url;
    }
    
    public class fileEverSign {
        public String name;
        public String file_url;
        public String file_id;
        public String file_base64;
    }
    
    public class fieldEverSign{
        public String type;
        public String x;
        public String y;
        public String width;
        public String height;
        public String page;
        public String signer;
        public String name;
        public String identifier;
        public Integer required;
        public Integer readonly;
        public String validation_type;
        public String text_size;
        public String text_color;
        public String text_font;
        public String text_style;
        public String value;
    }

    public class CancelEverSign {
        public String success;
        public Map<String, Object> error;
    }
}