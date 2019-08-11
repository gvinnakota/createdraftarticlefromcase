/**
 * Created by klukawski on 9/11/18.
 */

public with sharing class PACManagementController {

    public class QuoteWrapper {

        public zqu__Quote__c record { get; set; }

        public QuoteWrapper(zqu__Quote__c quote) {
            this.record = quote;
        }

        public PageReference nextStep() {
            PageReference ref = Page.PACManagement;
            ref.getParameters().put(QUOTE_PARAM, this.record.Id);
            ref.setRedirect(true);
            return ref;
        }
    }

    @TestVisible private static final String QUOTE_PARAM = 'quoteId';

    public zqu__Quote__c quote {
        get;
        private set;
    }

    public List<zqu__QuoteRatePlanCharge__c> quoteCharges {
        get;
        private set;
    }

    public Boolean quoteSelected {
        get {
            return quote != null;
        }
        private set;
    }

    public List<PAC__c> pacs {
        get;
        set;
    }

    public List<PAC__c> pacsToManuallyAllocate {
        get;
        set;
    }

    public Boolean unassign {
        get;
        set;
    }

    public Boolean allocate {
        get;
        set;
    }

    public Boolean allocateManually {
        get;
        set;
    }

    public Boolean markAsAssigned {
        get;
        set;
    }

    public Id pacToRemove{get;set;}


    public String filterString { get; set; }

    public List<QuoteWrapper> quoteOptions {
        get {
            if (quoteOptions == null) {
                quoteOptions = new List<QuoteWrapper>();
                if (!String.isEmpty(filterString)) {
                    for (zqu__Quote__c q : [
                        SELECT Name, zqu__Number__c
                        FROM zqu__Quote__c
                        WHERE zqu__Number__c LIKE :filterString
                        LIMIT 10
                    ]) {
                        quoteOptions.add(new QuoteWrapper(q));
                    }
                } else {
                    for (zqu__Quote__c q : [
                        SELECT Name, zqu__Number__c
                        FROM zqu__Quote__c
                        LIMIT 10
                    ]) {
                        quoteOptions.add(new QuoteWrapper(q));
                    }
                }
            }
            return quoteOptions;
        }
        set;
    }

    public void queryQuotes() {
        if (quoteOptions == null) {
            quoteOptions = new List<QuoteWrapper>();
        } else {
            quoteOptions.clear();
        }
        if (!String.isEmpty(filterString)) {
            for (zqu__Quote__c q : [
                SELECT Name, zqu__Number__c, zqu__StartDate__c
                FROM zqu__Quote__c
                WHERE zqu__Number__c LIKE :filterString
                LIMIT 10
            ]) {
                quoteOptions.add(new QuoteWrapper(q));
            }
        } else {
            for (zqu__Quote__c q : [
                SELECT Name, zqu__Number__c, zqu__StartDate__c
                FROM zqu__Quote__c
                LIMIT 10
            ]) {
                quoteOptions.add(new QuoteWrapper(q));
            }
        }
    }

    public void removePacFromSelectedList(){
        for (PAC__c pac : pacsToManuallyAllocate){
            if (pac.Id == pacToRemove){
                pacsToManuallyAllocate.remove(pacsToManuallyAllocate.indexOf(pac));
                break;
            }
        }
    }

    public String getWhereClause() {
        String whereClause = 'Id NOT IN ' + getCurrentToAddIds();
        return (whereClause.contains('()')) ? null : whereClause;
    }

    public String getCurrentToAddIds() {
        List<String> ids = new List<String>();
        for (PAC__c pac : pacs) {
            ids.add('\'' + pac.Id + '\'');
        }
        return '(' + String.join(ids, ',') + ')';
    }

    public PAC__c pacToAdd {get;set;}

    public PageReference addPacToSelectedList() {
        if (String.isNotBlank(pacToAdd.Id)) {
            Map<Id, PAC__c> pacMap = new Map<Id, PAC__c>(pacsToManuallyAllocate);
            if (!pacMap.containsKey(pacToAdd.Id)) {
                PAC__c pacToAddObject = [
                    SELECT Name, Status__c, Quote__c, Key__c, Assignment_Date__c,
                        Allocation_Date__c, Quantity__c, Duration__c, Product__c, Assigned_Product2__r.Name,
                        Subscription_Period__c
                    FROM PAC__c
                    WHERE Id = :pacToAdd.Id
                ];
                Product2 prod = [SELECT Name FROM Product2 WHERE Id = :pacToAdd.Assigned_Product2__c];
                pacToAddObject.Assigned_Product2__c = prod.Id;
                pacToAddObject.Assigned_Product2__r = prod;
                pacToAddObject.Subscription_Period_Start_Date__c = pacToAdd.Subscription_Period_Start_Date__c;
                pacToAddObject.Subscription_Period_End_Date__c = pacToAdd.Subscription_Period_End_Date__c;
                pacsToManuallyAllocate.add(pacToAddObject);
                pacToAdd = new PAC__c();
            }
        }
        return null;
    }


    public PACManagementController() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        if (params.containsKey(QUOTE_PARAM)) {
            quote = [
                SELECT Id, Name, zqu__Status__c
                FROM zqu__Quote__c
                WHERE Id = :params.get(QUOTE_PARAM)
            ];

            pacs = new List<PAC__c>([
                    SELECT Id, Status__c, Key__c, Assigned_Product2__r.Name, Duration__c, Quantity__c, Product__c,
                            Quote__c, Subscription_Period__c
                    FROM PAC__c
                    WHERE Quote__c = :quote.Id
            ]);

            Set<Id> applicableProductIds = new Set<Id>();

            for(PAC_Product_Map__c applicableProduct: PACKeyAllocator.productMaps){
                applicableProductIds.add(applicableProduct.Product2__c);
            }

            quoteCharges = new List<zqu__QuoteRatePlanCharge__c>([
                    SELECT zqu__Quantity__c, Initial_Term__c, Name, zqu__ProductRatePlanCharge__c,
                            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c,
                            Total_Unit_Quantity__c, Start_Date__c
                    FROM zqu__QuoteRatePlanCharge__c
                    WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :quote.Id
                    AND zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c IN :applicableProductIds
            ]);
        }

        unassign = false;
        allocate = false;
        markAsAssigned = false;
        allocateManually = false;

        pacToAdd = new PAC__c();
        pacsToManuallyAllocate = new List<PAC__c>();
    }

    public PageReference proceed() {
        if (unassign) {
            List<PAC__c> toUnassign = new List<PAC__c>();
            for (PAC__c pac : pacs) {
                if(String.isBlank(pac.Quote__c)){
                    continue;
                }
                pac.Quote__c = null;
                pac.Status__c = 'Unassigned';
                pac.Assigned_Product2__c = null;
                pac.Allocation_Date__c = null;
                pac.Assignment_Date__c = null;
                pac.Subscription_Period_Start_Date__c = null;
                pac.Subscription_Period_End_Date__c = null;
                toUnassign.add(pac);
            }
            update toUnassign;
        }
        if (allocate) {
            if (allocateManually) {
                List<PAC__c> pacsToAdd = new List<PAC__c>();
                for(PAC__c pac: pacsToManuallyAllocate){
                    pac.Status__c = 'Allocated';
                    pac.Quote__c = quote.Id;
                    pac.Allocation_Date__c = Datetime.now();
                    pacsToAdd.add(pac);
                }
                update pacsToAdd;
                pacs = pacsToManuallyAllocate;
            } else {
                PACKeyAllocator allocator = new PACKeyAllocator();
                pacs = allocator.allocatePACKeys(quote, quoteCharges);
                if(pacs != null){
                    update pacs;
                }
            }
        }
        if(markAsAssigned){
            List<PAC__c> toMarkAsAssigned = new List<PAC__c>();
            for (PAC__c pac : pacs) {
                pac.Status__c = 'Assigned';
                pac.Assignment_Date__c = Datetime.now();
                toMarkAsAssigned.add(pac);
            }
            update toMarkAsAssigned;
        }

        PageReference page = Page.PACManagement;
        page.setRedirect(true);
        page.getParameters().put(QUOTE_PARAM, quote.Id);
        return page;
    }

    public PageReference selectQuote() {
        PageReference page = Page.PACManagement;
        page.setRedirect(true);
        page.getParameters().put(QUOTE_PARAM, '');
        return page;
    }
}