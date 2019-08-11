@IsTest
public with sharing class TestPACBuilder {

    private PAC__c pac;

    public TestPACBuilder() {
        pac = new PAC__c();
    }

    public TestPACBuilder withCode(String code) {
        this.pac.Code__c = code;
        return this;
    }

    public TestPACBuilder withProduct(String product) {
        this.pac.Product__c = product;
        return this;
    }

    public TestPACBuilder withDuration(Decimal duration) {
        this.pac.Duration__c = duration;
        return this;
    }

    public TestPACBuilder withQuantity(Decimal quantity) {
        this.pac.Quantity__c = quantity;
        return this;
    }

    public TestPACBuilder withKey(String key) {
        this.pac.Key__c = key;
        return this;
    }

    public PAC__c buildWithoutSave() {
        return pac;
    }

    public PAC__c build() {
        buildWithoutSave();
        insert pac;
        return pac;
    }

    public PAC__c buildWithoutSaveAndClone() {
        PAC__c tmp = buildWithoutSave();
        this.pac = pac.clone();
        return tmp;
    }
}