/**
 * Created by klukawski on 2/1/18.
 */

public with sharing class ZuoraRevenueSplitHelper implements Schedulable{
    private static Pattern decimalTrimPattern = Pattern.compile('(?:\\d*\\.(\\d\\d)\\d{7})');
    private static final Integer ACCOUNTING_PERIODS_ERROR_CODE = 55600030;

    @TestVisible
    public static Boolean isSandbox {
        get{
            if(isSandbox == null){
                isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            }
            return isSandbox;
        }
        set;
    }

    @TestVisible
    public static String getZuoraBaseUrl(Boolean sandbox){
        if(sandbox){
            return 'https://apisandbox.zuora.com/';
        }
        return 'https://www.zuora.com/';
    }

    public static String processInvalidResponse(String response) {
        String jsonString = response.replace('number', 'number_field')
                .replace('currency', 'currency_field')
                .replace('Start_Date__c', 'startDate')
                .replace('End_Date__c', 'endDate')
                .replace('QuoteNumber__QT', 'QuoteNumber')
                .replace('QuoteBusinessType__QT', 'QuoteBusinessType')
                .replace('OpportunityCloseDate__QT', 'OpportunityCloseDate')
                .replace('OpportunityName__QT', 'OpportunityName')
                .replace('CpqBundleJsonId__QT', 'CpqBundleJsonId')
                .replace('QuoteType__QT', 'QuoteType')
                .replace('ChargeReferenceId__c', 'ChargeReferenceId');

        Matcher m = decimalTrimPattern.matcher(jsonString);
        while (m.find() && m.groupCount() == 3) {
            System.debug(m.group(1));
            System.debug(m.group(2));
            jsonString = m.replaceFirst(m.group(1) + '.' + m.group(2));
            m = decimalTrimPattern.matcher(jsonString);
        }
        return jsonString;
    }

    public class TokenRequest extends Request{
        public TokenRequest(){
            super('callout:Zuora_REST_Api/oauth/token', 'POST', TokenResponse.class);
        }
    }

    public class TokenResponse extends Response{
        public String access_token;
    }

    public class OrdersRequest extends Request{
        public OrdersRequest(){
            super('callout:Zuora_REST_Api/v1/orders', 'GET', OrdersResponse.class);
        }

        public override String processResponse(String response){
            return processInvalidResponse(response);
        }
    }

    public class OrdersResponse extends Response {
        public List<Order> orders;
        public String nextPage;
    }

    public class Order{
        public String status;
        public String orderNumber;
        List<Subscription> subscriptions;
    }

    public class Subscription{
        List<OrderAction> orderActions;
        public String subscriptionNumber;
    }

    public class OrderAction{
        public String type;
        public List<OrderMetrics> orderMetrics;
        public List<OrderItem> orderItems;
        public UpdateProduct updateProduct;
        //public CreateSubscription createSubscription;
    }

    public class UpdateProduct{
        public List<ChargeUpdates> chargeUpdates;
    }

    /*public class CreateSubscription {
    }*/

    public class ChargeUpdates {
        public String newRatePlanChargeId;
    }

    public class OrderItem {
        public String id;
        public String scId;
    }

    public class OrderMetrics{
        public List<TCV> tcv;
        public String productRatePlanChargeId;
    }

    public class TCV{
        public Decimal amount;
        public String startDate;
        public String endDate;
        public String orderItemId;
    }

    public class ChargeRequest extends Request{
        public ChargeRequest(){
            super('callout:Zuora_REST_Api/v1/object/rate-plan-charge/', 'GET', ChargeResponse.class);
        }

        public override String processResponse(String response){
            return processInvalidResponse(response);
        }
    }

    public class ChargeResponse extends Response {
        public String startDate;
        public String endDate;
        public String ChargeNumber;
    }

    public static String getOrdersRequestBody(OrdersResponse resp, Date startDate, Date endDate){
        if(resp != null && resp.nextPage != null){
            return '?' + resp.nextPage.substringAfterLast('?');
        }
        return '?dateFilterOption=updatedDate&startDate=' + String.valueOf(startDate).substringBeforeLast(' ') + '&endDate=' + String.valueOf(endDate.addDays(1)).substringBeforeLast(' ');
    }

    public class RevenueScheduleRequest extends Request{
        private transient Decimal remainder;

        public String amount;
        public String ChargeReferenceId;
        public String deferredRevenueAccountingCode;
        public String deferredRevenueAccountingCodeType;
        public String overrideChargeAccountingCodes;
        public String recognizedRevenueAccountingCode;
        public String recognizedRevenueAccountingCodeType;
        public List<RevenueDistribution> revenueDistributions;
        public RevenueEvent revenueEvent;
        public String revenueScheduleDate;

        public RevenueScheduleRequest(Decimal tcv, String effectiveStartDate, String chargeId, Split__c split, AccountingPeriodsResponse accPeriods, Decimal lastRemainder) {
            super('callout:Zuora_REST_Api/v1/revenue-schedules/subscription-charges/', 'POST', RevenueScheduleResponse.class);
            Decimal splitAmount = (tcv * split.Percentage__c) + lastRemainder;
            Decimal roundedAmount = splitAmount.round(System.RoundingMode.HALF_DOWN);
            amount = String.valueOf(roundedAmount / 100.00);
            remainder = splitAmount - roundedAmount;
            ChargeReferenceId = chargeId;
            overrideChargeAccountingCodes = 'true';
            deferredRevenueAccountingCode = split.Deferred_Revenue_Accounting_Code__c;
            deferredRevenueAccountingCodeType = split.Deferred_Revenue_Accounting_Code_Type__c;
            recognizedRevenueAccountingCode = split.Recognized_Revenue_Accounting_Code__c;
            recognizedRevenueAccountingCodeType = split.Recognized_Revenue_Accounting_Code_Type__c;
            List<String> startDateArray = effectiveStartDate.split('-');
            Date startDate = Date.newInstance(Integer.valueOf(startDateArray[0]), Integer.valueOf(startDateArray[1]),
                    Integer.valueOf(startDateArray[2]));
            revenueScheduleDate = effectiveStartDate;
            revenueDistributions = new List<RevenueDistribution>();
            RevenueDistribution rd = new RevenueDistribution();
            rd.newAmount = amount;
            AccountingPeriod p = null;
            for (AccountingPeriod ap : accPeriods.accountingPeriods) {
                if (ap.startDate <= startDate && ap.endDate >= startDate) {
                    p = ap;
                    break;
                }
            }
            if (p == null) {
                System.debug('No Accounting Period found for Revenue Distribution: ' + startDate);
            } else {
                rd.accountingPeriodName = p.name;
            }
            revenueDistributions.add(rd);
            RevenueEvent ev = new RevenueEvent();
            ev.eventType = 'Revenue Distributed';
            ev.eventTypeSystemId = 'RevenueDistributed__z';
            ev.notes = '';
            this.revenueEvent = ev;
        }

        private String getBody() {
            return JSON.serialize(this).replace('ChargeReferenceId', 'ChargeReferenceId__c');
        }

        public Decimal getRemainder() {
            return remainder;
        }
    }

    public class RevenueScheduleResponse extends Response{
        public Boolean success;
        public String revenueScheduleNumber;
    }

    public class RevenueDistribution {
        public String accountingPeriodName;
        public String newAmount;
    }

    public class RevenueEvent {
        public String eventType;
        public String eventTypeSystemId;
        public String notes;
    }

    public class AccountingPeriodsRequest extends Request{
        public AccountingPeriodsRequest(){
            super('callout:Zuora_REST_Api/v1/accounting-periods', 'GET', AccountingPeriodsResponse.class);
        }
    }

    public class AccountingPeriodsResponse extends Response{
        public List<AccountingPeriod> accountingPeriods;
    }

    public class AccountingPeriod {
        public String id;
        public String name;
        public Date startDate;
        public Date endDate;
        public String status;
    }

    public class TermDistributionRequest extends Request{
        public String distributionType;
        public String eventType;
        public String eventTypeSystemId;
        public String recognitionStart;
        public String recognitionEnd;

        public TermDistributionRequest(String startDate, String endDate) {
            super('callout:Zuora_REST_Api/v1/revenue-schedules/', 'PUT', TermDistributionResponse.class);
            distributionType = 'Daily Distribution';
            eventType = 'Revenue Distributed';
            eventTypeSystemId = 'RevenueDistributed__z';
            recognitionStart = startDate;
            recognitionEnd = endDate;
        }

        private String getBody() {
            return JSON.serialize(this);
        }
    }

    public class TermDistributionResponse extends Response{}

    public class ChargeSummaryRequest extends Request{
        public ChargeSummaryRequest(){
            super('callout:Zuora_REST_Api/v1/charge-revenue-summaries/subscription-charges/', 'GET', ChargeSummaryResponse.class);
        }

        public override String processResponse(String resp){
            return processInvalidResponse(resp);
        }
    }

    public class ChargeSummaryResponse extends Response{
        public String number_field;
        public String accountId;
    }

    public class AllRevenueSchedulesRequest extends Request{
        public AllRevenueSchedulesRequest(){
            super('callout:Zuora_REST_Api/v1/revenue-schedules/subscription-charges/', 'GET', AllRevenueSchedulesResponse.class);
        }

        public override String processResponse(String resp){
            return processInvalidResponse(resp);
        }
    }

    public class AllRevenueSchedulesResponse extends Response{
        public List<RevenueScheduleDetail> revenueSchedules;
    }

    public class RevenueScheduleDetail {
        public String ChargeReferenceId;
    }

    private static String lastChargeNumber;
    private static Set<String> chargesFailedOnClosedPeriods = new Set<String>();

    @future(callout=true)
    public static void sendCallouts(Set<Id> revSplitRequests) {
        List<Revenue_Splits_Request__c> requests = [
                SELECT Start_Date__c, End_Date__c, Status__c
                FROM Revenue_Splits_Request__c
                WHERE Id IN :revSplitRequests
        ];

        Revenue_Splits_Settings__c settings = Revenue_Splits_Settings__c.getOrgDefaults();

        TokenResponse sessionToken = (TokenResponse) new TokenRequest().sendRequest(
                new Map<String, String>{'Content-Type' => 'application/x-www-form-urlencoded'},
                'client_id={!$Credential.UserName}&client_secret={!$Credential.Password}&grant_type=client_credentials',
                ''
        );

        List<Product_Split_History__c> histories = new List<Product_Split_History__c>();

        List<Revenue_Splits_Request__c> requestsToUpdate = new List<Revenue_Splits_Request__c>();

        List<Split__c> splits = [
                SELECT Deferred_Revenue_Accounting_Code__c,
                    Deferred_Revenue_Accounting_Code_Type__c,
                    Recognized_Revenue_Accounting_Code__c,
                    Recognized_Revenue_Accounting_Code_Type__c,
                    Recognition_Rule__c, Percentage__c, Product_Split__r.Product_Rate_Plan_Charge__r.zqu__ZuoraId__c
                FROM Split__c
                WHERE Product_Split__r.Active__c = TRUE
        ];

        Set<String> splitZuoraIds = new Set<String>();
        for(Split__c split: splits){
            splitZuoraIds.add(split.Product_Split__r.Product_Rate_Plan_Charge__r.zqu__ZuoraId__c);
        }

        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        for(Revenue_Splits_Request__c request: requests){
            Set<String> orderNumbersToSend = new Set<String>();
            Messaging.SingleEmailMessage message;
            try {
                OrdersResponse orders;

                List<OrderAction> newSubscriptions = new List<OrderAction>();
                List<OrderAction> updateProducts = new List<OrderAction>();
                List<OrderAction> renewSubscriptions = new List<OrderAction>();
                List<OrderAction> addProducts = new List<OrderAction>();

                do{
                    orders = (OrdersResponse) new OrdersRequest().sendRequest(
                            new Map<String, String>{'Authorization' => 'Bearer ' + sessionToken.access_token},
                            null,
                            ZuoraRevenueSplitHelper.getOrdersRequestBody(
                                    orders,
                                    request.Start_Date__c,
                                    request.End_Date__c
                            )
                    );

                    if(!orders.success){
                        System.debug(orders.reasons);
                        break;
                    }

                    for(Order order: orders.orders){
                        for(Subscription subscription: order.subscriptions){
                            for(OrderAction action: subscription.orderActions){
                                if(action.type == 'CreateSubscription'){
                                    newSubscriptions.add(action);
                                } else if(action.type == 'UpdateProduct'){
                                    updateProducts.add(action);
                                } else if(action.type == 'RenewSubscription'){
                                    renewSubscriptions.add(action);
                                } else if(action.type == 'AddProduct'){
                                    addProducts.add(action);
                                } else {
                                    for(OrderMetrics metrics: action.orderMetrics){
                                        if(splitZuoraIds.contains(metrics.productRatePlanChargeId)){
                                            orderNumbersToSend.add(order.orderNumber);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }while(orders != null && orders.nextPage != null && orders.nextPage != '');

                AccountingPeriodsResponse accountingPeriodsResponse = (AccountingPeriodsResponse) new AccountingPeriodsRequest().sendRequest(
                        new Map<String, String>{'Authorization' => 'Bearer ' + sessionToken.access_token},
                        null,
                        ''
                );

                histories.addAll(processOrderActions(newSubscriptions, 'New Subscription', sessionToken, accountingPeriodsResponse, splits, request.Id));
                histories.addAll(processOrderActions(updateProducts, 'Amendment', sessionToken, accountingPeriodsResponse, splits, request.Id));
                histories.addAll(processOrderActions(renewSubscriptions, 'Renewal', sessionToken, accountingPeriodsResponse, splits, request.Id));
                histories.addAll(processOrderActions(addProducts, 'Add Product', sessionToken, accountingPeriodsResponse, splits, request.Id));

                request.Status__c = 'Succeeded';
                requestsToUpdate.add(request);


                if(!orderNumbersToSend.isEmpty()){
                    message = new Messaging.SingleEmailMessage();
                    message.subject = 'Revenue Splits automation encountered an unsupported order actions';
                    message.senderDisplayName = 'Revenue Splits Automation';
                    message.toAddresses = settings.Warning_Emails_c__c.split(',');
                    message.plainTextBody = settings.Unsupported_Action_Warning_Message__c + String.join(new List<String>(orderNumbersToSend), ', ');
                }

                if (!chargesFailedOnClosedPeriods.isEmpty()){
                    Messaging.SingleEmailMessage message2 = new Messaging.SingleEmailMessage();
                    message2.subject = 'Revenue Splits automation encountered charges overlapping a closed accounting period';
                    message2.senderDisplayName = 'Revenue Splits Automation';
                    message2.toAddresses = settings.Warning_Emails_c__c.split(',');
                    message2.plainTextBody = 'Those charges were overlapping closed accounting periods, so the revenue schedules were not created for them:' + String.join(new List<String>(chargesFailedOnClosedPeriods), ', ');
                    messages.add(message2);
                }
            }catch (Exception e){
                System.debug('EXCEPTION!!!:');
                request.Status__c = 'Failed';
                request.Error_Message__c = e.getMessage() + '\n' + e.getStackTraceString() + '\n' + e.getTypeName();
                Exception cause = e.getCause();
                if(cause != null){
                    request.Error_Message__c += '\nCause:\n' + cause.getMessage() + '\n' + cause.getStackTraceString() + '\n' + cause.getTypeName();
                }
                requestsToUpdate.add(request);
                message = new Messaging.SingleEmailMessage();
                message.subject = 'Revenue Splits automation failed to process a request';
                message.senderDisplayName = 'Revenue Splits Automation';
                message.toAddresses = settings.Warning_Emails_c__c.split(',');
                message.plainTextBody = settings.Failure_Warning_Message__c + request.Name;
                if(lastChargeNumber != null){
                    message.plainTextBody += '\nThe last processed charge was ' + lastChargeNumber;
                }
            }
            if(message != null){
                messages.add(message);
            }
        }

        if(messages.size()>0){
            Messaging.reserveSingleEmailCapacity(messages.size());
            Messaging.sendEmail(messages);
        }

        insert histories;
        update requestsToUpdate;
    }
    
    public static List<Product_Split_History__c> processOrderActions(List<OrderAction> actions, String type,
            TokenResponse sessionToken, AccountingPeriodsResponse accountingPeriodsResponse, List<Split__c> splits,
            Id revenueSplitRequestId){
        List<Product_Split_History__c> histories = new List<Product_Split_History__c>();

        for(OrderAction action: actions){
            for(OrderMetrics metrics: action.orderMetrics){
                if(metrics.tcv == null){
                    continue;
                }
                for(TCV tcv: metrics.tcv){
                    String rpcId;

                    if(type == 'New Subscription' || type == 'Renewal' || type == 'Add Product'){
                        for(OrderItem orderItem: action.orderItems){
                            if(orderItem.id == tcv.orderItemId){
                                rpcId = orderItem.scId;
                            }
                        }
                    } else if(type == 'Amendment') {
                        rpcId = action.updateProduct.chargeUpdates.get(0).newRatePlanChargeId;
                    }

                    ChargeResponse chargeDetails = (ChargeResponse) new ChargeRequest().sendRequest(
                            new Map<String, String>{'Authorization' => 'Bearer ' + sessionToken.access_token},
                            null,
                            rpcId
                    );

                    if(chargeDetails.ChargeNumber != null){
                        lastChargeNumber = chargeDetails.ChargeNumber;
                    }

                    AllRevenueSchedulesResponse allRevScheds = (AllRevenueSchedulesResponse) new AllRevenueSchedulesRequest().sendRequest(
                            new Map<String, String>{'Authorization' => 'Bearer ' + sessionToken.access_token},
                            null,
                            rpcId
                    );

                    if(allRevScheds.success && !Test.isRunningTest()){
                        Boolean shouldSkip = false;
                        for(RevenueScheduleDetail revSched: allRevScheds.revenueSchedules){
                            shouldSkip |= revSched.ChargeReferenceId == rpcId;
                        }
                        if(shouldSkip){
                            continue;
                        }
                    }

                    Integer generatedSplits = 0;

                    Decimal lastRemainder = 0.0;
                    for (Split__c split : splits) {
                        if(split.Product_Split__r.Product_Rate_Plan_Charge__r.zqu__ZuoraId__c != metrics.productRatePlanChargeId){
                            continue;
                        }

                        String startDate;
                        if(chargeDetails.startDate != null && chargeDetails.startDate != ''){
                            startDate = chargeDetails.startDate;
                        } else {
                            startDate = tcv.startDate;
                        }

                        String endDate;
                        if(chargeDetails.endDate != null && chargeDetails.endDate != ''){
                            endDate = chargeDetails.endDate;
                        } else {
                            endDate = tcv.endDate;
                        }

                        RevenueScheduleRequest revSchedRequest = new RevenueScheduleRequest(tcv.amount, startDate, rpcId, split, accountingPeriodsResponse, lastRemainder);
                        System.debug('RSR: ' + revSchedRequest.url + rpcId);
                        RevenueScheduleResponse schedResponse = (RevenueScheduleResponse) revSchedRequest.sendRequest(
                                new Map<String, String>{'Authorization' => 'Bearer ' + sessionToken.access_token},
                                revSchedRequest.getBody(),
                                rpcId
                        );
                        System.debug('RSR2: ' + schedResponse.revenueScheduleNumber);
                        lastRemainder = revSchedRequest.getRemainder();

                        if (!schedResponse.success) {
                            System.debug('ERROR in RevenueScheduleRequest!');
                            System.debug(schedResponse.reasons);

                            if(chargesFailedOnClosedPeriods.contains(chargeDetails.ChargeNumber)){
                                continue;
                            }

                            for(Response.Reason r: schedResponse.reasons){
                                if(r.code == ACCOUNTING_PERIODS_ERROR_CODE){
                                    chargesFailedOnClosedPeriods.add(chargeDetails.ChargeNumber);
                                    break;
                                }
                            }
                        }

                        if (split.Recognition_Rule__c == 'Recognize revenue over subscription start to end date') {
                            TermDistributionRequest termDistReq = new TermDistributionRequest(startDate, endDate);
                            System.debug('BEFORE: ' + termDistReq.url + schedResponse.revenueScheduleNumber + '/distribute-revenue-with-date-range');
                            TermDistributionResponse termDistResp = (TermDistributionResponse) termDistReq.sendRequest(
                                    new Map<String, String>{'Authorization' => 'Bearer ' + sessionToken.access_token},
                                    termDistReq.getBody(),
                                    schedResponse.revenueScheduleNumber + '/distribute-revenue-with-date-range'
                            );
                            System.debug('AFTER:');
                            checkSuccess(termDistResp, 'ERROR in TermDistributionRequest!');
                        }
                        generatedSplits++;
                        System.debug('GENSPLITS:' + generatedSplits);
                    }
                    System.debug(generatedSplits);
                    if(generatedSplits > 0 && !chargesFailedOnClosedPeriods.contains(chargeDetails.ChargeNumber)){
                        ChargeSummaryResponse csr = (ChargeSummaryResponse) new ChargeSummaryRequest().sendRequest(
                                new Map<String, String>{'Authorization' => 'Bearer ' + sessionToken.access_token},
                                null,
                                rpcId
                        );

                        histories.add(
                                new Product_Split_History__c(
                                        Name = csr.number_field,
                                        Summary_Hyperlink__c = getZuoraBaseUrl(ZuoraRevenueSplitHelper.isSandbox) + 'apps/RevenueSchedule.dox?method=viewCRS&number=' + csr.number_field,
                                        Type__c = type,
                                        Revenue_Splits_Request__c = revenueSplitRequestId
                                )
                        );
                    }
                }
            }
        }

        return histories;
    }

    @TestVisible
    private static void checkSuccess(Response r, String resType){
        if(!r.success){
            System.debug(resType);
            System.debug(r.reasons);
        }
    }

    public void execute(SchedulableContext param1) {
        insert new Revenue_Splits_Request__c(
                Start_Date__c = Date.today(),
                End_Date__c = Date.today()
        );

        /*Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.toAddresses = new List<String>{'kacper@launchpadq2c.com'};
        msg.subject = 'Revsplits job!';
        msg.plainTextBody = 'The job has ran at ' + Datetime.now();
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{msg});*/
    }
}