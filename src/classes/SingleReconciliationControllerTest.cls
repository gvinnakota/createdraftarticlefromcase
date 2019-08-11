/**
 * Created on 14/03/2019.
 */
@IsTest
public with sharing class SingleReconciliationControllerTest {

    @IsTest
    public static void testBehaviour(){
        TestDataUtil.dataValueMapCSData();
        Account a = TestDataFactory.createAccount(true);

        Opportunity opp = TestDataFactory.createOpportunity(a.Id, false);
        opp.Core_Order_Processed__c = 'Test';
        insert opp;

        Contact c = TestDataFactory.createContact(a.Id, true);

        zqu__Quote__c q = TestDataFactory.makeQuote(opp, c);
        zqu__Quote__c q2 = TestDataFactory.makeQuote(opp, c);
        q.Split_Parent_Quote__c = q2.Id;
        update q;
        q = [SELECT Id, zqu__Number__c FROM zqu__Quote__c WHERE Id = :q.Id];

        zqu__QuoteAmendment__c qa = new zqu__QuoteAmendment__c(zqu__Quote__c = q.Id);
        insert qa;

        zqu__QuoteRatePlan__c qrp = TestDataFactory.makeQuoteRatePlan(q, qa);

        Product2 prod = TestDataFactory.createProduct2(true);
        zqu__ZProduct__c zprod = TestDataFactory.makeProduct('Test', 'SKU');

        zqu__ProductRatePlan__c prp = TestDataFactory.makeProductRatePlan(zprod.Id, 'TestName', prod.Id);
        prp.zqu__ZuoraId__c = '2c92a0ff5b14d5ce015b160a505d3a27';
        update prp;

        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.makeProductRatePlanCharge(prp.Id, 'asd', 'NotRecurring');

        zqu__QuoteRatePlanCharge__c qrpc = new zqu__QuoteRatePlanCharge__c();
        qrpc.zqu__QuoteRatePlan__c = qrp.Id;
        qrpc.zqu__ProductRatePlanCharge__c = prpc.Id;
        qrpc.Product_Rate_Plan__c = prp.Id;
        qrpc.zqu__PreviewedTCV__c = 1;
        qrpc.zqu__MRR__c = 1;
        qrpc.MRR_USD__c = '1';
        qrpc.Product_Rate_Plan_ZuoraID__c = '2c92a0ff5b14d5ce015b160a505d3a27';
        qrpc.zqu__UOM__c = 'ASD';
        qrpc.End_Date__c = String.valueOf(Date.today().addYears(1));
        insert qrpc;

        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:__Zuora_REST_Api/v1/subscriptions/8a80830366f1a30e0168e3425225427c', 'SubscriptionResponse');
        mock.setStaticResource('callout:__Zuora_REST_Api/v1/batch-query/jobs/8a80830366f1a30e0168ec84fe7b438c', 'BatchQueryResponse');
        mock.setStaticResource('callout:__Zuora_REST_Api/v1/file/8a8082e866f1a3480168ec84ff374ede', 'AquaFileResponse');
        mock.setStaticResource('callout:__Zuora_REST_Api/v1/operations/billing-preview', 'BillingPreviewResponse');
        mock.setStaticResource('callout:__Zuora_REST_Api/oauth/token', 'TokenResponse');
        mock.setStaticResource('callout:__Zuora_REST_Api/v1/batch-query/', 'BatchQueryFailResponse');
        mock.setHeader('Content-Type', 'application/json');
        mock.setStatus('OK');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        Test.setCurrentPage(Page.SingleReconciliation);
        ApexPages.currentPage().getParameters().put('id', q.Id);
        Test.startTest();
        SingleReconciliationController ctrl = new SingleReconciliationController();
        ctrl.testQuoteId = q.Id;
        ctrl.testQuoteNumber = q.zqu__Number__c;
        Object result = ctrl.querySubscriptions();
        System.assertEquals(null, result);

        System.assertNotEquals(null, ctrl.rppByQuotes.get(q.zqu__Number__c).get(0).charges);
        Test.stopTest();




    }





}