public with sharing class RoleToRoleInstanceConverter {
    private Role__c role;
    private Id qrpcId;
    private Role_Instance__c roleInstance;

    public RoleToRoleInstanceConverter() {
    }

    public RoleToRoleInstanceConverter withRole(Role__c role) {
        this.role = role;
        return this;
    }

    public RoleToRoleInstanceConverter withQuoteRPCId(Id qrpcId) {
        this.qrpcId = qrpcId;
        return this;
    }

    public Role_Instance__c convert() {
        roleInstance = new Role_Instance__c(
                Name = role.Name,
                Hourly_rate__c = role.Hourly_rate__c,
                Quote_Rate_Plan_Charge__c = qrpcId,
                CurrencyIsoCode = role.CurrencyIsoCode
        );
        return roleInstance;
    }

    public static List<Role_Instance__c> convert(List<Role_to_PRPC_Map__c> rolesMap, Id quoteRPCId) {
        RoleToRoleInstanceConverter converter = new RoleToRoleInstanceConverter()
                .withQuoteRPCId(quoteRPCId);
        List<Role_Instance__c> instances = new List<Role_Instance__c>();
        for (Role_to_PRPC_Map__c mapping : rolesMap) {
            if (null != mapping.Role__r) {
                instances.add(converter.withRole(mapping.Role__r).convert());
            }
        }
        return instances;
    }

    public static Role_Instance__c convert(Role__c role, Id quoteRPCId) {
        return new RoleToRoleInstanceConverter()
                .withRole(role)
                .withQuoteRPCId(quoteRPCId)
                .convert();
    }
}