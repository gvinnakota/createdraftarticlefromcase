@isTest
public with sharing class PACReportingControllerTest {

    @TestSetup
    static void createData() {
        TestDataUtil.dataValueMapCSData();
        TestUtils.createUser('testLaunchpad', TestUtils.PROFILE_SYSTEM_ADMINISTRATOR, true);
    }


    static void prepareData() {
        Account acc = TestDataFactory.createAccount(true);
        Contact ctt = TestDataFactory.createContact(acc.Id, true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);
        opp.CloseDate = Date.valueOf('2019-05-05');
        update opp;

        Product2 product = new Product2(Name = 'Test App Suite', zqu__SKU__c = 'SSS-12123');
        insert product;

        zqu__ZProduct__c zProd = [SELECT Id, Name, zqu__SKU__c FROM zqu__ZProduct__c WHERE zqu__Product__c = :product.Id];

        zqu__ProductRatePlan__c prp = TestDataFactory.makeProductRatePlan(zProd.Id, 'Annual Rate Plan', product.Id);

        zqu__ProductRatePlanCharge__c prpc = ZTestFactory.makeProductRatePlanCharge(prp.Id, 'One-Time', 'Per Unit Pricing');
        prpc.zqu__UOM__c = 'Core';
        prpc.Unit_Quantity__c = 1;
        update prpc;

        zqu__Quote__c testQuote2 = TestDataFactory.makeQuote(opp, ctt);
        testQuote2.zqu__Status__c = 'Sent to ZBilling';
        update testQuote2;
        zqu__Quote__c testQuote = TestDataFactory.makeQuote(opp, ctt);
        testQuote.Primary_Quote__c = true;
        update testQuote;

        zqu__QuoteAmendment__c testAmendment = ZTestFactory.makeQuoteAmendment(testQuote);

        zqu__QuoteRatePlan__c testQRP = TestDataFactory.makeQuoteRatePlan(testQuote, testAmendment);

        zqu__QuoteRatePlanCharge__c testQRPC = ZTestFactory.makeQuoteRatePlanCharge(testQRP, prpc);
        testQRPC.zqu__Quantity__c = 1;
        testQRPC.Initial_Term__c = 12;
        testQRPC.Start_Date__c = '2019-05-05';
        update testQRPC;

        PACAllocatorTest.preparePACMapWithId(true, product.Id);
        PACAllocatorTest.preparePACsWithQuoteId(testQuote.Id);
        PAC__c pac = new PAC__c(
                Product__c = 'ABC',
                Quantity__c = 1,
                Status__c = 'Assigned',
                Code__c = 'CNA-NXT-ABC-C-1yr -1',
                Duration__c = 1,
                Key__c = 'AAAAA-AAAAA-AAAAA-AAAAA-AAADD',
                Quote__c = testQuote2.Id
        );
        insert pac;
    }

    @IsTest
    static void testResponseDateInRange() {
        prepareData();
        User u = TestUtils.findUser('testLaunchpad');
        System.runAs(u) {
            ApexPages.currentPage().getParameters().put('startDate', '2019-05-05');
            ApexPages.currentPage().getParameters().put('endDate', '2019-05-10');
            Test.startTest();
            PACReportingController controller = new PACReportingController();
            System.assertEquals('{"1_1_ABC":1}', controller.pipelineChartValueMap);
            Test.stopTest();
        }
    }

    @IsTest
    static void testResponseDateOutOfRange() {
        prepareData();
        User u = TestUtils.findUser('testLaunchpad');
        System.runAs(u) {
            ApexPages.currentPage().getParameters().put('startDate', '2019-05-06');
            ApexPages.currentPage().getParameters().put('endDate', '2019-05-10');
            Test.startTest();
            PACReportingController controller = new PACReportingController();
            System.debug(controller.pipelineChartValueMap);
            System.assertEquals('{}', controller.pipelineChartValueMap);
            Test.stopTest();
        }
    }

    @IsTest
    static void testResponseInventory() {
        prepareData();
        User u = TestUtils.findUser('testLaunchpad');
        System.runAs(u) {
            ApexPages.currentPage().getParameters().put('startDate', '2019-05-05');
            ApexPages.currentPage().getParameters().put('endDate', '2019-05-10');
            Test.startTest();
            PACReportingController controller = new PACReportingController();
            System.assertEquals('{"null_DDD":1,"null_ABC":6}', controller.inventoryChartValueMap);
            Test.stopTest();
        }
    }

    @IsTest
    static void testResponseInventoryLabels() {
        prepareData();
        User u = TestUtils.findUser('testLaunchpad');
        System.runAs(u) {
            ApexPages.currentPage().getParameters().put('startDate', '2019-05-05');
            ApexPages.currentPage().getParameters().put('endDate', '2019-05-10');
            Test.startTest();
            PACReportingController controller = new PACReportingController();
            System.debug(controller.inventoryChartLabelMap);
            System.assertEquals('{"null_DDD":"DDD with quantity 1 pcs and duration of 1 years","null_ABC":"ABC with quantity 1 pcs and duration of 1 years"}', controller.inventoryChartLabelMap);
            Test.stopTest();
        }
    }

    @IsTest
    static void testWithoutParameters() {
        User u = TestUtils.findUser('testLaunchpad');
        System.runAs(u) {
            Test.startTest();
            PACReportingController controller = new PACReportingController();
            Test.stopTest();
            System.assert(!controller.hasParams);
        }
    }

    @IsTest
    static void testWithParameters() {
        User u = TestUtils.findUser('testLaunchpad');
        System.runAs(u) {
            ApexPages.currentPage().getParameters().put('startDate', '2019-05-05');
            ApexPages.currentPage().getParameters().put('endDate', '2019-05-05');
            Test.startTest();
            PACReportingController controller = new PACReportingController();
            Test.stopTest();
            System.assert(controller.hasParams);
            System.assert(controller.startDate != null);
            System.assert(controller.endDate != null);
        }
    }

    @IsTest
    static void testRefreshAction() {
        User u = TestUtils.findUser('testLaunchpad');
        System.runAs(u) {
            Test.startTest();
            PACReportingController controller = new PACReportingController();
            controller.endDate = Date.valueOf('2019-05-05');
            controller.startDate = Date.valueOf('2018-05-05');
            PageReference ref = controller.refresh();
            Test.stopTest();
            System.assertEquals('2018-05-05', ref.getParameters().get('startDate'));
            System.assertEquals('2019-05-05', ref.getParameters().get('endDate'));
            System.assert(ref.getRedirect());
        }
    }
}