/******************************************************************************************************
* Apex Class Name  : ContactUpdateApexController
* Version          : 1.0
* Created Date     : 8 March 2017
* Function         : This Class has an invocable method which is used to Update the Contact Details that 
                     come from the Login Flow
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
Soham Banerjee              03/08/2018                Intial version
*******************************************************************************************************/
public without sharing class ContactUpdateApexController {
    @InvocableMethod
/***
Method Name : updateContact
Purpose : invocable method which is used to Update the Contact Details that come from the Login Flow
***/
    public static void updateContact(List<String> fieldValues){
        System.debug('fieldValues: ' + fieldValues);
        Contact contactRecord = new Contact();
        for(String fieldValuePair : fieldValues[0].split('~')){
            if(('Id').equalsIgnoreCase(fieldValuePair.substringBefore('='))){
                contactRecord.Id = fieldValuePair.substringAfter('=');
            }
            else if(('Best_Method_of_Contact__c').equalsIgnoreCase(fieldValuePair.substringBefore('='))){
                contactRecord.Best_Method_of_Contact__c = fieldValuePair.substringAfter('=');
            }
            else if(('Company__c').equalsIgnoreCase(fieldValuePair.substringBefore('='))){
                contactRecord.Company__c = fieldValuePair.substringAfter('=');
            }
            else if(('Phone').equalsIgnoreCase(fieldValuePair.substringBefore('='))){
                contactRecord.Phone = fieldValuePair.substringAfter('=').remove(',');
            }
            else if(('Product_Selection2__c').equalsIgnoreCase(fieldValuePair.substringBefore('='))){
                contactRecord.Product_Selection2__c = fieldValuePair.substringAfter('=');
            }
            else if(('TermsAndConditions__c').equalsIgnoreCase(fieldValuePair.substringBefore('='))){
                if(fieldValuePair.substringAfter('=') == 'true')
                    contactRecord.TermsAndConditions__c = true;
            }
            else if(('Time_Zone__c').equalsIgnoreCase(fieldValuePair.substringBefore('='))){
                contactRecord.Time_Zone__c = fieldValuePair.substringAfter('=');
            }
            else if(('Title').equalsIgnoreCase(fieldValuePair.substringBefore('='))){
                contactRecord.Title = fieldValuePair.substringAfter('=');
            }
            else if(('MailingCountryCode').equalsIgnoreCase(fieldValuePair.substringBefore('='))){
                contactRecord.MailingCountryCode = fieldValuePair.substringAfter('=');
            }
            else if(('PCN').equalsIgnoreCase(fieldValuePair.substringBefore('=')) && 
                    String.isNotEmpty(fieldValuePair.substringAfter('='))){
                contactRecord.Pivotal_Customer_Number__c = fieldValuePair.substringAfter('=');
            }
            else if(('AlreadyL2').equalsIgnoreCase(fieldValuePair.substringBefore('=')) && 
                    ('').equalsIgnoreCase(fieldValuePair.substringAfter('='))){
                contactRecord.ChangedToL2__c = 'Profile Changed to L2';
            }
        }
        try{
            if(contactRecord.Id != NULL){
                contactRecord.First_Time_Login__c = 'No';
                CheckRecursive.checkContact = false;
                update contactRecord;
            }
        }
        catch(Exception e){
            ErrorLog.CreateER(e);//Exception captured in Utility Class Errorlog
        }
    }
}