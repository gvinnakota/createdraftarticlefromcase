/*
/*******************************************************************************************************************
* Apex Class Name  : PS_ContactTriggerHandler_TC
* Version          : 1.0
* Created Date     : 28 Oct 2017
* Function         : Class is used test PS_ContactTriggerHandler - create and update Portal User through Contact
* Modification Log : 
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Deepa Lakamanhalli            28/10/2017            Test Class to test PS_ContactTriggerHandler
* ------------------------------------------------------------------------------------------------------------------
********************************************************************************************************************
*/
@isTest
public class PS_ContactTriggerHandler_TC {
    static testmethod void createPortalUserTest(){
        Test.startTest();
        TestDataUtil.dataValueMapCSData();
        
        Contact rCont = TestDataUtil.createPortalContact();
        System.debug('contact : '+rCont+'-'+Contact.AccountId);
        System.assert(rCont !=null);
        System.assert(rCont.Name ==null, rCont.Name);
        User u = [Select id,ContactId, AccountId from User where contactId=:rCont.Id];
        System.debug('user created: '+u);
        Case cas = TestDataUtil.createCaseByPortalUser(u);
        checkRecursive.checkContact = true;
        rCont.BusinessHours__c= [select Id, Name FROM BusinessHours where isActive=true ORDER BY Name LIMIT 1].Id;
        rCont.Enable_Portal_User__c=true;
        rCont.Interact_with_Community__c=true;
        rCont.View_Account_Cases__c=true;
        rCont.Customer_Admin__c = true;
        rCont.MailingCountry = 'India';
        update rCont;
        Case cs = TestDataUtil.createTechnicalCase();
        cs.ContactId = rCont.Id;
        update cs;
        checkRecursive.checkContact = true;
        rCont.View_Account_Cases__c = true;
        rCont.BusinessHours__c=[select Id, Name FROM BusinessHours where isActive=true and name='EMEA' ORDER BY Name LIMIT 1].Id;
        update rCont;
        Test.stopTest();
    }
    static testmethod void createPortalUserTest1(){
        Test.startTest();
        TestDataUtil.dataValueMapCSData();
        Contact rCont1 = TestDataUtil.createPortalContact1();
        rCont1.Enable_Portal_User__c=true;
        checkRecursive.checkContact = true;
        update rCont1;
        rCont1.Update_check__c  = true;
        rCont1.Export_Status__c = 'In Progress';
        checkRecursive.checkContact = true;
        update rCont1;

        Test.stopTest();
    }
    static testmethod void createPortalUserTest2(){
        Test.startTest();
        TestDataUtil.dataValueMapCSData();
        
        Contact rCont2 = TestDataUtil.createPortalContact2();
        User u = [Select id,ContactId,ProfileId,AccountId,isActive from User where contactId=:rCont2.Id];
        System.debug('User activation-->'+ u.isActive);
        rCont2.Export_Status__c = 'Cleared';
        checkRecursive.checkContact = true;
        update rCont2;
        rCont2.Export_Status__c = 'Denied';
        checkRecursive.checkContact = true;
        update rCont2;
        rCont2.Update_check__c  = true;
        rCont2.Export_Status__c = 'In Progress';
        checkRecursive.checkContact = true;
        update rCont2;
        Test.stopTest();
        
 
    }

    static testmethod void createPortalUserTest3(){
        Test.startTest();
        TestDataUtil.dataValueMapCSData();
        
        Contact rCont = TestDataUtil.createPortalContact();
        System.debug('contact : '+rCont+'-'+Contact.AccountId);
        System.assert(rCont !=null);
        System.assert(rCont.Name ==null, rCont.Name);
        User u = [Select id,ContactId, AccountId from User where contactId=:rCont.Id];
        Case cas = TestDataUtil.createCaseByPortalUser(u);
        checkRecursive.checkContact = true;
        rCont.BusinessHours__c= [select Id, Name FROM BusinessHours where isActive=true ORDER BY Name LIMIT 1].Id;
        rCont.Enable_Portal_User__c=true;
        rCont.Interact_with_Community__c=true;
        rCont.View_Account_Cases__c=true;
        rCont.Customer_Admin__c = true;
        rCont.MailingCountry = 'India';
        update rCont;
        List<Contact> contactList = new List<Contact>();
        contactList.add(rCont);
        PS_ContactTriggerHandler.updateContactAccount(contactList);
        Test.stopTest();
    }

    static testmethod void createPortalUserTest4(){
        Test.startTest();
        TestDataUtil.dataValueMapCSData();
        
        Contact rCont = TestDataUtil.createPortalContact2();
        System.assert(rCont.Name == NULL, rCont.Name);
        rCont.Customer_Admin__c = false;
        rCont.View_Account_Cases__c = false;
        checkRecursive.checkContact = true;
        update rCont;

        Test.stopTest();
    }

    static testmethod void createPortalUserTest5(){
        Test.startTest();
        TestDataUtil.dataValueMapCSData();
        
        Contact rCont = TestDataUtil.createPortalContact1();
        System.assert(rCont.Name == NULL, rCont.Name);
        Account acc = new Account();
        acc.name = 'Test2';
        insert acc;
        AccountContactRelation acr = new AccountContactRelation(AccountId = acc.Id,
                                                                ContactId = rCont.Id,
                                                                Roles = 'Multiple PCN View All',
                                                                IsActive = true,
                                                                StartDate = Date.today().addDays(-1),
                                                                EndDate = Date.today().addDays(1));
        insert acr;

        rCont.Enable_Portal_User__c=true;
        rCont.View_Account_Cases__c = true;
        checkRecursive.checkContact = true;
        update rCont;
        
        Test.stopTest();
    }

    static testmethod void deleteDiscussionRecordListTest(){
        Test.startTest();        
        TestDataUtil.dataValueMapCSData();
        Contact cont = TestDataUtil.createPortalContact();
        User u = [SELECT Id,ContactId, AccountId 
                  FROM User 
                  WHERE contactId = :cont.Id];          
        FeedItem fi = new FeedItem(CreatedById = u.Id,
                                   Title = 'Test',
                                   Body = 'Test',
                                   Type = 'QuestionPost',
                                   ParentId = cont.AccountId);
        insert fi;
        cont.MailingCountry = 'Cuba';
        cont.Export_Status__c = 'Denied';
        checkRecursive.checkContact = true;
        update cont;
    }
}