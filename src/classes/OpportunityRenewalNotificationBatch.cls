global class OpportunityRenewalNotificationBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String date120 = formatDate(120);
        String date90 = formatDate(90);
        String date60 = formatDate(60);
        String date30 = formatDate(30);

        String query = 'SELECT Id FROM Opportunity WHERE Type = \'Renew Subscription\' AND IsClosed = FALSE AND (CloseDate = ' + date120 + ' OR CloseDate = ' + date90 + ' OR CloseDate = ' + date60 + ' OR CloseDate = ' + date30 + ')';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> opps) {
        for (Opportunity opp : opps) {
            Map<String, Object> params = new Map<String, Object>();
            params.put('opportunityId', opp.Id);
            Flow.Interview.Renewal_Notification renewalNotification = new Flow.Interview.Renewal_Notification(params);
            renewalNotification.start();
        }
    }

    private String formatDate(Integer num) {
        Date tempDate = System.Today() + num;
        String month = determineZero(tempDate.month());
        String day = determineZero(tempDate.day());

        return tempDate.year() + '-' + month + '-' + day;
    }

    private String determineZero(Integer num) {
        if(num < 10) {
            return '0' + String.valueOf(num);
        } else {
            return String.valueOf(num);
        }
    }

    global void finish(Database.BatchableContext BC) {}
}