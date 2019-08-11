trigger QuoteAmendmentTrigger on zqu__QuoteAmendment__c (before update) {
    for(zqu__QuoteAmendment__c qam : Trigger.new) {
        zqu__QuoteAmendment__c oldQAM = Trigger.oldMap.get(qam.Id);
        if(oldQAM.zqu__ContractEffectiveDate__c != null && qam.zqu__ContractEffectiveDate__c  == null) {
            qam.zqu__ContractEffectiveDate__c = oldQAM.zqu__ContractEffectiveDate__c;
        }
        if(oldQAM.zqu__CustomerAcceptanceDate__c != null && qam.zqu__CustomerAcceptanceDate__c  == null) {
            qam.zqu__CustomerAcceptanceDate__c = oldQAM.zqu__CustomerAcceptanceDate__c;
        }
        if(oldQAM.zqu__ServiceActivationDate__c != null && qam.zqu__ServiceActivationDate__c  == null) {
            qam.zqu__ServiceActivationDate__c = oldQAM.zqu__ServiceActivationDate__c;
        }
    }
}