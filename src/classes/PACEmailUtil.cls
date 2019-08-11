public with sharing class PACEmailUtil {
    public static void sendPACNotificationEmail(Id quoteId){

        Messaging.reserveSingleEmailCapacity(1);

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

        message.toAddresses = new List<String>{PAC_Settings__c.getInstance().PAC_Email__c};
        message.subject = 'Not enough PAC keys to allocate to a Quote';
        message.senderDisplayName = 'PAC Key Allocation Process';

        message.htmlBody = 'There is not enough PAC codes to allocate to the quote.\n<br/>';
        message.htmlBody += 'Add more keys and then, use the hyperlink below to retry codes allocation.\n<br/>';
        message.htmlBody += '\n<br/>';
        message.htmlBody += '<a href="' + Url.getSalesforceBaseUrl().toExternalForm() + '/apex/PACManagement?quoteId=' + quoteId + '" target="_blank">Retry Allocation</a>';
        List<Messaging.SendEmailResult> res = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
        System.debug(res);
    }

    public static void sendNewDealEmail(Id quoteId){
        if(!String.isEmpty(PAC_Settings__c.getInstance().New_Deal_Notification_Emails__c)){
            List<String> addresses = PAC_Settings__c.getInstance().New_Deal_Notification_Emails__c.split(';');
            for (Integer i = 0; i< addresses.size(); ++i){
                addresses.set(i, addresses.get(i).trim());
            }

            Messaging.reserveSingleEmailCapacity(addresses.size());

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            message.toAddresses = addresses;
            message.subject = 'A new PAC deal just went through';
            message.senderDisplayName = 'PAC Key Allocation Process';

            message.htmlBody = 'A new deal including PACs just went through.\n<br/>';
            message.htmlBody += '\n<br/>';
            message.htmlBody += '<a href="' + Url.getSalesforceBaseUrl().toExternalForm() + '/' + quoteId + '" target="_blank">Click here to get to the quote</a>';
            List<Messaging.SendEmailResult> res = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{message});
            System.debug(res);
        }
    }
}