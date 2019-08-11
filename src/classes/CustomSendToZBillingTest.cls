@isTest(SeeAllData=true)
public class CustomSendToZBillingTest {
    
    @isTest static void test_SubQuoteAlreadyExist(){
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact);
        zqu__Quote__c subquote = ZTestFactory.makeQuote(opp, contact);
        subquote.Split_Parent_Quote__c = quote.id;
        update subquote;

        Test.startTest();
        SendToZbillingWithSplitQuotes.quoteSplit(quote.id, null);   
    }

    @isTest static void test_ZuoraErrors(){
        List<Zuora.zObject> errors = new List<Zuora.zObject>();

        Zuora.zObject error = new Zuora.zObject('Error');
        error.setValue('Code', 'errorcode');
        error.setValue('Message', 'Opps, we got an error.');
        errors.add(error);

        Test.startTest();
        SendToZbillingWithSplitQuotes.parseZuoraError(errors);

      //for (Zuora.zObject error : errors) {
      //  String errorCode = (String)error.getValue('Code');
      //  message = (String)error.getValue('Message');
      //  //more code here...
      //}
    }

    @isTest static void test_Initilize_CustomSendToZBillingTest() {
        
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact);
        buildQuote(quote);
        quote.Company_Code1__c = 'US46';
        quote.zqu__PaymentMethod__c = 'Check';
        quote.zqu__ZuoraAccountID__c = 'asdgfaddaga';
        quote.zqu__ZuoraSubscriptionID__c = '245nk334lk5h34';
        quote.state__c = 'New';
        quote.certificate_Id1__c = 'DUMMY CERT ID';
        quote.zqu__BillingMethod__c = 'Email';

        update quote;
        Test.startTest();

         ApexPages.StandardController con = new ApexPages.StandardController(quote);
         CustomSendToZBilling castzb = new CustomSendToZBilling(con);
         castzb.checkOnLoad();
         
         Boolean testBoolean = castzb.readyToSend;
         List < String > testList = castzb.listofQuoteIds;
         Boolean testBoolean2 = castzb.showExistingCharges;
         List < zqu__Quote__c > testList3 = castzb.ListofSubQuotes;
         //List < zqu.zChargeGroup > testList4 = castzb.existingSeparateChargeGroups;
         //List < zqu__QuoteRatePlanCharge__c > testList9 = castzb.existingQuoteCharges;

        try {
            castzb.checkOnLoad();
            castzb.callQuoteSplit();
        } catch(Exception ex) {

        }

        SendToZbillingWithSplitQuotes.sendQuote(String.valueOf(quote.id), quote, new List<String> {'id1'});

    }
    
    @isTest static void test_Method_One() {
        
        Map<String, List < zqu.zChargeGroup>> testMap = new Map<String, List < zqu.zChargeGroup>> ();
        
        //setup test data
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote1 = ZTestFactory.makeQuote(opp, contact);
        buildQuote(quote1);
        quote1.Company_Code1__c = 'US46';
        quote1.zqu__PaymentMethod__c = 'Check';
        quote1.zqu__ZuoraAccountID__c = 'asdgfaddaga';
        quote1.zqu__ZuoraSubscriptionID__c = '245nk334lk5h34';
        update quote1;
        
        Test.StartTest();
        PageReference pageRef = Page.CustomSendToZBilling;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('id', quote1.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController con = new ApexPages.StandardController(quote1);
        CustomSendToZBilling castzb = new CustomSendToZBilling(con);

        SendToZbillingWithSplitQuotes.sendQuote(String.valueOf(quote1.id), quote1, new List<String> {'id1'});

    }

    @isTest static void test_Method_Two() {
        
        Map<String, List < zqu.zChargeGroup>> testMap = new Map<String, List < zqu.zChargeGroup>> ();
        
        //setup test data
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote1 = ZTestFactory.makeQuote(opp, contact);
        buildQuote(quote1);
        quote1.Company_Code1__c = 'US46';
        quote1.zqu__PaymentMethod__c = 'Check';
        quote1.zqu__ZuoraSubscriptionID__c = '245nk334lk5h34';
        update quote1;
        
        Test.StartTest();
        PageReference pageRef = Page.CustomSendToZBilling;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('id', quote1.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController con = new ApexPages.StandardController(quote1);
        CustomSendToZBilling castzb = new CustomSendToZBilling(con);
        //SendToZbillingWithSplitQuotes.cloneQuote((String)quote.Id, '');

        quote1.Error_Message__c = 'SubQuotes already exist for this Quote';
        quote1.state__c = 'New';
        update quote1;

        castzb.checkOnLoad();        
    }

    @isTest static void test_Method_Three() {
        
        Map<String, List < zqu.zChargeGroup>> testMap = new Map<String, List < zqu.zChargeGroup>> ();
        
        //setup test data
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote1 = ZTestFactory.makeQuote(opp, contact);
        buildQuote(quote1);
        quote1.Company_Code1__c = 'US46';
        quote1.zqu__PaymentMethod__c = 'Check';
        quote1.zqu__ZuoraSubscriptionID__c = '245nk334lk5h34';
        update quote1;
        
        Test.StartTest();
        PageReference pageRef = Page.CustomSendToZBilling;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('id', quote1.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController con = new ApexPages.StandardController(quote1);
        CustomSendToZBilling castzb = new CustomSendToZBilling(con);
        //SendToZbillingWithSplitQuotes.cloneQuote((String)quote.Id, '');

        quote1.Error_Message__c = 'Quote has already been sent';
        quote1.state__c = 'New';
        update quote1;

        castzb.checkOnLoad();        
    }

    @isTest static void test_Method_Four() {
        
        Map<String, List < zqu.zChargeGroup>> testMap = new Map<String, List < zqu.zChargeGroup>> ();
        
        //setup test data
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote1 = ZTestFactory.makeQuote(opp, contact);
        buildQuote(quote1);
        quote1.Company_Code1__c = 'US46';
        quote1.zqu__PaymentMethod__c = 'Check';
        quote1.zqu__ZuoraSubscriptionID__c = '245nk334lk5h34';
        update quote1;
        
        Test.StartTest();
        PageReference pageRef = Page.CustomSendToZBilling;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('id', quote1.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController con = new ApexPages.StandardController(quote1);
        CustomSendToZBilling castzb = new CustomSendToZBilling(con);
        //SendToZbillingWithSplitQuotes.cloneQuote((String)quote.Id, '');

        quote1.Error_Message__c = 'Other Error Message';
        quote1.state__c = 'New';
        update quote1;

        castzb.checkOnLoad();       
    }


    @isTest static void test_Sending() {
        
        Map<String, List < zqu.zChargeGroup>> testMap = new Map<String, List < zqu.zChargeGroup>> ();
        
        //setup test data
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote1 = ZTestFactory.makeQuote(opp, contact);
        buildQuote(quote1);
        quote1.Company_Code1__c = 'US46';
        quote1.zqu__PaymentMethod__c = 'Check';
        quote1.zqu__ZuoraSubscriptionID__c = '245nk334lk5h34';
        update quote1;
        
        Test.StartTest();
        PageReference pageRef = Page.CustomSendToZBilling;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('id', quote1.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController con = new ApexPages.StandardController(quote1);
        CustomSendToZBilling castzb = new CustomSendToZBilling(con);
        //SendToZbillingWithSplitQuotes.cloneQuote((String)quote.Id, '');

        quote1.state__c = 'Sending';
        update quote1;

        castzb.checkOnLoad();    

            
    }


    @isTest static void test_AlreadySentQuote() {
        
        Map<String, List < zqu.zChargeGroup>> testMap = new Map<String, List < zqu.zChargeGroup>> ();
        
        //setup test data
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote1 = ZTestFactory.makeQuote(opp, contact);
        buildQuote(quote1);
        quote1.Company_Code1__c = 'US46';
        quote1.zqu__PaymentMethod__c = 'Check';
        quote1.zqu__ZuoraSubscriptionID__c = '245nk334lk5h34';
        update quote1;
        
        Test.StartTest();
        PageReference pageRef = Page.CustomSendToZBilling;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('id', quote1.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController con = new ApexPages.StandardController(quote1);
        CustomSendToZBilling castzb = new CustomSendToZBilling(con);
        //SendToZbillingWithSplitQuotes.cloneQuote((String)quote.Id, '');

        quote1.Error_Message__c = 'Quote has been successfully sent to Zuora';
        quote1.state__c = 'Sent';
        quote1.zqu__SubscriptionType__c = 'Amend Subscription';
        update quote1;

        castzb.checkOnLoad();        

        quote1.state__c = 'Sent';
        quote1.zqu__SubscriptionType__c = 'Renew Subscription';
        update quote1;

        castzb.checkOnLoad();        

    }

    @isTest static void test_Other_Errors() {
        
        Map<String, List < zqu.zChargeGroup>> testMap = new Map<String, List < zqu.zChargeGroup>> ();
        
        //setup test data
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote1 = ZTestFactory.makeQuote(opp, contact);
        buildQuote(quote1);
        quote1.Company_Code1__c = 'US46';
        quote1.zqu__PaymentMethod__c = 'Check';
        quote1.zqu__ZuoraSubscriptionID__c = '245nk334lk5h34';
        update quote1;
        
        Test.StartTest();
        PageReference pageRef = Page.CustomSendToZBilling;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('id', quote1.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController con = new ApexPages.StandardController(quote1);
        CustomSendToZBilling castzb = new CustomSendToZBilling(con);

        if (castzb.existingQuoteCharges == null){
            System.debug('Good');
        }

        if( SendToZbillingWithSplitQuotes.sendSuccess == false){
            System.debug('Good');
        }

        quote1.Error_Message__c = 'Other Error Message';
        quote1.state__c = 'Sent';
        update quote1;

        castzb.checkOnLoad();       

        castzb.returnToQuote();

        //castzb.DeletingQuotes();
    }
    

    @isTest static void test_Rollback() {
        
        Map<String, List < zqu.zChargeGroup>> testMap = new Map<String, List < zqu.zChargeGroup>> ();
        
        //setup test data
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote1 = ZTestFactory.makeQuote(opp, contact);
        buildQuote(quote1);
        quote1.Company_Code1__c = 'US46';
        quote1.zqu__PaymentMethod__c = 'Check';
        quote1.zqu__ZuoraSubscriptionID__c = '245nk334lk5h34';
        update quote1;
        
        Test.StartTest();
        PageReference pageRef = Page.CustomSendToZBilling;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('id', quote1.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController con = new ApexPages.StandardController(quote1);
        CustomSendToZBilling castzb = new CustomSendToZBilling(con);
        //SendToZbillingWithSplitQuotes.cloneQuote((String)quote.Id, '');

        quote1.state__c = 'RollBack';
        update quote1;

        castzb.checkOnLoad();    


    }


    @isTest static void test_BuildZAccount() {
        
        Map<String, List < zqu.zChargeGroup>> testMap = new Map<String, List < zqu.zChargeGroup>> ();
        
        //setup test data
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote1 = ZTestFactory.makeQuote(opp, contact);
        buildQuote(quote1);
        quote1.Company_Code1__c = 'US46';
        quote1.zqu__PaymentMethod__c = 'Check';
        quote1.zqu__ZuoraSubscriptionID__c = '245nk334lk5h34';
        update quote1;
        
        Test.StartTest();

        PageReference pageRef = Page.CustomSendToZBilling;
        pageRef.setRedirect(true);
        pageRef.getParameters().put('id', quote1.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController con = new ApexPages.StandardController(quote1);
        CustomSendToZBilling castzb = new CustomSendToZBilling(con);
        //SendToZbillingWithSplitQuotes.cloneQuote((String)quote.Id, '');

        Zuora.zApi zuoraApi = SendToZbillingWithSplitQuotes.login();
        SendToZbillingWithSplitQuotes.buildZAccount( quote1, quote1, zuoraApi, false, String.valueOf(acct.Id));

    }

    @isTest static void test_setEndPoint(){
        //setup test data
        Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote1 = ZTestFactory.makeQuote(opp, contact);
        buildQuote(quote1);
        quote1.Company_Code1__c = 'US46';
        quote1.zqu__PaymentMethod__c = 'Check';
        quote1.zqu__ZuoraSubscriptionID__c = '245nk334lk5h34';
        update quote1;
        
        Test.StartTest();

        ApexPages.StandardController con = new ApexPages.StandardController(quote1);
        CustomSendToZBilling castzb = new CustomSendToZBilling(con);
        //SendToZbillingWithSplitQuotes.cloneQuote((String)quote.Id, '');

        Zuora.zApi zuoraApi = SendToZbillingWithSplitQuotes.login();
        SendToZbillingWithSplitQuotes.buildZAccount( quote1, quote1, zuoraApi, false, String.valueOf(acct.Id));

        quote1.Company_Code1__c = 'WrongCompanyCode';
        update quote1;
        SendToZbillingWithSplitQuotes.buildZAccount( quote1, quote1, zuoraApi, true, String.valueOf(acct.Id));

    }

    public static List < Zuora.zObject > dummyQueryResults() {
        List<Zuora.zObject> result = new List<Zuora.zObject >();
        Zuora.zObject obj = new Zuora.zObject('Subscription');
        obj.setValue('Id', 'asdgadfg');
        result.add(obj);
        return result;
    }

    public static List < zqu.zQuoteUtil.zBillingResult > dummySZBResults(boolean isfailurecase) {
        List < zqu.zQuoteUtil.zBillingResult > result = new List < zqu.zQuoteUtil.zBillingResult >();
        zqu.zQuoteUtil.zBillingResult obj = new zqu.zQuoteUtil.zBillingResult();
        if (isfailurecase) {
            obj.success = false;
            obj.message = 'this be broke!';
        } else {
            obj.success = true;
            obj.zSubscriptionId = 'asdgadfg';
        }
        
        result.add(obj);
        return result;
    }

    public static List < zqu.zQuoteUtil.zBillingResult > dummySZBResults(Boolean isfailurecase, List<zqu.zQuoteUtil.ZBillingQuoteRequest> listOfReqs) {
       List < zqu.zQuoteUtil.zBillingResult > result = new List < zqu.zQuoteUtil.zBillingResult >();
       for (zqu.zQuoteUtil.ZBillingQuoteRequest req : listOfReqs) {
           zqu.zQuoteUtil.zBillingResult obj = new zqu.zQuoteUtil.zBillingResult();
           if (isfailurecase) {
               obj.success = false;
               obj.message = 'this be broke!';
           } else {
               obj.success = true;
               obj.zSubscriptionId = 'asdgadfg';
           }
           
           result.add(obj);
       }
       
       return result;
   }


    public static List<Zuora.zApi.DeleteResult> dummyDeleteResults() {
        List<Zuora.zApi.DeleteResult> result = new List<Zuora.zApi.DeleteResult>();
        Zuora.zApi.DeleteResult obj = new Zuora.zApi.DeleteResult();
        obj.success = true;
        result.add(obj);
        return result;
    }

    public static List<Zuora.zApi.SaveResult> dummySaveResults() {
        List<Zuora.zApi.SaveResult> result = new List<Zuora.zApi.SaveResult>();
        Zuora.zApi.SaveResult obj = new Zuora.zApi.SaveResult();
        obj.id = 'dafhasdgkj';
        obj.success = true;
        result.add(obj);
        return result;
    }

    public static void buildQuote(zqu__Quote__c quote) {

        Map<String, zqu__ProductRatePlan__c> PC = ZTestFactory.makePivotalProductCatalog();
        
        System.Debug('Quote Bill To: ' + quote.zqu__BillToContact__c);
        System.Debug('Quote Sold To: ' + quote.zqu__SoldToContact__c);
        Set<String> quoteChargeCustomFields = new Set<String>{'id', 'listed_price__c', 'listed_total__c', 'initial_term__c', 'start_date__c', 'end_date__c', 'country_uplift__c', 'calculated_discount__c', 'quote_split_number__c','psamount__c', 'rate_usd__c','tcv_usd__c'};
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = quoteChargeCustomFields;
        zqu.zChargeGroup chargeGroup1 = zqu.zQuoteUtil.getChargeGroup(quote.Id, PC.get('Annual').Id);
        zqu.zChargeGroup chargeGroup2 = zqu.zQuoteUtil.getChargeGroup(quote.Id, PC.get('Service').Id);
        chargeGroup1.zCharges[0].ChargeObject.put('Initial_Term__c', 12);
        chargeGroup2.zCharges[0].ChargeObject.put('Initial_Term__c', 12);
        
        List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>();
        List<zqu.zChargeGroup> Test1 = new List<zqu.zChargeGroup>();
        List<zqu.zChargeGroup> Test2 = new List<zqu.zChargeGroup>();
        for (Integer i=0 ; i<4 ; i++) {
            
            if(i<2)
            {
                chargeGroups.add(chargeGroup1);
                System.debug('tcv usd: '+chargeGroup1.zCharges[0].ChargeObject.get('TCV_USD__c'));
                Test1.add(chargegroup1);
                //testMap.add('Test1', chargegroup);
            }
            else
            {
                chargeGroups.add(chargeGroup2);
                System.debug('tcv usd: '+chargeGroup2.zCharges[0].ChargeObject.get('TCV_USD__c'));
                Test2.add(chargegroup2);
                //testMap.add('Test2', chargegroup);
            }
        }
        //testMap.put('Test1', Test1);
        //testMap.put('Test2', Test2);
        zqu.zQuoteUtil.addChargeGroups(chargeGroups);

        List<zqu__QuoteRatePlanCharge__c> charges = [SELECT Id, Quote_Split_Number__c
                                                        FROM zqu__QuoteRatePlanCharge__c
                                                        WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :quote.Id];

        Integer counter = 0;
        for (zqu__QuoteRatePlanCharge__c charge : charges) {
            charge.Start_Date__c = '2015-06-30';
            if (counter == 1) {
                charge.Quote_Split_Number__c = 'Services-12345';
                continue;
            }
            if (math.mod(counter, 2) == 0) {
                charge.Quote_Split_Number__c = '1';
            } else {
                charge.Quote_Split_Number__c = '2';
            }
            counter++;
        }

        update charges;
    }

}