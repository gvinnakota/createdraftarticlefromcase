public with sharing class RoleInstancesOnQuoteRatePlanController {
    private Id qrpId;
    public List<Role_Instance__c> instances {get; set;}

    public RoleInstancesOnQuoteRatePlanController(ApexPages.StandardController stdController) {
        qrpId = stdController.getRecord().Id;
        instances = [
                SELECT id, Name, List_Price__c, Hourly_rate__c, Hours_Per_Role__c, Role_Quantity__c, Total_Hours__c
                FROM Role_Instance__c WHERE Quote_Rate_Plan_Charge__r.zqu__QuoteRatePlan__c = :qrpId];
    }
//
//    public RoleInstancesOnQuoteRatePlanController() {
//        Id quoteId = ApexPages.currentPage().getParameters().get('quoteId');
//        instances = [SELECT id, Name, List_Price__c, Hourly_rate__c, Hours_Per_Role__c, Role_Quantity__c, Total_Hours__c
//                FROM Role_Instance__c WHERE Quote_Rate_Plan_Charge__r.zqu__QuoteRatePlan__r.zqu__Quote__c = :quoteId];
//    }
}