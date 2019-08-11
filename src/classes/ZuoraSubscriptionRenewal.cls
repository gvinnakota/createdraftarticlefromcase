@RestResource(urlMapping='/ZuoraSubscriptionRenewal')
global class ZuoraSubscriptionRenewal{
    @HttpPost
    global static String receiveSubscriptionRenewalNotification(String AmendmentID) {
        Zuora_Amendment_Notification__c notif = new Zuora_Amendment_Notification__c(Name=AmendmentID, Type__c = 'Renewal');
        upsert notif;
        ZuoraRevenueSplitHelper.sendAmendmentCallouts(new List<Id>{notif.Id});
        return 'Success';
    }
}