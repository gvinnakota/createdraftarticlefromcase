@IsTest
private class ZuoraRevenueSplitHelper_Test {
    @TestSetup
    public static void setup(){
        Product2 prod = new Product2(Name = 'Test App Suite', zqu__SKU__c = 'SSS-12123');
        insert prod;

        zqu__ZProduct__c zProd = [SELECT Id, Name, zqu__SKU__c FROM zqu__ZProduct__c WHERE zqu__Product__c = :prod.Id];

        zqu__ProductRatePlan__c prp = TestDataFactory.makeProductRatePlan(zProd.Id, 'Annual Rate Plan', prod.Id);

        zqu__ProductRatePlanCharge__c prpc = ZTestFactory.makeProductRatePlanCharge(prp.Id, 'One-Time', 'Per Unit Pricing');
        prpc.zqu__ZuoraId__c = '2c92c0f9659e64ce0165a9dbcf5953f3';
        update prpc;

        Product_Split__c ps = new Product_Split__c(
                Product_Rate_Plan_Charge__c = prpc.Id
        );
        insert ps;

        Split__c split1 = new Split__c(
                Product_Split__c = ps.Id,
                Percentage__c = 40,
                Deferred_Revenue_Accounting_Code__c = 'DEFERRED REVENUE - SUBSCRIPTION',
                Deferred_Revenue_Accounting_Code_Type__c = 'Deferred Revenue',
                Recognized_Revenue_Accounting_Code__c = 'REVENUE - SUBSCRIPTION',
                Recognized_Revenue_Accounting_Code_Type__c = 'Sales Revenue',
                Recognition_Rule__c = 'Recognize revenue in period of start date'
        );

        Split__c split2 = new Split__c(
                Product_Split__c = ps.Id,
                Percentage__c = 60,
                Deferred_Revenue_Accounting_Code__c = 'DEFERRED REVENUE - SUBSCRIPTION',
                Deferred_Revenue_Accounting_Code_Type__c = 'Deferred Revenue',
                Recognized_Revenue_Accounting_Code__c = 'REVENUE - SUBSCRIPTION',
                Recognized_Revenue_Accounting_Code_Type__c = 'Sales Revenue',
                Recognition_Rule__c = 'Recognize revenue over subscription start to end date'
        );

        insert new List<Split__c>{split1, split2};

        ps.Active__c = true;
        update ps;
    }

    public static testMethod void testValidScheduledSubs(){
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
                'callout:Zuora_REST_Api/v1/orders?dateFilterOption=updatedDate&startDate='
                + String.valueOf(Date.today()).substringBeforeLast(' ')
                + '&endDate='
                + String.valueOf(Date.today().addDays(1)).substringBeforeLast(' ')
                , 'OrdersResponse'
        );

        mock.setStaticResource('callout:Zuora_REST_Api/v1/accounting-periods', 'AccountingPeriodsResponse');

        mock.setStaticResource('callout:Zuora_REST_Api/v1/subscriptions/A-S00004514', 'SubscriptionResponse');

        mock.setStaticResource('callout:Zuora_REST_Api/v1/object/rate-plan-charge/2c92c0f967a5766a0167ba944ff2609d', 'ChargeResponse');

        mock.setStaticResource(
                'callout:Zuora_REST_Api/v1/charge-revenue-summaries/subscription-charges/2c92c0f967a5766a0167ba944ff2609d',
                'ChargeSummaryResponse'
        );

        mock.setStaticResource('callout:Zuora_REST_Api/v1/revenue-schedules/subscription-charges/2c92c0f967a5766a0167ba944ff2609d', 'RevenueScheduleResponse');

        mock.setStaticResource('callout:Zuora_REST_Api/v1/revenue-schedules/420/distribute-revenue-with-date-range', 'TermDistributionResponse');

        mock.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, mock);



        new ZuoraRevenueSplitHelper().execute(null);
    }

    public static testMethod void testInvalidOrdersResponse(){
        Revenue_Splits_Settings__c settings = new Revenue_Splits_Settings__c(
                Failure_Warning_Message__c = 'Failure',
                Unsupported_Action_Warning_Message__c = 'Unsupported',
                Warning_Emails_c__c = 'test@email.com',
                SetupOwnerId=UserInfo.getOrganizationId()
        );
        insert settings;

        MultiStaticResourceCalloutMock mock = new MultiStaticResourceCalloutMock();
        mock.setStaticResource('callout:Zuora_REST_Api/oauth/token', 'TokenResponse');

        Test.setMock(HttpCalloutMock.class, mock);

        new ZuoraRevenueSplitHelper().execute(null);
    }

    public static testMethod void testVars(){
        ZuoraRevenueSplitHelper.isSandbox = true;
        System.assertEquals('https://apisandbox.zuora.com/', ZuoraRevenueSplitHelper.getZuoraBaseUrl(ZuoraRevenueSplitHelper.isSandbox));
        ZuoraRevenueSplitHelper.isSandbox = false;
        System.assertEquals('https://www.zuora.com/', ZuoraRevenueSplitHelper.getZuoraBaseUrl(ZuoraRevenueSplitHelper.isSandbox));
    }

    private class TestResponse extends Response{}

    public static testMethod void testErrorChecking(){
        Response.Reason rs = new Response.Reason();
        rs.message = 'Reason Message';
        rs.code = 43654562;

        TestResponse r = new TestResponse();
        r.reasons = new List<Response.Reason>{
                rs
        };
        r.success = false;

        ZuoraRevenueSplitHelper.checkSuccess(r, 'Test Error');
    }

    public static testMethod void testAutomationDate(){
        insert new Revenue_Splits_Settings__c(Automation_Start_Date__c = Date.today().addDays(3));
        try{
            insert new Revenue_Splits_Request__c(Start_Date__c = Date.today(), End_Date__c = Date.today(), Type__c = 'Manual');
        }catch (Exception e){}
    }
}