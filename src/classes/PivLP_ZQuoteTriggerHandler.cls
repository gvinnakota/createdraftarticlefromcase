public class PivLP_ZQuoteTriggerHandler extends TriggerHandler {
    protected override void beforeUpdate(){
        setZuoraAccountNumber();
    }

    protected override void beforeInsert(){
        setZuoraAccountNumber();
    }

    private void setZuoraAccountNumber(){
        //workaround for issue #167134
        Id defaultRecordTypeId = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
        Id amendmentRecordTypeId = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
        Id renewalRecordTypeId = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByDeveloperName().get('Renewal').getRecordTypeId();
        Set<String> zaccountIds = new Set<String>();
		for(zqu__Quote__c quote : (List<zqu__Quote__c>)Trigger.new) {
            if((quote.RecordTypeId == amendmentRecordTypeId || quote.RecordTypeId == renewalRecordTypeId || quote.RecordTypeId == defaultRecordTypeId) && !String.isBlank(quote.zqu__ZuoraAccountID__c) && String.isBlank(quote.zqu__Zuora_Account_Number__c)){
				//collect Z account ID
				zaccountIds.add(quote.zqu__ZuoraAccountID__c);
            }
        }

        if(!zaccountIds.isEmpty()){
            Map<String, Zuora__CustomerAccount__c> zAccountsByZID = new Map<String, Zuora__CustomerAccount__c>();
            for(Zuora__CustomerAccount__c zaccount : [select Id, Zuora__AccountNumber__c, Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where Zuora__Zuora_Id__c in :zaccountIds]){
                zAccountsByZID.put(zaccount.Zuora__Zuora_Id__c, zaccount);
            }
    
            for(zqu__Quote__c quote : (List<zqu__Quote__c>)Trigger.new) {
                if((quote.RecordTypeId == amendmentRecordTypeId || quote.RecordTypeId == renewalRecordTypeId|| quote.RecordTypeId == defaultRecordTypeId) && !String.isBlank(quote.zqu__ZuoraAccountID__c) && String.isBlank(quote.zqu__Zuora_Account_Number__c)){
                    //Populate account number from ID 
                    Zuora__CustomerAccount__c zaccount = zAccountsByZID.get(quote.zqu__ZuoraAccountID__c);               
                    if(zaccount != null && !String.isBlank(zaccount.Zuora__AccountNumber__c)) {
                        quote.zqu__Zuora_Account_Number__c = zaccount.Zuora__AccountNumber__c;
                    }
                }
            }
        }        
    }
}