/***************************************************************************************************************************
* Apex Class Name  : PS_TaskOwnerUpdate
* Test Class Name  : PS_TaskOwnerUpdateTC
* Version          : 1.0
* Created Date     : 12 September 2017
* Function         : class is used to update task owner name whenever case owner changes
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------------
* Richa Gupta               12/09/2017            intial version
* ------------------------------------------------------------------------------------------------------------------------
****************************************************************************************************************************/
public class PS_TaskOwnerUpdate {
    /*
     1.This method is used to update task owner name whenever case owner changes.
     2.If 'Task_Remains_with_Case__c' field is true then update task owner name if case owner has changed. 
    */
    
   public static void updateTaskOwner() 
    {
        Set<Id> relatedCaseIds = new Set<Id>(); 
        List<Task> taskToUpdate = new List<Task>();
        For(Task taskObj : (List<Task>) Trigger.new){
            if(taskObj.whatId != null && String.valueOf(taskObj.whatId).Startswith('500')){
                if(Trigger.isInsert && taskObj.Task_Remains_with_Case__c){
                        relatedCaseIds.add(taskObj.whatID);
                        taskToUpdate.add(taskObj);
                    }else if(Trigger.isUpdate){
                         Task oldTask = (Task) Trigger.OldMap.get(taskObj.Id);
                if((oldTask != null && taskObj.Task_Remains_with_Case__c != oldTask.Task_Remains_with_Case__c && taskObj.Task_Remains_with_Case__c)){
                    relatedCaseIds.add(taskObj.whatID);
                    taskToUpdate.add(taskObj);
                }
                }
            }     
        }
                   if(!relatedCaseIds.isEmpty()){
                       Map<Id,Case> relatedCaseRecordMap = new Map<Id,Case>([SELECT ID , ownerID FROM case where id =:relatedCaseIds]);
                       for(Task taskObj : taskToUpdate){
                           if(relatedCaseRecordMap.containsKey(taskObj.WhatId)){
                               String caseOwnerId =  relatedCaseRecordMap.get(taskObj.WhatId).OwnerID;
                               if(caseOwnerId.startsWith('005')){
                                   taskObj.OwnerId = relatedCaseRecordMap.get(taskObj.WhatId).OwnerID;
                               }
                           }
                       }
                   }               
        }

}