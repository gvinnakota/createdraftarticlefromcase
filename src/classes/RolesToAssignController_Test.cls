@IsTest
private class RolesToAssignController_Test {
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

        List<Role__c> roles = new List<Role__c>();
        roles.add(new Role__c(Name = 'RoleInstance'));
        roles.add(new Role__c(Name = 'testRoleInstance2'));
        insert roles;

        List<Role_Instance__c> roleInstances = new List<Role_Instance__c>();
        roleInstances.add(new Role_Instance__c(Name = 'testRoleInstance2', Quote_Rate_Plan_Charge__c = qrpc.Id));
        insert roleInstances;

        ApexPages.currentPage().getParameters().put('qrpcId', qrpc.Id);

        RolesToAssignController roleToAssignController = new RolesToAssignController();

        System.assertNotEquals(null, roleToAssignController.roles);
        System.assert(!roleToAssignController.roles.isEmpty());

        roleToAssignController.roles.get(0).selected = true;
        roleToAssignController.addSelectedRoles();

        roleInstances = new List<Role_Instance__c>([
                SELECT Id
                FROM Role_Instance__c
                WHERE Quote_Rate_Plan_Charge__c = :qrpc.Id
        ]);

        System.assertNotEquals(null, roleInstances);
        System.assertEquals(2, roleInstances.size());
    }

    @IsTest
    static void testRoleToRoleInstanceConverter() {
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

        String roleName = 'testRoleInstance';
        Decimal hourlyRate = 123;

        Role__c role = new Role__c(Name = roleName, Hourly_Rate__c = hourlyRate);
        insert role;

        insert new Role_to_PRPC_Map__c(Role__c = role.Id, Product_Rate_Plan_Charge__c = prpc.Id, Status__c = 'Active');
        List<Role_to_PRPC_Map__c> roleToPrpcMaps = new List<Role_to_PRPC_Map__c>([
                SELECT Id, Role__c, Role__r.Name, Role__r.Hourly_Rate__c, Status__c, Role__r.CurrencyIsoCode
                FROM Role_to_PRPC_Map__c
        ]);

        List<Role_Instance__c> roleInstances = RoleToRoleInstanceConverter.convert(roleToPrpcMaps, qrpc.Id);

        System.debug('bdec // roleInstances: ' + roleInstances);
        System.assertNotEquals(null, roleInstances);
        System.assert(!roleInstances.isEmpty());
        System.assertEquals(roleName, roleInstances.get(0).Name);
        System.assertEquals(hourlyRate, roleInstances.get(0).Hourly_rate__c);

        Role_Instance__c riNew = RoleToRoleInstanceConverter.convert(role, qrpc.Id);

        System.assertNotEquals(null, riNew);
        System.assertEquals(roleName, riNew.Name);

        List<Role__c> roles = RoleHelper.findAllRoles();
        System.assert(RoleHelper.isAddingRoleAvailable(null));
    }
}