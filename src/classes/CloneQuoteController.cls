public class CloneQuoteController {
    @TestVisible
    private class BillingAccountWrapper {
        public Zuora__CustomerAccount__c account { get; private set; }
        public Boolean selected { get; set; }

        public BillingAccountWrapper(Zuora__CustomerAccount__c acc) {
            account = acc;
            selected = false;
        }
    }

    public static final String QUOTE_PARAM = 'id';
    public static final String OPTION_PARAM = 'opt';
    public static final String ZACC_PARAM = 'zAccId';
    public static final String BTID_PARAM = 'billToId';
    public static final String STID_PARAM = 'soldToId';
    public static final List<SelectOption> OPTIONS { get; private set; }

    private static String getAllFields(SObjectType objectType) {
        List<String> fieldList = new List<String>(objectType.getDescribe().fields.getMap().keySet());

        return String.join(fieldList, ', ');
    }

    public Boolean disableClone {
        get {
            return option == null || (option == 'change' || option == 'clone') && !billingAccountSelected;
        }
        private set;
    }

    public String accountAssociated{
        get{
            return sourceQuote.zqu__ZuoraAccountID__c==''||sourceQuote.zqu__ZuoraAccountID__c==null?'no':'yes';
        }
        set;
    }

    public String option { get; set; }

    @TestVisible
    public List<BillingAccountWrapper> billingAccounts { get; private set; }
    public Boolean showBillingAccountTable {
        get {
            return (option == 'change' || option == 'clone') && billingAccounts.size() > 0;
        }
        private set;
    }

    public Boolean showQuoteSubscriptionTypeError{
        get{
            return sourceQuote!=null?sourceQuote.zqu__SubscriptionType__c != 'New Subscription':false;
        }
        private set;
    }

    private Boolean billingAccountSelected {
        get {
            Boolean selected = false;
            for (BillingAccountWrapper acc : billingAccounts) {
                selected |= acc.selected;
                if (selected) {
                    break;
                }
            }

            return selected;
        }
        private set;
    }

    private BillingAccountWrapper selectedBillingAcc {
        get {
            for (BillingAccountWrapper w : billingAccounts) {
                if (w.selected) {
                    return w;
                }
            }
            return null;
        }
    }

    @testVisible
    private zqu__Quote__c sourceQuote;

    static {
        OPTIONS = new List<SelectOption>{
                new SelectOption('existing', 'Clone and keep existing billing account as is'),
                new SelectOption('change', 'Clone and associate a different and existing billing account'),
                new SelectOption('clone', 'Clone, edit existing billing account, then save that as a new billing account')
        };
    }

    @testVisible
    private void setTestBillingAccounts() {
        billingAccounts = new List<BillingAccountWrapper>{
                new BillingAccountWrapper(null),
                new BillingAccountWrapper(null),
                new BillingAccountWrapper(null)
        };
    }

    public CloneQuoteController(ApexPages.StandardController stdCtrl) {
        resolveURLParams();
        populateBillingAccounts();
    }

    private void resolveURLParams() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String quoteId = params.get(QUOTE_PARAM);
        sourceQuote = [SELECT zqu__Account__c, zqu__SubscriptionType__c, zqu__ZuoraAccountID__c FROM zqu__Quote__c WHERE Id = :quoteId];

        if (params.containsKey(OPTION_PARAM)) {
            option = ApexPages.currentPage().getParameters().get(OPTION_PARAM);
        }
    }

    private void populateBillingAccounts() {
        billingAccounts = new List<BillingAccountWrapper>();
        for (Zuora__CustomerAccount__c acc : [
                SELECT
                        Id, Name, Zuora__AccountNumber__c, Zuora__Zuora_Id__c, Company_Code__c, Channel__c,
                        CRM_Bill_To_Contact_Id__c, CRM_Sold_To_Contact_Id__c,
                        CRM_Bill_To_Contact__r.Name, CRM_Bill_To_Contact__r.MailingStreet, CRM_Bill_To_Contact__r.MailingCity,
                        CRM_Bill_To_Contact__r.MailingState, CRM_Bill_To_Contact__r.MailingCountry,
                        CRM_Sold_To_Contact__r.Name, CRM_Sold_To_Contact__r.MailingStreet, CRM_Sold_To_Contact__r.MailingCity,
                        CRM_Sold_To_Contact__r.MailingState, CRM_Sold_To_Contact__r.MailingCountry
                FROM
                        Zuora__CustomerAccount__c
                WHERE
                        Zuora__Account__c = :sourceQuote.zqu__Account__c
        ]) {
            billingAccounts.add(new BillingAccountWrapper(acc));
        }

        OPTIONS[1].setDisabled(billingAccounts.isEmpty()||(billingAccounts.size()==1 && sourceQuote.zqu__ZuoraAccountID__c==''));
        OPTIONS[2].setDisabled(billingAccounts.size()==0);

    }

    public PageReference redirectClone(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        if(params.containsKey(OPTION_PARAM)&&params.containsKey(ZACC_PARAM)&&params.containsKey(BTID_PARAM)&&params.containsKey(STID_PARAM)){
            return CloneQuoteController.cloneQuote(sourceQuote, option, new Zuora__CustomerAccount__c(Zuora__Zuora_Id__c = params.get(ZACC_PARAM),
                    CRM_Bill_To_Contact_Id__c = params.get(BTID_PARAM),
                    CRM_Sold_To_Contact_Id__c = params.get(STID_PARAM)));
        }
        return null;
    }

    public PageReference cloneQuote() {
        if (option == 'clone') {
            //open billAcc clone page with parameters
            PageReference ref = Page.CloneBillingAccount;
            ref.getParameters().put(CloneBillingAccountController.ID_PARAM, selectedBillingAcc.account.Id);
            ref.getParameters().put(CloneBillingAccountController.QUOTE_PARAM, sourceQuote.Id);
            return ref;
        } else {
            return cloneQuote(sourceQuote, option, option == 'change' ? selectedBillingAcc.account : null);
        }
    }

    public PageReference cancel() {
        return new PageReference('/' + sourceQuote.Id);
    }

    public static PageReference cloneQuote(zqu__Quote__c sourceQuote, String option, Zuora__CustomerAccount__c selectedBillingAcc) {
        /*zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS =
                Schema.SObjectType.zqu__QuoteRatePlanCharge__c.fieldSets.getMap().get();*/
        System.debug('clonequote');
        zqu.Quote source = zqu.Quote.getInstance(sourceQuote.Id);
        zqu.CloneQuoteOptions opts = new zqu.CloneQuoteOptions();
        opts.shouldCloneProducts = true;
        zqu.QuoteCloneResponse res = source.cloneQuote(opts);
        if (res.isSuccess) {
            zqu.Quote clone = res.clonedQuote;
            clone.set('zqu__Status__c', 'New');
            clone.set('Approval__c', '<img src="/resource/Approval_Status_images/notsubmitted.png" alt="Other" border="0"/>');
            if (option == 'change') {
                clone.set('zqu__ZuoraAccountID__c', selectedBillingAcc.Zuora__Zuora_Id__c);
                clone.set('zqu__BillToContact__c', selectedBillingAcc.CRM_Bill_To_Contact_Id__c);
                clone.set('zqu__SoldToContact__c', selectedBillingAcc.CRM_Sold_To_Contact_Id__c);
            }
            clone.buildAndSave();
            //REMOVE OUTDATED PRODUCTS


            zqu__Quote__c clonedSObject = clone.getSObject();
            List<zqu__QuoteRatePlan__c> quoteRatePlans = [SELECT Id, zqu__ProductRatePlan__r.zqu__EffectiveEndDate__c
                    FROM zqu__QuoteRatePlan__c
                    WHERE zqu__Quote__c = :clonedSObject.Id];
            Map<String, zqu__QuoteRatePlan__c> plansToDelete = new Map<String, zqu__QuoteRatePlan__c>();
            for(zqu__QuoteRatePlan__c quoteRatePlan: quoteRatePlans){
                if(quoteRatePlan.zqu__ProductRatePlan__r.zqu__EffectiveEndDate__c < Date.today()){
                    plansToDelete.put(quoteRatePlan.Id, quoteRatePlan);
                }
            }



            if (!plansToDelete.isEmpty()) {
                delete plansToDelete.values();
                PageReference ref = Page.QuoteRatePlanDeletedList;
                ref.getParameters().put(QuoteRatePlanDeletedListController.CLONE_ID, clone.getId());
                ref.getParameters().put(
                        QuoteRatePlanDeletedListController.RATE_PLAN_IDS,
                        String.join(new List<String>(plansToDelete.keySet()), ','));
                return ref;
            }

            clone.save();

            Map<String, zqu__QuoteRatePlanCharge__c> qrpcsByNames = new Map<String, zqu__QuoteRatePlanCharge__c>();

            for (zqu__QuoteRatePlanCharge__c qrpc : [
                SELECT Id, Initial_Term__c, Name FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__r.Id = :sourceQuote.Id
            ]){
                qrpcsByNames.put(qrpc.Name, qrpc);
            }

            List<zqu__QuoteRatePlanCharge__c> qrpcToUpdate = new List<zqu__QuoteRatePlanCharge__c>();
            for (zqu__QuoteRatePlanCharge__c qrpc : [
                SELECT Id, Initial_Term__c, Name FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__r.Id = :clonedSObject.Id
            ]){
                if (qrpcsByNames.containsKey(qrpc.Name)){
                    qrpc.Initial_Term__c = qrpcsByNames.get(qrpc.Name).Initial_Term__c;
                    qrpcToUpdate.add(qrpc);
                }
            }
            System.debug('qrpcstoupdate: ' + qrpcToUpdate);
            update qrpcToUpdate;
            //END REMOVE OUTDATED PRODUCTS
            return new PageReference('/' + clone.getId());
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, res.errorMessage));
            return null;
        }
    }

}