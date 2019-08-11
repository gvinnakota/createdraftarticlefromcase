/*******************************************************************************************************************
* Trigger Name  : SpecialHandlingInstructionsTrigger 
* Version          : 1.0
* Created Date     : 16 August 2017
* Function         : Trigger On SpecialHandlingInstructions object
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Karthik.A.S               08/16/2017            intial version
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
trigger PS_SpecialHandlingInstructionsTrigger on Special_Handling_Instructions__c (after insert, after update) {
    list<Special_Handling_Instructions__c>spllistnew= new list<Special_Handling_Instructions__c>();
    list<Special_Handling_Instructions__c>spllistupdate= new list<Special_Handling_Instructions__c>();
    if(trigger.isinsert){
        for(Special_Handling_Instructions__c spl :trigger.new){
            spllistnew.add(spl);
        }
    }
    if(trigger.isupdate){
        for(Special_Handling_Instructions__c splupdate :trigger.new){
            
            if(trigger.oldmap.get(splupdate.id).Handling_Instructions__c!=splupdate.Handling_Instructions__c){
                spllistupdate.add(splupdate);
               }
        }
    }
    if(!spllistnew.isempty()){
        PS_SpecialHandlingTriggerhandler.updatecase(spllistnew);
        
    }
    if(!spllistupdate.isempty()){
        PS_SpecialHandlingTriggerhandler.updatecase(spllistupdate);
        
    }
    
    
    
    
}