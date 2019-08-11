global class LeadEmailMasker implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Lead WHERE Email != null AND IsConverted = false';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Lead> Leads) {
        for (Lead ld : Leads) {
            ld.Email = 'fakeEmail@sfdc.com';
        }
        update Leads;
    }

    global void finish(Database.BatchableContext BC) {}
}