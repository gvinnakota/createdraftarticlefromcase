@IsTest
private class ZQuote_EmailTemplate_Controller_Test {

    private static testmethod void contactTest(){

        Account acct = TestDataFactory.createAccount(true);
        Contact contact = TestDataFactory.createContact(acct.Id,true);
        Opportunity opp = TestDataFactory.createOpportunity(acct.Id,true);

        Product2 productvar = TestDataFactory.createProduct2(false);
        productvar.ProductCode = 'SKU-A-00000001';
        productvar.Selling_Motion__c = 'PaaS';
        insert productvar;

        PricebookEntry pbr = TestDataFactory.createPricebookEntry(productvar.Id,2345,true);

        Pricebook2 pbk = TestDataFactory.createPricebook2(true);
        pbk.Name = 'Subscription';
        update pbk;

        PricebookEntry custompbEntry = new PricebookEntry();
        custompbEntry.Product2Id = productvar.Id;
        custompbEntry.UnitPrice = 23456.00;
        custompbEntry.IsActive = true;
        custompbEntry.Pricebook2Id = pbk.Id;
        custompbEntry.CurrencyIsoCode = 'USD';
        insert custompbEntry;

        zqu__Quote__c quote = TestDataFactory.makeQuote(opp,contact);
        quote.Company_Code1__c = 'US46';
        quote.Primary_Quote__c = true;
        quote.PurchaseOrder__c = 'TESTPO1';
        quote.Payment_Plan__c = 'Annual';
        quote.Tax_Exempt__c = true;
        quote.Channel__c = 'Direct';
        update quote;

        zqu__ZProduct__c zprod = TestDataFactory.creatZProduct('SKU-A-00000001','SKU-A-00000001',true);

        zqu__Quote__c updatedQuote = [SELECT Id,name,zqu__Currency__c,zqu__Status__c from zqu__Quote__c where Id=:quote.Id];

        zqu__ProductRatePlan__c prp = TestDataFactory.createProductRatePlan(zprod,'Test Prp',false);
        prp.BillingPeriod__c = 'Annual';
        prp.zqu__Product__c = productvar.Id;
        insert prp;

        zqu__ProductRatePlanCharge__c prpc = TestDataFactory.createProductRatePlanCharge(prp,'Recurring' ,'Per Unit Pricing',true);
        zqu__ProductRatePlanChargeTier__c prctp = TestDataFactory.makeProductRatePlanChargeTier(prpc.Id,true);

        Set<String> quoteChargeCustomFields = new Set<String>{'listed_price__c', 'product_rate_plan_zuoraid__c', 'product_rate_plan__c', 'listed_total__c', 'initial_term__c', 'start_date__c', 'start_date_display__c', 'end_date__c', 'end_date_display__c', 'country_uplift__c', 'rate_usd__c', 'calculated_discount__c', 'zqu__period__c', 'zqu__specificbillingperiod__c','zqu__triggerdate__c','zqu__triggerevent__c', 'quote_split_number__c','psamount__c','product_name__c','tcv_usd__c','acv_usd__c','arr_usd__c','mrr_usd__c','custom_tcv_formula__c'};
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = quoteChargeCustomFields;
        zqu.zChargeGroup chargeGroup1 = zqu.zQuoteUtil.getChargeGroup(quote.Id, prp.Id);
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

        List<zqu__QuoteRatePlan__c> updateqrp = new List<zqu__QuoteRatePlan__c>();
        List<zqu__QuoteRatePlan__c> qrps = [SELECT id, name,zqu__ProductRatePlan__c,zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU2__c from zqu__QuoteRatePlan__c where zqu__Quote__c = :updatedQuote.Id];
        List<String> qrpIds = new List<String>();
        for (zqu__QuoteRatePlan__c qrp : qrps) {
            qrp.zqu__ProductRatePlan__c = prp.Id;
            updateqrp.add(qrp);
        }
        update updateqrp;
        List<zqu__QuoteChargeSummary__c> updateqcss = new List<zqu__QuoteChargeSummary__c>();
        List<zqu__QuoteChargeSummary__c> qcss = [SELECT Id, name, Product_Rate_Plan_Charge__c,Booking_SKU__c,zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Currency__c,zqu__QuoteRatePlanCharge__c from zqu__QuoteChargeSummary__c where zqu__QuoteRatePlan__r.Id in :updateqrp];

        List<zqu__QuoteRatePlanCharge__c> qrpcs = [SELECT id, name from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__c in :qrpIds];

        Test.startTest();
        ZQuote_EmailTemplate_Controller emailTemplate_controller = new ZQuote_EmailTemplate_Controller();
        emailTemplate_controller.quoteId = updatedQuote.Id;

        List<zqu__QuoteChargeSummary__c> qcsList = emailTemplate_controller.results;
        Test.stopTest();

        system.debug('@@'+emailTemplate_controller.results);
    }
}