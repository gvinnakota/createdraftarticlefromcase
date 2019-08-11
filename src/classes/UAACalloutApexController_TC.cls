@isTest
public class UAACalloutApexController_TC{
    @isTest static void testCallout() {
        List<UAA_Callout__c> uaaCalloutCSList = new List<UAA_Callout__c>();
        uaaCalloutCSList.add(new UAA_Callout__c(Name = 'client_id', Value__c = 'test'));
        uaaCalloutCSList.add(new UAA_Callout__c(Name = 'client_secret', Value__c = 'test'));
        uaaCalloutCSList.add(new UAA_Callout__c(Name = 'Endpoint', Value__c = 'https://test.com'));
        uaaCalloutCSList.add(new UAA_Callout__c(Name = 'grant_type', Value__c = 'test'));
        uaaCalloutCSList.add(new UAA_Callout__c(Name = 'response_type', Value__c = 'test'));
        uaaCalloutCSList.add(new UAA_Callout__c(Name = 'token_format', Value__c = 'test'));
        insert uaaCalloutCSList;
        TestDataUtil.dataValueMapCSData(); 
        Contact con = TestDataUtil.createPortalContact();
        User userRecord = [Select Id, ContactId, CreatedDate from User where ContactId =: con.Id];
        // Use MultiStaticResourceCalloutMock to
        // specify fake response for a certain endpoint and 
        // include response body in a static resource. 
        Test.startTest();
        Map<String,String> userFieldValuesMap = new Map<String,String>();
        userFieldValuesMap.put(userRecord.Id,'FirstName=abc,LastName=def,Email=a@b.com,CreatedDate=' + 
                               userRecord.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss') + '.918Z' +
                               ',Phone=9876543210');
        UAACalloutApexController.createUserInUAA(userFieldValuesMap);
        StaticResourceCalloutMock mock1 = new StaticResourceCalloutMock();
        mock1.setStaticResource('UAAAccessToken');
        mock1.setStatusCode(200);
        mock1.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock1);
        
        // Call the method for the first endpoint
        String accessToken = UAACalloutApexController.getAccessToken(System.Label.UAAAccessTokenLink);
        System.assert(String.isNotEmpty(accessToken));
        
        StaticResourceCalloutMock mock2 = new StaticResourceCalloutMock();
        mock2.setStaticResource('UAAInviteUsers');
        mock2.setStatusCode(200);
        mock2.setHeader('Content-Type', 'application/json');
        
        // Set the mock callout mode
        Test.setMock(HttpCalloutMock.class, mock2);
        // Verify response received 
        
        // Call the method for the second endpoint
        String verificationLink = UAACalloutApexController.getVerificationLink(accessToken, 'a@b.com',
                                                                               System.Label.UAAInviteUsersLink + 
                                                                               System.Label.UAAClientId + 
                                                                               System.Label.UAARedirectURI);
        System.debug('verificationLink: ' + verificationLink);
        // Verify response received
        System.assert(String.isNotEmpty(verificationLink));
        Test.stopTest();
    }
}