@IsTest
global class FinanceCollectionHelperCalloutMockImpl implements HttpCalloutMock {

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        res.setBody(getSerializedObjectByEndpoint(req.getEndpoint()));

        return res;
    }

    public static String getSerializedObjectByEndpoint(String endpoint) {
        Object response;

        if (endpoint.contains('oauth/token')) {
            ZuoraRevenueSplitHelper.TokenResponse tokenResponse = new ZuoraRevenueSplitHelper.TokenResponse();
            tokenResponse.access_token = 'access_token';
            response = tokenResponse;
        } else if (endpoint.contains('object/invoice')) {
            //FinanceCollectionHelper.ZuoraGetInvoiceResp resp = new FinanceCollectionHelper.ZuoraGetInvoiceResp();
            //resp.Body = 'body';
            //response = resp;
            return '{"Body":"body"}';
        } else if (endpoint.contains('subscriptions')) {
            ZuoraRevenueSplitHelper.SubscriptionResponse resp = new ZuoraRevenueSplitHelper.SubscriptionResponse();
            resp.termStartDate = '2018-05-19';
            resp.termEndDate = '2018-09-05';

            ZuoraRevenueSplitHelper.RatePlanCharge rpc = new ZuoraRevenueSplitHelper.RatePlanCharge();
            rpc.name = 'ratePlanName';
            rpc.tcv = 100;
            rpc.effectiveStartDate = '2018-05-19';
            rpc.effectiveEndDate = '2018-05-19';

            ZuoraRevenueSplitHelper.RatePlan ratePlan = new ZuoraRevenueSplitHelper.RatePlan();
            ratePlan.ratePlanName = 'ratePlanName';
            ratePlan.ratePlanCharges = new List<ZuoraRevenueSplitHelper.RatePlanCharge>{
                    rpc
            };

            resp.ratePlans = new List<ZuoraRevenueSplitHelper.RatePlan>{
                    ratePlan
            };

            response = resp;
        } else if (endpoint.contains('accounting-periods')) {
            ZuoraRevenueSplitHelper.AccountingPeriodsResponse resp = new ZuoraRevenueSplitHelper.AccountingPeriodsResponse();
            resp.accountingPeriods = new List<ZuoraRevenueSplitHelper.AccountingPeriod>{
                    new ZuoraRevenueSplitHelper.AccountingPeriod()
            };
            resp.accountingPeriods.get(0).startDate = Date.newInstance(2018, 05, 20);
            resp.accountingPeriods.get(0).endDate = Date.newInstance(2018, 09, 4);
            resp.success = true;
            response = resp;
        } else if (endpoint.contains('amendments')) {
            ZuoraRevenueSplitHelper.AmendmentResponse resp = new ZuoraRevenueSplitHelper.AmendmentResponse();
            resp.success = true;
            response = resp;
        } else if (endpoint.contains('revenue-schedules/subscription-charges')) {
            ZuoraRevenueSplitHelper.AmendmentRevenueScheduleResponse resp = new ZuoraRevenueSplitHelper.AmendmentRevenueScheduleResponse();
            resp.success = true;
            response = resp;
        } else if (endpoint.contains('charge-revenue-summaries/subscription-charges')) {
            ZuoraRevenueSplitHelper.ChargeSummaryResponse resp = new ZuoraRevenueSplitHelper.ChargeSummaryResponse();
            resp.success = true;
            response = resp;
        }

        return JSON.serialize(response);
    }
}