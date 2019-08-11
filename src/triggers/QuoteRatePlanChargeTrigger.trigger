trigger QuoteRatePlanChargeTrigger on zqu__QuoteRatePlanCharge__c (after insert, after update) {
	//new QuoteRatePlanTriggerHandler().run();
	new QuoteRatePlanChargeTriggerHandler().run();
}