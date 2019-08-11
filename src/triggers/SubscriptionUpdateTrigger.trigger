trigger SubscriptionUpdateTrigger on zqu__Quote__c (before update, after update, after insert) {

    List<String> oppIds = new List<String>();
    if (Trigger.New.size() == 1) {
        /*
        for (zqu__Quote__c quote : Trigger.new) {
            oppIds.add(quote.zqu__Opportunity__c);
        }

        List<zqu__Quote__c> quoteList = [SELECT Id, zqu__Opportunity__c from zqu__Quote__c where zqu__Opportunity__c in :oppIds];

        Map<String, List<zqu__Quote__c>> oppToQuoteMap = new Map<String, List<zqu__Quote__c>>();

        for (zqu__Quote__c quote : quoteList) {
            if (oppToQuoteMap.get(quote.zqu__Opportunity__c) != null) {
                oppToQuoteMap.get(quote.zqu__Opportunity__c).add(quote);
            } else {
                List<zqu__Quote__c> newQList = new List<zqu__Quote__c>();
                newQList.add(quote);
                oppToQuoteMap.put(quote.zqu__Opportunity__c, newQList);
            }
        }
        */

        for (zqu__Quote__c quote : Trigger.new) {
            if (Trigger.isAfter) {

                
                if (Trigger.isUpdate) {
                    zqu__Quote__c oldquote = Trigger.oldMap.get(quote.Id);
                    if (oldquote.zqu__Status__c != 'Sent to Z-Billing' && 
                        quote.zqu__Status__c == 'Sent to Z-Billing' && 
                        !String.isEmpty(quote.zqu__ExistSubscriptionID__c)) {

                        ZuoraCalloutHandler.updateZuoraSubscription(quote.zqu__ExistSubscriptionID__c, quote.PurchaseOrder__c, quote.ChannelOrderID__c);
                    }
                }
                

                if ((quote.Primary_Quote__c == true && Trigger.isInsert) || (quote.Primary_Quote__c == true && Trigger.Old[0].Primary_Quote__c == false)) {
                    for (zqu__Quote__c oppquote : Trigger.new) {
                        oppIds.add(oppquote.zqu__Opportunity__c);
                    }

                    List<zqu__Quote__c> quoteList = [SELECT Id, zqu__Opportunity__c from zqu__Quote__c where zqu__Opportunity__c in :oppIds and Primary_Quote__c = true];

                    Map<String, List<zqu__Quote__c>> oppToQuoteMap = new Map<String, List<zqu__Quote__c>>();

                    for (zqu__Quote__c oppquote : quoteList) {
                        if (oppToQuoteMap.get(oppquote.zqu__Opportunity__c) != null) {
                            oppToQuoteMap.get(oppquote.zqu__Opportunity__c).add(oppquote);
                        } else {
                            List<zqu__Quote__c> newQList = new List<zqu__Quote__c>();
                            newQList.add(oppquote);
                            oppToQuoteMap.put(oppquote.zqu__Opportunity__c, newQList);
                        }
                    }

                    List<zqu__Quote__c> qList = oppToQuoteMap.get(quote.zqu__Opportunity__c);
                    List<zqu__Quote__c> quotesToUpdate = new List<zqu__Quote__c>();
                    for (zqu__Quote__c oppQuote : qList) {
                        if (oppQuote.Id != quote.Id && quote.Primary_Quote__c == true) {
                            zqu__Quote__c quoteToUpdate = new zqu__Quote__c();
                            quoteToUpdate.Id = oppQuote.Id;
                            quoteToUpdate.Primary_Quote__c = false;
                            quotesToUpdate.add(quoteToUpdate);
                        }
                    }
                    update quotesToUpdate;
                }
            }

            if (Trigger.isBefore) {
                if (quote.zqu__SubscriptionType__c != 'New Subscription') {
                    if (quote.zqu__Previewed_Delta_TCV__c != null) {
                        Decimal tax = 0;
                        if (quote.zqu__Previewed_Tax__c != null) {
                            tax = quote.zqu__Previewed_Tax__c;
                        }
                        quote.Amend_Preview_Total__c = quote.zqu__Previewed_Delta_TCV__c + tax;
                    }
                    
                }
                
            }
            
        }
    }
    

}