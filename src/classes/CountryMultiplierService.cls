public with sharing class CountryMultiplierService {
    public CountryMultiplierService() {}

    public CountryMultiplierInfo countryMultipliers(Zqu__Quote__c quote) {
        Decimal productMultiplier;
        Decimal serviceMultiplier;

        Id soldToContactId = quote.zqu__SoldToContact__c;
        Contact soldToContact = [SELECT Id,
                MailingCountryCode
        FROM Contact
        WHERE Id = :soldToContactId];

        String country = soldToContact.MailingCountryCode;

        List<Country_Uplift__c> countryUplifts = [SELECT Country_Code__c,
                Uplift_Multiplier__c,
                Service_Multiplier__c
        FROM Country_Uplift__c
        WHERE Country_Code__c = :country];

        productMultiplier = 1;
        productMultiplier.setScale(2);

        serviceMultiplier = 1;
        serviceMultiplier.setScale(2);

        if (countryUplifts.size() > 0) {
            Country_Uplift__c countryUplift = countryUplifts.get(0);
            productMultiplier = countryUplift.Uplift_Multiplier__c;
            serviceMultiplier = countryUplift.Service_Multiplier__c;

            if (quote.Channel__c != 'Pivotal Direct' && quote.Channel__c != 'Federation') {
                serviceMultiplier = 1;
            }
        }

        return new CountryMultiplierInfo(productMultiplier, serviceMultiplier);
    }

    public Decimal multiplier(String productServiceCategory, CountryMultiplierInfo multiplierInfo) {
        CategoryType__c categoryType = CategoryType__c.getInstance(productServiceCategory);

        if(categoryType == null) {
            throw new CountryMultiplierServiceException('Category Type of ' + productServiceCategory + ' not found in the Category Type Custom Setting');
        } else if (categoryType.Type__c == 'Service') {
            return multiplierInfo.ServiceMultiplier;
        } else {
            return multiplierInfo.ProductMultiplier;
        }
    }

    public class CountryMultiplierServiceException extends Exception {}
}