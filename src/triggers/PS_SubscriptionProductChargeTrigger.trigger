/*******************************************************************************************************************
* Apex Trigger Name  : PS_SubscriptionProductChargeTrigger
* Version          : 1.0
* Created Date     : 28 August 2017
* Function         : Trigger for  SubscriptionProductCharge object
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Karthik.A.S               08/28/2017            intial version
* Rohan M Kolvekar          28/03/2017            Updated the trigger to Update the entitlement whenever SPC Start date or end date is changed or whenever the SPC record is deleted 
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
trigger  PS_SubscriptionProductChargeTrigger on Zuora__SubscriptionProductCharge__c (after insert,after update,after delete) {
    list<Zuora__SubscriptionProductCharge__c>subinsert= new list<Zuora__SubscriptionProductCharge__c>();
    list<Zuora__SubscriptionProductCharge__c>subupdate= new list<Zuora__SubscriptionProductCharge__c>();
    String DatePattern = '^\\d{4}-\\d{2}-\\d{2}$'; /********* Added by Dilip ********/
    Pattern MyPattern = Pattern.compile(DatePattern);
    //  Create a master list to hold the emails
   Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
  List<String> sendTo = new List<String>();
  sendTo.add('amarshall@pivotal.io');
  sendTo.add('dweller@pivotal.io');
 set<id>recd= new set<id>();
//  sendTo.add('dchaulagain@pivotal.io');
   mail.setToAddresses(sendTo);
    mail.setSubject('Wrong format Start Date & End Date Error');
     String body = 'Record Ids ';
  boolean isError=false;
    if(trigger.isafter && trigger.isInsert)
    {
        for(Zuora__SubscriptionProductCharge__c  checkskuvalue : trigger.new){
            if(checkskuvalue.Zuora__ProductSKU_Product__c !=null&&checkskuvalue.Zuora__Account__c !=null && checkskuvalue.Start_Date__c!= null && checkskuvalue.End_Date__c != null){
               /********* Added by Dilip To handle Date format********/
                Matcher StartDateMatcher = MyPattern.matcher(checkskuvalue.Start_Date__c);
                Matcher EndDateMatcher = MyPattern.matcher(checkskuvalue.End_Date__c);
                Boolean StartDateResult = StartDateMatcher.matches();
                Boolean EndDateResult = EndDateMatcher.matches();  
                  
                if(StartDateResult!=true)
                {
                    
                   recd.add(checkskuvalue.id);
                    //checkskuvalue.Start_Date__c.AddError('Please enter Start Date in YYYY-MM-DD format.');
                   
                    isError=true;
                }
                if(EndDateResult!=true)
                {
                  //  checkskuvalue.End_Date__c.AddError('Please enter End Date in YYYY-MM-DD format.');
                     recd.add(checkskuvalue.id);
                     isError=true;
                }
                
                if(StartDateResult == true && EndDateResult == true)
                {
                     subinsert.add(checkskuvalue);
                }
                
                
               
            }
            
        }
        
        if(isError)
        
        {
            list<id>lst= new list<id>();
            lst.addAll(recd);
            string s1=string.join(lst,',');
            body= 'Record Id: '+s1;
              mail.setHtmlBody(body);
             Messaging.sendEmail( new List<Messaging.SingleEmailMessage>{mail});
             
        }
    }
    // WR #2259,#2260,#2261,#2262 Starts
    if(trigger.isafter && trigger.isUpdate)
    {
        for(Zuora__SubscriptionProductCharge__c  checkskuvalue : trigger.new){
            if(checkskuvalue.Zuora__ProductSKU_Product__c !=null&&checkskuvalue.Zuora__Account__c !=null && checkskuvalue.Start_Date__c!= null && checkskuvalue.End_Date__c != null && (checkskuvalue.Start_Date__c!=trigger.OldMap.get(checkskuvalue.id).Start_Date__c||checkskuvalue.End_Date__c!=trigger.OldMap.get(checkskuvalue.id).End_Date__c)){
                subupdate.add(checkskuvalue);
            }
            
        }
        
    }
   // WR #2259,#2260,#2261,#2262 Ends
    if(!subinsert.isempty()){
        PS_SubscriptionProductChargeHandler.Entitlementcreation(subinsert);
    }
    
    //WR #2259,#2260,#2261,#2262 Starts
    if(!subupdate.isempty()){
        PS_SubscriptionProductChargeHandler.Entitlementupdation(subupdate);
    }
    if(trigger.isafter && trigger.isDelete)
    {
        PS_SubscriptionProductChargeHandler.Entitlementupdation(trigger.old);
    }   
    //WR #2259,#2260,#2261,#2262 Ends
    
}