/*
/*******************************************************************************************************************
* Apex Class Name  : AccountHelper_TC
* Version          : 1.0
* Created Date     : 28 Oct 2017
* Function         : Class is used test AccountHelper - account share create/update/delete
* Modification Log : 
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Deepa Lakamanhalli            28/10/2017            Test Class to test AccountHelper
* ------------------------------------------------------------------------------------------------------------------
********************************************************************************************************************
*/
@isTest
public class AccountHelper_TC{
    public static testmethod void accHelperTest(){
        Test.startTest();
        TestDataUtil.dataValueMapCSData();
        Account acc = TestDataUtil.createAccount();
        Contact con = TestDataUtil.createPortalContact();
        User usr = [Select id from User where ContactId=:con.Id];
        System.assert(usr!=Null,'User not created');
        AccountContactRole acr = TestDataUtil.createAccountContactRole(acc.Id, con.Id);    
        Test.setCurrentPage(Page.AccountContactRole);
        AccountHelper accHelpCtrl= new AccountHelper(new ApexPages.StandardController(acc));
        accHelpCtrl.rollupOppContacts();
        acr.Role = 'Multiple PCN View All'; 
        update acr;
        accHelpCtrl.rollupOppContacts();
        delete acr;
        accHelpCtrl.rollupOppContacts();
        
    }
}