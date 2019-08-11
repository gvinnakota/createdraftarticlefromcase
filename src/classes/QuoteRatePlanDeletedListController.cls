public with sharing class QuoteRatePlanDeletedListController {

    public static final String CLONE_ID = 'cloneId';
    public static final String CLONE_NAME = 'cloneName';
    public static final String RATE_PLAN_IDS = 'ratePlanIds';
    public String cloneId {get; set;}
    public List<zqu__QuoteRatePlan__c> deletedRatePlans {get; private set;}

    public QuoteRatePlanDeletedListController() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        cloneId = params.get(CLONE_ID);
        String ratePlansIds = params.get(RATE_PLAN_IDS);
        if (String.isNotBlank(ratePlansIds)) {
            List<String> deletedRatePlanIds = ratePlansIds.split(',');
            deletedRatePlans = [SELECT Name FROM zqu__QuoteRatePlan__c WHERE Id IN :deletedRatePlanIds ALL ROWS];
            if (deletedRatePlans.size() > 1) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Multiple Quote Related Rate Plans Expired'));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Single Quote Related Rate Plans Expired'));
            }
        }
    }

    public PageReference redirect(){
        if(cloneId == null){
            return null;
        } else {
            PageReference pageRef = new PageReference('/' + cloneId);
            return pageRef;
        }
    }
}