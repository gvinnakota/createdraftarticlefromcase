@isTest
private class PortalNewCaseController_TC {
   /* @isTest
    static void TC1(){
        TestDataUtil.dataValueMapCSData();
        User curUser=new User(Id = UserInfo.getUserID());
                 
        Account acc = new Account(Name='Test Account',Type='Prospect');
        insert acc;
        
        Contact con=new Contact(firstname='Test',lastname='Test',email='test@test.com',AccountID=acc.Id);
        insert con;        
        AccountContactRole__c AccountContactRole = new AccountContactRole__c(Account__c=acc.Id,AccountAccessLevel__c='Read', CaseAccessLevel__c='Test',Contact__c=con.Id,ContactAccessLevel__c='Test',Role__c='Test',User__c=curUser.Id);
        insert AccountContactRole;
        Id entitlementProcessId = [SELECT Id FROM SlaProcess WHERE SObjectType = 'Case' AND Name='Businesshourprocess'].Id;
        
        Entitlement ent = new Entitlement (AccountId=acc.Id, SLAProcessId = entitlementProcessId, Name = 'Test Entitlement');
        insert ent;
        String accid = [Select id, name from Account].Id;
        //String accid1 = [Select Accountid from User].AccountId;
        PortalNewCaseController.getEntitlementList();
        PortalNewCaseController.getRelatedContacts(accid);
        PortalNewCaseController.getRelatedEntitlements(accid);
        PortalNewCaseController.getAccountList();
    }
    @isTest
    static void TC2(){
        TestDataUtil.dataValueMapCSData();
        Account acc = new Account(Name='Test Account',Type='Prospect');
        insert acc;
        Contact con=new Contact(firstname='Test',lastname='Test',email='test@test.com',AccountID=acc.Id);
        insert con;
        
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Manager' LIMIT 1];
        User usr = new User(LastName = 'Test1',FirstName='Test1',Alias = 'Test1',Email = 'Test1@acc.com',
                             Username = 'Test1@acc.com',ProfileId = profileId.id, TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', 
                             EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US',contactid=con.id);
        insert usr;
        
        System.runAs(usr){
            String accid=(String)acc.Id;
        PortalNewCaseController.getRelatedContacts(accid);
        }
        
    }
    @isTest
    static void TC3(){
        TestDataUtil.dataValueMapCSData();
        Account acc = new Account(Name='Test Account',Type='Prospect');
        insert acc;
        Account acc1 = new Account(Name='Test Account',Type='Prospect');
        insert acc1;   
        Contact con1=new Contact(firstname='Test',lastname='Test',email='test@test.com',AccountID=acc1.Id);
        insert con1;
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Manager' LIMIT 1];
        User usr1 = new User(LastName = 'Test2',FirstName='Test2',Alias = 'Test2',Email = 'Test2@acc.com',
                             Username = 'Test2@acc.com',ProfileId = profileId.id, TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', 
                             EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US',contactid=con1.id);
        insert usr1;
        AccountContactRole__c AccountContactRole = new AccountContactRole__c(Account__c=acc.Id,AccountAccessLevel__c='Read', CaseAccessLevel__c='Test',Contact__c=con1.Id,ContactAccessLevel__c='Test',Role__c='Multiple PCN View All',User__c=usr1.Id);
        insert AccountContactRole;
        AccountShare AccShare = new AccountShare(AccountId = acc.Id, AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read', UserOrGroupId = usr1.Id);
        Insert AccShare;
       
        System.runAs(usr1){
        String accid1=(String)acc.Id;
        PortalNewCaseController.getEntitlementList();
        PortalNewCaseController.getRelatedContacts(accid1); 
        
        }
    }
    @isTest
    static void TC4(){
        TestDataUtil.dataValueMapCSData();
        Account acc = new Account(Name='Test Account',Type='Prospect');
        insert acc;
        Account acc1 = new Account(Name='Test Account',Type='Prospect');
        insert acc1;   
        Contact con1=new Contact(firstname='Test',lastname='Test',email='test@test.com',AccountID=acc1.Id);
        insert con1;
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Manager' LIMIT 1];
        User usr1 = new User(LastName = 'Test2',FirstName='Test2',Alias = 'Test2',Email = 'Test2@acc.com',
                             Username = 'Test2@acc.com',ProfileId = profileId.id, TimeZoneSidKey = 'GMT', LanguageLocaleKey = 'en_US', 
                             EmailEncodingKey = 'UTF-8', LocaleSidKey = 'en_US',contactid=con1.id);
        insert usr1;
        AccountContactRole__c AccountContactRole = new AccountContactRole__c(Account__c=acc.Id,AccountAccessLevel__c='Read', CaseAccessLevel__c='Test',Contact__c=con1.Id,ContactAccessLevel__c='Test',Role__c='Test',User__c=usr1.Id);
        insert AccountContactRole;
        AccountShare AccShare = new AccountShare(AccountId = acc.Id, AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read', UserOrGroupId = usr1.Id);
        Insert AccShare;
       
        System.runAs(usr1){
        String accid1=(String)acc.Id;
        PortalNewCaseController.getEntitlementList();
        PortalNewCaseController.getRelatedContacts(accid1); 
        
        }
    }
    @isTest
    static void TC5()
    {
        TestDataUtil.dataValueMapCSData();
        Account acc = new Account(Name='Test Account',Type='Prospect',Special_Handling__c='EH - Executive Handling');
        insert acc;
        Contact con=new Contact(firstname='Test',lastname='Test',email='test@test.com',AccountID=acc.Id);
        insert con;
        ProductEntitlementMap__c PEM=new ProductEntitlementMap__c(Name='Test', Entitlement_Process__c='Test', Product_SKU__c='Test',SFDC_Product_Name__c='Test',Products__c='Test');
        insert PEM;
        Id entitlementProcessId12 = [SELECT Id FROM SlaProcess WHERE SObjectType = 'Case' AND Name='Businesshourprocess'].Id;
        
        Entitlement ent1 = new Entitlement (AccountId=acc.Id,ProductEntitlementMap__c=PEM.Id,StartDate= Date.newInstance(2016, 12, 9), EndDate=Date.newInstance(2025, 12, 9), SLAProcessId = entitlementProcessId12, Name = 'Test12 Entitlement');
        insert ent1;
        
        List<BusinessHours> bhs=[select id from BusinessHours];
        Id bhs1=(Id)bhs[0].ID;
        Case caseObj = new Case(ContactId = con.ID,AccountId = acc.Id,Status = 'Open',Origin = 'Email', EntitlementId=ent1.ID, BusinessHoursId=bhs1, Priority='Severity 1 - Critical',Subject='Test', Description='Test Description');
        insert caseObj;
        Case caseObj1 = new Case(ContactId = con.ID,AccountId = acc.Id,Status = 'Open',Origin = 'Email', BusinessHoursId=bhs1, Priority='Severity 1 - Critical',Subject='Test', Description='Test Description');
        insert caseObj1;
        List<String> liststr=new List<String> {'1','2','3'};
        PortalNewCaseController.createRecord(caseObj,liststr);
        PortalNewCaseController.createRecord(caseObj1,liststr);
        String str='Environment__c';
        CaseDep__c casde=new CaseDep__c(Name='Test CaseDep',Component__c='Test Component', Product__c='Test', ProductVersion__c='Test ProductVersion',  Subcomponent__c='Test Subcomponent');
        insert casde;
        
        PortalNewCaseController.getselectOptions(caseObj,str);
        PortalNewCaseController.getAllDepFieldValue(ent1.id);
        PortalNewCaseController.getSubCompValue('Test Component');
        PortalNewCaseController.getSendSafetyURL(acc.Id);
        PortalNewCaseController.getCurrentUser();
    }*/
    
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
            PortalNewCaseController.getEntitlementList();
            PortalNewCaseController.getRelatedContacts(acc.Id);
            PortalNewCaseController.getselectOptions(new Case(),'Environment__c');
            PortalNewCaseController.createRecord(caseObj,null);
        }
        Contact pCont1 = TestDataUtil.createPortalContact();
        AccountContactRole acr1 = new AccountContactRole(AccountId=pCont1.AccountId,ContactId=pCont1.Id,Role='Partner');
        insert acr1;
        AccountShare AccShare1 = new AccountShare(AccountId = pCont1.AccountId, AccountAccessLevel = 'Read', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read', UserOrGroupId = usr.Id);
        Insert AccShare1;        
        System.runAs(usr){
            PortalNewCaseController.getRelatedContacts(pCont.AccountId);
            PortalNewCaseController.getRelatedContacts(pCont1.AccountId);
        }
        PortalNewCaseController.attachFileOnCase(caseObj.id,'');
        PortalNewCaseController.getSendSafetyURL(pCont.AccountId,caseObj.id);
        PortalNewCaseController.getSendSafetyURL(pCont.AccountId,null);
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
          // User u= PortalNewCaseController.getCurrentUser();
         //  case caseObj = [select id from case limit 1];
           system.runAs(usr){
           user u= PortalNewCaseController.getCurrentUser();
            list<Account> accList = PortalNewCaseController.getAccountList();
            System.assert(!acclist.isEmpty());
           list<Entitlement> rEnt1 = PortalNewCaseController.getRelatedEntitlements(accList[0].Id);
           list<Entitlement> rEnt = new list<Entitlement>();
           rEnt.add(ent);
           rEnt.add(ent1);
           System.assert(!rEnt.isEmpty());

           /*Case caseObj = new Case(Subject='Ignore Test Case' , Description='Ignore Test Case' , AccountId=pCont.AccountId, ContactId =pCont.Id);
            caseObj.Priority = 'Severity 3 - Minor'; 
        caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Non-Technical').getRecordTypeId();
        insert caseObj;*/
           // System.assertEquals(caseObj.Id!=null,true,'Case Created');
            
          PortalNewCaseController.getAllDepFieldValue(rEnt[0].Id);
          portalNewCaseController.getSubCompValue(rEnt[0].Id,'Test Component');
         // portalNewCaseController.getSendSafetyURL(accList[0].Id,caseObj.Id);
          PortalNewCaseController.getRelatedContacts(accList[0].Id);
          
        //TestDataUtil.removeDataValueMapCSData();
        list<Entitlement> rEnt2 = PortalNewCaseController.getRelatedEntitlements(accList[0].Id);
          // PortalNewCaseController.createRecord(caseObj,null);
           }
        Test.StopTest();
}
}