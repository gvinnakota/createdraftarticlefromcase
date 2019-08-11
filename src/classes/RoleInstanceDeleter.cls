public with sharing class RoleInstanceDeleter {
    private List<Id> quoteRPCId = new List<Id>();

    public void addAll(Set<Id> qrpcIds) {
        quoteRPCId.addAll(qrpcIds);
    }

    public void deleteRoleInstances() {
        delete [SELECT Id FROM Role_Instance__c WHERE Quote_Rate_Plan_Charge__c IN : quoteRPCId];
    }
}