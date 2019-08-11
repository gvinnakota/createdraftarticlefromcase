public with sharing class RoleInstanceCreator {
    private Map<Id, zqu__QuoteRatePlanCharge__c> quoteRatePlanChargesMap = new Map<Id, zqu__QuoteRatePlanCharge__c>();
    private Map<Id, String> qrpcId2CurrencyCode = new Map<Id, String>();
    private Map<Id, List<zqu__QuoteRatePlanCharge__c>> productRPC2quoteRPC = new Map<Id, List<zqu__QuoteRatePlanCharge__c>>();
    private Map<Id, List<Role_to_PRPC_Map__c>> productId2ActiveRolesMap = new Map<Id, List<Role_to_PRPC_Map__c>>();
    private List<Role_Instance__c> roleInstancesToInsert = new List<Role_Instance__c>();

    public void add(zqu__QuoteRatePlanCharge__c qrpc) {
        if (isApplicable(qrpc)) {
            quoteRatePlanChargesMap.put(qrpc.Id, qrpc);
            if (productRPC2quoteRPC.containsKey(qrpc.zqu__ProductRatePlanCharge__c)) {
                productRPC2quoteRPC.get(qrpc.zqu__ProductRatePlanCharge__c).add(qrpc);
            } else {
                productRPC2quoteRPC.put(qrpc.zqu__ProductRatePlanCharge__c, new List<zqu__QuoteRatePlanCharge__c> {qrpc});
            }
        }
    }

    public void process() {
        if (!productRPC2quoteRPC.isEmpty()) {
            collectActiveRoles();
            collectCurrencyCodes();
            insertRoleInstances();
        }
    }

    private Boolean isApplicable(zqu__QuoteRatePlanCharge__c qrpc) {
        return true;
    }

    private void collectActiveRoles() {
        for (zqu__ProductRatePlanCharge__c prpc : [
                SELECT Name,
                (SELECT Role__c,
                        Role__r.Name,
                        Role__r.Hourly_Rate__c,
                        Role__r.CurrencyIsoCode
                FROM Role_to_PRPC_Map__r
                WHERE Status__c = :RoleHelper.STATUS_ROLE_MAPPING_ACTIVE)
                FROM zqu__ProductRatePlanCharge__c
                WHERE Id IN :productRPC2quoteRPC.keySet()
        ]) {
            if (!prpc.Role_to_PRPC_Map__r.isEmpty()) {
                productId2ActiveRolesMap.put(prpc.Id, prpc.Role_to_PRPC_Map__r);
            }
        }
    }

    private void insertRoleInstances() {
        for (zqu__QuoteRatePlanCharge__c qrpc : quoteRatePlanChargesMap.values()) {
            if (productId2ActiveRolesMap.containsKey(qrpc.zqu__ProductRatePlanCharge__c)) {
//                roleInstancesToInsert.addAll(RoleToRoleInstanceConverter.convert(productId2ActiveRolesMap.get(qrpc.zqu__ProductRatePlanCharge__c), qrpc.Id));
                RoleToRoleInstanceConverter converter = new RoleToRoleInstanceConverter()
                        .withQuoteRPCId(qrpc.Id);
                for (Role_to_PRPC_Map__c mapping : productId2ActiveRolesMap.get(qrpc.zqu__ProductRatePlanCharge__c)) {
                    if (null != mapping.Role__r && mapping.Role__r.CurrencyIsoCode == qrpcId2CurrencyCode.get(qrpc.Id)) {
                        roleInstancesToInsert.add(converter.withRole(mapping.Role__r).convert());
                    }
                }
            }
        }
        insert roleInstancesToInsert;
    }

    private void collectCurrencyCodes() {
        for (zqu__QuoteRatePlanCharge__c qrpc : [
                SELECT zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Currency__c
                FROM zqu__QuoteRatePlanCharge__c
                WHERE Id IN :quoteRatePlanChargesMap.keySet()
        ]) {
            qrpcId2CurrencyCode.put(qrpc.Id, qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Currency__c);
        }
    }
}