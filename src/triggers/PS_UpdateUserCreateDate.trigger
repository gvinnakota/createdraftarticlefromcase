/*******************************************************************************************************************
* Apex TriggerName  : Update Created Date to a Custom Field.
* Version           : 1.0
* Created Date      : Oct 30 2018
* Function          : User Trigger
* Modification Log  :
*/

trigger PS_UpdateUserCreateDate on User (before insert) {

    for(user usr :Trigger.new){
           usr.User_Create_Date__c = Datetime.now();
    }

}