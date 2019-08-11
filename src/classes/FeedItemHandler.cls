/***************************************************************************************************************************
* Apex Class Name  : FeeditemHandler
* Test Class Name  :
* Version          : 1.0
* Created Date     : 23 August 2017
* Function         : class is used to update first response time in case and completion time in first response mile stone
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------------
* Karthik.A.S               08/23/2017            intial version
* Hemavathi                 08/30/2017            Updated logic to Create Related Cases when Post is added on Closed Case.
* ------------------------------------------------------------------------------------------------------------------------
****************************************************************************************************************************/
public without sharing class FeedItemHandler{
    /* 1. This method is user to Update First Response update on Case record for 1st Email Outbound from Salesforce
       2. To create related cases if any post is added on closed case
    */    
    public static void updateCaseRecord(List<Feeditem> insertFeedItem){
        try{
            String portalUser = UserInfo.getUserType();
            String portalTypeLabel = System.Label.PortalUserTypeLicense;
            Set<Id> caseIdSet = new Set<Id>();
            for(Feeditem feed : insertFeedItem){
                if(feed.ParentId != null && string.valueOf(feed.ParentId).startsWith('500')) {
                    caseIdSet.add(feed.ParentId);
                }           
            }
            if(!caseIdSet.isEmpty()){
                List<Case> updatableCaseLst = new List<Case>();
                 Map<Id,Case> updatableCaseMap = new Map<Id,Case>();
                 Map<Id,Case> caseMaps = new Map<Id,Case>();
                String query = 'SELECT SuppliedEmail ,Status, First_Response_Time__c,Comments__c,Case_Comments__c, OwnerId,ContactId, Contact.Email ,Contact.Name,caseNumber  ';
                Map<string, RelatedCaseFieldMapping__c> allRecords = RelatedCaseFieldMapping__c.getAll();
                for(RelatedCaseFieldMapping__c sourceField : allRecords.Values()){
                   if(!query.contains(sourceField.Name)){
                        query = query + ', ' + sourceField.Name;
                    }
                }
                query = query + ' FROM case WHERE Id =: caseIdSet';
                Map<Id, sObject> caseMap = new Map<Id,sObject>();
                caseMap.putAll(Database.query(query));
                if(!caseMap.isEmpty()){
                    List<Case> relatedCaseList = new List<Case>();
                    String technicalId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
                    String nonTechnicalId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Non-Technical').getRecordTypeId();
                    for(Feeditem feedObj : insertFeedItem){
                        if(feedObj.ParentId != null && caseMap.containsKey(feedObj.ParentId)){
                            Case cObj = (case)caseMap.get(feedObj.ParentId);
                            if(feedObj.type=='TextPost' && cObj.ContactId != null&& cObj.Contact.Email != null){
                                caseMaps.put(cObj.Id,cObj);
                             }
                            
                            if(portalUser != portalTypeLabel){
                                if(feedObj.Visibility !='InternalUsers' &&  (feedObj.type=='TextPost'||feedObj.type=='LinkPost'||feedObj.type=='ContentPost') && cObj.First_Response_Time__c == null) {
                                    if(updatableCaseMap.containsKey(cObj.id)){
                                        updatableCaseMap.get(cObj.Id).First_Response_Time__c  = feedObj.CreatedDate;
                                    }else{
                                        cObj.First_Response_Time__c = feedObj.CreatedDate;
                                        updatableCaseMap.put(cObj.Id,cObj);
                                    }
                                }
                            }else if (portalUser == portalTypeLabel){
                                if(cObj.Status == 'Closed'){
                                    Case relatedCase = new Case();
                                    for(RelatedCaseFieldMapping__c csFields : allRecords.Values()){
                                        String str = csFields.Destination__c;
                                        if(cObj.RecordTypeId == technicalId && csFields.isTechnical__c){
                                            relatedCase.put(str,cObj.get(csFields.Name));
                                        }else if(cObj.RecordTypeId == NontechnicalId && csFields.isNonTechnical__c){
                                            if(csFields.Name == 'Product__c' && cObj.get(csFields.Name) == 'CSR'){
                                                relatedCase.put(str,cObj.get(csFields.Name));
                                            }else{
                                                relatedCase.put(str,cObj.get(csFields.Name));
                                            }
                                        }
                                    }
                                    relatedCaseList.add(relatedCase);
                                }else if(cObj.Status == 'Solved'){
                                    String feedBody = feedObj.body;
                                        feedBody = feedBody.Replace('<p>',' ');
                                        feedBody = feedBody.Replace('</p>',' ');
                                    if(updatableCaseMap.containsKey(cObj.id)){
                                        updatableCaseMap.get(cObj.Id).Status='Open';
                                        
                                        updatableCaseMap.get(cObj.Id).Case_Comments__c = feedBody;
                                    }else{
                                        cObj.Status='Open';
                                        cObj.case_Comments__c = feedBody;
                                        updatableCaseMap.put(cObj.Id,cObj);
                                    }
                                }
                            }
                        }
                    }if(!updatableCaseMap.isEmpty()){
                        update updatableCaseMap.values();
                    }
                    if(!relatedCaseList.isEmpty()){
                        AssignmentRule assignRule = new AssignmentRule();
                        assignRule = [SELECT id FROM AssignmentRule WHERE sObjectType ='Case' and Active = true limit 1];
                        Database.DMLOptions dmlOpts = new Database.DMLOptions();
                        dmlOpts.assignmentRuleHeader.assignmentRuleId= assignRule.id;
                        Database.insert(relatedCaseList, dmlOpts);
                    }
                }
            }
        }catch(exception e){
                ErrorLog.CreateER(e);
        }                
    } 
    /*This method Closes the Milestones on Case Object, order of closing the Milestone is First Repose, if already it is closed, it closes the Update milestone*/
    public static void setMilestoneDate(List<Feeditem> inputLst){ 
       String portalUser = UserInfo.getUserType();
       String portalTypeLabel = System.Label.PortalUserTypeLicense;
        try{
         if(portalUser != portalTypeLabel){
            Set<Id> caseIdSet = new Set<Id>();
                List<CaseMilestone> updableMilestone = new List<CaseMilestone>();
                list<CaseMilestone> mileStoneToUpdateLst = new list<CaseMilestone>();
                for(Feeditem feed : inputLst) {
                    if(feed.ParentId != null && string.valueOf(feed.ParentId).startsWith('500') && feed.Visibility !='InternalUsers'&&  feed.type=='TextPost' ) {
                        caseIdSet.add(feed.ParentId);
                    }           
                }
                if(!caseIdSet.isEmpty()) {
                    List<CaseMilestone> milestoneLst = [Select id,CaseId,CompletionDate,MilestoneType.Name from CaseMilestone where CaseId =: caseIdSet  and CompletionDate = null];        
                    if(!milestoneLst.isEmpty()){   
                        for(CaseMilestone casemileObj : milestoneLst) {               
                            if(casemileObj.MilestoneType.Name == 'First Response') {   
                                casemileObj.CompletionDate = System.Now(); 
                                mileStoneToUpdateLst.add(casemileObj);                          
                            }
                        }       
                    }
                }
                if(!mileStoneToUpdateLst.isEmpty()) {
                    Update mileStoneToUpdateLst;
                }
          }
        }catch(exception e){
            ErrorLog.CreateER(e);
            
        }
    } 
}