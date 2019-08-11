global class ZQuoteEmailMasker implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, zqu__Opportunity__r.Name FROM zqu__Quote__c WHERE Ship_Contact_Email__c != \'fakeEmail@zuora.com\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<zqu__Quote__c> quotes) {
        List<zqu__Quote__c> badQuotes = new List<zqu__Quote__c>();
        List<zqu__Quote__c> goodQuotes = new List<zqu__Quote__c>();

        for (zqu__Quote__c quote : quotes) {
            if(quote.zqu__Opportunity__r.Name == null) {
                badQuotes.add(quote);
            } else {
                quote.Ship_Contact_Email__c = 'fakeEmail@zuora.com';
                goodQuotes.add(quote);
            }
        }

        delete badQuotes;
        update goodQuotes;
    }

    global void finish(Database.BatchableContext BC) {}
}