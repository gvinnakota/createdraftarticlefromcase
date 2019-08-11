@isTest
private class CreateCaseTest {
  
   static testmethod void TestConstructor(){
       TestDataUtil.dataValueMapCSData();
       CreateCaseCtrl cctrl = new CreateCaseCtrl();
       CreateCaseCtrl.getSeverityValue('Severity 1 - Critical');
       CreateCaseCtrl.mapOfSeverity.clear();
       CreateCaseCtrl.getSeverityValue('Severity 1 - Critical');
   }
        
        

   static testmethod void portalCaseCreation(){
        TestDataUtil.dataValueMapCSData();
        Account acc = TestDataUtil.createAccount();
        System.assert(acc.Id!=null);
        Contact pCont = TestDataUtil.createPortalContact();
        
        System.assert(pCont.Id!=null);
        TestDataUtil.createAccountContactRole(acc.Id,pCont.Id);
        Entitlement ent = TestDataUtil.createEntitlement(pCont.AccountId);
        System.assert(ent.Id != null);
        User usr = [Select Id ,AccountId,ProfileId from User where contactId =: pCont.Id];     
        System.assert(usr != null);
        System.assertEquals(pCont.AccountId,usr.AccountId);
        System.assert(usr.AccountId != acc.Id);
        DataValueMap__c csData = DataValueMap__c.getInstance('PortalManagerProfileId');
        csData.Data_Value__c = usr.ProfileId;
        update csData;
        System.assertEquals(usr.ProfileId,csData.Data_Value__c);
        AccountContactRole acr = new AccountContactRole(AccountId=acc.Id,ContactId=pCont.Id,Role='Multiple PCN View All');
        insert acr;
        System.assert(acr.Id != null);
        AccountShare AccShare = new AccountShare(AccountId = acc.Id, AccountAccessLevel = 'Read', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read', UserOrGroupId = usr.Id);
        Insert AccShare;
        Case caseObj = new Case(Subject='Ignore Test Case' ,Case_Comments__c='Test Case Created', Description='Ignore Test Case' , AccountId=pCont.AccountId, ContactId =pCont.Id);
        
        System.runAs(usr){
            //CreateCaseCtrl.getEntitlementList();
            CreateCaseCtrl.getRelatedContacts(acc.Id);
            CreateCaseCtrl.getselectOptions(new Case(),'Environment__c');
            CreateCaseCtrl.createRecord(caseObj);
            LIST<CASE> caselist = [SELECT Id, AccountId FROM CASE ORDER BY CreatedDate DESC LIMIT 1];
            if (caseList.size()>0){
                caseObj = caselist[0];
            }
        }
        Contact pCont1 = TestDataUtil.createPortalContact();
        AccountContactRole acr1 = new AccountContactRole(AccountId=pCont1.AccountId,ContactId=pCont1.Id,Role='Partner');
        insert acr1;
        AccountShare AccShare1 = new AccountShare(AccountId = pCont1.AccountId, AccountAccessLevel = 'Read', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read', UserOrGroupId = usr.Id);
        Insert AccShare1;        
        System.runAs(usr){
            CreateCaseCtrl.getRelatedContacts(pCont.AccountId);
            CreateCaseCtrl.getRelatedContacts(pCont1.AccountId);
        }
        CreateCaseCtrl.attachFileOnCase(caseObj.id,'');
        CreateCaseCtrl.getSendSafetyURL(caseObj.id,pCont.AccountId);
        CreateCaseCtrl.getSendSafetyURL(caseObj.id,null);
    }
    
    static testmethod void portalCaseCreation_1(){
        TestDataUtil.dataValueMapCSData();
        TestDataUtil.createCaseDep();
       
         List<Profile> lstProfile = TestDataUtil.getProfiles();
        List<DataValueMap__c>  csDataList =  new List<DataValueMap__c>();
        csDataList.add(new DataValueMap__c(Name='Pivotal - AccountShare Access',Data_Value__c='0PSf0000000DNtBGAW'));
        insert csDataList;
        
       
        Test.StartTest();
           Contact pCont = TestDataUtil.createPortalContact();
            System.assert(pCont.Id!=null);
            pCont.Interact_with_Community__c =true;
            pCont.Enable_Portal_User__c =true;
            pCont.View_Account_Cases__c =true;
            pCont.Customer_Admin__c=true;
            update pCont;
            System.debug('contact id-'+pCont.Id+'--'+pCont.Customer_Admin__c);
            User usr = [Select id,ContactId, AccountId,ProfileId from User where isActive=true and ContactId=:pCont.Id];
            system.debug('user pro'+usr.profileId);
            System.assert(usr!=Null,'User not created');
            Entitlement ent = TestDataUtil.createEntitlement(pCont.AccountId);
            Entitlement ent1 = TestDataUtil.createEntitlement(pCont.AccountId);
            System.assert(ent.Id != null);
          // User u= CreateCaseCtrl.getCurrentUser();
         //  case caseObj = [select id from case limit 1];
           system.runAs(usr){
           user u= CreateCaseCtrl.getCurrentUser();
            list<Account> accList = CreateCaseCtrl.getAccountList();
            System.assert(!acclist.isEmpty());
           list<Entitlement> rEnt1 = CreateCaseCtrl.getRelatedEntitlements(accList[0].Id);
           list<Entitlement> rEnt = new list<Entitlement>();
           rEnt.add(ent);
           rEnt.add(ent1);
           System.assert(!rEnt.isEmpty());

           /*Case caseObj = new Case(Subject='Ignore Test Case' , Description='Ignore Test Case' , AccountId=pCont.AccountId, ContactId =pCont.Id);
            caseObj.Priority = 'Severity 3 - Minor'; 
        caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Non-Technical').getRecordTypeId();
        insert caseObj;*/
           // System.assertEquals(caseObj.Id!=null,true,'Case Created');
            
          CreateCaseCtrl.getAllDepFieldValue(rEnt[0].Id);
          CreateCaseCtrl.getSubCompValue(rEnt[0].Id,'Test Component');
         // CreateCaseCtrl.getSendSafetyURL(accList[0].Id,caseObj.Id);
          CreateCaseCtrl.getRelatedContacts(accList[0].Id);
          
        //TestDataUtil.removeDataValueMapCSData();
        list<Entitlement> rEnt2 = CreateCaseCtrl.getRelatedEntitlements(accList[0].Id);
          // CreateCaseCtrl.createRecord(caseObj,null);
           }
        Test.StopTest();
}
}