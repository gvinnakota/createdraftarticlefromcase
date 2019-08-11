/*******************************************************************************************************************
* Apex Class Name  : PortalNewCaseController
* Test Class Name  : PortalNewCaseController_TC
* Version          : 1.0
* Function         : Class is used to create a new case from Community
* Modification Log :
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Hemavathi NM                 10/12/2017            Used to create case record from portal
* Hemavathi NM                 19/02/2017            User Story 1729 Contacts with Multiple Accounts
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
public without sharing class PortalNewCaseController {
    public static user curUser;
    public static Set<String> accountIds;
    // public static Map<Id,AccountShare> mapAccountShare;
    public static List<AccountContactRelation> lstAccountContactRelation;
    /* Method to get the contact role */
    public static void getContactRole(){
        try{
            accountIds =  new Set<String>();
            //mapAccountShare = new Map<Id,AccountShare>();
            lstAccountContactRelation = new List<AccountContactRelation>();
            curUser = [SELECT Id,ContactId,AccountId,Profile.Name,ProfileId FROM User WHERE Id =: UserInfo.getUserID()];
            /* for(AccountShare acr : [Select Id,AccountId,CaseAccessLevel,ContactAccessLevel from AccountShare where userOrGroupId =: UserInfo.getUserID() and RowCause  <>  'ImplicitParent']){
mapAccountShare.put(acr.AccountId,acr);
accountIds.add(acr.AccountId);5

}*/
            // Added by Hema/Rohan as the part of User story 1729 starts 
            for(AccountContactRelation acR : [Select id, AccountId, Roles,Account.name from AccountContactRelation where contactId =: curUser.ContactId]){
                accountIds.add(acR.AccountId);
                lstAccountContactRelation.add(acR);
            } 
        }catch(Exception e){
            ErrorLog.CreateER(e);
        }
        // Added by Hema/Rohan as the part of User story 1729 Ends     
    }
    /* Get All entitlement of logged in user*/
    @AuraEnabled//Annotation to use method in lightning component
    public static List<Entitlement> getEntitlementList(){//Fetch data
        List<Entitlement> entitlementList = new  List<Entitlement>();
        try{
            getContactRole();
            accountIds.add(curUser.AccountId);
            entitlementList = [SELECT Id,Name,AccountId,Startdate,EndDate,Type,Account.Name, Status FROM Entitlement WHERE AccountId =:accountIds order by EndDate desc limit 1000];
        }catch(Exception e){
            ErrorLog.CreateER(e);
        }
        if(!entitlementList.isEmpty()){
            return entitlementList;
        }else{
            return null;
        }
        
    }
    /*Get All related Contacts*/
    @AuraEnabled
    Public static list<Contact> getRelatedContacts(String accountId){
        List<Contact> listContact = new List<Contact>();
        try{
        if(accountId != null && accountId !='None'){
            getContactRole();
            String userProfileId = DataValueMap__c.getInstance('PortalUserProfileId').Data_Value__c;
            String customerAdminProfileId = DataValueMap__c.getInstance('PortalManagerProfileId').Data_Value__c;
            String query = 'SELECT Id , Name , AccountId FROM contact WHERE Interact_with_Community__c =: active and ';
            String contactId;
            Boolean active = true;
            
            if(!customerAdminProfileId.containsIgnoreCase(curUser.ProfileId)){
                contactId =curUser.contactId;
                query = query + ' Id =: contactId';
            }
            if(customerAdminProfileId.containsIgnoreCase(curUser.ProfileId)){
                if(curUser.accountId == accountId){
                    query = query + ' AccountId =: accountId';
                }else{
                    
                    string role;
                    //System.debug('curUser.ContactId--->'+curUser.ContactId);
                    contactId =curUser.ContactId;
                    for(AccountContactRelation acR1 : lstAccountContactRelation ){ // Added by Hema/Rohan as the part of User story 1729 
                        if(acr1.AccountId==accountId) // Added by Hema/Rohan as the part of User story 1729 
                        {
                            role = acR1.Roles;
                            //system.debug('accountId-->'+accountId);
                            //System.debug('role1 --->'+role);
                        }
                    }
                    //system.debug('accountId-->'+accountId);
                    //System.debug('role2 --->'+role);
                    if(role == 'Multiple PCN View All'){
                        query = query + ' (Id =:contactId'+' or ' +' AccountId =: accountId)'; // Added by Hema as the part of User story 1729
                    }else{
                        contactId =curUser.contactId;
                        query = query + ' Id =: contactId';
                    }
                    // Commented as the part of User story #1729 by Hema Starts 
                    
                    /* if(!mapAccountShare.isEmpty() && mapAccountShare.containsKey(accountId)){
                        //AccountShare acr = mapAccountShare.get(accountId);
                        string role;
                        for( AccountContactRole acR1 : [Select Role from AccountContactRole where ContactId =: curUser.ContactId and AccountId =: accountId]){
                        role = acR1.Role;
                        }
                        
                        if(role == 'Multiple PCN View All'){
                        query = query + ' AccountId =: accountId';
                        }else{
                        contactId =curUser.contactId;
                        query = query + ' Id =: contactId';
                    }
                    }*/ // Commented as the part of User story #1729 by Hema Ends 
                }
            }
            query = query + ' limit 1000';
            //System.debug('query--->'+query);
           listContact = Database.query(query);
        }
        }catch(Exception e){
                        ErrorLog.CreateER(e);
                        }
            if(!listContact.isEmpty()){
                return listContact;
            }else{
                return null;
            }
        
        return null;
    }

    /*Get Related Entitlement*/
    @AuraEnabled//Annotation to use method in lightning component
    public static List<Entitlement> getRelatedEntitlements(String accountId){//Fetch data
        List<Entitlement> entitlementList = new List<Entitlement>();
        try{
        if(accountId != null && accountId!='None'){
            String Active = DataValueMap__c.getInstance('Active').Data_Value__c;
            getContactRole();
            accountIds.add(curUser.AccountId);
            entitlementList = [SELECT Id,Name,AccountId,Startdate,Status, EndDate,Type,Account.Name FROM Entitlement WHERE AccountId =:accountId and Status =: Active];
        }
        }catch(Exception e){
                        ErrorLog.CreateER(e);
                        }
            if(!entitlementList.isEmpty()){
                return entitlementList;
            }
            return null;   
    }
    
    /*Get All Account Associated */
    @AuraEnabled
    Public static list<Account> getAccountList(){
      List<Account> listAccount = new List<Account>();
        try{        
        getContactRole();
        accountIds.add(curUser.AccountId);
        //  accountIds.clear();
        for(AccountContactRelation acR : lstAccountContactRelation ){ // Added by Hema/Rohan as the part of User story 1729 Ends
            accountIds.add(acR.AccountId);
            Account acc = new Account();
            acc.name=acr.account.name;
            acc.id=acR.AccountId;
            listAccount.add(acc);
        }
        }catch(Exception e){
                        ErrorLog.CreateER(e);
                        }
        
                /*for(Account acc :[Select Name,Id from Account WHERE Id =:accountIds]){
        listAccount.add(acc);
        }*/
        if(!listAccount.isEmpty()){
            return listAccount;
        }else{
            return null;
        }
    }
    /*Create Case Record*/
    @AuraEnabled
    public static String createRecord (Case ca, List<String> fieldValue){
        try{
            if(ca != null){
                if(ca.EntitlementId != null){
                    ca.RecordTypeId = label.Technical;
                }else{
                    ca.RecordTypeId = label.NonTechnical;
                }

                // added to use api value.
                string componentApiValue = fetchPickListApiValue('Case', 'Component__c', ca.Component__c);
                if (!string.isBlank(componentApiValue))
                    ca.Component__c = componentApiValue;

                string productApiValue = fetchPickListApiValue('Case', 'Products__c', ca.Products__c);
                if (!string.isBlank(productApiValue))
                    ca.Products__c = productApiValue;


                string environmentApiValue = fetchPickListApiValue('Case', 'Environment__c', ca.Environment__c);
                if (!string.isBlank(environmentApiValue))
                    ca.Environment__c = environmentApiValue;

                string versionApiValue = fetchPickListApiValue('Case', 'Versions__c', ca.Versions__c);
                if (!string.isBlank(versionApiValue))
                    ca.Versions__c = versionApiValue;

                string subcomponentApiValue = fetchPickListApiValue('Case', 'Sub_Component__c', ca.Sub_Component__c);
                if (!string.isBlank(subcomponentApiValue))
                    ca.Sub_Component__c = subcomponentApiValue;
                //end added

                ca.origin = 'Community';
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                ca.setOptions(dmo);
                insert ca;
                if(ca.Case_Comments__c != null){
                   /* FeedItem fi = new FeedItem();
                    fi.ParentId = ca.Id;
                    System.debug('ca.C---'+ca.Case_Comments__c);
                    fi.body = ca.case_Comments__c;
                    fi.Type ='TextPost';
                    fi.Visibility = 'Allusers';
                    insert fi;*/
                    attachFileOnCase(ca.Id,ca.Case_Comments__c);
               }
            }
       //     return null;
        }catch(Exception ex){
            ErrorLog.CreateER(ex);
        }
        return null;
    }
    
    @AuraEnabled
    /*Method used to get picklist values for Fields like:Environment*/
    public static List < String > getselectOptions(sObject objObject, string fld) {
        List < String > allOpts = new list < String > ();
        try{       
        
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        allOpts.sort();
        }catch(Exception e){
                        ErrorLog.CreateER(e);
                        }
        return allOpts;
    }
    // @AuraEnabled
    /*Method used to get case dependent field values*/
    /*
    Public static map<String,list<String>> getAllDepFieldValue(String entId){
        try{
        Map<String,list<String>> mapDepenPicValues = new Map<String,list<String>>();

        set<String> versionSet = new set<String>();
        set<String> componentSet = new set<String>();
        set<String> subComponentSet = new set<String>();

        mapDepenPicValues.put('ProductVersion' , new list<String>());
        mapDepenPicValues.put('Component' , new list<String>());
        mapDepenPicValues.put('SubComponent' , new list<String>());
        
        if(entId != null && entId != 'None'){
            String product = [Select Entitlement_Product_Name__c from Entitlement where id =: entId].Entitlement_Product_Name__c;
            System.debug('Product---->'+product);
            mapDepenPicValues.put('Product' , new list<String>{product});


           for(CaseDep__c caseDep : [Select ProductVersion__c FROM CaseDep__c WHERE Inactive__c=FALSE AND Product__c =:product AND ProductVersion__c !='Other' ORDER BY ProductVersion__c DESC]){
                if(caseDep.ProductVersion__c != null){
                    set<String> validate = new set<String>();
                    mapDepenPicValues.get('ProductVersion').add(caseDep.ProductVersion__c);
                    validate.addAll(mapDepenPicValues.get('ProductVersion'));
                    mapDepenPicValues.get('ProductVersion').clear();
                    mapDepenPicValues.get('ProductVersion').addAll(validate); 
                }

            }
            
            mapDepenPicValues.get('ProductVersion').add('Other');
            
            for(CaseDep__c caseDep : [Select ProductVersion__c,Component__c,Subcomponent__c,Product__c FROM CaseDep__c WHERE Inactive__c=FALSE AND Product__c =:product order by Component__c asc]){

                if(caseDep.Component__c != null){
                    set<String> validate = new set<String>();
                    mapDepenPicValues.get('Component').add(caseDep.Component__c);
                    validate.addAll(mapDepenPicValues.get('Component'));
                    mapDepenPicValues.get('Component').clear();
                    mapDepenPicValues.get('Component').addAll(validate);
                    
                    
                }
                if(caseDep.Subcomponent__c != null){
                    set<String> validate = new set<String>();
                    mapDepenPicValues.get('SubComponent').add(caseDep.Subcomponent__c);
                    validate.addAll(mapDepenPicValues.get('SubComponent'));
                    mapDepenPicValues.get('SubComponent').clear();
                    mapDepenPicValues.get('SubComponent').addAll(validate);
                }
            }
            
            //******************* Code added by Dilip to Reslove the sorting issue Date 10/02/2018*********
             //mapDepenPicValues.get('ProductVersion').sort();
             //mapDepenPicValues.get('Component').sort();
             mapDepenPicValues.get('SubComponent').sort();
            
            return mapDepenPicValues;
        }
        }catch(Exception e){
                        ErrorLog.CreateER(e);
                        }
        return null;
    }
    */

    @AuraEnabled
    /*Method used to get case dependent field values*/
    Public static map<String,list<String>> getAllDepFieldValue(String entId){
        //try{
        Map<String,list<String>> mapDepenPicValues = new Map<String,list<String>>();
        set<String> versionSet = new set<String>();
        set<String> componentSet = new set<String>();
        set<String> subComponentSet = new set<String>();

        mapDepenPicValues.put('ProductVersion' , new list<String>());
        mapDepenPicValues.put('Component' , new list<String>());
        mapDepenPicValues.put('SubComponent' , new list<String>());
        
        //system.debug('sun entId:' + entId);
        
        if(entId != null && entId != 'None'){
            String product = [Select Entitlement_Product_Name__c from Entitlement where id =: entId].Entitlement_Product_Name__c;
            //System.debug('Product---->'+product);
            mapDepenPicValues.put('Product' , new list<String>{product});
            for(CaseDep__c caseDep : [Select ProductVersion__c,Component__c,Subcomponent__c,Product__c FROM CaseDep__c WHERE Inactive__c=FALSE AND Product__c =:product ORDER BY ProductVersion__c DESC]){
                if(caseDep.ProductVersion__c != null){

                    if (caseDep.ProductVersion__c!= 'Other'){
                      versionSet.add(caseDep.ProductVersion__c);
                    }
                }
                if(caseDep.Component__c != null){
                    componentSet.add(caseDep.Component__c);
                }
                if(caseDep.Subcomponent__c != null){
                    subComponentSet.add(caseDep.Subcomponent__c);
                }
            }
            
			

            mapDepenPicValues.get('ProductVersion').addAll(versionSet);
            mapDepenPicValues.get('ProductVersion').add('Other'); 
            mapDepenPicValues.get('Component').addAll(componentSet);
            mapDepenPicValues.get('Component').sort();

            mapDepenPicValues.get('SubComponent').addAll(subComponentSet);
            mapDepenPicValues.get('SubComponent').sort();
            
            return mapDepenPicValues;
        }
        //}catch(Exception e){
                       // ErrorLog.CreateER(e);
        //                }
        return null;
    }

    public static string fetchPickListApiValue(string obj, string fldName, string label){
        string apiValue = '';
        sObjectType objName = ((sObject) type.forName(obj).newInstance()).getSObjectType();
        list<PicklistEntry> pickListValues = objName.getDescribe().fields.getmap().get(fldName).getDescribe().getPickListValues();
        map<string,string> mapOfPickListValues = new map<string,string>();
        for(PicklistEntry a: pickListValues){
            mapOfPickListValues.put(a.getLabel(),a.getValue());
        }

        apiValue = mapOfPickListValues.get(label);
        return apiValue;
    }



    @AuraEnabled
    /*Method used to get All sub compoenent values based on Selected component*/
    public static list<String> getSubCompValue(String entitlementId, String cmpId){
        try{
        Set<String> subCompLst = new Set<String>();
        
        LIST<Entitlement> entitlementList = [SELECT Entitlement_Product_Name__c FROM Entitlement WHERE Id =: entitlementId];    
        
            if (!entitlementList.isEmpty()){
                for(CaseDep__c caseDep : [Select ProductVersion__c,Component__c,Subcomponent__c,Product__c FROM CaseDep__c WHERE Component__c =:cmpId AND Inactive__c=FALSE AND Product__c =: entitlementList[0].Entitlement_Product_Name__c]){
                    subCompLst.add(caseDep.Subcomponent__c);
                }
            }
            
            if(!subCompLst.isEmpty()){
                list<string> subComList = new list<String>();
                subComList.addAll(subCompLst);
                subComList.sort();
                return subComList;
            }   
        }catch(Exception e){
                        ErrorLog.CreateER(e);
                        }
        return null;
    }

    @AuraEnabled
    /*Method to get Current logged in User details*/
    public static user getCurrentUser(){
        return [SELECT Id,ContactId,AccountId,Account.Name,Email,Contact.Email, Contact.Name,Profile.Name,ProfileId FROM User WHERE Id =: UserInfo.getUserId()];
    }
    
    @auraenabled
    /*Method to get SendSafetyURL from case field*/
    Public static string  getSendSafetyURL(String accountId ,String caseId){
       String APIkey_URL;
        try{
        if(caseId != null){
            list<Case> accountIds = [Select Id,AccountId from Case where Id=:caseId and AccountId !=null];
            accountId = accountIds[0].AccountId;
        }
        // Stores APIKey and URL of SS
        Map<String,Sendsafely__c> sendSafelyCS = Sendsafely__c.getAll();
        if(accountId != null && accountId != 'None'){
            for(Account acc :[select Special_Handling__c from Account where id =:accountId]){
                String ssURL = acc.Special_Handling__c;
                if(sendSafelyCS.containsKey(ssURL)){
                    APIkey_URL = sendSafelyCS.get(ssURL).APIkey__c + '*' + sendSafelyCS.get(ssURL).ssURL__c;
                }else{
                    APIkey_URL += sendSafelyCS.get('Standard').APIkey__c + '*' + sendSafelyCS.get('Standard').ssURL__c;
                }
            }
        }
        }catch(Exception e){
                        ErrorLog.CreateER(e);
                        }
        return APIkey_URL;
    }
    
    @auraEnabled
    /*Method to Inser case feeditem whenever a file is attached by a Sendsaftly link*/
    public static void  attachFileOnCase(String caseId,string body){
        try{
        FeedItem fi = new FeedItem();
        fi.Body= body;
        fi.Visibility='AllUsers';
        fi.ParentId=caseId;
        insert fi;
        }catch(Exception e){
          ErrorLog.CreateER(e);
        }
    }
}