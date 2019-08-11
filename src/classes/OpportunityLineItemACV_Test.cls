@isTest
public with sharing class OpportunityLineItemACV_Test {

    /* Test Methods */
    
    static void SetupCustomSettingData(){
        TestDataUtil.dataValueMapCSData();
    }

    static testMethod void ACV_calculates_correctly_for_over_12_months() {
        SetupCustomSettingData();
        User salesUser = generateUser();
        OpportunityLineItem oppLine = generateOpportunityLineItem(salesUser.Id, 15);

        System.runAs(salesUser) {
            insert oppLine;
        }

        OpportunityLineItem updatedOppLine = [SELECT Id, Forecast_ACV__c FROM OpportunityLineItem WHERE Id = :oppLine.Id];
        System.assertEquals(120, updatedOppLine.Forecast_ACV__c, 'ACV not calculating correctly');
    }

    static testMethod void ACV_calculates_correctly_for_under_12_months() {
        SetupCustomSettingData();
        User salesUser = generateUser();
        OpportunityLineItem oppLine = generateOpportunityLineItem(salesUser.Id, 7);

        System.runAs(salesUser) {
            insert oppLine;
        }

        OpportunityLineItem updatedOppLine = [SELECT Id, Forecast_ACV__c FROM OpportunityLineItem WHERE Id = :oppLine.Id];
        System.assertEquals(150, updatedOppLine.Forecast_ACV__c, 'ACV not calculating correctly');
    }

    /* Private Methods */

    private static User generateUser() {
        Profile userProfile = TestDataFactory.createProfile('Pivotal - Sales Rep');
        return TestDataFactory.createUser(userProfile.Id, true);
    }

    private static OpportunityLineItem generateOpportunityLineItem(Id salesUserId, Integer months) {
        Account acc = TestDataFactory.createAccount(true);

        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, false);
        opp.ownerId = salesUserId;
        insert opp;

        Product2 product = TestDataFactory.createProduct2(true);
        PricebookEntry pbEntry = TestDataFactory.createPricebookEntry(product.Id, 1, true);

        OpportunityLineItem oppLine = TestDataFactory.createOpportunityLineItem(opp.Id, pbEntry.Id, 150, false);
        oppLine.Months__c = months;
        return oppLine;
    }
}