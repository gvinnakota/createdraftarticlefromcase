/**
 * Created by klukawski on 10/15/18.
 */

@IsTest
public with sharing class QuoteRatePlanDeletedListControllerTest {
    @TestSetup
    public static void setup(){
        TestDataUtil.dataValueMapCSData();
    }

    public static testMethod void testController(){
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact);
        zqu__Quote__c quote2 = ZTestFactory.makeQuote(opp, contact);

        zqu__QuoteAmendment__c qa = ZTestFactory.makeQuoteAmendment(quote);
        zqu__QuoteRatePlan__c qrp = ZTestFactory.makeQuoteRatePlan(quote, qa);

        Map<String, String> params = new Map<String, String>{
                QuoteRatePlanDeletedListController.CLONE_ID => quote2.Id,
                QuoteRatePlanDeletedListController.RATE_PLAN_IDS => qrp.Id
        };

        ApexPages.currentPage().getParameters().putAll(params);

        QuoteRatePlanDeletedListController ctrl = new QuoteRatePlanDeletedListController();
        System.assertNotEquals(ctrl.redirect(), null);

        ApexPages.currentPage().getParameters().clear();
        ctrl = new QuoteRatePlanDeletedListController();
        System.assertEquals(ctrl.redirect(), null);
    }
}