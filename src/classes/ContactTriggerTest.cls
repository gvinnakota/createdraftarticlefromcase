@isTest(SeeAllData=true)
public class ContactTriggerTest {
	
	@isTest static void test_method_one() {
		Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);

        contact.LastName = 'Bla'; 
        update contact;

	}

	public static List < Zuora.zObject > dummyQueryResults() {
    	List<Zuora.zObject> result = new List<Zuora.zObject >();
    	Zuora.zObject obj = new Zuora.zObject('Account');
    	obj.setValue('Id', 'asdgadfg');
    	obj.setValue('SoldToId', 'asdgadfg');
    	obj.setValue('BillToId', 'asdgadfg');
    	result.add(obj);
    	return result;
    }

    public static List<Zuora.zApi.SaveResult> dummySaveResults() {
    	List<Zuora.zApi.SaveResult> result = new List<Zuora.zApi.SaveResult>();
    	Zuora.zApi.SaveResult obj = new Zuora.zApi.SaveResult();
    	obj.id = 'dafhasdgkj';
    	obj.success = false;
    	Zuora.zObject error = new Zuora.zObject('Error');
    	error.setValue('Code', 'Error code');
    	error.setValue('Message', 'Error message');
    	List<Zuora.zObject> errorList = new List<Zuora.zObject>();
    	errorList.add(error);
    	obj.errors = errorList;
    	result.add(obj);
    	return result;
    }
	
	
}