trigger Z_CA_Trigger on Zuora__CustomerAccount__c (before insert, before update) {
    Z_CA_TriggerHandler handler = new Z_CA_TriggerHandler(); 
    if (trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            handler.onBeforeInsert(trigger.new);
        }        
    }
}