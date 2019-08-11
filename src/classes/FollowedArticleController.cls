public class FollowedArticleController {
    @AuraEnabled
    public static List<KnowledgeArticleVersion> getFollowedAricles(){
        //system.debug(UserInfo.getUserId());
        DataValueMap__c articleTypes = DataValueMap__c.getValues('ArticleTypeNames');
        List<String> setArtTypes = articleTypes.Data_Value__c.split(',');
        System.debug('setArtTypes: '+setArtTypes[0]);
        Set<Id> setParentIds = new Set<Id>();
        List<EntitySubscription> lstEntSubs= [SELECT Id, NetworkId, CreatedDate, CreatedById, SubscriberId, ParentId,
                                              Parent.Type, Parent.Name FROM EntitySubscription WHERE
                                              SubscriberId = : UserInfo.getUserId()
                                              AND Parent.Type IN :setArtTypes limit 1000];
        for(EntitySubscription es : lstEntSubs){
            setParentIds.add(es.ParentId);
        }
        system.debug('lstParentIds:'+setParentIds);
        Map<Id, KnowledgeArticleVersion> mapKA = new Map<Id, KnowledgeArticleVersion>();
        List<KnowledgeArticleVersion> lstKA = [SELECT UrlName, Title, Id, KnowledgeArticleId
                                               FROM KnowledgeArticleVersion];
        List<KnowledgeArticleVersion> lstKADisplay = new List<KnowledgeArticleVersion>();
        for(KnowledgeArticleVersion ka: lstKA){
            if(!mapKA.containsKey(ka.KnowledgeArticleId)){
                mapKA.put(ka.KnowledgeArticleId, ka);
            }
        }
        for(EntitySubscription es : lstEntSubs){
            if(mapKA.containsKey(es.ParentId)){
                lstKADisplay.add(mapKA.get(es.ParentId));
            }
        }
        system.debug('lstKADisplay :'+lstKADisplay);
        return lstKADisplay;
    }
}