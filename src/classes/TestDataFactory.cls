@isTest
public class TestDataFactory {

    public static Account createAccount(Boolean insertYN) {
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Type = 'Customer';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'Washington';

        if(insertYN) {insert acc;}
        
        return acc;
    }

    public static Contact createContact(Id accID, Boolean insertYN) {


        Contact ctt = new Contact();
        ctt.FirstName = 'Test';
        ctt.LastName = 'Contact';
        ctt.Email = 'email@mail.me';
        ctt.MailingCountry = 'United States';
        ctt.MailingCountryCode = 'US';
        ctt.MailingState = 'Washington';
        ctt.MailingStateCode = 'WA';
        ctt.MailingPostalCode = '12345';
        ctt.MailingStreet = '123 Main St.';
        ctt.MailingCity = 'Seattle';
        ctt.Phone = '404-444-4444';
        ctt.AccountId = accID;

        if(insertYN) {insert ctt;}

        return ctt;
    }

    public static Opportunity createOpportunity(Id accID, Boolean insertYN) {
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = accID;
        opp.StageName = 'Technical Validation';
        opp.Forecast_Status__c = 'Pipeline';
        opp.Amount = 100;
        opp.CloseDate = System.today() + 30;

        if(insertYN) {insert opp;}

        return opp;
    }

    public static OpportunityLineItem createOpportunityLineItem(Id oppID, Id pbEntryID, Decimal price, Boolean insertYN) {
        OpportunityLineItem oppLine = new OpportunityLineItem();
        oppLine.OpportunityId = oppID;
        oppLine.PricebookEntryId = pbEntryID;
        oppLine.Forecasted_New_Amount__c = price;
        oppLine.Software_Type__c = 'Subscription';
        oppLine.Months__c = 12;


        if(insertYN) {insert oppLine;}

        return oppLine;
    }

    public static void createCompanyCode(Boolean insertYN) {
        Company_Code__c cc = new Company_Code__c();
        cc.Code__c = 'US46';
        cc.Country__c = 'US';
        cc.City__c = 'Seattle';
        cc.Currency_Picklist__c = 'USD';

        if(insertYN) {insert cc;}
    }

    public static Product2 createProduct2(Boolean insertYN) {
        Product2 prod = new Product2();
        prod.Name = 'Test Product';
        prod.IsActive = true;
        prod.ProductCode = 'PCF';
        prod.Report_Category__c = 'PaaS';
        prod.ProductCode = 'SSS-0000';

        if(insertYN) {insert prod;}

        return prod;
    }

    public static Pricebook2 createPricebook2(Boolean insertYN) {
        Pricebook2 pbk = new Pricebook2();
        pbk.Name = 'Test Pricebook';
        pbk.IsActive = true;

        if(insertYN) {insert pbk;}

        return pbk;
    }

    public static PricebookEntry createPricebookEntry(Id prodID, Decimal price, Boolean insertYN) {
        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.Product2Id = prodID;
        pbEntry.UnitPrice = price;
        pbEntry.IsActive = true;
        pbEntry.Pricebook2Id = Test.getStandardPricebookId();

        if(insertYN) {insert pbEntry;}

        return pbEntry;
    }

    public static Task createTask(Id leadId, Boolean insertYN) {
        Task taskObj = new Task();
        taskObj.whoId = leadId;
        taskObj.Subject = 'Send Email to User';
        taskObj.Status = 'New';
        taskObj.Priority = 'Normal';
        taskObj.Type = 'Phone Call';

        if(insertYN) {insert taskObj;}

        return taskObj;
    }

    public static Profile createProfile(String profileName) {
        return [SELECT Id FROM Profile WHERE Name = :profileName];
    }

    public static User createUser(Id profileId, Boolean insertYN) {
        User u = new User();
        u.Alias = 'standt';
        u.Email='standarduser@testorg.com';
        u.EmailEncodingKey='UTF-8';
        u.LastName='Testing';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        u.ProfileId = profileId;
        u.TimeZoneSidKey='America/Los_Angeles';
        u.UserName='UnitTestUser' + Math.round(Math.random()*1000) + '@testorg.com';
        u.Theater__c = 'AMER';
        u.Region__c = 'Pacific NorthWest';

        if(insertYN) {insert u;}

        return u;
    }

    public static UserRole createUserRole(String userRoleName) {
        insertUserRole(userRoleName);
        return [SELECT Id, Name FROM UserRole WHERE Name = :userRoleName];
    }

    public static Lead createLead(Boolean insertYN) {
        Lead ld = new Lead();
        ld.Company = 'Fancy Company';
        ld.Email = 'Fancy@email.com';
        ld.FirstName = 'Lead';
        ld.LastName = 'Lady';

        if(insertYN) {insert ld;}

        return ld;
    }

    public static Country_Uplift__c createCountryUplift(String countryCode,
                                                        Decimal productMultipler,
                                                        Decimal serviceMultipler,
                                                        Boolean insertYN) {
        Country_Uplift__c countryUplift = new Country_Uplift__c();
        countryUplift.name = 'Test + ' + countryCode;
        countryUplift.Country_Code__c = countryCode;
        countryUplift.Uplift_Multiplier__c = productMultipler;
        countryUplift.Service_Multiplier__c = serviceMultipler;
        if (insertYN) { insert countryUplift; }

        return countryUplift;
    }

    public static void createCategoryType(String name, String type) {
        CategoryType__c categoryType = new CategoryType__c();
        categoryType.Name = name;
        categoryType.Type__c = type;
        insert categoryType;
    }

    @future
    private static void insertUserRole(String userRoleName) {
        UserRole userRoleObj = new UserRole();
        userRoleObj.Name = userRoleName;
        insert userRoleObj;
    }

    @future
    public static void assignUserRole(Id userId, Id roleId) {
        User u = new User();
        u.Id = userId;
        u.UserRoleId = roleId;
        update u;
    }

    public static CNS_Region__c createCNSRegion(Id userId, String Region) {
        CNS_Region__c cnsRegion = new CNS_Region__c();
        cnsRegion.Region__c = Region;
        cnsRegion.CNS_Rep__C = userId;

        insert cnsRegion;

        return cnsRegion;
    }
    public static zqu__ZProduct__c creatZProduct(String name, String sku,Boolean insertYN)
    {
        zqu__ZProduct__c testProduct = new zqu__ZProduct__c();
        testProduct.Name = name;
        testProduct.zqu__SKU__c = sku;
        testProduct.zqu__ZuoraId__c = '12345';
        testProduct.zqu__EffectiveStartDate__c = date.newinstance(2000, 1, 1);
        testProduct.zqu__EffectiveEndDate__c = date.newinstance(2050, 1, 1);
        testProduct.zqu__Deleted__c = false;
        if(insertYN) {
            insert testProduct;
        }

        return testProduct;
    }

    private static integer ratePlanId = 154657;

    public static zqu__ProductRatePlan__c createProductRatePlan(zqu__ZProduct__c zproduct, String name,Boolean insertYN)
    {
        zqu__ProductRatePlan__c testrp = new zqu__ProductRatePlan__c();
        testrp.name = 'test rp';
        testrp.zqu__ZProduct__c = zproduct.Id;
        testrp.zqu__ZuoraId__c = 'abc21335';
        testrp.zqu__Deleted__c = false;
        //set custom fields

        //Needed for pricing queries
        testrp.zqu__EffectiveStartDate__c = Date.newInstance(2010, 1, 1);
        testrp.zqu__EffectiveEndDate__c = Date.newInstance(2020, 1, 1);
        if(insertYN) {
            insert testrp;
        }
        return testrp;
    }
    public static zqu__ProductRatePlanCharge__c createProductRatePlanCharge(zqu__ProductRatePlan__c prp, String type, String model,Boolean insertYN)
    {
        zqu__ProductRatePlanCharge__c testprpc = new zqu__ProductRatePlanCharge__c();
        testprpc.zqu__ProductRatePlan__c = prp.Id;
        testprpc.name=type + model;
        testprpc.zqu__ZuoraId__c = '23424567';
        testprpc.zqu__UOM__c = 'test UOM';
        testprpc.zqu__Type__c = type;
        testprpc.zqu__RecurringPeriod__c = 'Month';
        testprpc.zqu__PrepaymentPeriods__c = 1;
        testprpc.zqu__Model__c = model;
        testprpc.zqu__MinQuantity__c = 0;
        testprpc.zqu__MaxQuantity__c = 1000;
        testprpc.zqu__ListPrice__c = 5;
        testprpc.zqu__Description__c = 'Test charge';
        testprpc.zqu__DefaultQuantity__c = 5;
        testprpc.zqu__Discount_Apply_Type__c = 0;
        testprpc.zqu__Discount_Level__c = 'RatePlan';
        testprpc.zqu__Upto_How_Many_Periods__c = 0;
        testprpc.zqu__Deleted__c = false;
        //testprpc.SubQuote__c = type == 'Usage' ? 'True' : 'False';
        if(insertYN) {
            insert testprpc;
        }
        return testprpc;
    }

    private static integer tierId = 0;

    public static zqu__ProductRatePlanChargeTier__c makeProductRatePlanChargeTier(Id prpc,Boolean insertYN)
    {
        zqu__ProductRatePlanChargeTier__c testprpct = new zqu__ProductRatePlanChargeTier__c();

        //testprpct.Name = 'Test tier';
        testprpct.zqu__Currency__c = 'USD';
        testprpct.zqu__Deleted__c = false;
        testprpct.zqu__StartingUnit__c = 0;
        //testprpct.zqu__EndingUnit__c = 100;//Leave null to have this tier be for all quantities
        testprpct.zqu__IsOveragePrice__c = false;
        testprpct.zqu__ProductRatePlanCharge__c = prpc;
        //testprpct.zqu__ProductRatePlanChargeId__c = '123';//?
        testprpct.zqu__Tier__c = 1;
        testprpct.zqu__ZuoraId__c = '1232342';
        tierId++;
        testprpct.zqu__Price__c = 100;
        testprpct.zqu__PriceFormat__c = 'Per Unit';
        if(insertYN) {
            insert testprpct;
        }
        return testprpct;
    }
    public static zqu__Quote__c makeQuote(Opportunity testOpp, Contact ctct) {

        zqu__Quote__c testQuote = new zqu__Quote__c();

        testQuote.Name = 'my test quote';

        testQuote.zqu__Opportunity__c = testOpp.Id;
        testQuote.zqu__Currency__c = 'USD';
        testQuote.zqu__Hidden_Subscription_Name__c = 'Boo';
        testQuote.zqu__Status__c = 'New';
        testquote.Primary_Quote__c = true;
        testQuote.zqu__SubscriptionTermStartDate__c = Date.today();
        testQuote.zqu__StartDate__c = Date.today();
        testQuote.zqu__InitialTerm__c = 12;
        testQuote.zqu__RenewalTerm__c = 12;
        testQuote.zqu__SubscriptionTermEndDate__c = Date.today().addMonths(12);
        testQuote.zqu__SubscriptionType__c ='New Subscription';
        testQuote.zqu__BillToContact__c = ctct.Id;
        testQuote.zqu__SoldToContact__c = ctct.Id;
        testquote.Ship_To_First_Name__c = 'Test';
        testquote.Ship_To_Last_Name__c = 'Test';
        testQuote.Ship_To_Email__c = 'testemail@zuora.com';
        testQuote.Ship_Contact_Email__c = 'realEmail@zuora.com';
        testQuote.Document_Type__c = 'Default';

        insert testQuote;
        return testQuote;
    }

    public static zqu__QuoteRatePlan__c makeQuoteRatePlan(zqu__Quote__c quote, zqu__QuoteAmendment__c qAmendment){

        zqu__QuoteRatePlan__c testQRP = new zqu__QuoteRatePlan__c();
        testQRP.Name = 'my test quote rate plan';
        testQRP.zqu__Quote__c = quote.Id;
        testQRP.zqu__AmendmentType__c = 'NewProduct';
        testQRP.zqu__QuoteProductName__c = 'Pivotal App Suite v2';
        testQRP.zqu__QuoteAmendment__c = qAmendment.Id;
        testQRP.zqu__ProductRatePlanZuoraId__c = '2eadfcd';

        insert testQRP;
        return testQRP;
    }
    
    public static zqu__ZProduct__c makeProduct(String name, String sku)
    {
        zqu__ZProduct__c testProduct = new zqu__ZProduct__c();
        testProduct.Name = name;
        testProduct.zqu__SKU__c = sku;
        testProduct.zqu__ZuoraId__c = getUniqueObjectId();
        testProduct.zqu__EffectiveStartDate__c = date.newinstance(2000, 1, 1);
        testProduct.zqu__EffectiveEndDate__c = date.newinstance(2050, 1, 1);
        testProduct.zqu__Deleted__c = false;
        //testProduct.Requires_VMW_Fulfillment__c = requiresVmvFulfillment;

        insert testProduct;
        return testProduct;
    }
    private static integer ratePlanIdVar = 154657;

    public static zqu__ProductRatePlan__c makeProductRatePlan(String zproduct, String name)
    {
        return makeProductRatePlan(zproduct, name, null);
    }

    public static zqu__ProductRatePlan__c makeProductRatePlan(String zproduct, String name, String prodId)
    {
        zqu__ProductRatePlan__c testrp = new zqu__ProductRatePlan__c();
        testrp.name = 'test rp';
        testrp.zqu__ZProduct__c = zproduct;
        testrp.zqu__ZuoraId__c = '2eadfcd';
        testrp.zqu__Product__c = prodId;
        testrp.zqu__Deleted__c = false;
        //set custom fields 

        //Needed for pricing queries
        testrp.zqu__EffectiveStartDate__c = Date.newInstance(2010, 1, 1);
        testrp.zqu__EffectiveEndDate__c = Date.newInstance(2020, 1, 1);

        insert testrp;
        return testrp;
    }
    public static zqu__ProductRatePlan__c makeProductRatePlan(Id zproduct, String name, Id prodId)
    {
        zqu__ProductRatePlan__c testrp = new zqu__ProductRatePlan__c();
        testrp.name = 'test rp';
        testrp.zqu__ZProduct__c = zproduct;
        testrp.zqu__ZuoraId__c = '2eadfcd';
        testrp.zqu__Product__c = prodId;
        testrp.zqu__Deleted__c = false;
        //set custom fields

        //Needed for pricing queries
        testrp.zqu__EffectiveStartDate__c = Date.newInstance(2010, 1, 1);
        testrp.zqu__EffectiveEndDate__c = Date.newInstance(2020, 1, 1);

        insert testrp;
        return testrp;
    }

    public static zqu__ProductRatePlanCharge__c makeProductRatePlanCharge(String prp, String type, String model)
    {
        zqu__ProductRatePlanCharge__c testprpc = new zqu__ProductRatePlanCharge__c();
        testprpc.zqu__ProductRatePlan__c = prp;
        testprpc.name=type + model;
        testprpc.zqu__ZuoraId__c = getUniqueObjectId();
        testprpc.zqu__UOM__c = 'test UOM';
        testprpc.zqu__Type__c = type;
        testprpc.zqu__RecurringPeriod__c = 'Month';
        testprpc.zqu__PrepaymentPeriods__c = 1;
        testprpc.zqu__Model__c = model;
        testprpc.zqu__MinQuantity__c = 0;
        testprpc.zqu__MaxQuantity__c = 1000;
        testprpc.zqu__ListPrice__c = 5;
        testprpc.zqu__Description__c = 'Test charge';
        testprpc.zqu__DefaultQuantity__c = 5;
        testprpc.zqu__Discount_Apply_Type__c = 0;
        testprpc.zqu__Discount_Level__c = 'RatePlan';
        testprpc.zqu__Upto_How_Many_Periods__c = 0;
        testprpc.zqu__Deleted__c = false;

        insert testprpc;
        return testprpc;
    }
    public static String getUniqueObjectId() {
        if(uniqueObjectId == null){
          uniqueObjectId = '1';
        } else {
          uniqueObjectId = '' + (Integer.valueOf(uniqueObjectId) + 1);
        }
        return uniqueObjectId;
    }
    public static String uniqueObjectId = '1';

    public static Zuora__ZInvoice__c createZInvoice(Boolean shouldInsert, Id billingAccountId, Date dueDate, Decimal balance2, Decimal totalAmount) {
        Zuora__ZInvoice__c invoice = new Zuora__ZInvoice__c();

        invoice.Zuora__BillingAccount__c = billingAccountId;
        invoice.Zuora__DueDate__c = dueDate;
        invoice.Zuora__Balance2__c = balance2;
        invoice.Zuora__TotalAmount__c = totalAmount;

        if (shouldInsert) {
            insert invoice;
        }

        return invoice;
    }
}