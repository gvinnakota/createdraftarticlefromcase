/***************************************************************************************************************************************
* Apex Class Name  : FeedItemCommentTriggerHandler
* Test Class Name  :
* Version          : 1.0
* Created Date     : 10 August 2017
* Function         : Class is used as an handler to perform logics to an event occur. 
                     Limitation on Process builder & Workflow to notify author on commenting on article. 
                    
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Hemavathi NM              8/10/2017                  intial version
* --------------------------------------------------------------------------------------------------------------------
***************************************************************************************************************************************/
/*Method: Class is used as an handler to perform logics to an event occur.Limitation on Process builder & Workflow to notify author on commenting on article.  */
public without sharing class FeedItemCommentTriggerHandler {
    /*Method: Feed Item Method. */
    public void feedItemMethod(){
        try{
        Set<Id> articleIds = new Set<Id>();
        Map<SObject,Id> mapFeedArticleId = new Map<SObject,Id>();
            if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            String articleTypes = DataValueMap__c.getInstance('ArticleTypes').Data_Value__c;
            
            for(FeedItem feedItem : (List<FeedItem>)Trigger.New){
                String parentId = feedItem.ParentId;
                if(articleTypes.contains(parentId.subString(0,3))){
                    articleIds.add(feedItem.ParentId);
                    mapFeedArticleId.put(feedItem,feedItem.ParentId);
                }
            }
            SendEmailNotification(mapFeedArticleId,'feedItem');
        }
        }catch(Exception e){
                        ErrorLog.CreateER(e);
                        }
    }
    /*Method: Feed Comment Method. */
  /*  public void feedCommentMethod(){
        try{
        Set<Id> articleIds = new Set<Id>();
        Map<SObject,Id> mapFeedArticleId = new Map<SObject,Id>();
            if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
            String articleTypes = DataValueMap__c.getInstance('ArticleTypes').Data_Value__c;
            
            for(FeedComment feedItem : (List<FeedComment>)Trigger.New){
                String parentId = feedItem.ParentId;
                if(articleTypes.contains(parentId.subString(0,3))){
                    articleIds.add(feedItem.ParentId);
                    mapFeedArticleId.put(feedItem,feedItem.ParentId);
                }
            }
            SendEmailNotification(mapFeedArticleId,'feedComment');
        }
        }catch(Exception e){
                        ErrorLog.CreateER(e);
                        }
    } */
    
    /*Method: to send notification to author of an article when comments are posted. */
    public void SendEmailNotification(Map<SObject,Id> mapFeedArticleId,String Type){
        try{
        Map<id,Sobject> mapKBArticles= new Map<Id,sobject>();
        Set<Id> articleId = new Set<Id>();
        for(Id artId : mapFeedARticleId.values()){
            articleId.add(artId);
        }
        if(!mapFeedArticleId.isempty()){
            List<KnowledgeArticleVersion>  kavList =[Select Id,KnowledgeArticleId,ArticleCreatedBy.Name,ArticleNumber, CreatedBy.Name,CreatedBy.Email, CreatedById from KnowledgeArticleVersion  where KnowledgeArticleId =: articleId and (PublishStatus ='Online')];
            List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
            string commenter = userInfo.getName(); 
            
            for(KnowledgeArticleVersion kavObj : kavList){
                  mapKBArticles.put(kavObj.KnowledgeArticleId, kavObj);            
            }
            
            for(sObject feed : mapFeedArticleId.keyset()){
                FeedItem feedIt ;
                FeedComment feedCom;
                if(type=='feedItem'){
                    feedIt = (feedItem)feed;
                }else if(type=='feedComment'){
                     feedCom = (feedComment)feed;
                }
                if((feedIt !=null && mapKBArticles.containsKey(feedIt.ParentId)) || (feedCom != null && mapKBArticles.containsKey(feedCom.ParentId)) ){
                KnowledgeArticleVersion kavObj = (feedCom !=null ? (KnowledgeArticleVersion)mapKBArticles.get(feedCom.ParentId):(KnowledgeArticleVersion)mapKBArticles.get(feedIt.ParentId));
                list<string> toAddress = new list<String>();
                toAddress.add(kavObj.CreatedBy.Email);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(kavObj.createdById);
                mail.setToAddresses(toAddress);
                mail.saveAsActivity = false;
                mail.setSubject('Attention - '+commenter+' commented on your KB article');
                    String body = 'Dear ' + kavObj.CreatedBy.Name + ',<br/>'+'<br/>' ;
                body += 'Your article '+kavObj.ArticleNumber + '  has a comment from '+commenter+'.'+'<br/>';
                body +='<br/>'+'Regards,<br/> Pivotal Knowledge Management Team';
                mail.setHtmlBody(body);
                mailsToSend.add(mail);
                }
            }
            Messaging.SendEmailResult[] mailResults = Messaging.sendEmail(mailsToSend );             
        } 
        }catch(Exception e){
                        ErrorLog.CreateER(e);
                        }
    }    
}