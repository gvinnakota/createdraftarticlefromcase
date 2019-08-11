/******************************************************************************************************
* Apex Class Name  : ContactUpdateApexControllerL1
* Version          : 1.0
* Created Date     : 14 March 2017
* Function         : This Class has an invocable method which is used to Update the Contact Details that 
                     come from the Login Flow for L1 Profile
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
Soham Banerjee              03/14/2018                Intial version
*******************************************************************************************************/
public without sharing class ContactUpdateApexControllerL1 {
    @InvocableMethod
 /***
Method Name : updateContact
Purpose : invocable method which is used to Update the Contact Details that come from the Login Flow for L1 profile
***/   
    public static void updateContactL1(List<String> fieldValues){
        System.debug('String: ' + fieldValues[0]);
        Contact contactRecord = new Contact();
        for(String fieldValuePair : fieldValues[0].split('~')){
            if(('Id').equalsIgnoreCase(fieldValuePair.substringBefore('='))){
                contactRecord.Id = fieldValuePair.substringAfter('=');
                System.debug('Id: ' + contactRecord.Id);
            }
            else if(('MailingCountryCode').equalsIgnoreCase(fieldValuePair.substringBefore('='))){
                contactRecord.MailingCountryCode = fieldValuePair.substringAfter('=');
            }
            else if(('TermsAndConditions__c').equalsIgnoreCase(fieldValuePair.substringBefore('='))){
                if(fieldValuePair.substringAfter('=') == 'true')
                    contactRecord.TermsAndConditions__c = true;
            }
        }
        try{
            if(contactRecord.Id != NULL){
                contactRecord.Interact_with_Community__c = true;
                contactRecord.First_Time_Login__c = 'No';
                CheckRecursive.checkContact = false;
                update contactRecord;
                System.debug('contactRecord: ' + contactRecord);
            }
        }
        catch(Exception e){
            ErrorLog.CreateER(e);//Exception captured in Utility Class Errorlog
        }
    }
}