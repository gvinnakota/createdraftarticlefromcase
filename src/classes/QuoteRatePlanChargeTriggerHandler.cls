public class QuoteRatePlanChargeTriggerHandler {
    public void run(){
        if(Trigger.isInsert && Trigger.isBefore) onBeforeInsert();
        if(Trigger.isInsert && Trigger.isAfter) onAfterInsert();
        if(Trigger.isUpdate && Trigger.isAfter) onAfterUpdate();
    }

    public void onBeforeInsert(){
        setRollupTypes();
    }

    public void onAfterInsert(){
        setAmendmentDates();
        copyOverrides();
    }
    
    public void onAfterUpdate(){
        setAmendmentDates();
    }

    private void copyOverrides(){
        List<zqu__QuoteRatePlanCharge__c> newCharges = [
            SELECT Id, Product_Rate_Plan__r.zqu__Product__r.T_E_Percentage_Override__c,
                Product_Rate_Plan__r.zqu__Product__r.Overridden_T_E_Percentage__c,
                Overridden_T_E_Percentage__c, T_E_Percentage_Override__c
            FROM zqu__QuoteRatePlanCharge__c
            WHERE Id IN :Trigger.new
        ];
        for (zqu__QuoteRatePlanCharge__c qrpc : newCharges){
            qrpc.Overridden_T_E_Percentage__c = qrpc.Product_Rate_Plan__r.zqu__Product__r.Overridden_T_E_Percentage__c;
            qrpc.T_E_Percentage_Override__c = qrpc.Product_Rate_Plan__r.zqu__Product__r.T_E_Percentage_Override__c;
        }
        update newCharges;
    }

    private void setAmendmentDates(){
  		Set<Id> quoteRatePlanIds = collectLookupIds(Trigger.new, 'zqu__QuoteRatePlan__c');
        Map<Id, sObject> quoteRatePlansById = findAndCollectSObjectsById(zqu__QuoteRatePlan__c.SObjectType, quoteRatePlanIds, 
			new Set<String>{'zqu__QuoteAmendment__c'});
		Set<Id> quoteAmendmentIds = collectLookupIds(quoteRatePlansById.values(), 'zqu__QuoteAmendment__c');
        Map<Id, sObject> quoteAmendmentsById = findAndCollectSObjectsById(zqu__QuoteAmendment__c.SObjectType, quoteAmendmentIds, 
			new Set<String>{'zqu__Quote__r.zqu__StartDate__c', 'zqu__ContractEffectiveDate__c', 'zqu__CustomerAcceptanceDate__c', 'zqu__ServiceActivationDate__c'});
		Set<Id> quoteIds = collectLookupIds(quoteAmendmentsById.values(), 'zqu__Quote__c');
        Map<Id, sObject> quotesById = findAndCollectSObjectsById(zqu__Quote__c.SObjectType, quoteIds, new Set<String>{'zqu__StartDate__c'});
        
        Map<Id, zqu__QuoteAmendment__c> qamUpdatesById = new Map<Id, zqu__QuoteAmendment__c>();
        for(zqu__QuoteRatePlanCharge__c qrpc : (List<zqu__QuoteRatePlanCharge__c>)Trigger.new) {
            if(qrpc.zqu__QuoteRatePlan__c != null && quoteRatePlansById.containsKey(qrpc.zqu__QuoteRatePlan__c)) {
                zqu__QuoteRatePlan__c qrp = (zqu__QuoteRatePlan__c)quoteRatePlansById.get(qrpc.zqu__QuoteRatePlan__c);
                if(qrp.zqu__QuoteAmendment__c != null && quoteAmendmentsById.containsKey(qrp.zqu__QuoteAmendment__c)) {
                    zqu__QuoteAmendment__c qam = (zqu__QuoteAmendment__c)quoteAmendmentsById.get(qrp.zqu__QuoteAmendment__c);
                    boolean updateIt = false;
                    Date dt = qrpc.Start_Date_Display__c;
                    system.debug('**** 0921:qrpc.Name=' + qrpc.Name);
                    system.debug('**** 0921:dt='+dt);
                    if(dt == null){
                        dt = qam.zqu__Quote__r.zqu__StartDate__c;
	                    system.debug('**** 0921:qam.zqu__Quote__r.zqu__StartDate__c='+qam.zqu__Quote__r.zqu__StartDate__c);
                    }
                    if(qam.zqu__ContractEffectiveDate__c == null) {
                        qam.zqu__ContractEffectiveDate__c = dt;
                        updateIt = true;
                    }
                    if(qam.zqu__CustomerAcceptanceDate__c == null) {
                        qam.zqu__CustomerAcceptanceDate__c = dt;
                        updateIt = true;
                    }
                    if(qam.zqu__ServiceActivationDate__c == null) {
                        qam.zqu__ServiceActivationDate__c = dt;
                        updateIt = true;
                    }
                    if(updateIt) qamUpdatesById.put(qam.ID, qam);
                }                
            }
        }
        
        system.debug('**** 0921:qamUpdatesById.size=' + qamUpdatesById.size());
        system.debug('**** 0921:qamUpdatesById=' + qamUpdatesById);
        update qamUpdatesById.values();
    }

    public void setRollupTypes(){
        for(zqu__QuoteRatePlanCharge__c qrpc: (List<zqu__QuoteRatePlanCharge__c>)Trigger.new){
            if(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.RecordType.Name == 'Renewal'){
                qrpc.Rollup_Type__c = 'Renewal';
            } else {
                qrpc.Rollup_Type__c = 'New';
            }
        }
    }

    public Map<Id, sObject> findAndCollectSObjectsById(SObjectType sobjType, Set<Id> ids, Set<String> fieldsToQuery){
        return new Map<Id, sObject>(
            Database.query(buildQuery(sobjType, fieldsToQuery))
        );
    }

    private String buildQuery(SObjectType sobjType, Set<String> fieldsToQuery){
        return 'select Id,' + String.join(new List<String>(fieldsToQuery), ',') + ' from ' + sobjType.getDescribe().getName() + ' where Id in :ids';
    }

    public Set<Id> collectLookupIds(List<sObject> sobjsList, String lookupFieldName) {
        Set<Id> ids = new Set<Id>();
        for(sObject sobj : sobjsList){
            Id lookupId = (Id)sobj.get(lookupFieldName);
            if(lookupId != null) ids.add(lookupId);
        }
        return ids;
    }
}