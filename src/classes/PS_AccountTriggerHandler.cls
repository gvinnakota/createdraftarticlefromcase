/*******************************************************************************************************************
* Apex Class Name  : Accounthandler
* Version          : 1.0
* Created Date     : 16 August 2017
* Function         : class is used to update case field Special_Handling_Instructions__c when case product eqauls 
                     Special_Handling_Instructions object product field which are related accounts
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Karthik.A.S               08/16/2017            intial version
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
public without sharing class PS_AccountTriggerHandler{
/***
Method Name : UpdateCase
Purpose : To update case field Special_Handling_Instructions__c when case product eqauls Special_Handling_Instructions object product field which are related accounts 
***/
    public static void UpdateCase(Map<Id,Account> accMap){
        try{
        list<case> caseUpdate= new list<Case>();
        Map<Id,Case> caseToUpdateMap = new Map<Id,Case>();
        Map<Id,List<Case>> accIdWithCaseMap = new Map<Id,List<Case>>();
        for(case cObj : [Select Id,Special_Handling__c, Special_Handling_Type__c,Special_Handling_Instructions__c,Products__c,AccountId,Account.Special_Handling__c from case where AccountId =:accMap.keySet()]){
            if(accIdWithCaseMap.containskey(cObj.AccountId)){
                accIdWithCaseMap.get(cObj.AccountId).add(cObj);
            }else{
                accIdWithCaseMap.put(cObj.AccountId, new list<case>{cObj});
            }
            cObj.Special_Handling_Type__c = cObj.Special_Handling__c;
            caseToUpdateMap.put(cObj.Id,cObj);
        }        
        for(Special_Handling_Instructions__c  splObj : [select id,Handling_Instructions__c,Account__r.Id ,Products__c,Account__c from Special_Handling_Instructions__c where Account__c in:accMap.keySet()]){
            if(!accIdWithCaseMap.isEmpty()){
                if(accIdWithCaseMap.containskey(splObj.Account__r.Id)){
                   for(case caseObj : accIdWithCaseMap.get(splObj.Account__r.Id)){
                       case cObj = caseToUpdateMap.get(caseObj.Id);
                        if(cObj.Products__c == splObj.Products__c){
                            cObj.Special_Handling_Instructions__c = splObj.Handling_Instructions__c;
                        }
                    }
                }
            }           
        }        
        if(!caseToUpdateMap.isEmpty()){
            Database.Update(caseToUpdateMap.values(),false);
        }
        }catch(Exception e){
                        ErrorLog.CreateER(e);
                        }
    }      
}