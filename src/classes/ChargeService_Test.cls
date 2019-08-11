@isTest
public class ChargeService_Test {
	static testMethod void whenCalculatingListPrice_shouldApplyCountryMultiplierAndConversionRate() {
		Decimal basePrice = 100.0;
		Decimal countryMultiplier = 2.0;
		Double conversionRate = 5;

		ChargeService service = new ChargeService();
		Decimal listPrice = service.calculateListPrice(basePrice, countryMultiplier, conversionRate);

		System.assertEquals(1000.0, listPrice, 'List price is WRONG!');
	}
}