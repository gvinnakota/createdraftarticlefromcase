/*******************************************************************************************************************
* Apex Class Name  : PS_EmailMessageTriggerHandler
* Test Class Name  : PS_EmailMessageTriggerHandler_Test
* Version          : 1.0
* Created Date     : 23 August 2017
* Function         : class is used to update first response on case and completion date in milestone
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Karthik.A.S               08/23/2017            intial version
* Shane Smalldon            04/24/2019            Removed logic that creates cases on email destined to closed case as a flow does this for us
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
public class PS_EmailMessageTriggerHandler
{
    //Related case creation on email- Code starts
    public static void RelatedCaseRecord(List<EmailMessage> emailMsgLst){
    try{
        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> createdbyUserId = new Set<Id>();
        List<EmailMessage> lstEmailMessage = new List<EmailMessage>();
        Map<Id,EmailMessage> caseMsgMap = new Map<Id,EmailMessage>();
        for(EmailMessage emailObj : emailMsgLst){
            System.debug('emailObj---->'+emailObj);
            if(emailObj.ParentId != null && string.valueOf(emailObj.ParentId).startsWith('500') ) {
            /*******Code commented by Dilip on 10/13/2018 for IsExternallyVisible issue 
                if(emailObj.IsExternallyVisible){
                System.debug('emailObj.IsExternallyVisible1'+emailObj.IsExternallyVisible);
                    caseIdSet.add(emailObj.ParentId);
                }
                *****/
                
                 caseIdSet.add(emailObj.ParentId);
                 System.debug('emailObj.IsExternallyVisible1'+caseIdSet);
                
                createdbyUserId.add(emailObj.CreatedById); 
                caseMsgMap.put(emailObj.ParentId, emailObj);
            }           
        }
        if(!caseIdSet.isEmpty()){
            List<Case> updatableCaseLst = new List<Case>();
            setMilestoneDate(caseIdSet,createdbyUserId);
            for(Case caseObj: [Select Id, First_Response_Time__c,Status from Case where Id =: caseIdSet and Status != 'Closed']){
                if(!caseMsgMap.isEmpty() && caseMsgMap.containsKey(caseObj.Id)){
                    EmailMessage emails = caseMsgMap.get(caseObj.Id);
                    System.debug('emails.IsExternallyVisible2'+emails.IsExternallyVisible);
                    /*******Code commented by Dilip on 10/13/2018 for IsExternallyVisible issue */
                    if(caseObj.First_Response_Time__c == null /* && emails.IsExternallyVisible*/) {
                    System.debug('emails.IsExternallyVisible2'+emails.IsExternallyVisible);
                        caseObj.First_Response_Time__c = emails.CreatedDate;
                        updatableCaseLst.add(caseObj);
                    }
                }
                              
            }
            if(!updatableCaseLst.isEmpty()){
                update updatableCaseLst;
            }
        }
    }catch(Exception e){
          ErrorLog.CreateER(e);
        }                
    }    
    //Related case creation ends - Code Ends
    
    // This method Closes the Milestones on Case Object, order of closing the Milestone is First Repose, if already it is closed, it closes the Update milestone
    public static void setMilestoneDate(Set<Id> caseIds,Set<Id> createdByIds)
    {   
        Map<Id, User> userIdMap;
        try{
            list<CaseMileStone> updateMilestone = new list<CaseMileStone>();
                for(CaseMileStone caseMileObj : [Select id,CaseId,CompletionDate,MilestoneType.Name from CaseMilestone where CaseId =: caseIds and CompletionDate = null]){
                    if(caseMileObj.MilestoneType.Name == 'First Response') {                    
                        caseMileObj.CompletionDate = System.Now(); 
                        updateMilestone.add(caseMileObj);                    
                    }                   
                }
            if(!updateMilestone.isEmpty()) {   
                update updateMilestone;
            }
        }
        catch(Exception e) {         
             System.debug('Exception occurred');
        }     
    }
    public static void email2CaseRouting(Map<Id,EmailMessage> caseEmailMsgMap){
        if(!caseEmailMsgMap.isEmpty()){
            /*Custom Setting Data from DataValueMap */
            String OnDemandaccountId = DataValueMap__c.getInstance('OnDemandaccountId').Data_Value__c;
            String PWSaccountId = DataValueMap__c.getInstance('PWSaccountId').Data_Value__c;
            String OnDemandaccountAlias = DataValueMap__c.getInstance('OnDemandaccountAlias').Data_Value__c;
            String PWSaccountAlias = DataValueMap__c.getInstance('PWSaccountAlias').Data_Value__c;
            String techRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
            String defaultBusHrs = DataValueMap__c.getInstance('DefaultBusHrs').Data_Value__c;
            String status = DataValueMap__c.getInstance('customerCaseStatus').Data_Value__c;
            List<Contact> InsertContactList = new List<Contact>();
            /*Local variables*/
            List<Case> caseList = new list<Case>();
        try{
            Map<Id,Case> caseToUpdateMap = new Map<Id,Case>();
            Map<Id,Case> caseMap = new Map<Id,Case>();
            Map<Id,Contact> contactToInsert = new Map<Id,Contact>();
            Map<String,Id> emailAccountMap = new Map<String,Id>();
            Set<Id> accountIdlst = new Set<Id>();
            Set<String> emailSet = new Set<String>();
            String onDemandPwsAccountIds;
            String pwsOnDemandAccountId;
            Boolean nonPwsDemandAccount = false;
            String pwsDemandAccountIds = OnDemandaccountId+','+PWSaccountId;
            Map<Id,EmailMessage> caseIdEmailMsgMap = new Map<Id,EmailMessage>();
            for(Case caseMsg : [Select Id, ContactId,ThreadId__c, Contact.Email , AccountId , Status from Case where Id =: caseEmailMsgMap.keySet()]){
                EmailMessage email = caseEmailMsgMap.get(caseMsg.Id);
                String emailBody = (email.Textbody != null?email.Textbody:'No Content');
                if((status.containsIgnoreCase(caseMsg.Status))){
                    caseIdEmailMsgMap.put(caseMsg.Id, email);
                }
                else if(caseMsg.Status == 'Open' && !emailBody.contains(caseMsg.ThreadId__c)){
                    String emailAlias = ';'+email.ToAddress+';';
                    String fromEmail = email.FromAddress;
                    //caseMsg.InboundEmailAlias__c = email.ToAddress;
                    onDemandPwsAccountIds = OnDemandaccountAlias+','+PWSaccountAlias;
                    String emailKey = email.FromAddress + caseMsg.AccountId;
                    if(onDemandPwsAccountIds.contains(emailAlias)){
                        if(OnDemandaccountAlias != null && OnDemandaccountAlias.contains(emailAlias)){
                            pwsOnDemandAccountId = OnDemandaccountId;
                        }
                        if(PWSaccountAlias != null && PWSaccountAlias.contains(emailAlias)){
                            pwsOnDemandAccountId = PWSaccountId;
                        }
                        if(pwsOnDemandAccountId != null){
                            Contact cont = new Contact();
                            String[] name = String.Valueof(email.FromName).split(',');
                            cont.FirstName = (name != null? name[0]:'PWS');
                            cont.LastName = ((name != null && name.size() > 1)? name[1]:'Contact');
                            cont.Email = email.FromAddress;
                            cont.AccountId = pwsOnDemandAccountId;
                            cont.BusinessHours__c = defaultBusHrs;
                           // cont.MailingCountry = 'N/A';    
                            contactToInsert.put(caseMsg.Id,cont);
                        }
                       //caseMsg.RecordTypeId = techRTId;
                    }else{
                        nonPwsDemandAccount = true;
                    }
                    emailAccountMap.put(email.FromAddress,caseMsg.Id);
                    caseMap.put(caseMsg.Id,caseMsg);
                    emailSet.add(email.FromAddress);
                }
            }
            if(!emailSet.isEmpty()){
                Map<String, Contact> validateMap = new Map<String,Contact>();
                List<Contact> lstContact = new List<Contact>([SELECT Id, AccountId,Email FROM Contact WHERE Email =:emailSet Order By CreatedDate asc limit 1]);
                if(!lstContact.isEmpty()){
                    for(Contact con :lstContact){
                        Case cObj = caseMap.get(emailAccountMap.get(con.Email));
                        if(cObj.ContactId != con.Id){
                            cObj.AccountId = con.AccountId;
                            cObj.ContactId = con.Id;
                            caseToUpdateMap.put(cObj.Id,cObj);                        
                        }
                        if(pwsOnDemandAccountId!=null && pwsOnDemandAccountId.containsIgnoreCase(cObj.AccountId)){
                                accountIdlst.add(cObj.AccountId);
                            }
                        contactToInsert.remove(cObj.Id);
                    }
                }          
            }
            
                if(!contactToInsert.isEmpty()){
                    insert contactToInsert.values();
                    for(Id caseId:contactToInsert.keySet()){
                        Case caseObj = caseMap.get(caseId);
                        Contact con = contactToInsert.get(caseId);
                        caseObj.ContactId = con.Id;
                        caseObj.AccountId = con.AccountId;
                        caseToUpdateMap.put(caseObj.Id,caseObj);
                        if(pwsOnDemandAccountId!=null && pwsOnDemandAccountId.containsIgnoreCase(con.AccountId)){
                          accountIdlst.add(con.AccountId);
                        }
                    }
                }
                if(!accountIdlst.isEmpty()){
                    for(Entitlement entObj :[select Id,AccountId from Entitlement where AccountId=:accountIdlst and Status = 'Active' limit 1]){
                        for(Id caseId:caseMap.keySet()){
                            Case caseObj = caseMap.get(caseId);
                            if(caseObj.AccountId == entObj.AccountId){
                                caseObj.EntitlementId = entObj.Id;
                            }
                            caseToUpdateMap.put(caseObj.Id,caseObj);
                        }
                    }
                }
                if(!caseToUpdateMap.isEmpty()){
                    update caseToUpdateMap.values();
                }
                if(!caseIdEmailMsgMap.isEmpty()){
                    updateCaseOnResponse(caseIdEmailMsgMap);
                }
            }catch(Exception e){
                 ErrorLog.CreateER(e);//Exception captured in Utility Class Errorlog
             }       
        }
    }/*End of Method*/
    
    /*-------Add Post as Related Cases on Closed Cases / Pending /On Hold------Code Start*/
     public static void updateCaseOnResponse(Map<Id,EmailMessage> responseEmailMessageMap){
        List<Case> relatedCaseList = new List<Case>();
        List<Case> updateRelatedCaseLst = new List<Case>();
        List<Id> caseIds = new list<Id>();
        caseIds.addAll(responseEmailMessageMap.keySet());
        
        String query = 'SELECT Status, OwnerId';
        Map<string, RelatedCaseFieldMapping__c> allRecords = RelatedCaseFieldMapping__c.getAll();
        for(RelatedCaseFieldMapping__c sourceField : allRecords.Values()){  // Iterating over custom seetings fields
            query = query + ', ' + sourceField.Name;
        }
        query = query + ' FROM case WHERE Id =: caseIds';
        Map<Id, sObject> caseMap = new Map<Id,sObject>();
        caseMap.putAll(Database.query(query));
        String technicalId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        String nonTechnicalId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Non-Technical').getRecordTypeId();
        System.debug('logged in user---->'+UserInfo.getUserID());
        System.debug('logged in user---->'+UserInfo.getUserID());
        if(!caseMap.isEmpty()){
            for(Case cObj :(list<Case>) caseMap.Values()){
               /* https://www.pivotaltracker.com/story/show/164737098 - Commenting this out as it was generating duplicate cases for what a flow is going to be doing
               if(cObj.Status == 'Closed'){
                    Case relatedCase = new Case();
                    for(RelatedCaseFieldMapping__c csFields : allRecords.Values()){
                        String str = csFields.Destination__c;
                        if(cObj.RecordTypeId == technicalId && csFields.isTechnical__c){
                            relatedCase.put(str,cObj.get(csFields.Name));
                        }else if(cObj.RecordTypeId == NontechnicalId && csFields.isNonTechnical__c){
                            if(csFields.Name == 'Products__c' && cObj.get(csFields.Name) == 'CSR'){
                                relatedCase.put(str,cObj.get(csFields.Name));
                            }else{
                                relatedCase.put(str,cObj.get(csFields.Name));
                            }
                        }
                    }
                    relatedCaseList.add(relatedCase);
                }
                */
                
                if(cObj.Status == 'Pending'){
                    cObj.Status = 'Open';
                    cObj.Sub_Status__c = null; 
                    updateRelatedCaseLst.add(cObj);
                }
                if(cObj.Status == 'Solved'){
                    cObj.Status = 'Open';
                    updateRelatedCaseLst.add(cObj);
                }
            }
            
            /*-------Add Post as Related Cases on Closed Cases------Code Start*/
            if(!relatedCaseList.isEmpty()){
                AssignmentRule assignRule = new AssignmentRule();
                assignRule = [SELECT id FROM AssignmentRule WHERE sObjectType ='Case' and Active = true limit 1];
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= assignRule.id;
                Database.SaveResult[] results = Database.insert(relatedCaseList, dmlOpts);
                System.debug('result----'+results);
            }
            /*-------Add Post as Related Cases on Closed Cases------Code End*/
            if(!updateRelatedCaseLst.isEmpty()){
                try{
                    Update updateRelatedCaseLst;
                }
                catch(Exception e){
                    ErrorLog.CreateER(e);//Exception captured in Utility Class Errorlog
                }
            }
        }
     }
     /*-------Add Post as Related Cases on Closed Cases------Code End*/
}