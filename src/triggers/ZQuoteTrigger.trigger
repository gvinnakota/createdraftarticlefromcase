trigger ZQuoteTrigger on zqu__Quote__c (after insert, before update, before insert) {
    new ZQuoteTriggerHandler().run();
    if(Trigger.isBefore){
	    new PivLP_ZQuoteTriggerHandler().run();
    }
}