@IsTest
public class OpportunityTriggerCalculateLinkedTest {

    /**
     * One Master Opportunity with 4 sub opportunities
     * 2 sub opportunities with record type Services
     * 2 sub opportunities with record type Subscription
     * Each sub opportunity has 3 OpportunityLineItem
     */
    @TestSetup
    static void setupTest() {
        Account account = TestDataFactory.createAccount(true);
        Opportunity master = TestDataFactory.createOpportunity(account.Id, true);
        RecordType servicesRecordType = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Services'
        ];
        RecordType subscriptionRecordType = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Subscription'
        ];
        List<Opportunity> childOpportunities = new List<Opportunity>();
        for (Integer i = 0; i < 4; i++) {
            Opportunity opportunity = TestDataFactory.createOpportunity(account.Id, false);
            opportunity.Master_Opportunity_Subscription__c = master.Id;
            opportunity.Name = 'Test - ' + i;
            if (Math.mod(i, 2) == 0) {
                opportunity.RecordTypeId = servicesRecordType.Id;
            } else {
                opportunity.RecordTypeId = subscriptionRecordType.Id;
            }
            childOpportunities.add(opportunity);
            /*
            This fields should be empty or default
            AppTx_Scoping_Scheduled__c, //AppTx Scoping Scheduled
            AppTx_Scoping_Delivered_to_Customer__c, //AppTx SOW Delivered to Customer
            PCFS_Scoping_Scheduled_Date__c, //PCFS Scoping Scheduled Date
            PCFS_Scoping_Delivered_to_Customer__c //PCFS SOW Delivered to Customer
             */
        }

        insert childOpportunities;

        Product2 product2PAT = TestDataFactory.createProduct2(false);
        product2PAT.Report_Category__c = 'PaaS - App Trans';

        Product2 product2AL = TestDataFactory.createProduct2(false);
        product2AL.Report_Category__c = 'Agile - Labs';

        Product2 product2PS = TestDataFactory.createProduct2(false);
        product2PS.Report_Category__c = 'PaaS - Services';

        insert new List<Product2>{
                product2PAT, product2AL, product2PS
        };

        PricebookEntry pricebookPAT = TestDataFactory.createPricebookEntry(product2PAT.Id, 10, false);
        PricebookEntry pricebookAL = TestDataFactory.createPricebookEntry(product2AL.Id, 10, false);
        PricebookEntry pricebookPS = TestDataFactory.createPricebookEntry(product2PS.Id, 10, false);
        insert new List<PricebookEntry>{
                pricebookPAT, pricebookAL, pricebookPS
        };

        List<OpportunityLineItem> items = new List<OpportunityLineItem>();
        for (Opportunity opportunity : childOpportunities) {
            OpportunityLineItem item = TestDataFactory.createOpportunityLineItem(opportunity.Id, pricebookPAT.Id, 50, false);
            items.add(item);
            item = TestDataFactory.createOpportunityLineItem(opportunity.Id, pricebookAL.Id, 50, false);
            items.add(item);
            item = TestDataFactory.createOpportunityLineItem(opportunity.Id, pricebookPS.Id, 50, false);
            items.add(item);
        }

        insert items;
    }

    @IsTest
    static void LinkedServiceOpportunityTotalShouldUpdate() {
        Opportunity opportunity = [
                SELECT Master_Opportunity_Subscription__c, Amount
                FROM Opportunity
                WHERE Master_Opportunity_Subscription__c != NULL
                AND RecordType.Name = 'Services'
                LIMIT 1
        ];

        OpportunityLineItem lineItem = [
                SELECT Forecasted_New_Amount__c
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunity.Id
                LIMIT 1
        ];

        Test.startTest();
        lineItem.Forecasted_New_Amount__c = 100;
        update lineItem;
        Test.stopTest();

        opportunity = [
                SELECT Linked_Service_Opportunity_Total__c
                FROM Opportunity
                WHERE Id = :opportunity.Master_Opportunity_Subscription__c
        ];
        System.assertEquals(350, opportunity.Linked_Service_Opportunity_Total__c);
    }

    @IsTest
    static void LinkedSubscriptionOpportunityTotalShouldUpdate() {
        Opportunity opportunity = [
                SELECT Master_Opportunity_Subscription__c, Amount
                FROM Opportunity
                WHERE Master_Opportunity_Subscription__c != NULL
                AND RecordType.Name = 'Subscription'
                LIMIT 1
        ];

        OpportunityLineItem lineItem = [
                SELECT Forecasted_New_Amount__c
                FROM OpportunityLineItem
                WHERE OpportunityId = :opportunity.Id
                LIMIT 1
        ];

        Test.startTest();
        lineItem.Forecasted_New_Amount__c = 100;
        update lineItem;
        Test.stopTest();

        opportunity = [
                SELECT Linked_Subscription_Opportunity_Total__c
                FROM Opportunity
                WHERE Id = :opportunity.Master_Opportunity_Subscription__c
        ];
        System.assertEquals(350, opportunity.Linked_Subscription_Opportunity_Total__c);
    }

    @IsTest
    static void LinkedAppTXServicesOpportunityTotalShouldUpdate() {
        Opportunity opportunity = [
                SELECT Master_Opportunity_Subscription__c
                FROM Opportunity
                WHERE Master_Opportunity_Subscription__c != NULL
                LIMIT 1
        ];

        OpportunityLineItem lineItem = [
                SELECT Forecasted_New_Amount__c, OpportunityId
                FROM OpportunityLineItem
                WHERE Product_Portfolio_txt__c = 'PaaS - App Trans'
                AND OpportunityId = :opportunity.Id
        ];

        Test.startTest();
        lineItem.Forecasted_New_Amount__c = 256;
        update lineItem;
        Test.stopTest();

        opportunity = [
                SELECT Linked_AppTX_Services_Opportunity_Total__c
                FROM Opportunity
                WHERE Id = :opportunity.Master_Opportunity_Subscription__c
        ];

        System.assertEquals(256 + 150, opportunity.Linked_AppTX_Services_Opportunity_Total__c);
    }

    @IsTest
    static void LinkedAppTXScopingScheduledShouldUpdate() {
        Opportunity opportunity = [
                SELECT AppTx_Scoping_Scheduled__c, Master_Opportunity_Subscription__c
                FROM Opportunity
                WHERE Master_Opportunity_Subscription__c != NULL
                AND RecordType.Name = 'Services'
                LIMIT 1
        ];

        Opportunity masterOpportunity = [
                SELECT Linked_AppTX_Scoping_Scheduled__c
                FROM Opportunity
                WHERE Id = :opportunity.Master_Opportunity_Subscription__c
        ];

        System.assertEquals(false, masterOpportunity.Linked_AppTX_Scoping_Scheduled__c);

        Test.startTest();
        opportunity.AppTx_Scoping_Scheduled__c = Date.newInstance(2000, 1, 1);
        update opportunity;
        Test.stopTest();

        masterOpportunity = [
                SELECT Linked_AppTX_Scoping_Scheduled__c
                FROM Opportunity
                WHERE Id = :masterOpportunity.Id
        ];

        System.assertEquals(true, masterOpportunity.Linked_AppTX_Scoping_Scheduled__c);
    }

    @IsTest
    static void LinkedPCFSScopingScheduledDateShouldUpdate() {
        Opportunity opportunity = [
                SELECT PCFS_Scoping_Scheduled_Date__c, Master_Opportunity_Subscription__c
                FROM Opportunity
                WHERE Master_Opportunity_Subscription__c != NULL
                AND RecordType.Name = 'Services'
                LIMIT 1
        ];

        Opportunity masterOpportunity = [
                SELECT Linked_PCFS_Scoping_Scheduled_Date__c
                FROM Opportunity
                WHERE Id = :opportunity.Master_Opportunity_Subscription__c
        ];

        System.assertEquals(false, masterOpportunity.Linked_PCFS_Scoping_Scheduled_Date__c);

        Test.startTest();
        opportunity.PCFS_Scoping_Scheduled_Date__c = Date.newInstance(2000, 1, 1);
        update opportunity;
        Test.stopTest();

        masterOpportunity = [
                SELECT Linked_PCFS_Scoping_Scheduled_Date__c
                FROM Opportunity
                WHERE Id = :masterOpportunity.Id
        ];

        System.assertEquals(true, masterOpportunity.Linked_PCFS_Scoping_Scheduled_Date__c);
    }

    @IsTest
    static void LinkedPCFSSOWDeliveredToCustomerShouldUpdate() {
        Opportunity opportunity = [
                SELECT PCFS_Scoping_Delivered_to_Customer__c, Master_Opportunity_Subscription__c
                FROM Opportunity
                WHERE Master_Opportunity_Subscription__c != NULL
                AND RecordType.Name = 'Services'
                LIMIT 1
        ];

        Opportunity masterOpportunity = [
                SELECT Linked_PCFS_SOW_Delivered_to_Customer__c
                FROM Opportunity
                WHERE Id = :opportunity.Master_Opportunity_Subscription__c
        ];

        System.assertEquals(false, masterOpportunity.Linked_PCFS_SOW_Delivered_to_Customer__c);

        Test.startTest();
        opportunity.PCFS_Scoping_Delivered_to_Customer__c = true;
        update opportunity;
        Test.stopTest();

        masterOpportunity = [
                SELECT Linked_PCFS_SOW_Delivered_to_Customer__c
                FROM Opportunity
                WHERE Id = :masterOpportunity.Id
        ];

        System.assertEquals(true, masterOpportunity.Linked_PCFS_SOW_Delivered_to_Customer__c);
    }

    @IsTest
    static void LinkedAppTxSOWDeliveredToCustomerShouldUpdate() {
        Opportunity opportunity = [
                SELECT AppTx_Scoping_Delivered_to_Customer__c, Master_Opportunity_Subscription__c
                FROM Opportunity
                WHERE Master_Opportunity_Subscription__c != NULL
                AND RecordType.Name = 'Services'
                LIMIT 1
        ];

        Opportunity masterOpportunity = [
                SELECT Linked_AppTx_SOW_Delivered_to_Customer__c
                FROM Opportunity
                WHERE Id = :opportunity.Master_Opportunity_Subscription__c
        ];

        System.assertEquals(false, masterOpportunity.Linked_AppTx_SOW_Delivered_to_Customer__c);

        Test.startTest();
        opportunity.AppTx_Scoping_Delivered_to_Customer__c = true;
        update opportunity;
        Test.stopTest();

        masterOpportunity = [
                SELECT Linked_AppTx_SOW_Delivered_to_Customer__c
                FROM Opportunity
                WHERE Id = :masterOpportunity.Id
        ];

        System.assertEquals(true, masterOpportunity.Linked_AppTx_SOW_Delivered_to_Customer__c);
    }

    @IsTest
    static void LinkedLabsScopingScheduledShouldUpdate() {
        Opportunity opportunity = [
                SELECT Scoping_Scheduled__c, Master_Opportunity_Subscription__c
                FROM Opportunity
                WHERE Master_Opportunity_Subscription__c != NULL
                AND RecordType.Name = 'Services'
                LIMIT 1
        ];

        Opportunity masterOpportunity = [
                SELECT Linked_Labs_Scoping_Scheduled__c
                FROM Opportunity
                WHERE Id = :opportunity.Master_Opportunity_Subscription__c
        ];

        System.assertEquals(false, masterOpportunity.Linked_Labs_Scoping_Scheduled__c);

        Test.startTest();
        opportunity.Scoping_Scheduled__c = Date.newInstance(2000, 1, 1);
        update opportunity;
        Test.stopTest();

        masterOpportunity = [
                SELECT Linked_Labs_Scoping_Scheduled__c
                FROM Opportunity
                WHERE Id = :masterOpportunity.Id
        ];

        System.assertEquals(true, masterOpportunity.Linked_Labs_Scoping_Scheduled__c);
    }

    @IsTest
    static void PCFServicesOpportunityTotalShouldUpdate() {
        Opportunity opportunity = [
                SELECT Master_Opportunity_Subscription__c
                FROM Opportunity
                WHERE Master_Opportunity_Subscription__c != NULL
                LIMIT 1
        ];

        OpportunityLineItem lineItem = [
                SELECT Forecasted_New_Amount__c, OpportunityId, TotalPrice
                FROM OpportunityLineItem
                WHERE Product_Portfolio_txt__c = 'PaaS - Services'
                AND OpportunityId = :opportunity.Id
        ];

        Test.startTest();
        lineItem.Forecasted_New_Amount__c = 256;
        update lineItem;
        Test.stopTest();

        opportunity = [
                SELECT Linked_PCF_Services_Opportunity_Total__c
                FROM Opportunity
                WHERE Id = :opportunity.Master_Opportunity_Subscription__c
        ];

        System.assertEquals(256 + 150, opportunity.Linked_PCF_Services_Opportunity_Total__c);
    }

    @IsTest
    static void LinkedLabsServicesOpportunityTotalShouldUpdate() {
        Opportunity opportunity = [
                SELECT Master_Opportunity_Subscription__c
                FROM Opportunity
                WHERE Master_Opportunity_Subscription__c != NULL
                LIMIT 1
        ];

        OpportunityLineItem lineItem = [
                SELECT Forecasted_New_Amount__c, OpportunityId, TotalPrice
                FROM OpportunityLineItem
                WHERE Product_Portfolio_txt__c = 'Agile - Labs'
                AND OpportunityId = :opportunity.Id
        ];

        Test.startTest();
        lineItem.Forecasted_New_Amount__c = 256;
        update lineItem;
        Test.stopTest();

        opportunity = [
                SELECT Linked_Labs_Services_Opportunity_Total__c
                FROM Opportunity
                WHERE Id = :opportunity.Master_Opportunity_Subscription__c
        ];

        System.assertEquals(256 + 150, opportunity.Linked_Labs_Services_Opportunity_Total__c);
    }

    @IsTest
    static void LinkedAllServicesOpportunityTotalShouldUpdate() {
        Opportunity opportunity = [
                SELECT Master_Opportunity_Subscription__c
                FROM Opportunity
                WHERE Master_Opportunity_Subscription__c != NULL
                LIMIT 1
        ];

        OpportunityLineItem lineItem = [
                SELECT Forecasted_New_Amount__c, OpportunityId
                FROM OpportunityLineItem
                WHERE Product_Portfolio_txt__c = 'Agile - Labs'
                AND OpportunityId = :opportunity.Id
        ];

        Test.startTest();
        lineItem.Forecasted_New_Amount__c = 256;
        update lineItem;
        Test.stopTest();

        opportunity = [
                SELECT Linked_All_Services_Opportunity_Total__c
                FROM Opportunity
                WHERE Id = :opportunity.Master_Opportunity_Subscription__c
        ];

        System.assertEquals(256 + 350, opportunity.Linked_All_Services_Opportunity_Total__c);
    }


    @IsTest
    static void LinkedDataScopingCompleteShouldUpdate() {
        Opportunity opportunity = [
                SELECT Data_Scoping_Complete__c, Master_Opportunity_Subscription__c
                FROM Opportunity
                WHERE Master_Opportunity_Subscription__c != NULL
                LIMIT 1
        ];

        Opportunity masterOpportunity = [
                SELECT Linked_Data_Scoping_Complete__c
                FROM Opportunity
                WHERE Id = :opportunity.Master_Opportunity_Subscription__c
        ];

        System.assertEquals(false, masterOpportunity.Linked_Data_Scoping_Complete__c);

        Test.startTest();
        opportunity.Data_Scoping_Complete__c = true;
        update opportunity;
        Test.stopTest();

        opportunity = [
                SELECT Data_Scoping_Complete__c
                FROM Opportunity
                WHERE Id = :opportunity.Id
        ];

        System.assert(opportunity.Data_Scoping_Complete__c);

        masterOpportunity = [
                SELECT Linked_Data_Scoping_Complete__c
                FROM Opportunity
                WHERE Id = :masterOpportunity.Id
        ];

        System.assertEquals(true, masterOpportunity.Linked_Data_Scoping_Complete__c);
    }

    @IsTest
    static void LinkedLabsScopingCompleteShouldUpdate() {
        Opportunity opportunity = [
                SELECT Labs_Scoping_Complete__c, Master_Opportunity_Subscription__c
                FROM Opportunity
                WHERE Master_Opportunity_Subscription__c != NULL
                LIMIT 1
        ];

        Opportunity masterOpportunity = [
                SELECT Linked_Labs_Scoping_Complete__c
                FROM Opportunity
                WHERE Id = :opportunity.Master_Opportunity_Subscription__c
        ];

        System.assertEquals(false, masterOpportunity.Linked_Labs_Scoping_Complete__c);

        Test.startTest();
        opportunity.Labs_Scoping_Complete__c = true;
        update opportunity;
        Test.stopTest();

        opportunity = [
                SELECT Labs_Scoping_Complete__c
                FROM Opportunity
                WHERE Id = :opportunity.Id
        ];

        System.assert(opportunity.Labs_Scoping_Complete__c);

        masterOpportunity = [
                SELECT Linked_Labs_Scoping_Complete__c
                FROM Opportunity
                WHERE Id = :masterOpportunity.Id
        ];

        System.assertEquals(true, masterOpportunity.Linked_Labs_Scoping_Complete__c);
    }

    @IsTest
    static void servicesPercentageOfTotalDealTest() {
        Opportunity opportunity = [
                SELECT Services_Percentage_Of_Total_Deal__c
                FROM Opportunity
                WHERE Master_Opportunity_Subscription__c = NULL
                LIMIT 1
        ];
        System.assertEquals(50, opportunity.Services_Percentage_Of_Total_Deal__c);
    }
}