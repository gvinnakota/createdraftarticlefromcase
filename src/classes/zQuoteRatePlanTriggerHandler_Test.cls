@isTest
public class zQuoteRatePlanTriggerHandler_Test {
    
    /* Test Methods */
    static testMethod void newQuotes_populateProductRatePlan() {
        TestDataUtil.dataValueMapCSData();
        Account acc = TestDataFactory.createAccount(true);
        Contact ctt = TestDataFactory.createContact(acc.Id, true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);
        zqu__Quote__c testQuote = TestDataFactory.makeQuote(opp, ctt);
        zqu__QuoteAmendment__c quoteAmend = ZTestFactory.makeQuoteAmendment(testQuote);
        zqu__ZProduct__c zProd = TestDataFactory.makeProduct('Test App Suite','SSS-12123');
		zqu__ProductRatePlan__c prp = TestDataFactory.makeProductRatePlan(zProd.Id,'Annual Rate Plan');
        
        Test.startTest();
        zqu__QuoteRatePlan__c quoteRatePlan = TestDataFactory.makeQuoteRatePlan(testQuote, quoteAmend);
        Test.stopTest();
    }
}