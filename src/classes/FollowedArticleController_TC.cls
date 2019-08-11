@isTest
Private class FollowedArticleController_TC {
    static testMethod  void  testgetFollowedAricles(){
        TestDataUtil.dataValueMapCSData();
        KnowledgeArticle__kav bf = new KnowledgeArticle__kav();
        bf.Title = 'Test Articles';
        bf.UrlName = 'TestArticles';
        bf.Symptom__c = 'Test Articles';
        bf.Resolution__c = 'Test Articles';
        bf.Product2__c  = 'Alpine Chorus for Pivotal Data Suite';
        bf.Article_Author_Lookup__c = UserInfo.getUserId();
        insert bf;
        System.assert(bf.Id!=null);
        String arId = [SELECT KnowledgeArticleId FROM KnowledgeArticle__kav WHERE Id = :bf.Id].KnowledgeArticleId;
        KbManagement.PublishingService.publishArticle(arId, true);
        
        List<EntitySubscription> lstEntSubs = new List<EntitySubscription>();
        EntitySubscription entSubs = new EntitySubscription();
        entSubs.SubscriberId = UserInfo.getUserId();
        entSubs.ParentId = arId; 
        insert entSubs;
        
        FollowedArticleController.getFollowedAricles();
        
    }
}