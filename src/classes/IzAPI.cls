/******************************************************************************
Name                :    IzAPI
Author              :    Reid Beckett, Launchpad
Description         :    Interface for Zuora SOAP API callouts
Date                :    10/05/2018
*******************************************************************************/
public interface IzAPI {
    List<Zuora.zApi.SaveResult> zcreate(List<Zuora.zObject> zobjs);
    List<Zuora.zObject> zquery(String zoql);
    List<Zuora.zApi.SaveResult> zupdate(List<Zuora.zObject> zobjs);
    List<Zuora.zApi.DeleteResult> zdelete(String zType, List<String> zIds);
    List<Zuora.zApi.SubscribeResult> zsubscribe(List<Zuora.zApi.SubscribeRequest> subscribeRequests);
    List<zqu.zQuoteUtil.zBillingResult> sendToZBilling(List<zqu.zQuoteUtil.ZBillingQuoteCollection> quoteCollections);
}