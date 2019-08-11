public with sharing class Z_CA_TriggerHandler {

	public void onBeforeInsert(List<Zuora__CustomerAccount__c> newCAs) {

		List<String> potentialContactIds = new List<String>();
		for (Zuora__CustomerAccount__c ca : newCAs){
			potentialContactIds.add(ca.CRM_Bill_To_Contact_Id__c);
			potentialContactIds.add(ca.CRM_Sold_To_Contact_Id__c);
		}

		Map<Id, Contact> existingContacts = new Map<Id, Contact>([
			SELECT Id FROM Contact WHERE Id IN :potentialContactIds
		]);

		for (Zuora__CustomerAccount__c ca : newCAs) {
			if (ca.CRM_Bill_To_Contact_Id__c != null && existingContacts.containsKey(ca.CRM_Bill_To_Contact_Id__c)) {
				ca.CRM_Bill_To_Contact__c = ca.CRM_Bill_To_Contact_Id__c; 
			}
			if (ca.CRM_Sold_To_Contact_Id__c !=null && existingContacts.containsKey(ca.CRM_Sold_To_Contact_Id__c)) {
				ca.CRM_Sold_To_Contact__c = ca.CRM_Sold_To_Contact_Id__c; 
			}
		}
	}

}