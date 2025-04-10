public class IcxOppInterface {
    @AuraEnabled
    public static Opportunity getOppDetails(id recordId) {
        return [select Id, Country__c, City__c, Start_Date__c, Account.PersonEmail FROM Opportunity WHERE Id = :recordId];
    }
    
    @AuraEnabled
    public static List<Room__c> getRooms(String city, String country,Id recordId) {
        return [select Id, Name, Property__c, Property__r.City__c, Property__r.Area__c,Price__c, HA__c, Number_of_windows__c,Property__r.Name,Description__c,
                (select id, name,Move_out_date__c,StartDate,ContractNumber from contracts__r where status != 'Draft' and status != 'Terminated'  and status != 'Canceled' ),
                (select id, name,StageName,Start_Date__c from opportunities__r where StageName != 'Closed Won' AND StageName != 'Closed Lost' AND Id != :recordId)
                FROM Room__c 
                WHERE Property__r.Country__c = :country
               AND Property__r.City__c = :city
               AND Property__r.Stage__c = 'Launched'];
    }
    
    public class RoomAndStatus {
        Public Room__c room {get;set;}
        Public String Status {get;set;}
        Public String ContractId {get;set;}
    }
    
    //return a LIST<RoomAndStatus>
    @auraEnabled
    public static String getRoomsWithStatus(Id oppId) {
        Set <Id> oppRooms = new Set<Id>();
        Set <Id> contractRooms = new Set<Id>();
        Map <Id, Id> contractRoomsMap = new Map<Id, Id>();
        List<RoomAndStatus> customRooms = new List<RoomAndStatus>();
        Opportunity opp = [SELECT Country__c, City__c, Start_Date__c FROM Opportunity WHERE Id = :oppId];
        String query = 'SELECT Id, Name, Property__c, Property__r.City__c, Property__r.Area__c FROM room__c';
        
        if (opp.Country__c != null || opp.City__c != null) {
            query += ' WHERE';
            if (opp.Country__c != null) query += ' Property__r.Country__c = \''+opp.Country__c+'\'';
            if (opp.Country__c != null && opp.City__c != null) query += ' AND';
            if (opp.City__c != null) query += ' Property__r.City__c = \''+opp.City__c+'\'';
        }
        System.debug('query = ' + query);
        List <Room__c> rooms = Database.query(query);
        System.debug('rooms = ' + rooms);
        for (Opportunity op :[SELECT Room__c FROM Opportunity WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost' AND Id != :oppId]) {
            oppRooms.add(op.Room__c);
        }
        
        for (Contract con :[SELECT Id, Room__c, EndDate  FROM Contract WHERE (startDate > :opp.Start_Date__c OR EndDate > :opp.Start_Date__c ) ORDER BY EndDate DESC]) {
            contractRoomsMap.put(con.Room__c, con.Id);
            contractRooms.add(con.Room__c);
        }
        
        
        for (Room__c room: rooms) {
            RoomAndStatus ras = new RoomAndStatus();
            ras.room = room;
            if (contractRoomsMap.containsKey(room.Id)) { 
                ras.Status = 'error';
                ras.ContractId = contractRoomsMap.get(room.Id);
            } else if (oppRooms.contains(room.Id)) ras.Status = 'warning'; 
            else ras.Status = 'like';
            
            customRooms.add(ras);
        }
        return JSON.serialize(customRooms);
    }
    
    @auraEnabled
    public static void setRoomOnOpp(Id oppId, Id RoomId) {
        Room__c room = [SELECT STRIPE_Product_Id__c, Name, property__r.Billing_Entity__r.Stripe_Account__r.secret_key__c  FROM Room__c WHERE Id =:RoomId];
        if (room.STRIPE_Product_Id__c == null)  {
            Map<String, Object> stripe_product = (Map<String, Object>)JSON.deserializeUntyped(StripeService.postToStripe('products', 'type=service&name='+room.Name, room.property__r.Billing_Entity__r.Stripe_Account__r.secret_key__c));
            room.STRIPE_Product_Id__c = (String)stripe_product.get('id');
            update room;
        }
        
        update new Opportunity(Id = oppId, Room__c  = RoomId);
    }

    @auraEnabled
    public static String getAccountEmail(Id oppId) {
        return [select Account.PersonEmail FROM Opportunity WHERE ID = : oppId].Account.PersonEmail;
    }
    
    @AuraEnabled
    public static EmailTemplate getTemplate(String tplId) {
        System.debug('tplId = ' + tplId);
        return [select subject,HtmlValue from emailtemplate where id=:tplId ];
    }
    
    @AuraEnabled
    public static List<Opportunity> getOppsOnThisRoom(String roomId, String actualOpp) {
        return [SELECT Id, Name FROM Opportunity WHERE StageName != 'Closed Won' AND StageName != 'Closed Lost' AND Room__c = :roomId AND Id != :actualOpp];
    }
    
}