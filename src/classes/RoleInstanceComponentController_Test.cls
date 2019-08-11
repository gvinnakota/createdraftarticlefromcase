@IsTest
private class RoleInstanceComponentController_Test {
    @TestSetup
    static void prepare(){
        TestDataUtil.dataValueMapCSData();
    }

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

        String name1 = 'name1';
        String name2 = 'name2';

        List<Role_Instance__c> roleInstances = new List<Role_Instance__c>();
        roleInstances.add(new Role_Instance__c(Name = name1, Quote_Rate_Plan_Charge__c = qrpc.Id));
        insert roleInstances;

        ApexPages.StandardController ctrl = new ApexPages.StandardController(qrpc);
        RoleInstanceComponentController roleInstancesController = new RoleInstanceComponentController(ctrl);

        System.assertEquals(qrpc.Id, roleInstancesController.getQRPCId());
        System.assert(roleInstancesController.getIsCustomCharge());
        System.debug('bdec // getRenderPage(): ' + roleInstancesController.getRenderPage());

        System.assertNotEquals(null, roleInstancesController.instances);
        System.assert(!roleInstancesController.instances.isEmpty());

        roleInstancesController.instances.get(0).Name = name2;
        roleInstancesController.saveAndCalculate();

        roleInstances = new List<Role_Instance__c>([
                SELECT Id, Name, Quote_Rate_Plan_Charge__c
                FROM Role_Instance__c
        ]);

        System.assertEquals(name2, roleInstances.get(0).Name);

        roleInstancesController.editMode = false;
        roleInstancesController.editRow();
        System.assert(roleInstancesController.editMode);

        System.assertEquals(null, roleInstancesController.displayPopup);
        roleInstancesController.showPopup();
        System.assert(roleInstancesController.displayPopup);
        roleInstancesController.closePopup();
        System.assert(!roleInstancesController.displayPopup);
    }
}