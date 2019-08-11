/******************************************************************************
Name                :    PivLP_ZSOAPClient
Author              :    Reid Beckett, Launchpad
Description         :    Wrapper for Zuora SOAP API callouts
Date                :    09/14/2018
*******************************************************************************/
public class PivLP_ZSOAPClient {
    private static PivLP_ZSOAPClient instance;
    private zAPI zapiInstance;
    private zAPIMock zapiMockInstance;
    
    private IzAPI getAPIInstance(){
        return Test.isRunningTest() ? getMockZAPIInstance() : getRealZAPIInstance();
    }
    
    @TestVisible
    private IzAPI getRealZAPIInstance() {
        if(zapiInstance == null){
            zapiInstance = new zAPI();
        }
        return zapiInstance;
    }

    @TestVisible
    private IzAPI getMockZAPIInstance() {
        if(zapiMockInstance == null){
            zapiMockInstance = (zAPIMock)Test.createStub(zAPIMock.class, new zAPIMock());
        }
        return zapiMockInstance;
    }

    public static PivLP_ZSOAPClient getInstance() {
        if(instance == null) instance = new PivLP_ZSOAPClient();
        return instance;
    }
    
    public static String parseZuoraErrors(Zuora.zObject[] zuoraerrors){
        Zuora.zObject[] errors = zuoraerrors;
        List<String> messages = new List<String>();
        for (Zuora.zObject error : errors) {
            String errorCode = (String)error.getValue('Code');
            String message = (String)error.getValue('Message');
            messages.add(errorCOde + ':' + message);
        }
        return String.join(messages, ';');
    }
    
    public String zcreate(Zuora.zObject zobj){
        return zcreate(new List<Zuora.zObject>{ zobj }).get(0);
    }

    public List<String> zcreate(List<Zuora.zObject> zobjs){
		List<Zuora.zApi.SaveResult> results = getAPIInstance().zcreate(zobjs);        
        List<String> ids = new List<String>();
        for (Zuora.zApi.SaveResult result : results) {
            if (result.Success){
                ids.add(result.Id);
            } else {
                throw new PivLP_Exception('Error with response code: '+ parseZuoraErrors(result.errors));
            }
        }
        return ids;
    }

    public void zupdate(Zuora.zObject zobj){
        zupdate(new List<Zuora.zObject>{ zobj });
    }

    public void zupdate(List<Zuora.zObject> zobjs){
		List<Zuora.zApi.SaveResult> results = getAPIInstance().zupdate(zobjs);        
        for (Zuora.zApi.SaveResult result : results) {
            if (!result.Success){
                throw new PivLP_Exception('Error with response code: '+ parseZuoraErrors(result.errors));
            }
        }
    }

    public List<Zuora.zObject> zquery(String zoql){
        PivLP_Logger.debug('zquery:'+zoql);
        return getAPIInstance().zquery(zoql);
    }

    public Zuora.zApi.DeleteResult zdelete(String zType, String zId){
        return zdelete(zType, new List<String>{ zId }).get(0);
    }

    public List<Zuora.zApi.DeleteResult> zdelete(String zType, List<String> zIds){
		List<Zuora.zApi.DeleteResult> results = getAPIInstance().zdelete(zType, zIds);        
        for (Zuora.zApi.DeleteResult result : results) {
            if (!result.Success){
                throw new PivLP_Exception('Error with response code: '+ parseZuoraErrors(result.errors));
            }
        }
        return results;
    }
    
    public List<Zuora.zApi.SubscribeResult> zsubscribe(List<Zuora.zApi.SubscribeRequest> subscribeRequests){
        return getAPIInstance().zsubscribe(subscribeRequests);
    }

    public List<zqu.zQuoteUtil.zBillingResult> sendToZBilling(List<zqu.zQuoteUtil.ZBillingQuoteCollection> quoteCollections){
        return getAPIInstance().sendToZBilling(quoteCollections);
    }
}