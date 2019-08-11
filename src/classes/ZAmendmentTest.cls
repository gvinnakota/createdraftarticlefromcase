@isTest(SeeAllData=true)
public class ZAmendmentTest {
    
    @isTest static void test_method_one() {
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);

        Map<String, zqu__ProductRatePlan__c> prpMap = ZTestFactory.makePivotalProductCatalog();
        zqu__ProductRatePlan__c prepaidRatePlan = prpMap.get('Prepaid');
        prepaidRatePlan.zqu__ZuoraId__c = 'adgadfgakhj';
        update prepaidRatePlan;
        zqu__ProductRatePlanCharge__c prpc = [SELECT id from zqu__ProductRatePlanCharge__c where zqu__ProductRatePlan__c = :prepaidRatePlan.Id];


        zqu__Quote__c quote = ZTestFactory.makeAmendmentQuote(opp);
        zqu__QuoteAmendment__c quoteAmendment = ZTestFactory.makeQuoteAmendment(quote);
        zqu__QuoteRatePlan__c quoteRatePlan = ZTestFactory.makeQuoteRatePlan(quote, quoteAmendment);
        quoteRatePlan.zqu__ProductRatePlanZuoraId__c = 'adgadfgakhj';
        update quoteRatePlan;

        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
        zqu__QuoteChargeSummary__c quoteChargeSummary = ZTestFactory.makeQuoteChargeSummary(quoteRatePlan, quoteRatePlanCharge);

        quote.zqu__Status__c = 'Sent to Z-Billing';
        quote.zqu__ExistSubscriptionID__c = 'adgw0s8dgfs';
        update quote; 

        zqu__Quote__c quote1 = ZTestFactory.makeQuote(opp, contact);
        zqu__QuoteAmendment__c quoteAmendment1 = ZTestFactory.makeQuoteAmendment(quote1);
        zqu__QuoteRatePlan__c quoteRatePlan1 = ZTestFactory.makeQuoteRatePlan(quote1, quoteAmendment);
        quoteRatePlan1.zqu__ProductRatePlanZuoraId__c = 'adgadfgakhj';
        update quoteRatePlan1;

        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge1 = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan1, prpc);
        zqu__QuoteChargeSummary__c quoteChargeSummary1 = ZTestFactory.makeQuoteChargeSummary(quoteRatePlan1, quoteRatePlanCharge1);

        quote1.zqu__Status__c = 'Sent to Z-Billing';
        quote1.zqu__ExistSubscriptionID__c = 'adgw0s8dgfs';
        update quote1;

    }

    public static List < Zuora.zObject > dummyQueryResults() {
        List<Zuora.zObject> result = new List<Zuora.zObject >();
        Zuora.zObject obj = new Zuora.zObject('Subscription');
        obj.setValue('Id', 'asdgadfg');
        obj.setValue('OriginalId', 'asdgadfg');
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