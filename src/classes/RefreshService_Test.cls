@isTest
public class RefreshService_Test {

    /* Test Methods */

    static testMethod void activateAndSetPasswords_shouldDoThat() {
        List<Profile> lstProfile = TestDataUtil.getProfiles();
        
         List<DataValueMap__c>  csDataList =  new List<DataValueMap__c>();
        csDataList.add(new DataValueMap__c(Name = 'PortalManagerProfileId', Data_Value__c = lstProfile[0].Id));
        csDataList.add(new DataValueMap__c(Name = 'PortalUserProfileId', Data_Value__c = lstProfile[1].Id)); 
        csDataList.add(new DataValueMap__c(Name = 'ErrorOnCloseCaseUpdate', Data_Value__c = 'You can not modify closed case.'));
        csDataList.add(new DataValueMap__c(Name = 'customerCaseStatus', Data_Value__c = 'Closed,Solved,In Progress'));
        csDataList.add(new DataValueMap__c(Name = 'Expired', Data_Value__c = 'Expired'));
        csDataList.add(new DataValueMap__c(Name = 'Active', Data_Value__c = 'active'));
        csDataList.add(new DataValueMap__c(Name = 'ArticleTypes', Data_Value__c = 'a42'));
        csDataList.add(new DataValueMap__c(Name = 'bypassModifyClosedCase', Data_Value__c = 'TRUE'));
        csDataList.add(new DataValueMap__c(Name = 'EHSP support', Data_Value__c = 'ehsp.scqa@pivotal.io'));
        csDataList.add(new DataValueMap__c(Name = 'EHSP Escalations', Data_Value__c = 'ehsp-escalations.scqa@pivotal.io'));
        csDataList.add(new DataValueMap__c(Name = 'OnDemandaccountAlias', Data_Value__c = 'ondemand-support.scqa@pivotal.io')); 
        csDataList.add(new DataValueMap__c(Name='Embargo_Countries',Data_Value__c=';Iran;Cuba;North Korea;Sudan;Syria;'));
        csDataList.add(new DataValueMap__c(Name='RPS_Status',Data_Value__c=';Triple Red;Double Red;Red;Risk Country;Yellow;'));
        csDataList.add(new DataValueMap__c(Name='PortalRegisteredUserId',Data_Value__c='00eW0000000I1OOIA0'));
        
       
        csDataList.add(new DataValueMap__c(Name='PivotalSupportProfile',Data_Value__c='00eW0000000I1OmIAK'));
        csDataList.add(new DataValueMap__c(Name='Internal comments for R&D and PKS',Data_Value__c=';00eW0000000M6s9IAC;00eW0000000M7iPIAS;'));
        csDataList.add(new DataValueMap__c(Name='Closed',Data_Value__c='Closed'));
        csDataList.add(new DataValueMap__c(Name='Visibility',Data_Value__c='AllUsers'));
        csDataList.add(new DataValueMap__c(Name='Not Entitled',Data_Value__c='Not Entitled'));
        csDataList.add(new DataValueMap__c(Name='Type',Data_Value__c='TextPost'));
        csDataList.add(new DataValueMap__c(Name='QuestionPost',Data_Value__c='QuestionPost'));
        csDataList.add(new DataValueMap__c(Name='ArticleTypeNames',Data_Value__c='KnowledgeArticle__ka,Break_Fix_ka,Tools__ka,Troubleshooting_Guide__ka,Concept__ka,How_To__ka, Checklist__ka,'));
        csDataList.add(new DataValueMap__c(Name='Pivotal - AccountShare Access',Data_Value__c='0PSf0000000DNtBGAW'));
        insert csDataList;
      
        Test.startTest();
        //  deactivateUser('Falkirk IAD Integration');

        //System.assertEquals(false, isUserActive('Falkirk IAD Integration'), 'Falkirk IAD Integration did not become inactive');

        List<String> users = new List<String>{'Falkirk IAD Integration'};
        RefreshService.refresh(users);
        Test.stopTest();

        System.assertEquals(true, isUserActive('Falkirk IAD Integration'), 'Falkirk IAD Integration did not become active');
    }

    static testMethod void taxRegions_shouldBePrependedWithTest() {
        
         List<Profile> lstProfile = TestDataUtil.getProfiles();
         List<DataValueMap__c>  csDataList =  new List<DataValueMap__c>();
        csDataList.add(new DataValueMap__c(Name = 'PortalManagerProfileId', Data_Value__c = lstProfile[0].Id));
        csDataList.add(new DataValueMap__c(Name = 'PortalUserProfileId', Data_Value__c = lstProfile[1].Id)); 
        csDataList.add(new DataValueMap__c(Name = 'ErrorOnCloseCaseUpdate', Data_Value__c = 'You can not modify closed case.'));
        csDataList.add(new DataValueMap__c(Name = 'customerCaseStatus', Data_Value__c = 'Closed,Solved,In Progress'));
        csDataList.add(new DataValueMap__c(Name = 'Expired', Data_Value__c = 'Expired'));
        csDataList.add(new DataValueMap__c(Name = 'Active', Data_Value__c = 'active'));
        csDataList.add(new DataValueMap__c(Name = 'ArticleTypes', Data_Value__c = 'a42'));
        csDataList.add(new DataValueMap__c(Name = 'bypassModifyClosedCase', Data_Value__c = 'TRUE'));
        csDataList.add(new DataValueMap__c(Name = 'EHSP support', Data_Value__c = 'ehsp.scqa@pivotal.io'));
        csDataList.add(new DataValueMap__c(Name = 'EHSP Escalations', Data_Value__c = 'ehsp-escalations.scqa@pivotal.io'));
        csDataList.add(new DataValueMap__c(Name = 'OnDemandaccountAlias', Data_Value__c = 'ondemand-support.scqa@pivotal.io')); 
        csDataList.add(new DataValueMap__c(Name='Embargo_Countries',Data_Value__c=';Iran;Cuba;North Korea;Sudan;Syria;'));
        csDataList.add(new DataValueMap__c(Name='RPS_Status',Data_Value__c=';Triple Red;Double Red;Red;Risk Country;Yellow;'));
        csDataList.add(new DataValueMap__c(Name='PortalRegisteredUserId',Data_Value__c='00eW0000000I1OOIA0'));
        
       
        csDataList.add(new DataValueMap__c(Name='PivotalSupportProfile',Data_Value__c='00eW0000000I1OmIAK'));
        csDataList.add(new DataValueMap__c(Name='Internal comments for R&D and PKS',Data_Value__c=';00eW0000000M6s9IAC;00eW0000000M7iPIAS;'));
        csDataList.add(new DataValueMap__c(Name='Closed',Data_Value__c='Closed'));
        csDataList.add(new DataValueMap__c(Name='Visibility',Data_Value__c='AllUsers'));
        csDataList.add(new DataValueMap__c(Name='Not Entitled',Data_Value__c='Not Entitled'));
        csDataList.add(new DataValueMap__c(Name='Type',Data_Value__c='TextPost'));
        csDataList.add(new DataValueMap__c(Name='QuestionPost',Data_Value__c='QuestionPost'));
        csDataList.add(new DataValueMap__c(Name='ArticleTypeNames',Data_Value__c='KnowledgeArticle__ka,Break_Fix_ka,Tools__ka,Troubleshooting_Guide__ka,Concept__ka,How_To__ka, Checklist__ka,'));
        csDataList.add(new DataValueMap__c(Name='Pivotal - AccountShare Access',Data_Value__c='0PSf0000000DNtBGAW'));
        insert csDataList;
      
        
        Company_Code__c code = new Company_Code__c();
        code.Name = 'This is Foo';
        code.Tax_Region__c = 'bar';
        insert code;

        Test.startTest();
        List<String> users = new List<String>{'Falkirk IAD Integration'};
        RefreshService.refresh(users);
        Test.stopTest();

        Company_Code__c updatedCode = [SELECT Name, Tax_Region__c FROM Company_Code__c WHERE Name = 'This is Foo'];
        System.assertEquals('TEST-bar', updatedCode.Tax_Region__c);
    }

    static testMethod void taxRegions_whenTheyAreAlreadyAppendedWithTest_shouldNotBePrependedWithMoreTests() {
        
         List<Profile> lstProfile = TestDataUtil.getProfiles();
        
         List<DataValueMap__c>  csDataList =  new List<DataValueMap__c>();
        csDataList.add(new DataValueMap__c(Name = 'PortalManagerProfileId', Data_Value__c = lstProfile[0].Id));
        csDataList.add(new DataValueMap__c(Name = 'PortalUserProfileId', Data_Value__c = lstProfile[1].Id)); 
        csDataList.add(new DataValueMap__c(Name = 'ErrorOnCloseCaseUpdate', Data_Value__c = 'You can not modify closed case.'));
        csDataList.add(new DataValueMap__c(Name = 'customerCaseStatus', Data_Value__c = 'Closed,Solved,In Progress'));
        csDataList.add(new DataValueMap__c(Name = 'Expired', Data_Value__c = 'Expired'));
        csDataList.add(new DataValueMap__c(Name = 'Active', Data_Value__c = 'active'));
        csDataList.add(new DataValueMap__c(Name = 'ArticleTypes', Data_Value__c = 'a42'));
        csDataList.add(new DataValueMap__c(Name = 'bypassModifyClosedCase', Data_Value__c = 'TRUE'));
        csDataList.add(new DataValueMap__c(Name = 'EHSP support', Data_Value__c = 'ehsp.scqa@pivotal.io'));
        csDataList.add(new DataValueMap__c(Name = 'EHSP Escalations', Data_Value__c = 'ehsp-escalations.scqa@pivotal.io'));
        csDataList.add(new DataValueMap__c(Name = 'OnDemandaccountAlias', Data_Value__c = 'ondemand-support.scqa@pivotal.io')); 
        csDataList.add(new DataValueMap__c(Name='Embargo_Countries',Data_Value__c=';Iran;Cuba;North Korea;Sudan;Syria;'));
        csDataList.add(new DataValueMap__c(Name='RPS_Status',Data_Value__c=';Triple Red;Double Red;Red;Risk Country;Yellow;'));
        csDataList.add(new DataValueMap__c(Name='PortalRegisteredUserId',Data_Value__c='00eW0000000I1OOIA0'));
        
       
        csDataList.add(new DataValueMap__c(Name='PivotalSupportProfile',Data_Value__c='00eW0000000I1OmIAK'));
        csDataList.add(new DataValueMap__c(Name='Internal comments for R&D and PKS',Data_Value__c=';00eW0000000M6s9IAC;00eW0000000M7iPIAS;'));
        csDataList.add(new DataValueMap__c(Name='Closed',Data_Value__c='Closed'));
        csDataList.add(new DataValueMap__c(Name='Visibility',Data_Value__c='AllUsers'));
        csDataList.add(new DataValueMap__c(Name='Not Entitled',Data_Value__c='Not Entitled'));
        csDataList.add(new DataValueMap__c(Name='Type',Data_Value__c='TextPost'));
        csDataList.add(new DataValueMap__c(Name='QuestionPost',Data_Value__c='QuestionPost'));
        csDataList.add(new DataValueMap__c(Name='ArticleTypeNames',Data_Value__c='KnowledgeArticle__ka,Break_Fix_ka,Tools__ka,Troubleshooting_Guide__ka,Concept__ka,How_To__ka, Checklist__ka,'));
        csDataList.add(new DataValueMap__c(Name='Pivotal - AccountShare Access',Data_Value__c='0PSf0000000DNtBGAW'));
        insert csDataList;
      
        
        Company_Code__c code = new Company_Code__c();
        code.Name = 'This is Foo';
        code.Tax_Region__c = 'TEST-bar';
        insert code;

        Test.startTest();
        List<String> users = new List<String>{'Falkirk IAD Integration'};
        RefreshService.refresh(users);
        Test.stopTest();

        Company_Code__c updatedCode = [SELECT Name, Tax_Region__c FROM Company_Code__c WHERE Name = 'This is Foo'];
        System.assertEquals('TEST-bar', updatedCode.Tax_Region__c);
    }

    static testMethod void contactEmails_shouldBeChanged() {
       
       
          Account acc = TestDataFactory.createAccount(true);
        List<Profile> lstProfile = TestDataUtil.getProfiles();
    
    List<DataValueMap__c>  csDataList =  new List<DataValueMap__c>();
    csDataList.add(new DataValueMap__c(Name = 'PortalManagerProfileId', Data_Value__c = lstProfile[0].Id));
    csDataList.add(new DataValueMap__c(Name = 'PortalUserProfileId', Data_Value__c = lstProfile[1].Id)); 
    csDataList.add(new DataValueMap__c(Name = 'ErrorOnCloseCaseUpdate', Data_Value__c = 'You can not modify closed case.'));
    csDataList.add(new DataValueMap__c(Name = 'customerCaseStatus', Data_Value__c = 'Closed,Solved,In Progress'));
    csDataList.add(new DataValueMap__c(Name = 'Expired', Data_Value__c = 'Expired'));
    csDataList.add(new DataValueMap__c(Name = 'Active', Data_Value__c = 'active'));
    csDataList.add(new DataValueMap__c(Name = 'ArticleTypes', Data_Value__c = 'a42'));
    csDataList.add(new DataValueMap__c(Name = 'bypassModifyClosedCase', Data_Value__c = 'TRUE'));
    csDataList.add(new DataValueMap__c(Name = 'EHSP support', Data_Value__c = 'ehsp.scqa@pivotal.io'));
    csDataList.add(new DataValueMap__c(Name = 'EHSP Escalations', Data_Value__c = 'ehsp-escalations.scqa@pivotal.io'));
    csDataList.add(new DataValueMap__c(Name = 'OnDemandaccountAlias', Data_Value__c = 'ondemand-support.scqa@pivotal.io')); 
    csDataList.add(new DataValueMap__c(Name='Embargo_Countries',Data_Value__c=';Iran;Cuba;North Korea;Sudan;Syria;'));
    csDataList.add(new DataValueMap__c(Name='RPS_Status',Data_Value__c=';Triple Red;Double Red;Red;Risk Country;Yellow;'));
    csDataList.add(new DataValueMap__c(Name='PortalRegisteredUserId',Data_Value__c='00eW0000000I1OOIA0'));
    csDataList.add(new DataValueMap__c(Name = 'RegisteredAccount', Data_Value__c = acc.id));
    
    
    csDataList.add(new DataValueMap__c(Name='PivotalSupportProfile',Data_Value__c='00eW0000000I1OmIAK'));
    csDataList.add(new DataValueMap__c(Name='Internal comments for R&D and PKS',Data_Value__c=';00eW0000000M6s9IAC;00eW0000000M7iPIAS;'));
    csDataList.add(new DataValueMap__c(Name='Closed',Data_Value__c='Closed'));
    csDataList.add(new DataValueMap__c(Name='Visibility',Data_Value__c='AllUsers'));
    csDataList.add(new DataValueMap__c(Name='Not Entitled',Data_Value__c='Not Entitled'));
    csDataList.add(new DataValueMap__c(Name='Type',Data_Value__c='TextPost'));
    csDataList.add(new DataValueMap__c(Name='QuestionPost',Data_Value__c='QuestionPost'));
    csDataList.add(new DataValueMap__c(Name='ArticleTypeNames',Data_Value__c='KnowledgeArticle__ka,Break_Fix_ka,Tools__ka,Troubleshooting_Guide__ka,Concept__ka,How_To__ka, Checklist__ka,'));
    csDataList.add(new DataValueMap__c(Name='Pivotal - AccountShare Access',Data_Value__c='0PSf0000000DNtBGAW'));
    insert csDataList;
      
      
        
     
        string Emailid= 'testcontactEmails@gmail.com';
        Contact ctt = new Contact();
        ctt.FirstName = 'Test';
        ctt.LastName = 'Contact';
        ctt.Email = Emailid;
        ctt.MailingCountry = 'United States';
        ctt.MailingCountryCode = 'US';
        ctt.MailingState = 'Washington';
        ctt.MailingStateCode = 'WA';
        ctt.MailingPostalCode = '12345';
        ctt.MailingStreet = '123 Main St.';
        ctt.MailingCity = 'Seattle';
        ctt.Phone = '404-444-4444';
        ctt.AccountId = acc.id;

        insert ctt;

        Test.startTest();
        List<String> users = new List<String>{'Falkirk IAD Integration'};
        RefreshService.refresh(users);
        Test.stopTest();

        Contact updatedCtt = [SELECT Id, Email FROM Contact WHERE Id = :ctt.Id];
        //System.assertEquals('fakeemail@sfdc.com', updatedCtt.Email, 'Contact email should be fake');
    }

    static testMethod void leadEmails_shouldBeChanged() {
          
         List<Profile> lstProfile = TestDataUtil.getProfiles();
         List<DataValueMap__c>  csDataList =  new List<DataValueMap__c>();
        csDataList.add(new DataValueMap__c(Name = 'PortalManagerProfileId', Data_Value__c = lstProfile[0].Id));
        csDataList.add(new DataValueMap__c(Name = 'PortalUserProfileId', Data_Value__c = lstProfile[1].Id)); 
        csDataList.add(new DataValueMap__c(Name = 'ErrorOnCloseCaseUpdate', Data_Value__c = 'You can not modify closed case.'));
        csDataList.add(new DataValueMap__c(Name = 'customerCaseStatus', Data_Value__c = 'Closed,Solved,In Progress'));
        csDataList.add(new DataValueMap__c(Name = 'Expired', Data_Value__c = 'Expired'));
        csDataList.add(new DataValueMap__c(Name = 'Active', Data_Value__c = 'active'));
        csDataList.add(new DataValueMap__c(Name = 'ArticleTypes', Data_Value__c = 'a42'));
        csDataList.add(new DataValueMap__c(Name = 'bypassModifyClosedCase', Data_Value__c = 'TRUE'));
        csDataList.add(new DataValueMap__c(Name = 'EHSP support', Data_Value__c = 'ehsp.scqa@pivotal.io'));
        csDataList.add(new DataValueMap__c(Name = 'EHSP Escalations', Data_Value__c = 'ehsp-escalations.scqa@pivotal.io'));
        csDataList.add(new DataValueMap__c(Name = 'OnDemandaccountAlias', Data_Value__c = 'ondemand-support.scqa@pivotal.io')); 
        csDataList.add(new DataValueMap__c(Name='Embargo_Countries',Data_Value__c=';Iran;Cuba;North Korea;Sudan;Syria;'));
        csDataList.add(new DataValueMap__c(Name='RPS_Status',Data_Value__c=';Triple Red;Double Red;Red;Risk Country;Yellow;'));
        csDataList.add(new DataValueMap__c(Name='PortalRegisteredUserId',Data_Value__c='00eW0000000I1OOIA0'));
        
       
        csDataList.add(new DataValueMap__c(Name='PivotalSupportProfile',Data_Value__c='00eW0000000I1OmIAK'));
        csDataList.add(new DataValueMap__c(Name='Internal comments for R&D and PKS',Data_Value__c=';00eW0000000M6s9IAC;00eW0000000M7iPIAS;'));
        csDataList.add(new DataValueMap__c(Name='Closed',Data_Value__c='Closed'));
        csDataList.add(new DataValueMap__c(Name='Visibility',Data_Value__c='AllUsers'));
        csDataList.add(new DataValueMap__c(Name='Not Entitled',Data_Value__c='Not Entitled'));
        csDataList.add(new DataValueMap__c(Name='Type',Data_Value__c='TextPost'));
        csDataList.add(new DataValueMap__c(Name='QuestionPost',Data_Value__c='QuestionPost'));
        csDataList.add(new DataValueMap__c(Name='ArticleTypeNames',Data_Value__c='KnowledgeArticle__ka,Break_Fix_ka,Tools__ka,Troubleshooting_Guide__ka,Concept__ka,How_To__ka, Checklist__ka,'));
        csDataList.add(new DataValueMap__c(Name='Pivotal - AccountShare Access',Data_Value__c='0PSf0000000DNtBGAW'));
        insert csDataList;
      
        
        Lead lead = TestDataFactory.createLead(true);

        Test.startTest();
        List<String> users = new List<String>{'Falkirk IAD Integration'};
        RefreshService.refresh(users);
        Test.stopTest();

        Lead updatedLead = [SELECT Id, Email FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('fakeemail@sfdc.com', updatedLead.Email, 'Lead email should be fake');
    }

    static testMethod void quoteShipTo_shouldBeChanged() {
         TestDataUtil.dataValueMapCSData();
        Account acc = TestDataFactory.createAccount(true);
        //Contact ctt = getContact(acc.Id);
        
        Contact ctt = TestDataFactory.createContact(acc.id, false);
        ctt.LastName = 'Fake12';
        ctt.Email = 'ZuoraSuxshouldBeChanged@hotmail.com';
        insert ctt;
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);
        zqu__Quote__c zQuote = ZTestFactory.makeQuote(opp, ctt);

        Test.startTest();
        List<String> users = new List<String>{'Falkirk IAD Integration'};
        RefreshService.refresh(users);
        Test.stopTest();

        zqu__Quote__c updatedQuote = [SELECT Id, Ship_Contact_Email__c FROM zqu__Quote__c WHERE Id = :zQuote.Id];
        //System.assertEquals('ZuoraSuxshouldBeChanged@zuora.com', updatedQuote.Ship_Contact_Email__c, 'Ship to email should be fake'); 
    } 

    /* Private Methods */

    private static boolean isUserActive(String name) {
        User u = [SELECT Id, isActive FROM User WHERE Name = :name];
        return u.isActive;
    }

    private static void deactivateUser(String userName) {
        User u = [SELECT Id FROM User WHERE Name = :userName];
        u.isActive = false;
        update u;
    }

    private static Contact getContact(Id accId,string emailid) {
        //This Method is in use because of a terrible trigger Zuora has us using
        Contact ctt1 = TestDataFactory.createContact(accId, true);
        Contact ctt2 = TestDataFactory.createContact(accId, false);
        ctt2.LastName = 'Fake';
        ctt2.Email = emailid;
        insert ctt2;
        return ctt1;
    }
}