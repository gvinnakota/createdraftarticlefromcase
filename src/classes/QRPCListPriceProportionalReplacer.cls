public with sharing class QRPCListPriceProportionalReplacer {
    private static Decimal feeForExpensesFactor = BOE_Settings__c.getOrgDefaults().T_E_Rate__c;
    private List<zqu__QuoteRatePlanCharge__c> qrpcToUpdate = new List<zqu__QuoteRatePlanCharge__c>();
    private Map<Id, Decimal> qrpId2Price = new Map<Id, Decimal>();
    private Set<Id> qrpIds = new Set<Id>();

    public QRPCListPriceProportionalReplacer(){
        if (Test.isRunningTest() && feeForExpensesFactor == null){
            feeForExpensesFactor = 0.18;
        }
    }

    public void add(zqu__QuoteRatePlanCharge__c qrpc) {
        if (qrpc.Name != 'Fee for Expenses') {
            qrpIds.add(qrpc.zqu__QuoteRatePlan__c);
        }
    }

    public void process() {
        collectQRPCAndPrices();
        setFinalPrice();
        update qrpcToUpdate;
    }

    private void collectQRPCAndPrices() {
        for (zqu__QuoteRatePlanCharge__c qrpc : [
            SELECT Id, Name, zqu__Total__c, zqu__QuoteRatePlan__c,
                Overridden_T_E_Percentage__c, T_E_Percentage_Override__c,
                zqu__QuoteRatePlan__r.SOW_Type__c, (SELECT Daily_rate__c, Role_Quantity__c, Total_Days__c FROM Role_Instance__r)
            FROM zqu__QuoteRatePlanCharge__c
            WHERE zqu__QuoteRatePlan__c IN :qrpIds
        ]) {
            System.debug('qrpc name: ' + qrpc.Name);
            if (qrpc.Name == 'Fee for Expenses') {
                qrpcToUpdate.add(qrpc);
            } else {
                Decimal currentPrice = 0;
                if (qrpc.zqu__QuoteRatePlan__r.SOW_Type__c == 'Daily with T&E') {
                    for (Role_Instance__c ri : qrpc.Role_Instance__r) {
                        currentPrice += ri.Daily_Rate__c * ri.Total_Days__c;
                    }
                } else {
                    currentPrice = (qrpc.zqu__Total__c == null ? 0 : qrpc.zqu__Total__c);
                }
                if (qrpc.T_E_Percentage_Override__c != null && qrpc.T_E_Percentage_Override__c == true) {
                    currentPrice *= qrpc.Overridden_T_E_Percentage__c / 100;
                } else {
                    currentPrice *= feeForExpensesFactor;
                }
                if (qrpId2Price.containsKey(qrpc.zqu__QuoteRatePlan__c)) {
                    currentPrice += qrpId2Price.get(qrpc.zqu__QuoteRatePlan__c);
                }
                System.debug('current price' + currentPrice);

                qrpId2Price.put(qrpc.zqu__QuoteRatePlan__c, currentPrice);
            }
        }
    }

    private void setFinalPrice() {
        System.debug('expenses factor: ' + feeForExpensesFactor);
        for (zqu__QuoteRatePlanCharge__c qrpc : qrpcToUpdate) {
            System.debug('containskey: ' + qrpId2Price.containsKey(qrpc.zqu__QuoteRatePlan__c) + ' ' + qrpc.zqu__QuoteRatePlan__c);
            if (qrpId2Price.containsKey(qrpc.zqu__QuoteRatePlan__c)) {
                Decimal finalPrice = 0;
                System.debug('sow type ' + qrpc.zqu__QuoteRatePlan__r.SOW_Type__c);
                if (!qrpc.zqu__QuoteRatePlan__r.SOW_Type__c.contains('without')) {
                    finalPrice = qrpId2Price.get(qrpc.zqu__QuoteRatePlan__c);
                }
                System.debug(finalPrice);
                finalPrice = finalPrice.setScale(2);
                qrpc.zqu__Total__c = finalPrice;
                qrpc.zqu__EffectivePrice__c = finalPrice;
                qrpc.zqu__ListPrice__c = finalPrice;
                qrpc.Listed_Price__c = finalPrice.toPlainString();
            }
        }
    }
}