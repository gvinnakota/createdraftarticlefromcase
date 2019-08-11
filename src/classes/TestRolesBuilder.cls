@IsTest
public with sharing class TestRolesBuilder {

    private Role__c role;

    public TestRolesBuilder() {
        role = new Role__c();
    }

    public TestRolesBuilder withName(String name) {
        role.Name = name;
        return this;
    }

    public TestRolesBuilder withHourlyRate(Decimal hourlyRate) {
        role.Hourly_Rate__c = hourlyRate;
        return this;
    }

    public Role__c buildWithoutSave() {
        return role;
    }

    public Role__c build() {
        insert role;
        return role;
    }

    public Role__c buildMultipleWithoutSave() {
        Role__c tmp = buildWithoutSave();
        this.role = role.clone();
        return tmp;
    }

    public static List<Role__c> getTestRoles(Integer num) {
        List<Role__c> roles = new List<Role__c>();
        TestRolesBuilder builder = new TestRolesBuilder();
        for (Integer i = 0; i < num; i++) {
            roles.add(builder
                .withName('Role ' + (i+1))
                .withHourlyRate(100 + 10 * i)
                .buildMultipleWithoutSave());
        }

        return roles;
    }
}