/*******************************************************************************************************************
* Apex Class Name  : PS_CaseTriggerHandler
* Test Class Name  : PS_CaseTriggerHandler_Test
* Version          : 1.0
* Created Date     : 16 August 2017
* Function         : class is used to update Case field Special_Handling_Instructions__c when Case product eqauls 
Special_Handling_Instructions object product field which are related accounts
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Karthik.A.S               08/16/2017            Intial version
* Karthik.A.S               08/29/2017            Added logic to increase support_Exceptions_Granted__c,Support_Exceptions_Rejected__c values on realted Account
* Richa Gupta               08/30/2017            Added logic to increase Support_Exceptions_Rejected__c value when Resolution Code equals Not-Entitled. 
* Karthik.A.S               09/01/2017            Added logic to update Special_Handling_Instructions__c when Case product is changed
* Richa Gupta               09/14/2017            Added logic to increase support_Exceptions_Granted__c value when Support Exception is true on Entitlement. 
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
public without sharing class PS_CaseTriggerHandler{
    /*This method is used update Case field Special_Handling_Instructions__c when Case product eqauls SpecialHandlingInstructions product*/
    public static boolean caseSloveRecursion=false; // Added by dilip to handle too many SOQL error while change the case status to solved 
    public static void updatecase(){
        try{
            
            Boolean matchFound = false;
            set<id>accountids=new set<id>();
            list<Case>caseupdate= new list<Case>();
            Map<Id,Case> caseMap = new Map<Id,Case>();
            Map<Id, List<Case>> accountCaseMap = new Map<Id,list<Case>>();
            
            for(Case caseobj: (List<Case>) Trigger.New){
                accountids.add(caseobj.accountid);
                Case oldCase = new Case();
                
                if(Trigger.isUpdate)
                    oldCase = (Case) Trigger.oldMap.get(caseobj.id);           
                
                if((Trigger.isInsert ? (caseobj.Products__c!=null) : (oldCase.Products__c != caseobj.Products__c))){
                    if(!accountCaseMap.containsKey(caseobj.accountid)){
                        accountCaseMap.put(caseobj.accountid,new list<Case>{caseObj});
                    }else{
                        accountCaseMap.get(caseobj.accountid).add(caseObj);
                    }
                }            
            }
            
            //added for performance turning
            if (!accountCaseMap.isEmpty()){
                for(Special_Handling_Instructions__c splHandling: [SELECT id,Handling_Instructions__c,Products__c,Account__c FROM Special_Handling_Instructions__c WHERE Account__c in:accountCaseMap.keySet()]){
                    
                    if(accountCaseMap.containsKey(splHandling.Account__c)){
                        for(Case caseObj : accountCaseMap.get(splHandling.Account__c)){                    
                            if(caseObj.Products__c!= null && splHandling.Products__c != null && caseObj.Products__c.contains(splHandling.Products__c)){
                                matchFound = true;                    
                                caseObj.Special_Handling_Instructions__c=splHandling.Handling_Instructions__c;                        
                            }
                            if(!matchFound){
                                caseObj.Special_Handling_Instructions__c = NULL;                       
                            }                    
                        }
                    }
                }
            }  
        }catch(Exception e){ErrorLog.CreateER(e);
        }
    }
    public static void ChangeAccount(list<Case> caseUpdated, Map<Id,Case> caseOldMap){
        Set<Id> accIdSet = new Set<Id>();
        Map<Id,Account> accountsToBeUpdatedMap = new Map<Id,Account>();
        for(Case caseObj : caseUpdated){
            accIdSet.add(caseObj.accountId);
            accIdSet.add(caseOldMap.get(caseObj.Id).AccountId);
        }
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, Support_Exceptions_Granted__c, Support_Exceptions_Rejected__c 
                                                           FROM Account
                                                           WHERE Id IN :accIdSet]);
        for(Case cObj : caseUpdated){
            Account newAccountRecord = accountMap.get(cObj.AccountId);
            Account oldAccountRecord = accountMap.get(caseOldMap.get(cObj.Id).AccountId);
            
            // Do a null Check for account - Sun 10/09/2018
            if (newAccountRecord != null ){
            
                if(cObj.Resolution_Code__c == 'Not Entitled'){
                    if(newAccountRecord.Support_Exceptions_Rejected__c == NULL){
                        newAccountRecord.Support_Exceptions_Rejected__c = 1;
                    }
                    else{
                        if(accountsToBeUpdatedMap.containsKey(newAccountRecord.Id)){
                            newAccountRecord.Support_Exceptions_Rejected__c = accountsToBeUpdatedMap.get(newAccountRecord.Id).Support_Exceptions_Rejected__c + 1;
                        }else{
                            newAccountRecord.Support_Exceptions_Rejected__c = newAccountRecord.Support_Exceptions_Rejected__c + 1;
                        }
                    }
                    
                    // Do a null Check for account - Sun 10/15/2018
                    if (oldAccountRecord != null)
                        oldAccountRecord.Support_Exceptions_Rejected__c -= 1;
                }
                else{
                    if(newAccountRecord.Support_Exceptions_Granted__c == NULL){
                        newAccountRecord.Support_Exceptions_Granted__c = 1;
                    }
                    else{
                        if(accountsToBeUpdatedMap.containsKey(newAccountRecord.Id)){
                            System.debug('Line#95');
                            newAccountRecord.Support_Exceptions_Granted__c = accountsToBeUpdatedMap.get(newAccountRecord.Id).Support_Exceptions_Granted__c + 1;
                        }else{
                            System.debug('Line#98');
                            newAccountRecord.Support_Exceptions_Granted__c = newAccountRecord.Support_Exceptions_Granted__c + 1;
                        }
                    }

                    // Do a null Check for account - Sun 10/15/2018
                    if (oldAccountRecord != null)
                        oldAccountRecord.Support_Exceptions_Granted__c -= 1;
                }
                
                accountsToBeUpdatedMap.put(newAccountRecord.Id, newAccountRecord);
                
               // Do a null Check for account - Sun 10/15/2018
               if (oldAccountRecord != null)               
                   accountsToBeUpdatedMap.put(oldAccountRecord.Id, oldAccountRecord);
            }
        }
        if(!accountsToBeUpdatedMap.isEmpty()){ 
            try{
                update accountsToBeUpdatedMap.values();
            }
            catch(Exception e){ErrorLog.CreateER(e); // Exception is captured in Utility class Errorlog
            }
        }
    }
    /* Method to Update Account and post a chatter */
    public static void afterInsertUpdateOperations(){
        system.debug('PS_CaseTriggerHandler.caseSloveRecursion---'+PS_CaseTriggerHandler.caseSloveRecursion);
            if (PS_CaseTriggerHandler.caseSloveRecursion != true) {
        List<Account> updateAccountList = new List<Account>();
        Set<id> accountIdSet = new Set<id>();
        Set<Id> caseIds = new Set<Id>();
        //To Do - first check if the Case is Solved
        //Second check if the Entitlement associated with it has Support_Exception__c as true
        //then update the Account's Support_Exceptions_Rejected__c & Support_Exceptions_Granted__c
        
        List<Case> caseToUpdate = new List<Case>();
        for(Case caseObj: (List<Case>)Trigger.New){ 
            /** Added by dilip to stop recursion of case and account tirgger*********/
             if(caseobj.Status == 'Solved')
             {
                 PS_CaseTriggerHandler.caseSloveRecursion = true;
             }
             
            system.debug('caseobj.Status--'+caseobj.Status);
            if(caseobj.Status == 'Solved' && Trigger.isInsert) 
            {
                accountIdSet.add(caseObj.accountId);
                
            }
            if(Trigger.isUpdate){
                Case oldCase = (Case) Trigger.OldMap.get(caseObj.Id);
                if(caseobj.AccountId == oldCase.AccountId && caseobj.Status == 'Solved') 
                {
                    PS_CaseTriggerHandler.caseSloveRecursion = true;
                    accountIdSet.add(caseObj.accountId);
                }
                if(caseObj.Status != oldCase.Status && oldCase.Status=='On Hold' && oldCase.Sub_Status__c == 'RPS Hold' && caseObj.Status == 'Open'){
                    caseIds.add(caseObj.Id);
                    
                }
            }
        }
        Set<Id> entitlementIdSet = new Set<Id>();
        //Logic to populate Special handling field on Case 
        if(Trigger.isAfter && !accountIdSet.isempty()){ 
            //Logic to increment Account Count for Rejected and Granted
            Map<Id,Account> accountMap= new Map<Id,Account>([SELECT Id, Support_Exceptions_Granted__c, Support_Exceptions_Rejected__c, 
                                                             (SELECT Id,Support_Exception__c 
                                                              FROM Entitlements
                                                              WHERE Support_Exception__c = true) 
                                                             FROM Account
                                                             WHERE Id IN :accountIdSet]);
            for(Id accId : accountMap.keySet()){
                for(Entitlement entRecord : accountMap.get(accId).Entitlements){
                    entitlementIdSet.add(entRecord.Id);
                }
            }
            Map<Id,Integer> accountIdGrantedCountMap = new Map<Id,Integer>();
            Map<Id,Integer> accountIdRejectedCountMap = new Map<Id,Integer>();
            for(Case ca : [SELECT Id, Status, EntitlementId, AccountId, Resolution_Code__c
                           FROM Case
                           WHERE AccountId IN :accountIdSet AND
                           EntitlementId IN :entitlementIdSet AND
                           Status = 'Solved']){
                               System.debug('ca.Resolution_Code__c: ' + ca.Resolution_Code__c);
                               if(ca.Resolution_Code__c == 'Not Entitled'){
                                   System.debug('Rejected');
                                   if(accountIdRejectedCountMap.containsKey(ca.AccountId))
                                       accountIdRejectedCountMap.put(ca.AccountId,accountIdRejectedCountMap.get(ca.AccountId)+ 1);
                                   else
                                       accountIdRejectedCountMap.put(ca.AccountId,1);
                               }
                               else{
                                   System.debug('Granted');
                                   if(accountIdGrantedCountMap.containsKey(ca.AccountId))
                                       accountIdGrantedCountMap.put(ca.AccountId,accountIdGrantedCountMap.get(ca.AccountId)+ 1);
                                   else
                                       accountIdGrantedCountMap.put(ca.AccountId,1);
                               }
                           }
            for(Id accId : accountMap.keySet()){
                Account accountRecord = accountMap.get(accId);
                if(accountIdRejectedCountMap.containsKey(accId))
                    accountRecord.Support_Exceptions_Rejected__c = accountIdRejectedCountMap.get(accId);
                else
                    accountRecord.Support_Exceptions_Rejected__c = 0;
                if(accountIdGrantedCountMap.containsKey(accId))
                    accountRecord.Support_Exceptions_Granted__c = accountIdGrantedCountMap.get(accId);
                else
                    accountRecord.Support_Exceptions_Granted__c = 0;
                updateAccountList.add(accountRecord); 
            }
            System.debug('updateAccountList: ' + updateAccountList);
            if(!updateAccountList.isempty()){
                try{
                    update updateAccountList;
                }catch(Exception e){ErrorLog.CreateER(e);// Exception is captured in Utility class Errorlog
                }
            }
        }
        
        if(!caseIds.isEmpty()){
            list<FeedItem> feedList = new list<FeedItem>();
            for(Id ids : caseIds){
                FeedItem feed = new FeedItem();
                feed.parentId = ids;
                feed.body = 'Contact cleared by Compliance.';
                feedList.add(feed);     
            }
            if(!feedList.isEmpty()){
                try{
                    insert feedList;
                }catch(Exception e){ErrorLog.CreateER(e); // Exception is captured in Utility class Errorlog
                }
            }
        }
            }
    }

    /*public static void beforeDeleteOperations(){
        System.debug('beforeDeleteOperations');
        Set<Id> accIdSet = new Set<Id>();
        Map<Id,Account> accountsToBeUpdatedMap = new Map<Id,Account>();
        for(Case caseObj : (List<Case>) Trigger.old){
            accIdSet.add(caseObj.accountId);
        }
        Map<Id,Account> accountMap = new Map<Id,Account>([SELECT Id, Support_Exceptions_Granted__c, Support_Exceptions_Rejected__c 
                                                          FROM Account
                                                          WHERE Id IN :accIdSet]);
        for(Case cObj : (List<Case>) Trigger.old){
            System.debug('cObj: ' + cObj);
            Account accountRecord = accountMap.get(cObj.AccountId);
            if(cObj.Resolution_Code__c == 'Not Entitled'){
                if(accountRecord.Support_Exceptions_Rejected__c != NULL){
                    if(accountsToBeUpdatedMap.containsKey(accountRecord.Id)){
                        accountRecord.Support_Exceptions_Rejected__c = accountsToBeUpdatedMap.get(accountRecord.Id).Support_Exceptions_Rejected__c - 1;
                    }else{
                        accountRecord.Support_Exceptions_Rejected__c = accountRecord.Support_Exceptions_Rejected__c - 1;
                    }
                }
            }
            else{
                if(accountRecord.Support_Exceptions_Granted__c != NULL){
                    System.debug('Line#238');
                    if(accountsToBeUpdatedMap.containsKey(accountRecord.Id)){
                        System.debug('Line#240');
                        accountRecord.Support_Exceptions_Granted__c = accountsToBeUpdatedMap.get(accountRecord.Id).Support_Exceptions_Granted__c - 1;
                    }else{
                        System.debug('Line#243');
                        accountRecord.Support_Exceptions_Granted__c = accountRecord.Support_Exceptions_Granted__c - 1;
                    }
                }
            }
            
            accountsToBeUpdatedMap.put(accountRecord.Id, accountRecord);
        }
        if(!accountsToBeUpdatedMap.isEmpty()){ 
            try{
                update accountsToBeUpdatedMap.values();
            }
            catch(Exception e){ErrorLog.CreateER(e); // Exception is captured in Utility class Errorlog
            }
        }
    }*/

    //@future
    /*Future Method to Update CaseMilestone*/
    public static void casesladatepopulate(set<id>ca){
        list<Case> listCaseToUpdate = new list<Case>();
        list<casemilestone> camile=[SELECT id,targetdate,caseid,Case.First_Response_Time__c , CompletionDate FROM casemilestone WHERE CaseId in:ca and iscompleted=false];
        list<CaseMilestone> updCM = new List<CaseMilestone>();
        if(!camile.isempty()){
            for(casemilestone cm:camile){
                Case caseObj = new Case(id=cm.caseId );
                System.debug('caseObj '+caseObj );
                System.debug('caseObj '+cm.Case.First_Response_Time__c );
                if(cm.Case.First_Response_Time__c==NULL){ 
                    caseObj.SLA_Target_date__c = cm.targetdate; //change as per new SLO design
                } else {
                    system.debug('FR: '+caseObj.First_Response_Time__c);
                    cm.CompletionDate = cm.Case.First_Response_Time__c; //change as per new SLO design
                    updCM.add(cm);
                }
                listCaseToUpdate.add(caseObj); 
                
            }
            if(!listCaseToUpdate.isEmpty()){
                try{
                    update listCaseToUpdate;
                }catch(Exception e){ErrorLog.CreateER(e); // Exception is captured in Utility class Errorlog
                }
            }
            if(!updCM.isEmpty()){
                try{
                    update updCM;
                    system.debug('CM :'+updCM);
                }catch(Exception e){
                    system.debug('CM :'+e);
                    ErrorLog.CreateER(e); // Exception is captured in Utility class Errorlog
                }
            }
        }
    }
    /*Creates post on the Case when the Case is created FROM EHSP support email-to-Case. */
    public static void postFeedonEhspCase()
    {
        List<FeedItem> newComment = new List<FeedItem>();
        String emailAlias = DataValueMap__c.getInstance('EHSP support').Data_Value__c;
        for(Case ca: (list<Case>)Trigger.new)
        {
            Case caOld = (Case)Trigger.OldMap.get(ca.Id);
            if (ca.InboundEmailAlias__c !=null && caOld.InboundEmailAlias__c != ca.InboundEmailAlias__c && ca.InboundEmailAlias__c==emailAlias)
            {
                FeedItem com = new FeedItem();
                com.ParentId = ca.Id;
                com.Type= 'TextPost';
                com.Body= Label.FeedPostForEhspSupport+'\n'+'\n'+ca.SendSafely_URL__c;
                com.Visibility= 'InternalUsers';
                newComment.add(com) ;
            }
        }
        if(!newComment.isEmpty())
        {
            try{
                Insert newComment;
            }
            Catch(Exception e){ErrorLog.CreateER(e); // Exception is captured in Utility class Errorlog
            }
        }
    }
    
    /* Reassign Task Ownwer */
    public static void ReassignTaskOwner()
    {
        Map<id,Case> changedOwnerCases = new Map<id,Case>();
        for (Case cas :(List<Case>) Trigger.new) {
            Case oldCase = (Case) Trigger.OldMap.get(cas.Id);
            if (cas.OwnerId<> oldCase.OwnerId) {
                changedOwnerCases.put(cas.id,cas);
            }
        }
        List<Task> restoreTaskOwner = new List<Task>();
        System.debug('changedOwnerCases:' + changedOwnerCases);
        // Find all the tasks that are not closed for these cases and revert them
        // //added for performance tuning
        if (!changedOwnerCases.isempty()){ 
            for(Task t : [SELECT Id, WhatId, OwnerId, OldOwner__c 
                      FROM Task
                      Where WhatId in : changedOwnerCases.keySet() AND IsClosed <> TRUE AND OldOwner__c <> null AND Task_Remains_with_Case__c=FALSE]) {
                          system.debug('t.OwnerId:' + t.OwnerId);
                          system.debug('t.OldOwner__c:' + t.OldOwner__c);
                          if (t.OwnerId <> t.OldOwner__c) {
                              t.OwnerId = t.OldOwner__c;
                              restoreTaskOwner.add(t);
                          }
                      }
        
        }
        System.debug('restoreTaskOwner:' + restoreTaskOwner);
        if (!restoreTaskOwner.isEmpty()) {
            update restoreTaskOwner;
        }
    }   
}