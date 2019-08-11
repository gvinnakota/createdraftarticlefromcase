/*******************************************************************************************************************
* Apex trigger : CaseTrigger
* Version          : 1.0
* Created Date     : 16 August 2017
* Function         : 
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Karthik.A.S               08/16/2017            intial version
  Hemavathi N M             09/04/2017            Added logic to restirct user modify closed case. 
  Deepa Lakamanhalli        11/07/2017            Updated the logic to populate SLO Target Date based on Entitlement, Severity, Contact
  Sun Nathan                11/01/2018            161638636 - Change bypassModifyClosedCase to always allow Administrators to modify closed cases
* * --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
trigger PS_CaseTrigger on Case (after insert,after update,before insert, before update) {
/********* To Restrict user from Modifying Closed Case : Code Start**********/
         if(trigger.isBefore && trigger.isUpdate){ 
        String errorMessage = DataValueMap__c.getInstance('ErrorOnCloseCaseUpdate').Data_Value__c;
        String bypassModifyClosedCase= DataValueMap__c.getInstance('bypassModifyClosedCase').Data_Value__c;
        String systemAdministratorProfileId= DataValueMap__c.getInstance('SystemAdministratorProfileId').Data_Value__c;
        for (Case caseobj: Trigger.new) {
            if(trigger.oldmap.get(caseobj.id).Status=='Closed' && bypassModifyClosedCase == 'false' && userinfo.getProfileId() != systemAdministratorProfileId){
                caseObj.addError(errorMessage);
            }         
        }
    }
    
    if(trigger.isBefore && (trigger.isUpdate||trigger.isInsert)){
        for (Case caseobj: Trigger.new) {
             caseobj.Special_Handling_Type__c = caseobj.Special_Handling__c;
             caseobj.Email_to_case_Test__c = caseobj.Email_to_Case_Origin__c;
        }
    }
    
        
/********* To Restrict user from Modifying Closed Case : Code End**********/
       
    if(trigger.isafter &&(trigger.isInsert || trigger.isUpdate) ){
        PS_CaseTriggerHandler.afterInsertUpdateOperations();
    }
    if(trigger.isafter &&trigger.isInsert){
        set<id> caseids=new set<id>();
        list<case> caselst=new list<Case>();
        for(case ca:trigger.new){
            //String Recordtype = Label.nontechnical;
            if(!ca.PCN_Check__c){
                caseids.add(ca.id);
            }/*
            if(ca.recordtypeid==Recordtype){          
                caselst.add(ca);
            }*/
            // Commented by Sun to include the SLO Time irrespective of Entitlemnent id.
            //if(ca.EntitlementId == NULL){ //As per new change SLO
                caselst.add(ca);
            //}
        }
        if(!caseids.isEmpty()){
            PS_CaseTriggerHandler.casesladatepopulate(caseids);
        }
        if(!caselst.isempty()){
            PS_CaseBusinessHours.setCaseSLATargetDate(caselst);
        }
    }
    
    if(trigger.isafter && trigger.isupdate ){
        List<case> listCaseUpdated = new List<Case>();
        List<case> lstCaseUpdSLO = new List<Case>();
        Set<Id> setCaseIdUpd = new Set<Id>();
        for (Case caseobj: Trigger.new) {  
            Case oldCase = Trigger.oldMap.get(caseobj.ID);
            if(caseobj.AccountId != oldCase.AccountId) {
                listCaseUpdated.add(caseobj);
            }
            if(caseobj.EntitlementId == NULL && (oldCase.Priority!= caseobj.Priority || oldCase.BusinessHoursId!= caseobj.BusinessHoursId)){
                lstCaseUpdSLO.add(caseobj); //As per new change SLO
            }
            else if(caseobj.EntitlementId != NULL && (oldCase.Priority!= caseobj.Priority || oldCase.BusinessHoursId != caseobj.BusinessHoursId 
            || caseobj.EntitlementId != oldCase.EntitlementId)){ //As per new change SLO
                setCaseIdUpd.add(caseobj.Id);
            }
        }
        if(!listCaseUpdated.isempty()){
            PS_CaseTriggerHandler.ChangeAccount(listCaseUpdated,Trigger.oldMap);
        }
        if(!lstCaseUpdSLO.isEmpty()){ //As per new change SLO
            PS_CaseBusinessHours.setCaseSLATargetDate(lstCaseUpdSLO);
        }
        if(!setCaseIdUpd.isEmpty()){ //As per new change SLO
            PS_CaseTriggerHandler.casesladatepopulate(setCaseIdUpd);
        }
        
        PS_CaseTriggerHandler.postFeedonEhspCase();
    }
    
    if(trigger.isbefore && (trigger.isInsert || trigger.isUpdate)){
        PS_CaseTriggerHandler.updatecase();
    }
     /* Reassign Task Ownwer */
    if(trigger.isAfter &&  trigger.isUpdate)
    {
        PS_CaseTriggerHandler.ReassignTaskOwner();
    }  
     /* Reassign Task Ownwer */ 
    

      
}