//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global without sharing class UAAJITRegHandlerApexController implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    Contact conRecord = new Contact();
    
    /***************************************************************************************************** 
    Method Name:        handleUserForUAA
    @return  :          User
    Description:        UAA Just In Time provisioning
    Added By:           Accenture - SB
    Modified By:        Changes: 
    Accenture - SB      This method queries the User Object with the data from the FederationIdentifier
    ******************************************************************************************************/
    private User handleUserForUAA(Map<String, String> attributes, String federationIdentifier) {
        if(attributes.containsKey('User.FederationIdentifier')){
            federationIdentifier = attributes.get('User.FederationIdentifier');
        }
        if(federationIdentifier != NULL){
            try{
                List<User> userRecordList = [SELECT Id, UserName, Email, FederationIdentifier
                                             FROM User
                                             WHERE FederationIdentifier LIKE :federationIdentifier
                                             LIMIT 1];
                if(userRecordList.isEmpty() && conRecord != NULL){
                    String queryString = 'SELECT Id, FirstName, LastName, Email, Interact_with_Community__c, ' +
                                                'Enable_Portal_User__c, View_Account_Cases__c, Customer_Admin__c, ' +
                                                'AccountId, DPL_Status__c, ';
                    for(PortalUserCreationMap__c cSFields : PortalUserCreationMap__c.getAll().Values())
                    {
                        if(!queryString.containsIgnoreCase(cSFields.Source__c + ', '))
                            queryString += cSFields.Source__c + ', ';
                    }
                    queryString = queryString.removeEnd(', ');
                    String contactRecordId = conRecord.Id;
                    queryString += ' FROM Contact ' +
                                   'WHERE Id = :contactRecordId';
                    System.debug('queryString: ' + queryString);
                    List<Contact> conList = Database.query(queryString);
                    conRecord = conList[0];
                    
                    User usrRecord = new User();
                    for(PortalUserCreationMap__c cSFields : PortalUserCreationMap__c.getAll().Values())
                    {
                        usrRecord.put(cSFields.Name,conRecord.get(cSFields.Source__c));
                    }
                    usrRecord.EmailEncodingKey = 'ISO-8859-1';
                    String keyToNickName = conRecord.LastName + conRecord.Email + conRecord.FirstName;
                    String Nickname = PS_ContactTriggerHandler.generateRandomString(12, keyToNickName);
                    usrRecord.Alias = PS_ContactTriggerHandler.generateRandomString(6, Nickname);
                    usrRecord.CommunityNickname = Nickname;
                    usrRecord.ProfileId = DataValueMap__c.getInstance('PortalRegisteredUserId').Data_Value__c;
                    usrRecord.TimeZoneSidKey = 'America/Los_Angeles';
                    usrRecord.LanguageLocaleKey = 'en_US';
                    usrRecord.LocaleSidKey = 'en_US';
                    if(conRecord.DPL_Status__c != 'Restricted')
                    {   
                        usrRecord.isActive = true;
                    }
                    insert usrRecord;
                    
                    conRecord.Interact_with_Community__c = true;
                    update conRecord;
                    
                    return usrRecord;
                }
                else if(userRecordList[0].Email != userRecordList[0].FederationIdentifier){
                    ErrorLog.CreateER(new JitException('Email and FederationId does not match in Salesforce. Contact the CSR for further assistance.'));
                }
                else{
                    userRecordList[0].FederationIdentifier = federationIdentifier;
                    userRecordList[0].Email = federationIdentifier;
                    return userRecordList[0];
                }
                return NULL;
            }catch(Exception e){
                ErrorLog.CreateER(e);//Exception captured in Utility Class Errorlog
                return NULL;
            }
        }
        return NULL;
    }

    /***************************************************************************************************** 
    Method Name:        handleContactForUAA
    @return  :          User
    Description:        UAA Just In Time provisioning
    Added By:           Accenture - SB
    Modified By:        Changes: 
    Accenture - SB      This method queries the Contact object with the data from the email attribute
    ******************************************************************************************************/
    private void handleContactForUAA(Map<String, String> attributes, String federationIdentifier) {
        List<Contact> conList = [SELECT Id, Email, LastModifiedDate
                                 FROM Contact 
                                 WHERE Email LIKE :attributes.get('email')
                                 ORDER By LastModifiedDate DESC
                                 LIMIT 1];
        if(conList.isEmpty()){
            conRecord.AccountId = DataValueMap__c.getInstance('RegisteredAccount').Data_Value__c;
            conRecord.Email = attributes.get('User.FederationIdentifier');
            //conRecord.Email = federationIdentifier;
            /*if(attributes.containsKey('User.FirstName'))
                conRecord.FirstName = attributes.get('User.FirstName').substringBefore('@');
            else if (attributes.containsKey('name'))
                conRecord.FirstName = attributes.get('name').substringBefore('@');
            if(attributes.containsKey('User.LastName'))
                conRecord.LastName = attributes.get('User.LastName').substringBefore('@');
            else if (attributes.containsKey('name'))
                conRecord.LastName = attributes.get('name').substringBefore('@');*/
            if(attributes.containsKey('Contact.FirstName'))
                conRecord.FirstName = attributes.get('Contact.FirstName');
            else if (attributes.containsKey('name'))
                conRecord.FirstName = attributes.get('name').substringBefore('@');
            if(attributes.containsKey('Contact.LastName'))
                conRecord.LastName = attributes.get('Contact.LastName');
            else if (attributes.containsKey('name'))
                conRecord.LastName = attributes.get('name').substringBefore('@');
            conRecord.Interact_with_Community__c = true;
            conRecord.UAA_ID__c = attributes.get('User.FederationIdentifier');
            //conRecord.UAA_ID__c = federationIdentifier;
            conRecord.Source_of_Creation__c = 'JIT';
            insert conRecord;
        }
        else
            conRecord = conList[0];
    }

    /***************************************************************************************************** 
    Method Name:        handleJitForUAA
    @return  :          User
    Description:        UAA Just In Time provisioning
    Added By:           Accenture - SB
    Modified By:        Changes: 
    Accenture - SB      Associate the new Contact with "Registered User Account"
    ******************************************************************************************************/

    private User handleJitForUAA(Map<String, String> attributes, String federationIdentifier) {
        if(attributes.containsKey('origin') && ('uaa').equalsIgnoreCase(attributes.get('origin'))){
            handleContactForUAA(attributes, federationIdentifier);
            return handleUserForUAA(attributes, federationIdentifier);
        }
        return NULL;
    }

    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        return handleJitForUAA(attributes, federationIdentifier);
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
    }
}