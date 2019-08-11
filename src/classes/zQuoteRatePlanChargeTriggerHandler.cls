public with sharing class zQuoteRatePlanChargeTriggerHandler extends TriggerHandler {

    private RoleInstanceCreator roleInstanceCreator;
    private RoleInstanceDeleter roleInstanceDeleter;
    private QRPCListPriceProportionalReplacer listPriceProportionalReplacer;

    public zQuoteRatePlanChargeTriggerHandler() {
    }

    protected override void afterInsert(){
        roleInstanceCreator = new RoleInstanceCreator();
        for (zqu__QuoteRatePlanCharge__c qrpc : (List<zqu__QuoteRatePlanCharge__c>) Trigger.new) {
            roleInstanceCreator.add(qrpc);
        }
        roleInstanceCreator.process();
    }

    protected override void afterUpdate(){
        listPriceProportionalReplacer = new QRPCListPriceProportionalReplacer();
        for (zqu__QuoteRatePlanCharge__c qrpc : (List<zqu__QuoteRatePlanCharge__c>) Trigger.new) {
            listPriceProportionalReplacer.add(qrpc);
        }
        listPriceProportionalReplacer.process();
    }

    protected override void beforeDelete() {
        roleInstanceDeleter = new RoleInstanceDeleter();
        roleInstanceDeleter.addAll(Trigger.oldMap.keySet());
        roleInstanceDeleter.deleteRoleInstances();
    }
}