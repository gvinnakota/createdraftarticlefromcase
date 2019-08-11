@isTest
public class OpportunityTriggerFirstProductDate_Test {

    /* Test Methods */

    static testmethod void account_test_PCF_date_no_parent() {
        List<Opportunity> oppList = new List<Opportunity>();
        Account acc = TestDataFactory.createAccount(true);
        
        // changed to create 4 opportunity instead of 8;    
        for(Integer i=0; i<2 ; i++) {
            oppList.add(setupOpportunity('PaaS', acc.Id));
        }

        Test.startTest();

        update oppList;

        Test.stopTest();

        testChildAccountPCFDate(acc.Id);
    }

    static testmethod void account_test_data_products_date_no_parent() {
        List<Opportunity> oppList = new List<Opportunity>();
        Account acc = TestDataFactory.createAccount(true);

        for(Integer i=0; i<2 ; i++) {
            oppList.add(setupOpportunity('Data - Big Data Suite', acc.Id));
        }

        Test.startTest();

        update oppList;

        Test.stopTest();

        testChildAccountDataProductDate(acc.Id);
    }

    static testmethod void account_test_labs_date_no_parent() {
        List<Opportunity> oppList = new List<Opportunity>();
        Account acc = TestDataFactory.createAccount(true);

        for(Integer i=0; i<8 ; i++) {
            oppList.add(setupOpportunity('Agile - Labs', acc.Id));
        }

        Test.startTest();

        update oppList;

        Test.stopTest();

        testChildAccountLabsDate(acc.Id);
    }

    static testmethod void account_test_all_product_dates_no_parent() {
        List<Opportunity> oppList = new List<Opportunity>();
        Account acc = TestDataFactory.createAccount(true);

        for(Integer i=0; i<2 ; i++) {
            oppList.add(setupOpportunity('PaaS', acc.Id));
            oppList.add(setupOpportunity('Data - Big Data Suite', acc.Id));
            oppList.add(setupOpportunity('Agile - Labs', acc.Id));
        }

        Test.startTest();

        update oppList;

        Test.stopTest();

        testChildAccountPCFDate(acc.Id);
        testChildAccountDataProductDate(acc.Id);
        testChildAccountLabsDate(acc.Id);
    }

    static testmethod void account_test_PCF_date_with_parent() {
        List<Opportunity> oppList = new List<Opportunity>();
        Account parentAcc = TestDataFactory.createAccount(true);

        Account childAcc1 = TestDataFactory.createAccount(false);
        childAcc1.ParentId = parentAcc.Id;
        insert childAcc1;

        Account childAcc2 = TestDataFactory.createAccount(false);
        childAcc2.ParentId = parentAcc.Id;
        insert childAcc2;

        for(Integer i=0; i<2 ; i++) {
            oppList.add(setupOpportunity('PaaS', parentAcc.Id));
            oppList.add(setupOpportunity('PaaS', childAcc1.Id));
            oppList.add(setupOpportunity('PaaS', childAcc2.Id));
        }

        Test.startTest();

        update oppList;

        Test.stopTest();

        testChildAccountPCFDate(childAcc1.Id);
        testChildAccountPCFDate(childAcc2.Id);
        testParentAccountPCFDate(parentAcc.Id, childAcc1.Id, childAcc2.Id);
    }

    static testmethod void account_test_data_products_date_with_parent() {
        List<Opportunity> oppList = new List<Opportunity>();
        Account parentAcc = TestDataFactory.createAccount(true);

        Account childAcc1 = TestDataFactory.createAccount(false);
        childAcc1.ParentId = parentAcc.Id;
        insert childAcc1;

        Account childAcc2 = TestDataFactory.createAccount(false);
        childAcc2.ParentId = parentAcc.Id;
        insert childAcc2;

        for(Integer i=0; i<2 ; i++) {
            oppList.add(setupOpportunity('Data - Big Data Suite', parentAcc.Id));
            oppList.add(setupOpportunity('Data - Big Data Suite', childAcc1.Id));
            oppList.add(setupOpportunity('Data - Big Data Suite', childAcc2.Id));
        }

        Test.startTest();

        update oppList;

        Test.stopTest();

        testChildAccountDataProductDate(childAcc1.Id);
        testChildAccountDataProductDate(childAcc2.Id);
        testParentAccountDataProductDate(parentAcc.Id, childAcc1.Id, childAcc2.Id);
    }

    static testmethod void account_test_labs_date_with_parent() {
        List<Opportunity> oppList = new List<Opportunity>();
        Account parentAcc = TestDataFactory.createAccount(true);

        Account childAcc1 = TestDataFactory.createAccount(false);
        childAcc1.ParentId = parentAcc.Id;
        insert childAcc1;

        Account childAcc2 = TestDataFactory.createAccount(false);
        childAcc2.ParentId = parentAcc.Id;
        insert childAcc2;

        for(Integer i=0; i<2 ; i++) {
            oppList.add(setupOpportunity('Agile - Labs', parentAcc.Id));
            oppList.add(setupOpportunity('Agile - Labs', childAcc1.Id));
            oppList.add(setupOpportunity('Agile - Labs', childAcc2.Id));
        }

        Test.startTest();

        update oppList;

        Test.stopTest();

        testChildAccountLabsDate(childAcc1.Id);
        testChildAccountLabsDate(childAcc2.Id);
        testParentAccountLabsDate(parentAcc.Id, childAcc1.Id, childAcc2.Id);
    }

    /*  
    static testmethod void account_test_all_product_dates_with_parent() {
        List<Opportunity> oppList = new List<Opportunity>();
        Account parentAcc = TestDataFactory.createAccount(true);

        Account childAcc1 = TestDataFactory.createAccount(false);
        childAcc1.ParentId = parentAcc.Id;
        insert childAcc1;

        Account childAcc2 = TestDataFactory.createAccount(false);
        childAcc2.ParentId = parentAcc.Id;
        insert childAcc2;
    
        testParentAccountPCFDate(parentAcc.Id, childAcc1.Id, childAcc2.Id);
        testParentAccountDataProductDate(parentAcc.Id, childAcc1.Id, childAcc2.Id);
        testParentAccountLabsDate(parentAcc.Id, childAcc1.Id, childAcc2.Id);
   
    }
    */
    
    static testmethod void account_test_all_product_dates_with_parent_Old() {
        List<Opportunity> oppList = new List<Opportunity>();
        Account parentAcc = TestDataFactory.createAccount(true);

        Account childAcc1 = TestDataFactory.createAccount(false);
        childAcc1.ParentId = parentAcc.Id;
        insert childAcc1;

        Account childAcc2 = TestDataFactory.createAccount(false);
        childAcc2.ParentId = parentAcc.Id;
        insert childAcc2;

        oppList.add(setupOpportunity('PaaS', parentAcc.Id));
        oppList.add(setupOpportunity('Data - Big Data Suite', parentAcc.Id));
        oppList.add(setupOpportunity('Agile - Labs', parentAcc.Id));

        oppList.add(setupOpportunity('PaaS', childAcc1.Id));
        oppList.add(setupOpportunity('Data - Big Data Suite', childAcc1.Id));
        oppList.add(setupOpportunity('Agile - Labs', childAcc1.Id));

        oppList.add(setupOpportunity('PaaS', childAcc2.Id));
        oppList.add(setupOpportunity('Data - Big Data Suite', childAcc2.Id));

        Test.startTest();

        update oppList;

        Test.stopTest();


        testParentAccountPCFDate(parentAcc.Id, childAcc1.Id, childAcc2.Id);
        testParentAccountDataProductDate(parentAcc.Id, childAcc1.Id, childAcc2.Id);
        testParentAccountLabsDate(parentAcc.Id, childAcc1.Id, childAcc2.Id);
   
    }    
    

    /*
    static testmethod void account_test_all_product_dates_with_parentEx() {
        List<Opportunity> oppList = new List<Opportunity>();
        Account parentAcc = TestDataFactory.createAccount(true);

        Account childAcc1 = TestDataFactory.createAccount(false);
        childAcc1.ParentId = parentAcc.Id;
        insert childAcc1;

        Account childAcc2 = TestDataFactory.createAccount(false);
        childAcc2.ParentId = parentAcc.Id;
        insert childAcc2;

        oppList.add(setupOpportunity('PaaS', parentAcc.Id));
        oppList.add(setupOpportunity('Data - Big Data Suite', parentAcc.Id));
        oppList.add(setupOpportunity('Agile - Labs', parentAcc.Id));



        Test.startTest();

        update oppList;

        Test.stopTest();
    }
    */
    
    /* Private Methods */

    private static Opportunity setupOpportunity(String reportCategory, Id accId) {
        Opportunity opp = TestDataFactory.createOpportunity(accId, true);
        opp.CloseDate = System.today() - Math.round(Math.random()*1000);
        opp.StageName = 'Booked';

        Product2 product = TestDataFactory.createProduct2(true);
        product.Report_Category__c = reportCategory;
        update product;

        Pricebook2 pricebook = TestDataFactory.createPricebook2(true);
        PricebookEntry pbEntry = TestDataFactory.createPricebookEntry(product.Id, 5000.00, true);

        OpportunityLineItem oppLineItem = TestDataFactory.createOpportunityLineItem(opp.Id, pbEntry.Id, 500.00, false);
        oppLineItem.Software_Type__c = 'Subscription';
        oppLineItem.Years__c = '1';
        insert oppLineItem;

        return opp;
    }

    private static void testChildAccountPCFDate(Id accId) {
        Account updatedAcc = [SELECT Id, First_Purchase_Date_PCF__c FROM Account WHERE Id = :accId];
        List<AggregateResult> minCloseDate = [SELECT min(closeDate)date FROM Opportunity WHERE AccountId = :accId AND Total_Pivotal_CF_Product__c > 0];
        System.assertEquals(minCloseDate[0].get('date'), updatedAcc.First_Purchase_Date_PCF__c, 'Child Account\'s First PCF date is incorrect');
    }

    private static void testParentAccountPCFDate(Id parentAccId, Id childAcc1Id, Id childAcc2Id) {
        Account updatedParentAcc = [SELECT Id, First_Purchase_Date_PCF__c FROM Account WHERE Id = :parentAccId];
        List<AggregateResult> minCloseDate = [SELECT min(closeDate)date FROM Opportunity WHERE (AccountId = :parentAccId OR AccountId = :childAcc1Id OR AccountId = :childAcc2Id) AND Total_Pivotal_CF_Product__c > 0];
        System.assertEquals(minCloseDate[0].get('date'), updatedParentAcc.First_Purchase_Date_PCF__c, 'Parent Account\'s First PCF date is incorrect');
    }

    private static void testChildAccountDataProductDate(Id accId) {
        Account updatedAcc = [SELECT Id, First_Purchase_Date_Data_Products__c FROM Account WHERE Id = :accId];
        List<AggregateResult> minCloseDate = [SELECT min(closeDate)date FROM Opportunity WHERE AccountId = :accId AND Total_Data_Product__c > 0];
        System.assertEquals(minCloseDate[0].get('date'), updatedAcc.First_Purchase_Date_Data_Products__c, 'Child Account\'s First Data Product date is incorrect');
    }

    private static void testParentAccountDataProductDate(Id parentAccId, Id childAcc1Id, Id childAcc2Id) {
        Account updatedParentAcc = [SELECT Id, First_Purchase_Date_Data_Products__c FROM Account WHERE Id = :parentAccId];
        List<AggregateResult> minCloseDate = [SELECT min(closeDate)date FROM Opportunity WHERE (AccountId = :parentAccId OR AccountId = :childAcc1Id OR AccountId = :childAcc2Id) AND Total_Data_Product__c > 0];
        System.assertEquals(minCloseDate[0].get('date'), updatedParentAcc.First_Purchase_Date_Data_Products__c, 'Parent Account\'s First Data Product date is incorrect');
    }

    private static void testChildAccountLabsDate(Id accId) {
        Account updatedAcc = [SELECT Id, First_Purchase_Date_Labs__c FROM Account WHERE Id = :accId];
        List<AggregateResult> minCloseDate = [SELECT min(closeDate)date FROM Opportunity WHERE AccountId = :accId AND Total_Pivotal_Labs__c > 0];
        System.assertEquals(minCloseDate[0].get('date'), updatedAcc.First_Purchase_Date_Labs__c, 'Child Account\'s First Labs date is incorrect');
    }

    private static void testParentAccountLabsDate(Id parentAccId, Id childAcc1Id, Id childAcc2Id) {
        Account updatedParentAcc = [SELECT Id, First_Purchase_Date_Labs__c FROM Account WHERE Id = :parentAccId];
        List<AggregateResult> minCloseDate = [SELECT min(closeDate)date FROM Opportunity WHERE (AccountId = :parentAccId OR AccountId = :childAcc1Id OR AccountId = :childAcc2Id) AND Total_Pivotal_Labs__c > 0];
        System.assertEquals(minCloseDate[0].get('date'), updatedParentAcc.First_Purchase_Date_Labs__c, 'Parent Account\'s First Labs date is incorrect');
    }
}