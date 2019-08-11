public with sharing class PACReportingController {
    public static final String DATE_START_PARAM = 'startDate';
    public static final String DATE_END_PARAM = 'endDate';

    public Date endDate { get; set; }
    public Date startDate { get; set; }
    public Boolean hasParams { get; set; }

    private List<AggregateResult> inventory;

    public String inventoryChartLabelMap {
        get {
            Map<String, String> labels = new Map<String, String>();
            for (AggregateResult res : inventory) {
                labels.put(String.escapeSingleQuotes(res.get('Grouping_Field__c') + '_' + res.get('Product__c')), String.escapeSingleQuotes(res.get('Product__c') + ' with quantity ' + res.get('quantity') + ' pcs and duration of ' + res.get('duration') + ' years'));
            }
            return JSON.serialize(labels);
        }
        private set;
    }

    public String inventoryChartValueMap {
        get {
            Map<String, Integer> values = new Map<String, Integer>();
            for (AggregateResult res : inventory) {
                values.put(String.escapeSingleQuotes(res.get('Grouping_Field__c') + '_' + res.get('Product__c')), Integer.valueOf(res.get('remainingKeys')));
            }
            return JSON.serialize(values);
        }
        private set;
    }

    private Map<Id, Map<Id, Integer>> maxQuantitiesOverZproducts = new Map<Id, Map<Id, Integer>>();
    private Map<Id, Map<Id, Integer>> initialTermsOverZproducts = new Map<Id, Map<Id, Integer>>();
    private Map<Id, Map<Id, Date>> startDatesOverZproducts = new Map<Id, Map<Id, Date>>();

    public Map<String, Integer> pacsInPipeline = new Map<String, Integer>();
    public String pipelineChartValueMap {
        get {
            return JSON.serialize(pacsInPipeline);
        }
        private set;
    }

    public PACReportingController() {
        hasParams = pageHasParam(DATE_END_PARAM) && pageHasParam(DATE_START_PARAM);
        if (hasParams) {
            endDate = Date.valueOf(ApexPages.currentPage().getParameters().get(DATE_END_PARAM));
            startDate = Date.valueOf(ApexPages.currentPage().getParameters().get(DATE_START_PARAM));

            inventory = [
                    SELECT COUNT(Id) remainingKeys, Product__c, Grouping_Field__c, MIN(Quantity__c) quantity, MIN(Duration__c) duration
                    FROM PAC__c
                    WHERE Status__c = 'Unassigned' OR Status__c = 'Allocated'
                    GROUP BY Product__c, Grouping_Field__c
                    ORDER BY Product__c ASC, MIN(Duration__c) ASC, MIN(Quantity__c) ASC
            ];

            List<zqu__Quote__c> quotesInPipeline = [
                    SELECT Id
                    FROM zqu__Quote__c
                    WHERE zqu__Opportunity__r.CloseDate <= :endDate AND zqu__Opportunity__r.CloseDate >= :startDate
                    AND (OM_Status__c = '' OR OM_Status__c = NULL OR OM_Status__c = 'Accepted')
                    AND Primary_Quote__c = TRUE
                    AND zqu__Status__c != 'Sent to ZBilling'
            ];

            Set<Id> pipelinedQuoteIds = new Set<Id>();
            for (zqu__Quote__c quote : quotesInPipeline) {
                pipelinedQuoteIds.add(quote.Id);
            }

            List<PAC_Product_Map__c> mappings = [
                    SELECT Product2__c, PAC_Product__c
                    FROM PAC_Product_Map__c
            ];

            Map<Id, String> productMapping = new Map<Id, String>();
            for (PAC_Product_Map__c mapping : mappings) {
                productMapping.put(mapping.Product2__c, mapping.PAC_Product__c);
            }

            List<zqu__QuoteRatePlanCharge__c> chargesInPipeline = [
                    SELECT Initial_Term__c, zqu__Quantity__c, zqu__QuoteRatePlan__r.zqu__Quote__c,
                            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c,
                            Total_Unit_Quantity__c, Start_Date__c
                    FROM zqu__QuoteRatePlanCharge__c
                    WHERE zqu__QuoteRatePlan__r.zqu__Quote__c IN :pipelinedQuoteIds
                    AND zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c IN :productMapping.keySet()
            ];

            Map<String, Map<Integer, List<Integer>>> availableDenominations =
                    new Map<String, Map<Integer, List<Integer>>>(); //Denominations listed by duration and by product

            for (AggregateResult aggregateResult : inventory) {
                String product = String.valueOf(aggregateResult.get('Product__c'));
                if (!availableDenominations.containsKey(product)) {
                    availableDenominations.put(product, new Map<Integer, List<Integer>>());
                }

                Integer duration = Integer.valueOf(aggregateResult.get('duration'));
                if (!availableDenominations.get(product).containsKey(duration)) {
                    availableDenominations.get(product).put(duration, new List<Integer>());
                }

                Integer quantity = Integer.valueOf(aggregateResult.get('quantity'));
                if (!availableDenominations.get(product).get(duration).contains(quantity)) {
                    availableDenominations.get(product).get(duration).add(quantity);
                }
            }

            for (String product : availableDenominations.keySet()) {
                for (Integer duration : availableDenominations.get(product).keySet()) {
                    availableDenominations.get(product).get(duration).sort();
                }
            }

            Map<Id, Map<Id, List<ChargeWrapper>>> chargesOverZproducts = new Map<Id, Map<Id, List<ChargeWrapper>>>();
            for (zqu__QuoteRatePlanCharge__c charge : chargesInPipeline) {
                if (!chargesOverZproducts.containsKey(charge.zqu__QuoteRatePlan__r.zqu__Quote__c)) {
                    chargesOverZproducts.put(charge.zqu__QuoteRatePlan__r.zqu__Quote__c, new Map<Id, List<ChargeWrapper>>());
                }
                if (!chargesOverZproducts.get(charge.zqu__QuoteRatePlan__r.zqu__Quote__c).containsKey(charge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c)) {
                    chargesOverZproducts.get(charge.zqu__QuoteRatePlan__r.zqu__Quote__c).put(charge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c, new List<ChargeWrapper>());
                }
                chargesOverZproducts.get(charge.zqu__QuoteRatePlan__r.zqu__Quote__c).get(charge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c).add(new ChargeWrapper(charge));
            }

            for (zqu__Quote__c quoteInPipeline : quotesInPipeline) {
                if (!chargesOverZproducts.containsKey(quoteInPipeline.Id)) {
                    continue;
                }
                startDatesOverZproducts.put(quoteInPipeline.Id, new Map<Id, Date>());
                initialTermsOverZproducts.put(quoteInPipeline.Id, new Map<Id, Integer>());
                maxQuantitiesOverZproducts.put(quoteInPipeline.Id, new Map<Id, Integer>());
                for(Id productId: chargesOverZproducts.get(quoteInPipeline.Id).keySet()){
                    chargesOverZproducts.get(quoteInPipeline.Id).get(productId).sort();
                }
                calculateChargeParams(chargesOverZproducts.get(quoteInPipeline.Id), quoteInPipeline.Id);
                for (Id productId: startDatesOverZproducts.get(quoteInPipeline.Id).keySet()) {
                    Integer maxQuantity = maxQuantitiesOverZproducts.get(quoteInPipeline.Id).get(productId);
                    Integer initialTerm = initialTermsOverZproducts.get(quoteInPipeline.Id).get(productId);
                    Integer pacDuration = initialTerm <= 12 ? 1 : 3;
                    Map<String, Integer> currentPacs = new Map<String, Integer>();
                    String pacProduct = productMapping.get(productId);
                    List<Integer> currentPacDenominations = availableDenominations.get(pacProduct).get(pacDuration);
                    for(Integer i = currentPacDenominations.size()-1; i>=0; --i){
                        Integer currentDenomination = currentPacDenominations.get(i);
                        System.debug('Debug_denom:');
                        System.debug(currentDenomination);
                        System.debug(maxQuantity);
                        while(currentDenomination <= maxQuantity){
                            String groupingString = buildGroupingString(currentDenomination, pacDuration, pacProduct);
                            if(!currentPacs.containsKey(groupingString)){
                                currentPacs.put(groupingString, 0);
                            }
                            currentPacs.put(groupingString, currentPacs.get(groupingString)+1);
                            maxQuantity -= currentDenomination;
                        }
                    }
                    System.debug('DEBUG_current:');
                    System.debug(JSON.serializePretty(currentPacs));
                    for(String groupingString: currentPacs.keySet()){
                        if(!pacsInPipeline.containsKey(groupingString)){
                            pacsInPipeline.put(groupingString, currentPacs.get(groupingString));
                        }else{
                            pacsInPipeline.put(groupingString, currentPacs.get(groupingString)
                                    + pacsInPipeline.get(groupingString));
                        }
                    }
                    System.debug('DEBUG_full:');
                    System.debug(JSON.serializePretty(pacsInPipeline));
                }
            }
        }
    }

    private String buildGroupingString(Integer quantity, Integer duration, String pacProduct){
        return String.valueOf(quantity) + '_' + String.valueOf(duration) + '_' + pacProduct;
    }

    class ChargeWrapper implements Comparable {
        protected zqu__QuoteRatePlanCharge__c charge;

        public ChargeWrapper(zqu__QuoteRatePlanCharge__c charge) {
            this.charge = charge;
        }

        public Integer compareTo(Object param1) {
            zqu__QuoteRatePlanCharge__c other = ((ChargeWrapper) param1).charge;
            return Date.valueOf(other.Start_Date__c).daysBetween(Date.valueOf(this.charge.Start_Date__c));
        }
    }

    @TestVisible
    private void calculateChargeParams(Map<Id, List<ChargeWrapper>> chargesOverZproducts, Id quoteId) {
        for (Id product : chargesOverZproducts.keySet()) {
            List<ChargeWrapper> chargeWrappers = chargesOverZproducts.get(product);

            if (chargeWrappers.size() == 1) {
                ChargeWrapper charge = chargeWrappers.get(0);
                maxQuantitiesOverZproducts.get(quoteId).put(product, charge.charge.Total_Unit_Quantity__c.intValue());
                initialTermsOverZproducts.get(quoteId).put(product, charge.charge.Initial_Term__c.intValue());
                startDatesOverZproducts.get(quoteId).put(product, Date.valueOf(charge.charge.Start_Date__c));
                continue;
            }

            List<zqu__QuoteRatePlanCharge__c> subtracted = new List<zqu__QuoteRatePlanCharge__c>();
            Integer maxQuantity = 0;
            Integer quantity = 0;
            Date firstChargeDate = Date.valueOf(chargeWrappers[0].charge.Start_Date__c);
            Date lastEndDate = firstChargeDate;

            for (Integer i = 0; i < chargeWrappers.size(); ++i) {
                Date currentStartDate = Date.valueOf(chargeWrappers[i].charge.Start_Date__c);
                Date currentEndDate = currentStartDate.addMonths(chargeWrappers[i].charge.Initial_Term__c.intValue());
                quantity += chargeWrappers[i].charge.Total_Unit_Quantity__c.intValue();
                if (lastEndDate.monthsBetween(currentEndDate) > 0) {
                    lastEndDate = currentEndDate;
                }
                for (Integer j = 0; j < i; ++j) {
                    zqu__QuoteRatePlanCharge__c previousCharge = chargeWrappers[j].charge;
                    if (Date.valueOf(previousCharge.Start_Date__c).addMonths(previousCharge.Initial_Term__c.intValue()).addDays(-1).daysBetween(currentStartDate) > 0 && !subtracted.contains(previousCharge) /*&& charges.size()>1*/) {
                        subtracted.add(previousCharge);
                        quantity -= previousCharge.Total_Unit_Quantity__c.intValue();
                    }
                }
                if (quantity > maxQuantity) {
                    maxQuantity = quantity;
                }
            }
            startDatesOverZproducts.get(quoteId).put(product, firstChargeDate);
            initialTermsOverZproducts.get(quoteId).put(product, firstChargeDate.monthsBetween(lastEndDate));
            maxQuantitiesOverZproducts.get(quoteId).put(product, maxQuantity);
        }
    }

    public PageReference refresh() {
        PageReference ref = Page.PACReporting;
        ref.getParameters().put(DATE_END_PARAM, String.valueOf(endDate));
        ref.getParameters().put(DATE_START_PARAM, String.valueOf(startDate));
        ref.setRedirect(true);
        return ref;
    }

    private Boolean pageHasParam(String param) {
        return ApexPages.currentPage().getParameters().containsKey(param);
    }
}