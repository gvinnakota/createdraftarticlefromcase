/******************************************************************************
Name                :    PivLP_Tests
Author              :    Reid Beckett, Launchpad
Description         :    Test coverage for PivLP classes
Date                :    10/01/2018
*******************************************************************************/
@isTest(SeeAllData=true)
public class PivLP_Tests {

    @isTest static void test_ZSOAPClient() {
        List<Zuora.zObject> zobjs = new List<Zuora.zObject>();
        Zuora.zObject zobj = new Zuora.zObject('Account');
		zobjs.add(zobj);
        ((PivLP_ZSOAPClient)PivLP_ZSOAPClient.getInstance()).getRealZAPIInstance();
        zAPIMock.Mock_Error = true;
        try {
            PivLP_ZSOAPClient.getInstance().zcreate(zobj);
        }catch(Exception e){

        }
        zAPIMock.Mock_Error = false;
        PivLP_ZSOAPClient.getInstance().zcreate(zobj);
        PivLP_ZSOAPClient.getInstance().zcreate(zobjs);
        PivLP_ZSOAPClient.getInstance().zupdate(zobj);
        zAPIMock.Mock_Error = true;
        try {
	        PivLP_ZSOAPClient.getInstance().zupdate(zobj);
        }catch(Exception e){
        }
        zAPIMock.Mock_Error = false;
        //PivLP_ZSOAPClient.getInstance().zupdate(zobjs);
        PivLP_ZSOAPClient.getInstance().zdelete('Account', '1111');
        zAPIMock.Mock_Error = true;
        try {
	        PivLP_ZSOAPClient.getInstance().zdelete('Account', '1111');
        }catch(Exception e){
        }
        zAPIMock.Mock_Error = false;
        PivLP_ZSOAPClient.getInstance().zdelete('Account', new List<String>{'1111'});
        PivLP_ZSOAPClient.getInstance().zquery('select Id from Account');
        List<Zuora.zApi.SubscribeRequest> subReqs = new List<Zuora.zApi.SubscribeRequest>();
        PivLP_ZSOAPClient.getInstance().zsubscribe(subReqs);
    }

    static zqu__Quote__c setup_split_test(){
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact, false);
        quote.Company_Code1__c = 'US46';
        quote.Primary_Quote__c = true;
        quote.PurchaseOrder__c = 'TESTPO1';
        insert quote;

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
        charge.ChargeObject.put('Quote_Split_Number__c', '1');
        String chargeName = chargeGroup1.zCharges[0].NAME;
        zqu.zChargeGroup chargeGroup2 = zqu.zQuoteUtil.getChargeGroup(quote.Id, productCatalog.get('Support').Id);
        zqu.zCharge charge2 = chargeGroup2.zCharges[0];
        charge2.ChargeObject.put('Listed_Price__c', '5000');
        charge2.ChargeObject.put('Start_Date__c', '2015-06-12');
        charge2.ChargeObject.put('Initial_Term__c', 12);
        charge2.ChargeObject.put('Listed_Total__c', '5000');
        charge2.ChargeObject.put('Calculated_Discount__c', '5');
        charge2.ChargeObject.put('Quote_Split_Number__c', '1');
        zqu.zChargeGroup chargeGroup3 = zqu.zQuoteUtil.getChargeGroup(quote.Id, productCatalog.get('ServiceUsage').Id);
        zqu.zCharge charge3 = chargeGroup3.zCharges[0];
        charge3.ChargeObject.put('Listed_Price__c', '5000');
        charge3.ChargeObject.put('Start_Date__c', '2015-06-12');
        charge3.ChargeObject.put('Initial_Term__c', 12);
        charge3.ChargeObject.put('Listed_Total__c', '5000');
        charge3.ChargeObject.put('Calculated_Discount__c', '5');
        charge3.ChargeObject.put('Quote_Split_Number__c', 'Services-2016-06-12');
        List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>();
        chargeGroups.add(chargeGroup1);
        chargeGroups.add(chargeGroup2);
        chargeGroups.add(chargeGroup3);
        zqu.zQuoteUtil.addChargeGroups(chargeGroups);
        return quote;
    }

    @isTest static void test_ZOrdersManager_1(){
        zqu__Quote__c qt = setup_split_test();
        system.assertNotEquals(0, [select Id from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__r.zqu__Quote__c = :qt.Id].size());
        PivLP_SendToZBillingAuraController.initAction(qt.Id);
        List<PivLP_AuraModel.Quote> chargeKeys = PivLP_SendToZBillingAuraController.getChargeKeys(qt.Id);
        system.assertNotEquals(0, chargeKeys.size());
        PivLP_SendToZBillingAuraController.cleanSplit(qt.Id);
    }

    @isTest static void test_ZOrdersManager_1b(){
      zqu__Quote__c qt = setup_split_test();
      system.assertNotEquals(0, [select Id from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__r.zqu__Quote__c = :qt.Id].size());
      PivLP_SendToZBillingAuraController.initAction(qt.Id);
      List<PivLP_AuraModel.Quote> chargeKeys = PivLP_SendToZBillingAuraController.getChargeKeys(qt.Id);
      system.assertNotEquals(0, chargeKeys.size());
      Test.startTest();
      List<Id> subQuoteIds = new List<Id>();
      for(PivLP_AuraModel.Quote q : chargeKeys){
          system.debug('*** ' + q);
          if(!q.key.startsWith('Services')) subQuoteIds.add(PivLP_SendToZBillingAuraController.splitQuote(qt.Id, q.key));
      }

      system.assertNotEquals(0, subQuoteIds.size());
      PivLP_SendToZBillingAuraController.initAction(qt.Id);
      Test.stopTest();
      //PivLP_SendToZBillingAuraController.createZuoraAccount(subQuoteIds.get(0));
      //PivLP_SendToZBillingAuraController.sendToZBilling(subQuoteIds.get(0));
    }

    @isTest static void test_ZOrdersManager_1c(){
        Test.startTest();
        zqu__Quote__c qt = setup_split_test();
        Test.stopTest();
        system.assertNotEquals(0, [select Id from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__r.zqu__Quote__c = :qt.Id].size());
        PivLP_SendToZBillingAuraController.initAction(qt.Id);
        List<PivLP_AuraModel.Quote> chargeKeys = PivLP_SendToZBillingAuraController.getChargeKeys(qt.Id);
        system.assertNotEquals(0, chargeKeys.size());
        PivLP_SendToZBillingAuraController.cleanSplit(qt.Id);
		List<Id> subQuoteIds = new List<Id>();
        for(PivLP_AuraModel.Quote q : chargeKeys){
            system.debug('*** ' + q);
            if(!q.key.startsWith('Services')) subQuoteIds.add(PivLP_SendToZBillingAuraController.splitQuote(qt.Id, q.key));
        }

        system.assertNotEquals(0, subQuoteIds.size());
        PivLP_SendToZBillingAuraController.initAction(qt.Id);
        PivLP_SendToZBillingAuraController.createZuoraAccount(subQuoteIds.get(0));
        //PivLP_SendToZBillingAuraController.sendToZBilling(subQuoteIds.get(0));
    }

    @isTest static void test_ZOrdersManager_1d(){
        Test.startTest();
        zqu__Quote__c qt = setup_split_test();
        Test.stopTest();
        PivLP_SendToZBillingAuraController.initAction(qt.Id);
        List<PivLP_AuraModel.Quote> chargeKeys = PivLP_SendToZBillingAuraController.getChargeKeys(qt.Id);
        system.assertNotEquals(0, chargeKeys.size());
        //PivLP_SendToZBillingAuraController.cleanSplit(qt.Id);
		List<Id> subQuoteIds = new List<Id>();
        for(PivLP_AuraModel.Quote q : chargeKeys){
            system.debug('*** ' + q);
            if(!q.key.startsWith('Services')) subQuoteIds.add(PivLP_SendToZBillingAuraController.splitQuote(qt.Id, q.key));
        }

        system.assertNotEquals(0, subQuoteIds.size());
        //PivLP_SendToZBillingAuraController.initAction(qt.Id);
        PivLP_SendToZBillingAuraController.createZuoraAccount(subQuoteIds.get(0));
        //PivLP_SendToZBillingAuraController.sendToZBilling(subQuoteIds.get(0));
    }

    @isTest static void test_ZOrdersManager_2(){
        Test.startTest();
        zqu__Quote__c qt = setup_split_test();
        system.assertNotEquals(0, [select Id from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__r.zqu__Quote__c = :qt.Id].size());
        PivLP_SendToZBillingAuraController.initAction(qt.Id);
        Test.stopTest();
        List<PivLP_AuraModel.Quote> chargeKeys = PivLP_SendToZBillingAuraController.getChargeKeys(qt.Id);
        system.assertNotEquals(0, chargeKeys.size());
        PivLP_SendToZBillingAuraController.cleanSplit(qt.Id);
		List<Id> subQuoteIds = new List<Id>();
        integer i=0;
        for(PivLP_AuraModel.Quote q : chargeKeys){
            if(q.key.startsWith('Services')) subQuoteIds.add(PivLP_SendToZBillingAuraController.splitQuote(qt.Id, q.key));
            i++;
        }

        system.assertNotEquals(0, subQuoteIds.size());
    }

    @isTest static void test_ZOrdersManager_3_getChargeKeys_error(){
        PivLP_Logger.error('test error log');
        PivLP_Logger.save('test save log');
        zqu__Quote__c qt = setup_split_test();
        system.assertNotEquals(0, [select Id from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__r.zqu__Quote__c = :qt.Id].size());
        PivLP_SendToZBillingAuraController.initAction(qt.Id);
        PivLP_SendToZBillingAuraController.quoteSplitManagerInstance = (PivLP_QuoteSplitManager)Test.createStub(PivLP_QuoteSplitManager.class, new PivLP_Mock());
        try {
            List<PivLP_AuraModel.Quote> chargeKeys = PivLP_SendToZBillingAuraController.getChargeKeys(qt.Id);
        }catch(AuraHandledException e){
            //mock will throw exception
	        PivLP_SendToZBillingAuraController.quoteSplitManagerInstance = null;
        }
    }

    @isTest static void test_ZOrdersManager_4_splitQuote_error(){
        zqu__Quote__c qt = setup_split_test();
        system.assertNotEquals(0, [select Id from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__r.zqu__Quote__c = :qt.Id].size());
        PivLP_SendToZBillingAuraController.initAction(qt.Id);
        List<PivLP_AuraModel.Quote> chargeKeys = PivLP_SendToZBillingAuraController.getChargeKeys(qt.Id);

        try {
            Test.startTest();
            List<Id> subQuoteIds = new List<Id>();
            integer i=0;
	        PivLP_SendToZBillingAuraController.quoteSplitManagerInstance = (PivLP_QuoteSplitManager)Test.createStub(PivLP_QuoteSplitManager.class, new PivLP_Mock());
            for(PivLP_AuraModel.Quote q : chargeKeys){
                if(q.key.startsWith('Services')) subQuoteIds.add(PivLP_SendToZBillingAuraController.splitQuote(qt.Id, q.key));
                i++;
            }

            system.assertNotEquals(0, subQuoteIds.size());
            Test.stopTest();
        }catch(AuraHandledException e){
            //mock will throw exception
	        PivLP_SendToZBillingAuraController.quoteSplitManagerInstance = null;
        }
    }

    @isTest static void test_ZOrdersManager_5_cleanQuote_error(){

        zqu__Quote__c qt = setup_split_test();
        PivLP_SendToZBillingAuraController.quoteSplitManagerInstance = (PivLP_QuoteSplitManager)Test.createStub(PivLP_QuoteSplitManager.class, new PivLP_Mock());
        try {
	        PivLP_SendToZBillingAuraController.cleanSplit(qt.Id);
        }catch(AuraHandledException e){
            //mock will throw exception
	        PivLP_SendToZBillingAuraController.quoteSplitManagerInstance = null;
        }
    }

    @isTest static void test_ZOrdersManager_6_init_error(){

        zqu__Quote__c qt = setup_split_test();
        PivLP_SendToZBillingAuraController.zordersManagerInstance = (PivLP_ZOrdersManager)Test.createStub(PivLP_ZOrdersManager.class, new PivLP_Mock());
        try {
	        PivLP_SendToZBillingAuraController.initAction(qt.Id);
        }catch(AuraHandledException e){
            //mock will throw exception
	        PivLP_SendToZBillingAuraController.quoteSplitManagerInstance = null;
        }
    }

    @isTest static void test_ZOrdersManager_sendError(){
        zqu__Quote__c qt = setup_split_test();
        system.assertNotEquals(0, [select Id from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__r.zqu__Quote__c = :qt.Id].size());
        PivLP_SendToZBillingAuraController.initAction(qt.Id);
        List<PivLP_AuraModel.Quote> chargeKeys = PivLP_SendToZBillingAuraController.getChargeKeys(qt.Id);
        system.assertNotEquals(0, chargeKeys.size());
        PivLP_SendToZBillingAuraController.cleanSplit(qt.Id);
        Test.startTest();
		List<Id> subQuoteIds = new List<Id>();
        for(PivLP_AuraModel.Quote q : chargeKeys){
            if(!q.key.startsWith('Services')) subQuoteIds.add(PivLP_SendToZBillingAuraController.splitQuote(qt.Id, q.key));
        }

        system.assertNotEquals(0, subQuoteIds.size());
        PivLP_SendToZBillingAuraController.createZuoraAccount(subQuoteIds.get(0));
        zAPIMock.Mock_SendToZBilling_Error = true;
        try{
            PivLP_SendToZBillingAuraController.sendToZBilling(subQuoteIds.get(0));
        }catch(Exception e){}
        Test.stopTest();
    }

    @isTest static void cover_zAPI(){
        List<Zuora.zObject> zobjs = new List<Zuora.zObject>();
        Zuora.zObject zobj = new Zuora.zObject('Account');
		zobjs.add(zobj);
        new zAPI().zcreate(zobjs);
        new zAPI().zquery(null);
        new zAPI().zupdate(null);
        new zAPI().zdelete(null,null);
        new zAPI().zsubscribe(null);
    }

    @isTest static void test_DisplayFieldSetAuraController(){
        Test.startTest();
        zqu__Quote__c qt = setup_split_test();
        Test.stopTest();
        DisplayFieldSetAuraController.getFields(new Map<String,Object>{'Id'=>qt.Id}, 'zqu__Quote__c', 'Quote_Information_Custom');
    }

    @isTest static void test_Quote_trigger(){
        Account acct = ZTestFactory.makeAccount();
        Zuora__CustomerAccount__c ca = new Zuora__CustomerAccount__c();
        ca.Name = 'Test Billing Account';
        ca.Zuora__Account__c = acct.Id;
        ca.Zuora__AccountNumber__c = 'A1111';
        ca.Zuora__Zuora_Id__c = 'ABC123';
        insert ca;

        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact, false);
        quote.Company_Code1__c = 'US46';
        quote.Primary_Quote__c = true;
        quote.PurchaseOrder__c = 'TESTPO1';
        quote.zqu__ZuoraAccountID__c = 'ABC123';
        quote.RecordTypeId = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('Amendment').getRecordTypeId();
        insert quote;

        quote = [select zqu__Zuora_Account_Number__c from zqu__Quote__c where Id = :quote.Id];
        system.assertEquals('A1111', quote.zqu__Zuora_Account_Number__c);
    }

    @isTest static void test_cover_NewQuotePageController_new(){
        Company_Code__c cc = new Company_Code__c(Code__c='TestCompanyCode', Currency__c = 'USD');
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        ApexPages.currentPage().getParameters().put('quoteType','Subscription');
        ApexPages.StandardController con = new ApexPages.StandardController(opp);
        NewQuotePageController c = new NewQuotePageController(con);
        system.debug(c.optionsForBillTo);
        system.debug(c.optionsForSoldTo);
        system.debug(c.currencyValues);
        system.debug(c.quote);
        c.quote.Company_Code1__c = 'TestCompanyCode';
        //c = new NewQuotePageController(con);
        system.debug(c.companyCodeValues);
        new NewQuotePageController.PropertyContactLookupController().getAdditionalCondition();
        NewQuotePageController.DefaultValuesPlugin dvp = new NewQuotePageController.DefaultValuesPlugin();
        system.debug(dvp.api);
        dvp.populateDefaultFieldValue((SObject)c.quote, c);
        new PivLP_Exception();
    }

    @isTest static void test_cover_NewQuotePageController_amend(){
        Company_Code__c cc = new Company_Code__c(Code__c='TestCompanyCode', Currency__c = 'USD');
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);

        ApexPages.currentPage().getParameters().put('billingAccountId', 'dasgadgkjbn23lkj245');
        ApexPages.currentPage().getParameters().put('crmAccountId', acct.Id);
        ApexPages.currentPage().getParameters().put('oppId', opp.Id);
        ApexPages.currentPage().getParameters().put('quoteType', 'Amendment');
        ApexPages.currentPage().getParameters().put('editMode', 'false');
        ApexPages.StandardController con = new ApexPages.StandardController(opp);
        NewQuotePageController c = new NewQuotePageController(con);
        system.debug(c.optionsForBillTo);
        system.debug(c.optionsForSoldTo);
        system.debug(c.currencyValues);
        system.debug(c.quote);
        c.quote.Company_Code1__c = 'TestCompanyCode';
        //c = new NewQuotePageController(con);
        system.debug(c.companyCodeValues);
        new NewQuotePageController.PropertyContactLookupController().getAdditionalCondition();
        NewQuotePageController.DefaultValuesPlugin dvp = new NewQuotePageController.DefaultValuesPlugin();
        system.debug(dvp.api);
        dvp.populateDefaultFieldValue((SObject)c.quote, c);
        new PivLP_Exception();
    }

    @isTest static void test_cover_ProductSelectorController1(){

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

        for(ProductSelectorController.ChargeGroupHolder cgh: psc.cghList){
	        psc.planToDuplicate = cgh.id;
        }

        psc.doDuplicateRatePlan();

        psc.selectedproductRatePlanMap.put(annualRatePlan, false);
        psc.selectedproductRatePlan = annualRatePlan;
        psc.selectedChargeName = chargeName;
        psc.pickRatePlan();
        Test.stopTest();
    }

    @isTest static void test_cover_ProductSelectorController2(){

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
        Test.startTest();
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
        //psc.validateAndSaveQuote();
    		//psc.removeAll();
        Test.stopTest();
    }

    @isTest static void test_cover_ProductSelectorController2b(){

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
        Test.startTest();
        psc.doSearch();
        Test.stopTest();
    }

    @isTest static void test_cover_ProductSelectorController3(){

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
		/*
        Map<String, String> chargeToRatePlanMap = new Map<String, String>();
        for(zqu.zChargeGroup chargeGroup : chargeGroups){
            for (zqu.ZCharge charge : chargeGroup.zCharges) {
              System.debug('prp id: '+chargeGroup.productRateplanZuoraID);
              chargeToRatePlanMap.put(charge.PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID, String.valueOf(charge.ChargeObject.get('Product_Rate_Plan_ZuoraID__c')));
            }
        }
		psc.subscribePreviewCall(chargeGroups, chargeToRatePlanMap, quote);
		*/
        Test.stopTest();
    }

    @isTest static void test_cover_Booking_ZQuoteTriggerHandler(){

        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact);

        Pricebook2 pb = new Pricebook2(Name = 'Subscription', IsActive = true);
        insert pb;

        List<PricebookEntry> pbEntries = new List<PricebookEntry>();
        Map<String, zqu__ProductRatePlan__c> productCatalog = ZTestFactory.makePivotalProductCatalog();
        Map<Id, Product2> sfdcProducts = new Map<Id, Product2>();
        DateTime dt = DateTime.now().addMinutes(-10);
        for(zqu__ZProduct__c zp : [select Id, Name, zqu__SKU__c, zqu__ZuoraId__c from zqu__ZProduct__c where CreatedDate >= :dt]){
            Product2 p = new Product2(
            	Name = zp.Name, zqu__SKU2__c = zp.zqu__SKU__c, zqu__ZuoraId__c = zp.zqu__ZuoraId__c, ProductCode = zp.zqu__SKU__c
            );
            sfdcProducts.put(zp.Id, p);
        }
        insert sfdcProducts.values();
        for(Product2 p : sfdcProducts.values()){
            system.debug('product code='+p.ProductCode);
            PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = p.Id, IsActive = true, CurrencyIsoCode = 'USD', UnitPrice = 1000);
            PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = p.Id, IsActive = true, CurrencyIsoCode = 'USD', UnitPrice = 1000);
            pbEntries.add(pbe1);
            pbEntries.add(pbe2);
        }
        insert pbEntries;

        List<zqu__ProductRatePlan__c> prps = [select Id, zqu__ZProduct__c, zqu__Product__c from zqu__ProductRatePlan__c where CreatedDate = TODAY and zqu__ZProduct__c != null];
        for(zqu__ProductRatePlan__c prp : prps){
            system.assertNotEquals(null, prp.zqu__ZProduct__c);
            Product2 p = sfdcProducts.get(prp.zqu__ZProduct__c);
            if(p != null) {
                prp.zqu__Product__c = p.Id;
            }
        }
        update prps;

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
        List<zqu__QuoteChargeSummary__c> qcss = [SELECT id, name, Booking_SKU__c, zqu__QuoteRatePlanCharge__c from zqu__QuoteChargeSummary__c where zqu__QuoteRatePlan__c in :qrpIds];
        system.assertNotEquals(0, qcss.size());

        Set<String> skus = new Set<String>();
        for(zqu__QuoteChargeSummary__c qcs : qcss){
            skus.add(qcs.Booking_SKU__c);
        }

        List<String> skusList = new List<String>(skus);
        Integer i = 0;
        Integer num_skus = skusList.size();

        for(Product2 p : sfdcProducts.values()){
            integer idx = i < num_skus ? i : 0;
            p.ProductCode = skusList.get(idx);
            i++;
        }
        update sfdcProducts.values();

        /*
        List<PricebookEntry> pricebookEntries = [
            SELECT Id, Pricebook2Id, Product2Id, CurrencyIsoCode, ProductCode FROM PricebookEntry
            WHERE Pricebook2.Name = 'Subscription' AND IsActive = true AND ProductCode IN :skus
        ];*/


        quote.Company_Code1__c = 'US46';
        quote.Primary_Quote__c = true;
        quote.PurchaseOrder__c = 'TESTPO1';
        quote.zqu__Status__c = 'Sent to Z-Billing';
        quote.Fulfilled__c = false;

        Test.startTest();
        update quote;
        Test.stopTest();

    }

    private static zqu__Quote__c createTestQuote(){
        zqu__ZProduct__c zprod = ZTestFactory.prepareProductCatalog(true);
        Map<String, zqu__ProductRatePlan__c> prpMap = ZTestFactory.makePivotalProductCatalog();
        zqu__ProductRatePlan__c prepaidRatePlan = prpMap.get('Prepaid');
        prepaidRatePlan.zqu__ZuoraId__c = 'adgadfgakhj';
        update prepaidRatePlan;
        zqu__ProductRatePlanCharge__c prpc = [SELECT id from zqu__ProductRatePlanCharge__c where zqu__ProductRatePlan__c = :prepaidRatePlan.Id];

        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact);
        zqu__QuoteAmendment__c quoteAmendment = ZTestFactory.makeQuoteAmendment(quote);
        zqu__QuoteRatePlan__c quoteRatePlan = ZTestFactory.makeQuoteRatePlan(quote, quoteAmendment);
        quoteRatePlan.zqu__ProductRatePlanZuoraId__c = 'adgadfgakhj';
        update quoteRatePlan;

        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
        zqu__QuoteChargeSummary__c quoteChargeSummary = ZTestFactory.makeQuoteChargeSummary(quoteRatePlan, quoteRatePlanCharge);


        zqu__ProductRatePlan__c serviceRatePlan = prpMap.get('ServiceUsage');
        serviceRatePlan.zqu__ZuoraId__c = 'adgadfgakhi';
        update serviceRatePlan;
        zqu__ProductRatePlanCharge__c prpc2 = [SELECT id from zqu__ProductRatePlanCharge__c where zqu__ProductRatePlan__c = :serviceRatePlan.Id];

        zqu__QuoteAmendment__c quoteAmendment2 = ZTestFactory.makeQuoteAmendment(quote);
        zqu__QuoteRatePlan__c quoteRatePlan2 = ZTestFactory.makeQuoteRatePlan(quote, quoteAmendment2);
        quoteRatePlan2.zqu__ProductRatePlanZuoraId__c = 'adgadfgakhj';
        update quoteRatePlan2;

        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge2 = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan2, prpc2);
        zqu__QuoteChargeSummary__c quoteChargeSummary2 = ZTestFactory.makeQuoteChargeSummary(quoteRatePlan2, quoteRatePlanCharge2);

        return quote;
    }
}