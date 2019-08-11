/**
 * Created on 13/02/2019.
 */

public with sharing class ZOQLHelper {

    public class TokenResponse {
        public String access_token;
        String token_type;
        Integer expires_in;
        String scope;
        String jti;
    }

    public static TokenResponse getSessionToken() {
        Http http = new Http();

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('callout:__Zuora_REST_Api/oauth/token');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('client_id={!$Credential.UserName}&client_secret={!$Credential.Password}&grant_type=client_credentials');

        String jsonResponseBody = '';

        HttpResponse res = http.send(req);
        jsonResponseBody = res.getBody();

        return (TokenResponse) JSON.deserialize(jsonResponseBody, TokenResponse.class);
    }

    public class AQuARequest {

        private String format;
        private String version;
        private String name;
        private String encrypted;
        private String useQueryLabels;
        private String partner = 'salesforce';
        private String project = UserInfo.getOrganizationId();
        private String dateTimeUtc = 'false';
        private List<QueryObject> queries;


        public AQuARequest(String format, String version, String name, String encrypted, String useQueryLabels){
            this.format = format;
            this.version = version;
            this.name = name;
            this.encrypted = encrypted;
            this.useQueryLabels = useQueryLabels;
            this.queries = new List<QueryObject>();
        }

        public AQuARequest addQuery(QueryObject query){
            this.queries.add(query);
            return this;
        }

        public AQuARequest addQueries (List<QueryObject> queries){
            this.queries.addAll(queries);
            return this;
        }

        public HttpRequest getRequest(TokenResponse token){
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:__Zuora_REST_Api/v1/batch-query/');
            req.setBody(JSON.serialize(this));
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + token.access_token);
            return req;
        }

    }

    public class QueryObject {
        private final String name;
        private final String type;
        private final String query;

        public QueryObject (String name, String type, String query){
            this.name = name;
            this.type = type;
            this.query = query;
        }

    }

    public class QueryResponse {
        public String name;
        public String query;
        public String status;
        public Integer recordCount;
        public String apiVersion;
        public String batchId;
        public String batchType;
        public String fileId;
    }

    public class AQuAResponse {
        public List<QueryResponse> batches;
        public String project;
        public String partner;
        public String name;
        public String id;
        public String version;
        public String format;
        public String status;
        public String encrypted;

        public List<Map<String, Object>> getBatchByName(String name, TokenResponse token){
            for (QueryResponse qr : batches){
                if (qr.name == name){
                    return getObjectListFromCsv(new Http().send(getFileRequest(qr.fileId, token)).getBody());
                }
            }
            return new List<Map<String, Object>>();
        }
    }

    public static List<Map<String, Object>> getObjectListFromCsv (String csv){
        String objectName = csv.substringBefore('.').trim();
        List<String> fieldNames = csv.substringBefore('\n').split(',');
        for (Integer i = 0; i < fieldNames.size(); i++ ){
            fieldNames[i] = fieldNames[i].remove(objectName + '.').trim();
        }
        List<Map<String, Object>> toReturn = new List<Map<String, Object>>();

        csv = csv.substringAfter('\n');

        while (!String.isEmpty(csv)){
            Map<String, Object> obj = new Map<String, Object>();
            List<String> current = csv.substringBefore('\n').split(',');
            Integer j = 0;
            for (Integer i = 0; i < fieldNames.size(); i++){
                String toPut = '';
                if(current[j].contains('"')){
                    do {
                        toPut += current[j];
                        j++;
                    } while (!current[j].contains('"'));
                } else {
                    toPut = current[j];
                }
                j++;
                obj.put(fieldNames[i], toPut.remove('"'));
            }
            csv = csv.substringAfter('\n');
            toReturn.add(obj);
        }
        return toReturn;
    }


    public static HttpRequest getFileRequest(String fileId, TokenResponse token){

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('callout:__Zuora_REST_Api/v1/file/' + fileId);
        req.setHeader('Authorization', 'Bearer ' + token.access_token);
        return req;

    }

    public class BillingPreview {
        public BillingPreview(String accountId, String assumeRenewal, String includingEvergreenSubscription, Date targetDate){
            this.accountId = accountId;
            this.assumeRenewal = assumeRenewal;
            this.includingEvergreenSubscription = includingEvergreenSubscription;
            this.targetDate = targetDate;
        }
        public String accountId;
        public String assumeRenewal;
        public String includingEvergreenSubscription;
        public Date targetDate;
    }

}