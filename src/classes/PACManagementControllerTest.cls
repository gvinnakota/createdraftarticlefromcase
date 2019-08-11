/**
 * Created on 25.09.2018.
 */
@IsTest
public with sharing class PACManagementControllerTest {

    private static Account acc;
    private static Contact ctt;
    private static Opportunity opp;

    private static zqu__Quote__c testQuote;
    private static zqu__QuoteAmendment__c quoteAmend;
    private static Product2 prod;
    private static zqu__ProductRatePlan__c prp;
    private static zqu__ProductRatePlanCharge__c prpc;
    private static zqu__QuoteRatePlan__c quoteRatePlan;
    private static User u;

    @TestSetup
    static void prepare(){
        TestDataUtil.dataValueMapCSData();
    }

    public static void prepareRemainingData() {
        prod = new Product2(Name = 'Test App Suite', zqu__SKU__c = 'SSS-12123');
        insert prod;
        PACAllocatorTest.preparePACMapWithId(true, prod.Id);

        u = TestUtils.createUser('testLaunchpad', TestUtils.PROFILE_SYSTEM_ADMINISTRATOR, true);
        acc = TestDataFactory.createAccount(true);
        ctt = TestDataFactory.createContact(acc.Id, true);
        opp = TestDataFactory.createOpportunity(acc.Id, true);
        testQuote = TestDataFactory.makeQuote(opp, ctt);
        quoteAmend = ZTestFactory.makeQuoteAmendment(testQuote);

        zqu__ZProduct__c zProd = [SELECT Id, Name, zqu__SKU__c FROM zqu__ZProduct__c WHERE zqu__Product__c = :prod.Id];
        update zProd;
        System.debug('zprod: ' + zProd);

        prp = TestDataFactory.makeProductRatePlan(zProd.Id, 'Annual Rate Plan', prod.Id);

        prpc = ZTestFactory.makeProductRatePlanCharge(prp.Id, 'One-Time', 'Per Unit Pricing');
        prpc.Unit_Quantity__c = 1;
        update prpc;

        quoteRatePlan = TestDataFactory.makeQuoteRatePlan(testQuote, quoteAmend);
    }

    @IsTest
    public static void testBehaviour(){
        prepareRemainingData();
        Test.startTest();
        Map<Id, PAC__c> pacs = PACAllocatorTest.preparePACsWithQuoteId(testQuote.Id);
        pacs.values()[0].Status__c = 'Assigned';
        update pacs.values();
        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
        quoteRatePlanCharge.zqu__Quantity__c = 1;

        update quoteRatePlanCharge;


        Test.setCurrentPage(Page.PACManagement);
        ApexPages.currentPage().getParameters().put('quoteId', testQuote.Id);
        PACManagementController ctrl = new PACManagementController();
        ctrl.unassign = true;
        ctrl.proceed();
        System.assert([SELECT Id FROM PAC__c WHERE Status__c = 'Assigned'].isEmpty());

        Set<Id> applicableProductIds = new Set<Id>();

        for(PAC_Product_Map__c applicableProduct: PACKeyAllocator.productMaps){
            applicableProductIds.add(applicableProduct.Product2__c);
        }

        System.debug(PACKeyAllocator.productMaps);

        System.debug([
                SELECT zqu__Quantity__c, Initial_Term__c, Name, zqu__ProductRatePlanCharge__c,
                        zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c,
                        Total_Unit_Quantity__c, Start_Date__c
                FROM zqu__QuoteRatePlanCharge__c
                WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :testQuote.Id
                AND zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c IN :applicableProductIds
        ]);

        ctrl = new PACManagementController();
        ctrl.allocate = true;
        ctrl.unassign = false;
        ctrl.proceed();
        System.assertEquals(1, [SELECT Id FROM PAC__c WHERE Status__c = 'Allocated'].size());
        Test.stopTest();
    }

    @IsTest
    public static void testAssign(){
        Test.startTest();
        prepareRemainingData();
        Map<Id, PAC__c> pacs = PACAllocatorTest.preparePACsWithQuoteId(testQuote.Id);
        pacs.values()[0].Status__c = 'Assigned';
        update pacs.values();
        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
        quoteRatePlanCharge.zqu__Quantity__c = 1;
        update quoteRatePlanCharge;
        Test.setCurrentPage(Page.PACManagement);
        ApexPages.currentPage().getParameters().put('quoteId', testQuote.Id);
        PACManagementController ctrl = new PACManagementController();
        ctrl.markAsAssigned = true;
        ctrl.proceed();
        Test.stopTest();
        System.assertEquals(pacs.size(), [SELECT Id FROM PAC__c WHERE Status__c = 'Assigned'].size());
    }

    @IsTest
    public static void testQueryQuotes(){
        prepareRemainingData();
        Test.setCurrentPage(Page.PACManagement);
        PACManagementController ctrl = new PACManagementController();
        ctrl.filterString = 'asdasdad';
        ctrl.queryQuotes();
        System.assertEquals(0, ctrl.quoteOptions.size());

        ctrl.filterString = testQuote.zqu__Number__c;
        ctrl.queryQuotes();
        System.assertEquals(1, ctrl.quoteOptions.size());

        ctrl.filterString = '';
        ctrl.queryQuotes();
        System.assertEquals(1, ctrl.quoteOptions.size());

    }

    @IsTest
    public static void testManualAllocate(){
        Test.startTest();
        prepareRemainingData();
        Map<Id, PAC__c> pacs = PACAllocatorTest.preparePACsWithQuoteId(testQuote.Id);
        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
        quoteRatePlanCharge.zqu__Quantity__c = 1;
        update quoteRatePlanCharge;
        Test.setCurrentPage(Page.PACManagement);
        ApexPages.currentPage().getParameters().put('quoteId', testQuote.Id);
        PACManagementController ctrl = new PACManagementController();

        ctrl.allocate = true;
        ctrl.allocateManually = true;
        pacs.values()[0].Assigned_Product2__c = prod.Id;
        update pacs.values();
        ctrl.pacToAdd = pacs.values().get(0);
        ctrl.addPacToSelectedList();

        ctrl.proceed();
        System.assertEquals(1, [SELECT Id FROM PAC__c WHERE Status__c = 'Allocated'].size());

        System.assert(ctrl.getWhereClause()!=null);
    }

}