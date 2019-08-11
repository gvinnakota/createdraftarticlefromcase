/*******************************************************************************************************************
* Apex Class Name  : UpdateCase 
* Test Class Name  : UpdateCase _Test
* Version          : 1.0
* Function         : 
* Modification Log :
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Richa Gupta
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
public without sharing class UpdateCase {
    public String caseId {get;set;}
    public user usr {get;set;}
    case caseObj;
/* constructor : UpdateCase
   purpose     : to get user Id, user ContactId and user profileId */    
    public UpdateCase(ApexPages.StandardController controller) {        
        caseObj = (Case)controller.getRecord();
        caseId = caseObj.Id;
        usr = [Select ID, ContactId, ProfileId from user where id=:userinfo.getUserID()];
            
                 
    }
/* Method     : getResponse
   return type : Void */   
    public void getResponse()
    {
        try{
        caseObj.Requestupdate__c= true;
        update caseObj;
        }catch(Exception e){
                        ErrorLog.CreateER(e);
                        }
    }
    
/* method : getRequestEscalateResponse
   return type : void  */   
    public  void getRequestEscalateResponse(){
        
    }
/* method : getEscalateResponse
   purpose : to update the case  */     
    @AuraEnabled
    public static void getEscalateResponse(Id caseRecordId){
        try{
        if(caseRecordId != NULL){
            System.debug('caseRecordId: ' + caseRecordId);
            List<Case> caseRecordList = [SELECT Status, Escalation_Management_Escalation__c 
                                         FROM Case 
                                         WHERE Id =: caseRecordId
                                         LIMIT 1];
            if(caseRecordList != NULL && caseRecordList.size() > 0){
/* caseRecordList[0].Status = 'Escalated';
                caseRecordList[0].Escalation_Management_Escalation__c = true; */
                update caseRecordList;
            }
        }
        }catch(Exception e){
                        ErrorLog.CreateER(e);
                        }
    } 
}