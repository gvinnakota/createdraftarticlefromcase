public with sharing class RolesToAssignController {

    public List<RoleWrapper> roles {get; private set;}
    private Id qrpcId;

    public RolesToAssignController() {
        qrpcId = ApexPages.currentPage().getParameters().get('qrpcId');
        roles = new List<RoleWrapper>();
        for (Role__c r : RoleHelper.findRolesAssignableToCustomQRPC(qrpcId)) {
            roles.add(new RoleWrapper(r));
        }
    }

    public PageReference addSelectedRoles() {
        List<Role_Instance__c> instances = new List<Role_Instance__c>();
        RoleToRoleInstanceConverter converter = new RoleToRoleInstanceConverter().withQuoteRPCId(qrpcId);
        for (RoleWrapper wrp : roles) {
            if (wrp.selected) {
                instances.add(converter.withRole(wrp.role).convert());
            }
        }
        insert instances;
        return null;
    }

    private class RoleWrapper {
        public Role__c role {get; private set;}
        public Boolean selected {get; set;}

        public RoleWrapper(Role__c role) {
            this.role = role;
            selected = false;
        }
    }
}