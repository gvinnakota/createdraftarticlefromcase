/**
 * Created by klukawski on 10/4/18.
 */
@IsTest
public with sharing class PACEmailUtilTest {
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
        u = TestUtils.createUser('testLaunchpad', TestUtils.PROFILE_SYSTEM_ADMINISTRATOR, true);
        acc = TestDataFactory.createAccount(true);
        ctt = TestDataFactory.createContact(acc.Id, true);
        opp = TestDataFactory.createOpportunity(acc.Id, true);
        testQuote = TestDataFactory.makeQuote(opp, ctt);
        quoteAmend = ZTestFactory.makeQuoteAmendment(testQuote);

        prod = new Product2(Name = 'Test App Suite', zqu__SKU__c = 'SSS-12123');
        insert prod;

        zqu__ZProduct__c zProd = [SELECT Id, Name, zqu__SKU__c FROM zqu__ZProduct__c WHERE zqu__Product__c = :prod.Id];
        update zProd;
        System.debug('zprod: ' + zProd);

        prp = TestDataFactory.makeProductRatePlan(zProd.Id, 'Annual Rate Plan', prod.Id);

        prpc = ZTestFactory.makeProductRatePlanCharge(prp.Id, 'One-Time', 'Per Unit Pricing');
        prpc.Unit_Quantity__c = 1;
        update prpc;

        quoteRatePlan = TestDataFactory.makeQuoteRatePlan(testQuote, quoteAmend);
    }

    public static PAC_Product_Map__c preparePACMap() {
        return PACAllocatorTest.preparePACMapWithId(true, prod.Id);
    }

    public static testMethod void testEmailUtil(){
        Test.startTest();
        prepareRemainingData();
        Map<Id, PAC__c> pacs = PACAllocatorTest.preparePACsWithQuoteId(testQuote.Id);
        preparePACMap();
        pacs.values()[0].Status__c = 'Assigned';
        update pacs.values();
        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
        quoteRatePlanCharge.zqu__Quantity__c = 1;

        update quoteRatePlanCharge;

        insert new PAC_Settings__c(New_Deal_Notification_Emails__c = 'test@test.com',
        PAC_Email__c = 'test@test.com');

        PACEmailUtil.sendNewDealEmail(testQuote.Id);
        PACEmailUtil.sendPACNotificationEmail(testQuote.Id);
    }
}