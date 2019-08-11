trigger RoleInstanceTrigger on Role_Instance__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (BOE_Settings__c.getOrgDefaults() != null && BOE_Settings__c.getOrgDefaults().CSC_on__c != null && BOE_Settings__c.getOrgDefaults().CSC_on__c){
        new RoleInstanceTriggerHandler().run();
    }

}