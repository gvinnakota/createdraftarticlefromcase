/**
 * Created on 07/02/2019.
 */

public without sharing class ReconciliationController {


    public String searchText {get;set;}
    public String searchResultTitle {get;set;}

    private ZOQLHelper.TokenResponse token;

    public List<ResultWrapper> searchResults {get;set;}
//    public Boolean searchUnsubmittedQuotes {get;set;}

    public Date startCreatedDate {get;set;}
    public Date endCreatedDate {get;set;}
    public Date startActivationDate {get;set;}
    public Date endActivationDate {get;set;}

    private QueryString quoteString;

    @TestVisible
    private String requestLabel;

    public ReconciliationController(){
        this.searchResultTitle = 'Recent Subscriptions';
        this.searchResults = new List<ResultWrapper>();

    }

    public Object loadRecent(){
        Object o = loadSearch();
        this.searchResultTitle = 'Recent Subscriptions';
        return o;
    }
    public Object loadSearch(){
        searchResults.clear();

        System.debug('Search Text: ' + searchText);
        System.debug('Start Activation Date: ' + startActivationDate);
        System.debug('End Activation Date: ' + endActivationDate);
        System.debug('Start Created Date: ' + startCreatedDate);
        System.debug('End Created Date: ' + endCreatedDate);

        QueryString subString = new QueryString()
            .addSelect('*')
//            .addSelect('Id')
//            .addSelect('Name')
//            .addSelect('SubscriptionStartDate')
//            .addSelect('CreatedDate')
            .addOrderBy('CreatedDate desc')
            .setLimit('100')
            .setFrom('Subscription');


//        if (searchUnsubmittedQuotes){
//            quoteString = new QueryString()
//                .addSelect('Id')
//                .addSelect('Name')
//                .addSelect('zqu__Number__c')
//                .addSelect('zqu__StartDate__c')
//                .addSelect('zqu__ZuoraEntityId__c')
//                .addOrderBy('zqu__StartDate__c desc')
////                .addWhere('zqu__Status__c != \'Sent to Z-Billing\'')
//                .setLimit('100')
//                .setFrom('zqu__Quote__c');
//        } else {
//            quoteString = null;
//        }



        if (!String.isEmpty(searchText)){
            String subQuoteNumbers = '';
            for (zqu__Quote__c q : [
                SELECT Id, zqu__Number__c FROM zqu__Quote__c WHERE Split_Parent_Quote__r.zqu__Number__c LIKE :searchText
            ]){
                subQuoteNumbers += 'QuoteNumber__QT LIKE \'%' + q.zqu__Number__c + '%\' OR ';
            }
            subQuoteNumbers = subQuoteNumbers.substringBeforeLast('OR');

            subString.addWhere('Name LIKE \'%' + searchText + '%\' OR Id LIKE \'' + searchText + '%\'' + ' OR QuoteNumber__QT LIKE \'%' + searchText + '%\'' + (!String.isEmpty(subQuoteNumbers) ? ' OR ' + subQuoteNumbers : ''));


//            if (searchUnsubmittedQuotes){
////                quoteString.addWhere('Name LIKE \'%' + searchText + '%\' OR zqu__Number__c LIKE \'%' + searchText + '%\'');
//                subString.addWhere('QuoteNumber__QT LIKE \'%' + searchText + '%\'');
//            }
        }

        if (startActivationDate != null){
            subString.addWhere('SubscriptionStartDate > \'' + String.valueOf(startActivationDate).substringBefore(' ') + '\'');
        }
        if (endActivationDate != null){
            subString.addWhere('SubscriptionStartDate < \'' + String.valueOf(endActivationDate).substringBefore(' ') + '\'');
        }
        if (startCreatedDate != null){
            subString.addWhere('CreatedDate > \'' + String.valueOf(Datetime.newInstance(startCreatedDate, Time.newInstance(0,0,0,0))).replace(' ', 'T') + '-00:00' + '\'');
        }
        if (endCreatedDate != null){
            subString.addWhere('CreatedDate < \'' + String.valueOf(Datetime.newInstance(endCreatedDate, Time.newInstance(0,0,0,0))).replace(' ', 'T') + '-00:00' + '\'');
        }

        this.token = ZOQLHelper.getSessionToken();
        System.debug('acctoken: ' + this.token.access_token);

        ZOQLHelper.AQuARequest request = new ZOQLHelper.AQuARequest(
            'csv',
            '1.0',
            'reconciliation-request-' + UserInfo.getUserId(),
            'none',
            'true'
        );

        request
            .addQuery(new ZOQLHelper.QueryObject('subs', 'zoqlexport', subString.getQuery()));

        System.debug(token);

        this.searchResultTitle = 'Search Results';
//        Continuation con = new Continuation(120);
//        con.ContinuationMethod = 'CallbackMethod';
//        this.requestLabel = con.addHttpRequest(request.getRequest(token));

        return CallbackMethod(new Http().send(request.getRequest(token)));
    }

    public Object CallbackMethod (HttpResponse resp) {

//        HttpResponse resp = Continuation.getResponse(this.requestLabel);
        System.debug(resp);
        System.debug('failed body: \n' + resp.getBody());
        ZOQLHelper.AQuAResponse AQuAresponse = (ZOQLHelper.AQuAResponse) JSON.deserialize(resp.getBody(), ZOQLHelper.AQuAResponse.class);
        System.debug(AQuAresponse);

        while (AQuAresponse.status != 'completed' && AQuAresponse.status != 'error'){
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:__Zuora_REST_Api/v1/batch-query/jobs/' + AQuAresponse.id);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + token.access_token);
            request.setMethod('GET');
            AQuAresponse = (ZOQLHelper.AQuAResponse) JSON.deserialize(new Http().send(request).getBody(), ZOQLHelper.AQuAResponse.class);
        }

        if (AQuAresponse.status == 'error'){
            return null;
        }

        this.searchResults = new List<ResultWrapper>();
        List<Map<String, Object>> subs = AQuAresponse.getBatchByName('subs', token);

        System.debug(subs);
        while (!subs.isEmpty()){
            searchResults.add(new ResultWrapper(subs.get(0)));
            subs.remove(0);
        }


        return null;
    }





    public class ResultWrapper {
        public String Name {get;set;}
        public String ZId {get;set;}
        public String ZNumber {get;set;}
        public String QuoteId {get;set;}
        public Date StartDate {get;set;}
        public Date EndDate {get;set;}
        public Decimal TCV {get;set;}

        public ResultWrapper(Map<String, Object> zObject){
            for (String s : zObject.keySet()){
                System.debug(s + ': ' + zObject.get(s));
            }
            this.ZNumber = (String) zObject.get('Name');
            this.Name = (String) zObject.get('QuoteNumber__QT');
            this.ZId = (String) zObject.get('Id');
            this.QuoteId = (String) zObject.get('QuoteID__c');
            this.StartDate = Date.valueOf(((String)zObject.get('SubscriptionStartDate') + ' 00:00:00'));

        }


    }

}