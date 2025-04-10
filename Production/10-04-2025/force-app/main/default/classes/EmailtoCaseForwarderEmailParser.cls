public class EmailtoCaseForwarderEmailParser {
  
    @InvocableMethod(label='EmailtoCaseForwarderEmailParser' description='This class will accept case id and parse non common email from description and put it on supplied email and also update contact using that email')
    public static void ParseEmailfromCaseDescription(List<ID> ids) {
        list<Case> cases = [select id, SuppliedEmail, ContactID, Description from Case where id in:ids];
        map<id,string> CaseEmailMap = new map<id,string> ();
        
        for(Case c : cases){
            
            list<string> StrDescriptionlist = c.description.split('\n');
            system.debug('StrDescriptionlist sise::'+StrDescriptionlist.size());
            system.debug('StrDescriptionlist::'+StrDescriptionlist);
            
            
            String StrDescription = c.description.replace('\r\n',' ');
            
            Pattern emailPattern = Pattern.compile('([a-zA-Z0-9_\\+-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))');
            
            boolean IsEmailFound = False;
            
            for(string s : StrDescriptionlist){
                s = s.replace('\r\n',' ');
                If(IsEmailFound){ 
                    system.debug('In break:::');
                    break; 
                }
                 
                Matcher matcher = emailPattern.matcher(s);
                while (matcher.find()){   
                    if(matcher.group() != null && !matcher.group().contains('common.com') && !matcher.group().contains('zendesk.com')){
                        IsEmailFound = True;
                        system.debug('In email found:::');
                        CaseEmailMap.put(c.id,matcher.group()); 
                    }
                }        
            }
            
        }
        
        map<string,id> ContactEmailMap = new map<string,id> ();
        list<Contact> existingContacts = [select id,Email from Contact where email in:CaseEmailMap.Values()];
        for(Contact c : existingContacts){
            ContactEmailMap.put(c.Email,c.id);
        }
        
        for(Case c : cases){
            c.SuppliedEmail = CaseEmailMap.get(c.id);
            
            if(CaseEmailMap.get(c.id) != null){
                c.ContactID = ContactEmailMap.get(CaseEmailMap.get(c.id));
            }
        }
        
        update cases;
    }
}