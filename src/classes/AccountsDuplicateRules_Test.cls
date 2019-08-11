@isTest
public class AccountsDuplicateRules_Test {

	static testMethod void testMatchingNameAndZIP_shouldBeDuplicate() {
		Account acc1 = accountWithNameAndZIP('Fancy Account Name', '94103');
		Account acc2 = accountWithNameAndZIP('Fancy Account Name', '94103');

		assertDuplicateRecordFound(acc1, acc2);
	}

	static testMethod void testMatchingNameAndDifferentZIP_shouldNotBeDuplicate() {
		Account acc1 = accountWithNameAndZIP('Fancy Account Name', '94103');
		Account acc2 = accountWithNameAndZIP('Fancy Account Name', '58503');

		assertNoDuplicateRecordFound(acc1, acc2);
	}

	static testMethod void testMatchingZIPAndDifferentName_shouldNotBeDuplicate() {
		Account acc1 = accountWithNameAndZIP('Boring Account Name', '58503');
		Account acc2 = accountWithNameAndZIP('Fancy Account Name', '58503');

		assertNoDuplicateRecordFound(acc1, acc2);
	}

	static testMethod void testFuzzyMatchingNameAndZIP_shouldBeDuplicate() {
		Account acc1 = accountWithNameAndZIP('Fancy Account Name', '94103');
		Account acc2 = accountWithNameAndZIP('Fancy Account Name, Inc.', '94103-1234');

		assertDuplicateRecordFound(acc1, acc2);
	}

	private static Account accountWithNameAndZIP(String name, String zip) {
		Account account = TestDataFactory.createAccount(false);
		account.name = name;
		account.billingPostalCode = zip;
		return account;
	}

	private static void assertDuplicateRecordFound(Account acc1, Account acc2) {
		insert acc1;
		try {
			insert acc2;
			System.assert(false, 'Did not detect duplicate account.');
		} catch(DmlException ex) {
			//Passing case
		}
	}

	private static void assertNoDuplicateRecordFound(Account acc1, Account acc2) {
		insert acc1;
		try {
			insert acc2;
		} catch(DmlException ex) {
			System.assert(false, 'Detected duplicate account incorrectly.');
		}
	}
}