/**
 * Created on 15/03/2019.
 */
@IsTest
public with sharing class ReconciliationControllerTest {

    @IsTest
    static void testBehaviour(){
        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:__Zuora_REST_Api/v1/subscriptions/8a80830366f1a30e0168e3425225427c', 'SubscriptionResponse');
        mock.setStaticResource('callout:__Zuora_REST_Api/v1/batch-query/jobs/8a80830366f1a30e0168ec84fe7b438c', 'BatchQueryResponse');
        mock.setStaticResource('callout:__Zuora_REST_Api/v1/file/8a8082e866f1a3480168ec84ff374ede', 'AquaFileResponse');
        mock.setStaticResource('callout:__Zuora_REST_Api/oauth/token', 'TokenResponse');
        mock.setStaticResource('callout:__Zuora_REST_Api/v1/batch-query/', 'BatchQueryFailResponse');
        mock.setHeader('Content-Type', 'application/json');
        mock.setStatus('OK');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        Test.setCurrentPage(Page.ReconciliationPage);
        ReconciliationController ctrl = new ReconciliationController();

        Test.startTest();
        Object result = ctrl.loadRecent();
        System.assertEquals(null, result);

    }

}