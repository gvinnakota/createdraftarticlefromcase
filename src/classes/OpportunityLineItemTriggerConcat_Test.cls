@isTest
public class OpportunityLineItemTriggerConcat_Test {

    /* Test Methods */

    static testMethod void test_inserting_a_line_item() {
        Opportunity opp = generateOpportunity();
        List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>();

        oppLines.add(generateOpportunityLineItem(opp.Id, 'Osprey'));
        oppLines.add(generateOpportunityLineItem(opp.Id, 'Osprey'));
        oppLines.add(generateOpportunityLineItem(opp.Id, 'Falcon'));
        oppLines.add(generateOpportunityLineItem(opp.Id, 'Eagle'));

        Test.startTest();

        insert oppLines;

        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, Product_Concat__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Osprey; Falcon; Eagle', updatedOpp.Product_Concat__c, 'Product Concat not updated');
    }

    static testMethod void test_deleting_a_line_item() {
        Opportunity opp = generateOpportunity();
        List<OpportunityLineItem> oppLines = new List<OpportunityLineItem>();

        OpportunityLineItem ospreyLineItem = generateOpportunityLineItem(opp.Id, 'Osprey');
        OpportunityLineItem falconLineItem  = generateOpportunityLineItem(opp.Id, 'Falcon');

        oppLines.add(generateOpportunityLineItem(opp.Id, 'Osprey'));
        oppLines.add(ospreyLineItem);
        oppLines.add(falconLineItem);
        oppLines.add(generateOpportunityLineItem(opp.Id, 'Eagle'));
        insert oppLines;

        Test.startTest();

        delete ospreyLineItem;
        delete falconLineItem;

        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, Product_Concat__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Osprey; Eagle', updatedOpp.Product_Concat__c, 'Product Concat not updated');
    }

    /* Private Methods */

    private static Opportunity generateOpportunity() {
        Account acc = TestDataFactory.createAccount(true);
        return TestDataFactory.createOpportunity(acc.Id, true);
    }

    private static OpportunityLineItem generateOpportunityLineItem(Id oppId, String productName) {
        Product2 product = TestDataFactory.createProduct2(false);
        product.name = productName;
        insert product;

        PricebookEntry pbEntry = TestDataFactory.createPricebookEntry(product.Id, 100, true);

        return TestDataFactory.createOpportunityLineItem(oppId, pbEntry.Id, 100, false);
    }
}