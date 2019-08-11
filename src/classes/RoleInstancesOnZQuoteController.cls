public with sharing class RoleInstancesOnZQuoteController {
    private Id quoteId;

    public List<Role_Instance__c> instances {get; set;}
    public Map<Id, RoleInstanceWrapper> roleOnQRPCWrappersMap {get; set;}
    private Map<Id, zqu__QuoteRatePlan__c> quoteRatePlanMap;
    public Boolean editMode {get; set;}
    public RoleInstancesOnZQuoteController(ApexPages.StandardController stdController) {
        quoteId = stdController.getRecord().Id;
        editMode = true;
        fillInstances();
    }

    public String selectedOption {get;set;}

    public List<SelectOption> getSOWOptions(){
        List<SelectOption> toReturn = new List<SelectOption>();
        toReturn.add(new SelectOption('empty','--select one to populate all SKUs--'));
        for (PicklistEntry pe : zqu__QuoteRatePlan__c.getSObjectType().getDescribe().fields.getMap().get('SOW_Type__c').getDescribe().getPicklistValues()){
            toReturn.add(
                new SelectOption(pe.value, pe.label)
            );
        }
        return toReturn;
    }

    public void populateSKUs(){
        if (selectedOption != 'empty'){
            for (RoleInstanceWrapper riw : roleOnQRPCWrappersMap.values()){
                riw.qrp.SOW_Type__c = String.valueOf(selectedOption);
            }
        }
    }

    public List<RoleInstanceWrapper> getRoleOnQRPCWrappers() {
        return roleOnQRPCWrappersMap.values();
    }

    public Boolean getHasRoles() {
        return !instances.isEmpty();
    }

    public PageReference saveAndCalculate(){
        System.debug('RoleInstanceComponentController::saveAndCalculate instances: ' + instances);
        List<zqu__QuoteRatePlan__c> toUpdate = new List<zqu__QuoteRatePlan__c>();
        for (zqu__QuoteRatePlan__c qrp : quoteRatePlanMap.values()){
            System.debug('SOW: ' + qrp.SOW_Type__c);
            if (qrp.zqu__Quote__r.zqu__Status__c != 'Sent to Z-Billing'){
                toUpdate.add(qrp);
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Quotes that were already sent to Zuora cannot have their BOEs altered'));
            }

        }
        update toUpdate;


        update instances;
        fillInstances();
        return null;
    }

    private void fillInstances() {
        instances = [
            SELECT Id, Name, List_Price__c, Hourly_rate__c, Hours_Per_Role__c, Role_Quantity__c, Total_Hours__c,
                Daily_rate__c, Days_per_role__c, Total_Days__c,
                Quote_Rate_Plan_Charge__c,
                Quote_Rate_Plan_Charge__r.zqu__QuoteRatePlan__r.SOW_Type__c,
                Quote_Rate_Plan_Charge__r.Name,
                Quote_Rate_Plan_Charge__r.Listed_Price__c,
                Quote_Rate_Plan_Charge__r.SKU__c,
                Quote_Rate_Plan_Charge__r.zqu__QuoteRatePlan__c,
                Quote_Rate_Plan_Charge__r.zqu__QuoteRatePlan__r.Name,
                Quote_Rate_Plan_Charge__r.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Status__c
            FROM Role_Instance__c
            WHERE Quote_Rate_Plan_Charge__r.zqu__QuoteRatePlan__r.zqu__Quote__c = :quoteId
        ];
        List<zqu__QuoteRatePlanCharge__c> qrpcs = [
            SELECT zqu__QuoteRatePlan__r.SOW_Type__c,
                Name,
                Listed_Price__c,
                SKU__c,
                zqu__QuoteRatePlan__c,
                zqu__QuoteRatePlan__r.Name,
                zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Status__c, Id
            FROM zqu__QuoteRatePlanCharge__c
            WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :quoteId
            AND Name != 'Fee for Expenses'
        ];
        quoteRatePlanMap = new Map<Id, zqu__QuoteRatePlan__c>();
        roleOnQRPCWrappersMap = new Map<Id, RoleInstanceWrapper>();
        for (Role_Instance__c instance : instances) {
            addRoleInstanceToQuote(instance);
            quoteRatePlanMap.put(instance.Quote_Rate_Plan_Charge__r.zqu__QuoteRatePlan__c, instance.Quote_Rate_Plan_Charge__r.zqu__QuoteRatePlan__r);
        }
//        for (zqu__QuoteRatePlanCharge__c qrpc : qrpcs){
//            addRoleInstanceToQuote(qrpc);
//            quoteRatePlanMap.put(qrpc.zqu__QuoteRatePlan__c, qrpc.zqu__QuoteRatePlan__r);
//        }
    }

    private void addRoleInstanceToQuote(Role_Instance__c instance) {
        if (roleOnQRPCWrappersMap.containsKey(instance.Quote_Rate_Plan_Charge__c)) {
            roleOnQRPCWrappersMap.get(instance.Quote_Rate_Plan_Charge__c)
                    .addRoleInstance(instance);
        } else {
            roleOnQRPCWrappersMap.put(instance.Quote_Rate_Plan_Charge__c,
                    new RoleInstanceWrapper(instance));
        }
    }

//    private void addRoleInstanceToQuote(zqu__QuoteRatePlanCharge__c qrpc) {
//        if (!roleOnQRPCWrappersMap.containsKey(qrpc.Id)) {
//            roleOnQRPCWrappersMap.put(
//                qrpc.Id,
//                new RoleInstanceWrapper(qrpc));
//        }
//    }

    class RoleInstanceWrapper {
        public zqu__QuoteRatePlanCharge__c qrpc {get; private set;}
        public Boolean isCustomQRPC {get; private set;}
        public List<Role_Instance__c> instances {get; private set;}
        public zqu__QuoteRatePlan__c qrp {get; private set;}

        public RoleInstanceWrapper(Role_Instance__c instance) {
            this.qrpc = instance.Quote_Rate_Plan_Charge__r;
            this.qrp = instance.Quote_Rate_Plan_Charge__r.zqu__QuoteRatePlan__r;
            if (this.qrp.SOW_Type__c == null){
                this.qrp.SOW_Type__c = zqu__QuoteRatePlan__c.getSObjectType().getDescribe().fields.getMap().get('SOW_Type__c').getDescribe().getPicklistValues().get(0).getValue();
            }
            this.isCustomQRPC = RoleHelper.isAddingRoleAvailable(instance.Quote_Rate_Plan_Charge__r);
            instances = new List<Role_Instance__c>{instance};
        }

        public RoleInstanceWrapper addRoleInstance(Role_Instance__c instance) {
            instances.add(instance);
            return this;
        }

//        public RoleInstanceWrapper(zqu__QuoteRatePlanCharge__c qrpc){
//            this.qrpc = qrpc;
//            this.qrp = qrpc.zqu__QuoteRatePlan__r;
//            if (this.qrp.SOW_Type__c == null){
//                this.qrp.SOW_Type__c = zqu__QuoteRatePlan__c.getSObjectType().getDescribe().fields.getMap().get('SOW_Type__c').getDescribe().getPicklistValues().get(0).getValue();
//            }
//            this.isCustomQRPC = RoleHelper.isAddingRoleAvailable(qrpc);
//            instances = new List<Role_Instance__c>();
//        }
    }
}