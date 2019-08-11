trigger ZuoraContactUpdateTrigger on Contact (after update) {
    if(!System.isFuture()){
        if (Trigger.new.size() == 1) {
            Contact ctct = Trigger.new[0];
            Contact oldcontact = Trigger.oldMap.get(ctct.Id);
            if( ctct.MailingStreet != oldcontact.MailingStreet || ctct.MailingCity != oldcontact.MailingCity || ctct.MailingCountryCode != oldcontact.MailingCountryCode || ctct.MailingPostalCode != oldcontact.MailingPostalCode || ctct.MailingStateCode != oldcontact.MailingStateCode || ctct.FirstName != oldcontact.FirstName || ctct.LastName != oldcontact.LastName || ctct.Email != oldcontact.Email || ctct.Phone != oldcontact.Phone ){
                ZuoraCalloutHandler.updateZuoraContacts(String.valueOf(ctct.Id), ctct.MailingStreet, ctct.MailingCity, ctct.MailingCountryCode, ctct.MailingPostalCode, ctct.MailingStateCode, ctct.FirstName, ctct.LastName, ctct.Email, ctct.Phone);
            }
            //List<Zuora__CustomerAccount__c> billToAccounts = [SELECT Id, Bill_To_Contact_Address__c FROM Zuora__CustomerAccount__c where CRM_Bill_To_Contact_Id__c = :ctct.Id];
            //List<Zuora__CustomerAccount__c> soldToAccounts = [SELECT Id, Sold_To_Contact_Address__c FROM Zuora__CustomerAccount__c where CRM_Sold_To_Contact_Id__c = :ctct.Id];
            //for (Zuora__CustomerAccount__c acct : billToAccounts) {
            //    acct.Bill_To_Contact_Address__c = ctct.MailingStreet+'\n '+ctct.MailingCity+', '+ctct.MailingStateCode+' '+ctct.MailingPostalCode+' '+ctct.MailingCountryCode;
            //}
            //update billToAccounts;
            //for (Zuora__CustomerAccount__c acct : soldToAccounts) {
            //    acct.Sold_To_Contact_Address__c = ctct.MailingStreet+'\n '+ctct.MailingCity+', '+ctct.MailingStateCode+' '+ctct.MailingPostalCode+' '+ctct.MailingCountryCode;
            //}
            //update soldToAccounts;
        }
    }
}