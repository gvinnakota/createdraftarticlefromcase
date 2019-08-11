/*******************************************************************************************************************
* Apex Class Name  : PS_SubscriptionTriggerHandler
* Test Class Name  : PS_SubscriptionTriggerHandler_TC
* Version          : 1.0
* Created Date     : 30 August 2017
* Function         : class is used to update entitlement status as expired when subcritpion status ="Cancelled"
                     class is used to update entitlement status as Active when subcritpion status ="active"

* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Karthik.A.S               08/30/2017            intial version
  Amit Kumar                         09/15/2017            intial version

* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
Public without sharing class PS_SubscriptionTriggerHandler{
    /* Method to Deactivate Entitlement */
    public static void InactiveEntitlement(list<Zuora__Subscription__c>inactivelst){
        Map<String,DataValueMap__c> dataValueMap = DataValueMap__c.getAll();
        String Expired = DataValueMap__c.getInstance('Expired').Data_Value__c;
        String active = DataValueMap__c.getInstance('Active').Data_Value__c;
        list<Entitlement>ent=[select id, StartDate,EndDate,Subscription__c,Status from Entitlement where Subscription__c in:inactivelst];
        list<Entitlement>entupprev= new list<Entitlement>();
        list<Entitlement>entupnext= new list<Entitlement>();
        if(!ent.isempty()){
            for(Zuora__Subscription__c Subcription :inactivelst){
                for(Entitlement entupdate:ent){                    
                    if((entupdate.startdate==system.today()||entupdate.startdate>system.today())&&entupdate.status!=Expired){                        
                        entupdate.startdate=system.today()-1;
                        entupdate.enddate=system.today()-1;    
                        entupnext.add(entupdate); 
                    }
                    else if((entupdate.startdate!=system.today()||entupdate.startdate<system.today())&&entupdate.status==active){
                        entupdate.startdate=system.today()-2;
                        entupdate.enddate=system.today()-2; 
                        entupprev.add(entupdate);
                    }
                }
            }
        }
        if(!entupprev.isempty()){
            try{
            update entupprev;
            }
            catch(Exception e){
             ErrorLog.CreateER(e);//Exception captured in Utility Class Errorlog
            }
        }
        if(!entupnext.isempty()){
            try{
            update entupnext;
            }
            catch(Exception e){
             ErrorLog.CreateER(e);//Exception captured in Utility Class Errorlog
            }
        }        
    }
    
     /* Method to Activate Entitlement */
    public static void activeEntitlement(list<Zuora__Subscription__c>activelst){
        Map<String,DataValueMap__c> dataValueMap = DataValueMap__c.getAll();
        String active = DataValueMap__c.getInstance('Active').Data_Value__c;
        list<Entitlement>ent=[select id, StartDate,EndDate,Subscription__c,Status from Entitlement where Subscription__c in:activelst];
        list<Entitlement>entupprev1= new list<Entitlement>();
        if(!ent.isempty()){
            for(Zuora__Subscription__c Subcription:activelst){
                for(Entitlement entupdate:ent){
                   if((entupdate.startdate!=system.today()||entupdate.startdate<system.today())&&entupdate.status!=active){
                       entupdate.startdate=system.today();
                       entupdate.enddate=Subcription.Zuora__SubscriptionEndDate__c;
                       entupprev1.add(entupdate);
                    }
                }
            }
        }
        if(!entupprev1.isempty()){
            try{
                update entupprev1;
            }
            
            catch(DMLException e){
                ErrorLog.CreateER(e);//Exception captured in Utility Class Errorlog
                for (Zuora__Subscription__c Zuora : activelst) {
                Zuora.addError('Subscription End Date Must Be Equal or greater than Today Date');
            }
         }
       }
    }    
}