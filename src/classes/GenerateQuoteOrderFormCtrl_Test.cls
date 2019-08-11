@IsTest
private class GenerateQuoteOrderFormCtrl_Test {

    static testMethod void testBehavior() {
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
        qrpc.zqu__Quantity__c = 1;
        qrpc.zqu__ListPrice__c = 1;
        update qrpc;

        String name1 = 'name1';
        String name2 = 'name2';

        List<Role_Instance__c> roleInstances = new List<Role_Instance__c>();
        roleInstances.add(new Role_Instance__c(Name = name1, Quote_Rate_Plan_Charge__c = qrpc.Id));
        roleInstances.add(new Role_Instance__c(Name = name1, Quote_Rate_Plan_Charge__c = qrpc.Id));
        insert roleInstances;

        ApexPages.StandardController ctrl = new ApexPages.StandardController(testQuote);
        GenerateQuoteOrderForm_Controller controller = new GenerateQuoteOrderForm_Controller(ctrl);

        System.assertNotEquals(null, controller.products);
        System.assert(!controller.products.isEmpty());

        System.debug('bdec // controller.products: ' + controller.products);
        System.debug('bdec // controller.products.size(): ' + controller.products.size());
        System.assertNotEquals(null, controller.getPrintView());
    }
}