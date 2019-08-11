public with sharing class QRPCPriceMultiplier {
    public Decimal conversionRate;
    public Decimal countryMultiplier;
    public String serviceCategory;
    String countryCode;
    String currencyCode;
    Decimal basePrice;
    Decimal calculatedPrice;
    Boolean ignoreCountryMultiplier;

    public QRPCPriceMultiplier withBasePrice(Decimal basePrice) {
        this.basePrice = basePrice;
        return this;
    }

    public QRPCPriceMultiplier withCountryCode(String countryCode) {
        this.countryCode = countryCode;
        return this;
    }

    public QRPCPriceMultiplier withCurrencyCode(String currencyCode) {
        this.currencyCode = currencyCode;
        return this;
    }

    public QRPCPriceMultiplier withIgnoreCountryMultiplier(Boolean ignoreCountryMultiplier) {
        this.ignoreCountryMultiplier = ignoreCountryMultiplier;
        return this;
    }

    public Decimal calculatePrice() {
        calculatedPrice = basePrice;
        if (!ignoreCountryMultiplier) {
            multiplyWith(countryMultiplier);
        }
        multiplyWith(conversionRate);
        return calculatedPrice;
    }

    private Decimal multiplyWith(Decimal multiplier) {
        if (null != multiplier) {
            calculatedPrice *= multiplier;
        }
        return calculatedPrice;
    }
}