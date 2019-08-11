@IsTest
public with sharing class TestRoleToPrpcMapBuilder {

    private Role_to_PRPC_Map__c roleMap;

    public TestRoleToPrpcMapBuilder() {
        this.roleMap = new Role_to_PRPC_Map__c();
    }

    public TestRoleToPrpcMapBuilder withRoleId(Id roleId) {
        this.roleMap.Role__c = roleId;
        return this;
    }

    public TestRoleToPrpcMapBuilder withPrpc(Id prpcId) {
        this.roleMap.Product_Rate_Plan_Charge__c = prpcId;
        return this;
    }

    public TestRoleToPrpcMapBuilder withStatus(String status) {
        this.roleMap.Status__c = status;
        return this;
    }

    public Role_to_PRPC_Map__c buildWithoutSave() {
        if (roleMap.Status__c == null) {
            roleMap.Status__c = RoleHelper.STATUS_ROLE_MAPPING_ACTIVE;
        }
        return roleMap;
    }

    public Role_to_PRPC_Map__c build() {
        insert roleMap;
        return roleMap;
    }

    public Role_to_PRPC_Map__c buildMultipleWithoutSave() {
        Role_to_PRPC_Map__c tmp = buildWithoutSave();
        this.roleMap = roleMap.clone();
        return tmp;
    }

    public static List<Role_to_PRPC_Map__c> assignRolesToPrpc(Id prpcId, List<Role__c> roles) {
        List<Role_to_PRPC_Map__c> mappings = new List<Role_to_PRPC_Map__c>();
        TestRoleToPrpcMapBuilder builder = new TestRoleToPrpcMapBuilder()
            .withPrpc(prpcId);
        for (Role__c role : roles) {
            mappings.add(builder
                .withRoleId(role.Id)
                .buildMultipleWithoutSave());
        }
        return mappings;
    }
}