public with sharing class ChargeService {
    public ChargeService() {
    }

    public Decimal calculateListPrice(Decimal basePrice, Decimal countryMultiplier, Double conversionRate) {
        return basePrice * countryMultiplier * conversionRate;
    }

    public class ChargeServiceException extends Exception {
    }
}