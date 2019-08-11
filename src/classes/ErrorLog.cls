/*******************************************************************************************************************
* Apex Class Name  : ErrorLog
* Version          : 1.0
* Function         : Class is used capture exception log and create a record for it.
* Modification Log :
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Ranjithkumar Udhaya        10/11/2017               Utility Class to Capture exception log
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
/***
Purpose : Utility Class to Capture exception log
***/
public without sharing class ErrorLog{  
/***
Method Name : CreateER
Purpose : Method is used to Create a error log record to capture the exception message
***/    
    public static void CreateER(Exception e){
      
        String loggedinUser = userinfo.getName();
        Exception_Log__c elog = new Exception_Log__c();
        elog.Cause__c = string.valueOf(e.getCause());
        elog.Class_Name__c = e.getStackTraceString().substringBefore(':');
        elog.Exception_Message__c = e.getMessage();
        elog.LineNumber__c = string.valueOf(e.getLineNumber());
        elog.StackTrace__c = e.getStackTraceString();
        elog.logged_in_user__c = loggedinUser;
        Database.insert(elog,false);
   
    }
}