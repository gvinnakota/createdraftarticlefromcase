@isTest
public class LeadsDuplicateRules_Test {
	static testMethod void testMatchingData_shouldBeDuplicate() {
		Lead lead1 = leadWithData('Fancy Company', 'lead@example.com', 'Sara', 'Salesperson');
		Lead lead2 = leadWithData('Fancy Company', 'lead@example.com', 'Sara', 'Salesperson');

		assertDuplicateRecordFound(lead1, lead2);
	}

	static testMethod void testDifferentCompany_shouldNotBeDuplicate() {
		Lead lead1 = leadWithData('Crummy Company', 'lead@example.com', 'Sara', 'Salesperson');
		Lead lead2 = leadWithData('Fancy Company', 'lead@example.com', 'Sara', 'Salesperson');

		assertNoDuplicateRecordFound(lead1, lead2);
	}

	static testMethod void testDifferentEmail_shouldNotBeDuplicate() {
		Lead lead1 = leadWithData('Fancy Company', 'Dump@example.com', 'Sara', 'Salesperson');
		Lead lead2 = leadWithData('Fancy Company', 'lead@example.com', 'Sara', 'Salesperson');

		assertNoDuplicateRecordFound(lead1, lead2);
	}

	static testMethod void testDifferentFirstName_shouldNotBeDuplicate() {
		Lead lead1 = leadWithData('Fancy Company', 'lead@example.com', 'Lead', 'Salesperson');
		Lead lead2 = leadWithData('Fancy Company', 'lead@example.com', 'Sara', 'Salesperson');

		assertNoDuplicateRecordFound(lead1, lead2);
	}

	static testMethod void testDifferentLastName_shouldNotBeDuplicate() {
		Lead lead1 = leadWithData('Fancy Company', 'lead@example.com', 'Sara', 'LeadPerston');
		Lead lead2 = leadWithData('Fancy Company', 'lead@example.com', 'Sara', 'Salesperson');

		assertNoDuplicateRecordFound(lead1, lead2);
	}

	private static Lead leadWithData(String company, String email, String firstName, String lastName) {
		Lead ld = TestDataFactory.createLead(false);
		ld.Company = company;
		ld.Email = email;
		ld.FirstName = firstName;
		ld.LastName = lastName;
		return ld;
	}

	private static void assertDuplicateRecordFound(Lead lead1, Lead lead2) {
		insert lead1;
		try {
			insert lead2;
			System.assert(false, 'Did not detect duplicate lead.');
		} catch(DmlException ex) {
			//Passing case
		}
	}

	private static void assertNoDuplicateRecordFound(Lead lead1, Lead lead2) {
		insert lead1;
		try {
			insert lead2;
		} catch(DmlException ex) {
			System.assert(false, 'Detected duplicate lead incorrectly.');
		}
	}
}