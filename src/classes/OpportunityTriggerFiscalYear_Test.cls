@isTest
private class OpportunityTriggerFiscalYear_Test {

    // Test Close Date prior to 1/1/2017
    @isTest static void test_prior_close() {
        runTest(date.newInstance(2016,10,16),'Q4-2016',false);

    }

    // Test Close Date on the first Saturday of February - start of fiscal year
    @isTest static void test_fiscal_start() {
        runTest(date.newInstance(2017,2,4),'Q1-2018',false);
    }

    // Test Close Date within fiscal year
    @isTest static void test_within_fiscal() {
        runTest(date.newInstance(2018,9,10),'Q3-2019',false);
    }

    // Test Close Date within next fiscal year and also in next calendar year
    @isTest static void test_within_fiscal_next_year() {
        runTest(date.newInstance(2018,1,10),'Q4-2018',false);
    }

    // Test Close Date FY18
    @isTest static void test_within_fy18() {
        runTest(date.newInstance(2017,9,10),'Q3-2018',false);
    }

    // Test Close Date FY19
    @isTest static void test_within_fy19() {
        runTest(date.newInstance(2018,10,23),'Q3-2019',false);
    }

    // Test Close Date FY20
    @isTest static void test_within_fy20() {
        runTest(date.newInstance(2019,6,20),'Q2-2020',false);
    }

    // Test Close Date FY21
    @isTest static void test_within_fy21() {
        runTest(date.newInstance(2020,4,6),'Q1-2021',false);
    }

    // Test Close Date FY22
    @isTest static void test_within_fy22() {
        runTest(date.newInstance(2022,1,10),'Q4-2022',false);
    }

    // Test Close Date FY23
    @isTest static void test_within_fy23() {
        runTest(date.newInstance(2022,7,11),'Q2-2023',false);
    }

    // Test Close Date FY24
    @isTest static void test_within_fy24() {
        runTest(date.newInstance(2023,8,22),'Q3-2024',false);
    }

    // Test Close Date FY25
    @isTest static void test_within_fy25() {
        runTest(date.newInstance(2024,11,20),'Q4-2025',false);
    }

    // Test Close Date FY26
    @isTest static void test_within_fy26() {
        runTest(date.newInstance(2025,3,16),'Q1-2026',false);
    }

    // Update Test Close Date FY26
    @isTest static void update_close_date() {
        runTest(date.newInstance(2019,6,20),'Q3-2020',true);
    }

    private static void runTest(Date close, String expected, Boolean isUpdate) {
        Account acc = TestDataFactory.createAccount(true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, false);
        opp.CloseDate = close;

        insert opp;

        if (isUpdate) {
            opp.CloseDate = close.adddays(100);
            update opp;
        }

        opp = [SELECT Fiscal_Period__c FROM Opportunity WHERE Id = :opp.Id];

        System.assertEquals(expected, opp.Fiscal_Period__c);
    }
}