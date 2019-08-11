/**
 * Created by klukawski on 9/26/18.
 */

@IsTest
public with sharing class PACEmailTableControllerTest {
    
    public static testMethod void initController(){
        TestDataUtil.dataValueMapCSData();

        Account acc = TestDataFactory.createAccount(true);
        Contact ctt = TestDataFactory.createContact(acc.Id, true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);
        zqu__Quote__c testQuote = TestDataFactory.makeQuote(opp, ctt);
        zqu__QuoteAmendment__c quoteAmend = ZTestFactory.makeQuoteAmendment(testQuote);

        Product2 product = new Product2(Name = 'Test App Suite', zqu__SKU__c = 'SSS-12123');
        insert product;

        zqu__ZProduct__c zProd = [SELECT Id, Name, zqu__SKU__c FROM zqu__ZProduct__c WHERE zqu__Product__c = :product.Id];
        update zProd;
        System.debug('zprod: ' + zProd);

        zqu__ProductRatePlan__c prp = TestDataFactory.makeProductRatePlan(zProd.Id, 'Annual Rate Plan', product.Id);

        zqu__ProductRatePlanCharge__c prpc = ZTestFactory.makeProductRatePlanCharge(prp.Id, 'One-Time', 'Per Unit Pricing');
        prpc.Unit_Quantity__c = 1;
        update prpc;

        zqu__QuoteRatePlan__c quoteRatePlan = TestDataFactory.makeQuoteRatePlan(testQuote, quoteAmend);

        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
        quoteRatePlanCharge.zqu__Quantity__c = 1;
        quoteRatePlanCharge.Initial_Term__c = 12;
        update quoteRatePlanCharge;
        quoteRatePlanCharge = [
            SELECT Id, Total_Unit_Quantity__c, Start_Date__c,
                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c,
                Initial_Term__c
            FROM zqu__QuoteRatePlanCharge__c
            WHERE Id = :quoteRatePlanCharge.Id
        ];
        System.debug('TUQ' + [SELECT Total_Unit_Quantity__c FROM zqu__QuoteRatePlanCharge__c WHERE Id = :quoteRatePlanCharge.Id].Total_Unit_Quantity__c);

        insert new PAC_Product_Map__c(
                PAC_Product__c = 'PKS',
                Product2__c = product.Id,
                Active__c = true
        );

        insert new PAC__c(
                Code__c = 'CNA-NXT-PKS-C-1yr -1',
                Key__c =  '550A3-4ZJ3K-Z8RU1-A02H7-9RZHH',
                Product__c = 'PKS',
                Quantity__c = 1,
                Duration__c = 1
        );

        testQuote.GRO_Timestamp__c = Datetime.now();
        testQuote.OM_Status__c = 'Accepted';
        update testQuote;

        System.debug('PACS:' + new PACKeyAllocator().allocatePACKeys(testQuote, new List<zqu__QuoteRatePlanCharge__c>{quoteRatePlanCharge}));

        PACEmailTableController ctrl = new PACEmailTableController();
        ctrl.quoteId = testQuote.Id;

        System.debug([SELECT Status__c FROM PAC__c LIMIT 1].Status__c);
        //System.debug([SELECT Status__c FROM PAC__c WHERE Quote__c = :testQuote.Id LIMIT 1].Status__c);

        System.assert(ctrl.renderPACs);
    }

}