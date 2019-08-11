/**
 * Created on 19/02/2019.
 */

public with sharing class SingleReconciliationController {

    public static final Map<String, String> zuoraToSfModels = new Map<String, String>{
        'PerUnit' => 'Per Unit Pricing',
        'FlatFee' => 'Flat Fee Pricing'
    };

    public zqu__Quote__c quote {get;set;}
    public List<zqu__Quote__c> subQuotes {get;set;}
    private Set<Id> quoteIds;

    private ZOQLHelper.TokenResponse token;

    @TestVisible //workaround for being unable to set Quote Number & Id in tests to a specific value
    private String testQuoteId;
    @TestVisible
    private String testQuoteNumber;

    @TestVisible
    private String requestLabel;

    public Boolean isValid {get; set;}

    public String reconciliationStatus {get;set;}

    public Map<String, List<RatePlanReconciliation>> rppByQuotes {get;set;}

    public List<String> quoteNumbers {get;set;}

    private Map<String, ZuoraSubscriptionWrapper> searchResults {get;set;}

    private List<ZuoraSubscriptionWrapper> wrapperList {get;set;}

    public List<ReconciliationWrapper> reconciliationList {get;set;}

    public Decimal totalZuoraTCV {get;set;}
    public Decimal sfTcv {get;set;}

    public String xmlRequest {get;set;}
    public String xmlResponse {get;set;}

    private Set<String> prpIds = new Set<String>();
    public List<RatePlanReconciliation> ratePlans {get;set;}

    private Date latestChargeDate;

    public SingleReconciliationController(){
        this.token = ZOQLHelper.getSessionToken();
        this.reconciliationStatus = 'In progress...';
        Id qId = ApexPages.currentPage().getParameters().get('id');
        if (qId != null){
            zqu__Quote__c quote = [
                SELECT Id, zqu__Number__c, Name, Total_TCV_Formatted__c, zqu__Zuora_Account_Number__c,
                    zqu__InitialTermPeriodType__c, zqu__InitialTerm__c, zqu__StartDate__c, zqu__RenewalSetting__c,
                    zqu__Subscription_Term_Type__c, zqu__RenewalTerm__c, zqu__RenewalTermPeriodType__c,
                    Split_Parent_Quote__c, zqu__ZuoraAccountID__c
                FROM zqu__Quote__c
                WHERE Id = :qId
            ];
            if (quote.Split_Parent_Quote__c != null){
                this.quote = [
                    SELECT Id, zqu__Number__c, Name, Total_TCV_Formatted__c, zqu__Zuora_Account_Number__c,
                        zqu__InitialTermPeriodType__c, zqu__InitialTerm__c, zqu__StartDate__c, zqu__RenewalSetting__c,
                        zqu__Subscription_Term_Type__c, zqu__RenewalTerm__c, zqu__RenewalTermPeriodType__c,
                        Split_Parent_Quote__c, zqu__ZuoraAccountID__c
                    FROM zqu__Quote__c
                    WHERE Id = :quote.Split_Parent_Quote__c
                ];
            } else {
                this.quote = quote;
            }
            this.subQuotes = new List<zqu__Quote__c>([
                SELECT Id, zqu__Number__c, Name, Total_TCV_Formatted__c, zqu__Zuora_Account_Number__c,
                    zqu__InitialTermPeriodType__c, zqu__InitialTerm__c, zqu__StartDate__c, zqu__RenewalSetting__c,
                    zqu__Subscription_Term_Type__c, zqu__RenewalTerm__c, zqu__RenewalTermPeriodType__c,
                    Split_Parent_Quote__c, zqu__ZuoraAccountID__c
                FROM zqu__Quote__c
                WHERE Split_Parent_Quote__c = :this.quote.Id
            ]);
            this.quoteIds = new Set<Id>{this.quote.Id};
            this.quoteNumbers = new List<String>();//{this.quote.zqu__Number__c};
            for (zqu__Quote__c q : subQuotes){
                this.quoteIds.add(q.Id);
                this.quoteNumbers.add(q.zqu__Number__c);
            }
        }
        sfTcv = this.quote.Total_TCV_Formatted__c == null ? 0 : this.quote.Total_TCV_Formatted__c;
        for (zqu__QuoteRatePlanCharge__c qrpc : [
            SELECT Custom_TCV_Formula__c
            FROM zqu__QuoteRatePlanCharge__c
            WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :this.quote.Id AND zqu__QuoteRatePlan__r.ApproveProductServiceCatF__c = 'Services'
        ]){
            sfTcv -= qrpc.Custom_TCV_Formula__c;
        }
        sfTcv = sfTcv.setScale(2, System.RoundingMode.HALF_EVEN);

        querySubscriptions();
    }

    public Object querySubscriptions(){
        String idString = '';
        for (Id id : quoteIds){
            idString += 'QuoteId__c = \'' + String.valueOf(id).substring(0,15) + '\' OR ';
        }
        idString = '(' + idString.substringBeforeLast('OR') + ')';
        QueryString qString = new QueryString()
            .addSelect('*')
            .setFrom('Subscription')
            .addWhere(idString)
            .addWhere('Subscription_Type__c != \'PS\'');

        System.debug(qString.getQuery());

        ZOQLHelper.AQuARequest req = new ZOQLHelper.AQuARequest(
            'csv',
            '1.0',
            'single-reconciliation-request-' + UserInfo.getUserId(),
            'none',
            'true'
        );

        req.addQuery(new ZOQLHelper.QueryObject('subs', 'zoqlexport', qString.getQuery()));

//        Continuation con = new Continuation(120);
//        con.ContinuationMethod = 'CallbackMethod';
//        this.requestLabel = con.addHttpRequest(req.getRequest(token));

        return CallbackMethod(new Http().send(req.getRequest(token)));
    }

    public Object CallbackMethod(HttpResponse resp){
//        HttpResponse resp = Continuation.getResponse(this.requestLabel);
        ZOQLHelper.AQuAResponse AQuAresponse = (ZOQLHelper.AQuAResponse) JSON.deserialize(resp.getBody(), ZOQLHelper.AQuAResponse.class);
        HttpResponse response;
        while (AQuAresponse.status != 'completed' && AQuAresponse.status != 'error'){
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:__Zuora_REST_Api/v1/batch-query/jobs/' + AQuAresponse.id);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + token.access_token);
            request.setMethod('GET');
            response = new Http().send(request);
            AQuAresponse = (ZOQLHelper.AQuAResponse) JSON.deserialize(response.getBody(), ZOQLHelper.AQuAResponse.class);
        }

        if (AQuAresponse.status == 'error'){
            return null;
        }

        this.searchResults = new Map<String, ZuoraSubscriptionWrapper>();
        this.wrapperList = new List<ZuoraSubscriptionWrapper>();
        List<Map<String, Object>> subs = AQuAresponse.getBatchByName('subs', token);
        List<String> zuoraIds = new List<String>();
        List<String> zuoraNumbers = new List<String>();
        totalZuoraTCV = 0;
        for (Map<String, Object> sub : subs){
            HttpRequest TCVRequest = new HttpRequest();
            TCVRequest.setEndpoint('callout:__Zuora_REST_Api/v1/subscriptions/' + sub.get('Id'));
            TCVRequest.setHeader('Authorization', 'Bearer ' + token.access_token);
            TCVRequest.setMethod('GET');
            HttpResponse TCVResponse = new Http().send(TCVRequest);
            System.debug('tcvresp for ' + sub.get('Id') + ': ' + TCVResponse.getBody());
            ZuoraSubscriptionWrapper zsw = (ZuoraSubscriptionWrapper) JSON.deserialize(TCVResponse.getBody().replace('QuoteNumber__QT', 'QuoteNumber'), ZuoraSubscriptionWrapper.class);
            if (Test.isRunningTest()){
                zsw.QuoteID = this.testQuoteId;
                zsw.QuoteNumber = this.testQuoteNumber;
            } else {
                zsw.QuoteID = (String) sub.get('QuoteID__c');
            }
            for (ZuoraRatePlanWrapper zrpw : zsw.ratePlans){
                this.prpIds.add(zrpw.productRatePlanId);
            }

            this.wrapperList.add(zsw);
            this.searchResults.put(zsw.subscriptionNumber, zsw);
            totalZuoraTCV += zsw.totalContractedValue == null ? 0 : zsw.totalContractedValue;
            zuoraIds.add(zsw.id);
            zuoraNumbers.add(zsw.subscriptionNumber);
        }
        totalZuoraTCV = totalZuoraTCV.setScale(2, RoundingMode.HALF_EVEN);

        Map<String, Zuora__Subscription__c> sfdcSubscriptions = new Map<String, Zuora__Subscription__c>();
        for (Zuora__Subscription__c sub : [
            SELECT Id, Zuora__SubscriptionNumber__c, Zuora__TermStartDate__c, Zuora__SubscriptionStartDate__c,
                Quote__c, Name, Zuora__Zuora_Id__c, QuoteID__c, Zuora__TCV__c, Zuora__SubscriptionEndDate__c,
                Zuora__QuoteNumber__c, Quote__r.zqu__Number__c
            FROM Zuora__Subscription__c
            WHERE QuoteID__c = :quote.Id
            OR Zuora__Zuora_Id__c IN :zuoraIds
        ]){
            sfdcSubscriptions.put(sub.Zuora__SubscriptionNumber__c, sub);
        }

        Map<String, Map<String, Map<String, List<zqu__QuoteRatePlanCharge__c>>>> qrpcByDateByRpcByQuote = new Map<String, Map<String, Map<String, List<zqu__QuoteRatePlanCharge__c>>>>();
        for (String quoteNumber : quoteNumbers){
            qrpcByDateByRpcByQuote.put(quoteNumber, new Map<String, Map<String, List<zqu__QuoteRatePlanCharge__c>>>());
        }
        for (zqu__QuoteRatePlanCharge__c qrpc : [
            SELECT Id, zqu__ProductRatePlanChargeZuoraId__c, Quote_ID__c, Product_Rate_Plan_ZuoraID__c, SKU__c,
                zqu__QuoteRatePlan__r.Name, Start_Date__c, End_Date__c, Name, zqu__EffectivePrice__c, zqu__Model__c,
                Custom_TCV_Formula__c, zqu__TriggerDate__c, zqu__TriggerEvent__c, zqu__QuoteRatePlan__r.zqu__ProductRatePlanZuoraId__c,
                zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Number__c, zqu__UOM__c, zqu__TCV__c
            FROM zqu__QuoteRatePlanCharge__c
            WHERE (Product_Rate_Plan_ZuoraID__c IN :prpIds
            OR zqu__QuoteRatePlan__r.zqu__ProductRatePlanZuoraId__c IN :prpIds)
            AND Quote_ID__c IN :quoteIds
            AND Quote_ID__c != :quote.Id
        ]) {

            String quoteNumber = qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Number__c;
            if (String.isEmpty(qrpc.Product_Rate_Plan_ZuoraID__c)){
                qrpc.Product_Rate_Plan_ZuoraID__c = qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlanZuoraId__c;
            }
            if (!qrpcByDateByRpcByQuote.containsKey(quoteNumber)){
                qrpcByDateByRpcByQuote.put(quoteNumber, new Map<String, Map<String, List<zqu__QuoteRatePlanCharge__c>>>());
            }
            if (!qrpcByDateByRpcByQuote.get(quoteNumber).containsKey(qrpc.Product_Rate_Plan_ZuoraID__c)){
                qrpcByDateByRpcByQuote.get(quoteNumber).put(qrpc.Product_Rate_Plan_ZuoraID__c, new Map<String, List<zqu__QuoteRatePlanCharge__c>>());
            }
            if (qrpc.Start_Date__c == null){
                qrpc.Start_Date__c = 'N/A';
            }
            if (!qrpcByDateByRpcByQuote.get(quoteNumber).get(qrpc.Product_Rate_Plan_ZuoraID__c).containsKey(qrpc.Start_Date__c)){
                qrpcByDateByRpcByQuote.get(quoteNumber).get(qrpc.Product_Rate_Plan_ZuoraID__c).put(qrpc.Start_Date__c, new List<zqu__QuoteRatePlanCharge__c>());
            }
            if (qrpc.zqu__UOM__c != null && qrpc.zqu__UOM__c.startsWith('PS')){
                continue;
            } else {
                if (this.latestChargeDate == null || this.latestChargeDate < Date.valueOf(qrpc.End_Date__c)){
                    this.latestChargeDate = Date.valueOf(qrpc.End_Date__c);
                }
                qrpcByDateByRpcByQuote.get(quoteNumber).get(qrpc.Product_Rate_Plan_ZuoraID__c).get(qrpc.Start_Date__c).add(qrpc);
            }

        }

        this.reconciliationList = new List<ReconciliationWrapper>();

        this.ratePlans = new List<RatePlanReconciliation>();

        for (String key : this.searchResults.keySet()){
            this.reconciliationList.add(new ReconciliationWrapper(sfdcSubscriptions.get(key), this.searchResults.get(key), key));
        }

        rppByQuotes = new Map<String, List<RatePlanReconciliation>>();
        for (String s : quoteNumbers){
            rppByQuotes.put(s, new List<RatePlanReconciliation>());
        }

        for (ZuoraSubscriptionWrapper zsw : searchResults.values()){
            String quoteNumber = zsw.QuoteNumber;
            if (!rppByQuotes.containsKey(zsw.QuoteNumber)){
                rppByQuotes.put(zsw.QuoteNumber, new List<RatePlanReconciliation>());
            }
            String qNumber = zsw.QuoteNumber;
            List<zqu__QuoteRatePlanCharge__c> qrpcToRemove = new List<zqu__QuoteRatePlanCharge__c>();
            List<ZuoraRatePlanChargeWrapper> toRemove = new List<ZuoraRatePlanChargeWrapper>();
            for (ZuoraRatePlanWrapper zrpw : zsw.ratePlans){
                System.debug(qrpcByDateByRpcByQuote.keySet());
                System.debug(quoteNumber);
                if (!qrpcByDateByRpcByQuote.containsKey(quoteNumber) || !qrpcByDateByRpcByQuote.get(quoteNumber).containsKey(zrpw.productRatePlanId)){
                    for (ZuoraRatePlanChargeWrapper zrpcw : zrpw.ratePlanCharges){
                        RatePlanReconciliation rpp = new RatePlanReconciliation();
                        rpp.subNumber = zsw.subscriptionNumber;
                        rpp.ratePlanChargeReconciliations = new List<RatePlanChargeReconciliation>();
                        rpp.ratePlanChargeReconciliations.add(new RatePlanChargeReconciliation(new zqu__QuoteRatePlanCharge__c(Name = ''), zrpcw, zrpw.ratePlanName));
                        rppByQuotes.get(qNumber).add(rpp);
                        toRemove.add(zrpcw);
                    }
                    for (ZuoraRatePlanChargeWrapper zrpcw : toRemove){
                        zrpw.ratePlanCharges.remove(zrpw.ratePlanCharges.indexOf(zrpcw));
                    }
                    toRemove.clear();
                } else {
                    for (String key : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).keySet()){
                        System.debug('PRP Id: ' + key);
                        Boolean found = false;
                        RatePlanReconciliation rpp = new RatePlanReconciliation();
                        rpp.name = zrpw.ratePlanName;
                        rpp.subNumber = zsw.subscriptionNumber;
                        rpp.ratePlanChargeReconciliations = new List<RatePlanChargeReconciliation>();
                        for (zqu__QuoteRatePlanCharge__c qrpc : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key)){
                            if (zrpw.ratePlanCharges != null){
                                for (ZuoraRatePlanChargeWrapper zrpcw : zrpw.ratePlanCharges){
//                                    System.debug(qrpc.Start_Date__c + ' ' + qrpc.End_Date__c + ' ' + zrpcw.effectiveStartDate + ' ' + zrpcw.effectiveEndDate);
                                    if ((!String.isEmpty(qrpc.Start_Date__c) && zrpcw.effectiveStartDate != null) && String.valueOf(zrpcw.effectiveStartDate) == qrpc.Start_Date__c && (qrpc.End_Date__c != null && zrpcw.effectiveEndDate != null) &&  zrpcw.effectiveEndDate == Date.valueOf(qrpc.End_Date__c) && qrpc.Custom_TCV_Formula__c == zrpcw.tcv){
                                        found = true;
                                        toRemove.add(zrpcw);
                                        qrpcToRemove.add(qrpc);
                                        System.debug('found by Start & End date: ' + qrpc + ' ' + zrpcw);
                                        rpp.ratePlanChargeReconciliations.add(new RatePlanChargeReconciliation(qrpc, zrpcw));
                                    }
                                }
                                for (ZuoraRatePlanChargeWrapper zrpcw : toRemove){
                                    zrpw.ratePlanCharges.remove(zrpw.ratePlanCharges.indexOf(zrpcw));
                                }
                                toRemove.clear();
                            }
                        }
                        for (zqu__QuoteRatePlanCharge__c qrpc : qrpcToRemove){
                            qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key).remove(
                                qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key).indexOf(qrpc)
                            );
                        }
                        qrpcToRemove.clear();
                        if (found){
//                            ratePlans.add(rpp);
                            rppByQuotes.get(qNumber).add(rpp);
                        }
                    }
                }

            }
            for (ZuoraRatePlanWrapper zrpw : zsw.ratePlans){
                System.debug('Rate Plan On ZSub: ' + zrpw);
                if (qrpcByDateByRpcByQuote.containsKey(quoteNumber) && qrpcByDateByRpcByQuote.get(quoteNumber).containsKey(zrpw.productRatePlanId)){
                    for (String key : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).keySet()){
                        System.debug('PRP Id: ' + key);
                        Boolean found = false;
                        RatePlanReconciliation rpp = new RatePlanReconciliation();
                        rpp.subNumber = zsw.subscriptionNumber;
                        rpp.name = zrpw.ratePlanName;
                        rpp.ratePlanChargeReconciliations = new List<RatePlanChargeReconciliation>();

                        for (zqu__QuoteRatePlanCharge__c qrpc : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key)){
                            for (ZuoraRatePlanChargeWrapper zrpcw : zrpw.ratePlanCharges){
                                Integer len = Math.min(qrpc.Name.length(), zrpcw.name.length());
                                if ((!String.isEmpty(qrpc.Start_Date__c) && zrpcw.effectiveStartDate != null) && String.valueOf(zrpcw.effectiveStartDate) == qrpc.Start_Date__c && (qrpc.End_Date__c != null && zrpcw.effectiveEndDate != null) &&  zrpcw.effectiveEndDate == Date.valueOf(qrpc.End_Date__c)){
                                    found = true;
                                    toRemove.add(zrpcw);
                                    qrpcToRemove.add(qrpc);
                                    System.debug('found by Start date & Name: ' + qrpc + ' ' + zrpcw);
                                    rpp.ratePlanChargeReconciliations.add(new RatePlanChargeReconciliation(qrpc, zrpcw));
                                }
                            }
                            for (ZuoraRatePlanChargeWrapper zrpcw : toRemove){
                                zrpw.ratePlanCharges.remove(zrpw.ratePlanCharges.indexOf(zrpcw));
                            }
                            toRemove.clear();
                        }
                        for (zqu__QuoteRatePlanCharge__c qrpc : qrpcToRemove){
                            qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key).remove(
                                qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key).indexOf(qrpc)
                            );
                        }
                        qrpcToRemove.clear();
                        if (found){
//                            ratePlans.add(rpp);
                            rppByQuotes.get(qNumber).add(rpp);
                        }
                    }
                }
            }
            for (ZuoraRatePlanWrapper zrpw : zsw.ratePlans){
                System.debug('Rate Plan On ZSub: ' + zrpw);
                if (qrpcByDateByRpcByQuote.containsKey(quoteNumber) && qrpcByDateByRpcByQuote.get(quoteNumber).containsKey(zrpw.productRatePlanId)){
                    for (String key : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).keySet()){
                        System.debug('PRP Id: ' + key);
                        Boolean found = false;
                        RatePlanReconciliation rpp = new RatePlanReconciliation();
                        rpp.subNumber = zsw.subscriptionNumber;
                        rpp.name = zrpw.ratePlanName;
                        rpp.ratePlanChargeReconciliations = new List<RatePlanChargeReconciliation>();

                        for (zqu__QuoteRatePlanCharge__c qrpc : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key)){
                            for (ZuoraRatePlanChargeWrapper zrpcw : zrpw.ratePlanCharges){
                                Integer len = Math.min(qrpc.Name.length(), zrpcw.name.length());
                                if ((!String.isEmpty(qrpc.Start_Date__c) && zrpcw.effectiveStartDate != null) && String.valueOf(zrpcw.effectiveStartDate) == qrpc.Start_Date__c && String.valueOf(zrpcw.effectiveStartDate) == qrpc.Start_Date__c && zrpcw.name.substring(0, len) == qrpc.Name.substring(0, len)){
                                    found = true;
                                    toRemove.add(zrpcw);
                                    qrpcToRemove.add(qrpc);
                                    System.debug('found by Start date & Name: ' + qrpc + ' ' + zrpcw);
                                    rpp.ratePlanChargeReconciliations.add(new RatePlanChargeReconciliation(qrpc, zrpcw));
                                }
                            }
                            for (ZuoraRatePlanChargeWrapper zrpcw : toRemove){
                                zrpw.ratePlanCharges.remove(zrpw.ratePlanCharges.indexOf(zrpcw));
                            }
                            toRemove.clear();
                        }
                        for (zqu__QuoteRatePlanCharge__c qrpc : qrpcToRemove){
                            qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key).remove(
                                    qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key).indexOf(qrpc)
                            );
                        }
                        qrpcToRemove.clear();
                        if (found){
//                            ratePlans.add(rpp);
                            rppByQuotes.get(qNumber).add(rpp);
                        }
                    }
                }
            }
            for (ZuoraRatePlanWrapper zrpw : zsw.ratePlans){
                System.debug('Rate Plan On ZSub: ' + zrpw);
                if (qrpcByDateByRpcByQuote.containsKey(quoteNumber) && qrpcByDateByRpcByQuote.get(quoteNumber).containsKey(zrpw.productRatePlanId)){
                    for (String key : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).keySet()){
                        System.debug('PRP Id: ' + key);
                        Boolean found = false;
                        RatePlanReconciliation rpp = new RatePlanReconciliation();
                        rpp.subNumber = zsw.subscriptionNumber;
                        rpp.name = zrpw.ratePlanName;
                        rpp.ratePlanChargeReconciliations = new List<RatePlanChargeReconciliation>();

                        for (zqu__QuoteRatePlanCharge__c qrpc : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key)){
                            for (ZuoraRatePlanChargeWrapper zrpcw : zrpw.ratePlanCharges){
                                Integer len = Math.min(qrpc.Name.length(), zrpcw.name.length());
                                if (zrpcw.name.substring(0, len) == qrpc.Name.substring(0, len)){
                                    found = true;
                                    toRemove.add(zrpcw);
                                    qrpcToRemove.add(qrpc);
                                    System.debug('found by Name date: ' + qrpc + ' ' + zrpcw);
                                    rpp.ratePlanChargeReconciliations.add(new RatePlanChargeReconciliation(qrpc, zrpcw));
                                }
                            }
                            for (ZuoraRatePlanChargeWrapper zrpcw : toRemove){
                                zrpw.ratePlanCharges.remove(zrpw.ratePlanCharges.indexOf(zrpcw));
                            }
                            toRemove.clear();
                        }
                        for (zqu__QuoteRatePlanCharge__c qrpc : qrpcToRemove){
                            qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key).remove(
                                qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key).indexOf(qrpc)
                            );
                        }
                        qrpcToRemove.clear();
                        if (found){
//                            ratePlans.add(rpp);
                            rppByQuotes.get(qNumber).add(rpp);
                        }
                    }
                }
            }
        }
        for (Map<String, Map<String, List<zqu__QuoteRatePlanCharge__c>>> mapMap : qrpcByDateByRpcByQuote.values()){
            for (Map<String, List<zqu__QuoteRatePlanCharge__c>> qrpcMap : mapMap.values()){
                for (List<zqu__QuoteRatePlanCharge__c> qrpcList : qrpcMap.values()){
                    for (zqu__QuoteRatePlanCharge__c qrpc : qrpcList){
                        System.debug('leftover qrpc: ' + qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Number__c);
                        RatePlanReconciliation rpp = new RatePlanReconciliation();
                        rpp.name = qrpc.zqu__QuoteRatePlan__r.Name;
                        rpp.ratePlanChargeReconciliations = new List<RatePlanChargeReconciliation>();
                        rpp.ratePlanChargeReconciliations.add(new RatePlanChargeReconciliation(qrpc, new ZuoraRatePlanChargeWrapper()));
                        if (!rppByQuotes.containsKey(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Number__c)){
                            rppByQuotes.put(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Number__c, new List<RatePlanReconciliation>());
                        }
                        rppByQuotes.get(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Number__c).add(rpp);
                    }
                }
            }
        }



//        if(zuoraIds.isEmpty()){
            HttpRequest previewSubscriptionCall = new HttpRequest();
            previewSubscriptionCall.setMethod('POST');
            previewSubscriptionCall.setEndpoint('callout:__Zuora_REST_Api/v1/operations/billing-preview');
            previewSubscriptionCall.setHeader('Authorization', 'Bearer ' + token.access_token);
            previewSubscriptionCall.setHeader('Content-Type', 'application/json');
            ZOQLHelper.BillingPreview billingPreview = new ZOQLHelper.BillingPreview(this.quote.zqu__ZuoraAccountID__c, 'None', 'true', this.latestChargeDate == null ? Date.today().addYears(1) : this.latestChargeDate);
            previewSubscriptionCall.setBody(JSON.serialize(billingPreview));
            HttpResponse resp2 = new Http().send(previewSubscriptionCall);
            System.debug('preview response: ' + resp2.getBody());
            System.debug('preview call: ' + previewSubscriptionCall.getBody());
            this.xmlResponse = resp2.getBody();
            this.xmlRequest = previewSubscriptionCall.getBody();
//        }
//        System.debug(this.latestChargeDate);
//        System.debug(this.quote.zqu__Zuora_Account_Number__c);
//        PivLP_AuraModel.BillingPreviewResult result = new PivLP_ZSOAPClient().billingPreview(this.quote.zqu__Zuora_Account_Number__c, this.latestChargeDate);
//        System.debug('RESULT: ' + result);
        if (this.rppByQuotes != null){
            this.isValid = true;
            for (String key : rppByQuotes.keySet()){
                if (key == this.quote.zqu__Number__c){
                    continue;
                } else {
                    for (RatePlanReconciliation rpp : rppByQuotes.get(key)){
                        for (ChargeWrapper chargeWrapper : rpp.charges){
                            this.isValid &= !chargeWrapper.isInvalid();
                        }
                    }
                }
            }
        } else {
            this.isValid = false;
        }
        if(isValid){
            this.reconciliationStatus = 'Quote is valid';
        } else {
            this.reconciliationStatus = 'There are errors in the Quote';
        }
        return null;
    }

    public class RatePlanReconciliation {
        public String name {get;set;}
        public String subNumber {get;set;}
        public List<RatePlanChargeReconciliation> ratePlanChargeReconciliations {get;set;}
        public List<ChargeWrapper> charges {get {
            if (this.charges == null || this.charges.isEmpty()){
                this.charges = new List<ChargeWrapper>();
                for (RatePlanChargeReconciliation rpcw : ratePlanChargeReconciliations){
                    this.charges.add(new ChargeWrapper(rpcw.sfRatePlanCharge, rpcw.zuoraRatePlanCharge, true));
                    this.charges.add(new ChargeWrapper(rpcw.sfRatePlanCharge, rpcw.zuoraRatePlanCharge, false));
                }
                ratePlanChargeReconciliations.clear();
            }
            return this.charges;
        }set;}

    }

    public class ChargeWrapper {

        public ChargeWrapper (zqu__QuoteRatePlanCharge__c qrpc, ZuoraRatePlanChargeWrapper zrpcw, Boolean zuora){
            if (zuora){
                this.name = zrpcw.name.trim() + ' (Zuora)';
                this.startDate = zrpcw.effectiveStartDate;
                this.endDate = zrpcw.effectiveEndDate;
                this.amount = zrpcw.tcv == null ? (zrpcw.price == null ? 0 : zrpcw.price.setScale(2, RoundingMode.HALF_EVEN)) : zrpcw.tcv.setScale(2, RoundingMode.HALF_EVEN);
                this.model = zrpcw.model;
            } else {
                this.name = qrpc.Name.trim() + ' (Salesforce)';
                if (qrpc.Start_Date__c != null && qrpc.Start_Date__c != 'N/A'){
                    this.startDate = Date.valueOf(qrpc.Start_Date__c);
                }
                if (qrpc.End_Date__c != null){
                    this.endDate = Date.valueOf(qrpc.End_Date__c);
                }
                if (qrpc.Custom_TCV_Formula__c == null && qrpc.zqu__TCV__c == null){
                    this.amount = 0;
                } else {
                    this.amount = qrpc.Custom_TCV_Formula__c == 0 ? qrpc.zqu__TCV__c.setScale(2, RoundingMode.HALF_EVEN) : qrpc.Custom_TCV_Formula__c.setScale(2, RoundingMode.HALF_EVEN);
                }
                this.model = qrpc.zqu__Model__c;
            }
            Integer len = Math.min(qrpc.Name.trim().length(), zrpcw.name.trim().length());
            this.markName = zrpcw.name.trim().substring(0, len) != qrpc.Name.trim().substring(0, len);
            if (qrpc.Start_Date__c != null && qrpc.Start_Date__c != 'N/A'){
                this.markStartDate = zrpcw.effectiveStartDate != Date.valueOf(qrpc.Start_Date__c);
            } else {
                this.markStartDate = true;
            }
            if (qrpc.End_Date__c != null){
                this.markEndDate = zrpcw.effectiveEndDate != Date.valueOf(qrpc.End_Date__c);
            } else {
                this.markEndDate = true;
            }
            System.debug(qrpc);
            if (qrpc.Custom_TCV_Formula__c == null && qrpc.zqu__EffectivePrice__c == null){
                this.markAmount = true;
            } else {
                this.markAmount = (zrpcw.tcv == null ? (zrpcw.price == null ? 0 : zrpcw.price.setScale(2, RoundingMode.HALF_EVEN)) : zrpcw.tcv.setScale(2, RoundingMode.HALF_EVEN)) != (qrpc.Custom_TCV_Formula__c == 0 ? qrpc.zqu__EffectivePrice__c.setScale(2, RoundingMode.HALF_EVEN) : qrpc.Custom_TCV_Formula__c.setScale(2, RoundingMode.HALF_EVEN));
            }
            this.markModel = SingleReconciliationController.zuoraToSfModels.get(zrpcw.model) != qrpc.zqu__Model__c;

        }

        public Boolean markName {get;set;}
        public String name {get;set;}
        public Boolean markStartDate {get;set;}
        public Date startDate {get;set;}
        public Boolean markEndDate {get;set;}
        public Date endDate {get;set;}
        public Boolean markAmount {get;set;}
        public Decimal amount {get;set;}
        public Boolean markModel {get;set;}
        public String model {get;set;}

        public Boolean isInvalid(){
            return this.markName || this.markModel || this.markEndDate || this.markAmount || this.markStartDate;
        }
    }

    public class RatePlanChargeReconciliation {

        public RatePlanChargeReconciliation (zqu__QuoteRatePlanCharge__c qrpc, ZuoraRatePlanChargeWrapper zrpcw){
            this.sfRatePlanCharge = qrpc;
            this.zuoraRatePlanCharge = zrpcw;
            if (qrpc != null){
                this.name = qrpc.zqu__QuoteRatePlan__r.Name;
            }
        }
        public RatePlanChargeReconciliation (zqu__QuoteRatePlanCharge__c qrpc, ZuoraRatePlanChargeWrapper zrpcw, String name){
            this.sfRatePlanCharge = qrpc;
            this.zuoraRatePlanCharge = zrpcw;
            this.name = name;
        }

        public String name {get;set;}
        public zqu__QuoteRatePlanCharge__c sfRatePlanCharge {get;set;}
        public ZuoraRatePlanChargeWrapper zuoraRatePlanCharge {get;set;}
    }

    public class ReconciliationWrapper {
        public List<SubscriptionWrapper> wrappers {get;set;}
        public String key {get;set;}

        public ReconciliationWrapper(Zuora__Subscription__c sSub, ZuoraSubscriptionWrapper zSub, String key){
            this.key = key;
            this.wrappers = new List<SubscriptionWrapper>();
            this.wrappers.add(new SubscriptionWrapper(zSub == null ? new ZuoraSubscriptionWrapper() : zSub, sSub == null ? new Zuora__Subscription__c() : sSub, true));
            this.wrappers.add(new SubscriptionWrapper(zSub == null ? new ZuoraSubscriptionWrapper() : zSub, sSub == null ? new Zuora__Subscription__c() : sSub, false));
        }

    }

    public class SubscriptionWrapper {
        public SubscriptionWrapper (ZuoraSubscriptionWrapper zSubscription, Zuora__Subscription__c sSubscription, Boolean fromZuora){
            if (!fromZuora){
                this.origin = 'Salesforce';
                this.QuoteNumber = sSubscription.Zuora__QuoteNumber__c;
                this.tcv = sSubscription.Zuora__TCV__c == null ? 0 : sSubscription.Zuora__TCV__c.setScale(2, RoundingMode.HALF_EVEN);
                this.SubscriptionNumber = sSubscription.Zuora__SubscriptionNumber__c;
                this.ZuoraId = sSubscription.Zuora__Zuora_Id__c;
                this.startDate = sSubscription.Zuora__SubscriptionStartDate__c;
            } else {
                this.origin = 'Zuora';
                this.QuoteNumber = zSubscription.QuoteNumber;
                this.tcv = zSubscription.totalContractedValue.setScale(2, RoundingMode.HALF_EVEN);
                this.SubscriptionNumber = zSubscription.subscriptionNumber;
                this.ZuoraId = zSubscription.id;
                this.startDate = zSubscription.subscriptionStartDate;
            }
            this.markQuoteNumber = zSubscription.QuoteNumber != sSubscription.Zuora__QuoteNumber__c;
            this.markTcv = (zSubscription.totalContractedValue == null ? 0 : zSubscription.totalContractedValue.setScale(2, RoundingMode.HALF_EVEN)) != (sSubscription.Zuora__TCV__c == null ? 0 : sSubscription.Zuora__TCV__c.setScale(2, RoundingMode.HALF_EVEN));
            this.markSubscriptionNumber = zSubscription.subscriptionNumber != sSubscription.Zuora__SubscriptionNumber__c;
            this.markId = zSubscription.id != sSubscription.Zuora__Zuora_Id__c;
            this.markDate = zSubscription.subscriptionStartDate != sSubscription.Zuora__SubscriptionStartDate__c;
        }

        public String origin {get;set;}
        public String QuoteNumber{get;set;}
        public Decimal tcv {get;set;}
        public String SubscriptionNumber {get;set;}
        public String ZuoraId {get;set;}
        public Date startDate {get;set;}
        public Boolean markQuoteNumber {get;set;}
        public Boolean markTcv {get;set;}
        public Boolean markSubscriptionNumber {get;set;}
        public Boolean markId {get;set;}
        public Boolean markDate {get;set;}
    }

    public class ZuoraSubscriptionWrapper {
        public Decimal totalContractedValue {get;set;}
        public String name {get;set;}
        public String id {get;set;}
        public String accountName {get;set;}
        public String subscriptionNumber {get;set;}
        public Date subscriptionStartDate {get;set;}
        public Date termStartDate {get;set;}
        public Date termEndDate {get;set;}
        public Integer initialTerm {get;set;}
        public Integer currentTerm {get;set;}
        public Integer renewalTerm {get;set;}
        public String QuoteID {get;set;}
        public String QuoteNumber {get;set;}
        public List<ZuoraRatePlanWrapper> ratePlans;
    }

    public class ZuoraRatePlanWrapper {
        public String ratePlanName;
        public String id;
        public String productName;
        public String productSku;
        public String productRatePlanId;
        public List<ZuoraRatePlanChargeWrapper> ratePlanCharges {get;set;}
    }

    public class ZuoraRatePlanChargeWrapper {
        public ZuoraRatePlanChargeWrapper(){
            this.name = '';
        }
        public String model;
        public String id;
        public String rpcNumber;
        public String name;
        public String type;
        public Decimal price;
        public String billingPeriod;
        public String quantity;
        public Date effectiveStartDate {get;set;}
        public Date effectiveEndDate {get;set;}
        public Decimal tcv {get;set;}
    }


}