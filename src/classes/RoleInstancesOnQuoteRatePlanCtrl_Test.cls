@IsTest
public class RoleInstancesOnQuoteRatePlanCtrl_Test {
    @TestSetup
    static void prepare(){
        TestDataUtil.dataValueMapCSData();
    }

    @IsTest
    static void testController() {
        Account acc = TestDataFactory.createAccount(true);
        Contact ctt = TestDataFactory.createContact(acc.Id, true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);
        zqu__Quote__c testQuote = TestDataFactory.makeQuote(opp, ctt);
        zqu__QuoteAmendment__c quoteAmend = ZTestFactory.makeQuoteAmendment(testQuote);

        zqu__ZProduct__c zProd = TestDataFactory.makeProduct('Test App Suite', 'SSS-12123');
        zqu__ProductRatePlan__c prp = TestDataFactory.makeProductRatePlan(zProd.Id, 'Annual Rate Plan');
        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.makeProductRatePlanCharge(prp.Id, 'type', 'model');

        zqu__QuoteRatePlan__c quoteRatePlan = TestDataFactory.makeQuoteRatePlan(testQuote, quoteAmend);
        zqu__QuoteRatePlanCharge__c qrpc = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);

        Role_Instance__c ri = new Role_Instance__c();
        ri.Quote_Rate_Plan_Charge__c = qrpc.Id;
        insert ri;

        ApexPages.StandardController ctrl = new ApexPages.StandardController(quoteRatePlan);
        RoleInstancesOnQuoteRatePlanController roleInstancesController = new RoleInstancesOnQuoteRatePlanController(ctrl);

        System.assertNotEquals(null, roleInstancesController.instances);
        System.assert(!roleInstancesController.instances.isEmpty());
    }

}