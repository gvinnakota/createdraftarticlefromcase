/**
 * Created by jwilkosz on 17/12/2018.
 */
@IsTest
public with sharing class ZuoraRevenueSplitsManagementCtrl_Test {
    @IsTest
    public static void testCtrl(){
        Revenue_Splits_Settings__c settings = new Revenue_Splits_Settings__c(
                Failure_Warning_Message__c = 'Failure',
                Unsupported_Action_Warning_Message__c = 'Unsupported',
                Warning_Emails_c__c = 'test@email.com',
                SetupOwnerId=UserInfo.getOrganizationId()
        );
        insert settings;

        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:Zuora_REST_Api/oauth/token', 'TokenResponse');

        mock.setStaticResource(
            'callout:Zuora_REST_Api/v1/orders?pageSize=1&startDate='
                + String.valueOf(Date.today().addDays(-1)).substringBeforeLast(' ')
                + '&endDate='
                + String.valueOf(Date.today()).substringBeforeLast(' ')
            , 'OrdersResponse'
        );

        mock.setStaticResource('callout:Zuora_REST_Api/v1/accounting-periods', 'AccountingPeriodsResponse');

        mock.setStaticResource('callout:Zuora_REST_Api/v1/subscriptions/A-S00004514', 'SubscriptionResponse');


        mock.setStaticResource(
            'callout:Zuora_REST_Api/v1/charge-revenue-summaries/subscription-charges/2c92c0f967a5766a0167ba944ff2609d',
            'ChargeSummaryResponse'
        );

        mock.setStaticResource('callout:Zuora_REST_Api/v1/revenue-schedules/subscription-charges/2c92c0f967a5766a0167ba944ff2609d', 'RevenueScheduleResponse');

        mock.setStaticResource('callout:Zuora_REST_Api/v1/revenue-schedules/420/distribute-revenue-with-date-range', 'TermDistributionResponse');

        mock.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, mock);

        Test.setCurrentPage(Page.ZuoraRevenueSplitsManagement);
        ApexPages.currentPage().getParameters().put('id', 'randomid');
        ZuoraRevenueSplitsManagementController ctrl = new ZuoraRevenueSplitsManagementController();
        ctrl.cronJobName = 'Test Name 123213';
        ApexPages.currentPage().getParameters().remove('id');
        ctrl.schedule();
        ctrl = new ZuoraRevenueSplitsManagementController();
        ctrl.cronJobName = 'Test Name 123213';
        ctrl.cancel();
        ctrl.runManually();
    }
}