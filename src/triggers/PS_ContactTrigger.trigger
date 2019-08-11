/*******************************************************************************************************************
* Apex Trigger Name  : PS_ContactTrigger 
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------

* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
trigger PS_ContactTrigger on Contact (after insert,after update,before insert, before update) {
   

    //if(!System.isFuture()){ // commented to run the business hours.
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
            List<Contact> lstCon = new List<Contact>(); 
            Set<Id> ConId = new Set<Id>();
            Set<Id> contactIdSet = new Set<Id>();
            list<Contact> lstCont =  new list<Contact>();
            set<String> setEmailId =  new set<String>();
            list<Contact> lstdupCont = new list<Contact>();
            String managerId = DataValueMap__c.getInstance('PortalManagerProfileId').Data_Value__c;
            for(Contact c : Trigger.New){
            
                if(String.isEmpty(c.UAA_ID__c) || !c.Email.equals(c.UAA_ID__c)){
                    if((Trigger.isInsert && c.Source_of_Creation__c != 'JIT') || (Trigger.isUpdate && (c.Interact_with_Community__c != Trigger.oldMap.get(c.Id).Interact_with_Community__c && c.Interact_with_Community__c)))
                        c.UAA_ID__c = c.Email;
                }
                if(Trigger.isUpdate?c.Time_Zone__c != Trigger.oldMap.get(c.Id).Time_Zone__c:TRUE) {
                    //if(Trigger.isUpdate && c.Time_Zone__c != Trigger.oldMap.get(c.Id).Time_Zone__c){ 
                    
                    lstCon.add(c);
                }
                // Avoid Duplication of Contact Record Starts
                if(Trigger.isUpdate && (c.email != Trigger.oldMap.get(c.Id).email || (c.Interact_with_Community__c != Trigger.oldMap.get(c.Id).Interact_with_Community__c && c.Interact_with_Community__c))) lstdupCont.add(c);
                // Avoid Duplication of Contact Record Ends
                if(c.DPL_Status__c == 'Restricted' && 
                   Trigger.oldMap.get(c.Id).DPL_Status__c != c.DPL_Status__c){
                       contactIdSet.add(c.Id);
                   }
            }
            if(Trigger.isInsert && UserInfo.getProfileId()==managerId){
               /* Id acc= [Select Id,AccountId from User where Id=: UserInfo.getUserId() limit 1].accountId;
                for(Contact con:Trigger.new){
                    con.AccountId =  acc;
                } */
                PS_ContactTriggerHandler.updateContactAccount(Trigger.new);
            }
            
            // Avoid Duplication of Contact Record Starts
            if(PS_ContactTriggerHandler.check &&  Trigger.isInsert)
            {
                PS_ContactTriggerHandler.duplicationcheck(Trigger.new);
            }
            if(PS_ContactTriggerHandler.check &&  Trigger.isUpdate)
            {
                PS_ContactTriggerHandler.duplicationcheck(lstdupCont);
            }
            // Avoid Duplication of Contact Record Ends
            
            if(!lstCon.isEmpty()){
                PS_ContactTriggerHandler.populateBusinessHours(lstCon);
            }
            if(contactIdSet.size() > 0){
                PS_ContactTriggerHandler.deleteDiscussionRecordList(contactIdSet);
            }
            
        }
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            
            if(checkRecursive.runContactTrigger()){
                PS_ContactTriggerHandler.createPortalUser();
                List<contact> lstCont = new List<contact>();
                //AccountHelper.UpdateCaseCommentOnContact(Trigger.New);
                if(Trigger.isUpdate){
                    Map<Id,Contact> contactMap = new Map<Id,Contact>();
                    for(Contact con : Trigger.new){
                        if(con.BusinessHours__c != Trigger.oldMap.get(con.Id).BusinessHours__c){
                            contactMap.put(con.Id,con);                
                        }
                        if(con.MailingCountry != Trigger.oldMap.get(con.Id).MailingCountry){
                            lstCont.add(con);
                        }
                        
                    }
                    if(!contactMap.isEmpty()){
                        PS_ContactTriggerHandler.updateAssociatedCases(contactMap);
                    }
                    if(lstCont.size()>0){
                        // PS_ContactTriggerHandler.updateEmbargoCountry(lstCont);
                    }
                }
            }
        }
    //}
}