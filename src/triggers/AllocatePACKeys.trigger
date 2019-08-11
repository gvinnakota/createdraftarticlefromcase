trigger AllocatePACKeys on zqu__Quote__c (after update) {
    System.debug('TriggerRun');
    Set<Id> quotes = Trigger.newMap.keySet();

    List<PAC_Product_Map__c> appliableProducts = [SELECT Product2__c FROM PAC_Product_Map__c WHERE Active__c = TRUE];
    Set<Id> appliableProductIds = new Set<Id>();

    for(PAC_Product_Map__c appliableProduct: appliableProducts){
        appliableProductIds.add(appliableProduct.Product2__c);
    }

    List<zqu__QuoteRatePlanCharge__c> qrpcs = [
            SELECT Id, zqu__QuoteRatePlan__r.zqu__Quote__c, zqu__Quantity__c, Initial_Term__c,
                    zqu__ProductRatePlanCharge__c, Total_Unit_Quantity__c,
                    zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c, Start_Date__c//, zqu__ProductRatePlanCharge__r.UOMmultiplier__c
            FROM zqu__QuoteRatePlanCharge__c
            WHERE zqu__QuoteRatePlan__r.zqu__Quote__c IN :quotes
                AND zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c IN :appliableProductIds];

    Map<Id, List<zqu__QuoteRatePlanCharge__c>> qrpcMap = new Map<Id, List<zqu__QuoteRatePlanCharge__c>>();

    for(zqu__QuoteRatePlanCharge__c qrpc: qrpcs){
        if(!qrpcMap.containsKey(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__c)){
            qrpcMap.put(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__c, new List<zqu__QuoteRatePlanCharge__c>());
        }
        qrpcMap.get(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__c).add(qrpc);
    }

    List<PAC__c> pacsToUpdate = new List<PAC__c>();
    List<PAC__c> pacsToAssign = new List<PAC__c>();

    Set<Id> quotesToRemovePACs = new Set<Id>();
    for(zqu__Quote__c quote: Trigger.new) {
        if (quote.OM_Status__c == 'Accepted' && Trigger.oldMap.get(quote.Id).OM_Status__c != 'Accepted' && qrpcMap.containsKey(quote.Id) && quote.Split_Parent_Quote__c == null) {
            quotesToRemovePACs.add(quote.Id);
        }
    }

    if(!quotesToRemovePACs.isEmpty()) {
        PACKeyAllocator.unallocatePACKeys([SELECT Id FROM PAC__c WHERE Quote__c IN :quotesToRemovePACs]);
    }

    PACKeyAllocator allocator = new PACKeyAllocator();

    for(zqu__Quote__c quote: Trigger.new) {
        System.debug(qrpcMap.get(quote.Id));
        if (quote.OM_Status__c == 'Accepted' && Trigger.oldMap.get(quote.Id).OM_Status__c != 'Accepted' && qrpcMap.containsKey(quote.Id) && quote.Split_Parent_Quote__c == null) {
            System.debug('trigger fired for: ' + quote.Id + ' ' + quote.Name);

            List<PAC__c> pacs = allocator.allocatePACKeys(quote, qrpcMap.get(quote.Id));
            System.debug('trigger pacs: ' + pacs);
            if (pacs == null) {
                PACEmailUtil.sendPACNotificationEmail(quote.Id);
                //quote.addError('There was an error while allocating PAC Keys for this quote.');
                break;
            } else {
                pacsToUpdate.addAll(pacs);
                PACEmailUtil.sendNewDealEmail(quote.Id);
            }
        }
        if (quote.zqu__Status__c == 'Sent to Z-Billing' && Trigger.oldMap.get(quote.Id).zqu__Status__c != 'Sent to Z-Billing' && qrpcMap.containsKey(quote.Id) && quote.Split_Parent_Quote__c == null){
            List<PAC__c> pacs = [SELECT Id FROM PAC__c WHERE Quote__c = :quote.Id];
            for(PAC__c pac : pacs){
                pac.Status__c = 'Assigned';
                pac.Assignment_Date__c = System.now();
                pacsToAssign.add(pac);
            }
        }
        
    }
    System.debug('pacsToUpdate Size: ' + pacsToUpdate.size());
    System.debug('pacsToAssign Size: ' + pacsToAssign.size());
    update pacsToUpdate;
    update pacsToAssign;
}