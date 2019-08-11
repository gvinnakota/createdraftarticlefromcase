/*
*************************************************************************************************************
* Apex Class Name  : ContactUpdateApexController_TC
* Version          : 1.0
* Created Date     : 13 Mar 2018
* Function         : Class is used test ContactUpdateApexController - update Contact with field values 
					 coming from Login Flow
* Modification Log : 
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Soham Banerjee	             13/03/2018            Test Class to test ContactUpdateApexController
* ------------------------------------------------------------------------------------------------------------------
************************************************************************************************************
*/
@isTest
private class ContactUpdateApexController_TC {
	
	@isTest static void test_method_one() {
		Test.startTest();
        TestDataUtil.dataValueMapCSData();
        Contact rCont = TestDataUtil.createPortalContact();
        System.assert(rCont !=null);
        System.assert(rCont.Name ==null, rCont.Name);
		List<String> strFieldValuesList = new List<String>();
		strFieldValuesList.add(rCont.Id);
		strFieldValuesList.add('Email');
		strFieldValuesList.add('Test Company');
		strFieldValuesList.add('9876543210');
		strFieldValuesList.add('Pivotal App Suite');
		strFieldValuesList.add('Pacific/Enderbury');
		strFieldValuesList.add('Specialist');
		strFieldValuesList.add('IN');

		List<String> parametersList = new List<String>();
		parametersList.add('Id=' + strFieldValuesList[0] + 
						   '~Best_Method_of_Contact__c=' + strFieldValuesList[1] + 
						   '~Company__c=' + strFieldValuesList[2] + 
						   '~Phone=' + strFieldValuesList[3] + 
						   '~Product_Selection2__c=' + strFieldValuesList[4] + 
						   '~TermsAndConditions__c=true' + 
						   '~Time_Zone__c=' + strFieldValuesList[5] + 
						   '~Title=' + strFieldValuesList[6] + 
						   '~MailingCountryCode=' + strFieldValuesList[7] +
       					   '~PCN=true' +
                          '~AlreadyL2=true');
		ContactUpdateApexController.updateContact(parametersList);
		Test.stopTest();
		/*System.assertEquals('Email', rCont.Best_Method_of_Contact__c);
		System.assertEquals('Test Company', rCont.Contact_Company__c);
		System.assertEquals('9876543210', rCont.Phone);
		System.assertEquals('Pivotal App Suite', rCont.Product_Selection__c);
		System.assertEquals(true, rCont.TermsAndConditions__c);
		System.assertEquals('Pacific/Enderbury', rCont.Time_Zone__c);
		System.assertEquals('Specialist', rCont.Title);
		System.assertEquals('IN', rCont.MailingCountryCode);*/
	}
}