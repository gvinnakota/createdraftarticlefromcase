/*******************************************************************************************************************
* Apex Class Name  : PS_ContactTriggerHandler
* Test Class Name  : PS_ContactTriggerHandler_TC
* Version          : 1.0
* Created Date     : 26 July 2017
* Function         : class is used to Update the Profile based on the Customer Admin and Enable Portal User     Fields Present in contact detail Page. 
IF the Customer Admin Field will be True then Profile will be Customer Community Plus Login Manager and 
If Enable Portal User Field will be True then Profile will be Customer Community Plus Login User
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Hemavathi 
Amit Kumar               7/26/2017                intial version
Deepa Lakamanhalli       11/09/2017               Auto Populate business hours based on time zone selected on Contact
Rohan Kolvekar           20/02/2018               User Story #1729 Made changes to accountShareAccess() method to give access to Contact's case and Accounts based on AccountContactRelation
Rohan Kolvekar           9/03/2018                JIT flow to update the user profile whenever the DPL status is changed
Soham Banerjee           22/03/2018               User Story# 2239 - Ability to freeze/archive Discussion 
threads that a user who failed DPL initiated
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
/*class is used to Update the Profile based on the Customer Admin and Enable Portal User Fields Present in contact detail Page*/
public without sharing Class PS_ContactTriggerHandler{
    //Custom Setting Values 
    static String managerId = DataValueMap__c.getInstance('PortalManagerProfileId').Data_Value__c;
    static String portalUserProfileId = DataValueMap__c.getInstance('PortalUserProfileId').Data_Value__c;
    static String regAccountId = DataValueMap__c.getInstance('RegisteredAccount').Data_Value__c; // Added by srinath as part of user creation
    static String L1ProfileId = DataValueMap__c.getInstance('PortalRegisteredUserId').Data_Value__c; // Added By Rohan as the part of JIT Flow
    static String L2ProfileId = DataValueMap__c.getInstance('PortalUserProfileId').Data_Value__c; // Added By Rohan as the part of JIT Flow
    static String L0ProfileId = DataValueMap__c.getInstance('PivotalSupportProfile').Data_Value__c;
    static List<PortalUserCreationMap__c > cSRecordsList =PortalUserCreationMap__c.getAll().Values();
    public static boolean check = true;
    static Map<String,UAA_Callout__c> uaaValues = UAA_Callout__c.getAll();
    static Map<Id,Id> contactIdAccountIdMap = new Map<Id,Id>();
    /* Method to create portal User whenever a contact is created */   
    public static void createPortalUser(){
        
        Map<Id,Contact> contactsMap = new Map<Id,Contact>();
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        Map<Id,user> userMap = new Map<Id,user>();
        Set<Id> contactId = new Set<id>();
        String contactIds ;
        String contactViewAllIds ;
        Set<Id> contactIdToRemoveViewAll = new set<Id>();
        List<Id> viewAllAccountCasesContactIdList = new List<Id>();
        Map<Id,Contact>viewAllAccountCasesContactIdMap = new Map<Id,Contact>();
        List<Id> removeViewAllAccountCasesContactIdList = new List<Id>();
        Boolean accounShareDeletedBln = false;
        List<User> filteredUserList = new List<User>();
        Map<Id,User> contactIdUserMap = new Map<Id,User>(); 
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){ 
            for(contact con: (List<Contact>)Trigger.New){ 
                contactIdAccountIdMap.put(con.Id, con.AccountId);
                if(Trigger.isInsert){
                    contactMap.put(con.Id,con);  
                }else{ 
                    Contact oldContact = (Contact) Trigger.OldMap.get(con.Id);
                    for(PortalUserCreationMap__c cSFields : cSRecordsList){
                        if(con.Customer_Admin__c != oldContact.Customer_Admin__c || 
                           con.get(cSFields.Source__c) != oldContact.get(cSFields.Source__c)||
                           con.RPS_Status__c != oldContact.RPS_Status__c||
                           con.Enable_Portal_User__c!= oldContact.Enable_Portal_User__c||
                           con.DPL_Status__c!=oldContact.DPL_Status__c||
                           con.Export_Status__c!=oldContact.Export_Status__c||
                           con.Interact_with_Community__c!=oldContact.Interact_with_Community__c ||
                           con.Embargo_Country__c != oldContact.Embargo_Country__c ||
                           con.RPS_Date__c != oldContact.RPS_Date__c){
                             contactMap.put(con.Id,con); 
                           } 
                        if(con.Customer_Admin__c != oldContact.Customer_Admin__c){
                            contactIds = contactIds +','+con.Id; 
                        }                        
                    }
                    contactId.add(con.Id);
                    if(con.View_Account_Cases__c != oldContact.View_Account_Cases__c){
                        contactViewAllIds = contactViewAllIds +','+con.Id;
                    }                     
                }

               if((con.View_Account_Cases__c) && (Trigger.isInsert || (Trigger.isUpdate && con.View_Account_Cases__c != ((Contact)Trigger.OldMap.get(con.Id)).View_Account_Cases__c ))){
                    //viewAllAccountCasesContactIdList.add(con.Id);
                    viewAllAccountCasesContactIdMap.put(con.Id,con);
               } 
               else if(Trigger.isUpdate && con.View_Account_Cases__c != ((Contact)Trigger.OldMap.get(con.Id)).View_Account_Cases__c && !con.View_Account_Cases__c){
                    //viewAllAccountCasesContactIdList.add(con.Id);
                    viewAllAccountCasesContactIdMap.put(con.Id,con);
                    //contactIdToRemoveViewAll.add(con.Id);
                    accounShareDeletedBln = true;
               }
            }
            if(Trigger.isUpdate && !contactId.isEmpty()){
                Set<Id> updatePortalUserContact = new Set<Id>();
                for(User usr : [SELECT Id, ContactId , contact.AccountId,AccountId,View_All__c,
                                contact.View_Account_Cases__c,ProfileId,isActive
                                FROM user 
                                WHERE contactId =:contactId]){
                    contactIdUserMap.put(usr.ContactId, usr);
                    if(contactMap.containsKey(usr.ContactId)){
                        updatePortalUserContact.add(usr.ContactId); 
                        if(contactIds!= null && contactIds.contains(usr.ContactId)){ 
                            usr.ProfileId = (contactMap.get(usr.ContactId).Customer_Admin__c ? managerId : portalUserProfileId);
                            userMap.put(usr.Id,usr);
                        }
                        contactMap.remove(usr.ContactId);
                    }
                    if(contactViewAllIds != null && contactViewAllIds.contains(usr.ContactId)){
                        userMap.put(usr.Id,usr);
                    } 
                }
                /*list<User> removeViewAllAccessToUser = new list<User>();
                for(User usrRecord : userMap.values()){ 
                    if(viewAllAccountCasesContactIdList.contains(usrRecord.ContactId)) 
                       filteredUserList.add(usrRecord);
                    if(contactIdToRemoveViewAll.contains(usrRecord.ContactId)){
                        removeViewAllAccessToUser.add(usrRecord);
                    }
                }
                if(!filteredUserList.isEmpty()){
                    createAccountShareRecords(filteredUserList, contactIdAccountIdMap);
                }  
                if(!removeViewAllAccessToUser.isEmpty()){
                    deleteAccountShareRecords(removeViewAllAccessToUser, contactIdAccountIdMap);
                } */
               
                //added by rohan as the part of WR #2125
                if(updatePortalUserContact.size() > 0){ 
                    PS_ContactTriggerHandler.updatePortalUserRecord(updatePortalUserContact);
                    PS_ContactTriggerHandler.UpdateContactCheckbox(updatePortalUserContact);
                }
                if(!userMap.isEmpty() && contactViewAllIds != null){
                    //PS_ContactTriggerHandler.accountShareAccess(userMap,contactViewAllIds, true);
                    managePermissionSet(userMap.KeySet());
                } 
                if(!userMap.isEmpty() && contactIds != null){
                    PS_ContactTriggerHandler.accountShareAccess(userMap,contactIds,false); 
                } 
                 
         }

            
            //Insert new user record
            if(!contactMap.isEmpty()){ 
                List<User> userToInsert = new List<User>();
                for(Contact cont :contactMap.Values()){ 
                    if(cont.Interact_with_Community__c) userToInsert.add(newPortalUserFormat(cont));
                }
                if(userToInsert.size()>0){ 
                    try{ checkRecursive.checkUser = false;
                        insert userToInsert;
                       
                        Integer i = 0;
                        List<Integer> indexIntegerList = new List<Integer>();
                        set<Id> userIds = new set<Id>();
                        for(User usrRecord : userToInsert){
                            if(viewAllAccountCasesContactIdList.contains(usrRecord.ContactId)) {
                                filteredUserList.add(usrRecord);
                                indexIntegerList.add(i);                                
                            }
                            i++;
                            userIds.add(usrRecord.Id);
                        }
                         managePermissionSet(userIds);
                        for(Integer intCount : indexIntegerList){
                            userToInsert.remove(intCount);
                        }
                        //for the users check the contact's View Cases for Account
                        if(Trigger.isUpdate){
                            for(User userRecord : userToInsert){
                                if(((Contact)Trigger.newMap.get(userRecord.ContactId)).View_Account_Cases__c && 
                                    ((Contact)Trigger.newMap.get(userRecord.ContactId)).View_Account_Cases__c == ((Contact)Trigger.oldMap.get(userRecord.ContactId)).View_Account_Cases__c && 
                                    !contactIdUserMap.containsKey(userRecord.ContactId)){
                                    filteredUserList.add(userRecord);
                                }
                            }
                        }
                        
                        //if(filteredUserList.size() > 0) createAccountShareRecords(filteredUserList, contactIdAccountIdMap);
                        createUsersInUAA(userToInsert);
                    }catch(Exception e){ 
                        ErrorLog.CreateER(e);//Exception captured in Utility Class Errorlog
                    }
                }
            }
        }
    }//End of Method
    @future
    private static void managePermissionSet(set<Id> userIds){
        List<User> userList = [SELECT Id, IsActive,View_All__c, Contact.View_Account_Cases__c FROM User WHERE Id=:userIds];
        managePermissionSet(userList);
    }
    
    public static void managePermissionSet(List<user> userList){
        Map<String,PermissionSetAssignment> grantPermissionMap = new Map<String,PermissionSetAssignment>();
        List<PermissionSetAssignment> removePermissionList = new List<PermissionSetAssignment>();
        set<Id> userIds = new set<Id>();
        String permissionSetId = DataValueMap__c.getInstance('Pivotal - AccountShare Access').Data_Value__c;
        for(User usr : userList){
            if(usr.View_All__c && usr.IsActive){
                PermissionSetAssignment  psa = new PermissionSetAssignment 
                  (PermissionSetId = permissionSetId, AssigneeId = usr.Id);
                String key = permissionSetId +''+ usr.Id;
                grantPermissionMap.put(key, psa);
            }
            userIds.add(usr.Id);
        }
        for(PermissionSetAssignment psa : [SELECT Id ,PermissionSetId ,AssigneeId FROM PermissionsetAssignment WHERE PermissionSetId =: permissionSetId and AssigneeId =: userIds]){
            removePermissionList.add(psa);
            String key = psa.PermissionSetId +''+ psa.AssigneeId;
            grantPermissionMap.remove(Key);           
        }
        if(!grantPermissionMap.isEmpty()){
            if(!Test.isRunningTest())
            insert grantPermissionMap.values();
        }
        if(!removePermissionList.isEmpty()){
            delete removePermissionList;
        }
    }
   
    /***************************************************************************************************** 
    Method Name:        createUserInUAA
    @return  :          void
    @parameters:        userRecordList - List of Users to be created in UAA
    Description:        User Story# 2289 - Call method in UAACalloutApexController class UAA to create new 
    User for the new Portal User created in Salesforce.
    Added By:           Accenture - SB - 11/04/2018
    Modified By:        Date:       Changes: 
    
    ******************************************************************************************************/
    private static void createUsersInUAA(List<User> userRecordList){
        List<User> userListToBeUpdated = new List<User>();
        Map<String,String> userFieldValuesMap = new Map<String,String>();
        for(User userRecord : [SELECT Id, Name, IsActive,FirstName, LastName, Source_of_Creation__c, Email, 
                                Phone, CreatedDate
                                FROM User
                                WHERE Id IN :userRecordList]){ if(userRecord.Source_of_Creation__c == 'Salesforce UI'){    userFieldValuesMap.put(String.valueOf(userRecord.Id),'FirstName=' + userRecord.FirstName +
                                       ',LastName=' + userRecord.LastName +
                                       ',Email=' + userRecord.Email +
                                       ',CreatedDate=' + userRecord.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss') + '.918Z' +
                                       ',Phone=' + userRecord.Phone);    
            }
        }
        if(!Test.isRunningTest()) UAACalloutApexController.createUserInUAA(userFieldValuesMap);
    }
    
    /* Create Portal User */
    public static user newPortalUserFormat(Contact contObj){ User usrRecord = new User();  
        try{ 
            for(PortalUserCreationMap__c cSFields : cSRecordsList){ 
                usrRecord.put(cSFields.Name,contObj.get(cSFields.Source__c));
            }
            usrRecord.EmailEncodingKey = 'ISO-8859-1';
            String keyToNickName = contObj.LastName+contObj.Email+contObj.FirstName;
            String Nickname = generateRandomString(12,keyToNickName);
            usrRecord.Alias = generateRandomString(6,Nickname);
            usrRecord.CommunityNickname = Nickname;
            //If the contact Account is a Standard Account then the portal user will be created with Regestered community user profile
            
            if(contObj.AccountId == regAccountId ) usrRecord.ProfileId = L1ProfileId ;    
            // Added by Rohan as the part of WR 2161 starts
            
            else if(contObj.Interact_with_Community__c && !contObj.Enable_Portal_User__c && !contObj.View_Account_Cases__c && !contObj.Customer_Admin__c && contObj.AccountId != regAccountId) usrRecord.ProfileId = L1ProfileId;    
            else if(contObj.Interact_with_Community__c && contObj.Enable_Portal_User__c && !contObj.Customer_Admin__c && contObj.AccountId != regAccountId) usrRecord.ProfileId = portalUserProfileId;        
            else if(contObj.Interact_with_Community__c && contObj.Enable_Portal_User__c && contObj.View_Account_Cases__c  && contObj.Customer_Admin__c && contObj.AccountId != regAccountId) usrRecord.ProfileId = managerId;
            
            if(contObj.DPL_Status__c != 'Restricted') usrRecord.isActive = true;
        }catch(Exception e){ ErrorLog.CreateER(e);
        }
        // Added by Rohan as the part of WR 2161 Ends
        return usrRecord;
    }
    /* Update Portal User */
    @future
    public static void updatePortalUserRecord(Set<Id> contactRecIds){
        Map<Id,User> userToUpdate = new Map<Id,User>();
        Map<Id, User> userFailedDPLMap = new Map<Id, User>();
        Set<Id> userIds = new Set<Id>();
        String query = 'SELECT Customer_Admin__c , Language__c,Interact_with_Community__c, RPS_Status__c,Embargo_Country__c,DPL_Status__c,Enable_Portal_User__c,Update_check__c'; // Added By Rohan as the part of JIT Flow
        //Get all fields from Custom Settings.
        for(PortalUserCreationMap__c cSFields : cSRecordsList){ 
            if(!query.containsIgnoreCase(cSFields.Source__c)) 
                query = query + ' , ' + cSFields.Source__c;
        }
        query = query + ' FROM Contact WHERE id=: contactRecIds';
        Map<Id, sObject> contactMap = new Map<Id,sObject>();
        contactMap.putAll(Database.query(query));
        list<user> userList = new List<user>();
        for(User usr : [SELECT Id, isActive ,ProfileId,FederationIdentifier,ContactId,View_All__c, Contact.View_Account_Cases__c, AccountId FROM User WHERE ContactId =:contactRecIds]){ 
            if(contactMap.containsKey(usr.ContactId)){ 
                Contact cont = (contact)contactMap.get(usr.ContactId);
                for(PortalUserCreationMap__c cSFields : cSRecordsList){ 
                    String byPass = 'ContactId,UserName,FederationIdentifier';
                    if(!byPass.containsIgnoreCase(cSFields.Name) && cSFields.Source__c !='Enable_Portal_User__c') 
                        usr.put(cSFields.Name,cont.get(cSFields.Source__c)); //Added by Mrunmai for updating Registered User to Community User
                    else if(cSFields.Source__c =='Enable_Portal_User__c' && cont.Interact_with_Community__c==True && usr.ProfileId == L1ProfileId && cont.DPL_Status__c=='Unrestricted') 
                        usr.ProfileId =  portalUserProfileId;
                    if(cSFields.Name=='FederationIdentifier' && usr.FederationIdentifier == null){
                        usr.put(cSFields.Name,cont.get(cSFields.Source__c));
                    }
                   
                }                   
                //usr.ProfileId = (cont.Customer_Admin__c ? managerId : portalUserProfileId); // Commented by Soham as the part of User registration
                userToUpdate = profileAssignment(Usr,cont); 
                // Changes made by Rohan for WR #2161
                if(cont.DPL_Status__c == 'Restricted'){
                    usr.IsActive = false;
                    userFailedDPLMap.put(usr.Id,usr);
                }
                else usr.IsActive = cont.Interact_with_Community__c; 
                // Changes made by Rohan for WR #2161
                userToUpdate.put(usr.Id,usr);    
            }
            userList.add(usr);
            userIds.add(usr.Id);
        }
        if(!userToUpdate.isEmpty()){
            try{   
                checkRecursive.checkUser = false;
                update userToUpdate.values();
            }catch(Exception e){ 
                ErrorLog.CreateER(e);//Exception captured in Utility Class Errorlog
            }
        }
    } 
   
    /*To Update Accountshare to give access for user to Contact, Cases*/
    public static void accountShareAccess(Map<Id,user> userMap, String contactIds , Boolean isViewAll){
        try{ 
            List<AccountShare> accShareToUpdate = new List<AccountShare>();
            Map<AccountShare , Sobject> accShareSobject = new Map<AccountShare,SObject>();
            //  Map<Id,AccountContactRole> contactWithACRMap = new Map<Id,AccountContactRole>(); 
            Map<Id,AccountContactRelation> contactWithACRMap = new Map<Id,AccountContactRelation>(); // Added by Rohan as the part of User story #1729
            List<AccountShare> accShareLst = new List<AccountShare>();
            if(!userMap.isEmpty()){ 
                accShareLst = [SELECT AccountAccessLevel,ContactAccessLevel,CaseAccessLevel, AccountId , userorGroupId FROM AccountShare WHERE UserorGroupId =: userMap.KeySet()];
                if(isViewAll){
                    managePermissionSet(userMap.KeySet());
                }
            }
            if(!userMap.isEmpty() && !accShareLst.isEmpty()){ 
                if(!isViewAll && contactIds != null){
                    String[] contactIdLst = contactIds.split(',');
                    Map<String,PortalObjectAccess__c> portalObjectAccessMap = PortalObjectAccess__c.getAll();
                    //   Map<Id,AccountContactRole> accountContactRoleMap = new Map<Id,AccountContactRole>([Select Id, Role, ContactId , AccountId from AccountContactRole where contactId =: contactIdLst]);
                    Map<Id,AccountContactRelation> accountContactRelationMap = new Map<Id,AccountContactRelation>([Select Id, Roles, ContactId , AccountId from AccountContactRelation where contactId =: contactIdLst]); // Added by Rohan as the part of User story #1729
                    
                    if(!accountContactRelationMap.isEmpty()){
                        for(AccountContactRelation acR : accountContactRelationMap.values()){ 
                            contactWithACRMap.put(acR.AccountId,acR);
                        }
                        for(AccountShare accShare : accShareLst){ user usr = userMap.get(accShare.UserorGroupId);
                            if(usr.AccountId != accShare.AccountId && contactWithACRMap.containsKey(accShare.AccountId)){ String role = String.valueOf(contactWithACRMap.get(accShare.AccountId).Roles).remove('-');
                                String key = usr.ProfileId + role.deleteWhitespace();
                                PortalObjectAccess__c objAccess = portalObjectAccessMap.get(key);
                                String shareKey = accShare.AccountAccessLevel+accShare.ContactAccessLevel+accShare.CaseAccessLevel;
                                String masterKey = objAccess.Account__c+objAccess.Contact__c+objAccess.Case__c;
                                if(shareKey != masterKey){ accShare.AccountAccessLevel = objAccess.Account__c;
                                    accShare.ContactAccessLevel = objAccess.Contact__c;
                                    accShare.CaseAccessLevel = objAccess.Case__c;
                                    accShareToUpdate.add(accShare);
                                    accShareSobject.put(accShare,contactWithACRMap.get(accShare.AccountId));
                                }
                            }
                        }   
                    }
                }
                if(!accShareToUpdate.isEmpty()){ 
                    Database.SaveResult[] srList = Database.update(accShareToUpdate, false);
                }
            }               
        }catch(Exception e){ 
            ErrorLog.CreateER(e);
        }
    }
    /*Method to Associated Case*/
    public static void updateAssociatedCases(Map<Id,Contact> contactMap){ Map<Id,Case> caseMap = new Map<Id,Case>();
        list<case> caseToUpdate = new list<case>();
        String Closed = DataValueMap__c.getInstance('Closed').Data_Value__c;
        for(Case caseObj : [Select Id, ContactId,Contact.BusinessHours__c, BusinessHoursId from case where contactId =: contactMap.KeySet() and Status !=: Closed]){ if(contactMap.containsKey(caseObj.ContactId)){ Contact con = contactMap.get(caseObj.ContactId);
                if(con.BusinessHours__c != null){
                    caseObj.BusinessHoursId = con.BusinessHours__c;
                    caseToUpdate.add(caseObj);
                }
            }
        }
        if(!caseToUpdate.isEmpty()){ try{ Database.SaveResult[] srList = Database.update(caseToUpdate, false);
                for (Database.SaveResult sr : srList) { if (sr.isSuccess()) {System.debug('Successfully updated Case. Case ID: ' + sr.getId());
                    }
                    else {  for(Database.Error err : sr.getErrors()) { insert new Exception_Log__c(Cause__c = string.valueOf(err.getMessage()), Class_Name__c = 'PS_ContactTriggerHandler', Exception_Message__c = err.getStatusCode() + ': ' + err.getMessage() + '- ' + err.getFields(), LineNumber__c = '349', StackTrace__c = 'Class.PS_ContactTriggerHandler.updateAssociatedCases: line 349, column 1 Trigger.PS_ContactTrigger: line 85, column 1', logged_in_user__c = UserInfo.getName());
                        }
                    }
                }
            }catch(Exception e){ ErrorLog.CreateER(e);//Exception captured in Utility Class Errorlog
            }
        }
    }
    /*Method to generate the random string */
    public static String generateRandomString(Integer len ,String key) { final String chars = key.trim()+'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        try{ 
            while (randStr.length() < len) { 
                Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                randStr += chars.substring(idx, idx+1);
            }
        }catch(Exception e){ 
            ErrorLog.CreateER(e);
        }
        return randStr; 
    }
    /*
    Start : Auto Populate business hours based on time zone selected on Contact
    */
    public static void populateBusinessHours(List<Contact> lstCon){
    
         system.debug('SN lstCon:' + lstCon );
         
        try{ 
            Set<String> setConTimeZone = new Set<String>();
            for(Contact c : lstCon){ if(c.Time_Zone__c!=NULL) setConTimeZone.add(c.Time_Zone__c);
            }
            List<TimeZone_BusinessHour__mdt> lstTZBHmdt = [SELECT Id, DeveloperName, MasterLabel, Time_Zone_Label__c, Business_Hours__c FROM TimeZone_BusinessHour__mdt WHERE Time_Zone_Label__c IN: setConTimeZone];
            
            Map<Id, BusinessHours> mapBHrs = new Map<Id, BusinessHours>([SELECT Id, Name, IsActive FROM BusinessHours WHERE isActive=True]);
            Map<String, BusinessHours> mapBhrName = new Map<String, BusinessHours>();
            for(BusinessHours bh : mapBHrs.values()){ if(!mapBhrName.containsKey(bh.Name)) mapBhrName.put(bh.Name, bh );
            }
            Map<String, BusinessHours> mapTZoneBHrs = new Map<String, BusinessHours>();
            for(TimeZone_BusinessHour__mdt tb : lstTZBHmdt){ if(!mapTZoneBHrs.containsKey(tb.Time_Zone_Label__c)) mapTZoneBHrs.put(tb.Time_Zone_Label__c, mapBhrName.get(tb.Business_Hours__c));
            }
            mapTZoneBHrs.put('Default', mapBhrName.get('AMER'));
            for(Contact c : lstCon){ if(c.Time_Zone__c!=NULL && mapTZoneBHrs.containsKey(c.Time_Zone__c) && mapTZoneBHrs.get(c.Time_Zone__c)!=NULL) c.BusinessHours__c = mapTZoneBHrs.get(c.Time_Zone__c).Id;
                else if(c.Time_Zone__c == NULL) c.BusinessHours__c = mapTZoneBHrs.get('Default').Id;
            }
        }catch(Exception e){ 
            ErrorLog.CreateER(e);
        }
    }
    /*
    END : Auto Populate business hours based on time zone selected on Contact
    */  
    
    /* Created the method by Rohan to update the User profile based on the DPL Status */
    public static Map<Id,User> profileAssignment(User usr,Contact cont){ Map<Id,User> dplUserToUpdate = new Map<Id,User>();
        try{ if(!cont.Interact_with_Community__c &&!cont.Update_check__c){ usr.ProfileId = L1ProfileId;           
                dplUserToUpdate.put(usr.Id,usr);
            }   
            else if(!cont.Update_check__c){ usr.ProfileId = (cont.Enable_Portal_User__c ? L2ProfileId : L1ProfileId);
                usr.ProfileId = (cont.Customer_Admin__c ? managerId : usr.ProfileId);
                dplUserToUpdate.put(usr.Id,usr);
            }
        }catch(Exception e){ 
            ErrorLog.CreateER(e);
        }
        return dplUserToUpdate;
    }
    
    
    /*Added by Rohan for the req 2161 starts*/
    /* Method that updates the contact record checkbox's based on the assigned user profile */
    public static void UpdateContactCheckbox(set<Id> contactIds)
    {
        List<Contact> conlst = [Select id,DPL_Status__c,Interact_with_Community__c,Enable_Portal_User__c,View_Account_Cases__c,Customer_Admin__c,Update_check__c,Embargo_Country__c from contact where ID IN:contactIds];
        List<User> LstUser = [Select id,contactId,name,ProfileId,IsActive from User where contactId IN:contactIds];
        Map<Id,User> mapUser = new Map<Id,User>();
        List<Contact> Lstcon = new List<Contact>();
        for(User usr : LstUser){ mapUser.put(usr.contactId, usr);
        }
        if(!mapUser.isEmpty()){ for(Contact con : conlst){ User usr = (user)mapUser.get(con.id);
                Contact oldContact = (Contact) Trigger.OldMap.get(con.Id);
                if(con.DPL_Status__c=='Unrestricted' &&  con.Update_check__c ){if(usr.ProfileId==L1ProfileId){ con.Interact_with_Community__c = true; 
                        con.Update_check__c =false;                 
                        Lstcon.add(con);
                    }
                    else if(usr.ProfileId==L2ProfileId){con.Interact_with_Community__c = true;
                        con.Enable_Portal_User__c=true;
                        con.Update_check__c =false;
                        Lstcon.add(con);
                    }
                    else if(usr.ProfileId==managerId){con.Interact_with_Community__c = true;
                        con.Enable_Portal_User__c = true;
                        con.View_Account_Cases__c = true;
                        con.Customer_Admin__c = true;
                        con.Update_check__c =false;
                        Lstcon.add(con);
                    }
                }
            }
            
            if(Lstcon.size()>0){ try{ update Lstcon; }
                catch(Exception e){ErrorLog.CreateER(e);//Exception captured in Utility Class Errorlog
                }
            } 
        }
    }
    /*Added by Rohan for the req 2161 Ends*/
    
    /***************************************************************************************************** 
    Method Name:        deleteDiscussionRecordList
    @return  :          void
    @parameters:        userIdSet - Set of User Ids to hold the Users who failed DPL check.
    Description:        User Story# 2239 - Ability to delete Discussion threads that a user who failed DPL check
    Added By:           Accenture - SB - 21/03/2018
    Modified By:        Date:       Changes: 
    Accenture - SB      22/03/2018  Optimized the method
    ******************************************************************************************************/
    /*Ability to delete Discussion threads that a user who failed DPL check*/
    public static void deleteDiscussionRecordList(Set<Id> contactIdSet){
        /*Query the Discussion("FeedItem" Object with Type "QuestionPost") object record pertaining to the 
User for whom DPL Status came as "Restricted". */
        try{
            String QuestionPost= DataValueMap__c.getInstance('QuestionPost').Data_Value__c;
            Map<Id, User> userIdMap = new Map<ID, User>([SELECT Id, Name,IsActive 
                                                         FROM User
                                                         WHERE ContactId IN : contactIdSet]);
            List<FeedItem> discussionFeedItemList = [SELECT Id, ParentId, CreatedById, Title, Body, CreatedDate 
                                                     FROM FeedItem 
                                                     WHERE Type =: QuestionPost AND 
                                                     CreatedById IN : userIdMap.keySet()];
            
            /*Insert a record on the CommunityDiscussionArchive__c object when the DPL Status 
            has been changed to "Restricted" on a Contact record with data from the above query. */
            if(discussionFeedItemList != NULL && discussionFeedItemList.size() > 0){ List<CommunityDiscussionArchive__c> cdaListToBeInserted = new List<CommunityDiscussionArchive__c>();
                for(FeedItem feedItemRecord : discussionFeedItemList){ cdaListToBeInserted.add(new CommunityDiscussionArchive__c( Archive_Date_Time__c = System.now(),
                        Archive_Reason__c = 'Denied Party Restriction',
                        Content_Created_By__c = feedItemRecord.CreatedById,
                        Content_Created_Date__c = date.newinstance(
                            feedItemRecord.CreatedDate.year(), 
                            feedItemRecord.CreatedDate.month(), 
                            feedItemRecord.CreatedDate.day()),
                        Feed_Content__c = feedItemRecord.Body,
                        FeedTitle__c = feedItemRecord.Title)
                                           );
                }
                if(!Test.isRunningTest()) insert cdaListToBeInserted;
                /*Delete the Discussion("FeedItem" Object with Type "QuestionPost") object record.*/
                delete discussionFeedItemList;
            }  
        }catch(Exception e){ ErrorLog.CreateER(e);
        }
    }
    /*Update contact with Account when the User profile is Community Manager*/
    public static void updateContactAccount(list<contact> lstcont)
    {
        try{ Id acc= [Select Id,AccountId from User where Id=: UserInfo.getUserId() limit 1].accountId;
            for(Contact con:lstcont){ 
                con.AccountId =  acc;
            }
        }catch(Exception e){ ErrorLog.CreateER(e);
        }   
    }
    /* Avoid Duplication of Contact Record Starts */
    public static void duplicationcheck (List<contact> lstcontact)
    {
        System.debug('duplicationcheck: ' + lstcontact);
        try{
            Set<String> emailIdSet =  new Set<String>();
            Map<String,Id> contactEmailIdMap = new Map<String,Id>();
            for(Contact c : lstcontact){ 
                if(c.Interact_with_Community__c) 
                    emailIdSet.add(c.Email);
            }
            
            //added for performance tuning
            if(!emailIdSet.isEmpty()){
                for(User userRecord : [SELECT Id, FederationIdentifier, ContactId
                                       FROM User
                                       WHERE FederationIdentifier IN :emailIdSet AND
                                             isActive = true AND
                                             ContactId != NULL]){ contactEmailIdMap.put(userRecord.FederationIdentifier, userRecord.ContactId);
                }
            }
            for(Contact conRecord : lstcontact){ 
                if(contactEmailIdMap.keySet().contains(conRecord.Email) && contactEmailIdMap.get(conRecord.Email) != conRecord.Id){ 
                    conRecord.addError('Duplicate record found');
                }
            }
            PS_ContactTriggerHandler.check = false; 
        }
        catch(Exception e){
            ErrorLog.CreateER(e);
        }
    }
}