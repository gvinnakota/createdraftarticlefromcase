/******************************************************************************
Name                :    zAPI
Author              :    Reid Beckett, Launchpad
Description         :    Wrapper for Zuora SOAP API callouts
Date                :    10/05/2018
*******************************************************************************/
public class zAPI implements IzAPI {
    private Zuora.zApi api;
    
    public zAPI(){
        api = new Zuora.zApi();
        if(!Test.isRunningTest()) api.zlogin();
    }
    
    //wrap all Zuora.zApi methods
    public List<Zuora.zApi.SaveResult> zcreate(List<Zuora.zObject> zobjs){
        return !Test.isRunningTest() ? api.zcreate(zobjs) : null;                
    }

    public List<Zuora.zObject> zquery(String zoql){
        return !Test.isRunningTest() ? api.zquery(zoql) : null;                
    }

    public List<Zuora.zApi.SaveResult> zupdate(List<Zuora.zObject> zobjs){
        return !Test.isRunningTest() ? api.zupdate(zobjs) : null; 
    }
    
    public List<Zuora.zApi.DeleteResult> zdelete(String zType, List<String> zIds){
        return !Test.isRunningTest() ? api.zdelete(zType, zIds) : null;       
    }

    public List<Zuora.zApi.SubscribeResult> zsubscribe(List<Zuora.zApi.SubscribeRequest> subscribeRequests){
        return !Test.isRunningTest() ? api.zsubscribe(subscribeRequests) : null;
    }
    
    public List<zqu.zQuoteUtil.zBillingResult> sendToZBilling(List<zqu.zQuoteUtil.ZBillingQuoteCollection> quoteCollections){
        return zqu.zQuoteUtil.sendToZBilling(quoteCollections);
    }


}