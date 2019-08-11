///////////////////////////////
//https://www.pivotaltracker.com/story/show/159511945
//Stolen and modified from https://help.salesforce.com/articleView?id=entitlements_milestones_trigger.htm&type=5
//to allow Milestones and First response time to be automatically set when a case is closed/resolved by specific profiles
//
//Test class:  MilestoneTest
//
//Revision History
//May 2019 - Created by Shane
//////////////////////////////
public class MilestoneUtils {
    public static void completeMilestone(List<Id> caseIds, 
            String milestoneName, DateTime complDate) {
                
    //update milestone
    List<CaseMilestone> cmsToUpdate = [select Id, completionDate
            from CaseMilestone cm
            where caseId in :caseIds and cm.MilestoneType.Name=:milestoneName 
            and completionDate = null];
    if (cmsToUpdate.isEmpty() == false){
        for (CaseMilestone cm : cmsToUpdate){
            cm.completionDate = complDate;
            }
        update cmsToUpdate;
        }
    
//todo - should this be put in a different method?
    
    //update First response time field
    List<Case> caseToUpdate = [select Id, First_Response_Time__c
            from case 
            where Id in :caseIds and First_Response_Time__c = null];
    if (caseToUpdate.isEmpty() == false){
        for (Case casefrt : caseToUpdate){
            casefrt.First_Response_Time__c = complDate;
            }
        update caseToUpdate;
        }
    }
}