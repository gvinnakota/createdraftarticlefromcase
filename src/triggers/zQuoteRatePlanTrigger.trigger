trigger zQuoteRatePlanTrigger on zqu__QuoteRatePlan__c (before insert) {
    new zQuoteRatePlanTriggerHandler().run();
}