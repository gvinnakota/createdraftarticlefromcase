/*
*************************************************************************************************************
* Apex Class Name  : ContactUpdateApexControllerL1_TC
* Version          : 1.0
* Created Date     : 14 Mar 2018
* Function         : Class is used test ContactUpdateApexController - update Contact with field values 
                     coming from Login Flow for L1 profile
* Modification Log : 
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Soham Banerjee                 14/03/2018            Test Class to test ContactUpdateApexController
* ------------------------------------------------------------------------------------------------------------------
************************************************************************************************************
*/
@isTest
private class ContactUpdateApexControllerL1_TC {
    
    @isTest static void test_method_one() {
        Test.startTest();
        TestDataUtil.dataValueMapCSData();
        Contact rCont = TestDataUtil.createPortalContact();
        System.assert(rCont !=null);
        System.assert(rCont.Name ==null, rCont.Name);
        List<String> strFieldValuesList = new List<String>();
        strFieldValuesList.add(rCont.Id);
        strFieldValuesList.add('IN');

        List<String> parametersList = new List<String>();
        parametersList.add('Id=' + strFieldValuesList[0] + 
                           '~TermsAndConditions__c=true' + 
                           '~MailingCountryCode=' + strFieldValuesList[1]);
        ContactUpdateApexControllerL1.updateContactL1(parametersList);
        Test.stopTest();
    }
}