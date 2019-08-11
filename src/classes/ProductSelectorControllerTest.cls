@isTest(SeeAllData=true)
public class ProductSelectorControllerTest {

    @isTest static void test_login() {
        Test.startTest();
        ProductSelectorController.login();
        Test.stopTest();
    }

    @isTest static void test_endpoint() {
        Test.startTest();

        ProductSelectorController.setEndpoints(new URL('https://apisandbox.zuora.com'));
        ProductSelectorController.setEndpoints(new URL('https://www.zuora.com'));
        ProductSelectorController.setEndpoints(new URL('https://services451.zuora.com'));

        try{
            // this will throw an exception
            ProductSelectorController.setEndpoints(new URL('https://wrongurl.zuora.com'));
        }catch(ZRestException e){
            System.assert(e.getMessage().contains('Cannot determine endpoint for'));
        }

        Test.stopTest();
    }

    @isTest static void test_getQuoteStartDate() {
        Test.startTest();
        zqu__Quote__c quote = createTestQuote();

        ApexPages.StandardController con = new ApexPages.StandardController(quote);
        ProductSelectorController psc = new ProductSelectorController(con);

        psc.getQuoteStartDate();

        try {
            quote.zqu__StartDate__c = null;
            update quote;
            psc.getQuoteStartDate();
        } catch (Exception ex) {
            //Zuora code
        }

        Test.stopTest();
    }
    
    @isTest static void test_new_quote() {

        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact);
        quote.Company_Code1__c = 'US46';
        quote.Primary_Quote__c = true;
        quote.PurchaseOrder__c = 'TESTPO1';
        update quote;

        Map<String, zqu__ProductRatePlan__c> productCatalog = ZTestFactory.makePivotalProductCatalog();
        Set<String> quoteChargeCustomFields = new Set<String>{'listed_price__c', 'product_rate_plan_zuoraid__c', 'listed_total__c', 'initial_term__c', 'start_date__c', 'start_date_display__c', 'end_date__c', 'end_date_display__c', 'country_uplift__c', 'calculated_discount__c', 'zqu__period__c', 'zqu__specificbillingperiod__c','zqu__triggerdate__c','zqu__triggerevent__c', 'quote_split_number__c', 'psamount__c'};
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = quoteChargeCustomFields;
        zqu.zChargeGroup chargeGroup1 = zqu.zQuoteUtil.getChargeGroup(quote.Id, productCatalog.get('Annual').Id);
        zqu.zCharge charge = chargeGroup1.zCharges[0];
        charge.ChargeObject.put('Listed_Price__c', '5000');
        charge.ChargeObject.put('Start_Date__c', '2015-06-12');
        charge.ChargeObject.put('Initial_Term__c', 12);
        charge.ChargeObject.put('Listed_Total__c', '5000');
        charge.ChargeObject.put('Calculated_Discount__c', '5');
        String chargeName = chargeGroup1.zCharges[0].NAME;
        zqu.zChargeGroup chargeGroup2 = zqu.zQuoteUtil.getChargeGroup(quote.Id, productCatalog.get('Support').Id);
        zqu.zCharge charge2 = chargeGroup2.zCharges[0];
        charge2.ChargeObject.put('Listed_Price__c', '5000');
        charge2.ChargeObject.put('Start_Date__c', '2015-06-12');
        charge2.ChargeObject.put('Initial_Term__c', 12);
        charge2.ChargeObject.put('Listed_Total__c', '5000');
        charge2.ChargeObject.put('Calculated_Discount__c', '5');
        List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>();
        chargeGroups.add(chargeGroup1);
        chargeGroups.add(chargeGroup2);
        zqu.zQuoteUtil.addChargeGroups(chargeGroups);
        List<zqu__QuoteRatePlan__c> qrps = [SELECT id, name from zqu__QuoteRatePlan__c where zqu__Quote__c = :quote.Id];
        List<String> qrpIds = new List<String>();
        for (zqu__QuoteRatePlan__c qrp : qrps) {
            qrpIds.add(qrp.Id);
        }
        List<zqu__QuoteChargeSummary__c> qcss = [SELECT id, name, zqu__QuoteRatePlanCharge__c from zqu__QuoteChargeSummary__c where zqu__QuoteRatePlan__c in :qrpIds];
        List<zqu__QuoteRatePlanCharge__c> qrpcs = [SELECT id, name from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__c in :qrpIds];
        System.debug('qcs: '+qcss);
        System.debug('qrpcs: '+qrpcs);

        Test.startTest();

        ApexPages.StandardController con = new ApexPages.StandardController(quote);
        ProductSelectorController psc = new ProductSelectorController(con);
        Integer pageSize = psc.productRatePlanSetPageSize;
        Integer pageNumber = psc.productRatePlanSetPageNumber;
        Integer maxPageSize = psc.productRatePlanSetMaxPage;
        Integer resultSize = psc.productRatePlanSetResultSize;
        Boolean hasNext = psc.productRatePlanSetHasNext;
        Boolean hasPrevious = psc.productRatePlanSetHasPrevious;
        List < zqu__productRatePlan__c > records = psc.productRatePlanSetRecords;
        psc.pickProduct();
        List < SelectOption > productFamily = psc.productFamilyValues;
        List < SelectOption > serviceCategory = psc.serviceCategoryValues;
        List < SelectOption > availability = psc.availabilityValues;
        boolean showPF = psc.showProductFamily;
        boolean showSC = psc.showServiceCategory;
        boolean showA = psc.showAvailability;
        psc.next();
        psc.previous();
        psc.doSearch();
        psc.doClearSearch();
        psc.selectedProductFamily = 'All';
        psc.pickProductFamily();
        psc.selectedServiceCategory = 'All';
        psc.pickServiceCategory();
        psc.selectedAvailability = 'All';
        psc.pickAvailability();
        psc.pickProduct();
        String annualRatePlan = productCatalog.get('Annual').Id;
        psc.selectedproductRatePlanMap.put(annualRatePlan, true);
        psc.selectedproductRatePlan = annualRatePlan;
        psc.selectedChargeName = chargeName;
        psc.pickRatePlan();
        psc.selectedproductRatePlanMap.put(annualRatePlan, false);
        psc.selectedproductRatePlan = annualRatePlan;
        psc.pickRatePlan();
        psc.selectedproductRatePlanMap.put(annualRatePlan, true);
        psc.selectedproductRatePlan = annualRatePlan;
        psc.pickRatePlan();
        

        psc.isNew = 'false';
        psc.selectedChargeGroupId = '0';
        psc.effectivePriceChange();
        psc.quantityChange();
        psc.startDateChange();
        psc.durationChange();
        psc.listPriceChange();
        psc.discountChange();

        psc.isNew = 'true';
        psc.selectedChargeGroupId = '1';
        psc.effectivePriceChange();
        psc.quantityChange();
        psc.startDateChange();
        psc.durationChange();
        psc.listPriceChange();
        psc.discountChange();
        psc.specificBillingPeriodChange();

        //psc.selectedproductRatePlanMap.put(annualRatePlan, false);
        //psc.pickRatePlan();
        //psc.removeChargeGroup();
        psc.validateQuote();
        boolean showCharges = psc.showExistingCharges;
        boolean RatePlanSelected = psc.productRatePlanSelected;
        boolean showPlans = psc.showRatePlans;
        //psc.updateQuoteSplitNumbers();
        new PivLP_QuoteSplitManager().updateQuoteSplitNumbers(psc.quote, psc.cghList, psc.existingChargeGroupHolders, Double.valueOf(1.0));
        psc.addNewCharges();

        for(ProductSelectorController.ChargeGroupHolder cgh : psc.cghList){
            if(cgh.display == null){
                System.debug('Display is null');
            }
            if(cgh.ChargeWrappers == null){
                System.debug('ChargeWrappers is null');
            }
            if(cgh.hasBeenUpdated == null){
                System.debug('hasBeenUpdated is null');
            }
        }

        if(psc.productSelected == null){
            System.debug('productSelected is null');
        }
        if(psc.showExistingCharges == null){
            System.debug('showExistingCharges is null');
        }
        if(psc.productRatePlanSelected == null){
            System.debug('productRatePlanSelected is null');
        }
        if(psc.showRatePlans == null){
            System.debug('showRatePlans is null');
        }
        
        Test.stopTest();
    }

    @isTest static void test_new_quote2() {

        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact);
        quote.Company_Code1__c = 'US46';
        quote.Primary_Quote__c = true;
        quote.PurchaseOrder__c = 'TESTPO1';
        update quote;

        Map<String, zqu__ProductRatePlan__c> productCatalog = ZTestFactory.makePivotalProductCatalog();
        Set<String> quoteChargeCustomFields = new Set<String>{'listed_price__c', 'product_rate_plan_zuoraid__c', 'listed_total__c', 'initial_term__c', 'start_date__c', 'start_date_display__c', 'end_date__c', 'end_date_display__c', 'country_uplift__c', 'calculated_discount__c', 'zqu__period__c', 'zqu__specificbillingperiod__c','zqu__triggerdate__c','zqu__triggerevent__c', 'quote_split_number__c', 'psamount__c'};
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = quoteChargeCustomFields;
        zqu.zChargeGroup chargeGroup1 = zqu.zQuoteUtil.getChargeGroup(quote.Id, productCatalog.get('Annual').Id);
        zqu.zCharge charge = chargeGroup1.zCharges[0];
        charge.ChargeObject.put('Listed_Price__c', '5000');
        charge.ChargeObject.put('Start_Date__c', '2015-06-12');
        charge.ChargeObject.put('Initial_Term__c', 12);
        charge.ChargeObject.put('Listed_Total__c', '5000');
        charge.ChargeObject.put('Calculated_Discount__c', '5');
        String chargeName = chargeGroup1.zCharges[0].NAME;
        zqu.zChargeGroup chargeGroup2 = zqu.zQuoteUtil.getChargeGroup(quote.Id, productCatalog.get('Support').Id);
        zqu.zCharge charge2 = chargeGroup2.zCharges[0];
        charge2.ChargeObject.put('Listed_Price__c', '5000');
        charge2.ChargeObject.put('Start_Date__c', '2015-06-12');
        charge2.ChargeObject.put('Initial_Term__c', 12);
        charge2.ChargeObject.put('Listed_Total__c', '5000');
        charge2.ChargeObject.put('Calculated_Discount__c', '5');
        List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>();
        chargeGroups.add(chargeGroup1);
        chargeGroups.add(chargeGroup2);
        zqu.zQuoteUtil.addChargeGroups(chargeGroups);
        List<zqu__QuoteRatePlan__c> qrps = [SELECT id, name from zqu__QuoteRatePlan__c where zqu__Quote__c = :quote.Id];
        List<String> qrpIds = new List<String>();
        for (zqu__QuoteRatePlan__c qrp : qrps) {
            qrpIds.add(qrp.Id);
        }
        List<zqu__QuoteChargeSummary__c> qcss = [SELECT id, name, zqu__QuoteRatePlanCharge__c from zqu__QuoteChargeSummary__c where zqu__QuoteRatePlan__c in :qrpIds];
        List<zqu__QuoteRatePlanCharge__c> qrpcs = [SELECT id, name from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__c in :qrpIds];
        System.debug('qcs: '+qcss);
        System.debug('qrpcs: '+qrpcs);

        Test.startTest();

        ApexPages.StandardController con = new ApexPages.StandardController(quote);
        ProductSelectorController psc = new ProductSelectorController(con);
        psc.doClearSearch();
        String annualRatePlan = productCatalog.get('Annual').Id;
        psc.selectedproductRatePlanMap.put(annualRatePlan, true);
        psc.selectedproductRatePlan = annualRatePlan;
        psc.selectedChargeName = chargeName;
        psc.pickRatePlan();
        psc.validateAndSaveQuote();
        Test.stopTest();
    }
    
@isTest static void test_method_two() {
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact);
        quote.Company_Code1__c = 'US46';
        quote.Primary_Quote__c = true;
        quote.PurchaseOrder__c = 'TESTPO1';
        quote.Payment_Plan__c = 'Prepaid';
        quote.Tax_Exempt__c = true;
        quote.Channel__c = 'Direct';
        update quote;

        Test.startTest();

    Map<String, zqu__ProductRatePlan__c> productCatalog = ZTestFactory.makePivotalProductCatalog();
        Set<String> quoteChargeCustomFields = new Set<String>{'listed_price__c', 'product_rate_plan_zuoraid__c', 'product_rate_plan__c', 'listed_total__c', 'initial_term__c', 'start_date__c', 'start_date_display__c', 'end_date__c', 'end_date_display__c', 'country_uplift__c', 'rate_usd__c', 'calculated_discount__c', 'zqu__period__c', 'zqu__specificbillingperiod__c','zqu__triggerdate__c','zqu__triggerevent__c', 'quote_split_number__c','psamount__c','product_name__c','tcv_usd__c','acv_usd__c','arr_usd__c','mrr_usd__c','custom_tcv_formula__c'};
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = quoteChargeCustomFields;
        zqu.zChargeGroup chargeGroup1 = zqu.zQuoteUtil.getChargeGroup(quote.Id, productCatalog.get('Prepaid').Id);
        zqu.zCharge charge = chargeGroup1.zCharges[0];
        charge.ChargeObject.put('Listed_Price__c', '5000');
        charge.ChargeObject.put('Start_Date__c', '2015-06-12');
        charge.ChargeObject.put('Initial_Term__c', 12);
        charge.ChargeObject.put('Listed_Total__c', '5000');
        charge.ChargeObject.put('Calculated_Discount__c', '5');
        String chargeName = chargeGroup1.zCharges[0].NAME;
        zqu.zChargeGroup chargeGroup2 = zqu.zQuoteUtil.getChargeGroup(quote.Id, productCatalog.get('Service').Id);
        zqu.zCharge charge2 = chargeGroup2.zCharges[0];
        //charge2.ChargeObject.put('Listed_Price__c', '5000');
        //charge2.ChargeObject.put('Start_Date__c', '2015-06-12');
        charge2.ChargeObject.put('Initial_Term__c', 12); // Initial term cannot be null, otherwise it'll throw NPE
        //charge2.ChargeObject.put('Listed_Total__c', '5000');
        //charge2.ChargeObject.put('Calculated_Discount__c', '5');
        List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>();
        chargeGroups.add(chargeGroup1);
        chargeGroups.add(chargeGroup2);
        zqu.zQuoteUtil.addChargeGroups(chargeGroups);
        List<zqu__QuoteRatePlan__c> qrps = [SELECT id, name from zqu__QuoteRatePlan__c where zqu__Quote__c = :quote.Id];
        List<String> qrpIds = new List<String>();
        for (zqu__QuoteRatePlan__c qrp : qrps) {
            qrpIds.add(qrp.Id);
        }
        List<zqu__QuoteChargeSummary__c> qcss = [SELECT id, name, zqu__QuoteRatePlanCharge__c from zqu__QuoteChargeSummary__c where zqu__QuoteRatePlan__c in :qrpIds];
        List<zqu__QuoteRatePlanCharge__c> qrpcs = [SELECT id, name from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__c in :qrpIds];
        System.debug('qcs: '+qcss);
        System.debug('qrpcs: '+qrpcs);


        ApexPages.StandardController con = new ApexPages.StandardController(quote);
        ProductSelectorController psc = new ProductSelectorController(con);
        Integer pageSize = psc.productRatePlanSetPageSize;
        Integer pageNumber = psc.productRatePlanSetPageNumber;
        Integer maxPageSize = psc.productRatePlanSetMaxPage;
        Integer resultSize = psc.productRatePlanSetResultSize;
        Boolean hasNext = psc.productRatePlanSetHasNext;
        Boolean hasPrevious = psc.productRatePlanSetHasPrevious;
        List < zqu__productRatePlan__c > records = psc.productRatePlanSetRecords;
        psc.pickProduct();
        List < SelectOption > productFamily = psc.productFamilyValues;
        List < SelectOption > serviceCategory = psc.serviceCategoryValues;
        List < SelectOption > availability = psc.availabilityValues;
        boolean showPF = psc.showProductFamily;
        boolean showSC = psc.showServiceCategory;
        boolean showA = psc.showAvailability;
        psc.next();
        psc.previous();
        psc.doSearch();
        psc.doClearSearch();
        psc.selectedProductFamily = 'All';
        psc.pickProductFamily();
        psc.selectedServiceCategory = 'All';
        psc.pickServiceCategory();
        psc.selectedAvailability = 'All';
		psc.pickAvailability();
        psc.pickProduct();
        String annualRatePlan = productCatalog.get('Annual').Id;
        psc.selectedproductRatePlanMap.put(annualRatePlan, true);
        psc.selectedproductRatePlan = annualRatePlan;
        psc.selectedChargeName = chargeName;
        psc.pickRatePlan();
        psc.selectedproductRatePlanMap.put(annualRatePlan, false);
        psc.selectedproductRatePlan = annualRatePlan;
        psc.pickRatePlan();
        psc.selectedproductRatePlanMap.put(annualRatePlan, true);
        psc.selectedproductRatePlan = annualRatePlan;
        psc.pickRatePlan();


        psc.isNew = 'false';
        psc.selectedChargeGroupId = '0';
        psc.effectivePriceChange();
        psc.quantityChange();
        psc.startDateChange();
        psc.durationChange();
        psc.listPriceChange();
        psc.discountChange();

        psc.isNew = 'true';
        psc.selectedChargeGroupId = '1';
        psc.effectivePriceChange();
        psc.quantityChange();
        psc.startDateChange();
        psc.durationChange();
        psc.listPriceChange();
        psc.discountChange();
        psc.specificBillingPeriodChange();

        //psc.selectedproductRatePlanMap.put(annualRatePlan, false);
        //psc.pickRatePlan();
        psc.removeChargeGroup();
        psc.validateQuote();
        boolean showCharges = psc.showExistingCharges;
        boolean RatePlanSelected = psc.productRatePlanSelected;
        boolean showPlans = psc.showRatePlans;
        try {
            //psc.updateQuoteSplitNumbers();
            new PivLP_QuoteSplitManager().updateQuoteSplitNumbers(psc.quote, psc.cghList, psc.existingChargeGroupHolders, Double.valueOf(1.0));
        } catch (Exception ex) {
            //Thanks Zuora...
        }
        psc.addNewCharges();

        for(ProductSelectorController.ChargeGroupHolder cgh : psc.cghList){
            if(cgh.display == null){
                System.debug('Display is null');
            }
            if(cgh.ChargeWrappers == null){
                System.debug('ChargeWrappers is null');
            }
            if(cgh.hasBeenUpdated == null){
                System.debug('hasBeenUpdated is null');
            }
        }

        if(psc.productSelected == null){
            System.debug('productSelected is null');
        }
        if(psc.showExistingCharges == null){
            System.debug('showExistingCharges is null');
        }
            if(psc.productRatePlanSelected == null){
            System.debug('productRatePlanSelected is null');
        }
        if(psc.showRatePlans == null){
            System.debug('showRatePlans is null');
        }

        psc.validateQuote();
        //psc.validateAndSaveQuote();

        Test.stopTest();
}
    @IsTest
    static void test_subtotal_preview(){
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact);
        quote.Company_Code1__c = 'US46';
        quote.Primary_Quote__c = true;
        quote.PurchaseOrder__c = 'TESTPO1';
        quote.Payment_Plan__c = 'Prepaid';
        quote.Tax_Exempt__c = true;
        quote.Channel__c = 'Direct';
        update quote;

        Test.startTest();

        Map<String, zqu__ProductRatePlan__c> productCatalog = ZTestFactory.makePivotalProductCatalog();
        Set<String> quoteChargeCustomFields = new Set<String>{'listed_price__c', 'product_rate_plan_zuoraid__c', 'product_rate_plan__c', 'listed_total__c', 'initial_term__c', 'start_date__c', 'start_date_display__c', 'end_date__c', 'end_date_display__c', 'country_uplift__c', 'rate_usd__c', 'calculated_discount__c', 'zqu__period__c', 'zqu__specificbillingperiod__c','zqu__triggerdate__c','zqu__triggerevent__c', 'quote_split_number__c','psamount__c','product_name__c','tcv_usd__c','acv_usd__c','arr_usd__c','mrr_usd__c','custom_tcv_formula__c'};
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = quoteChargeCustomFields;
        zqu.zChargeGroup chargeGroup1 = zqu.zQuoteUtil.getChargeGroup(quote.Id, productCatalog.get('Prepaid').Id);
        zqu.zCharge charge = chargeGroup1.zCharges[0];
        charge.ChargeObject.put('Listed_Price__c', '5000');
        charge.ChargeObject.put('Start_Date__c', '2015-06-12');
        charge.ChargeObject.put('Initial_Term__c', 12);
        charge.ChargeObject.put('Listed_Total__c', '5000');
        charge.ChargeObject.put('Calculated_Discount__c', '5');
        String chargeName = chargeGroup1.zCharges[0].NAME;
        zqu.zChargeGroup chargeGroup2 = zqu.zQuoteUtil.getChargeGroup(quote.Id, productCatalog.get('Service').Id);
        zqu.zCharge charge2 = chargeGroup2.zCharges[0];
        charge2.ChargeObject.put('Initial_Term__c', 12); // Initial term cannot be null, otherwise it'll throw NPE

        List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>();
        chargeGroups.add(chargeGroup1);
        chargeGroups.add(chargeGroup2);
        zqu.zQuoteUtil.addChargeGroups(chargeGroups);
        List<zqu__QuoteRatePlan__c> qrps = [SELECT id, name from zqu__QuoteRatePlan__c where zqu__Quote__c = :quote.Id];
        List<String> qrpIds = new List<String>();
        for (zqu__QuoteRatePlan__c qrp : qrps) {
            qrpIds.add(qrp.Id);
        }

        ApexPages.StandardController con = new ApexPages.StandardController(quote);
        ProductSelectorController psc = new ProductSelectorController(con);

        psc.pickProduct();
        psc.next();
        psc.previous();
        psc.doSearch();
        psc.doClearSearch();
        psc.selectedProductFamily = 'All';
        psc.pickProductFamily();
        psc.selectedServiceCategory = 'All';
        psc.pickServiceCategory();
        psc.selectedAvailability = 'All';
        psc.pickAvailability();
        psc.pickProduct();
        String annualRatePlan = productCatalog.get('Annual').Id;
        psc.selectedproductRatePlanMap.put(annualRatePlan, true);
        psc.selectedproductRatePlan = annualRatePlan;
        psc.selectedChargeName = chargeName;
        psc.pickRatePlan();
        psc.selectedproductRatePlanMap.put(annualRatePlan, false);
        psc.selectedproductRatePlan = annualRatePlan;
        psc.pickRatePlan();
        psc.selectedproductRatePlanMap.put(annualRatePlan, true);
        psc.selectedproductRatePlan = annualRatePlan;
        psc.pickRatePlan();


        psc.isNew = 'false';
        psc.selectedChargeGroupId = '0';
        psc.effectivePriceChange();
        psc.quantityChange();
        psc.startDateChange();
        psc.durationChange();
        psc.listPriceChange();
        psc.discountChange();

        psc.isNew = 'true';
        psc.selectedChargeGroupId = '1';
        psc.effectivePriceChange();
        psc.quantityChange();
        psc.startDateChange();
        psc.durationChange();
        psc.listPriceChange();
        psc.discountChange();

        psc.removeChargeGroup();
        psc.validateQuote();
        try {
            new PivLP_QuoteSplitManager().updateQuoteSplitNumbers(psc.quote, psc.cghList, psc.existingChargeGroupHolders, Double.valueOf(1.0));
        } catch (Exception ex) {
            //Thanks Zuora...
        }
        psc.addNewCharges();

        String result = psc.subTotalPreview;

        Test.stopTest();

        System.assertNotEquals('ERROR', result);
    }

    @isTest static void test_amend_quote() {

        Zuora__Subscription__c originalSubscription = new Zuora__Subscription__c();
        originalSubscription.Name = 'TEST SUB';
        originalSubscription.Zuora__RenewalTerm__c = '12';
        insert originalSubscription;

        Zuora__SubscriptionProductCharge__c spc = new Zuora__SubscriptionProductCharge__c();
        spc.Name = 'Test Subscription Charge';
        spc.RATE_USD__c = '1.00';
        spc.Listed_Price__c = '100.00';
        spc.Start_Date__c = '2016-01-01'; //Date.today();
        spc.TCV_USD__c = '100.00';
        insert spc;

        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact);
        quote.Company_Code1__c = 'US46';
        quote.Primary_Quote__c = true;
        quote.PurchaseOrder__c = 'TESTPO1';
        quote.Payment_Plan__c = 'Prepaid';
        quote.Tax_Exempt__c = true;
        quote.zqu__SubscriptionType__c = 'Amend Subscription';
        quote.zqu__ExistSubscriptionID__c = originalSubscription.id;
        update quote;

        //zqu__QuoteAmendment__c qa = new zqu__QuoteAmendment__c();
        //qa.zqu__Quote__c = quote.Id;
        //insert qa;

        //zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
        //qrp.zqu__Quote__c = quote.Id;
        //qrp.zqu__QuoteAmendment__c = qa.Id;

        //insert qrp;

        //zqu__QuoteChargeSummary__c qcs = new zqu__QuoteChargeSummary__c();
        //qcs.zqu__QuoteRatePlan__c = qrp.Id;
        //qcs.zqu__TCV__c = 120.00;
        //qcs.zqu__MRR__c = 10.00;

        //insert qcs;

        //qcs.Billing_Period__c = 'Annual';
        //update qcs;

        //ApexPages.StandardController con = new ApexPages.StandardController(quote);
        //ProductSelectorController psc = new ProductSelectorController(con);

        //Test.startTest();
        
        //psc.validateAndSaveQuote();

        ApexPages.StandardController con = new ApexPages.StandardController(quote);
        ProductSelectorController psc = new ProductSelectorController(con);

        Map<String, zqu__ProductRatePlan__c> productCatalog = ZTestFactory.makePivotalProductCatalog();
        Set<String> quoteChargeCustomFields = new Set<String>{'listed_price__c', 'product_rate_plan_zuoraid__c', 'product_rate_plan__c', 'listed_total__c', 'initial_term__c', 'start_date__c', 'start_date_display__c', 'end_date__c', 'end_date_display__c', 'country_uplift__c', 'rate_usd__c', 'calculated_discount__c', 'zqu__period__c', 'zqu__specificbillingperiod__c','zqu__triggerdate__c','zqu__triggerevent__c', 'quote_split_number__c','psamount__c','product_name__c','tcv_usd__c','acv_usd__c','arr_usd__c','mrr_usd__c','custom_tcv_formula__c'};
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = quoteChargeCustomFields;
        zqu.zChargeGroup chargeGroup1 = zqu.zQuoteUtil.getChargeGroup(quote.Id, productCatalog.get('Annual').Id);
        zqu.zCharge charge = chargeGroup1.zCharges[0];
        charge.ChargeObject.put('Listed_Price__c', '5000');
        charge.ChargeObject.put('Start_Date__c', '2015-06-12');
        charge.ChargeObject.put('Initial_Term__c', 12);
        charge.ChargeObject.put('Listed_Total__c', '5000');
        charge.ChargeObject.put('Calculated_Discount__c', '5');
        String chargeName = chargeGroup1.zCharges[0].NAME;

        List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>();
        chargeGroups.add(chargeGroup1);
        zqu.zQuoteUtil.addChargeGroups(chargeGroups);

        Integer pageSize = psc.productRatePlanSetPageSize;
        Integer pageNumber = psc.productRatePlanSetPageNumber;
        Integer maxPageSize = psc.productRatePlanSetMaxPage;
        Integer resultSize = psc.productRatePlanSetResultSize;
        Boolean hasNext = psc.productRatePlanSetHasNext;
        Boolean hasPrevious = psc.productRatePlanSetHasPrevious;
        List < zqu__productRatePlan__c > records = psc.productRatePlanSetRecords;
        psc.pickProduct();
        List < SelectOption > productFamily = psc.productFamilyValues;
        List < SelectOption > serviceCategory = psc.serviceCategoryValues;
        List < SelectOption > availability = psc.availabilityValues;
        boolean showPF = psc.showProductFamily;
        boolean showSC = psc.showServiceCategory;
        boolean showA = psc.showAvailability;
        psc.next();
        psc.previous();
        psc.doSearch();
        psc.doClearSearch();
        Test.startTest();
        psc.selectedProductFamily = 'All';
        psc.pickProductFamily();
        psc.selectedServiceCategory = 'All';
        psc.pickServiceCategory();
        psc.selectedAvailability = 'All';
        psc.pickAvailability();
        psc.pickProduct();
        

        psc.isNew = 'false';
        psc.selectedChargeGroupId = '0';
        psc.effectivePriceChange();
        psc.quantityChange();
        psc.startDateChange();
        psc.durationChange();
        psc.listPriceChange();
        psc.discountChange();

        psc.isNew = 'true';
        psc.selectedChargeGroupId = '1';
        psc.effectivePriceChange();
        psc.quantityChange();
        psc.startDateChange();
        psc.durationChange();
        psc.listPriceChange();
        psc.discountChange();
        //psc.selectedproductRatePlanMap.put(annualRatePlan, false);
        //psc.pickRatePlan();
        psc.removeChargeGroup();
        psc.validateQuote();
        boolean showCharges = psc.showExistingCharges;
        boolean RatePlanSelected = psc.productRatePlanSelected;
        boolean showPlans = psc.showRatePlans;
        psc.addNewCharges();

        psc.validateQuote();
        psc.validateAndSaveQuote();

        Test.stopTest();
    }

    @isTest static void test_renewal_quote() {
        Test.startTest();
        Zuora__Subscription__c originalSubscription = new Zuora__Subscription__c();
        originalSubscription.Name = 'TEST SUB';
        originalSubscription.Zuora__RenewalTerm__c = '12';
        insert originalSubscription;

        Zuora__SubscriptionProductCharge__c spc = new Zuora__SubscriptionProductCharge__c();
        spc.Name = 'Test Subscription Charge';
        spc.RATE_USD__c = '1.00';
        spc.Listed_Price__c = '100.00';
        spc.Start_Date__c = '2016-01-01'; //Date.today();
        spc.TCV_USD__c = '100.00';
        insert spc;


        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact);
        quote.Company_Code1__c = 'US46';
        quote.Primary_Quote__c = true;
        quote.PurchaseOrder__c = 'TESTPO1';
        quote.Payment_Plan__c = 'Prepaid';

        Program__c program = new Program__c();
        program.Name = 'Test Program';

        insert program;

        acct.Program__c = program.Id;
        update acct;

        quote.zqu__ExistSubscriptionID__c = originalSubscription.id;
        quote.zqu__SubscriptionType__c = 'Renew Subscription';
        quote.zqu__RenewalTerm__c = 24;
        quote.Payment_Plan__c = 'Prepaid';
        update quote;

        zqu__QuoteAmendment__c qa = new zqu__QuoteAmendment__c();
        qa.zqu__Quote__c = quote.Id;
        insert qa;

        zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c();
        qrp.zqu__Quote__c = quote.Id;
        qrp.zqu__QuoteAmendment__c = qa.Id;

        insert qrp;

        zqu__QuoteChargeSummary__c qcs = new zqu__QuoteChargeSummary__c();
        qcs.zqu__QuoteRatePlan__c = qrp.Id;
        qcs.zqu__TCV__c = 120.00;
        qcs.zqu__MRR__c = 10.00;

        insert qcs;

        qcs.Billing_Period__c = 'Annual';
        update qcs;

        ApexPages.StandardController con = new ApexPages.StandardController(quote);
        ProductSelectorController psc = new ProductSelectorController(con);

        psc.updateQuoteServiceActivationDate(Date.today());
        psc.validateAndSaveQuote();

        psc.amendPreviewCall();
        Test.stopTest();
    }

    @isTest static void test_QuoteCharge(){
        Test.startTest();
        zqu__Quote__c quote = createTestQuote();

        // this object is obsolite but need test coverage
        zqu__QuoteCharge__c qc = new zqu__QuoteCharge__c();
        qc.name = 'test';
        qc.zqu__Quote__c = quote.id;

        insert qc;
        Test.stopTest();
    }

    @IsTest
    static void testSpecificBillingPeriodVisible(){
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact);
        ApexPages.StandardController con = new ApexPages.StandardController(quote);
        ProductSelectorController psc = new ProductSelectorController(con);
        Id profileID1 = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        Id profileID2 = [SELECT Id, Name FROM Profile WHERE Name = 'Contract Manager' LIMIT 1].Id;
        User u1 = new User(
                Username='test123456789QWASCAWCAWC1@test.com',
                LastName='testLastName',
                Email='test123456789QWASCAWCAWC1@test.com',
                ProfileId = profileID1,
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey='GMT',
                EmailEncodingKey='UTF-8',
                Alias = 'utu1'
        );
        User u2 = new User(
                Username='test123456789QWACWCAWCA2@test.com',
                LastName='testLastName',
                Email='test123456789QWACWCAWCA2@test.com',
                ProfileId = profileID2,
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                TimeZoneSidKey='GMT',
                EmailEncodingKey='UTF-8',
                Alias = 'utu2'
        );
        insert new List<User>{u1, u2};
        Product_Selector_View_Settings__c newSettings = Product_Selector_View_Settings__c.getInstance(u1.Id);
        newSettings.Exposed_Specific_Billing_Period__c = true;
        upsert newSettings;

        Boolean isVisibleForU1 = false;
        Boolean isVisibleForU2 = false;
        Test.startTest();
        System.runAs(u1){
            isVisibleForU1 = psc.getSpecificBillingPeriodVisibleForUser();
        }

        System.runAs(u2){
            isVisibleForU2 = psc.getSpecificBillingPeriodVisibleForUser();
        }
        Test.stopTest();
        System.assert(isVisibleForU1);
        System.assert(!isVisibleForU2);
    }

    public static zqu__Quote__c createTestQuote(){
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact);

        return quote;
    }

    public static List<Zuora.zApi.SubscribeResult> dummySubscribeResults() {
        List<Zuora.zApi.SubscribeResult> result = new List<Zuora.zApi.SubscribeResult>();
        Zuora.zApi.SubscribeResult obj = new Zuora.zApi.SubscribeResult();
        obj.success = true;
        List<Zuora.zObject> invoicedatas = new List<Zuora.zObject>();
        Zuora.zObject invoicedata = new Zuora.zObject('InvoiceData');
        Zuora.zObject invoice = new Zuora.zObject('Invoice');
        invoice.setValue('AmountWithoutTax', 42534);
        invoice.setValue('TaxAmount', 233);
        invoicedata.setValue('Invoice', invoice);
        invoicedatas.add(invoicedata);
        obj.InvoiceDatas = invoicedatas;
        result.add(obj);
        return result;
    }
}