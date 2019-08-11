/*******************************************************************************************************************
* Apex Trigger Name:  TaskOwnerUpdateTrigger
* Version          : 1.0
* Created Date     : 12 September 2017
* Function         : Trigger for Task object
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Richa Gupta               12/09/2017            intial version
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
trigger PS_TaskOwnerUpdateTrigger on Task (Before insert,Before update) {
    PS_TaskOwnerUpdate.updateTaskOwner();
       for (Task t : Trigger.new) {
          t.OldOwner__c= t.OwnerId;
        }
}