public with sharing class RoleInstanceTriggerHandler extends TriggerHandler {

    private QRPCListPriceReplacer quoteRPCReplacer = new QRPCListPriceReplacer();
    private QRPCWithRolesSetter qrpcWithRolesSetter = new QRPCWithRolesSetter();

    public RoleInstanceTriggerHandler() {}

    protected override void afterInsert(){
        addAllNew(quoteRPCReplacer);
        quoteRPCReplacer.processWithoutSave();
        System.debug('Adam quoteRPCReplacer.qrpcToUpdate: ' + quoteRPCReplacer.qrpcToUpdate);
        qrpcWithRolesSetter.withQRPCList(quoteRPCReplacer.qrpcToUpdate).process();
    }

    protected override void afterUpdate() {
        addAllNew(quoteRPCReplacer).process();
    }

    protected override void afterDelete() {
        addAllOld(quoteRPCReplacer);
        quoteRPCReplacer.processWithoutSave();
        System.debug('Adam quoteRPCReplacer.qrpcToUpdate: ' + quoteRPCReplacer.qrpcToUpdate);
        qrpcWithRolesSetter.withQRPCList(quoteRPCReplacer.qrpcToUpdate).process();
    }

    protected override void afterUndelete(){
        addAllNew(quoteRPCReplacer);
        quoteRPCReplacer.processWithoutSave();
        System.debug('Adam quoteRPCReplacer.qrpcToUpdate: ' + quoteRPCReplacer.qrpcToUpdate);
        qrpcWithRolesSetter.withQRPCList(quoteRPCReplacer.qrpcToUpdate).process();
    }

    private QRPCListPriceReplacer addAll(QRPCListPriceReplacer processor, List<SObject> sObjList) {
        for (Role_Instance__c qrpc : (List<Role_Instance__c>) sObjList) {
            processor.add(qrpc);
        }
        return processor;
    }

    private QRPCListPriceReplacer addAllNew(QRPCListPriceReplacer processor) {
        addAll(processor, Trigger.new);
        return processor;
    }

    private QRPCListPriceReplacer addAllOld(QRPCListPriceReplacer processor) {
        addAll(processor, Trigger.old);
        return processor;
    }

    class QRPCListPriceReplacer {
        public List<zqu__QuoteRatePlanCharge__c> qrpcToUpdate {get; private set;}
        private Set<Id> qrpcIds;
        private Map<Id, QRPCPriceMultiplier> qrpcId2PriceMultiplier = new Map<Id, QRPCPriceMultiplier>();

        public QRPCListPriceReplacer() {
            qrpcIds = new Set<Id>();
        }

        public void add(Role_Instance__c roleInstance) {
            qrpcIds.add(roleInstance.Quote_Rate_Plan_Charge__c);
        }

        public void process() {
            processWithoutSave();
            update qrpcToUpdate;
        }

        public void processWithoutSave() {
            qrpcToUpdate = new List<zqu__QuoteRatePlanCharge__c>();
            findAndCollectQuoteRPC();
            collectCountryMultipliers();
            for (zqu__QuoteRatePlanCharge__c qrpc : qrpcToUpdate) {
                processOneQuoteRPC(qrpc);
            }
        }

        private void findAndCollectQuoteRPC() {
            collectQuoteRPC();
        }

        private void collectQuoteRPC() {
            qrpcToUpdate = [SELECT id, zqu__ListPrice__c, zqu__EffectivePrice__c, zqu__Total__c,
                    zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Currency__c,
                    zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__SoldToContact__r.MailingCountryCode,
                    zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.ProductServiceCategory__c,
                    zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.IgnoreCountryMultiplier__c,
                    (SELECT List_Price__c FROM Role_Instance__r)
                    FROM zqu__QuoteRatePlanCharge__c
                    WHERE Id IN :qrpcIds];
        }

        private void processOneQuoteRPC(zqu__QuoteRatePlanCharge__c qrpc) {
            Decimal sumListPriceDec = sumListPrice(qrpc.Role_Instance__r);
            sumListPriceDec = qrpcId2PriceMultiplier.get(qrpc.Id)
                    .withBasePrice(sumListPriceDec)
                    .calculatePrice()
                    .setScale(2);
            qrpc.zqu__EffectivePrice__c = sumListPriceDec;
            qrpc.zqu__Total__c = sumListPriceDec;
            qrpc.Listed_Price__c = String.valueOf(sumListPriceDec);
        }

        private void collectCountryMultipliers() {
            Map<String, List<QRPCPriceMultiplier>> countryCode2PM = new Map<String, List<QRPCPriceMultiplier>>();
            Map<String, List<QRPCPriceMultiplier>> currencyCode2PM = new Map<String, List<QRPCPriceMultiplier>>();
            for (zqu__QuoteRatePlanCharge__c qrpc : qrpcToUpdate) {
                String currencyCode = qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Currency__c;
                String countryCode = qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__SoldToContact__r.MailingCountryCode;
                Boolean ignoreCountryMultiplier = qrpc.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.IgnoreCountryMultiplier__c;
                QRPCPriceMultiplier qrpcPM = new QRPCPriceMultiplier()
                        .withCountryCode(countryCode)
                        .withCurrencyCode(currencyCode)
                        .withIgnoreCountryMultiplier(ignoreCountryMultiplier);
                qrpcId2PriceMultiplier.put(qrpc.Id, qrpcPM);
                addToMap(countryCode2PM, countryCode, qrpcPM);
                addToMap(currencyCode2PM, currencyCode, qrpcPM);
            }
            fillMultipliersWithConversionRate(currencyCode2PM);
            fillMultipliersWithCountryMultiplier(countryCode2PM);
        }

        private void fillMultipliersWithCountryMultiplier(Map<String, List<QRPCPriceMultiplier>> countryCode2PM) {
            for (Country_Uplift__c countryUplift : [
                    SELECT Country_Code__c,
                            Uplift_Multiplier__c,
                            Service_Multiplier__c
                    FROM Country_Uplift__c
                    WHERE Country_Code__c = :countryCode2PM.keySet()
            ]) {
                for (QRPCPriceMultiplier qrpcPM : countryCode2PM.get(countryUplift.Country_Code__c)) {
                    //what about categoryType - first answer - it's always service
                    qrpcPM.countryMultiplier = countryUplift.Service_Multiplier__c;
                }
            }
        }

        private void fillMultipliersWithConversionRate(Map<String, List<QRPCPriceMultiplier>> currencyCode2PM) {
            for (Conversion_Rate__c rate : [
                    SELECT Conversion_Rate__c, CurrencyIsoCode
                    FROM Conversion_Rate__c
                    WHERE CurrencyIsoCode = :currencyCode2PM.keySet()
                    AND End_Date__c >= TODAY
                    AND Start_Date__c <= TODAY
            ]) {
                for (QRPCPriceMultiplier qrpcPM : currencyCode2PM.get(rate.CurrencyIsoCode)) {
                    qrpcPM.conversionRate = rate.Conversion_Rate__c;
                }
            }
        }

        private void addToMap(Map<String, List<QRPCPriceMultiplier>> qrpc2PM, String key, QRPCPriceMultiplier qrpcPM) {
            if (qrpc2PM.containsKey(key)) {
                qrpc2PM.get(key).add(qrpcPM);
            } else {
                qrpc2PM.put(key, new List<QRPCPriceMultiplier>{qrpcPM});
            }
        }

        private Decimal sumListPrice(List<Role_Instance__c> roleInstances) {
            Decimal sum = 0;
            if (null != roleInstances && !roleInstances.isEmpty()) {
                for (Role_Instance__c roleInstance : roleInstances) {
                    sum += roleInstance.List_Price__c;
                }
            }
            return sum;
        }
    }
}