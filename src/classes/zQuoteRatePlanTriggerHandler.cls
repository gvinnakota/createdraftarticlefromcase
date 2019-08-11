public class zQuoteRatePlanTriggerHandler extends TriggerHandler {
    
    public zQuoteRatePlanTriggerHandler() {}

    /* Context Overrides */

    protected override void beforeInsert(){
        popoulateProductRatePlan(Trigger.New);
    }
    
    public void popoulateProductRatePlan(List<zqu__QuoteRatePlan__c> qrpList){
        List<String> prpZIdsMissing = new List<String>();
        Map<String, Id> prpZIdToPrpSFId = new Map<String, Id>();
        for (zqu__QuoteRatePlan__c qrp : qrpList){
            if (qrp.zqu__ProductRatePlan__c == null){
                prpZIdsMissing.add(qrp.zqu__ProductRatePlanZuoraId__c);
            }
        }
        List<zqu__ProductRatePlan__c> prpList = [SELECT
                                                	zqu__ZuoraId__c,
                                                	Id
                                                FROM
                                                	zqu__ProductRatePlan__c
                                                WHERE
                                                	zqu__ZuoraId__c in :prpZIdsMissing];
        for (zqu__ProductRatePlan__c prp : prpList){
            prpZIdToPrpSFId.put(prp.zqu__ZuoraId__c, prp.Id);
        }
        
        for (zqu__QuoteRatePlan__c qrp : qrpList){
            if (qrp.zqu__ProductRatePlan__c == null){
                qrp.zqu__ProductRatePlan__c = prpZIdToPrpSFId.get(qrp.zqu__ProductRatePlanZuoraId__c);
            }
        }
    }
}