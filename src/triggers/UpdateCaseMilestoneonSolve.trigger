///////////////////////////////
//https://www.pivotaltracker.com/story/show/159511945
//Stolen and modified from https://help.salesforce.com/articleView?id=entitlements_milestones_trigger.htm&type=5
//to allow Milestones and First response time to be automatically set when a case is closed/resolved by specific profiles
//
//Test class:  MilestoneTest
//
//Revision History
//May 2019 - Created by Shane
//June 2019 - Shane Smalldon - Removed logic to only run for CSR and Sysadmin as business wants for CEs too
//////////////////////////////
trigger UpdateCaseMilestoneonSolve on Case (after update) {
    DateTime completionDate = System.now(); 
    List<Id> updateCases = new List<Id>();
    for (Case c : Trigger.new){
        //sun:Commented the slastartdate/SLA exist date check for now.
        //if (((c.isClosed == true)||(c.Status == 'Resovled'))&&((c.SlaStartDate 
        //                <= completionDate)&&(c.SlaExitDate == null)))
        if ((c.isClosed == true && Trigger.oldMap.get(c.Id).isClosed != true )||(c.Status == 'Resovled' && Trigger.oldMap.get(c.Id).Status != 'Resolved')){
                updateCases.add(c.Id);
        }
    }    
    if (updateCases.isEmpty() == false)
        milestoneUtils.completeMilestone(updateCases, 'First Response', completionDate);
   
}