@isTest
public with sharing class OpportunityLineItemValidationsBasic_Test {

    /* Test Methods */

    static testMethod void OL002_software_type_not_available_for_non_product_skus() {
         TestDataUtil.dataValueMapCSData();
        User salesUser = generateUser();
        OpportunityLineItem oppLine = generateOpportunityLineItem(salesUser.Id, 'SVC-0000');

        Test.startTest();

        System.runAs(salesUser) {
            try {
                insert oppLine;
                System.assert(false, 'Software Type invalid for non-Product SKUs');
            } catch (DmlException ex) {
                System.assert(ex.getMessage().contains('[OL002]'));
            }
        }

        Test.stopTest();
    }

    static testMethod void OL003_software_type_required_for_product_skus() {
         TestDataUtil.dataValueMapCSData();
        User salesUser = generateUser();
        OpportunityLineItem oppLine = generateOpportunityLineItem(salesUser.Id, 'SSS-0000');

        Test.startTest();

        System.runAs(salesUser) {
            try {
                oppLine.Software_Type__c = '';
                oppLine.Months__c = 12;
                insert oppLine;
                System.assert(false, 'Software Type required for SSS Products');
            } catch (DmlException ex) {
                System.assert(ex.getMessage().contains('[OL003]'));
            }
        }

        Test.stopTest();
    }

    static testMethod void OL004_months_forbidden_for_perpetual_software_type() {
         TestDataUtil.dataValueMapCSData();
        User salesUser = generateUser();
        OpportunityLineItem oppLine = generateOpportunityLineItem(salesUser.Id, 'SSS-0000');

        Test.startTest();

        System.runAs(salesUser) {
            try {
                oppLine.Software_Type__c = 'Perpetual';
                insert oppLine;
                System.assert(false, 'Months not allowed for Perpetual Sotware Type');
            } catch (DmlException ex) {
                System.assert(ex.getMessage().contains('[OL004]'));
            }
        }

        Test.stopTest();
    }

    static testMethod void OL005_months_required_for_subscription_or_maintenance_software_type() {
         TestDataUtil.dataValueMapCSData();
        User salesUser = generateUser();
        OpportunityLineItem oppLine = generateOpportunityLineItem(salesUser.Id, 'SSS-0000');

        Test.startTest();

        System.runAs(salesUser) {
            try {
                oppLine.Months__c = null;
                insert oppLine;
                //System.assert(false, 'Months Required for Subscription Type');
            } catch (DmlException ex) {
                System.assert(ex.getMessage().contains('[OL005]'));
            }
        }

        Test.stopTest();
    }

    /* Private Methods */

    private static User generateUser() {
        Profile userProfile = TestDataFactory.createProfile('Pivotal - Sales Rep');
        return TestDataFactory.createUser(userProfile.Id, true);
    }

    private static OpportunityLineItem generateOpportunityLineItem(Id userId, String sku) {
        Account acc = TestDataFactory.createAccount(true);

        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, false);
        opp.ownerId = userId;
        insert opp;

        Product2 product = TestDataFactory.createProduct2(false);
        product.ProductCode = sku;
        insert product;

        PricebookEntry pbEntry = TestDataFactory.createPricebookEntry(product.Id, 1, true);

        return TestDataFactory.createOpportunityLineItem(opp.Id, pbEntry.Id, 150, false);
    }
}