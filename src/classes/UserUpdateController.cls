/*******************************************************************************************************************
* Apex Class Name  : UserUpdateController

* Function         :Class used to get the profile id of the User

* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------


* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
public without sharing class UserUpdateController {
    @AuraEnabled
    /* Method used to the User details for the lighting component */
    public static void ProfileId(Id userRecordId) {
        try{
            if(userRecordId != NULL){
            System.debug('userRecordId: ' + userRecordId);
            List<User> userRecordList = [SELECT Id, ContactId,Profile_Update__c
                                         FROM User 
                                         WHERE Id =: userRecordId
                                         LIMIT 1];
           
        }
        }catch(Exception e){ErrorLog.CreateER(e);}
    }

}