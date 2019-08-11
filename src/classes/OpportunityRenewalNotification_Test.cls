@isTest
public class OpportunityRenewalNotification_Test {

    /* Test Methods */

    static testMethod void run_apex_job() {
        OpportunityRenewalNotificationJob job = new OpportunityRenewalNotificationJob();
        job.execute(null);
    }
}