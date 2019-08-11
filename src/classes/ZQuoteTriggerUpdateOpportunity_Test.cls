@isTest
private class ZQuoteTriggerUpdateOpportunity_Test {

    /* Test Methods */
    static testMethod void newQuotes_shouldUpdateOpportunityHasQuote() {
        Account acc = TestDataFactory.createAccount(true);
        Contact ctt = TestDataFactory.createContact(acc.Id, true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);

        Test.startTest();
        zqu__Quote__c testQuote = ZTestFactory.makeQuote(opp, ctt);
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, HasQuote__c FROM Opportunity WHERE Id = :opp.id];
        System.assertEquals(true, updatedOpp.HasQuote__c, 'Opportunity HasQuote not true');
    }

    static testMethod void newQuotes_shouldThrowErrorsWhenOppIsInvaild() {
        Account acc = TestDataFactory.createAccount(true);
        Contact ctt = TestDataFactory.createContact(acc.Id, true);

        Profile pfile = TestDataFactory.createProfile('Pivotal - Sales Manager');
        User usr = TestDataFactory.createUser(pfile.Id, true);

        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, false);
        opp.StageName = 'Agree to Purchase';
        opp.Forecast_Status__c = 'Commit';
        opp.OwnerId = usr.Id;
        insert opp;

        Test.startTest();

        System.runAs(usr) {
            try {
                zqu__Quote__c testQuote = ZTestFactory.makeQuote(opp, ctt);
                System.assert(false, 'Did not throw exception when expected');
            } catch (DmlException ex) {
                System.assertNotEquals(null, ex, 'Didn\'t get a dml exception');
            }
        }

        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, HasQuote__c FROM Opportunity WHERE Id = :opp.id];
        System.assertEquals(false, updatedOpp.HasQuote__c, 'Opportunity HasQuote not false');
    }
}