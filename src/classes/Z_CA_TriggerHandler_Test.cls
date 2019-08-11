@isTest(SeeAllData=true)
public class Z_CA_TriggerHandler_Test {

    static testMethod void testInsert() {
        // Starting test
        Test.startTest();
        
        Account acc = ZTestFactory.makeAccount();
        Contact ct = ZTestFactory.makeContact(acc);
        Zuora__CustomerAccount__c ca = new Zuora__CustomerAccount__c();
        ca.Name = 'Test Billing Account';
        ca.CRM_Bill_To_Contact_Id__c = ct.Id;
        ca.CRM_Sold_To_Contact_Id__c = ct.Id;
        ca.Zuora__Account__c = acc.Id; 
        
        insert ca; 

        // Stopping test
        Test.stopTest();
        
    }

}