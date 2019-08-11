//This class is executed from "UpdateAmendMetricsTrigger" and is used to populate the ProductRatePLanCharge on the Quote Charge Summary

public class ZQuoteChargeSummaryTriggerHandler extends TriggerHandler{
    
    public ZQuoteChargeSummaryTriggerHandler() {
    }
    
    protected override void beforeInsert() {
        populateProductRatePlanCharge(Trigger.new);
    }

    protected override void beforeUpdate() {
        populateProductRatePlanCharge(Trigger.new);
    }
    
    public void populateProductRatePlanCharge(List<zqu__QuoteChargeSummary__c> qrcList)
    {
        Set<ID> productRatePlanIdList = new Set<ID>();
        Map<String,Id> productRatePlanChargeIDMap = new Map<String,Id>();
        for(zqu__QuoteChargeSummary__c qcs : [Select Id,name, zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Id from zqu__QuoteChargeSummary__c where Id in : qrcList])
        {
            productRatePlanIdList.add(qcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Id);
        }
        for(zqu__ProductRatePlanCharge__c prpc : [Select Id,name, zqu__ProductRatePlan__r.id from zqu__ProductRatePlanCharge__c where zqu__ProductRatePlan__r.id in:productRatePlanIdList])
        {
            productRatePlanChargeIDMap.put(prpc.name,prpc.ID);
        }
        
        for (zqu__QuoteChargeSummary__c qrp : qrcList){
            if(!productRatePlanChargeIDMap.isEmpty() && productRatePlanChargeIDMap.containsKey(qrp.Name))
            {
                qrp.Product_Rate_Plan_Charge__c = productRatePlanChargeIDMap.get(qrp.Name);
            }
        }
    }
}