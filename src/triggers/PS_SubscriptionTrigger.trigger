/*******************************************************************************************************************
* Apex Trigger Name  :  Subscriptiontrigger
* Version          : 1.0
* Created Date     : 28 August 2017
* Function         : Trigger for Subscription(Zuora__Subscription__c) object
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Karthik.A.S               08/28/2017            intial version

    Amit                    09/15/2017            intial version
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
trigger PS_SubscriptionTrigger on Zuora__Subscription__c (after insert,After update) {
    list<Zuora__Subscription__c>inactiveSubscriptions = new list<Zuora__Subscription__c>();
      list<Zuora__Subscription__c>activeSubscriptions = new list<Zuora__Subscription__c>();
    if(trigger.isupdate&&trigger.isafter){
        for(Zuora__Subscription__c  inactivecheck :trigger.new){
            
            if(inactivecheck.Zuora__Status__c=='Cancelled'&& trigger.oldMap.get(inactivecheck.Id).Zuora__Status__c!='Cancelled'){
                
                inactiveSubscriptions.add(inactivecheck);
            }
            
        }
    }
   /* Commented as the part of WR #2259,#2260,#2261,#2262 Starts
   if(trigger.isupdate&&trigger.isafter){
        for(Zuora__Subscription__c  activecheck :trigger.new){
            
            if(activecheck.Zuora__Status__c=='active'&& trigger.oldMap.get(activecheck.Id).Zuora__Status__c!='active'){
                
                activeSubscriptions.add(activecheck);
            }
            
        }
    } */
    if(!inactiveSubscriptions.isempty()){
        PS_SubscriptionTriggerHandler.InactiveEntitlement(inactiveSubscriptions);
        
    }
   /* Commented as the part of WR #2259,#2260,#2261,#2262 Starts
   if(!activeSubscriptions.isempty()){
        PS_SubscriptionTriggerHandler.activeEntitlement(activeSubscriptions); 
        
    } */
    if(trigger.isinsert&&trigger.isafter){
        PS_SubscriptionTriggerHandler.InactiveEntitlement(Trigger.new);
        
    }
    
    
    if(trigger.isinsert&&trigger.isafter){
        PS_SubscriptionTriggerHandler.activeEntitlement(Trigger.new);
        
    }    
}