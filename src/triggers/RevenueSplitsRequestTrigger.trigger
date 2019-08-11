/**
 * Created by klukawski on 12/14/18.
 */

trigger RevenueSplitsRequestTrigger on Revenue_Splits_Request__c (before insert, after insert) {
    if(Trigger.isBefore){
        Revenue_Splits_Settings__c settings = Revenue_Splits_Settings__c.getInstance();
        for(Revenue_Splits_Request__c req: Trigger.new){
            if(settings.Automation_Start_Date__c != null){
                if(req.Start_Date__c.daysBetween(settings.Automation_Start_Date__c) > 0){
                    req.addError('Start date before Automation Start date in Revenue Split Settings, request ignored');
                }
            }
        }
    } else {
        ZuoraRevenueSplitHelper.sendCallouts(Trigger.newMap.keySet());
    }
}