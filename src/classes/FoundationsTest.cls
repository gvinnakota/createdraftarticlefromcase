@isTest
public class FoundationsTest {
    // Utility method that can be called by Apex tests to create price book entries.
    static testmethod void TestFoundation() {
        
         Account acc = TestDataUtil.createAccount();    
        
         Foundations__c foundation = new Foundations__c();
         foundation.Month_Consumption_Collected__c='February';
         foundation.Environment__c ='UAT';
         foundation.Account_FR__c = acc.id;
         insert foundation;
        
         test.StartTest();
         foundation.Month_Consumption_Collected__c='March';
         update foundation;
         test.StopTest();
        

         foundation.Month_Consumption_Collected__c='June';
         update foundation;

        

    }
    
}