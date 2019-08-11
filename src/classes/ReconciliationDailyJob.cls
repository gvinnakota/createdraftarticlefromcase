/**
 * Created on 26/02/2019.
 */

public with sharing class ReconciliationDailyJob implements Schedulable, Database.AllowsCallouts {

    private static Map<String, SingleReconciliationController.ZuoraSubscriptionWrapper> searchResults;

    private static Set<Id> quoteIds;

    private static Map<String, String> quotesByNumbers;

    private static ZOQLHelper.TokenResponse token;

    @TestVisible //workaround for being unable to set Quote Number & Id in tests to a specific value
    private static String testQuoteId;
    @TestVisible
    private static String testQuoteNumber;

    public void execute(SchedulableContext param1) {
        exec();
    }

    @Future(callout=true)
    private static void exec(){
        token = ZOQLHelper.getSessionToken();
        getSubscriptions();
        getMissingData();
    }

    private static void getMissingData(){

        DailyReconciliationReport__c report = new DailyReconciliationReport__c();
        insert report;

        Map<String, Map<String, Map<String, List<zqu__QuoteRatePlanCharge__c>>>> qrpcByDateByRpcByQuote = new Map<String, Map<String, Map<String, List<zqu__QuoteRatePlanCharge__c>>>>();
        for (zqu__QuoteRatePlanCharge__c qrpc : [
            SELECT Id, zqu__ProductRatePlanChargeZuoraId__c, Quote_ID__c, Product_Rate_Plan_ZuoraID__c, SKU__c,
                zqu__QuoteRatePlan__r.Name, Start_Date__c, End_Date__c, Name, zqu__EffectivePrice__c, zqu__Model__c,
                Custom_TCV_Formula__c, zqu__TriggerDate__c, zqu__TriggerEvent__c, zqu__QuoteRatePlan__r.zqu__ProductRatePlanZuoraId__c,
                zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Number__c, zqu__UOM__c, zqu__TCV__c
            FROM zqu__QuoteRatePlanCharge__c
            WHERE Quote_ID__c IN :quoteIds
            AND zqu__QuoteRatePlan__r.zqu__Quote__r.Split_Parent_Quote__c != NULL
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
                qrpcByDateByRpcByQuote.get(quoteNumber).get(qrpc.Product_Rate_Plan_ZuoraID__c).get(qrpc.Start_Date__c).add(qrpc);
            }
        }
        Map<String, List<SingleReconciliationController.RatePlanReconciliation>> rppByQuotes = new Map<String, List<SingleReconciliationController.RatePlanReconciliation>>();
        for (SingleReconciliationController.ZuoraSubscriptionWrapper zsw : searchResults.values()){
            String quoteNumber = zsw.QuoteNumber;
            if (!rppByQuotes.containsKey(zsw.QuoteNumber)){
                rppByQuotes.put(zsw.QuoteNumber, new List<SingleReconciliationController.RatePlanReconciliation>());
            }
            String qNumber = zsw.QuoteNumber;
            List<zqu__QuoteRatePlanCharge__c> qrpcToRemove = new List<zqu__QuoteRatePlanCharge__c>();
            List<SingleReconciliationController.ZuoraRatePlanChargeWrapper> toRemove = new List<SingleReconciliationController.ZuoraRatePlanChargeWrapper>();
            for (SingleReconciliationController.ZuoraRatePlanWrapper zrpw : zsw.ratePlans){
                System.debug(qrpcByDateByRpcByQuote.keySet());
                System.debug(quoteNumber);
                if (!qrpcByDateByRpcByQuote.containsKey(quoteNumber) || !qrpcByDateByRpcByQuote.get(quoteNumber).containsKey(zrpw.productRatePlanId)){
                    for (SingleReconciliationController.ZuoraRatePlanChargeWrapper zrpcw : zrpw.ratePlanCharges){
                        SingleReconciliationController.RatePlanReconciliation rpp = new SingleReconciliationController.RatePlanReconciliation();
                        rpp.subNumber = zsw.subscriptionNumber;
                        rpp.ratePlanChargeReconciliations = new List<SingleReconciliationController.RatePlanChargeReconciliation>();
                        rpp.ratePlanChargeReconciliations.add(new SingleReconciliationController.RatePlanChargeReconciliation(new zqu__QuoteRatePlanCharge__c(Name = ''), zrpcw, zrpw.ratePlanName));
                        rppByQuotes.get(qNumber).add(rpp);
                        toRemove.add(zrpcw);
                    }
                    for (SingleReconciliationController.ZuoraRatePlanChargeWrapper zrpcw : toRemove){
                        zrpw.ratePlanCharges.remove(zrpw.ratePlanCharges.indexOf(zrpcw));
                    }
                    toRemove.clear();
                } else {
                    for (String key : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).keySet()){
                        System.debug('PRP Id: ' + key);
                        Boolean found = false;
                        SingleReconciliationController.RatePlanReconciliation rpp = new SingleReconciliationController.RatePlanReconciliation();
                        rpp.name = zrpw.ratePlanName;
                        rpp.subNumber = zsw.subscriptionNumber;
                        rpp.ratePlanChargeReconciliations = new List<SingleReconciliationController.RatePlanChargeReconciliation>();
                        for (zqu__QuoteRatePlanCharge__c qrpc : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key)){
                            if (zrpw.ratePlanCharges != null){
                                for (SingleReconciliationController.ZuoraRatePlanChargeWrapper zrpcw : zrpw.ratePlanCharges){
//                                    System.debug(qrpc.Start_Date__c + ' ' + qrpc.End_Date__c + ' ' + zrpcw.effectiveStartDate + ' ' + zrpcw.effectiveEndDate);
                                    if ((!String.isEmpty(qrpc.Start_Date__c) && zrpcw.effectiveStartDate != null) && String.valueOf(zrpcw.effectiveStartDate) == qrpc.Start_Date__c && (qrpc.End_Date__c != null && zrpcw.effectiveEndDate != null) &&  zrpcw.effectiveEndDate == Date.valueOf(qrpc.End_Date__c) && qrpc.Custom_TCV_Formula__c == zrpcw.tcv){
                                        found = true;
                                        toRemove.add(zrpcw);
                                        qrpcToRemove.add(qrpc);
                                        System.debug('found by Start & End date: ' + qrpc + ' ' + zrpcw);
                                        rpp.ratePlanChargeReconciliations.add(new SingleReconciliationController.RatePlanChargeReconciliation(qrpc, zrpcw));
                                    }
                                }
                                for (SingleReconciliationController.ZuoraRatePlanChargeWrapper zrpcw : toRemove){
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
            for (SingleReconciliationController.ZuoraRatePlanWrapper zrpw : zsw.ratePlans){
                System.debug('Rate Plan On ZSub: ' + zrpw);
                if (qrpcByDateByRpcByQuote.containsKey(quoteNumber) && qrpcByDateByRpcByQuote.get(quoteNumber).containsKey(zrpw.productRatePlanId)){
                    for (String key : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).keySet()){
                        System.debug('PRP Id: ' + key);
                        Boolean found = false;
                        SingleReconciliationController.RatePlanReconciliation rpp = new SingleReconciliationController.RatePlanReconciliation();
                        rpp.subNumber = zsw.subscriptionNumber;
                        rpp.name = zrpw.ratePlanName;
                        rpp.ratePlanChargeReconciliations = new List<SingleReconciliationController.RatePlanChargeReconciliation>();

                        for (zqu__QuoteRatePlanCharge__c qrpc : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key)){
                            for (SingleReconciliationController.ZuoraRatePlanChargeWrapper zrpcw : zrpw.ratePlanCharges){
                                Integer len = Math.min(qrpc.Name.length(), zrpcw.name.length());
                                if ((!String.isEmpty(qrpc.Start_Date__c) && zrpcw.effectiveStartDate != null) && String.valueOf(zrpcw.effectiveStartDate) == qrpc.Start_Date__c && (qrpc.End_Date__c != null && zrpcw.effectiveEndDate != null) &&  zrpcw.effectiveEndDate == Date.valueOf(qrpc.End_Date__c)){
                                    found = true;
                                    toRemove.add(zrpcw);
                                    qrpcToRemove.add(qrpc);
                                    System.debug('found by Start date & Name: ' + qrpc + ' ' + zrpcw);
                                    rpp.ratePlanChargeReconciliations.add(new SingleReconciliationController.RatePlanChargeReconciliation(qrpc, zrpcw));
                                }
                            }
                            for (SingleReconciliationController.ZuoraRatePlanChargeWrapper zrpcw : toRemove){
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
            for (SingleReconciliationController.ZuoraRatePlanWrapper zrpw : zsw.ratePlans){
                System.debug('Rate Plan On ZSub: ' + zrpw);
                if (qrpcByDateByRpcByQuote.containsKey(quoteNumber) && qrpcByDateByRpcByQuote.get(quoteNumber).containsKey(zrpw.productRatePlanId)){
                    for (String key : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).keySet()){
                        System.debug('PRP Id: ' + key);
                        Boolean found = false;
                        SingleReconciliationController.RatePlanReconciliation rpp = new SingleReconciliationController.RatePlanReconciliation();
                        rpp.subNumber = zsw.subscriptionNumber;
                        rpp.name = zrpw.ratePlanName;
                        rpp.ratePlanChargeReconciliations = new List<SingleReconciliationController.RatePlanChargeReconciliation>();

                        for (zqu__QuoteRatePlanCharge__c qrpc : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key)){
                            for (SingleReconciliationController.ZuoraRatePlanChargeWrapper zrpcw : zrpw.ratePlanCharges){
                                Integer len = Math.min(qrpc.Name.length(), zrpcw.name.length());
                                if ((!String.isEmpty(qrpc.Start_Date__c) && zrpcw.effectiveStartDate != null) && String.valueOf(zrpcw.effectiveStartDate) == qrpc.Start_Date__c && String.valueOf(zrpcw.effectiveStartDate) == qrpc.Start_Date__c && zrpcw.name.substring(0, len) == qrpc.Name.substring(0, len)){
                                    found = true;
                                    toRemove.add(zrpcw);
                                    qrpcToRemove.add(qrpc);
                                    System.debug('found by Start date & Name: ' + qrpc + ' ' + zrpcw);
                                    rpp.ratePlanChargeReconciliations.add(new SingleReconciliationController.RatePlanChargeReconciliation(qrpc, zrpcw));
                                }
                            }
                            for (SingleReconciliationController.ZuoraRatePlanChargeWrapper zrpcw : toRemove){
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
            for (SingleReconciliationController.ZuoraRatePlanWrapper zrpw : zsw.ratePlans){
                System.debug('Rate Plan On ZSub: ' + zrpw);
                if (qrpcByDateByRpcByQuote.containsKey(quoteNumber) && qrpcByDateByRpcByQuote.get(quoteNumber).containsKey(zrpw.productRatePlanId)){
                    for (String key : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).keySet()){
                        System.debug('PRP Id: ' + key);
                        Boolean found = false;
                        SingleReconciliationController.RatePlanReconciliation rpp = new SingleReconciliationController.RatePlanReconciliation();
                        rpp.subNumber = zsw.subscriptionNumber;
                        rpp.name = zrpw.ratePlanName;
                        rpp.ratePlanChargeReconciliations = new List<SingleReconciliationController.RatePlanChargeReconciliation>();

                        for (zqu__QuoteRatePlanCharge__c qrpc : qrpcByDateByRpcByQuote.get(quoteNumber).get(zrpw.productRatePlanId).get(key)){
                            for (SingleReconciliationController.ZuoraRatePlanChargeWrapper zrpcw : zrpw.ratePlanCharges){
                                Integer len = Math.min(qrpc.Name.length(), zrpcw.name.length());
                                if (zrpcw.name.substring(0, len) == qrpc.Name.substring(0, len)){
                                    found = true;
                                    toRemove.add(zrpcw);
                                    qrpcToRemove.add(qrpc);
                                    System.debug('found by Name date: ' + qrpc + ' ' + zrpcw);
                                    rpp.ratePlanChargeReconciliations.add(new SingleReconciliationController.RatePlanChargeReconciliation(qrpc, zrpcw));
                                }
                            }
                            for (SingleReconciliationController.ZuoraRatePlanChargeWrapper zrpcw : toRemove){
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
                        SingleReconciliationController.RatePlanReconciliation rpp = new SingleReconciliationController.RatePlanReconciliation();
                        rpp.name = qrpc.zqu__QuoteRatePlan__r.Name;
                        rpp.ratePlanChargeReconciliations = new List<SingleReconciliationController.RatePlanChargeReconciliation>();
                        rpp.ratePlanChargeReconciliations.add(new SingleReconciliationController.RatePlanChargeReconciliation(qrpc, new SingleReconciliationController.ZuoraRatePlanChargeWrapper()));
                        if (!rppByQuotes.containsKey(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Number__c)){
                            rppByQuotes.put(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Number__c, new List<SingleReconciliationController.RatePlanReconciliation>());
                        }
                        rppByQuotes.get(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Number__c).add(rpp);
                    }
                }
            }
        }
        List<DailyReconciliationReportInstance__c> instances = new List<DailyReconciliationReportInstance__c>();
        if (rppByQuotes != null){
            for (String key : rppByQuotes.keySet()){
                Boolean isValid = true;
                for (SingleReconciliationController.RatePlanReconciliation rpp : rppByQuotes.get(key)){
                    System.debug(rpp);
                    System.debug(rpp.charges);
                    for (SingleReconciliationController.ChargeWrapper chargeWrapper : rpp.charges){
                        isValid &= !chargeWrapper.isInvalid();
                    }
                }
                instances.add(new DailyReconciliationReportInstance__c(
                    Daily_Reconciliation_Report__c = report.Id,
                    Quote__c = quotesByNumbers.get(key),
                    Zuora_Subscription_Id__c = rppByQuotes.get(key).get(0).subNumber,
                    Is_Valid__c = isValid
                ));

            }
        }
        insert instances;


    }

    private static void getSubscriptions(){
        QueryString subString = new QueryString()
            .addSelect('*')
            .addWhere('CreatedDate = \'' + String.valueOf(Date.today().addDays(-1)).substringBefore(' ') + '\'')
            .addWhere('Subscription_Type__c != \'PS\' AND QuoteID__c != NULL')
            .addOrderBy('CreatedDate desc')
            .setFrom('Subscription');

        ZOQLHelper.AQuARequest req = new ZOQLHelper.AQuARequest(
            'csv',
            '1.0',
            'daily-reconciliation-request-' + Date.today().addDays(-1),
            'none',
            'true'
        );

        req.addQuery(new ZOQLHelper.QueryObject('subs', 'zoqlexport', subString.getQuery()));

        Http http = new Http();
        HttpResponse resp = http.send(req.getRequest(token));
        System.debug(resp.getBody());
        ZOQLHelper.AQuAResponse AQuAresponse = (ZOQLHelper.AQuAResponse) JSON.deserialize(resp.getBody(), ZOQLHelper.AQuAResponse.class);


        while (AQuAresponse.status != 'completed' && AQuAresponse.status != 'error'){
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:__Zuora_REST_Api/v1/batch-query/jobs/' + AQuAresponse.id);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + token.access_token);
            request.setMethod('GET');
            System.debug(request.getBody());
            AQuAresponse = (ZOQLHelper.AQuAResponse) JSON.deserialize(new Http().send(request).getBody(), ZOQLHelper.AQuAResponse.class);
            System.debug(AQuAresponse);
        }
        System.debug(AQuAresponse);
        if (AQuAresponse.status == 'error'){
            System.debug('failed');
            return;
        }

        searchResults = new Map<String, SingleReconciliationController.ZuoraSubscriptionWrapper>();
        List<Map<String, Object>> subs = AQuAresponse.getBatchByName('subs', token);

        quotesByNumbers = new Map<String, String>();
        quoteIds = new Set<Id>();
        for (Map<String, Object> sub : subs){
            HttpRequest TCVRequest = new HttpRequest();
            TCVRequest.setEndpoint('callout:__Zuora_REST_Api/v1/subscriptions/' + sub.get('Id'));
            TCVRequest.setMethod('GET');
            TCVRequest.setHeader('Authorization', 'Bearer ' + token.access_token);
            HttpResponse TCVResponse = new Http().send(TCVRequest);
            System.debug('tcvresp for ' + sub.get('Id') + ': ' + TCVResponse.getBody());
            SingleReconciliationController.ZuoraSubscriptionWrapper zsw = (SingleReconciliationController.ZuoraSubscriptionWrapper) JSON.deserialize(TCVResponse.getBody().replace('QuoteNumber__QT', 'QuoteNumber'), SingleReconciliationController.ZuoraSubscriptionWrapper.class);
            if (Test.isRunningTest()){
                zsw.QuoteID = testQuoteId;
                zsw.QuoteNumber = testQuoteNumber;
            } else {
                zsw.QuoteID = (String) sub.get('QuoteID__c');
            }

            System.debug(zsw);
            searchResults.put(zsw.subscriptionNumber, zsw);
            quotesByNumbers.put(zsw.QuoteNumber, zsw.QuoteId);
            if (zsw.QuoteId instanceof Id){
                quoteIds.add(zsw.QuoteId);
            }
        }
    }


}