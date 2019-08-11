global class OpportunityRenewalNotificationJob implements Schedulable {
    global void execute(SchedulableContext sc) {
        OpportunityRenewalNotificationBatch oppBatch = new OpportunityRenewalNotificationBatch();
        Database.executeBatch(oppBatch);
    }
}