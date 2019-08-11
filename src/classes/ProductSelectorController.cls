public with sharing class ProductSelectorController {
    public String NOT_DISCOUNTABLE_MESSAGE {
        get{
            if(NOT_DISCOUNTABLE_MESSAGE == null){
                NOT_DISCOUNTABLE_MESSAGE = 'Not discountable';
            }
            return NOT_DISCOUNTABLE_MESSAGE;
        }
        set;
    }

    public Boolean canOverrideNotDiscountable {
        get{
            if(canOverrideNotDiscountable == null){
                canOverrideNotDiscountable = Undiscountable_Charges_Override__c.getInstance().Can_Override_Undiscountable_Charges__c;
            }
            return canOverrideNotDiscountable;
        }
        set;
    }

    //used to facilitate editing the chargeGroups
    public class ChargeGroupHolder {
        public Integer id { get; set; }
        public zqu.zChargeGroup chargeGroup { get; set; }
        public string display { get; set; }
        public string sRatePlanId { get; set; }
        public boolean isServices { get; set; }

        public zqu__ProductRatePlan__c sRatePlan { get; set; }

        public List<ChargeWrapper> chargeWrappers {
            get {
                if (chargeWrappers == null) {
                    chargeWrappers = new List<ChargeWrapper>();
                }
                return chargeWrappers;
            }
            set;
        }
        public boolean hasBeenUpdated {
            get {
                if (hasBeenUpdated == null) {
                    hasBeenUpdated = false;
                }
                return hasBeenUpdated;
            }
            set;
        }
    }

    public static ChargeGroupHolder copyChargeGroupHolder(ChargeGroupHolder source) {
        ChargeGroupHolder target = new ChargeGroupHolder();

        target.id = source.id + 100;
        target.chargeGroup = source.chargeGroup;
        target.display = source.display;
        target.sRatePlanId = source.sRatePlanId;
        target.isServices = source.isServices;
        target.sRatePlan = source.sRatePlan;
        target.chargeWrappers = new List<ChargeWrapper>(source.chargeWrappers);
        target.hasBeenUpdated = source.hasBeenUpdated;

        return target;
    }

    public class ChargeWrapper {
        public zqu.ZCharge zcharge { get; set; }
        public Date start_Date { get; set; }
        public String initial_Term { get; set; }
        public String listed_Price { get; set; }
        public String calculated_Discount { get; set; }
        public String listed_Total { get; set; }
        public boolean renderListPrice { get; set; }
        public String charge_model { get; set; }
        public Decimal oldQuantity { get; set; }
        public String rollupType { get; set; }
        public Boolean isNotDiscountable { get; set; }

        public ChargeWrapper() {
            rollupType = 'New';
        }
    }

    public List<SelectOption> rollupOptions {get;set;}

    // ------------------------------------------------------------------------
    // --- Constants ---
    // ------------------------------------------------------------------------
    /* Page size for the table with the rate plans */
    public static final Integer PAGE_SIZE = 25;
    /* Select list option for nothing selected */
    public static final String NONE = '-- none --';

    // ------------------------------------------------------------------------
    // --- Public VF Attributes ---
    // ------------------------------------------------------------------------

    private static Map<String, String> endPoints;

    public List < ChargeGroupHolder > cghList {
        get {
            if (cghList == null) {
                cghList = new List < ChargeGroupHolder >();
            }
            return cghList;
        }
        set;
    }
    /* Indicate that we successfully loaded the context */
    public Boolean initSuccess {
        get;
        set;
    }
    /* List of available customer account(s) that can subscribe */
    public List < zqu__productRatePlan__c > productRatePlanList {
        get;
        set;
    }
    /* Same, but as a map so we can display the selected account */
    public Map < ID, zqu__productRatePlan__c > productRatePlanMap {
        get;
        set;
    }
    /* Standard set controller for the list of product rate plan(s) */
    public ApexPages.StandardSetController productRatePlanSet {
        get {
            if (productRatePlanSet == null) {
                productRatePlanSet = new ApexPages.StandardSetController(new List < zqu__ProductRatePlan__c >());
            }
            return productRatePlanSet;
        }
        set;
    }
    /* Page size for the subscriber set */
    public Integer productRatePlanSetPageSize {
        get {
            return productRatePlanSet.getPageSize();
        }
        set;
    }
    /* Page number for the subscriber set */
    public Integer productRatePlanSetPageNumber {
        get {
            return productRatePlanSet.getPageNumber();
        }
        set;
    }
    /* Maximum page in the current set */
    public Integer productRatePlanSetMaxPage {
        get {
            return productRatePlanSet.getResultSize() / productRatePlanSet.getPageSize() + 1;
        }
        set;
    }
    /* Result size for the subscriber set */
    public Integer productRatePlanSetResultSize {
        get {
            return productRatePlanSet.getResultSize();
        }
        set;
    }
    /* Boolean to indicate if the subscriber set has next page */
    public Boolean productRatePlanSetHasNext {
        get {
            return productRatePlanSet.getHasNext();
        }
        set;
    }
    /* Boolean to indicate if the subscriber set has previous page */
    public Boolean productRatePlanSetHasPrevious {
        get {
            return productRatePlanSet.getHasPrevious();
        }
        set;
    }
    /* The record for the current page in the set */
    public List < zqu__productRatePlan__c > productRatePlanSetRecords {
        get {
            return productRatePlanSet.getRecords();
        }
        set;
    }
    /* Map that persists the state for the list of billing account (selected/unselected) */
    public Map < ID, Boolean > selectedproductRatePlanMap {
        get;
        set;
    }
    /* Set of selected subscriber billing account(s) */
    public Set < zqu__productRatePlan__c > selectedproductRatePlanSet {
        get;
        set;
    }
    /* Customer account that fired the checkbox event */
    public String selectedproductRatePlan {
        get;
        set;
    }
    /* Total count of selected subscribers */
    public Integer selectedproductRatePlanCount {
        get;
        set;
    }

    /* Calculate Quote subTotal for display only */
    public String subTotalPreview {
        get {
            zqu__Quote__c updatedQuote = null;
            try {
                if(quote.zqu__SubscriptionType__c == 'Renew Subscription' || quote.zqu__SubscriptionType__c == 'Amend Subscription') {
                    updatedQuote = amendPreviewCall();
                    //updatedQuote = new PivLP_QuoteSplitManager().updateQuoteSplitNumbersPreview(quote, cghList, existingChargeGroupHolders, conversionRate);
                } else if(quote.zqu__SubscriptionType__c == 'New Subscription') {
                    updatedQuote = new PivLP_QuoteSplitManager().updateQuoteSplitNumbersPreview(quote, cghList, existingChargeGroupHolders, conversionRate);
                }
            } catch (Exception e){
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                return 'ERROR';
            }

            if(updatedQuote == null){
                return formatCalculatedSubtotalForPreview(quote.Calculated_SubTotal__c);
            } else {
                return formatCalculatedSubtotalForPreview(updatedQuote.Calculated_SubTotal__c);
            }
        }
    }

    private String formatCalculatedSubtotalForPreview(String subtotalString){
        if(!String.isEmpty(subtotalString)) {
            try {
                //when subtotalString contains decimal.
                return Decimal.valueOf(subtotalString).format();
            } catch (Exception e) {
                //when subtotalString contains message.
                return subtotalString;
            }
        } else {
            return '-';
        }
    }

    public String isNew { get; set; }

    /* The quote to create */
    public zqu__Quote__c quote { get; set; }
    /* The search text (for subscriber) */
    public String productRatePlanSearchText { get; set; }
    public zqu.LookupComponentOptions optionsForProductLookup { get; set; }
    public ProductLookupController plc { get; set; }
    public boolean productSelected {
        get {
            if (productSelected == null) {
                productSelected = false;
            }
            return productSelected;
        }
        set;
    }
    public boolean showExistingCharges {
        get {
            if (showExistingCharges == null) {
                showExistingCharges = false;
            }
            return showExistingCharges;
        }
        set;
    }
    public String selectedProductId { get; set; }
    public String selectedProductName { get; set; }
    public boolean productRatePlanSelected {
        get {
            if (productRatePlanSelected == null) {
                productRatePlanSelected = false;
            }
            return productRatePlanSelected;
        }
        set;
    }

    public boolean showRatePlans {
        get {
            if (showRatePlans == null) {
                showRatePlans = true;
            }
            return showRatePlans;
        }
        set;
    }

    public static Zuora.zApi login() {

        Zuora.zApi zuoraApi = new Zuora.zApi();
        Zuora.zApi.LoginResult loginResults = null;

        if (!Test.isRunningTest()) {
            loginResults = zuoraApi.zlogin();
        } else {
            // Log into the sandbox
            loginResults = new Zuora.zApi.LoginResult();
            loginResults.ServerUrl = 'https://apisandbox.zuora.com';
            // Log into the services451 environment
            loginResults = new Zuora.zApi.LoginResult();
            loginResults.ServerUrl = 'https://services451.zuora.com';
        }
        setEndpoints(new URL(loginResults.ServerUrl));

        return zuoraApi;
    }

    public static void setEndpoints(URL url) {

        if (url.getAuthority() == 'apisandbox.zuora.com' ||
                url.getAuthority() == 'apisandbox-zforsf.zuora.com') {
            endPoints = new Map<String, String>{
                    'soap' => 'https://apisandbox.zuora.com' + url.getPath(),
                    'rest' => 'https://apisandbox-api.zuora.com/rest'
            };
        } else if (url.getAuthority() == 'services451.zuora.com' ||
                url.getAuthority() == 'service451-zforsf.zuora.com') {
            endPoints = new Map<String, String>{
                    'soap' => 'https://services451.zuora.com' + url.getPath(),
                    'rest' => 'https://services451.zuora.com/apps'
            };
        } else if (url.getAuthority() == 'www.zuora.com' ||
                url.getAuthority() == 'zforsf.zuora.com') {
            endPoints = new Map<String, String>{
                    'soap' => 'https://www.zuora.com' + url.getPath(),
                    'rest' => 'https://api.zuora.com/rest'
            };
        } else {
            throw new ZRestException('Cannot determine endpoint for [' + url + ']');
        }
    }


    public List < SelectOption > productFamilyValues {
        get {
            if (productFamilyValues == null) {
                productFamilyValues = getFieldValues('Product2', 'ProductFamily__c');
            }
            return productFamilyValues;
        }
        set;
    }

    public List < SelectOption > serviceCategoryValues {
        get {
            if (serviceCategoryValues == null) {
                serviceCategoryValues = new List < SelectOption >();
                List < SelectOption > serviceCategorys = getFieldValues('Product2', 'ProductServiceCategory__c');
                System.debug('quote type: ' + quote.zqu__SubscriptionType__c);
                for (SelectOption option : serviceCategorys) {
                    if (quote.zqu__SubscriptionType__c != 'New Subscription' && option.getValue() != quote.Subscription_Type__c) {
                        continue;
                    } else {
                        serviceCategoryValues.add(option);
                    }
                }
            }
            return serviceCategoryValues;
        }
        set;
    }

    public List < SelectOption > availabilityValues {
        get {
            if (availabilityValues == null) {
                availabilityValues = getFieldValues('zqu__ProductRatePlan__c', 'Availability__c');
                Integer counter = 0;
                for (SelectOption option : availabilityValues) {
                    if (option.getValue() == 'All') {
                        availabilityValues.remove(counter);
                        break;
                    }
                    counter++;
                }
            }
            return availabilityValues;
        }
        set;
    }

    public String pickedProductFamily { get; set; }
    public String selectedProductFamily { get; set; }
    public String pickedServiceCategory { get; set; }
    public String selectedServiceCategory { get; set; }
    public String pickedAvailability { get; set; }
    public String selectedAvailability { get; set; }
    public String selectedChargeGroupId { get; set; }
    public String selectedChargeName { get; set; }

    private CountryMultiplierService countryMultiplierSvc;
    private ChargeService chargeSvc;

    public List < ChargeGroupHolder > existingChargeGroupHolders {
        get {
            if (existingChargeGroupHolders == null) {
                existingChargeGroupHolders = new List < ChargeGroupHolder >();
            }
            return existingChargeGroupHolders;
        }
        set;
    }

    public boolean showProductFamily {
        get {
            if (showProductFamily == null) {
                showProductFamily = true;
            }
            return showProductFamily;
        }
        set;
    }

    public boolean showServiceCategory {
        get {
            if (showServiceCategory == null) {
                showServiceCategory = true;
            }
            return showServiceCategory;
        }
        set;
    }

    public boolean showAvailability {
        get {
            if (showAvailability == null) {
                showAvailability = true;
            }
            return showAvailability;
        }
        set;
    }

    public boolean showRemoveAll {
        get {
            return quote.RecordType.Name == 'default';
        }
        set;
    }

    public zqu.NotificationOptions notificationOptions { get; set; }
    // ------------------------------------------------------------------------
    // --- Private Attributes ---
    // ------------------------------------------------------------------------
    private List < zqu.zChargeGroup > existingChargeGroups {
        get {
            if (existingChargeGroups == null) {
                existingChargeGroups = new List < zqu.zChargeGroup >();
            }
            return existingChargeGroups;
        }
        set;
    }

    /* The controller passed in parameter */
    private ApexPages.StandardController controller;

    private String quoteId { get; set; }

    private Double conversionRate {
        get {
            if (conversionRate == null) {
                List<Conversion_Rate__c> conversionRates = [
                        SELECT Conversion_Rate__c
                        FROM Conversion_Rate__c
                        WHERE CurrencyIsoCode = :quote.zqu__Currency__c
                        AND End_Date__c >= TODAY
                        AND Start_Date__c <= TODAY
                ];

                if (conversionRates.size() > 0) {
                    conversionRate = conversionRates[0].Conversion_Rate__c;
                } else {
                    conversionRate = 1;
                }
            }

            return conversionRate;
        }
        set;
    }

    @TestVisible
    private CountryMultiplierInfo countryMultipliers {
        get {
            if (countryMultipliers == null) {
                countryMultipliers = countryMultiplierSvc.countryMultipliers(quote);
            }
            return countryMultipliers;
        }
        set;
    }

    private integer wrapperIdCounter {
        get {
            if (wrapperIdCounter == null) {
                wrapperIdCounter = 0;
            }
            return wrapperIdCounter;
        }
        set;
    }
    public Map < Integer, ChargeGroupHolder > chargeGroupHolderMap {
        get {
            if (chargeGroupHolderMap == null) {
                chargeGroupHolderMap = new Map < Integer, ChargeGroupHolder >();
            }
            return chargeGroupHolderMap;
        }
        set;
    }

    public Map < Integer, ChargeGroupHolder > existingChargeGroupHolderMap {
        get {
            if (existingChargeGroupHolderMap == null) {
                existingChargeGroupHolderMap = new Map < Integer, ChargeGroupHolder >();
            }
            return existingChargeGroupHolderMap;
        }
        set;
    }

    private Map<String, zqu__ProductRatePlan__c> productRatePlanZuoraIdMap {
        get {
            if (productRatePlanZuoraIdMap == null) {
                productRatePlanZuoraIdMap = new Map<String, zqu__ProductRatePlan__c>();
            }
            return productRatePlanZuoraIdMap;
        }
        set;
    }

    private Set<String> quoteChargeCustomFields {
        get {
            if (quoteChargeCustomFields == null) {
                //custom field names have to be lower cased - 3/17 - not TRUE
                quoteChargeCustomFields = new Set<String>{
                        'old_effective_price__c', 'old_quantity__c', 'listed_price__c', 'Product_Rate_Plan_ZuoraID__c', 'product_rate_plan__c', 'listed_total__c', 'initial_term__c', 'start_date__c', 'start_date_display__c', 'end_date__c', 'end_date_display__c', 'country_uplift__c', 'rate_usd__c', 'calculated_discount__c', 'zqu__period__c', 'zqu__specificbillingperiod__c', 'zqu__triggerdate__c', 'zqu__triggerevent__c', 'quote_split_number__c', 'psamount__c', 'product_name__c', 'tcv_usd__c', 'acv_usd__c', 'arr_usd__c', 'mrr_usd__c', 'custom_tcv_formula__c', 'rollup_type__c',
                        'zqu__effectivestartdate__c','zqu__effectiveenddate__c', 'zqu__specificbillingperiod__c'
                };
            }
            return quoteChargeCustomFields;
        }
        set;
    }

    // ------------------------------------------------------------------------
    // --- Public Methods ---
    // ------------------------------------------------------------------------
    /*
   *  Constructor
   */
    public ProductSelectorController(ApexPages.StandardController controller) {
        rollupOptions = new List<SelectOption>{
                new SelectOption('New', 'New'),
                new SelectOption('Renewal', 'Renewal')};
        quoteId = controller.getId();
        // Save the controller in attribute
        this.controller = controller;
        // Set up the attributes to their initial values
        initSuccess = false;
        selectedproductRatePlanMap = new Map < ID, Boolean >();
        selectedproductRatePlanSet = new Set < zqu__productRatePlan__c >();
        selectedproductRatePlanCount = 0;

        String quoteSoql = 'SELECT id,' +
                'zqu__Account__r.Name,' +
                'zqu__BillingEntity__c,' +
                'zqu__BillingEntity__r.Id,' +
                'zqu__BillingEntity__r.zqu__ZuoraId__c,' +
                'zqu__BillingEntity__r.zqu__EntityName__c,' +
                'zqu__BillingEntity__r.zqu__EntityID__c,' +
                'zqu__SubscriptionTermStartDate__c,' +
                'zqu__SoldToContact__r.MailingStreet,' +
                'zqu__SoldToContact__r.MailingCity,' +
                'zqu__SoldToContact__r.MailingCountry,' +
                'zqu__SoldToContact__r.MailingCountryCode,' +
                'zqu__SoldToContact__r.MailingPostalCode,' +
                'zqu__SoldToContact__r.MailingState,' +
                'zqu__SoldToContact__r.MailingStateCode,' +
                'zqu__SoldToContact__r.FirstName,' +
                'zqu__SoldToContact__r.LastName,' +
                'zqu__SubscriptionType__c,' +
                'Subscription_Type__c,' +
                'zqu__StartDate__c,' +
                'zqu__SubscriptionTermEndDate__c,' +
                'name,' +
                'Tax_Exempt__c,' +
                'Certificate_Id1__c,' +
                'VAT_ID1__c,' +
                'zqu__Currency__c,' +
                'zqu__PaymentTerm__c,' +
                'zqu__ZuoraAccountID__c,' +
                'zqu__Opportunity__c,' +
                'zqu__Opportunity__r.Type,' +
                'Company_Code1__c,' +
                'zqu__SoldToContact__c,' +
                'zqu__InitialTerm__c,' +
                'zqu__RenewalTerm__c,' +
                'Payment_Plan__c,' +
                'zqu__Service_Activation_Date__c,' +
                'zqu__Customer_Acceptance_Date__c,' +
                'zqu__ExistSubscriptionID__c,' +
                'zqu__AmendmentName__c,' +
                'zqu__Amendment_Name__c,' +
                'RecordType.Name,' +
                'Channel__c,'+
                'Calculated_SubTotal__c,' +
                'Override_Payment_Plan__c';
        quote = database.query(quotesoql + ' FROM zqu__Quote__c WHERE id= \'' + quoteId + '\'');

        //create the product options when everything has loaded
        plc = new ProductLookupController();
        optionsForProductLookup = plc.optionsForProductLookup;
        notificationOptions = getNotificationOptions();

        List < SelectOption > av = this.availabilityValues;
        selectedAvailability = av[0].getValue();
        pickedAvailability = av[0].getValue();


        existingChargeGroupHolders = getExistingChargeGroupHolders();
        System.debug('exisiting chargegroupholders: ' + existingChargeGroupHolders);

        System.debug('in constructor: chargeGroupHolderMap ' + chargeGroupHolderMap);

        // Everything was alright, initialization is successful
        initSuccess = true;
        countryMultiplierSvc = new CountryMultiplierService();
        chargeSvc = new ChargeService();
    }

    /*
   *  Advance the set to the next page
   */
    public void next() {
        productRatePlanSet.next();
    }

    /*
   *  Advance the set to the next page
   */
    public void previous() {
        productRatePlanSet.previous();
    }

    /*
   *  On checkbox change (product rate plan selection)
   */
    public void pickRatePlan() {
        Boolean isChecked = selectedproductRatePlanMap.get(selectedproductRatePlan);
        System.debug('##### Working with ' + selectedproductRatePlan + ' which is ' + isChecked);
        if (isChecked) {
            zqu__productRatePlan__c selectedRatePlan = productRatePlanMap.get(selectedproductRatePlan);

            selectedproductRatePlanSet.add(selectedRatePlan);
            System.debug('###### [MP] product rate Set now contains: ' + selectedproductRatePlanSet);
            selectedproductRatePlanCount++;
            cghList.addAll(getChargeGroupHolderList(selectedRatePlan));
        } else {
            planToRemove = getPlanIdByRatePlanChargeId(selectedproductRatePlan);
            doRemoveRatePlan();
        }
        if (selectedproductRatePlanCount > 0) {
            productRatePlanSelected = true;
        } else {
            productRatePlanSelected = false;
        }

    }

    private ChargeGroupHolder getPlanById(Integer id){
        for(ChargeGroupHolder cgh: cghList){
            if (cgh.id == id) {
                return cgh;
            }
        }
        return null;
    }

    private Integer getPlanIdByRatePlanChargeId(ID id){
        for(ChargeGroupHolder cgh: cghList){
            if (cgh.sRatePlanId == id) {
                return cgh.id;
            }
        }
        return null;
    }

    public Integer planToRemove {
        get;
        set;
    }


    /*
   *  On remove selected rate plan
   */
    public void doRemoveRatePlan() {
        System.debug('selected rate plan: ' + planToRemove);
        ChargeGroupHolder cghToRemove = getPlanById(planToRemove);
        if(cghToRemove == null){
            return;
        }
        selectedproductRatePlanSet.remove(cghToRemove.sRatePlan);
        selectedproductRatePlanMap.put(cghToRemove.sRatePlanId, false);
        selectedproductRatePlanCount--;
        if (selectedproductRatePlanCount > 0) {
            productRatePlanSelected = true;
        } else {
            productRatePlanSelected = false;
        }
        Integer counter = 0;
        for (ChargeGroupHolder cgh : cghList) {
            if (cgh.chargeGroup.groupType == zqu.zChargeGroup.TYPE_RENEWAL_REMOVEPRODUCT
                    || cgh.chargeGroup.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT) {
                zqu.zQuoteUtil.deleteChargeGroup(cgh.chargeGroup);
            }

            if (cgh.id == planToRemove) {
                cghList.remove(counter);
                break;
            }
            counter++;
        }
    }

    public Integer planToDuplicate {
        get;
        set;
    }

    /*
     *  On duplicate selected rate plan
     */
    public PageReference doDuplicateRatePlan() {
        System.debug('selected rate plan: ' + planToDuplicate);

        zqu__productRatePlan__c plan = getPlanById(planToDuplicate).sRatePlan;

        /*ChargeGroupHolder cgh = getChargeGroupHolderList(plan);

        cgh.clone(false, true, false, false);*/

        List<zqu__productRatePlanCharge__c> charges = [
                SELECT
                        Id
                FROM
                        zqu__ProductRatePlanCharge__c
                WHERE
                        zqu__ProductRatePlan__c = :plan.Id
        ];
        System.debug('Charges Number=' + charges.size());

        List<zqu__productRatePlanCharge__c> chargesToAdd = new List<zqu__productRatePlanCharge__c>();
        for (zqu__productRatePlanCharge__c charge : charges) {
            charge = charge.clone(false, true, false, false);
            //charge.zqu__ProductRatePlan__c = plan.Id;
        }

        try {
            upsert chargesToAdd;
        } catch (DmlException e) {
            ApexPages.addMessages(e);
        }

        selectedproductRatePlanSet.add(plan);
        productRatePlanMap.put(plan.Id, plan);
        selectedproductRatePlanMap.put(plan.Id, true);
        selectedproductRatePlanCount++;

        ChargeGroupHolder holderToDuplicate;
        for (ChargeGroupHolder holder : cghList) {
            if (holder.id == planToDuplicate) {
                holderToDuplicate = copyChargeGroupHolder(holder);
            }
        }

        System.debug('!!! holderToDuplicate=' + holderToDuplicate);

//        if (holderToDuplicate != null) {
//            holderToDuplicate.sRatePlan = plan;
//            cghList.add(holderToDuplicate);
//
//        } else {
        List<ChargeGroupHolder> holderList = getChargeGroupHolderList(plan);
//            holderList[0].chargeGroup = holderToDuplicate.chargeGroup;

        cghList.addAll(holderList);
//        }

        //addNewCharges();
        return null;
    }

    /*
   *  On search a given product rate plan
   */
    public void doSearch() {
        // Add values to the text entered
        String searchCriteria = '%' + productRatePlanSearchText + '%';
        String ratePlanQuery = buildRatePlanQuery();
        ratePlanQuery += ' AND (Name LIKE \'' + searchCriteria + '\'' + ' OR zqu__ZProduct__r.zqu__SKU__c LIKE \'' + searchCriteria + '\')';
        ratePlanQuery += ' ORDER BY Name';
        System.debug(ratePlanQuery);
        // Query the account list based on the text entered
        productRatePlanList = Database.query(ratePlanQuery);
        // Rebuild the set
        productRatePlanSet = new ApexPages.StandardSetController(productRatePlanList);
        productRatePlanSet.setPageSize(PAGE_SIZE);
        // Rebuild the map
        productRatePlanMap = new Map < ID, zqu__productRatePlan__c >(productRatePlanList);
        // Add those account to the map if they were not already present
        for (zqu__productRatePlan__c customerAccount : productRatePlanList) {
            if (selectedproductRatePlanMap.get(customerAccount.Id) == null) {
                selectedproductRatePlanMap.put(customerAccount.Id, false);
            }
        }
    }

    /*
   *  Clear the search result
   */
    public void doClearSearch() {
        productRatePlanSearchText = null;
        getProductRatePlans();
        // Rebuild the set
        productRatePlanSet = new ApexPages.StandardSetController(productRatePlanList);
        productRatePlanSet.setPageSize(PAGE_SIZE);
        productRatePlanMap = new Map < ID, zqu__productRatePlan__c >(productRatePlanList);
        // Add those account to the map if they were not already present
        for (zqu__productRatePlan__c customerAccount : productRatePlanList) {
            if (selectedproductRatePlanMap.get(customerAccount.Id) == null) {
                selectedproductRatePlanMap.put(customerAccount.Id, false);
            }
        }
    }

    /*
   * Method that faciliates a product being picked
   */
    public PageReference pickProduct() {
        //get the product rate plans with the selected product id
        //to get the unique price schdeules
        getProductRatePlans();
        productSelected = true;
        // Read through all the Product Rate Plans and capture the Price Schedule
        //query sfdc product rate plans to get a list of unique price schedules
        //from the custom field synchronized from zuora
        //set the selected product is and name on the lookup options so that
        //the selection will stay when the form is reloaded
        optionsForProductLookup.TargetId = selectedProductId;
        optionsForProductLookup.TargetName = selectedProductName;

        return null;
    }

    public PageReference pickProductFamily() {
        if (selectedProductFamily != 'All') {
            pickedProductFamily = selectedProductFamily;
        } else {
            pickedProductFamily = '';
        }
        getProductRatePlans();
        showRatePlans = true;
        return null;
    }

    public PageReference pickServiceCategory() {
        if (selectedServiceCategory != 'All') {
            pickedServiceCategory = selectedServiceCategory;
        } else {
            pickedServiceCategory = '';
        }

        getProductRatePlans();
        showRatePlans = true;
        return null;
    }

    public PageReference pickAvailability() {
        if (selectedAvailability != 'All') {
            pickedAvailability = selectedAvailability;
        } else {
            pickedAvailability = '';
        }
        pickedAvailability = selectedAvailability;
        getProductRatePlans();
        showRatePlans = true;
        return null;
    }
    /*
   *  Action to remove a charge group from the quote
   */
    public PageReference removeChargeGroup() {
        System.Debug('selectedChargeGroupId : ' + selectedChargeGroupId);
        System.Debug('chargeGroupHolderMap : ' + existingChargeGroupHolderMap);

        ChargeGroupHolder cgh = existingChargeGroupHolderMap.get(Integer.valueOf(selectedChargeGroupId));
        if (!Test.isRunningTest() && cgh != null) {
            zqu.zQuoteUtil.deleteChargeGroup(cgh.chargeGroup);
        }

        return makeProductSelectorPageRef();
    }
    /*
   *  Action to update the charge group effective price
   */
    public PageReference effectivePriceChange() {

        ChargeGroupHolder cg = null;

        if (isNew == 'false') {
            for (ChargeGroupHolder cgh : existingChargeGroupHolders) {

                if (String.valueOf(cgh.id) == selectedChargeGroupId) {
                    System.Debug('found charge group');
                    cg = cgh;
                    break;
                }
            }
        } else {
            for (ChargeGroupHolder cgh : cghList) {
                if (String.valueOf(cgh.id) == selectedChargeGroupId) {
                    cg = cgh;
                    break;
                }
            }
        }

        if (cg != null) {
            List<chargeWrapper> chargeWrappers = cg.chargeWrappers;
            List<zqu.ZCharge> charges = new List<zqu.ZCharge>();

            for (ChargeWrapper chargeWrapper : chargeWrappers) {
                if (chargeWrapper.zcharge.NAME == selectedChargeName) {

                    Decimal effectivePrice = Decimal.valueOf(chargeWrapper.zcharge.EFFECTIVE_PRICE);
                    Decimal listPrice = Decimal.valueOf(chargeWrapper.listed_Price);
                    Decimal discountDecimal = 0;
                    if (listPrice != 0) {
                        discountDecimal = (listPrice - effectivePrice) / listPrice * 100;
                    }

                    chargeWrapper.calculated_Discount = String.valueOf(discountDecimal.setScale(2));
                    Decimal total = 0;
                    if (chargeWrapper.zcharge.QUANTITY != '-') {
                        total = effectivePrice * Decimal.valueOf(chargeWrapper.zcharge.QUANTITY);
                    } else {
                        total = effectivePrice;
                    }

                    if (!cg.hasBeenUpdated && cg.chargeGroup.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL) {
                        Decimal oldEffecivePrice = (Decimal) chargeWrapper.zcharge.ChargeObject.get('zqu__EffectivePrice__c');
                        chargeWrapper.zcharge.ChargeObject.put('Old_Effective_Price__c', oldEffecivePrice);
                    }

                    chargeWrapper.zcharge.TOTAL = String.valueOf(total.setScale(2));

                    chargeWrapper.zcharge.ChargeObject.put('Calculated_Discount__c', chargeWrapper.calculated_Discount);
                    List<zqu.ZCharge> chargeList = new List<zqu.ZCharge>();
                    chargeList.add(chargeWrapper.zCharge);
                    List<zqu.ZCharge> returnedCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(chargeList);
                    charges.addAll(returnedCharges);
                } else {
                    charges.add(chargeWrapper.zcharge);
                }

            }

            cg.chargeGroup.zCharges = charges;

            System.Debug('selectedChargeGroupId : ' + selectedChargeGroupId);
            System.Debug('charge group holder : ' + chargeGroupHolderMap.get(Integer.valueOf(selectedChargeGroupId)));

            cg.hasBeenUpdated = true;
        }
        return null;
    }

    /*
   *  Action to update the charge group quantity
   */
    public PageReference quantityChange() {
        System.Debug('selectedChargeGroupId : ' + selectedChargeGroupId);
        System.Debug('charge group holder map: ' + existingChargeGroupHolders);
        System.Debug('charge group holder : ' + chargeGroupHolderMap.get(Integer.valueOf(selectedChargeGroupId)));

        ChargeGroupHolder cg = null;

        if (isNew == 'false') {
            for (ChargeGroupHolder cgh : existingChargeGroupHolders) {
                if (cgh.id == Integer.valueOf(selectedChargeGroupId)) {
                    cg = cgh;
                    break;
                }
            }
        } else {
            for (ChargeGroupHolder cgh : cghList) {
                if (cgh.id == Integer.valueOf(selectedChargeGroupId)) {
                    cg = cgh;
                    break;
                }
            }
        }

        if (cg != null) {
            List<chargeWrapper> chargeWrappers = cg.chargeWrappers;
            List<zqu.ZCharge> charges = new List<zqu.ZCharge>();

            for (ChargeWrapper chargeWrapper : chargeWrappers) {
                System.debug('wrapper name: ' + chargeWrapper.zcharge.NAME + ' selected name: ' + selectedChargeName);
                if (chargeWrapper.zcharge.NAME == selectedChargeName) {

                    System.debug('in selected charge');
                    Decimal effectivePrice = Decimal.valueOf(chargeWrapper.zcharge.EFFECTIVE_PRICE);
                    Decimal total = effectivePrice * Decimal.valueOf(chargeWrapper.zcharge.QUANTITY);
                    Decimal listTotal = Decimal.valueOf(chargeWrapper.listed_Price) * Decimal.valueOf(chargeWrapper.zcharge.QUANTITY);
                    chargeWrapper.zcharge.TOTAL = String.valueOf(total.setScale(2));
                    chargeWrapper.zcharge.ChargeObject.put('Listed_Total__c', String.valueOf(listTotal.setScale(2)));
                    chargeWrapper.listed_Total = String.valueOf(listTotal.setScale(2));
                    List<zqu.ZCharge> chargeList = new List<zqu.ZCharge>();
                    chargeList.add(chargeWrapper.zCharge);
                    if (!cg.hasBeenUpdated && cg.chargeGroup.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL) {
                        Decimal oldQuantity = (Decimal) chargeWrapper.zcharge.ChargeObject.get('zqu__Quantity__c');
                        chargeWrapper.zcharge.ChargeObject.put('Old_Quantity__c', oldQuantity);
                    }
                    List<zqu.ZCharge> returnedCharges = zqu.zQuoteUtil.calculateChargesOnQuantityChange(chargeList);
                    charges.addAll(returnedCharges);
                } else {
                    charges.add(chargeWrapper.zcharge);
                }

            }

            cg.chargeGroup.zCharges = charges;

            cg.hasBeenUpdated = true;
        }
        return null;
    }

    public PageReference startDateChange() {
        ChargeGroupHolder cg = null;

        if (isNew == 'false') {
            for (ChargeGroupHolder cgh : existingChargeGroupHolders) {
                if (cgh.id == Integer.valueOf(selectedChargeGroupId)) {
                    cg = cgh;
                    break;
                }
            }
        } else {
            for (ChargeGroupHolder cgh : cghList) {
                if (cgh.id == Integer.valueOf(selectedChargeGroupId)) {
                    cg = cgh;
                    break;
                }
            }
        }

        if (cg != null) {
            List<chargeWrapper> chargeWrappers = cg.chargeWrappers;
            List<zqu.ZCharge> charges = new List<zqu.ZCharge>();

            System.debug('selected name: ' + selectedChargeName);
            for (ChargeWrapper chargeWrapper : chargeWrappers) {
                if (chargeWrapper.zcharge.NAME == selectedChargeName) {
                    if (chargeWrapper.start_Date == null) {
                        chargeWrapper.start_Date = Date.valueOf(chargeWrapper.zcharge.ChargeObject.get('Start_Date__c') + ' 00:00:00');
                        return null;
                    }
                    System.debug('year: ' + chargeWrapper.start_Date.year() + ' month: ' + chargeWrapper.start_Date.month() + ' day: ' + chargeWrapper.start_Date.day());
                    Datetime dateTimeStartDate = datetime.newInstance(chargeWrapper.start_Date.year(), chargeWrapper.start_Date.month(), chargeWrapper.start_Date.day());
                    System.debug('date time: ' + dateTimeStartDate);
                    String formattedDate = dateTimeStartDate.format('yyyy-MM-dd');
                    System.debug('date time formatted: ' + formattedDate);
                    chargeWrapper.zcharge.ChargeObject.put('Start_Date__c', formattedDate);
                    chargeWrapper.zcharge.ChargeObject.put('Start_Date_Display__c', chargeWrapper.start_Date);
                    if (!cg.isServices) {
                        System.debug('setting start date');
                        chargeWrapper.zcharge.ChargeObject.put('zqu__TriggerDate__c', chargeWrapper.start_Date);
                    }
                }
                charges.add(chargeWrapper.zCharge);
            }
            cg.hasBeenUpdated = true;
            //cg.chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnDiscountChange(cg.chargeGroup.zCharges);
            //cg.chargeWrappers = chargeWrappers;
            System.debug('charge wrappers: ' + cg.chargeWrappers);
            cg.chargeGroup.zCharges = charges;
        }
        return null;
    }

    public PageReference specificBillingPeriodChange() {
        ChargeGroupHolder cg = null;
        if (isNew == 'false') {
            for (ChargeGroupHolder cgh : existingChargeGroupHolders) {
                if (cgh.id == Integer.valueOf(selectedChargeGroupId)) {
                    cg = cgh;
                    break;
                }
            }
        } else {
            for (ChargeGroupHolder cgh : cghList) {
                if (cgh.id == Integer.valueOf(selectedChargeGroupId)) {
                    cg = cgh;
                    break;
                }
            }
        }

        if(cg!=null){
            cg.hasBeenUpdated = true;
        }

        return null;
    }

    public Boolean getSpecificBillingPeriodVisibleForUser() {
        return Product_Selector_View_Settings__c.getInstance().Exposed_Specific_Billing_Period__c;
    }

    /*
   *  Action to update the charge group discount
   */
    public PageReference durationChange() {

        ChargeGroupHolder cg = null;

        if (isNew == 'false') {
            for (ChargeGroupHolder cgh : existingChargeGroupHolders) {
                if (cgh.id == Integer.valueOf(selectedChargeGroupId)) {
                    cg = cgh;
                    break;
                }
            }
        } else {
            for (ChargeGroupHolder cgh : cghList) {
                if (cgh.id == Integer.valueOf(selectedChargeGroupId)) {
                    cg = cgh;
                    break;
                }
            }
        }

        if (cg != null) {
            List<chargeWrapper> chargeWrappers = cg.chargeWrappers;
            List<zqu.ZCharge> charges = new List<zqu.ZCharge>();

            System.debug('Duration Change => selected name: ' + selectedChargeName);
            for (ChargeWrapper chargeWrapper : chargeWrappers) {
                if (chargeWrapper.zcharge.NAME == selectedChargeName) {
                    if (chargeWrapper.initial_Term == null || chargeWrapper.initial_Term == '') {
                        chargeWrapper.initial_Term = '1';
                    }
                    chargeWrapper.zcharge.ChargeObject.put('Initial_Term__c', Decimal.valueOf(chargeWrapper.initial_Term));
                    //Decimal listprice = Decimal.valueOf(chargeWrapper.quoteCharge.Initial_Term__c) * Decimal.valueOf(chargeWrapper.quoteCharge.Listed_Price__c);
                    if (chargeWrapper.zcharge.MODEL != 'Flat Fee Pricing') {
                        System.debug('billingperiod: ' + cg.sRatePlan.BillingPeriod__c);
                        if (quote.Payment_Plan__c == 'Prepaid' && cg.sRatePlan.BillingPeriod__c == 'Prepaid') {
                            String serviceCategory = cg.sRatePlan.zqu__Product__r.ProductServiceCategory__c;
                            Decimal multiplier = countryMultiplierSvc.multiplier(serviceCategory, countryMultipliers);
                            Decimal originalListPrice = chargeSvc.calculateListPrice(Decimal.valueOf(chargeWrapper.zcharge.LIST_PRICE), multiplier, conversionRate);
                            Decimal listprice = Decimal.valueOf(chargeWrapper.initial_Term) * originalListPrice;

                            String listPriceString = String.valueOf(listprice.setScale(2));
                            chargeWrapper.zcharge.ChargeObject.put('Listed_Price__c', listPriceString);
                            chargeWrapper.listed_Price = listPriceString;
                            chargeWrapper.zcharge.EFFECTIVE_PRICE = listPriceString;
                            chargeWrapper.zcharge.ChargeObject.put('Calculated_Discount__c', chargeWrapper.calculated_Discount);

                            Decimal total = 0;
                            if (chargeWrapper.zcharge.QUANTITY == '-') {
                                total = listprice;
                            } else {
                                total = listprice * Decimal.valueOf(chargeWrapper.zcharge.QUANTITY);
                            }

                            //Decimal total = listprice*Decimal.valueOf(chargeWrapper.zcharge.QUANTITY);
                            String totalString = String.valueOf(total.setScale(2));
                            chargeWrapper.zcharge.TOTAL = totalString;
                            chargeWrapper.zcharge.ChargeObject.put('Listed_Total__c', totalString);

                            chargeWrapper.listed_Total = totalString;
                            chargeWrapper.zcharge.ChargeObject.put('zqu__SpecificBillingPeriod__c', Decimal.valueOf(chargeWrapper.initial_Term));
                        }

                    }

                    List<zqu.ZCharge> chargeList = new List<zqu.ZCharge>();
                    chargeList.add(chargeWrapper.zCharge);
                    List<zqu.ZCharge> returnedCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(chargeList);

                    //chargeWrapper.quoteCharge = (zqu__QuoteCharge__c) returnedCharges[0].ChargeObject;
                    charges.addAll(returnedCharges);
                    chargeWrapper.zcharge = returnedCharges[0];
                } else {
                    charges.add(chargeWrapper.zcharge);
                }
            }

            cg.hasBeenUpdated = true;
            //cg.chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnDiscountChange(cg.chargeGroup.zCharges);
            cg.chargeWrappers = chargeWrappers;
            System.debug('charge wrappers: ' + cg.chargeWrappers);
            cg.chargeGroup.zCharges = charges;
        }

        return null;
    }

    public PageReference listPriceChange() {

        ChargeGroupHolder cg = null;

        if (isNew == 'false') {
            for (ChargeGroupHolder cgh : existingChargeGroupHolders) {
                if (cgh.id == Integer.valueOf(selectedChargeGroupId)) {
                    cg = cgh;
                    break;
                }
            }
        } else {
            for (ChargeGroupHolder cgh : cghList) {
                if (cgh.id == Integer.valueOf(selectedChargeGroupId)) {
                    cg = cgh;
                    break;
                }
            }
        }

        if (cg != null) {
            List<chargeWrapper> chargeWrappers = cg.chargeWrappers;
            List<zqu.ZCharge> charges = new List<zqu.ZCharge>();

            System.debug('selected name: ' + selectedChargeName);
            for (ChargeWrapper chargeWrapper : chargeWrappers) {
                if (chargeWrapper.zcharge.NAME == selectedChargeName) {
                    //Decimal discountDecimal = Decimal.valueOf(chargeWrapper.quoteCharge.Calculated_Discount__c.removeEnd('%'))/100;

                    Decimal effectivePrice = Decimal.valueOf(chargeWrapper.listed_Price.replace(',', ''));
                    chargeWrapper.zcharge.ChargeObject.put('Listed_Price__c', chargeWrapper.listed_Price);
                    //System.debug('discount: '+discountDecimal+' effectivePrice: '+effectivePrice);
                    chargeWrapper.zcharge.EFFECTIVE_PRICE = String.valueOf(effectivePrice.setScale(2));
                    Decimal total = 0;
                    if (chargeWrapper.zcharge.QUANTITY != '-') {
                        total = effectivePrice * Decimal.valueOf(chargeWrapper.zcharge.QUANTITY);
                        chargeWrapper.zcharge.TOTAL = String.valueOf(total.setScale(2));
                        chargeWrapper.zcharge.ChargeObject.put('Listed_Total__c', String.valueOf(total.setScale(2)));
                        chargeWrapper.listed_Total = String.valueOf(total.setScale(2));
                    } else {
                        total = effectivePrice;
                        chargeWrapper.zcharge.TOTAL = String.valueOf(total.setScale(2));
                        chargeWrapper.zcharge.ChargeObject.put('Listed_Total__c', String.valueOf(total.setScale(2)));
                        chargeWrapper.listed_Total = String.valueOf(total.setScale(2));
                    }

                    chargeWrapper.calculated_Discount = '0';
                    chargeWrapper.zcharge.ChargeObject.put('Calculated_Discount__c', chargeWrapper.calculated_Discount);
                    List<zqu.ZCharge> chargeList = new List<zqu.ZCharge>();
                    chargeList.add(chargeWrapper.zCharge);
                    List<zqu.ZCharge> returnedCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(chargeList);
                    //chargeWrapper.quoteCharge = (zqu__QuoteCharge__c) returnedCharges[0].ChargeObject;
                    charges.addAll(returnedCharges);
                    chargeWrapper.zcharge = returnedCharges[0];
                } else {
                    charges.add(chargeWrapper.zcharge);
                }
            }

            cg.hasBeenUpdated = true;
            //cg.chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnDiscountChange(cg.chargeGroup.zCharges);
            cg.chargeWrappers = chargeWrappers;
            System.debug('charge wrappers: ' + cg.chargeWrappers);
            cg.chargeGroup.zCharges = charges;
        }

        return null;
    }

    public PageReference discountChange() {

        ChargeGroupHolder cg = null;

        System.debug('selectedChargeGroupId: ' + selectedChargeGroupId);
        System.debug(' existing charge group: ' + existingChargeGroupHolders);

        if (isNew == 'false') {
            for (ChargeGroupHolder cgh : existingChargeGroupHolders) {
                System.debug('id: ' + String.valueOf(cgh.id));
                if (String.valueOf(cgh.id) == selectedChargeGroupId) {
                    System.debug('thing found');
                    cg = cgh;
                    break;
                }
            }
        } else {
            for (ChargeGroupHolder cgh : cghList) {
                if (String.valueOf(cgh.id) == selectedChargeGroupId) {
                    cg = cgh;
                    break;
                }
            }
        }

        if (cg != null) {
            List<chargeWrapper> chargeWrappers = cg.chargeWrappers;
            List<zqu.ZCharge> charges = new List<zqu.ZCharge>();

            System.debug('selected name: ' + selectedChargeName);
            for (ChargeWrapper chargeWrapper : chargeWrappers) {
                if (chargeWrapper.zcharge.NAME == selectedChargeName) {

                    if (chargeWrapper.calculated_Discount == null || chargeWrapper.calculated_Discount == '') {
                        Decimal effectivePrice = Decimal.valueOf(chargeWrapper.zcharge.EFFECTIVE_PRICE);
                        Decimal listPrice = Decimal.valueOf(chargeWrapper.listed_Price);
                        Decimal discountDecimal = 0;
                        if (listPrice != 0) {
                            discountDecimal = (listPrice - effectivePrice) / listPrice * 100;
                        }

                        chargeWrapper.calculated_Discount = String.valueOf(discountDecimal.setScale(2));
                    } else {

                        Decimal discountDecimal = Decimal.valueOf(chargeWrapper.calculated_Discount.removeEnd('%')) / 100;
                        Decimal effectivePrice = Decimal.valueOf(chargeWrapper.listed_Price) * (-discountDecimal) + Decimal.valueOf(chargeWrapper.listed_Price);
                        System.debug('discount: ' + discountDecimal + ' effectivePrice: ' + effectivePrice);
                        chargeWrapper.zcharge.EFFECTIVE_PRICE = String.valueOf(effectivePrice.setScale(2));
                        Decimal total = 0;
                        if (chargeWrapper.zcharge.QUANTITY != '-') {
                            total = effectivePrice * Decimal.valueOf(chargeWrapper.zcharge.QUANTITY);
                        } else {
                            total = effectivePrice;
                        }
                        //Decimal total = effectivePrice*Decimal.valueOf(chargeWrapper.zcharge.QUANTITY);
                        chargeWrapper.zcharge.TOTAL = String.valueOf(total.setScale(2));
                        chargeWrapper.zcharge.ChargeObject.put('Calculated_Discount__c', chargeWrapper.calculated_Discount);
                        List<zqu.ZCharge> chargeList = new List<zqu.ZCharge>();
                        chargeList.add(chargeWrapper.zCharge);
                        List<zqu.ZCharge> returnedCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(chargeList);
                        //chargeWrapper.quoteCharge = (zqu__QuoteCharge__c) returnedCharges[0].ChargeObject;
                        charges.addAll(returnedCharges);
                        chargeWrapper.zcharge = returnedCharges[0];
                    }
                } else {
                    charges.add(chargeWrapper.zcharge);
                }
            }

            cg.hasBeenUpdated = true;
            //cg.chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnDiscountChange(cg.chargeGroup.zCharges);
            cg.chargeWrappers = chargeWrappers;
            System.debug('charge wrappers: ' + cg.chargeWrappers);
            cg.chargeGroup.zCharges = charges;
        }

        return null;
    }
    /*
   *  Action to save the charge groups and go to the quote
   */
    public PageReference saveAndClose() {
        save();
        PivLP_Logger.flush();
        return new PageReference('/' + quoteId);
    }
    /*
   * Action to validate the quote, i.e run the rules
   */
    public PageReference validateQuote() {
        System.Debug('Validating Quote');
        List < zqu.zChargeGroup > chargeGroups = new List < zqu.zChargeGroup >();
        for (ChargeGroupHolder cgh : cghList) {
            chargeGroups.add(cgh.chargeGroup);
        }

        return null;
    }
    /*
   * Action to validate the quote and save if its valid
   */
    public PageReference validateAndSaveQuote() {
        System.Debug('Validating and saving Quote');
        List < zqu.zChargeGroup > chargeGroups = new List < zqu.zChargeGroup >();
        for (ChargeGroupHolder cgh : cghList) {
            chargeGroups.add(cgh.chargeGroup);
        }

        return saveAndClose();
    }

    /*
     *  Remove all products
     */
    public PageReference removeAll() {
        List<zqu__QuoteRatePlan__c> ratePlans = [
                SELECT
                        Id
                FROM
                        zqu__QuoteRatePlan__c
                WHERE
                        zqu__Quote__c = :quote.Id
        ];

        try {
            delete ratePlans;

        } catch (DmlException e) {
            ApexPages.addMessages(e);
            return null;
        }

        PageReference pageRef = new PageReference('/apex/ZProductSelector?scontrolCaching=1&id=' + quote.Id);
        pageRef.setRedirect(true);

        return pageRef;
    }

    // ------------------------------------------------------------------------
    // --- Private Methods ---
    // ------------------------------------------------------------------------

    private PageReference makeProductSelectorPageRef() {
        PageReference pr = new PageReference('/apex/ZProductSelector?id=' + quoteId);
        pr.setRedirect(true);
        return pr;
    }

    // Save the chargeGroups - add new ones and update existing ones
    private void save() {

        Date earliestDate = null;
        zqu__Quote__c quoteToUpdate = null;
        if (quote.zqu__SubscriptionType__c == 'New Subscription') {
            //earliestDate = updateQuoteSplitNumbers();
            earliestDate = new PivLP_QuoteSplitManager().updateQuoteSplitNumbers(quote, cghList, existingChargeGroupHolders, conversionRate);
        } else if (quote.zqu__SubscriptionType__c == 'Renew Subscription') {

            quoteToUpdate = amendPreviewCall();


            //System.Debug('Checking TermsAndConditionChanges');
            List<zqu__QuoteAmendment__c> quoteAmendments = [
                    SELECT id, name, zqu__Type__c
                    FROM zqu__QuoteAmendment__c
                    WHERE zqu__Quote__c = :quote.Id
                    AND zqu__Type__c in ('TermsAndConditions', 'Renewal')
            ];

            System.debug('Existing Quote Amendments : ' + quoteAmendments);

            Boolean hasTnC = false;
            Boolean hasRenewal = false;
            for (zqu__QuoteAmendment__c qa : quoteAmendments) {
                if (qa.zqu__Type__c == 'TermsAndConditions') {
                    hasTnC = true;
                } else if (qa.zqu__Type__c == 'Renewal') {
                    hasRenewal = true;
                }
            }

            if (!hasRenewal) {

                System.Debug('Adding Renewal Amendment');
                // Add renew amendment
                if (!Test.isRunningTest()) {
                    zqu.zQuoteUtil.renewQuote(quote);
                }
            }

            if (!hasTnC) {

                System.Debug('T&C Amendment does not exist, checking original subscription.');
                if (quote.zqu__ExistSubscriptionID__c != null) {

                    Zuora__Subscription__c originalSubscription;
                    if (!Test.isRunningTest()) {
                        originalSubscription = [
                                Select Id, Zuora__RenewalTerm__c
                                FROM Zuora__Subscription__c
                                WHERE Zuora__External_Id__c = :quote.zqu__ExistSubscriptionID__c
                                Limit 1
                        ];
                    } else {
                        originalSubscription = new Zuora__Subscription__c();
                        originalSubscription.Zuora__External_Id__c = quote.zqu__ExistSubscriptionID__c;
                        originalSubscription.Zuora__RenewalTerm__c = '12';
                        insert originalSubscription;
                    }

                    System.debug('Original Subcription =' + originalSubscription);
                    // if original subscription.Zuora__RenewalTerm__c is different from quote.zqu__RenewalTerm__c,
                    // add T&C amendment to quote
                    if (Integer.valueOf(originalSubscription.Zuora__RenewalTerm__c.split(' ', 2)[0])
                            != quote.zqu__RenewalTerm__c && quote.zqu__RenewalTerm__c != 0) {

                        System.Debug('Adding TermsAndCondition Amendment: renewal term = ' + quote.zqu__RenewalTerm__c);

                        //Map < String, Object > termsAndConditionChanges = new Map < String, Object > ();
                        //termsAndConditionChanges.put('zqu__RenewalTerm__c', quote.zqu__RenewalTerm__c);

                        // Pass the changes to subscriptionTermsMap to be used when the quote record is upserted
                        // zqu.zQuoteUtil.setSubscriptionTermChanges(new Map<String, Map<String, Object>>{quote.zqu__ExistSubscriptionID__c => termsAndConditionChanges});

                        zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
                        quoteAmendment.Name = quote.name;
                        quoteAmendment.zqu__Quote__c = quote.Id;
                        quoteAmendment.zqu__Type__c = 'TermsAndConditions';
                        quoteAmendment.zqu__RenewalTerm__c = quote.zqu__renewalterm__c;
                        quoteAmendment.zqu__Status__c = 'Draft';
                        quoteAmendment.zqu__Description__c = 'Changed Renewal Term to ' + quote.zqu__RenewalTerm__c;

                        insert quoteAmendment;

                    }
                }
            }

        } else if (quote.zqu__SubscriptionType__c == 'Amend Subscription') {
            quoteToUpdate = amendPreviewCall();
        }

        if (quoteToUpdate != null) {
            quoteToUpdate.zqu__Is_Charge_Expired__c = true;
            update quoteToUpdate;
        }


        addNewCharges();
        updateExistingCharges();

        if (earliestDate != null) {
            updateQuoteServiceActivationDate(earliestDate);
        }
    }

    public void updateQuoteServiceActivationDate(Date newDate) {
        if (quote.zqu__Service_Activation_Date__c != newDate) {
            quote.zqu__StartDate__c = newDate;
            quote.zqu__Service_Activation_Date__c = newDate;
            quote.zqu__Customer_Acceptance_Date__c = newDate;

            update quote;
        }
    }

    public void addNewCharges() {

        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = quoteChargeCustomFields;

        //add the new ones
        if (cghList.size() > 0) {
            List < zqu.zChargeGroup > chargeGroups = new List < zqu.zChargeGroup >();
            List<String> productNames = new List<String>();

            for (ChargeGroupHolder cgh : cghList) {
                productNames.add(cgh.chargeGroup.productName);
            }

            List<zqu__ZProductFeature__c> productFeatures = [
                    SELECT zqu__Product__r.Name, zqu__Product__r.Id, zqu__ZFeature__r.Name, zqu__ZFeature__r.zqu__ZuoraId__c, zqu__ZFeature__r.zqu__Description__c, zqu__ZFeature__r.Id
                    FROM zqu__ZProductFeature__c
                    WHERE zqu__Product__r.Name in :productNames
            ];

            Integer largestTerm = 0;

            for (ChargeGroupHolder cgh : cghList) {
                cgh.chargeGroup.quoteProductFeatures = new List<zqu__QuoteProductFeature__c>();
                for (zqu__ZProductFeature__c prodFeature : productFeatures) {
                    if (cgh.chargeGroup.productName == prodFeature.zqu__Product__r.Name) {
                        System.debug('feature name in add new: ' + prodFeature.zqu__ZFeature__r.Name);
                        zqu__QuoteProductFeature__c newQuoteProductFeature = new zqu__QuoteProductFeature__c();
                        newQuoteProductFeature.zqu__FeatureName__c = prodFeature.zqu__ZFeature__r.Name;
                        newQuoteProductFeature.zqu__FeatureZuoraId__c = prodFeature.zqu__ZFeature__r.zqu__ZuoraId__c;
                        newQuoteProductFeature.zqu__Description__c = prodFeature.zqu__ZFeature__r.zqu__Description__c;
                        newQuoteProductFeature.zqu__ZFeature__c = prodFeature.zqu__ZFeature__r.Id;
                        newQuoteProductFeature.zqu__Quote__c = quote.Id;
                        newQuoteProductFeature.zqu__Product__c = prodFeature.zqu__Product__r.Id;
                        cgh.chargeGroup.quoteProductFeatures.add(newQuoteProductFeature);
                    }
                }
                System.debug('features size: ' + cgh.chargeGroup.quoteProductFeatures.size());

                System.debug('JP: Product_Rate_Plan__c =' + cgh.sRatePlanId);

                for (zqu.zCharge charge : cgh.chargeGroup.zCharges) {
                    Date enddate = (Date)charge.ChargeObject.get('zqu__SpecificEndDate__c');
                    if(charge.SPECIFIC_END_DATE == null && enddate != null) {
                        charge.SPECIFIC_END_DATE = DateTime.newInstance(enddate.year(), enddate.month(), enddate.day()).format('yyyy-MM-dd');
                    }
                    charge.ChargeObject.put('Product_Rate_Plan__c', cgh.sRatePlanId);
                    charge.ChargeObject.put('RATE_USD__c', String.valueOf(conversionRate));
                    charge.ChargeObject.put('Product_Rate_Plan_ZuoraID__c', cgh.chargeGroup.productRateplanZuoraID);
                    System.debug('adding quote split number: ' + charge.ChargeObject.get('Quote_Split_Number__c'));

                    if (cgh.isServices) {
                        charge.ChargeObject.put('Custom_TCV_Formula__c', Decimal.valueOf(charge.TOTAL));
                        charge.ChargeObject.put('TCV_USD__c', String.valueOf((Decimal.valueOf(charge.TOTAL) / conversionRate).setScale(2)));
                    } else {
                        // if it's not service charge

                        // calculate metrics fields and set them
                        Decimal tcvValue = 0.00;
                        Decimal acvValue = 0.00;
                        Integer numberOfMonth = 0;
                        if (quote.zqu__SubscriptionType__c == 'New Subscription') {

                            numberOfMonth = Integer.valueOf(charge.ChargeObject.get('Initial_Term__c'));

                            if (charge.CHARGE_TYPE == 'Recurring') {
                                Decimal effectivePrice = Decimal.valueOf(charge.EFFECTIVE_PRICE);
                                Integer quantity = 1;
                                if (charge.ChargeObject.get('zqu__FeeType__c') == 'Per Unit') {
                                    quantity = Integer.valueOf(charge.ChargeObject.get('zqu__Quantity__c'));
                                }
                                if (quote.Payment_Plan__c == 'Annual') {
                                    tcvValue = numberOfMonth / 12.00 * effectivePrice * quantity;
                                }
                                if (quote.Payment_Plan__c == 'Monthly') {
                                    tcvValue = numberOfMonth * effectivePrice * quantity;
                                }
                                if (quote.Payment_Plan__c == 'Quarterly') {
                                    tcvValue = numberOfMonth / 3.00 * effectivePrice * quantity;
                                }
                                if (quote.Payment_Plan__c == 'Semi-Annual') {
                                    tcvValue = numberOfMonth / 6.00 * effectivePrice * quantity;
                                }

                            } else {


                                if (charge.ChargeObject.get('zqu__PreviewedTCV__c') != null) {
                                    tcvValue = (Decimal) charge.ChargeObject.get('zqu__PreviewedTCV__c');
                                }
                            }

                            // calculate acvValue
                            acvValue = tcvValue / numberOfMonth * 12.00;

                        } else {
                            if (charge.ChargeObject.get('zqu__PreviewedTCV__c') != null) {
                                tcvValue = (Decimal) charge.ChargeObject.get('zqu__PreviewedTCV__c');
                            }

                            if (quote.zqu__SubscriptionType__c == 'Renew Subscription') {
                                numberOfMonth = Integer.valueOf(quote.zqu__RenewalTerm__c);
                                acvValue = tcvValue;
                                if (numberOfMonth > 12) {
                                    acvValue = tcvValue / numberOfMonth * 12.00;
                                }
                            } else if (quote.zqu__SubscriptionType__c == 'Amend Subscription') {
                                //TODO figure out how to prorate the amend subscriptions
                                System.debug('start date: ' + quote.zqu__StartDate__c + ' end date: ' + quote.zqu__SubscriptionTermEndDate__c);
                                numberOfMonth = quote.zqu__StartDate__c.monthsBetween(quote.zqu__SubscriptionTermEndDate__c);
                                System.debug('num of months: ' + numberOfMonth);
                                Integer daysinMonth = Date.daysinMonth(quote.zqu__StartDate__c.addMonths(numberOfMonth).year(), quote.zqu__StartDate__c.addMonths(numberOfMonth).month());
                                Integer remainingDays = quote.zqu__StartDate__c.addMonths(numberOfMonth).daysBetween(quote.zqu__SubscriptionTermEndDate__c);
                                Decimal daysFraction = remainingDays * 1.00 / daysinMonth;
                                System.debug('remainingDays: ' + remainingDays);
                                System.debug('daysinMonth: ' + daysinMonth);
                                System.debug('daysFraction: ' + daysFraction);
                                acvValue = tcvValue / (numberOfMonth + daysFraction) * 12.00;
                            }
                        }


                        charge.ChargeObject.put('Custom_TCV_Formula__c', Decimal.valueOf(charge.TOTAL));

                        charge.ChargeObject.put('TCV_USD__c', String.valueOf((Decimal.valueOf(charge.TOTAL) / conversionRate).setScale(2)));

                        if (charge.ChargeObject.get('zqu__PreviewedMRR__c') != null) {
                            Decimal previewmrr = (Decimal) charge.ChargeObject.get('zqu__PreviewedMRR__c');
                            Decimal mrrusd = previewmrr / conversionRate;
                            Decimal arrusd = mrrusd * 12;
                            charge.ChargeObject.put('MRR_USD__c', String.valueOf(mrrusd.setScale(2)));
                            charge.ChargeObject.put('ARR_USD__c', String.valueOf(arrusd.setScale(2)));
                        }

                        if (charge.ChargeObject.get('Product_Category__c') == 'Services' ||
                                charge.ChargeObject.get('Billing_Period__c') == '' ||
                                charge.ChargeObject.get('Billing_Period__c') == null) {

                            charge.ChargeObject.put('ACV_USD__c', charge.ChargeObject.get('TCV_USD__c'));
                        } else {
                            charge.ChargeObject.put('ACV_USD__c', String.valueOf((acvValue / conversionRate).setScale(2)));
                        }

                        System.debug('Metrics field on QuoteRateplanCharge :' +
                                '\nTCV_USD__c = ' + charge.ChargeObject.get('TCV_USD__c') +
                                '\nACV_USD__c = ' + charge.ChargeObject.get('ACV_USD__c') +
                                '\nMRR_USD__c = ' + charge.ChargeObject.get('MRR_USD__c') +
                                '\nARR_USD__c = ' + charge.ChargeObject.get('ARR_USD__c') +
                                '\nRATE_USD__c = ' + charge.ChargeObject.get('RATE_USD__c') +
                                '\nCountry_Uplift__c = ' + charge.ChargeObject.get('Country_Uplift__c')
                        );
                        System.debug('listed price when saving: ' + charge.ChargeObject.get('Listed_Price__c'));
                    }
                }
                chargeGroups.add(cgh.chargeGroup);
            }
            //add the custom fields from the product rate plan to the quote charge in order
            //to facilate the removing and loading of associated rate plans

            System.debug('chargegroup size: ' + chargeGroups.size());
            zqu.zQuoteUtil.addChargeGroups(chargeGroups);
        }
    }

    private void updateExistingCharges() {
        //update the existing charges
        if (existingChargeGroupHolders.size() > 0) {

            List<String> productNames = new List<String>();

            for (ChargeGroupHolder cgh : existingChargeGroupHolders) {
                productNames.add(cgh.chargeGroup.productName);
            }

            List<zqu__ZProductFeature__c> productFeatures = [
                    SELECT zqu__Product__r.Name, zqu__Product__r.Id, zqu__ZFeature__r.Name, zqu__ZFeature__r.zqu__ZuoraId__c, zqu__ZFeature__r.zqu__Description__c, zqu__ZFeature__r.Id
                    FROM zqu__ZProductFeature__c
                    WHERE zqu__Product__r.Name in :productNames
            ];

            zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = quoteChargeCustomFields;
            //make sure it has been updated

            List<zqu.zChargeGroup> updatedExistingChargeGroupsList = new List<zqu.zChargeGroup>();
            for (ChargeGroupHolder cg : existingChargeGroupHolders) {
                for (zqu__ZProductFeature__c prodFeature : productFeatures) {
                    if (cg.chargeGroup.productName == prodFeature.zqu__Product__r.Name) {
                        System.debug('feature name in existing: ' + prodFeature.zqu__ZFeature__r.Name);
                        zqu__QuoteProductFeature__c newQuoteProductFeature = new zqu__QuoteProductFeature__c();
                        newQuoteProductFeature.zqu__FeatureName__c = prodFeature.zqu__ZFeature__r.Name;
                        newQuoteProductFeature.zqu__FeatureZuoraId__c = prodFeature.zqu__ZFeature__r.zqu__ZuoraId__c;
                        newQuoteProductFeature.zqu__Description__c = prodFeature.zqu__ZFeature__r.zqu__Description__c;
                        newQuoteProductFeature.zqu__ZFeature__c = prodFeature.zqu__ZFeature__r.Id;
                        newQuoteProductFeature.zqu__Product__c = prodFeature.zqu__Product__r.Id;
                        newQuoteProductFeature.zqu__Quote__c = quote.Id;
                        //cg.chargeGroup.quoteProductFeatures.add(newQuoteProductFeature);
                    }
                }


                for (zqu.zCharge charge : cg.chargeGroup.zCharges) {
                    charge.ChargeObject.put('RATE_USD__c', String.valueOf(conversionRate));
                    //charge.ChargeObject.put('Product_Rate_Plan_ZuoraID__c', cg.chargeGroup.productRateplanZuoraID);
                    System.debug('updating prp id: ' + cg.chargeGroup.productRateplanZuoraID);
                    System.debug('updating quote split number: ' + charge.ChargeObject.get('quote_split_number__c'));

                    if (cg.isServices) {
                        charge.ChargeObject.put('Custom_TCV_Formula__c', Decimal.valueOf(charge.TOTAL));
                        charge.ChargeObject.put('TCV_USD__c', String.valueOf((Decimal.valueOf(charge.TOTAL) / conversionRate).setScale(2)));
                    } else {
                        // if it's not service charge

                        // calculate metrics fields and set them
                        Decimal tcvValue = 0;
                        Decimal acvValue = 0;
                        Integer numberOfMonth = 0;
                        if (quote.zqu__SubscriptionType__c == 'New Subscription') {
                            numberOfMonth = Integer.valueOf(charge.ChargeObject.get('Initial_Term__c'));

                            if (charge.CHARGE_TYPE == 'Recurring') {
                                Decimal effectivePrice = Decimal.valueOf(charge.EFFECTIVE_PRICE);
                                Integer quantity = 1;
                                if (charge.ChargeObject.get('zqu__FeeType__c') == 'Per Unit') {
                                    quantity = Integer.valueOf(charge.ChargeObject.get('zqu__Quantity__c'));
                                }
                                if (quote.Payment_Plan__c == 'Annual') {
                                    tcvValue = numberOfMonth / 12.00 * effectivePrice * quantity;

                                    System.debug('Updating existing charges for New Subscription');
                                    System.debug('charge.Initial_Term__c = ' + numberOfMonth);
                                    System.debug('charge.CHARGE_TYPE = ' + charge.CHARGE_TYPE);
                                    System.debug('quote.Payment_Plan__c = ' + quote.Payment_Plan__c);
                                    System.debug('quantity = ' + quantity);
                                    System.debug('effective price = ' + effectivePrice);
                                    System.debug('Previewed TCV = ' + charge.ChargeObject.get('zqu__PreviewedTCV__c'));
                                    System.debug('number of month / 12 = ' + numberOfMonth / 12.00);
                                    System.debug('effectivePrice * quantity = ' + effectivePrice * quantity);
                                    System.debug('TCV Value = ' + tcvValue);
                                }
                                if (quote.Payment_Plan__c == 'Monthly') {
                                    tcvValue = numberOfMonth * effectivePrice * quantity;
                                }
                                if (quote.Payment_Plan__c == 'Quarterly') {
                                    tcvValue = numberOfMonth / 3.00 * effectivePrice * quantity;
                                }
                                if (quote.Payment_Plan__c == 'Semi-Annual') {
                                    tcvValue = numberOfMonth / 6.00 * effectivePrice * quantity;
                                }

                            } else {
                                if (charge.ChargeObject.get('zqu__PreviewedTCV__c') != null) {
                                    tcvValue = (Decimal) charge.ChargeObject.get('zqu__PreviewedTCV__c');
                                }
                            }

                            // calculate acvValue
                            acvValue = tcvValue / numberOfMonth * 12.00;

                        } else {
                            if (charge.ChargeObject.get('zqu__PreviewedTCV__c') != null) {
                                tcvValue = (Decimal) charge.ChargeObject.get('zqu__PreviewedTCV__c');
                            }

                            if (quote.zqu__SubscriptionType__c == 'Renew Subscription') {
                                numberOfMonth = Integer.valueOf(quote.zqu__RenewalTerm__c);
                                acvValue = tcvValue;
                                if (numberOfMonth > 12) {
                                    acvValue = tcvValue / numberOfMonth * 12.00;
                                }
                            } else if (quote.zqu__SubscriptionType__c == 'Amend Subscription') {
                                //TODO figure out how to prorate the amend subscriptions
                                System.debug('start date: ' + quote.zqu__StartDate__c + ' end date: ' + quote.zqu__SubscriptionTermEndDate__c);
                                numberOfMonth = quote.zqu__StartDate__c.monthsBetween(quote.zqu__SubscriptionTermEndDate__c);
                                System.debug('num of months: ' + numberOfMonth);
                                Integer daysinMonth = Date.daysinMonth(quote.zqu__StartDate__c.addMonths(numberOfMonth).year(), quote.zqu__StartDate__c.addMonths(numberOfMonth).month());
                                Integer remainingDays = quote.zqu__StartDate__c.addMonths(numberOfMonth).daysBetween(quote.zqu__SubscriptionTermEndDate__c);
                                Decimal daysFraction = remainingDays / daysinMonth;
                                System.debug('remainingDays: ' + remainingDays);
                                System.debug('daysinMonth: ' + daysinMonth);
                                System.debug('daysFraction: ' + daysFraction);
                                acvValue = tcvValue / (numberOfMonth + daysFraction) * 12.00;
                            }
                        }


                        charge.ChargeObject.put('Custom_TCV_Formula__c', tcvValue);

                        charge.ChargeObject.put('TCV_USD__c', String.valueOf((tcvValue / conversionRate).setScale(2)));

                        if (charge.ChargeObject.get('zqu__PreviewedMRR__c') != null) {
                            Decimal previewmrr = (Decimal) charge.ChargeObject.get('zqu__PreviewedMRR__c');
                            Decimal mrrusd = previewmrr / conversionRate;
                            Decimal arrusd = mrrusd * 12;
                            charge.ChargeObject.put('MRR_USD__c', String.valueOf(mrrusd.setScale(2)));
                            charge.ChargeObject.put('ARR_USD__c', String.valueOf(arrusd.setScale(2)));
                        }

                        if (charge.ChargeObject.get('Product_Category__c') == 'Services' ||
                                charge.ChargeObject.get('Billing_Period__c') == '' ||
                                charge.ChargeObject.get('Billing_Period__c') == null) {
                            //charge.ChargeObject.put('ACV_USD__c',String.valueOf((acvValue/conversionRate).setScale(2)));
                            charge.ChargeObject.put('ACV_USD__c', charge.ChargeObject.get('TCV_USD__c'));
                        } else {
                            charge.ChargeObject.put('ACV_USD__c', String.valueOf((acvValue / conversionRate).setScale(2)));
                        }
                    }
                    System.debug('Metrics field on QuoteRateplanCharge :' +
                            '\nCustom_TCV_Formula__c = ' + charge.ChargeObject.get('Custom_TCV_Formula__c') +
                            '\nTCV_USD__c = ' + charge.ChargeObject.get('TCV_USD__c') +
                            '\nACV_USD__c = ' + charge.ChargeObject.get('ACV_USD__c') +
                            '\nMRR_USD__c = ' + charge.ChargeObject.get('MRR_USD__c') +
                            '\nARR_USD__c = ' + charge.ChargeObject.get('ARR_USD__c') +
                            '\nRATE_USD__c = ' + charge.ChargeObject.get('RATE_USD__c') +
                            '\nCountry_Uplift__c = ' + charge.ChargeObject.get('Country_Uplift__c')
                    );
                    System.debug('ROLLUP TYPE: ' + charge.ChargeObject.get('Rollup_Type__c'));
                }

                if (cg.hasBeenUpdated) {
                    updatedExistingChargeGroupsList.add(cg.chargeGroup);
                }
            }

            // Call this one out side of the loop, so that it gets called once at the end
            if (updatedExistingChargeGroupsList.size() > 0 && !Test.isRunningTest()) {
                System.debug('------------TEST-SAVE-------');
                System.debug(updatedExistingChargeGroupsList);
                zqu.zQuoteUtil.updateChargeGroups(updatedExistingChargeGroupsList);
            }
        }
    }

    /*
    public Date updateQuoteSplitNumbers() {
        Map<Date, Integer> quoteSplitMap = new Map<Date, Integer>();
        //Map<String, List<zqu.zCharge>> subscriptionMap = new Map<String, List<zqu.zCharge>>();
        Map<String, List<zqu.zChargeGroup>> subscriptionMap = new Map<String, List<zqu.zChargeGroup>>();
        Map<String, String> chargeToRatePlanMap = new Map<String, String>();
        Integer increment = 1;
        Integer largestTerm = 0;
        Date earliestDate = null;


        // New charges
        for (ChargeGroupHolder cg : cghList) {
            cg.hasBeenUpdated = true;

            for (zqu.ZCharge charge : cg.chargeGroup.zCharges) {

                chargeToRatePlanMap.put(charge.PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID, cg.chargeGroup.productRateplanZuoraID);
                if (Integer.valueOf(charge.ChargeObject.get('Initial_Term__c')) > largestTerm) {
                    largestTerm = Integer.valueOf(charge.ChargeObject.get('Initial_Term__c'));
                }

                if (cg.isServices) {

                    charge.ChargeObject.put('PSAmount__c', Decimal.valueOf(charge.TOTAL));
                    System.debug('PS-REDESIGN : PS Amount = ' + charge.ChargeObject.get('PSAmount__c'));

                    // If it is PS charges,
                    // TCV_USD__c = PSAmount__c (GBP) / rate(0.65);
                    // MRR, ARR, ACV = 0 for PS charges
                    charge.ChargeObject.put('TCV_USD__c', String.valueOf((Decimal.valueOf(charge.TOTAL) / conversionRate).setScale(2)));


                    // Each "Services" rateplans should have unique Quote_Split_Number__c,
                    // so that each PS rateplan will be a separate subscription.
                    String subscriptionKey = 'Services-' + cg.sRatePlanId + charge.ChargeObject.get('Start_Date__c');
                    charge.ChargeObject.put('Quote_Split_Number__c', subscriptionKey);
                    //refactor subscirptionmap into map of chargegroups
                    if (!subscriptionMap.containsKey(subscriptionKey)) {
                        List<zqu.zChargeGroup> chargeList = new List<zqu.zChargeGroup>();
                        chargeList.add(cg.chargeGroup);
                        subscriptionMap.put(subscriptionKey, chargeList);
                    }
                }
                // end of PS charges
                else {
                    if (earliestDate == null) {
                        // set the earliest date to the start date of first charge
                        earliestDate = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00');
                    }

                    if (earliestDate > Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00')) {
                        earliestDate = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00');
                    }
                    Date enddate = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00').addMonths(Integer.valueOf(charge.ChargeObject.get('Initial_Term__c')));
                    Datetime dt = datetime.newInstance(enddate.year(), enddate.month(), enddate.day());
                    System.debug('end date display: ' + dt.format('yyyy-MM-dd'));
                    System.debug('end date: ' + enddate);
                    System.debug('in split, charge: ' + charge);
                    //refactor subscirptionmap into map of chargegroups
                    if (quoteSplitMap.containsKey(enddate)) {
                        String splitNumber = String.valueOf(quoteSplitMap.get(enddate));
                        charge.ChargeObject.put('Quote_Split_Number__c', splitNumber);
                        subscriptionMap.get(splitNumber).add(cg.chargeGroup);
                        System.debug('put charge in split number:' + quoteSplitMap.get(enddate));
                    } else {
                        quoteSplitMap.put(enddate, increment);
                        charge.ChargeObject.put('Quote_Split_Number__c', String.valueOf(increment));

                        List<zqu.zChargeGroup> chargeList = new List<zqu.zChargeGroup>();
                        chargeList.add(cg.chargeGroup);
                        subscriptionMap.put(String.valueOf(increment), chargeList);

                        System.debug('put charge in new split number:' + increment + ' number: ' + charge.ChargeObject.get('Quote_Split_Number__c'));
                    }
                    System.debug('Start_Date__c = ' + charge.ChargeObject.get('Start_Date__c'));
                    charge.ChargeObject.put('End_Date__c', dt.format('yyyy-MM-dd'));
                    charge.ChargeObject.put('End_Date_Display__c', enddate);
                }

                increment++;

            }
        }
        System.debug('quote split map: ' + quoteSplitMap);


        for (ChargeGroupHolder cg : existingChargeGroupHolders) {
            cg.hasBeenUpdated = true;
            for (zqu.ZCharge charge : cg.chargeGroup.zCharges) {
                System.debug('prp id: ' + cg.chargeGroup.productRateplanZuoraID);
                chargeToRatePlanMap.put(charge.PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID, String.valueOf(charge.ChargeObject.get('Product_Rate_Plan_ZuoraID__c')));
                if (Integer.valueOf(charge.ChargeObject.get('Initial_Term__c')) > largestTerm) {
                    largestTerm = Integer.valueOf(charge.ChargeObject.get('Initial_Term__c'));
                }


                if (cg.isServices) {

                    charge.ChargeObject.put('PSAmount__c', Decimal.valueOf(charge.TOTAL));
                    System.debug('PS-REDESIGN : PS Amount = ' + charge.ChargeObject.get('PSAmount__c'));


                    // If it is PS charges,
                    // TCV_USD__c = PSAmount__c (GBP) / rate(0.65); (test and confirm if )
                    // MRR, ARR, ACV = 0 for PS charges
                    charge.ChargeObject.put('TCV_USD__c', String.valueOf((Decimal.valueOf(charge.TOTAL) / conversionRate).setScale(2)));

                    // Each "Services" rateplans should have unique Quote_Split_Number__c,
                    // so that each PS rateplan will be a separate subscription.
                    String subscriptionKey = 'Services-' + cg.sRatePlanId + charge.ChargeObject.get('Start_Date__c');
                    charge.ChargeObject.put('Quote_Split_Number__c', subscriptionKey);
                    //refactor subscirptionmap into map of chargegroups
                    if (!subscriptionMap.containsKey(subscriptionKey)) {
                        List<zqu.zChargeGroup> chargeList = new List<zqu.zChargeGroup>();
                        chargeList.add(cg.chargeGroup);
                        subscriptionMap.put(subscriptionKey, chargeList);
                    }

                } else {
                    if (earliestDate > Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00')) {
                        earliestDate = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00');
                    }
                    System.debug('Initial Term: ' + charge.ChargeObject.get('Initial_Term__c'));
                    //Date enddate = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00').addMonths(Integer.valueOf(charge.ChargeObject.get('Initial_Term__c')));
                    //9/25/2018 change enddate to same date so all in same split
                    Date enddate = Date.today().addMonths(Integer.valueOf(charge.ChargeObject.get('Initial_Term__c')));
                    Datetime dt = datetime.newInstance(enddate.year(), enddate.month(), enddate.day());
                    //refactor subscirptionmap into map of chargegroups
                    if (quoteSplitMap.containsKey(enddate)) {
                        String splitNumber = String.valueOf(quoteSplitMap.get(enddate));
                        charge.ChargeObject.put('Quote_Split_Number__c', splitNumber);

                        subscriptionMap.get(splitNumber).add(cg.chargeGroup);
                        System.debug('put charge in split number:' + quoteSplitMap.get(enddate));
                    } else {
                        quoteSplitMap.put(enddate, increment);
                        charge.ChargeObject.put('Quote_Split_Number__c', String.valueOf(increment));

                        List<zqu.zChargeGroup> chargeList = new List<zqu.zChargeGroup>();
                        chargeList.add(cg.chargeGroup);
                        subscriptionMap.put(String.valueOf(increment), chargeList);

                        System.debug('put charge in new split number:' + increment + ' number: ' + charge.ChargeObject.get('Quote_Split_Number__c'));

                    }
                    System.debug('Start_Date__c = ' + charge.ChargeObject.get('Start_Date__c'));
                    System.debug('end date display: ' + dt.format('yyyy-MM-dd'));
                    System.debug('end date: ' + enddate);
                    charge.ChargeObject.put('End_Date__c', dt.format('yyyy-MM-dd'));
                    charge.ChargeObject.put('End_Date_Display__c', enddate);
                }

                increment++;
            }

        }
        System.debug('quote split map: ' + quoteSplitMap);
        System.debug('subscription map: ' + subscriptionMap);
        zqu__Quote__c quoteToUpdate = new zqu__Quote__c();
        quoteToUpdate.Id = quote.Id;


        quoteToUpdate.zqu__InitialTerm__c = largestTerm;

        Decimal tcv = 0;
        Decimal mrr = 0;
        Decimal subtotal = 0;
        Decimal tax = 0;
        Decimal total = 0;

        // update quote with quote metrics values
        for (String key : subscriptionMap.keySet()) {
            //create subscription
            List<zqu.zChargeGroup> chargeList = subscriptionMap.get(key);
            System.debug('chargeToRatePlanMap: ' + chargeToRatePlanMap);
            Map<String, Decimal> results = subscribePreviewCall(chargeList, chargeToRatePlanMap, quote);
            if (results.get('TCV') != null && results.get('MRR') != null) {
                tcv = results.get('TCV') + tcv;
                mrr = results.get('MRR') + mrr;
                subtotal = results.get('subtotal') + subtotal;
                tax = results.get('tax') + tax;
                total = subtotal + tax;
            } else {
                tcv = null;
                mrr = null;
                break;
            }
        }

        if (tcv != null && mrr != null) {
            quoteToUpdate.Calculated_Total_TCV__c = String.valueOf(tcv.setScale(2));
            quoteToUpdate.Calculated_Total_MRR__c = String.valueOf(mrr.setScale(2));
            quoteToUpdate.Calculated_SubTotal__c = String.valueOf(subtotal.setScale(2));
            quoteToUpdate.Calculated_Tax__c = String.valueOf(tax.setScale(2));
            quoteToUpdate.Calculated_Total__c = String.valueOf(total.setScale(2));
        } else {
            quoteToUpdate.Calculated_Total_TCV__c = 'Error in Calculating Metrics';
            quoteToUpdate.Calculated_Total_MRR__c = 'Error in Calculating Metrics';
            quoteToUpdate.Calculated_SubTotal__c = 'Error in Calculating Metrics';
            quoteToUpdate.Calculated_Tax__c = 'Error in Calculating Metrics';
            quoteToUpdate.Calculated_Total__c = 'Error in Calculating Metrics';
        }

        update quoteToUpdate;

        return earliestDate;
    }*/

    public zqu__Quote__c amendPreviewCall() {
        zqu__Quote__c quoteToUpdate = null;
        List<zqu__QuoteAmendment__c> quoteAmendmentsAfter = [
                SELECT id, name, zqu__Type__c, zqu__RenewalTerm__c
                FROM zqu__QuoteAmendment__c
                WHERE zqu__Quote__c = :quote.Id
                AND zqu__Type__c in ('TermsAndConditions', 'Renewal')
        ];

        List<ChargeGroupHolder> chargeGroupholders = new List<ChargeGroupHolder>();
        for (ChargeGroupHolder cg : existingChargeGroupHolders) {
            chargeGroupholders.add(cg);
        }
        for (ChargeGroupHolder cg : cghList) {
            chargeGroupholders.add(cg);
        }
        System.debug('charge holder size: ' + chargeGroupholders.size());
        if (chargeGroupholders.size() > 0) {
            Decimal terms = 0;
            Decimal renewalTerms = 0;

            for (zqu__QuoteAmendment__c qa : quoteAmendmentsAfter) {
                if (qa.zqu__Type__c == 'TermsAndConditions') {
                    renewalTerms = qa.zqu__RenewalTerm__c;
                } else {
                    renewalTerms = quote.zqu__RenewalTerm__c;
                }

            }
            terms = quote.zqu__InitialTerm__c + renewalTerms;
            Date subscriptionStartDate = quote.zqu__SubscriptionTermStartDate__c;
            if (quote.zqu__SubscriptionType__c == 'Renew Subscription' && quote.zqu__StartDate__c >= quote.zqu__SubscriptionTermEndDate__c) {
                subscriptionStartDate = quote.zqu__SubscriptionTermEndDate__c;
            }
            Date chargeStartdate = quote.zqu__StartDate__c;

            Zuora.zObject acc = new Zuora.zObject('Account');
            acc.setValue('Id', quote.zqu__ZuoraAccountID__c);

            Set<String> prpcSet = new Set<String>();
            List<Zuora.zObject> rpdList = new List<Zuora.ZObject>();
            for (ChargeGroupHolder chargeGroupholder : chargeGroupholders) {
                System.debug('group type: ' + chargeGroupholder.chargeGroup.groupType);
                if (chargeGroupholder.chargeGroup.groupType == zqu.zChargeGroup.TYPE_RENEWAL_NEWPRODUCT ||
                        chargeGroupholder.chargeGroup.groupType == zqu.zChargeGroup.TYPE_RENEWAL_UPDATEPRODUCT ||
                        chargeGroupholder.chargeGroup.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_NEWPRODUCT ||
                        chargeGroupholder.chargeGroup.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT ||
                        chargeGroupholder.chargeGroup.groupType == zqu.zChargeGroup.TYPE_RENEWAL_RENEWED ||
                        chargeGroupholder.chargeGroup.groupType == zqu.zChargeGroup.TYPE_PRODUCT_NEW ||
                        chargeGroupholder.chargeGroup.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_ORIGINAL ||
                        chargeGroupholder.chargeGroup.groupType == zqu.zChargeGroup.TYPE_RENEWAL_RENEWED) {

                    Zuora.zObject rpd = new Zuora.zObject('RatePlanData');
                    Zuora.zObject rp = new Zuora.zObject('RatePlan');
                    rp.setValue('ProductRatePlanId', chargeGroupholder.chargeGroup.productRateplanZuoraID);
                    List<Zuora.zObject> rpcds = new List<Zuora.zObject>();
                    Boolean chargeAvailable = false;
                    for (ChargeWrapper cWrapper : chargeGroupholder.chargeWrappers) {
                        Decimal chargeQuantity = (Decimal) cWrapper.zcharge.ChargeObject.get('Old_Quantity__c');
                        Decimal oldEffectivePrice = (Decimal) cWrapper.zcharge.ChargeObject.get('Old_Effective_Price__c');
                        Zuora.zObject rpc = new Zuora.zObject('RatePlanCharge');
                        rpc.setValue('ProductRatePlanChargeId', cWrapper.zcharge.PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID);
                        prpcSet.add(cWrapper.zcharge.PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID);
                        if (cWrapper.zcharge.isEffectivePriceEditable) {
                            rpc.setValue('Price', cWrapper.zcharge.EFFECTIVE_PRICE);
                            chargeAvailable = true;
                        }
                        if (cWrapper.zcharge.isQuantityEditable) {
                            rpc.setValue('Quantity', cWrapper.zcharge.QUANTITY);
                            chargeAvailable = true;
                        }
                        if (!chargeAvailable) {
                            continue;
                        }
                        if (chargeGroupholder.chargeGroup.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_ORIGINAL ||
                                chargeGroupholder.chargeGroup.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT) {
                            Boolean chargeSet = false;
                            System.debug('QUANTITY: ' + cWrapper.zcharge.QUANTITY + ' quantity: ' + cWrapper.zcharge.ChargeObject.get('zqu__Quantity__c') + ' old quantity: ' + cWrapper.zcharge.ChargeObject.get('Old_Quantity__c'));
                            if (cWrapper.zcharge.isQuantityEditable) {
                                if (Decimal.valueOf(cWrapper.zcharge.QUANTITY) > chargeQuantity) {
                                    rpc.setValue('Quantity', Decimal.valueOf(cWrapper.zcharge.QUANTITY) - chargeQuantity);
                                    chargeSet = true;
                                    chargeAvailable = true;
                                }
                                if (Test.isRunningTest()) {
                                    cWrapper.zcharge.EFFECTIVE_PRICE = '100.00';
                                }
                                if (Decimal.valueOf(cWrapper.zcharge.EFFECTIVE_PRICE) > oldEffectivePrice) {
                                    rpc.setValue('Price', Decimal.valueOf(cWrapper.zcharge.EFFECTIVE_PRICE) - oldEffectivePrice);
                                    if (!chargeSet) {
                                        rpc.setValue('Quantity', Decimal.valueOf(cWrapper.zcharge.QUANTITY));
                                    }
                                    chargeAvailable = true;
                                } else {
                                    continue;
                                }
                            }
                        }
                        if (cWrapper.zcharge.CHARGE_TYPE == 'Recurring') {
                            //Date startDate = Date.valueOf(charge.ChargeObject.get('Start_Date__c')+' 00:00:00');
                            Datetime startDateTime = datetime.newInstance(chargeStartdate.year(), chargeStartdate.month(), chargeStartdate.day());
                            rpc.setValue('TriggerEvent', 'SpecificDate');
                            //rpc.setValue('TriggerDate', startDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss'));
                            if (chargeGroupholder.chargeGroup.groupType == zqu.zChargeGroup.TYPE_RENEWAL_RENEWED && Decimal.valueOf(cWrapper.zcharge.QUANTITY) == cWrapper.oldQuantity) {
                                startDateTime = datetime.newInstance(quote.zqu__SubscriptionTermEndDate__c.year(), quote.zqu__SubscriptionTermEndDate__c.month(), quote.zqu__SubscriptionTermEndDate__c.day());
                            }
                            rpc.setValue('TriggerDate', startDateTime.formatGmt('yyyy-MM-dd'));
                        }
                        Zuora.zObject rpcd = new Zuora.zObject('RatePlanChargeData');
                        rpcd.setValue('RatePlanCharge', rpc);
                        rpcds.add(rpcd);

                    }
                    if (chargeAvailable) {
                        rpd.setValue('RatePlan', rp);
                        rpd.setValue('RatePlanChargeData', rpcds);
                        rpdList.add(rpd);
                    }
                }
            }

            Datetime dt = datetime.newInstance(subscriptionStartDate.year(), subscriptionStartDate.month(), subscriptionStartDate.day());
            //String effectiveDate = dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
            String effectiveDate = dt.formatGmt('yyyy-MM-dd');

            //subscription
            Zuora.zObject sub = new Zuora.zObject('Subscription');
            sub.setValue('Name', 'subscription - SubscriptionName');
            sub.setValue('ContractEffectiveDate', effectiveDate);
            sub.setValue('ServiceActivationDate', effectiveDate);
            sub.setValue('InitialTerm', terms);
            sub.setValue('RenewalTerm', 12);

            Zuora.zApi.SubscriptionData sd = new Zuora.zApi.SubscriptionData();
            sd.Subscription = sub;
            sd.RatePlanData = rpdList;

            // there is no rateplan data, subscribe call cannot be made.
            if (rpdList.size() == 0) {
                quoteToUpdate = new zqu__Quote__c();
                quoteToUpdate.Id = quote.Id;
                quoteToUpdate.Calculated_SubTotal__c = '0.00';
                quoteToUpdate.Calculated_Tax__c = '0.00';
                return quoteToUpdate;
            }

            Date todayDate = Date.today();
            Datetime invoiceDate = DateTime.newInstance(todayDate.year(), todayDate.month(), todayDate.day());


            Zuora.zApi.SubscribeInvoiceProcessingOptions sip = new Zuora.zApi.SubscribeInvoiceProcessingOptions();
            Datetime enddt = dt.addMonths((Integer) terms);
            //sip.InvoiceTargetDate = enddt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
            sip.InvoiceTargetDate = enddt.formatGmt('yyyy-MM-dd');
            //sip.InvoiceDate = invoiceDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
            sip.InvoiceDate = invoiceDate.formatGmt('yyyy-MM-dd');
            sip.InvoiceProcessingScope = 'Subscription';

            //subscription options
            Zuora.zApi.SubscribeOptions so = new Zuora.zApi.SubscribeOptions();
            so.GenerateInvoice = true;
            so.ProcessPayments = false;
            so.SubscribeInvoiceProcessingOptions = sip;

            //Preview options
            //Integer numOfPeriods =
            Zuora.zApi.PreviewOptions previewOpt = new Zuora.zApi.PreviewOptions();
            previewOpt.EnablePreviewMode = true;

            //previewOpt.NumberOfPeriods = numOfPeriods;

            //subscribe request
            Zuora.zApi.SubscribeRequest subsRequest = new Zuora.zApi.SubscribeRequest();

            subsRequest.ZAccount = acc;
            subsRequest.SubscribeOptions = so;
            subsRequest.SubscriptionData = sd;

            subsRequest.PreviewOptions = previewOpt;

            List<Zuora.zApi.SubscribeRequest> subsRequestLists = new List<Zuora.zApi.SubscribeRequest>{
                    subsRequest
            };

            Zuora.zApi zuoraApi = login();
            List<Zuora.zApi.SubscribeResult> subscribeResults = null;


            if (!Test.isRunningTest()) {
                //System.debug('amend preview request: '+amendRequests);
                quoteToUpdate = new zqu__Quote__c();
                quoteToUpdate.Id = quote.Id;
                try {
                    subscribeResults = zuoraApi.zsubscribe(subsRequestLists);

                    for (Zuora.zApi.SubscribeResult result : subscribeResults) {
                        if (result.Success) {
                            Decimal taxAmount = 0;
                            Decimal subtotal = 0;
                            if (result.InvoiceDatas != null) {

                                for (Zuora.zObject invData : result.InvoiceDatas) {
                                    Zuora.zObject zInvoice = (Zuora.zObject) invData.getValue('Invoice');
                                    subtotal = (Decimal) zInvoice.getValue('AmountWithoutTax');

                                    //in Preview mode, handle with the invoice data
                                    List<Object> invoiceItems = invData.getArrayValue('InvoiceItem');
                                    if (invoiceItems != null) {
                                        for (Object invItem : invoiceItems) {
                                            Zuora.zObject zInvoiceItem = (Zuora.zObject) invItem;
                                            //subtotal += ( Decimal ) zInvoiceItem.getValue( 'ChargeAmount' );
                                            taxAmount += (Decimal) zInvoiceItem.getValue('TaxAmount');
                                        }
                                    }
                                }
                                quoteToUpdate.Calculated_Tax__c = String.valueOf(taxAmount.setScale(2));
                                quoteToUpdate.Calculated_SubTotal__c = String.valueOf(subtotal.setScale(2));
                            }
                        } else {
                            Zuora.zObject[] errors = result.errors;
                            String message = '';
                            for (Zuora.zObject error : errors) {
                                message = (String) error.getValue('Message');
                                System.debug('Error message =' + message);
                            }
                            if (message.length() > 30) {
                                message = message.subString(0, 30);
                            }
                            quoteToUpdate.Calculated_Tax__c = message;
                        }
                    }
                } catch (Exception e) {
                    System.debug('Error message =' + e.getMessage());
                    quoteToUpdate.Calculated_Tax__c = (e.getMessage().length() > 30) ? e.getMessage().subString(0, 30) : e.getMessage();
                }
                //System.debug('amend preview result: '+amendResult);
                System.debug('SOAP Request = ' + Zuora.zApi.currentLogger.request);
                System.debug('SOAP Response = ' + Zuora.zApi.currentLogger.response);
                //update quoteToUpdate;
            } else {
                //amendResult = ProductSelectorControllerTest.dummySubscribeResults();
            }
        }
        return quoteToUpdate;

    }
	/*
    public static Map<String, Decimal> subscribePreviewCall(List<zqu.zChargeGroup> chargeGroups, Map<String, String> chargeMap, zqu__Quote__c q) {
        Map<String, Decimal> returnValues = new Map<String, Decimal>();

        system.debug('########### ChargeMap = ' + chargeMap);

        try {
            Company_Code__c companyCode = null;

            List<Company_Code__c> companyCodes = [SELECT Tax_Region__c from Company_Code__c where Code__c = :q.Company_Code1__c];
            if (companyCodes.size() > 0) {
                companyCode = companyCodes[0];
            }

            //build dummy account and contact
            Zuora.zObject acc = new Zuora.zObject('Account');
            acc.setValue('Name', q.zqu__Account__r.name);
            acc.setValue('Currency', q.zqu__Currency__c);
            acc.setValue('BillCycleDay', 1);
            acc.setValue('PaymentTerm', q.zqu__PaymentTerm__c);
            if (q.Tax_Exempt__c) {
                acc.setValue('TaxExemptStatus', 'Yes');
                //acc.setValue('TaxExemptCertificateID', 'Dummy Cert');
                acc.setValue('TaxExemptCertificateID', q.Certificate_Id1__c);
            } else {
                acc.setValue('TaxExemptStatus', 'No');
            }
            acc.setValue('Batch', 'Batch2'); //direct is 2, indirect is 1
            if (companyCode != null) {
                acc.setValue('TaxCompanyCode', companyCode.Tax_Region__c);
            }
            acc.setvalue('VATId', q.VAT_ID1__c);
            //acc.setValue('Invoice_VATID__c', q.VAT_ID1__c);

            //build contacts
            Zuora.zObject billToContact = new Zuora.zObject('Contact');
            billToContact.setValue('Address1', q.zqu__SoldToContact__r.MailingStreet);
            billToContact.setValue('City', q.zqu__SoldToContact__r.MailingCity);
            billToContact.setValue('Country', q.zqu__SoldToContact__r.MailingCountryCode);
            billToContact.setValue('PostalCode', q.zqu__SoldToContact__r.MailingPostalCode);
            billToContact.setValue('State', q.zqu__SoldToContact__r.MailingStateCode);
            billToContact.setValue('FirstName', q.zqu__SoldToContact__r.FirstName);
            billToContact.setValue('LastName', q.zqu__SoldToContact__r.LastName);

            Zuora.zObject soldToContact = new Zuora.zObject('Contact');
            soldToContact.setValue('Address1', q.zqu__SoldToContact__r.MailingStreet);
            soldToContact.setValue('City', q.zqu__SoldToContact__r.MailingCity);
            soldToContact.setValue('Country', q.zqu__SoldToContact__r.MailingCountryCode);
            soldToContact.setValue('PostalCode', q.zqu__SoldToContact__r.MailingPostalCode);
            soldToContact.setValue('State', q.zqu__SoldToContact__r.MailingStateCode);
            soldToContact.setValue('FirstName', q.zqu__SoldToContact__r.FirstName);
            soldToContact.setValue('LastName', q.zqu__SoldToContact__r.LastName);
            //soldToContact.setValue('TaxRegion', companyCode.Tax_Region__c);

            Map<String, Zuora.zObject> rpdMap = new Map<String, Zuora.zObject>();
            List<Zuora.zObject> rpdList = new List<Zuora.zObject>();

            Integer largestTerm = 0;
            Date earliestDate = null;

            for (zqu.zChargeGroup chargeGroup : chargeGroups) {
                String productRateplanId = chargeMap.get(chargeGroup.zCharges[0].PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID);

                system.debug('########### productRateplanId = ' + productRateplanId);

                Zuora.zObject rp = new Zuora.zObject('RatePlan');
                rp.setValue('ProductRatePlanId', productRateplanId);
                Zuora.zObject rpd = new Zuora.zObject('RatePlanData');
                rpd.setValue('RatePlan', rp);

                for (zqu.zCharge charge : chargeGroup.zCharges) {
                    if (Integer.valueOf(charge.ChargeObject.get('Initial_Term__c')) > largestTerm) {
                        largestTerm = Integer.valueOf(charge.ChargeObject.get('Initial_Term__c'));
                    }

                    if (earliestDate == null || earliestDate > Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00')) {
                        earliestDate = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00');
                    }

                    Zuora.zObject rpc = new Zuora.zObject('RatePlanCharge');
                    rpc.setValue('ProductRatePlanChargeId', charge.PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID);
                    if (charge.QUANTITY != '-') {
                        rpc.setValue('Quantity', charge.QUANTITY);
                    }
                    rpc.setValue('Price', charge.EFFECTIVE_PRICE);

                    if (charge.CHARGE_TYPE == 'Recurring') {
                        Date startDate = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00');
                        Datetime startDateTime = datetime.newInstance(startDate.year(), startDate.month(), startDate.day());
                        rpc.setValue('TriggerEvent', 'SpecificDate');
                        //rpc.setValue('TriggerDate', startDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss'));
                        rpc.setValue('TriggerDate', startDateTime.formatGmt('yyyy-MM-dd'));
                    }

                    Zuora.zObject rpcd = new Zuora.zObject('RatePlanChargeData');
                    rpcd.setValue('RatePlanCharge', rpc);
                    List<Zuora.zObject> existingRpcds = new List<Zuora.zObject>();
                    List < Object > exisingRpcdList = rpd.getArrayValue('RatePlanChargeData');
                    if (exisingRpcdList != null) {
                        for (Object exisingRpcd : exisingRpcdList) {
                            existingRpcds.add((Zuora.zObject) exisingRpcd);
                        }
                    }
                    existingRpcds.add(rpcd);
                    rpd.setValue('RatePlanChargeData', existingRpcds);

                    // Before creating new RATEPLANDATA for each charge,
                    // Need to find out if RATEPLANDATA exists.
                    // If exists, add the charge to existing RATEPLANDATA, else create new one
                    //rpdMap.put(quoteRatePlanId, rpd);
                }
                rpdList.add(rpd);
            }

            Datetime dt = datetime.newInstance(earliestDate.year(), earliestDate.month(), earliestDate.day());
            //String effectiveDate = dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
            String effectiveDate = dt.formatGmt('yyyy-MM-dd');

            //subscription
            Zuora.zObject sub = new Zuora.zObject('Subscription');
            sub.setValue('Name', 'subscription - SubscriptionName');
            sub.setValue('ContractEffectiveDate', effectiveDate);
            sub.setValue('ServiceActivationDate', effectiveDate);
            sub.setValue('InitialTerm', largestTerm);
            sub.setValue('RenewalTerm', 12);


            Zuora.zApi.SubscriptionData sd = new Zuora.zApi.SubscriptionData();
            sd.Subscription = sub;
            sd.RatePlanData = rpdList;

            Date todayDate = Date.today();
            Datetime invoiceDate = DateTime.newInstance(todayDate.year(), todayDate.month(), todayDate.day());


            Zuora.zApi.SubscribeInvoiceProcessingOptions sip = new Zuora.zApi.SubscribeInvoiceProcessingOptions();
            Datetime enddt = dt.addMonths(largestTerm);
            //sip.InvoiceTargetDate = enddt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
            sip.InvoiceTargetDate = enddt.formatGmt('yyyy-MM-dd');
            //sip.InvoiceDate = invoiceDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
            sip.InvoiceDate = invoiceDate.formatGmt('yyyy-MM-dd');

            //subscription options
            Zuora.zApi.SubscribeOptions so = new Zuora.zApi.SubscribeOptions();
            so.GenerateInvoice = true;
            so.ProcessPayments = false;
            so.SubscribeInvoiceProcessingOptions = sip;

            //Preview options
            //Integer numOfPeriods =
            Zuora.zApi.PreviewOptions previewOpt = new Zuora.zApi.PreviewOptions();
            previewOpt.EnablePreviewMode = true;

            //previewOpt.NumberOfPeriods = numOfPeriods;
            //subscribe request
            Zuora.zApi.SubscribeRequest subsRequest = new Zuora.zApi.SubscribeRequest();

            subsRequest.ZAccount = acc;
            subsRequest.BillToContact = billToContact;
            subsRequest.SoldToContact = soldToContact;
            subsRequest.SubscribeOptions = so;
            subsRequest.SubscriptionData = sd;

            subsRequest.PreviewOptions = previewOpt;

            List<Zuora.zApi.SubscribeRequest> subsRequestLists = new List<Zuora.zApi.SubscribeRequest>{
                    subsRequest
            };

            Zuora.zApi zuoraApi = login();
            List<Zuora.zApi.SubscribeResult> subscribeResults = null;
            if (!Test.isRunningTest()) {
                subscribeResults = zuoraApi.zsubscribe(subsRequestLists);
            } else {
                subscribeResults = ProductSelectorControllerTest.dummySubscribeResults();
            }
            if (!Test.isRunningTest()) {
                System.debug('SOAP Request = ' + Zuora.zApi.currentLogger.request);
                System.debug('SOAP Response = ' + Zuora.zApi.currentLogger.response);
            }

            for (Zuora.zApi.SubscribeResult result : subscribeResults) {
                if (result.Success) {
                    //Handle with the invoice data returned by previewing subscriptions
                    System.debug('MRR: ' + result.TotalMrr);
                    System.debug('TCV: ' + result.TotalTCV);
                    returnValues.put('TCV', result.TotalTCV);
                    returnValues.put('MRR', result.TotalMrr);
                    if (result.InvoiceDatas != null) {
                        for (Zuora.zObject invData : result.InvoiceDatas) {
                            //in Preview mode, handle with the invoice data
                            Zuora.zObject invoice = (Zuora.zObject) invData.getValue('Invoice');
                            Decimal amountwithoutTax = (Decimal) invoice.getValue('AmountWithoutTax');
                            Decimal taxAmount = (Decimal) invoice.getValue('TaxAmount');
                            returnValues.put('subtotal', amountwithoutTax);
                            returnValues.put('tax', taxAmount);
                        }
                    }

                } else {
                    returnValues.put('TCV', null);
                    returnValues.put('MRR', null);
                    //failure
                    //get the errors
                    Zuora.zObject[] errors = result.errors;
                    for (Zuora.zObject error : errors) {
                        String errorCode = (String) error.getValue('Code');
                        String message = (String) error.getValue('Message');
                        //more code here...
                        System.debug('Error during the preview call: [Error Code] =' + errorCode);
                        System.debug('Error during the preview call: [Error Message] =' + message);
                    }
                }
            }

        } catch (Zuora.zRemoteException ex) {
            returnValues.put('TCV', null);
            returnValues.put('MRR', null);
        } catch (Zuora.zAPIException ex) {
            returnValues.put('TCV', null);
            returnValues.put('MRR', null);
        } catch (Zuora.zForceException ex) {
            returnValues.put('TCV', null);
            returnValues.put('MRR', null);
        }

        return returnValues;
    }
	*/

    /*
   * Make a list of charge group holders
   */
    private List <ChargeGroupHolder> makeChargeGroupHolders(List <zqu.zChargeGroup> chargeGroups,
            List<zqu__ProductRatePlan__c> rateplans,
            Map<String, zqu__ProductRatePlan__c> prpMap,
            Map<Id, Boolean> notDiscountableMap,
            Boolean isNew) {

        List <ChargeGroupHolder> output = new List <ChargeGroupHolder>();
        if (isNew) {

            System.debug('New product rateplan is selected.');

//      Integer counter = 0;
            for (zqu.zChargeGroup cg : chargeGroups) {
                ChargeGroupHolder cgh = new ChargeGroupHolder();
                cgh.id = wrapperIdCounter;
                wrapperIdCounter++;
                String serviceCategory = '';
                if (rateplans != null) {
                    for (zqu__ProductRatePlan__c prp : rateplans) {
                        if (cg.productRateplanZuoraID == prp.zqu__ZuoraId__c) {
                            cgh.sRatePlan = prp;
                            cgh.sRatePlanId = prp.Id;
                            serviceCategory = prp.zqu__Product__r.ProductServiceCategory__c;

                            System.debug('Matching PRP found, Service category = ' + serviceCategory);
                            break;
                        }
                    }
                }

                List<ChargeWrapper> charges = new List<ChargeWrapper>();
                for (zqu.ZCharge charge : cg.ZCharges) {

                    System.debug('Product_Rate_Plan__c = ' + prpMap.get(charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID));
                    // set product rateplan id on quoterateplancharge
                    charge.ChargeObject.put('Product_Rate_Plan__c', prpMap.get(charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID).Id);
                    charge.ChargeObject.put('zqu__Currency__c', quote.zqu__Currency__c);
                    charge.ChargeObject.put('zqu__ProductRatePlanCharge__c', charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);
                    if(charge.ChargeObject.get('Rollup_Type__c') == null){
                        charge.chargeObject.put('Rollup_Type__c', quote.zqu__Opportunity__r.Type == 'Renew Subscription'?'Renewal':'New');
                    }

                    Decimal listTotal = 0;

                    System.debug(1);
                    Decimal multiplier = countryMultiplierSvc.multiplier(serviceCategory, countryMultipliers);
                    System.debug(2);
                    Decimal newListPrice = chargeSvc.calculateListPrice(Decimal.valueOf(charge.LIST_PRICE), multiplier, conversionRate);
                    System.debug(3);
                    Decimal effectivePrice = Decimal.valueOf(charge.EFFECTIVE_PRICE);
                    System.debug(4);
                    Decimal discount = 0;
                    System.debug(5);
                    if (newListPrice != 0) {
                        discount = (newListPrice - effectivePrice) / newListPrice * 100;
                    }
                    System.debug(6);
                    charge.ChargeObject.put('Start_Date__c', getQuoteStartDate());
                    charge.ChargeObject.put('Start_Date_Display__c', quote.zqu__StartDate__c);
                    System.debug('start date: ' + getQuoteStartDate());

                    charge.ChargeObject.put('Initial_Term__c', 1);

                    if (charge.CHARGE_TYPE == 'Recurring') {
                        if (quote.Payment_Plan__c == 'Annual') {
                            charge.ChargeObject.put('Initial_Term__c', 12);
                        } else if (quote.Payment_Plan__c == 'Semi-Annual') {
                            charge.ChargeObject.put('Initial_Term__c', 6);
                        } else if (quote.Payment_Plan__c == 'Quarterly') {
                            charge.ChargeObject.put('Initial_Term__c', 3);
                        }
                    }

                    System.debug('initial term: ' + quote.zqu__InitialTerm__c);

                    if (quote.zqu__SubscriptionType__c != 'New Subscription') {
                        Decimal term = quote.zqu__InitialTerm__c;
                        if (quote.zqu__SubscriptionType__c == 'Amend Subscription') {
                            term = quote.zqu__StartDate__c.monthsBetween(quote.zqu__SubscriptionTermEndDate__c);
                        } else {
                            Date endDate = quote.zqu__SubscriptionTermEndDate__c.addMonths(Integer.valueOf(quote.zqu__RenewalTerm__c));
                            term = quote.zqu__StartDate__c.monthsBetween(endDate);
                        }
                        charge.ChargeObject.put('Initial_Term__c', term);
                        if (cgh.sRatePlan.BillingPeriod__c == 'Prepaid') {
                            newListPrice = newListPrice * term;
                        }
                    }

                    if (charge.QUANTITY != '-') {
                        listTotal = newListPrice * Decimal.valueOf(charge.QUANTITY);
                    } else {
                        listTotal = newListPrice;
                    }

                    if (charge.CHARGE_TYPE == 'Recurring') {
                        if (quote.zqu__InitialTerm__c != 0) {
                            newListPrice = newListPrice * 1;
                        }
                        //discount = (newListPrice-effectivePrice)/newListPrice*100;
                        listTotal = newListPrice * Decimal.valueOf(charge.QUANTITY);

                        //System.debug('list price display: '+cp.zqu__ListPriceDisplay__c);
                        charge.ChargeObject.put('zqu__Period__c', 'Specific Months');
                        if (quote.Payment_Plan__c == 'Prepaid' || quote.Payment_Plan__c == 'Monthly') {
                            charge.ChargeObject.put('zqu__SpecificBillingPeriod__c', 1);
                        } else if (quote.Payment_Plan__c == 'Quarterly') {
                            charge.ChargeObject.put('zqu__SpecificBillingPeriod__c', 3);
                        } else if (quote.Payment_Plan__c == 'Semi-Annual') {
                            charge.ChargeObject.put('zqu__SpecificBillingPeriod__c', 6);
                        } else if (quote.Payment_Plan__c == 'Annual') {
                            charge.ChargeObject.put('zqu__SpecificBillingPeriod__c', 12);
                        }

                        //charge.ChargeObject.put('Initial_Term__c', 1);
                    }

                    System.debug('specific billing period: ' + charge.ChargeObject.get('zqu__SpecificBillingPeriod__c'));
                    System.debug('quote payment plan: ' + quote.Payment_Plan__c);

                    //discount = discount.setScale(2);
                    newListPrice = newListPrice.setScale(2);
                    listTotal = listTotal.setScale(2);
                    charge.ChargeObject.put('Listed_Price__c', String.valueOf(newListPrice));
                    charge.ChargeObject.put('Calculated_Discount__c', String.valueOf(0));
                    charge.ChargeObject.put('Listed_Total__c', String.valueOf(listTotal));
                    charge.EFFECTIVE_PRICE = String.valueOf(newListPrice);
                    charge.ChargeObject.put('Country_Uplift__c', String.valueOf(multiplier.setScale(2)));
                    charge.ChargeObject.put('RATE_USD__c', String.valueOf(conversionRate));

                    if (serviceCategory != 'Services' && quote.zqu__SubscriptionType__c != 'Renew Subscription') {
                        charge.ChargeObject.put('zqu__TriggerEvent__c', 'SpecificDate');
                        charge.ChargeObject.put('zqu__TriggerDate__c', quote.zqu__Customer_Acceptance_Date__c);
                    }


                    charge.TOTAL = String.valueOf(listTotal);

                    ChargeWrapper chargeWrapper = new ChargeWrapper();
                    System.debug('service cat: ' + serviceCategory + ' list price: ' + newListPrice);
                    if (serviceCategory == 'Services') {
                        cgh.isServices = true;
                        if (newListPrice == 0.00) {
                            chargeWrapper.renderListPrice = true;
                        }
                    } else {
                        chargeWrapper.renderListPrice = false;
                        cgh.isServices = false;
                    }
                    chargeWrapper.zcharge = charge;
                    chargeWrapper.start_Date = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00');
                    chargeWrapper.initial_Term = String.valueOf(charge.ChargeObject.get('Initial_Term__c'));
                    chargeWrapper.listed_Price = String.valueOf(charge.ChargeObject.get('Listed_Price__c'));
                    chargeWrapper.listed_Total = String.valueOf(charge.ChargeObject.get('Listed_Total__c'));
                    chargeWrapper.calculated_Discount = String.valueOf(charge.ChargeObject.get('Calculated_Discount__c'));
                    chargeWrapper.isNotDiscountable = notDiscountableMap.get(charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);

                    charges.add(chargeWrapper);

                }


                cgh.chargeWrappers = charges;
                List<zqu.ZCharge> updatedCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(cg.ZCharges);
                cg.ZCharges = updatedCharges;
                cgh.chargeGroup = cg;
                //cgh.display = (String)cg.zCharges[0].chargeObject.get('Display__c');
                output.add(cgh);
            }
        } else {
//      Integer counter = 0;
            for (zqu.zChargeGroup cg : chargeGroups) {
                ChargeGroupHolder cgh = new ChargeGroupHolder();
                cgh.id = wrapperIdCounter;
                wrapperIdCounter++;
                System.debug('chargegroup from subscription: ' + cg);
                String serviceCategory = '';

                if (prpMap.keySet().size() == 0) {
                    for (zqu__ProductRatePlan__c prp : rateplans) {
                        if (cg.productRateplanZuoraID == prp.zqu__ZuoraId__c) {
                            cgh.sRatePlan = prp;
                            cgh.sRatePlanId = prp.Id;
                            serviceCategory = prp.zqu__Product__r.ProductServiceCategory__c;
                            break;
                        }
                    }
                } else {
                    System.debug('cg.prpcid: ' + cg.zCharges[0].PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);
                    zqu__ProductRatePlan__c prp = prpMap.get(cg.zCharges[0].PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);
                    cgh.sRatePlanId = prp.Id;
                    cgh.sRatePlan = prp;
                    serviceCategory = prp.zqu__Product__r.ProductServiceCategory__c;
                }


                List<ChargeWrapper> charges = new List<ChargeWrapper>();
                for (zqu.ZCharge charge : cg.ZCharges) {
                    System.debug('charge from subscription: ' + charge);
                    ChargeWrapper chargeWrapper = new ChargeWrapper();
                    System.debug('service cat: ' + serviceCategory + ' list price: ' + charge.ChargeObject.get('Listed_Price__c'));
                    if (serviceCategory == 'Services') {
                        cgh.isServices = true;
                        if (charge.ChargeObject.get('Listed_Price__c') == '0.00') {
                            chargeWrapper.renderListPrice = true;
                        }
                    } else {
                        cgh.isServices = false;
                        chargeWrapper.renderListPrice = false;
                    }
                    chargeWrapper.zcharge = charge;

                    DateTime dateTimeStartDate = null;
                    String formattedDate = null;
                    Decimal term = quote.zqu__InitialTerm__c;
                    if (quote.zqu__SubscriptionType__c != 'New Subscription') {
                        if (cg.groupType == zqu.zChargeGroup.TYPE_RENEWAL_RENEWED) {
                            dateTimeStartDate = datetime.newInstance(quote.zqu__SubscriptionTermEndDate__c.year(), quote.zqu__SubscriptionTermEndDate__c.month(), quote.zqu__SubscriptionTermEndDate__c.day());
                            formattedDate = dateTimeStartDate.format('yyyy-MM-dd');
                            charge.ChargeObject.put('Start_Date__c', formattedDate);
                            charge.ChargeObject.put('Initial_Term__c', quote.zqu__RenewalTerm__c);
                        } else if (cg.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT || cg.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT) {
                            charge.ChargeObject.put('Start_Date__c', getQuoteStartDate());
                            term = quote.zqu__StartDate__c.monthsBetween(quote.zqu__SubscriptionTermEndDate__c);
                            charge.ChargeObject.put('Initial_Term__c', term);
                        } else if (cg.groupType == zqu.zChargeGroup.TYPE_RENEWAL_REMOVEPRODUCT || cg.groupType == zqu.zChargeGroup.TYPE_RENEWAL_UPDATEPRODUCT) {
                            charge.ChargeObject.put('Start_Date__c', getQuoteStartDate());
                            Date endDate = quote.zqu__SubscriptionTermEndDate__c.addMonths(Integer.valueOf(quote.zqu__RenewalTerm__c));
                            term = quote.zqu__StartDate__c.monthsBetween(endDate);
                            charge.ChargeObject.put('Initial_Term__c', term);
                        }
                    }

                    if (charge.ChargeObject.get('Start_Date__c') == null) {
                        charge.ChargeObject.put('Start_Date__c', getQuoteStartDate());
                    }
                    System.debug('start date: ' + charge.ChargeObject.get('Initial_Term__c') + ' trigger date: ' + charge.ChargeObject.get('Start_Date__c'));

                    chargeWrapper.start_Date = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00');
                    Integer initTerm = Integer.valueOf(charge.ChargeObject.get('Initial_Term__c'));

                    chargeWrapper.initial_Term = String.valueOf(initTerm);
                    if (charge.ChargeObject.get('Listed_Price__c') != null)
                        chargeWrapper.listed_Price = String.valueOf(charge.ChargeObject.get('Listed_Price__c')); else
                            chargeWrapper.listed_Price = charge.LIST_PRICE;
                    chargeWrapper.listed_Total = String.valueOf(charge.ChargeObject.get('Listed_Total__c'));
                    if (charge.ChargeObject.get('Calculated_Discount__c') != null)
                        chargeWrapper.calculated_Discount = String.valueOf(charge.ChargeObject.get('Calculated_Discount__c')); else
                            chargeWrapper.calculated_Discount = charge.DISCOUNT;

                    chargeWrapper.isNotDiscountable = notDiscountableMap.get(charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);

                    charges.add(chargeWrapper);
                }
                cgh.chargeWrappers = charges;
                cgh.chargeGroup = cg;
                output.add(cgh);
            }
        }
        if (isNew) {
            for (ChargeGroupHolder cgh : output) {
                chargeGroupHolderMap.put(cgh.Id, cgh);
            }
        } else {
            for (ChargeGroupHolder cgh : output) {
                existingChargeGroupHolderMap.put(cgh.Id, cgh);
            }
        }

        return output;
    }

    /*
   *  Create the holders for existing charge groups on the quote
   */
    private List<ChargeGroupHolder> getExistingChargeGroupHolders() {
        List < ChargeGroupHolder > output = new List < ChargeGroupHolder >();
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = quoteChargeCustomFields;
        //the product rate plan zuora id wont be set on the charge group...
        try {
            existingChargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteId);
        } catch (Exception ex) {
            this.appendMessage(ApexPages.Severity.ERROR, 'There is an error loading the page, please notify your administrator.');
            System.debug('get charge groups error: ' + ex.getMessage());
        }
        Map<String, zqu__ProductRatePlan__c> prpMap = new Map<String, zqu__ProductRatePlan__c>();
        Map<Id, Boolean> notDiscountableMap = new Map<Id, Boolean>();

        Set<String> prpIds = new Set<String>();
        Map<String, String> chargeIds = new Map<String, String>();
        for (zqu.zChargeGroup cg : existingChargeGroups) {
            if (cg.productRateplanZuoraID != null) {
                prpIds.add(cg.productRateplanZuoraID);
            }
            chargeIds.put(cg.zCharges[0].PRODUCT_RATE_PLAN_CHARGE_SFDC_ID, cg.groupID);
        }


        System.debug('prpids: ' + prpIds);

        System.Debug('existingChargeGroups size: ' + existingChargeGroups.size());

        Map<Id, zqu__ProductRatePlan__c> prpList = new Map<Id, zqu__ProductRatePlan__c>();
        Map<String, String> prpIdMap = new Map<String, String>();

        //if (prpIds.size() == 0) {
        List<zqu__ProductRatePlanCharge__c> prpcList = [
                SELECT Id,
                        PSMapping__c,
                        zqu__UOM__c,
                        zqu__ProductRatePlan__r.zqu__ZuoraId__c,
                        zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c,
                        Not_Discountable__c
                FROM zqu__ProductRatePlanCharge__c
                WHERE id in :chargeIds.keySet()
        ];
        for (zqu__ProductRatePlanCharge__c prpc : prpcList) {
            prpIds.add(prpc.zqu__ProductRatePlan__r.zqu__ZuoraId__c);
            prpIdMap.put(prpc.Id, prpc.zqu__ProductRatePlan__r.Id);
            notDiscountableMap.put(prpc.Id, prpc.Not_Discountable__c);
        }
        //}

        prpList = new Map<Id, zqu__ProductRatePlan__c>([
                SELECT Id,
                        zqu__ZuoraId__c,
                        zqu__Product__r.Name,
                        zqu__Product__r.ProductServiceCategory__c,
                        BillingPeriod__c,
                        zqu__Product__r.zqu__SKU__c
                FROM zqu__ProductRatePlan__c
                WHERE zqu__ZuoraId__c
                        IN :prpIds
        ]);

        System.debug('prplist: ' + prpList);

        for (String prpcId : prpIdMap.keySet()) {
            prpMap.put(prpcId, prpList.get(prpIdMap.get(prpcId)));
        }

        System.debug('prpMap: ' + prpMap);

        output = makeChargeGroupHolders(existingChargeGroups, prpList.values(), prpMap, notDiscountableMap, false);
        if (existingChargeGroups.size() > 0) {
            showExistingCharges = true;
        }
        return output;
    }

    /*
   *  Create the holders for new charge groups that are going to be added
   */
    private List < ChargeGroupHolder > getChargeGroupHolderList(zqu__productRatePlan__c rateplan) {

        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = quoteChargeCustomFields;

        List < ChargeGroupHolder > output = new List < ChargeGroupHolder >();

        if (rateplan != null) {
            Map<String, zqu__ProductRatePlan__c> prpMap = new Map<String, zqu__ProductRatePlan__c>();
            Map<Id, Boolean> notDiscountableMap = new Map<Id, Boolean>();

            zqu__ProductRatePlan__c prp = [
                    SELECT Id,
                            zqu__ZuoraId__c,
                            zqu__Product__r.Name,
                            zqu__Product__r.ProductServiceCategory__c,
                            BillingPeriod__c
                    FROM zqu__ProductRatePlan__c
                    WHERE Id = :rateplan.Id
                    limit 1
            ];

            for (zqu__ProductRatePlanCharge__c prpc : [SELECT Id, Not_Discountable__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__ProductRatePlan__c = :prp.Id]) {
                prpMap.put(prpc.Id, prp);
                notDiscountableMap.put(prpc.Id, prpc.Not_Discountable__c);
            }

            System.debug('Selected product rateplan:' + prpMap);

            try {
                output = makeChargeGroupHolders(new List<zqu.zChargeGroup>{
                        zqu.zQuoteUtil.getChargeGroup(quoteId, rateplan.Id)
                },
                        new List < zqu__productRatePlan__c >{
                                rateplan
                        },
                        prpMap,
                        notDiscountableMap,
                        true);
            } catch (Exception ex) {
                this.appendMessage(ApexPages.Severity.ERROR, 'There is an error loading the page, please notify your administrator.');
                System.debug('get charge groups error: ' + ex.getMessage());
                System.debug(ex.getStackTraceString());
            }

            System.Debug('Making charge group holder list' + output);
        }
        return output;
    }

    /*
   *  Display a message on the VF page
   */
    private void appendMessage(ApexPages.Severity severity, String message) {
        ApexPages.addMessage(new ApexPages.Message(severity, message));
    }
    /*
   *  Build the rate plan query with the selected filters
   */
    private string buildRatePlanQuery() {
        String ratePlanQuery = 'SELECT Id, Name, zqu__Description__c, ' +
                'zqu__ZuoraId__c, zqu__Product__r.Name, zqu__Product__r.zqu__SKU__c, zqu__Product__r.ProductServiceCategory__c, BillingPeriod__c  ' +
                'FROM zqu__ProductRatePlan__c ' +
                'WHERE zqu__Deleted__c = false and ' +
                'zqu__EffectiveStartDate__c <= TODAY and ' +
                'zqu__EffectiveEndDate__c >= TODAY and ' +
                'BillingPeriod__c != \'Usage\'' ;

        if (!String.isEmpty(selectedProductId)) {
            ratePlanQuery += 'AND zqu__Product__c = \'' + selectedProductId + '\'';
        }

        if (!String.isEmpty(quote.Payment_Plan__c) && quote.Payment_Plan__c != NONE && !quote.Override_Payment_Plan__c) {
            ratePlanQuery += ' AND BillingPeriod__c in (\'\', \'' + quote.Payment_Plan__c + '\')';
        }

        if (!String.isEmpty(pickedProductFamily) && pickedProductFamily != NONE && pickedProductFamily != 'All') {
            ratePlanQuery += ' AND zqu__Product__r.ProductFamily__c = \'' + pickedProductFamily + '\'';
        }

        if (quote.zqu__SubscriptionType__c != 'New Subscription') {
            ratePlanQuery += ' AND zqu__Product__r.ProductServiceCategory__c = \'' + quote.Subscription_Type__c + '\'';
        } else {
            if (!String.isEmpty(pickedServiceCategory) && pickedServiceCategory != NONE && pickedServiceCategory != 'All') {
                ratePlanQuery += ' AND zqu__Product__r.ProductServiceCategory__c = \'' + pickedServiceCategory + '\'';
            }
        }

        if (!String.isEmpty(pickedAvailability) && pickedAvailability != NONE && pickedAvailability != 'All') {
            ratePlanQuery += ' AND Availability__c = \'' + pickedAvailability + '\'';
        }


        return ratePlanQuery;
    }
    /*
   *  get the rate plans
   */
    private Boolean getProductRatePlans() {
        productRatePlanZuoraIdMap.clear();
        String ratePlanQuery = buildRatePlanQuery();
        ratePlanQuery += ' ORDER BY Name';
        System.Debug('ratePlanQuery: ' + ratePlanQuery);
        productRatePlanList = Database.query(ratePlanQuery);
        System.debug('### Retrieved ' + productRatePlanList.size() + ' product rate plan(s)');
        productRatePlanMap = new Map < ID, zqu__productRatePlan__c >(productRatePlanList);
        List<zqu__ProductRatePlan__c> displayPrpList = new List<zqu__ProductRatePlan__c>();
        for (zqu__productRatePlan__c prp : productRatePlanList) {
            //if the display flag is set add it to the map of pickable rate plans
            displayPrpList.add(prp);
            if (selectedproductRatePlanMap.get(prp.Id) == null) {
                selectedproductRatePlanMap.put(prp.Id, false);
            }

            productRatePlanZuoraIdMap.put(prp.zqu__ZuoraId__c, prp);
        }
        // Initialize the standard set (for the table on the VF page)
        productRatePlanSet = new ApexPages.StandardSetController(displayPrpList);
        productRatePlanSet.setPageSize(PAGE_SIZE);
        // Successfully validated the context
        return true;
    }

    public List<SelectOption> getFieldValues(String objectName, String fieldName) {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new Selectoption('All', 'All'));
        System.debug('populating field values: ');
        if (fieldName != null && fieldName != '') {

            SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            list<Schema.PicklistEntry> values = fieldMap.get(fieldName).getDescribe().getPickListValues();
            System.debug('values: ' + values);
            for (Schema.PicklistEntry a : values) {
                options.add(new SelectOption(a.getLabel(), a.getValue()));
            }
        }
        return options;
    }

    /*
   * Setup the notification options
   */

    public String getQuoteStartDate() {
        String formattedDate = '';

        if (quote.zqu__StartDate__c != null) {
            System.debug('year: ' + quote.zqu__StartDate__c.year() + ' month: ' + quote.zqu__StartDate__c.month() + ' day: ' + quote.zqu__StartDate__c.day());
            DateTime dateTimeStartDate = datetime.newInstance(quote.zqu__StartDate__c.year(), quote.zqu__StartDate__c.month(), quote.zqu__StartDate__c.day());
            formattedDate = dateTimeStartDate.format('yyyy-MM-dd');
        } else {
            DateTime dateTimeStartDate = datetime.now();
            formattedDate = dateTimeStartDate.format('yyyy-MM-dd');
        }
        return formattedDate ;
    }

    private zqu.NotificationOptions getNotificationOptions() {
        zqu.NotificationOptions no = new zqu.NotificationOptions();
        no.failureTitle = 'There are validation errors, please fix the following:';
        return no;
    }
}