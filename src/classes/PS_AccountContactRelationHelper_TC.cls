/*
/*******************************************************************************************************************
* Apex Class Name  : PS_AccountContactRelationHelper
* Version          : 1.0
* Created Date     : 19 Feb 2018
* Function         : Class is used test PS_AccountContactRelationHelper - account share create/update/delete
* Modification Log : 
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Rohan Kolvekar            19/02/2018            Test Class to test PS_AccountContactRelationHelper
* ------------------------------------------------------------------------------------------------------------------
********************************************************************************************************************
*/
@isTest
public class PS_AccountContactRelationHelper_TC{
    public static testmethod void accHelperTest(){
        Test.startTest();
        TestDataUtil.dataValueMapCSData();
        Account acc = TestDataUtil.createAccount();
        Contact con = TestDataUtil.createPortalContact();
        
        User usr = [Select id from User where ContactId=:con.Id];
        System.assert(usr!=Null,'User not created');        
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = acc.Id;
        acr.ContactId = con.Id;
        acr.Roles ='Multiple PCNs';
        insert acr;
        acr.Roles = 'Multiple PCN ViewAll'; 
        update acr;
        delete acr;
       

    }
}