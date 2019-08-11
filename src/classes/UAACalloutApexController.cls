/* Class : UAACalloutApexController
purpose : UAA callout when a user created from salesforce service console */
public without sharing class UAACalloutApexController {
    static Map<String,UAA_Callout__c> uaaValues = UAA_Callout__c.getAll();
    @TestVisible private static String getAccessToken(String endpointURL){
        String reqEndpoint = '';
        Http tokenH = new Http();
        HttpRequest tokenRequest = new HttpRequest();
        String strRequestBody = '';
        if(!uaaValues.isEmpty()){
            for(String keyName : uaaValues.keySet()){
                if(!('Endpoint').equalsIgnoreCase(keyName))
                    strRequestBody += keyName + '=' + uaaValues.get(keyName).Value__c + '&';
            }
            strRequestBody = strRequestBody.left(strRequestBody.length() - 1);
        }
        
        tokenRequest.setBody(strRequestBody);
        tokenRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        tokenRequest.setMethod('POST');
        //tokenRequest.setEndpoint(reqEndpoint + '/oauth/token');
        tokenRequest.setEndpoint(endpointURL);
        String accessToken;
        // http response
        HttpResponse tokenResponse = tokenH.send(tokenRequest);
        Integer tokenStatusCode = tokenResponse.getStatusCode();
        if(tokenStatusCode == 200){
            String jsonresponse = tokenResponse.getBody();
            JSONParser parser = JSON.createParser(jsonresponse);
            parser.nextToken();       
            parser.nextValue();
            accessToken = parser.getText();           
        }
        return accessToken;
    }
    /* ********************UAA Callout methods - start ************************************/
    /***************************************************************************************************** 
    Method Name:        createUserInUAA
    @return  :          void
    @parameters:        strFieldValues - key value pairs for First Name, Last Name, Email & Phone
    Description:        User Story# 2289 - API Call Out to UAA to create a UAA User for the new 
    Portal User created in Salesforce.
    Added By:           Accenture - SB - 11/04/2018
    Modified By:        Date:       Changes: 
    
    ******************************************************************************************************/
    @future(callout = true)
    public static void createUserInUAA(Map<String,String> strFieldValues){
        try{
            List<User> userListToBeUpdated = new List<User>();
            String emailId = '';
            for(String userId : strFieldValues.keySet()){
                String reqEndpoint = '';
                if(!uaaValues.isEmpty()){
                    if(uaaValues.containsKey('Endpoint') && uaaValues.get('Endpoint') != NULL){
                        reqEndpoint = uaaValues.get('Endpoint').Value__c;
                    }
                }
                String uaaToken = getAccessToken(reqEndpoint + '/oauth/token');
                for(String strFieldValue : strFieldValues.get(userId).split(',')){
                    if(('Email').equalsIgnoreCase(strFieldValue.substringBefore('='))){
                        emailId = strFieldValue.substringAfter('=');
                    }
                }
                if(String.isNotEmpty(uaaToken) && String.isNotEmpty(emailId)){
                    reqEndpoint = '';
                    if(!uaaValues.isEmpty()){
                        if(uaaValues.containsKey('Endpoint') && uaaValues.get('Endpoint') != NULL){
                            reqEndpoint = uaaValues.get('Endpoint').Value__c;
                        }
                        if(uaaValues.containsKey('client_id') && uaaValues.get('client_id') != NULL){
                            reqEndpoint += '/invite_users?client_id=' + uaaValues.get('client_id').Value__c +
                                '&redirect_uri=' + URL.getSalesforceBaseUrl().toExternalForm();
                        }
                    }
                    String verificationLink = getVerificationLink(uaaToken,emailId,reqEndpoint);
                    if(String.isNotEmpty(verificationLink)){
                        User userRecord = new User();
                        userRecord.UAA_Verification_Link__c = verificationLink;
                        userRecord.Id = userId;
                        userListToBeUpdated.add(userRecord);
                    }                
                }
            }
            if(!userListToBeUpdated.isEmpty()) update userListToBeUpdated;
        }catch(Exception e){
            ErrorLog.CreateER(e);
        }
    }
    /* **************************************************************************************************** 
    Method Name:        getVerificationLink
    @return  :          String
    @parameters:        accessToken, emailId
    Description:        User Story# 2289 - calling the UAA to fetch the verification link
    Added By:           Accenture - SB - 24/04/2018
    Modified By:        Date:       Changes: 
    
    ******************************************************************************************************/
    @TestVisible private static String getVerificationLink(String accessToken, String emailId, String endpointURL){
        String verificationLink = '';
        String authorizationHeader = 'Bearer '+ accessToken;
        Http h = new Http();
        // new http request
        HttpRequest request = new HttpRequest();
        //Change the End Point
        request.setEndpoint(endpointURL);
        request.setHeader('Authorization',authorizationHeader);
        request.setHeader('Content-Type', 'application/json');
        String jsonBody = '';
        //Fetch values from User Record to pass Email, First Name, Last Name & Phone Number
        if(String.isNotEmpty(emailId)){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject(); //{
            gen.writeFieldName('emails'); //"emails" : 
            gen.writeStartArray(); //[
            gen.writeString(emailId); //"user1@3axx0p.com"
            gen.writeEndArray(); //]
            gen.writeEndObject(); //}
            jsonBody = gen.getAsString();
            if(String.isNotEmpty(jsonBody)) request.setBody(jsonBody);
            request.setMethod('POST');
            // http response
            HttpResponse response = h.send(request);
            Integer statusCode = response.getStatusCode();
            
            if(statusCode == 200){
                JSONParser parser = JSON.createParser(response.getBody());
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                        (parser.getText() == 'inviteLink')) 
                    {
                        // Get the value.
                        parser.nextToken();
                        verificationLink = parser.getText();
                        break;
                    }
                }
            }
        }
        return verificationLink;
    }
}