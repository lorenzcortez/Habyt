/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-22-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class RunAssignmentRules {
    @InvocableMethod
    public static void assignLeads(List<Id> leadIds){
        System.debug('leadIds '+leadIds);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = TRUE;
        List<Lead> toAssign = [SELECT Id FROM Lead WHERE Id = :leadIds];
        Database.update(toAssign,dmo);
        /*List<Database.SaveResult> urList = Database.update(toAssign,dmo);
        for(Database.SaveResult updateResult : urList) {
            if (updateResult.isSuccess()) {
                System.debug('Lead updated successfully.');
            } else {
                // Iterate over each error
                for(Database.Error error : updateResult.getErrors()) {
                    // Handle or log the error
                    System.debug('Error updating lead: ' + error.getMessage());
                }
            }
        }*/
    }
}