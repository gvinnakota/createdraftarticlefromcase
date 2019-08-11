/*******************************************************************************************************************
* Trigger Name  : Accounttrigger
* Version          : 1.0
* Created Date     : 16 August 2017
* Function         : Trigger On Account object
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Karthik.A.S               08/16/2017            intial version
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
trigger PS_AccountTrigger on Account (after update) {
Map<Id,Account> accountMap = new Map<Id,Account>();
 /* 
     Karthik.A.S :The below mentioned code not required as of now needto  delete this code before deployment if no changes occured on Request-490 
 */
 for(account acc:trigger.new){
   if( trigger.isUpdate && trigger.oldmap.get(acc.id).Special_Handling__c!=acc.Special_Handling__c){
        accountMap.put(acc.Id,acc);
   
   }
 }
 if(!accountMap.isempty()){
  PS_AccountTriggerHandler.updatecase(accountMap);
 
 }

}