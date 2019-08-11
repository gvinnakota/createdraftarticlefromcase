public with sharing class QRPCWithRolesSetter {
    private List<zqu__QuoteRatePlanCharge__c> qrpcList;

    public QRPCWithRolesSetter withQRPCList(List<zqu__QuoteRatePlanCharge__c> qrpcList) {
        this.qrpcList = qrpcList;
        return this;
    }

    public void process() {
        for (zqu__QuoteRatePlanCharge__c qrpc : qrpcList) {
            qrpc.Has_Roles__c = !qrpc.Role_Instance__r.isEmpty();
        }
        update qrpcList;
    }
}