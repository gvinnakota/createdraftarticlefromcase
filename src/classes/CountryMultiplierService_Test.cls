@isTest
public class CountryMultiplierService_Test {
    static testMethod void whenProvidingCountryUpliftValue_calculatesCorrectlyUS() {
         TestDataUtil.dataValueMapCSData();
        Account acc = TestDataFactory.createAccount(true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);
        Country_Uplift__c usMultiplier = TestDataFactory.createCountryUplift('US', 1.0, 10.0, true);
      
        Contact us_ctt = TestDataFactory.createContact(acc.Id, true);
       

        zqu__Quote__c us_quote = ZTestFactory.makeQuote(opp, us_ctt);
        us_quote.Channel__c = 'Pivotal Direct';
        update us_quote;

        

        CountryMultiplierService service = new CountryMultiplierService();

        CountryMultiplierInfo usMultipliers = service.countryMultipliers(us_quote);
      

        System.assertEquals(1, usMultipliers.ProductMultiplier, 'US product multiplier <> 1');
        System.assertEquals(10, usMultipliers.ServiceMultiplier, 'US service multiplier <> 10');

       
    }
    
     static testMethod void whenProvidingCountryUpliftValue_calculatesCorrectlyCN() {
          TestDataUtil.dataValueMapCSData();
        Account acc = TestDataFactory.createAccount(true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);
        Country_Uplift__c cnMultiplier = TestDataFactory.createCountryUplift('CN', 2.0, 20.0, true);

      
        Contact china_ctt = TestDataFactory.createContact(acc.Id, false);
        china_ctt.MailingCountry = 'China';
        china_ctt.MailingCountryCode = 'CN';
        china_ctt.MailingState = 'Beijing';
        china_ctt.MailingStateCode = '11';
        insert china_ctt;

 

        zqu__Quote__c china_quote = ZTestFactory.makeQuote(opp, china_ctt);
        china_quote.Channel__c = 'Pivotal Direct';
        update china_quote;

        CountryMultiplierService service = new CountryMultiplierService();

        CountryMultiplierInfo chinaMultipliers = service.countryMultipliers(china_quote);
       

     

        System.assertEquals(2, chinaMultipliers.ProductMultiplier, 'CN product multiplier <> 2');
        System.assertEquals(20, chinaMultipliers.ServiceMultiplier, 'CN service multiplier<> 20');
    }
    

    static testMethod void shouldChooseTheCorrectUpliftMultiplier() {
         TestDataUtil.dataValueMapCSData();
        CountryMultiplierService service = new CountryMultiplierService();
        CountryMultiplierInfo multiplierInfo = new CountryMultiplierInfo(2.0, 4.0);

        TestDataFactory.createCategoryType('Resell', 'Product');
        TestDataFactory.createCategoryType('Ed Services', 'Service');

        System.assertEquals(2.0, service.multiplier('Resell', multiplierInfo));
        System.assertEquals(4.0, service.multiplier('Ed Services', multiplierInfo));
    }

    static testMethod void whenAMissingProductServiceCategoryIsProvided_shouldThrowException() {
         TestDataUtil.dataValueMapCSData();
        CountryMultiplierService service = new CountryMultiplierService();
        CountryMultiplierInfo multiplierInfo = new CountryMultiplierInfo(2.0, 4.0);

        try {
            service.multiplier('Pastrami', multiplierInfo);
            System.assert(false, 'Did not catch invalid case');
        } catch(Exception ex) {}
    }

    static testMethod void countryMultiplierInfo_whenChannelIsNotDirectOrFederation_returnsOneForServices() {
         TestDataUtil.dataValueMapCSData();
        Account acc = TestDataFactory.createAccount(true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);
        Country_Uplift__c cnMultiplier = TestDataFactory.createCountryUplift('CN', 2.0, 20.0, true);

        Contact china_ctt = TestDataFactory.createContact(acc.Id, false);
        china_ctt.MailingCountry = 'China';
        china_ctt.MailingCountryCode = 'CN';
        china_ctt.MailingState = 'Beijing';
        china_ctt.MailingStateCode = '11';
        insert china_ctt;

        zqu__Quote__c direct_china_quote = ZTestFactory.makeQuote(opp, china_ctt);
        direct_china_quote.Channel__c = 'Pivotal Direct';
        update direct_china_quote;

        zqu__Quote__c indirect_china_quote = ZTestFactory.makeQuote(opp, china_ctt);
        indirect_china_quote.Channel__c = 'EMC-IE';
        update indirect_china_quote;

        CountryMultiplierService service = new CountryMultiplierService();

        CountryMultiplierInfo directChinaMultipliers = service.countryMultipliers(direct_china_quote);
        CountryMultiplierInfo indirectChinaMultipliers = service.countryMultipliers(indirect_china_quote);

        System.assertEquals(2, directChinaMultipliers.ProductMultiplier, 'CN product multiplier <> 2');
        System.assertEquals(20, directChinaMultipliers.ServiceMultiplier, 'CN service multiplier<> 20');

        System.assertEquals(2, indirectChinaMultipliers.ProductMultiplier, 'CN product multiplier <> 2');
        System.assertEquals(1, indirectChinaMultipliers.ServiceMultiplier, 'Service multiplier should equal product multiplier when order is not direct or federation');
    }

    @isTest(SeeAllData = true)
    static void allProductCategoryTypesShouldHaveACategoryTypeRecord() {
        Schema.DescribeFieldResult fieldResult = zqu__ZProduct__c.ProductServiceCategory__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistEntries) {
            CategoryType__c categoryType = CategoryType__c.getInstance(entry.getValue());
            System.assertNotEquals(null, categoryType, 'The zqu__ZProduct__c.ProductServiceCategory__C picklist value ' + entry.getValue() + ' was not found in the Category Type Custom Setting. If ' + entry.getValue() + ' is a valid picklist value, please add it to the Category Type Custom Setting');
        }
    }
}