public class CreateCaseCtrl {
    public String AccountName;
    public String ContactName;
    public String Subject;
    public String Description;
    public String Product;
    public static Set<String> accountIds;
    public static user curUser;
    public static map<string,string> mapOfSeverity = new map<string,string>();
    public static map<string,string> mapOfPriority = new map<string,string>();
    public static List<AccountContactRelation> lstAccountContactRelation;


    public CreateCaseCtrl(){
        
        mapOfPriority.put(Label.Portal_Severity1,'Severity 1 - Critical');
        mapOfPriority.put(Label.Portal_Severity2,'Severity 2 - Major');
        mapOfPriority.put(Label.Portal_Severity3,'Severity 3 - Minor');
        mapOfPriority.put(Label.Portal_Severity4,'Severity 4 - Cosmetic');

        mapOfSeverity.put('Severity 1 - Critical',Label.Portal_Severity1);
        mapOfSeverity.put('Severity 2 - Major',Label.Portal_Severity2);
        mapOfSeverity.put('Severity 3 - Minor',Label.Portal_Severity3);
        mapOfSeverity.put('Severity 4 - Cosmetic',Label.Portal_Severity4);        
        
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

    public static void getContactRole(){
        try{
            accountIds =  new Set<String>();
            //mapAccountShare = new Map<Id,AccountShare>();
            lstAccountContactRelation = new List<AccountContactRelation>();
            curUser = [SELECT Id,ContactId,AccountId,Profile.Name,ProfileId FROM User WHERE Id =: UserInfo.getUserID()];
            system.debug('curUser.ContactId++'+curUser.ContactId);

            for(AccountContactRelation acR : [Select id, AccountId, Roles,Account.name from AccountContactRelation where contactId =: curUser.ContactId]){
                accountIds.add(acR.AccountId);
                lstAccountContactRelation.add(acR);
            } 
        }catch(Exception e){
            //ErrorLog.CreateER(e);
        }
        
    }


    @AuraEnabled
    Public static list<Contact> getRelatedContacts(String accountId){
        List<Contact> listContact = new List<Contact>();
        try{
        if(accountId != null && accountId !='None'){
            getContactRole();  
            //String userProfileId = DataValueMap__c.getInstance('PortalUserProfileId').Data_Value__c;
            String customerAdminProfileId = DataValueMap__c.getInstance(UserInfo.getProfileId()).Data_Value__c;  
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
                    System.debug('curUser.ContactId--->'+curUser.ContactId);
                    contactId =curUser.ContactId;
                    for(AccountContactRelation acR1 : lstAccountContactRelation ){ 
                        if(acr1.AccountId==accountId) 
                        {
                            role = acR1.Roles;
                            system.debug('accountId-->'+accountId);
                            System.debug('role1 --->'+role);
                        }
                    }
                    system.debug('accountId-->'+accountId);
                    System.debug('role2 --->'+role);
                    if(role == 'Multiple PCN View All'){
                        query = query + ' (Id =:contactId'+' or ' +' AccountId =: accountId)'; 
                    }else{
                        contactId =curUser.contactId;
                        query = query + ' Id =: contactId';
                    }
                   
                }
            }
            query = query + ' limit 1000';
            System.debug('query--->'+query);
           listContact = Database.query(query);
        }
        }catch(Exception e){}
            // ErrorLog.CreateER(e);
        if(!listContact.isEmpty()){
            return listContact;
        }else{
            return null;
        }
        
        //return null;
    }


    @AuraEnabled
    Public static list<Account> getAccountList(){
      List<Account> listAccount = new List<Account>();
        try{        
        system.debug('yes');
        getContactRole();
        accountIds.add(curUser.AccountId);
        system.debug('accountIds++'+accountIds+'++'+lstAccountContactRelation);

        //  accountIds.clear();
        for(AccountContactRelation acR : lstAccountContactRelation ){
            accountIds.add(acR.AccountId);
            Account acc = new Account();
            acc.name=acr.account.name;
            acc.id=acR.AccountId;
            listAccount.add(acc);
        }
        system.debug('listAccount++'+listAccount);

        }catch(Exception e){
                        //ErrorLog.CreateER(e);
                        }
        
        
        if(!listAccount.isEmpty()){
            return listAccount;
        }else{
            return null;
        }
    }


     
     @AuraEnabled
    public static List<Entitlement> getRelatedEntitlements(String accountId){//Fetch data
        List<Entitlement> entitlementList = new List<Entitlement>();
        try{
            if(accountId != null && accountId!='None'){
                String Active = 'Active';
                entitlementList = [SELECT Id,Name,AccountId,Startdate,Status, EndDate,Type,Account.Name FROM Entitlement WHERE AccountId =:accountId and Status =: Active ORDER BY Name ASC];
            }
        }catch(Exception e){
            //ErrorLog.CreateER(e);
        }
        
        if(!entitlementList.isEmpty()){
            return entitlementList;
        }
        return null;    
    }
    
    
    
     @AuraEnabled
     public static user getCurrentUser() {

          curUser = [SELECT Id,ContactId,AccountId,Account.Name,Email,Contact.Email, Contact.Name,Profile.Name,ProfileId FROM User WHERE Id =: UserInfo.getUserId()];

          return curUser;
     }

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
        boolean otherExists = false;
        
        if(entId != null && entId != 'None'){
            String product = [Select Entitlement_Product_Name__c from Entitlement where id =: entId].Entitlement_Product_Name__c;
            System.debug('Product---->'+product);
            mapDepenPicValues.put('Product' , new list<String>{product});
            for(CaseDep__c caseDep : [Select ProductVersion__c,Component__c,Subcomponent__c,Product__c FROM CaseDep__c WHERE Inactive__c=FALSE AND Product__c =:product ORDER BY ProductVersion__c DESC]){
                if(caseDep.ProductVersion__c != null){

                    if (caseDep.ProductVersion__c!= 'Other'){
                      versionSet.add(caseDep.ProductVersion__c);
                    }
                    else{
                        otherExists = true;
                    }


                    /*
                    set<String> validate = new set<String>();
                    validate.addAll(mapDepenPicValues.get('ProductVersion'));
                    mapDepenPicValues.get('ProductVersion').clear();
                    mapDepenPicValues.get('ProductVersion').addAll(validate); 
                    */
                }
                if(caseDep.Component__c != null){

                    /*
                    set<String> validate = new set<String>();
                    mapDepenPicValues.get('Component').add(caseDep.Component__c);
                    validate.addAll(mapDepenPicValues.get('Component'));
                    mapDepenPicValues.get('Component').clear();
                    mapDepenPicValues.get('Component').addAll(validate);
                    */
                    componentSet.add(caseDep.Component__c);
                    
                }
                if(caseDep.Subcomponent__c != null){


                    /*
                    set<String> validate = new set<String>();
                    mapDepenPicValues.get('SubComponent').add(caseDep.Subcomponent__c);
                    validate.addAll(mapDepenPicValues.get('SubComponent'));
                    mapDepenPicValues.get('SubComponent').clear();
                    mapDepenPicValues.get('SubComponent').addAll(validate);
                    */

                    subComponentSet.add(caseDep.Subcomponent__c);
                }
            }
            

            //list<String> sortversionList = getSortVersion(new List<String>(versionSet),'ASC');

            List<String> versionList = new List<String>(versionSet);
            List<String> sortedVersionList = VersionSortUtil.GetSorted(versionList, 'DESC-ALPH-END'); 
            mapDepenPicValues.get('ProductVersion').addAll(sortedVersionList);
            
            //mapDepenPicValues.get('ProductVersion').addAll(versionSet);
            
            if (otherExists)
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

    @AuraEnabled
    /*Method used to get All sub compoenent values based on Selected component*/
    public static list<String> getSubCompValue(String entitlementId, String cmpId){
        try{

         system.debug('sun cmpId:' + cmpId);  
         system.debug('sun entitlementId:' + entitlementId);   

        // Assign the label instead of Api Name    
        //cmpId = fetchPickListApiValue('Case', 'Component__c', cmpId);
        //system.debug('sun cmpId2:' + cmpId);   



        Set<String> subCompLst = new Set<String>();
        LIST<Entitlement> entitlementList = [SELECT Entitlement_Product_Name__c FROM Entitlement WHERE Id =: entitlementId];    
        
            if (!entitlementList.isEmpty()){
                for(CaseDep__c caseDep : [Select ProductVersion__c,Component__c,Subcomponent__c,Product__c FROM CaseDep__c WHERE Component__c =:cmpId AND Inactive__c=FALSE AND Product__c =: entitlementList[0].Entitlement_Product_Name__c order by Subcomponent__c ASC]){
                    subCompLst.add(caseDep.Subcomponent__c);
                }
            }
            
            if(!subCompLst.isEmpty()){
                list<string> subComList = new list<String>();
                subComList.addAll(subCompLst);
                return subComList;
            }   
        }catch(Exception e){
                        //ErrorLog.CreateER(e);
                        }
        return null;
    }

     @AuraEnabled
    public static String createRecord (Case ca){
        try{
          System.debug('ca++'+ca);
            if(ca != null){
                ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
                // Assign the label instead of Api Name    
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

                ca.origin = 'Community';
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                ca.setOptions(dmo);

                System.debug('ca++ before insert:'+ca);

                insert ca;
                if(ca.Case_Comments__c != null){
                    attachFileOnCase(ca.Id,ca.Case_Comments__c);
               }
            }
       //     return null;
        }catch(Exception ex){
            //ErrorLog.CreateER(ex);
            throw new AuraHandledException(ex.getMessage());

        }
        return null;
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
          //ErrorLog.CreateER(e);
        }
    } 

    public class optionClass{
        @AuraEnabled public  string label{get;set;}
        @AuraEnabled public  string value{get;set;}
    }

     
     @auraEnabled 
     
     public static List < optionClass > getselectOptions(sObject objObject, string fld){
          List < optionClass > allOpts = new list < optionClass > ();
          List < optionClass > allOptsReverseSorted = new list < optionClass > ();
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
            optionClass opt= new optionClass();
            if(fld == 'Priority'){
                opt.label = getSeverityValue(a.getValue());
                opt.value = a.getValue(); 
                allOpts.add(opt);
                
                
                
            }else{
                opt.label = a.getValue();
                opt.value = a.getValue(); 
                allOpts.add(opt);
            }
        }
        
        if(fld == 'Priority'){
            for (Integer i = allOpts.size() - 1; i >= 0; i--) {
                allOptsReverseSorted.add(allOpts[i]);
            }
            return allOptsReverseSorted;
        }
            
        //allOpts.sort();
        }catch(Exception e){
            //ErrorLog.CreateER(e);
        }
        return allOpts;
     }

     public static string getSeverityValue(string aVal){
        //map<string,string> mapOfSeverity;
        System.debug('mapOfSeverity++'+mapOfSeverity);
        if(mapOfSeverity.size()==0){  
            mapOfSeverity.put('Severity 1 - Critical',Label.Portal_Severity1);
            mapOfSeverity.put('Severity 2 - Major',Label.Portal_Severity2);
            mapOfSeverity.put('Severity 3 - Minor',Label.Portal_Severity3);
            mapOfSeverity.put('Severity 4 - Cosmetic',Label.Portal_Severity4);
        }
        return mapOfSeverity.get(aval);
     }

     /*public static string getPriorityValue(string aVal){

        if(mapOfPriority.size()==0){
            mapOfPriority= new map<string,string>();
            mapOfPriority.put('Minor','Low');
            mapOfPriority.put('Severity','Medium');
            mapOfPriority.put('Critical','High');
        }
        return mapOfPriority.get(aVal);
     }*/
/*
public static string fetchPickListLabel(string obj, string fldName, string apiName){
        string label = '';
        sObjectType objName = ((sObject) type.forName(obj).newInstance()).getSObjectType();
        list<PicklistEntry> pickListValues = objName.getDescribe().fields.getmap().get(fldName).getDescribe().getPickListValues();
        map<string,string> mapOfPickListValues = new map<string,string>();
        for(PicklistEntry a: pickListValues){
            mapOfPickListValues.put(a.getValue(),a.getLabel());
        }

        label = mapOfPickListValues.get(apiName);
        return label;
    }

*/
    
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

/*
   public static list<string> getSortVersion(list<string>versionLst, string sortOrder){
    
        list<string>sortedVersionLst = new list<string>();
        list<string>finalSortedVersionLst = new list<string>();

        for (integer i = 0; i < versionLst.size(); i++) {     
          for (integer j = i + 1; j < versionLst.size(); j++) {
            string fString = versionLst.get(i);
            list<string>fLoopLst = fString.split('\\.');
          
            string sString = versionLst.get(j);
            list<string>sLoopLst = sString.split('\\.');
            string tmp = '';
            //system.debug('s++'+integer.valueOf(fLoopLst[0])+'---'+integer.valueof(sLoopLst[0]));
            integer fLoop = 0;
            integer sLoop = 0;

            boolean fLoopIsString = pattern.matches('[a-zA-Z]+',fLoopLst[0]);
            boolean sLoopIsString = pattern.matches('[a-zA-Z]+',sLoopLst[0]);


            if(fLoopIsString && sLoopIsString){
              fLoop = fLoopLst[0].getChars()[0];
              sLoop = sLoopLst[0].getChars()[0];
            }else if(fLoopIsString && !sLoopIsString){
              break;
            }else if(!fLoopIsString && sLoopIsString){
              tmp = versionLst.get(i);
              versionLst[i] = versionLst[j];
              versionLst[j] = tmp;
              break;
            }else{
              fLoop = integer.valueOf(fLoopLst[0]);
              sLoop = integer.valueOf(sLoopLst[0]);
            }

            if (fLoop == sLoop){
              for(integer k=1; k<fLoopLst.size();k++){
                if(sLoopLst.size()>k){

                  fLoopIsString = pattern.matches('[a-zA-Z]+',fLoopLst[k]);
                  sLoopIsString = pattern.matches('[a-zA-Z]+',sLoopLst[k]);

                  if(fLoopIsString && sLoopIsString){
                    fLoop = fLoopLst[k].getChars()[0];
                    sLoop = sLoopLst[k].getChars()[0];
                  }else if(fLoopIsString && !sLoopIsString){
                    break;
                  }else if(!fLoopIsString && sLoopIsString){
                    tmp = versionLst.get(i);
                    versionLst[i] = versionLst[j];
                    versionLst[j] = tmp;
                    break;
                  }else{
                    fLoop = integer.valueOf(fLoopLst[k]);
                    sLoop = integer.valueOf(sLoopLst[k]);
                  }

                  if(fLoop == sLoop){
                     
                  }else{ 
                    if (fLoop > sLoop){
                        tmp = versionLst.get(i);
                        versionLst[i] = versionLst[j];
                        versionLst[j] = tmp;
                        break;
                    }else{
                      break;
                    }
                  }
                }else{
                  break;
                }
              }    
            }else if (fLoop > sLoop) {
                tmp = versionLst.get(i);
                versionLst[i] = versionLst[j];
                versionLst[j] = tmp;
            }

          }
        }
          

        if(sortOrder == 'DESC'){
           for(Integer i = versionLst.size()-1; i>=0;i--){
             finalSortedVersionLst.add(versionLst.get(i));
           }
        }else{
          finalSortedVersionLst = versionLst;
        }

      system.debug('finalSortedVersionLst++'+finalSortedVersionLst);
      return finalSortedVersionLst;
    }
*/


}