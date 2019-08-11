public with sharing class CountryMultiplierInfo {
    public Decimal ProductMultiplier {get; private set;}
    public Decimal ServiceMultiplier {get; private set;}

    public CountryMultiplierInfo(Decimal productMultiplierValue, Decimal serviceMultiplierValue) {
        ProductMultiplier = productMultiplierValue;
        ServiceMultiplier = serviceMultiplierValue;
    }
}