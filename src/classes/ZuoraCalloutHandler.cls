global class ZuoraCalloutHandler {
    @future(callout=true)
    public static void updateZuoraSubscription(String currentSubId, String ponumber, String channelSONumber){
        
        Zuora.zApi zApiInstance = new Zuora.zApi();
        if(!Test.isRunningTest()){
            zApiInstance.zlogin();
        }
        //query the Subscription with the subscription name with an Active status
        String zoql = 'Select OriginalId from subscription where Id=\'' + currentSubId + '\'';
        System.Debug('Querying subscription from Zuora : ' + zoql);
        List<Zuora.zObject> subscriptions = new List<Zuora.zObject>();
        try {
            if(!Test.isRunningTest()){
                subscriptions = zApiInstance.zquery(zoql);
            }else{
                subscriptions = ZAmendmentTest.dummyQueryResults();            
            }
        } 
        catch (Zuora.zAPIException e) {
            System.debug('Error in subscription query [' + zoql + '] ' + e);
            return;
        }

        System.Debug('Returning subscription ' + subscriptions);    
        String originalId = (String) subscriptions[0].getValue('OriginalId');

        zoql = 'Select Id from subscription where OriginalId=\'' + originalId + '\' and Status=\'Active\'';
        System.Debug('Querying subscription from Zuora : ' + zoql);
        subscriptions = new List<Zuora.zObject>();
        try {
            if(!Test.isRunningTest()){
                subscriptions = zApiInstance.zquery(zoql);
            }else{
                subscriptions = ZAmendmentTest.dummyQueryResults();            
            }
        } 
        catch (Zuora.zAPIException e) {
            System.debug('Error in subscription query [' + zoql + '] ' + e);
            return;
        }

        String subscriptionId = (String) subscriptions[0].getValue('Id');
                                                      
        Zuora.zObject sub = new Zuora.zObject('Subscription'); 
        sub.setValue('Id', subscriptionId);
        sub.setValue('PurchaseOrder__c', ponumber);
        sub.setValue('ChannelOrderID__c', channelSONumber);
        
        List < Zuora.zApi.SaveResult > results = null;

        if(!Test.isRunningTest()){
            results = zApiInstance.zupdate(new List<Zuora.zObject> {sub});
        } else {
            results = ZAmendmentTest.dummySaveResults();
        }
        System.debug('Zuora: ' + results[0]);
            
        // check for successful result
        if(results[0].success){
            // successful
        }else{
            // failure
            Zuora.zObject[] errors = results[0].errors;
            for (Zuora.zObject error : errors) {       
                system.debug('Error while updating Subscription record in Zuora.' +
                             ' Code: ' + error.getValue('Code') + 
                             ' Message: ' + error.getValue('Message'));
            }
        }    
    }

    @future(callout=true)
    public static void updateZuoraContacts(String id, String address, String city, String country, String postalCode, String state, String firstName, String lastName, String workEmail, String phone) {
        Zuora.zApi zApiInstance = new Zuora.zApi();
        if(!Test.isRunningTest()){
            zApiInstance.zlogin();
        }
        //query the Subscription with the subscription name with an Active status
        System.debug('id: '+id);
        String soldToZoql = 'Select Id, SoldToId from Account where CRM_Sold_To_Contact_Id__c=\'' + id + '\'';
        String billToZoql = 'Select Id, BillToId from Account where CRM_Bill_To_Contact_Id__c=\'' + id + '\'';
        //System.Debug('Querying subscription from Zuora : ' + zoql);
        List<Zuora.zObject> soldToContacts = new List<Zuora.zObject>();
        List<Zuora.zObject> billToContacts = new List<Zuora.zObject>();
        List<Zuora.zObject> contacts = new List<Zuora.zObject>();
        try {
            if(!Test.isRunningTest()){
                soldToContacts = zApiInstance.zquery(soldToZoql);
                billToContacts = zApiInstance.zquery(billToZoql);
            }else{
                soldToContacts = ZAmendmentTest.dummyQueryResults();
                billToContacts = ZAmendmentTest.dummyQueryResults();
            }
            for (Zuora.zObject contact : soldToContacts) {
                String contactId = (String) contact.getValue('SoldToId');                                
                Zuora.zObject soldToContact = new Zuora.zObject('Contact'); 
                soldToContact.setValue('Id', contactId);
                contacts.add(soldToContact);
            }
            for (Zuora.zObject contact : billToContacts) {
                String contactId = (String) contact.getValue('BillToId');                                
                Zuora.zObject billToContact = new Zuora.zObject('Contact'); 
                billToContact.setValue('Id', contactId);
                contacts.add(billToContact);
            }
        } 
        catch (Zuora.zAPIException e) {
            //System.debug('Error in contact query [' + zoql + '] ' + e);
            return;
        }

        List<Zuora.zObject> contactsToUpdate = new List<Zuora.zObject>();
        Integer counter = 0;
        List < Zuora.zApi.SaveResult > results = null;

        for (Zuora.zObject contact : contacts) {
            String contactId = (String) contact.getValue('Id');
            Zuora.zObject contactToUpdate = new Zuora.zObject('Contact'); 
            contactToUpdate.setValue('Id', contactId);
            contactToUpdate.setValue('Address1', address);
            contactToUpdate.setValue('City', city);
            contactToUpdate.setValue('Country', country);
            contactToUpdate.setValue('PostalCode', postalCode);
            contactToUpdate.setValue('State', state);
            contactToUpdate.setValue('FirstName', firstName);
            contactToUpdate.setValue('LastName', lastName);
            contactToUpdate.setValue('WorkEmail', workEmail);
            contactToUpdate.setValue('HomePhone', phone);

            if (counter < 50){
                contactsToUpdate.add(contactToUpdate);
                counter++;
                continue;
            } else {
                counter = 0;
                if(!Test.isRunningTest()){
                    results = zApiInstance.zupdate(contactsToUpdate);
                } else {
                    results = ZAmendmentTest.dummySaveResults();
                }
                contactsToUpdate = new List<Zuora.zObject>();
            }
        }
        if (contactsToUpdate.size() > 0) {
            if(!Test.isRunningTest()){
                results = zApiInstance.zupdate(contactsToUpdate);
            } else {
                results = ZAmendmentTest.dummySaveResults();
            }
        }

    }

}