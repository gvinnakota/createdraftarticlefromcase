@RestResource(urlMapping='/ZuoraAmendment')
global class ZuoraAmendment{
    @HttpPost
    global static String receiveSubscriptionRenewalNotification(String AmendmentID) {
        Zuora_Amendment_Notification__c notif = new Zuora_Amendment_Notification__c(Name=AmendmentID, Type__c = 'Amendment');
        upsert notif;
        ZuoraRevenueSplitHelper.sendAmendmentCallouts(new List<Id>{notif.Id});
        return 'Success';
    }
}