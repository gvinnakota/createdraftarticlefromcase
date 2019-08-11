/*******************************************************************************************************************
* Apex Class Name  : PS_EntitlementTriggerHandler
* Test Class Name  : PS_EntitlementTriggerHandler_TC
* Version          : 1.0
* Created Date     : 01 August 2017
* Function         : class is used to decrement and increment Support_Exception_Cases__c field count on account
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Karthik.A.S               08/01/2017            intial version
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
public without sharing class PS_EntitlementTriggerHandler{
    /*this method is used to revoke case count on realted account */
    public static void countSupportExceptionGranted(List<Entitlement> lstEnt){
        try{
            Set<Id> setAccId = new Set<Id>();
            Map<Id,Account> accountsToBeUpdatedMap = new Map<Id,Account>();
            for(Entitlement e : lstEnt){
                setAccId.add(e.AccountId);
            }
            
            Map<Id, Account> mapAccToUpdate = new Map<Id, Account> ();
            Map<Id, Account> mapAccWithEnt = new Map<Id, Account>([Select Id, Support_Exceptions_Granted__c,
                                                                          Support_Exceptions_Rejected__c
                                                                   from Account
                                                                   where Id IN: setAccId]);
            String NotEntitled= DataValueMap__c.getInstance('Not Entitled').Data_Value__c;
            List<Case> lstCaseWithEnt = [Select id, AccountId, Resolution_Code__c, Status
                                         from Case
                                         WHERE Accountid IN: setAccId AND 
                                               EntitlementId IN: lstEnt AND 
                                               Status = 'Solved'];

            

            
            Map<Id, List<Case>> mapAccWithCase = new Map<Id, List<Case>>();
            Map<Id, Integer> accIdGrantedCountMap = new Map<Id, Integer>();
            Map<Id, Integer> accIdRejectedCountMap = new Map<Id, Integer>();
            for(Id accountId : mapAccWithEnt.keySet()){
                if(mapAccWithEnt.get(accountId).Support_Exceptions_Granted__c != NULL)
                    accIdGrantedCountMap.put(accountId, Integer.valueOf(mapAccWithEnt.get(accountId).Support_Exceptions_Granted__c));
                else
                    accIdGrantedCountMap.put(accountId,0);
                if(mapAccWithEnt.get(accountId).Support_Exceptions_Rejected__c != NULL)
                    accIdRejectedCountMap.put(accountId, Integer.valueOf(mapAccWithEnt.get(accountId).Support_Exceptions_Rejected__c));
                else
                    accIdRejectedCountMap.put(accountId,0);
            }
            for(Case c : lstCaseWithEnt){
                if(c.AccountId != NULL){
                    if(c.Resolution_Code__c == NotEntitled){
                        if(accIdRejectedCountMap.get(c.AccountId) != 0)
                            accIdRejectedCountMap.put(c.AccountId, accIdRejectedCountMap.get(c.AccountId) + 1);
                        else
                            accIdRejectedCountMap.put(c.AccountId, 1);
                    }
                    else if(c.Resolution_Code__c != NotEntitled){
                        if(accIdGrantedCountMap.get(c.AccountId) != 0)
                            accIdGrantedCountMap.put(c.AccountId, accIdGrantedCountMap.get(c.AccountId) + 1);
                        else
                            accIdGrantedCountMap.put(c.AccountId, 1);
                    }
                    if(!mapAccWithCase.containskey(c.AccountId)){
                        mapAccWithCase.put(c.AccountId, new List<Case>{c});
                    } else {
                        List<Case> temp = mapAccWithCase.get(c.AccountId);
                        temp.add(c);
                        mapAccWithCase.put(c.AccountId, temp);
                    }
                }
            }

            List<Account> updateAccountList = new List<Account>();
            for(Id accountId : mapAccWithCase.keySet()){
                Account accountRecord = mapAccWithEnt.get(accountId);
                if(accIdGrantedCountMap.containsKey(accountId))
                    accountRecord.Support_Exceptions_Granted__c = accIdGrantedCountMap.get(accountId);
                if(accIdRejectedCountMap.containsKey(accountId))
                    accountRecord.Support_Exceptions_Rejected__c = accIdRejectedCountMap.get(accountId);
                updateAccountList.add(accountRecord);
            }

            if(updateAccountList.size() > 0){
                update updateAccountList;
            }
        }catch(Exception e){ErrorLog.CreateER(e);
            System.debug('exception e-->'+e);
        }
    }
    /*This method is used to revoke case count on realted account */
    public static void countSupportExceptionRejected(List<Entitlement> lstEnt){
        try{
            Set<Id> setAccId = new Set<Id>();
            Map<Id,Account> accountsToBeUpdatedMap = new Map<Id,Account>();
            for(Entitlement e : lstEnt){
                setAccId.add(e.AccountId);
            }
            
            Map<Id, Account> mapAccToUpdate = new Map<Id, Account> ();
            Map<Id, Account> mapAccWithEnt = new Map<Id, Account>([Select Id, Support_Exceptions_Granted__c,
                                                                          Support_Exceptions_Rejected__c
                                                                   from Account
                                                                   where Id IN: setAccId]);
            String NotEntitled= DataValueMap__c.getInstance('Not Entitled').Data_Value__c;
            List<Case> lstCaseWithEnt = [Select id, AccountId, Resolution_Code__c, Status
                                         from Case
                                         WHERE Accountid IN: setAccId AND 
                                               EntitlementId IN: lstEnt AND 
                                               Status = 'Solved'];

            

            
            Map<Id, List<Case>> mapAccWithCase = new Map<Id, List<Case>>();
            Map<Id, Integer> accIdGrantedCountMap = new Map<Id, Integer>();
            Map<Id, Integer> accIdRejectedCountMap = new Map<Id, Integer>();
            for(Id accountId : mapAccWithEnt.keySet()){
                if(mapAccWithEnt.get(accountId).Support_Exceptions_Granted__c != NULL)
                    accIdGrantedCountMap.put(accountId, Integer.valueOf(mapAccWithEnt.get(accountId).Support_Exceptions_Granted__c));
                else
                    accIdGrantedCountMap.put(accountId,0);
                if(mapAccWithEnt.get(accountId).Support_Exceptions_Rejected__c != NULL)
                    accIdRejectedCountMap.put(accountId, Integer.valueOf(mapAccWithEnt.get(accountId).Support_Exceptions_Rejected__c));
                else
                    accIdRejectedCountMap.put(accountId,0);
            }
            for(Case c : lstCaseWithEnt){
                if(c.AccountId != NULL){
                    if(c.Resolution_Code__c == NotEntitled && accIdRejectedCountMap.get(c.AccountId) != 0){
                        accIdRejectedCountMap.put(c.AccountId, accIdRejectedCountMap.get(c.AccountId) - 1);
                    }
                    else if(c.Resolution_Code__c != NotEntitled && accIdGrantedCountMap.get(c.AccountId) != 0){
                        accIdGrantedCountMap.put(c.AccountId, accIdGrantedCountMap.get(c.AccountId) - 1);
                    }
                    if(!mapAccWithCase.containskey(c.AccountId)){
                        mapAccWithCase.put(c.AccountId, new List<Case>{c});
                    } else {
                        List<Case> temp = mapAccWithCase.get(c.AccountId);
                        temp.add(c);
                        mapAccWithCase.put(c.AccountId, temp);
                    }
                }
            }

            List<Account> updateAccountList = new List<Account>();
            for(Id accountId : mapAccWithCase.keySet()){
                Account accountRecord = mapAccWithEnt.get(accountId);
                if(accIdGrantedCountMap.containsKey(accountId))
                    accountRecord.Support_Exceptions_Granted__c = accIdGrantedCountMap.get(accountId);
                if(accIdRejectedCountMap.containsKey(accountId))
                    accountRecord.Support_Exceptions_Rejected__c = accIdRejectedCountMap.get(accountId);
                updateAccountList.add(accountRecord);
            }

            if(updateAccountList.size() > 0){
                update updateAccountList;
            }
        }catch(Exception e){ErrorLog.CreateER(e);
            System.debug('exception e-->'+e);
        }
    }
}