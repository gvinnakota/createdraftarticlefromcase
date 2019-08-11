/*******************************************************************************************************************
* Apex Class Name  : updateContactFromUserTriggerHandler
* Version          : 1.0
* Created Date     : 05 Sept 2017
* Function         : Class is used to populate User information into Contact records
* Modification Log :
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Ranjithkumar Udhaya        05/09/2017              Intial version (Update User information into Contact Records.)
* Rohan Kolvekar             07/09/2017              Updated updateContact() method to update contact records checkbox based on user profile
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
public class UpdateContactFromUserTriggerHandler{
    static List<PortalUserCreationMap__c > cSRecordsList =PortalUserCreationMap__c.getAll().Values();
    static String userId = DataValueMap__c.getInstance('PortalUserProfileId').Data_Value__c;
    static String L1ProfileId = DataValueMap__c.getInstance('PortalRegisteredUserId').Data_Value__c; // Added By Rohan as the part of JIT Flow
    static String L2ProfileId = DataValueMap__c.getInstance('PortalUserProfileId').Data_Value__c; // Added By Rohan as the part of JIT Flow
    static String userQuery = 'SELECT Phone ,ProfileId ';
    static String contactQuery = 'SELECT Customer_Admin__c,Interact_with_Community__c,Enable_Portal_User__c,View_Account_Cases__c';
    public static void updateContactEnablePortalUserField(List<User> lstUser, Map<Id,User> OldMap,Boolean isInsert,Boolean isUpdate){
        set<Id> contactIds = new set<Id>(); 
        for(User usr : lstUser){
            if(isInsert)
                if(usr.isActive && usr.contactId != null)
                contactIds.add(usr.contactId);
            if(isUpdate){
                System.debug('User Created in UAA: ' + usr.User_Created_in_UAA__c);
                if(usr != oldMap.get(usr.id) && usr.contactId != null && (usr.User_Created_in_UAA__c == 'No' &&
                   oldMap.get(usr.id).get('User_Created_in_UAA__c') != usr.User_Created_in_UAA__c)){
                    contactIds.add(usr.contactId);
                }
                for(PortalUserCreationMap__c cSFields : cSRecordsList){
                    if(usr.get(csFields.Name) != oldMap.get(usr.id).get(csFields.Name) && usr.contactId != null){
                        contactIds.add(usr.contactId);
                        if(!userQuery.contains(csFields.Name))
                            userQuery = userQuery + ' , ' + cSFields.Name;
                        if(contactQuery.contains(csFields.Source__c))
                            contactQuery = contactQuery+' , '+csFields.Source__c;
                    }
                    
                }
            }
        } 
        if(!contactIds.isEmpty()){
            updateContact(contactIds);
        }
    }
    
    @future
    public static void updateContact(set<Id> contactIds){
        System.debug('Inside updateContact');
        List<contact> lstContact = new List<Contact>();
        Map<Id,sObject> mapUser = new Map<Id, sObject>();
        String managerId = DataValueMap__c.getInstance('PortalManagerProfileId').Data_Value__c;     
        Map<Id,User> mapContact = new Map<Id,User>();
        for(PortalUserCreationMap__c cSFields : cSRecordsList){
            if(!userQuery.contains(csFields.Name))
                userQuery = userQuery + ' , ' + cSFields.Name;
            if(!contactQuery.contains(csFields.Source__c))
                contactQuery = contactQuery+' , '+csFields.Source__c;
        }
        userQuery+= ' FROM User WHERE contactId =:contactIds';
        contactQuery+= ' FROM Contact WHERE id =:contactIds';
        List<User> lstUser = Database.query(userQuery);
        for(User usr : lstUser){
            mapUser.put(usr.contactId, usr);
        }
        System.debug('Inside updateContact 2');
        for(SObject sObj: (List<SObject>)Database.query(contactQuery)){
            Contact con = (contact) sObj;
            User usr = (user)mapUser.get(con.id);
            for(PortalUserCreationMap__c cSFields : cSRecordsList){
            /*By Pass update to username on User to be updating Contact's Email*/
               if(!('username').equalsIgnoreCase(cSFields.Name)){
                    if(cSFields.Name != 'ContactId' && cSFields.Name != 'IsActive' ){
                        System.debug('Inside updateContact 3');
                        con.put(csFields.Source__c,usr.get(csFields.Name));
                    }else if(cSFields.Name == 'IsActive' && usr.ProfileId == userId){
                        System.debug('Inside updateContact 4');
                        con.put(csFields.Source__c,usr.get(csFields.Name));
                    } 
              }
            }
            
            //con.Customer_Admin__c = (usr.ProfileId==managerId ?true : false);
            /* Rohan's changes starts  for WR 2161*/
            if(usr.isActive = true) {
                
            if(usr.ProfileId==L1ProfileId)
            {
                con.Interact_with_Community__c = true; 
                con.Enable_Portal_User__c = false;
                con.View_Account_Cases__c = false;
                con.Customer_Admin__c = false;  
                con.Update_check__c =false;
                System.debug('Inside l1 in user');
            }
            else if(usr.ProfileId==L2ProfileId)
            {
                con.Interact_with_Community__c = true;
                con.Enable_Portal_User__c=true;
                con.Customer_Admin__c = false;
                con.Update_check__c =false;
                 System.debug('Inside l2 in user');
            }
            else if(usr.ProfileId==managerId)
            {
                con.Interact_with_Community__c = true;
                con.Enable_Portal_User__c = true;
                con.View_Account_Cases__c = true;
                con.Customer_Admin__c = true;
                con.Update_check__c =false;
                System.debug('Inside l3 in user');
            }
        }
            
            /* Rohan's changes Ends for WR #2161*/
            
            con.Zuora_Future__c = True;
            lstContact.add(con);
        }  
        if(!lstContact.isEmpty()){
            checkRecursive.checkContact = false;
            if(!Test.isRunningTest())
            	update lstContact;
            System.debug('Inside updateContact 5');
        }  
    }
}