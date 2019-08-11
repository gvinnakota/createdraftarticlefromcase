/**
 * Created by klukawski on 1/25/18.
 */
@RestResource(urlMapping='/ZuoraNewSubscription')
global class ZuoraNewSubscription {
    @HttpPost
    global static String receiveNewSubscriptionNotification(String SubscriptionID, String StartDate, String EndDate) {
        Zuora_New_Subscription_Notification__c notif = new Zuora_New_Subscription_Notification__c(Name = SubscriptionID, StartDate__c = StartDate, EndDate__c = EndDate);
        insert notif;
        ZuoraRevenueSplitHelper.sendNewSubscriptionCallouts(new List<Id>{notif.Id});
        return 'Success';
    }
}