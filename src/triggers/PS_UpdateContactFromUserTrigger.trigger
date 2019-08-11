/*******************************************************************************************************************
* Apex TriggerName  : updateContactFromUserTrigger
* Version           : 1.0
* Created Date      : 05 Sept 2017
* Function          : User Trigger
* Modification Log  :
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Ranjithkumar Udhaya        05/09/2017              Intial version (Update User information into Contact Records.)
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
trigger PS_UpdateContactFromUserTrigger on User (after insert, after update) {
    if(checkRecursive.runUserTrigger()){
        updateContactFromUserTriggerHandler.updateContactEnablePortalUserField(Trigger.New, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
    }
    
    /*
    Map<String , PermissionSetAssignment> psaMap = new Map<String, PermissionSetAssignment>();
    set<String> keySetToValidateDuplicate = new set<String>();
    String permissionSetId = '0PSf0000000DNtBGAW';
    for(user usr :Trigger.new){
        System.debug('View All=='+usr.View_All__c);
        if(usr.contactId != null && usr.View_All__c && usr.isActive && ((Trigger.isUpdate && usr.IsActive != Trigger.oldMap.get(usr.Id).isActive))){
            String key = permissionSetId+''+usr.Id;
            psaMap.put(key,new PermissionSetAssignment 
      			  (PermissionSetId = permissionSetId, AssigneeId = usr.Id));
        }
    }
    
    
    if(!psaMap.isEmpty()){
        for(PermissionSetAssignment psa : [SELECT Id, PermissionSetId,AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId = '0PSf0000000DNtB' and AssigneeId =: Trigger.newMap.KeySet()]){
            User usr = Trigger.newMap.get(psa.AssigneeId);
            String Key = permissionSetId+''+psa.AssigneeId;
            if(psaMap.containsKey(key)){
                psaMap.remove(key);
            }
   		}
        if(!psaMap.isEmpty())
       		 Database.Insert(psaMap.values());
    }*/
    
    if(Trigger.isAfter && Trigger.isUpdate){
        list<User> userList = new list<User>();
        for(user usr :Trigger.new){
            if(usr.contactId != null && usr.View_All__c && usr.isActive && ((Trigger.isUpdate && usr.IsActive != Trigger.oldMap.get(usr.Id).isActive))){
            	userList.add(usr);
            }
        }
        if(!userList.isEmpty())
        	PS_ContactTriggerHandler.managePermissionSet(userList);
    }
   
}