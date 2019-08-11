@isTest

public with sharing class PACAllocatorTest {
    private static Account acc;
    private static Contact ctt;
    private static Opportunity opp;

    private static zqu__Quote__c testQuote;
    private static zqu__QuoteAmendment__c quoteAmend;
    private static zqu__ZProduct__c zProd;
    private static Product2 product;
    private static zqu__ProductRatePlan__c prp;
    private static zqu__ProductRatePlanCharge__c prpc;
    private static zqu__QuoteRatePlan__c quoteRatePlan;
    private static User u;

    @TestSetup
    static void prepare() {
        TestDataUtil.dataValueMapCSData();
    }

    public static Map<Id, PAC__c> preparePACsWithQuoteId(Id quoteId) {
        List<PAC__c> data = new List<PAC__c>();
        data.add(new PAC__c(
                Product__c = 'ABC',
                Quantity__c = 1,
                Status__c = 'Unassigned',
                Code__c = 'CNA-NXT-ABC-C-1yr -1',
                Duration__c = 1,
                Key__c = 'AAAAA-AAAAA-AAAAA-AAAAA-AAAAA'
        ));
        data.add(new PAC__c(
                Product__c = 'ABC',
                Quantity__c = 5,
                Status__c = 'Unassigned',
                Code__c = 'CNA-NXT-ABC-C-1yr -5',
                Duration__c = 1,
                Key__c = 'AAAAA-AAAAA-AAAAA-AAAAA-AAAAB'
        ));
        data.add(new PAC__c(
                Product__c = 'ABC',
                Quantity__c = 10,
                Status__c = 'Unassigned',
                Code__c = 'CNA-NXT-ABC-C-1yr -10',
                Duration__c = 1,
                Key__c = 'AAAAA-AAAAA-AAAAA-AAAAA-AAAAC'
        ));


        data.add(new PAC__c(
                Product__c = 'ABC',
                Quantity__c = 1,
                Status__c = 'Unassigned',
                Code__c = 'CNA-NXT-ABC-C-3yr -1',
                Duration__c = 3,
                Key__c = 'AAAAA-AAAAA-AAAAA-AAAAA-AAABA'
        ));
        data.add(new PAC__c(
                Product__c = 'ABC',
                Quantity__c = 5,
                Status__c = 'Unassigned',
                Code__c = 'CNA-NXT-ABC-C-3yr -1',
                Duration__c = 3,
                Key__c = 'AAAAA-AAAAA-AAAAA-AAAAA-AAABB'
        ));
        data.add(new PAC__c(
                Product__c = 'ABC',
                Quantity__c = 10,
                Status__c = 'Unassigned',
                Code__c = 'CNA-NXT-ABC-C-3yr -1',
                Duration__c = 3,
                Key__c = 'AAAAA-AAAAA-AAAAA-AAAAA-AAABC'
        ));

        data.add(new PAC__c(
                Product__c = 'DDD',
                Quantity__c = 1,
                Status__c = 'Unassigned',
                Code__c = 'CNA-NXT-DDD-C-1yr -1',
                Duration__c = 1,
                Key__c = 'AAAAA-AAAAA-AAAAA-DDDDD-AAAAA'
        ));

        if (String.isNotBlank(quoteId)) {
            for (PAC__c pac : data) {
                pac.Quote__c = quoteId;
            }
        }

        insert data;
        return new Map<Id, PAC__c>(data);
    }

    public static Map<Id, PAC__c> preparePACs() {
        return preparePACsWithQuoteId(null);
    }

    public static PAC_Product_Map__c preparePACMapWithId(Boolean shouldInsert, Id prod2Id) {
        PAC_Product_Map__c productMap = new PAC_Product_Map__c(
                PAC_Product__c = 'ABC',
                Product2__c = prod2Id,
                Active__c = true
        );

        if (shouldInsert) {
            insert productMap;
        }
        return productMap;
    }

    public static PAC_Product_Map__c preparePACMap() {
        return preparePACMapWithId(true, product.Id);
    }

    public static void prepareRemainingData() {
        u = TestUtils.createUser('testLaunchpad', TestUtils.PROFILE_SYSTEM_ADMINISTRATOR, true);
        acc = TestDataFactory.createAccount(true);
        ctt = TestDataFactory.createContact(acc.Id, true);
        opp = TestDataFactory.createOpportunity(acc.Id, true);
        testQuote = TestDataFactory.makeQuote(opp, ctt);
        quoteAmend = ZTestFactory.makeQuoteAmendment(testQuote);

        product = new Product2(Name = 'Test App Suite', zqu__SKU__c = 'SSS-12123');
        insert product;

        zProd = [SELECT Id, Name, zqu__SKU__c FROM zqu__ZProduct__c WHERE zqu__Product__c = :product.Id];
        update zProd;
        System.debug('zprod: ' + zProd);

        prp = TestDataFactory.makeProductRatePlan(zProd.Id, 'Annual Rate Plan', product.Id);

        prpc = ZTestFactory.makeProductRatePlanCharge(prp.Id, 'One-Time', 'Per Unit Pricing');
        prpc.zqu__UOM__c = 'Core';
        update prpc;

        quoteRatePlan = TestDataFactory.makeQuoteRatePlan(testQuote, quoteAmend);

        insert new PAC_Settings__c(New_Deal_Notification_Emails__c = 'test@test.com',
                PAC_Email__c = 'test@test.com');
    }

    @isTest
    public static void testSingle() {
        Test.startTest();

        prepareRemainingData();
        preparePACs();
        preparePACMap();

        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
        quoteRatePlanCharge.zqu__Quantity__c = 1;
        prpc.Unit_Quantity__c = 1;
        update prpc;

        update quoteRatePlanCharge;

        quoteRatePlanCharge = [SELECT zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c FROM zqu__QuoteRatePlanCharge__c WHERE Id = :quoteRatePlanCharge.Id];

        testQuote.GRO_Timestamp__c = Datetime.now();
        testQuote.OM_Status__c = 'Accepted';
        update testQuote;

        System.debug([SELECT Id, Product__c, Duration__c, Quantity__c, Code__c, Key__c FROM PAC__c]);
        PAC__c pac = [SELECT Id, Product__c, Duration__c, Quantity__c, Code__c, Key__c FROM PAC__c WHERE Status__c = 'Allocated'];

        System.assertNotEquals(pac, null);
        System.assertEquals(pac.Product__c, 'ABC');
        System.assertEquals(pac.Duration__c, 1);
        System.assertEquals(pac.Quantity__c, 1);
        System.assertEquals(pac.Code__c, 'CNA-NXT-ABC-C-1yr -1');
        System.assertEquals(pac.Key__c, 'AAAAA-AAAAA-AAAAA-AAAAA-AAAAA');

        Test.stopTest();
    }

    @IsTest
    public static void testMultiple() {
        Test.startTest();

        prepareRemainingData();
        preparePACs();
        preparePACMap();

        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
        prpc.Unit_Quantity__c = 1;
        update prpc;
        quoteRatePlanCharge.zqu__Quantity__c = 16;
        update quoteRatePlanCharge;

        quoteRatePlanCharge = [SELECT zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c, zqu__ProductRatePlanCharge__c FROM zqu__QuoteRatePlanCharge__c WHERE Id = :quoteRatePlanCharge.Id];

        System.debug('TEST UQ:' + [SELECT Unit_Quantity__c FROM zqu__ProductRatePlanCharge__c WHERE Id = :quoteRatePlanCharge.zqu__ProductRatePlanCharge__c]);

        testQuote.GRO_Timestamp__c = Datetime.now();
        testQuote.OM_Status__c = 'Accepted';
        update testQuote;

        List<PAC__c> pacs = [SELECT Id, Product__c, Duration__c, Quantity__c, Code__c, Key__c FROM PAC__c WHERE Status__c = 'Allocated'];

        System.assertEquals(3, pacs.size());

        Set<String> keys = new Set<String>();
        Set<Decimal> quantities = new Set<Decimal>();
        for (PAC__c pac : pacs) {
            System.assertEquals(pac.Product__c, 'ABC');
            System.assertEquals(pac.Duration__c, 1);
            System.assert(pac.Code__c.startsWith('CNA-NXT-ABC-C-1yr -'));
            keys.add(pac.Key__c);
            quantities.add(pac.Quantity__c);
        }
        //check quantities and keys


        Test.stopTest();
    }


    @IsTest
    public static void testMultipleWithMultiplier() {

        Test.startTest();

        prepareRemainingData();
        prpc.Unit_Quantity__c = 2;
        update prpc;
        preparePACs();
        preparePACMap();

        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge2 = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
        quoteRatePlanCharge.zqu__Quantity__c = 4;
        quoteRatePlanCharge2.zqu__Quantity__c = 4;
        update quoteRatePlanCharge;
        update quoteRatePlanCharge2;

        quoteRatePlanCharge = [SELECT zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c FROM zqu__QuoteRatePlanCharge__c WHERE Id = :quoteRatePlanCharge.Id];

        testQuote.GRO_Timestamp__c = Datetime.now();
        testQuote.OM_Status__c = 'Accepted';
        update testQuote;

        List<PAC__c> pacs = [SELECT Id, Product__c, Duration__c, Quantity__c, Code__c, Key__c FROM PAC__c WHERE Status__c = 'Allocated'];

        System.assertEquals(3, pacs.size());

        Set<String> keys = new Set<String>();
        Set<Decimal> quantities = new Set<Decimal>();
        for (PAC__c pac : pacs) {
            System.assertEquals(pac.Product__c, 'ABC');
            System.assertEquals(pac.Duration__c, 1);
            System.assert(pac.Code__c.startsWith('CNA-NXT-ABC-C-1yr -'));
            keys.add(pac.Key__c);
            quantities.add(pac.Quantity__c);
        }
        //check quantities and keys


        Test.stopTest();
    }

    @IsTest
    public static void testMultipleWithMultiplierSingle() {

        Test.startTest();

        prepareRemainingData();
        prpc.Unit_Quantity__c = 2;
        update prpc;
        preparePACs();
        preparePACMap();

        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
        quoteRatePlanCharge.zqu__Quantity__c = 8;
        update quoteRatePlanCharge;

        quoteRatePlanCharge = [SELECT zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c FROM zqu__QuoteRatePlanCharge__c WHERE Id = :quoteRatePlanCharge.Id];

        testQuote.GRO_Timestamp__c = Datetime.now();
        testQuote.OM_Status__c = 'Accepted';
        update testQuote;

        List<PAC__c> pacs = [SELECT Id, Product__c, Duration__c, Quantity__c, Code__c, Key__c FROM PAC__c WHERE Status__c = 'Allocated'];

        System.assertEquals(3, pacs.size());

        Set<String> keys = new Set<String>();
        Set<Decimal> quantities = new Set<Decimal>();
        for (PAC__c pac : pacs) {
            System.assertEquals(pac.Product__c, 'ABC');
            System.assertEquals(pac.Duration__c, 1);
            System.assert(pac.Code__c.startsWith('CNA-NXT-ABC-C-1yr -'));
            keys.add(pac.Key__c);
            quantities.add(pac.Quantity__c);
        }
        //check quantities and keys

        Test.stopTest();
    }



    @IsTest
    public static void testInvalid() {
        Test.startTest();

        prepareRemainingData();
        preparePACs();
        preparePACMap();

        Boolean didFail = false;

        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
        quoteRatePlanCharge.zqu__Quantity__c = 2;
        update quoteRatePlanCharge;

        testQuote.GRO_Timestamp__c = Datetime.now();
        testQuote.OM_Status__c = 'Accepted';
        try {
            update testQuote;
        } catch (Exception e) {
            didFail = true;
        }

        //System.assert(didFail);

        List<PAC__c> pacs = [SELECT Id, Key__c FROM PAC__c WHERE Status__c = 'Allocated'];
        System.assertEquals(pacs.size(), 0);

        Test.stopTest();
    }
}