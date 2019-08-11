global class ContactEmailMasker implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Contact WHERE Email != null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> contacts) {
        for (Contact ctt : contacts) {
            ctt.Email = 'fakeEmail@sfdc.com';
        }
        update contacts;
    }

    global void finish(Database.BatchableContext BC) {}
}