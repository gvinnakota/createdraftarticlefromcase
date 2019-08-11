/*******************************************************************************************************************
* Apex Class Name  : PS_SpecialHandlingTriggerhandler
* Test Class Name  : PS_SpecialHandlingTriggerhandler_Test 
* Version          : 1.0
* Created Date     : 16 August 2017
* Function         : class is used to update case field Special_Handling_Instructions__c when case product eqauls 
Special_Handling_Instructions object product field which are related accounts
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Karthik.A.S               08/16/2017            intial version
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
public without sharing class PS_SpecialHandlingTriggerhandler{
 /*Method to update case field Special_Handling_Instructions__c when case product eqauls 
Special_Handling_Instructions object product field which are related accounts*/   
    public static void updatecase(list<Special_Handling_Instructions__c>splhandling){
        set<id>splids=new set<id>();
        list<case>caseupdate= new list<Case>();
        for(Special_Handling_Instructions__c spl:splhandling){
            splids.add(spl.account__c);
        }
        System.debug('value in set'+splids);
        list<case>ca=[select id,Special_Handling_Instructions__c,Products__c,AccountId from case where Account.id in:splids];
        if(!ca.isempty()){
            for( Special_Handling_Instructions__c  spllist :splhandling){
                for(case casecheck: ca){
                    if(spllist.account__c==casecheck.accountid &&casecheck.Products__c==spllist.Products__c)
                    {
                        casecheck.Special_Handling_Instructions__c=spllist.Handling_Instructions__c;
                        caseupdate.add(casecheck);
                        
                    }
                }
            }
        }
        if(!caseupdate.isempty()){
        try{
             update caseupdate;
           }
        catch(Exception e){
             ErrorLog.CreateER(e);// Catches Exception in Utility Class ErrorLog
           }
      }
  }
}