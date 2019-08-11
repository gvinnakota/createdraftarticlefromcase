@isTest
public class ZQuoteTriggerHandlerValidUntilDate_Test {

    /* Test Methods */

    static testMethod void test_quote_valid_until_update() {
        Account acc = TestDataFactory.createAccount(true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);
        Contact ctct = TestDataFactory.createContact(acc.Id, true);

        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, ctct);
        quote.zqu__StartDate__c = System.today() + 90;
        quote.zqu__Customer_Acceptance_Date__c = System.today() + 90;
        quote.zqu__Service_Activation_Date__c = System.today() + 90;

        Test.startTest();

        update quote;

        Test.stopTest();

        Period quarterPeriod = [SELECT EndDate FROM Period WHERE StartDate <= :quote.zqu__StartDate__c AND EndDate >= :quote.zqu__StartDate__c AND Type = 'Quarter'];

        zqu__Quote__c updatedQuote = [SELECT Id, zqu__ValidUntil__c FROM zqu__Quote__c WHERE Id = :quote.Id];
        System.assertEquals(quarterPeriod.EndDate, updatedQuote.zqu__ValidUntil__c, 'Expiration Date is incorrect');
    }
}