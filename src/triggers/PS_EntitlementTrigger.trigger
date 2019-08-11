/*******************************************************************************************************************
* Trigger Name  : Entitlementtrigger
* Version          : 1.0
* Created Date     : 01 August 2017
* Function         : Trigger On Entitlement object
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Karthik.A.S               08/01/2017            intial version
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
trigger PS_EntitlementTrigger on Entitlement (after update) {
    
    list<Entitlement>entlistdec =new list<Entitlement>();
    list<Entitlement>entlistinc =new list<Entitlement>();    
    for(Entitlement entnew:trigger.new)
    {
       if(entnew.Support_Exception__c==false && trigger.oldMap.get(entnew.Id).Support_Exception__c==true){
           entlistdec.add(entnew);
       }
       if(entnew.Support_Exception__c==true && trigger.oldMap.get(entnew.Id).Support_Exception__c==false){       
           entlistinc.add(entnew);
       } 
    }
    if(!entlistdec.isempty()){
        //PS_EntitlementTriggerHandler.Revokecasecount(entlistdec);
        PS_EntitlementTriggerHandler.countSupportExceptionRejected(entlistdec);
    }
    if(!entlistinc.isempty()){
        //PS_EntitlementTriggerHandler.increasecasecount(entlistinc);
        PS_EntitlementTriggerHandler.countSupportExceptionGranted(entlistinc);
    }
    
}