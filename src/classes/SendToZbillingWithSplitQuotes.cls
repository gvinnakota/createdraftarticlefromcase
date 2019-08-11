public with sharing class SendToZbillingWithSplitQuotes {

  public static zqu__Quote__c quote;
  public static zqu__Quote__c subQuote;

  private static Map<String, String> endPoints;

  public static List < String > quoteIdsToSendtoZuora {
    get {
      if (quoteIdsToSendtoZuora == null) {
        quoteIdsToSendtoZuora = new List < String > ();
      }
      return quoteIdsToSendtoZuora;
    }
    set;
  }

  public static Set<String> quoteChargeCustomFields {
    get{
      if(quoteChargeCustomFields == null){
        quoteChargeCustomFields = new Set<String>{'id', 'listed_price__c', 'listed_total__c', 'initial_term__c', 'start_date__c', 'end_date__c', 'country_uplift__c', 'calculated_discount__c', 'quote_split_number__c','psamount__c', 'rate_usd__c','tcv_usd__c'};
      }
      return quoteChargeCustomFields;
    }
    set;
  }

  public static boolean sendSuccess {
    get {
      if (sendSuccess == null) {
        sendSuccess = false;
      }
      return sendSuccess;
    }
    set;
  }

  // create sub quotes for the separate charge maps create
  public static List < String > quoteSplit(Id thequoteId, Map < String, List < zqu__QuoteRatePlanCharge__c > > separateChargeMap) {

    quote = [SELECT Id, 
                    Error_Message__c, 
                    zqu__ZuoraAccountID__c 
             FROM zqu__Quote__c 
             WHERE Id = : thequoteId];

    // check if sub quote exists
    if ([SELECT Id from zqu__Quote__c where Split_Parent_Quote__c = : thequoteId].size() > 0) {
      System.Debug('SubQuotes already exist for this Quote');

      ApexPages.addMessage(new ApexPages.Message(
      ApexPages.severity.ERROR, 'SubQuotes already exist for this Quote'));
      Quote.Error_Message__c = 'SubQuotes already exist for this Quote';
      quoteIdsToSendtoZuora.add('Error');

      update quote;

    } else {

      zqu__Quote__c newSubQuote = null;
        System.debug('IseparateChargeMap =' + separateChargeMap + 'separateChargeMap Keyset' +separateChargeMap.keyset()); 
      
      if(!separateChargeMap.isEmpty() && separateChargeMap.keyset()!= null) {

      for (String key: separateChargeMap.keyset()) {
        System.debug('In QuoteSplit() : Key =' + key); 

        if (key != null && key.startsWith('Services-')) {
          System.debug('PS Charges are found. Building PS Usage Quote');
          // create shadow quote for each PS rateplans
          zqu__Quote__c shadowQuote = buildPSUsageQuote(quote.Id, separateChargeMap.get(key));
          quoteIdsToSendtoZuora.add(shadowQuote.Id);


          //if (quote.zqu__ZuoraAccountID__c != null && quote.zqu__ZuoraAccountID__c != '') {
          //  System.debug('In QuoteSplit() : with Existing Billing Account'); 
          //  //see if shadow subscription exists
          //  newSubQuote = cloneQuote(thequoteId, separateChargeMap.get(key), key);
          //  newSubQuote.zqu__Status__c = 'Sent to Z-Billing';
          //  update newSubQuote;
          //}
        } else {
          newSubQuote = cloneQuote(thequoteId, separateChargeMap.get(key), key);
          quoteIdsToSendtoZuora.add(newSubQuote.Id);
        }
      }

      // Copy psamount__c and other custom fields (metrics) from original quote
      copyChargeFields(quote.Id);
    }
   }

    return quoteIdsToSendtoZuora;

  }

  // Step #3.1.3 : copy PSamount__c and other custom field values from original quote
  public static void copyChargeFields(Id originalquoteid){

    // Query Service charges from original quote and   
    // Populate orginalServiceChargesMap
    Map<String, zqu__QuoteRatePlanCharge__c> originalServiceChargesMap = 
                                            new Map<String, zqu__QuoteRatePlanCharge__c>();

    for(zqu__QuoteRatePlanCharge__c originalCharge : 
                            [SELECT Id,
                                     PSMapping__c, 
                                     Product_Name__c,
                                     PSAmount__c,
                                     Country_Uplift__c,
                                     Start_Date__c,
                                     Start_Date_Formula__c,
                                     RATE_USD__c,
                                     TCV_USD__c
                             FROM zqu__QuoteRatePlanCharge__c
                             WHERE Product_Category__c = 'Services' AND
                                   zqu__QuoteRatePlan__r.zqu__Quote__c =: originalquoteid]){

            if(originalCharge.PSMapping__c != null){
              //String key = originalCharge.Product_Name__c + '::' + originalCharge.PSMapping__c;
              String key = originalCharge.Product_Name__c + '::' + originalCharge.PSMapping__c + '::' + originalCharge.Start_Date_Formula__c;
              System.debug('[ORIGINAL]====> ID: ' + originalCharge.id + ', Name: ' + originalCharge.Product_Name__c);
              System.debug('[ORIGINAL KEY]==========> ' + key);
              System.debug('[[[[ ORIGINAL ]]]]: ' + originalCharge);
              System.debug('[ORIGINAL]: {START DATE}: ' + originalCharge.Start_Date__c + '| {FORMULA}: ' + originalCharge.Start_Date_Formula__c);
              originalServiceChargesMap.put(key, originalCharge);
            }
    }

    // Load the quote rateplan charges from shadow quote
    List<zqu__QuoteRatePlanCharge__c> shadowCharges = 
                            [SELECT Id, 
                                    zqu__UOM__c, 
                                    Product_Name__c,
                                    PSAmount__c,
                                    Country_Uplift__c,
                                    Start_Date__c,
                                    Start_Date_Formula__c,
                                    RATE_USD__c,
                                    TCV_USD__c
                             FROM zqu__QuoteRatePlanCharge__c
                             WHERE zqu__QuoteRatePlan__r.zqu__Quote__r.Split_Parent_Quote__c =: originalquoteid AND
                                   zqu__UOM__c in ('PS Charge','PS Expense') 
                             ];

    System.debug('Charges from original quote:' + originalServiceChargesMap);
    System.debug('Charges from shadow quote: (before)' + shadowCharges);


    for(zqu__QuoteRatePlanCharge__c shadowCharge : shadowCharges){
        //String newkey = shadowCharge.Product_Name__c + '::' + shadowCharge.zqu__UOM__c;
        String newkey = shadowCharge.Product_Name__c + '::' + shadowCharge.zqu__UOM__c + '::' + shadowCharge.Start_Date_Formula__c;
        System.debug('[SHADOW]====> ID: ' + shadowCharge.id + ', Name: ' + shadowCharge.Product_Name__c);
        System.debug('[SHADOW KEY]============> ' + newkey);
        System.debug('[[[[ SHADOW ]]]]: ' + shadowCharge);
        System.debug('[SHADOW]: {START DATE}: ' + shadowCharge.Start_Date__c + '| {FORMULA}: ' + shadowCharge.Start_Date_Formula__c);
        zqu__QuoteRatePlanCharge__c source = originalServiceChargesMap.get(newkey);

        if(source != null){
          shadowCharge.PSAmount__c = source.PSAmount__c;
          shadowCharge.Country_Uplift__c = source.Country_Uplift__c;
          shadowCharge.RATE_USD__c = source.RATE_USD__c;
          shadowCharge.TCV_USD__c = source.TCV_USD__c;

        }

    }

    // Persist the updates
    update shadowCharges;

    System.debug('In copyPSAmount(): After copying custom value:' + shadowCharges);
  }

  // This method is called after cloneQuote process is finished.
  // Sending sub-Quotes To Z-Billing
  public static boolean sendQuote(String quoteId, zqu__Quote__c originalQuote, List<String> listofQuoteIds) {
    System.Debug('Sending quote: ' + quoteId+' subquotes: '+listofQuoteIds);
    zqu__Quote__c newquote, newsubQuote, quoteToUpdate;
    //get the quotes after the reload
    //List < String > ListOfSubsIdsToDelete = new List < String > ();

    //boolean hasServicesSub = false;

    //if (originalQuote.zqu__ZuoraAccountID__c != null && originalQuote.zqu__ZuoraAccountID__c != '') {
    //  Zuora.zApi zuoraApi = new Zuora.zApi();
    //  if (!Test.isRunningTest()) {
    //    zuoraApi.zlogin();
    //  }

    //  String queryString = 'select Id from Subscription where AccountId = \''+originalQuote.zqu__ZuoraAccountID__c+'\' and Subscription_Type__c = \''+'PS\'';

    //  System.debug('QueryString: ' + queryString);
    //  List < Zuora.zObject > queryresults = null;
    //  if (!Test.isRunningTest()) {
    //    queryresults = zuoraApi.zQuery(queryString);
    //  } else {
    //    queryresults = CustomSendToZBillingTest.dummyQueryResults();
    //  }

    //  System.Debug(queryresults);
    //  if (queryresults.size() > 0) {
    //    hasServicesSub = true;
    //  }
    //}

    // Map of subQuotes
    Map < Id, zqu__Quote__c > quoteMap = new Map < Id, zqu__Quote__c > ([SELECT Id,
      zqu__ZuoraAccountID__c,
      zqu__Account__r.Id,
      zqu__Account__r.Name,
      zqu__Currency__c,
      zqu__BillCycleDay__c,
      zqu__PaymentTerm__c,
      Owner.Name,
      zqu__BillToContact__r.MailingCity,
      zqu__BillToContact__r.MailingCountry,
      zqu__BillToContact__r.MailingCountryCode,
      zqu__BillToContact__r.MailingPostalCode,
      zqu__BillToContact__r.MailingState,
      zqu__BillToContact__r.MailingStateCode,
      zqu__BillToContact__r.MailingStreet,
      zqu__BillToContact__r.FirstName,
      zqu__BillToContact__r.LastName,
      zqu__BillToContact__r.Email,
      zqu__BillToContact__r.Phone,
      zqu__BillToContact__r.Contact_Company__c,
      zqu__SoldToContact__r.MailingCity,
      zqu__SoldToContact__r.MailingCountry,
      zqu__SoldToContact__r.MailingCountryCode,
      zqu__SoldToContact__r.MailingPostalCode,
      zqu__SoldToContact__r.MailingState,
      zqu__SoldToContact__r.MailingStateCode,
      zqu__SoldToContact__r.MailingStreet,
      zqu__SoldToContact__r.FirstName,
      zqu__SoldToContact__r.LastName,
      zqu__SoldToContact__r.Email,
      zqu__SoldToContact__r.Phone,
      zqu__SoldToContact__r.Contact_Company__c,
      Invoice_Template_Zuora_Id__c,
      Sold_Contact_Address__c,
      Sold_Contact_Address2__c,
      Contact_Address__c,
      Contact_Address2__c,
      Ship_Contact_Address__c,
      Ship_Contact_Address2__c,
      Ship_Contact_Email__c,
      Ship_To_First_Name__c,
      Ship_To_Last_Name__c,
      zqu__BillingMethod__c,
      zqu__PaymentMethod__c,
      Tax_Exempt__c,
      Certificate_Id1__c,
      VAT_ID1__c,
      Split_Parent_Quote__c,
      zqu__Status__c,
      Parent_Account__c,
      Subscription_Type__c,
      Channel__c,      
        Company_Code1__c,
      PurchaseOrder__c,
      ChannelOrderId__c
      FROM zqu__Quote__c
      WHERE Split_Parent_Quote__c = :quoteId
    ]);


    zqu.zQuoteUtil.ZBillingQuoteCollection quoteCollection = new zqu.zQuoteUtil.ZBillingQuoteCollection();
    List < zqu.zQuoteUtil.ZBillingQuoteCollection > quoteCollections = new List < zqu.zQuoteUtil.ZBillingQuoteCollection > ();
    quoteCollection.quoteRequests = new List < zqu.zQuoteUtil.ZBillingQuoteRequest > ();

    System.Debug('QuoteMap: ' + quoteMap);
    String accountId = '';
    Zuora.zApi zuoraApi = login();

    List < zqu.zQuoteUtil.ZBillingQuoteRequest > ListofReqs = new List < zqu.zQuoteUtil.ZBillingQuoteRequest > ();

    zqu__Quote__c quoteToDelete = null;
    String accountToDelete = null;
    String quoteFlow = '';

    Integer subQuoteCount = quoteMap.size();
    Integer sendToZBillingRequestCount = 0;
    Integer subQuoteSendToZBillingCount = 0;


    for (zqu__Quote__c zquote: quoteMap.values()) {
      //if (originalQuote.zqu__ZuoraAccountID__c != null && originalQuote.zqu__ZuoraAccountID__c != '' && zquote.zqu__Status__c == 'Sent to Z-Billing') {
      //  if (!hasServicesSub) {
      //    quoteToDelete = zquote;
      //    System.debug('quoteToDelete (sent to zbilling): ' + quoteToDelete);
      //  }
      //  continue;
      //}

      //if (originalQuote.zqu__ZuoraAccountID__c != null && originalQuote.zqu__ZuoraAccountID__c != '' && zquote.zqu__Status__c == 'New' && zquote.Subscription_Type__c == 'PS') {
      //  if (!hasServicesSub) {
      //    quoteToDelete = zquote;
      //    System.debug('quoteToDelete (new ps quote): ' + quoteToDelete);

      //    continue;
      //  }
      //}
      newquote = zquote;

      System.Debug('got quote: ' + newquote);

      zqu.zQuoteUtil.ZBillingQuoteRequest req = new zqu.zQuoteUtil.ZBillingQuoteRequest();
      req.sfdcQuoteId = newquote.Id; // SFDC Quote ID
      req.generateInvoice = true;
      req.invoiceProcessingOption = 'Subscription';
      

      ListofReqs.add(req);

      System.debug('accountId: '+accountId+'bla');
      System.debug('newQuote.zqu__ZuoraAccountID__c: '+newQuote.zqu__ZuoraAccountID__c+'bla');

      if ((String.isEmpty(newQuote.zqu__ZuoraAccountID__c) || newQuote.zqu__ZuoraAccountID__c == null) && accountId == '') {
        //create account
        System.debug('create account');

        accountId = buildZAccount(newquote, originalQuote, zuoraApi, false, accountId);

        if (accountId == '') {
          return sendSuccess;
        }
        accountToDelete = accountId;
        quoteCollection.zAccountId = accountId; // Zuora Billing Account ID
        quoteFlow = 'New Account';
      }
      else {
        System.debug('update account');
        //update account
        accountId = buildZAccount(newquote, originalQuote, zuoraApi, true, accountId);
        if (String.isEmpty(newQuote.zqu__ZuoraAccountID__c)) {
          quoteCollection.zAccountId = accountId;
        } else {
          quoteCollection.zAccountId = newQuote.zqu__ZuoraAccountID__c;
        }
        quoteFlow = 'Update Account';
        
      }

      quoteCollection.sfdcAccountId = newQuote.zqu__Account__r.Id;

    }

    sendToZBillingRequestCount = ListofReqs.size();

    if(subQuoteCount != sendToZBillingRequestCount){
      System.Debug('Number of sub quote and number of send to zbilling request does not match.');

      ApexPages.addMessage(new ApexPages.Message(
            ApexPages.severity.Error, 'Number of sub quote and number of send to zbilling request does not match.'));

      throw new ZRestException('Number of sub quote and number of send to zbilling request does not match.');
    }

    quoteCollection.quoteRequests = ListofReqs;
    quoteCollections.add(quoteCollection);

    List < zqu.zQuoteUtil.zBillingResult > results = new List < zqu.zQuoteUtil.zBillingResult > ();

    Boolean anyFailed = false;

    if (ListofReqs.size() > 0) {

      if (!Test.isRunningTest()) {
        results = zqu.zQuoteUtil.sendToZBilling(quoteCollections);
      } else {
        if (newQuote.zqu__ZuoraAccountID__c == null) {
          //results = CustomSendToZBillingTest.dummySZBResults(true);
          results = CustomSendToZBillingTest.dummySZBResults(true, ListofReqs);
        } else {
          //results = CustomSendToZBillingTest.dummySZBResults(false);
          results = CustomSendToZBillingTest.dummySZBResults(false, ListofReqs);
        }
      }
      
      System.Debug('sent to zbilling ' + results);
      if(!Test.isRunningTest()){
        System.debug( 'SOAP Request = ' + Zuora.zApi.currentLogger.request );
        System.debug( 'SOAP Response = ' + Zuora.zApi.currentLogger.response );
      }

      for (zqu.zQuoteUtil.zBillingResult result: results) {
        if (result.success) {      
          //ListOfSubsIdsToDelete.add(result.zSubscriptionId);
          ApexPages.addMessage(new ApexPages.Message(
            ApexPages.severity.Confirm, 'Quote has been successfully sent to Zuora'));
          sendSuccess = true;

          subQuoteSendToZBillingCount++;
        }
        else {
          //Reid: 9/6: changed for when called from Aura, testing
          if (Apexpages.currentPage() != null) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, result.message));
          }else{
              throw new ZRestException(result.message);
          }

          if (result.message.length() < 256) {
            originalQuote.Error_Message__c = result.message;
          }


          anyFailed = true;

          sendSuccess = false;

          quoteToUpdate = originalQuote;
        }

      }
    } else {
      sendSuccess = true;
    }

    System.debug('subQuoteSendToZBillingCount = ' + subQuoteSendToZBillingCount);
    System.debug('subQuoteCount = ' + subQuoteCount);
    

    if (anyFailed == true) {
      sendSuccess = false;
      if (accountToDelete != null && quoteFlow == 'New Account') {
        try {
          List<String> accounts = new List<String> {accountToDelete};
          List<Zuora.zApi.DeleteResult> acctresults = null;
          if (!Test.isRunningTest()) {
            acctresults = zuoraApi.zdelete('Account', accounts);
          } else {
            acctresults = CustomSendToZBillingTest.dummyDeleteResults();
          }

          for (Zuora.zApi.DeleteResult acctresult : acctresults) {
            if (acctresult.Success){
              //get the newly created id
              //accountId = acctresult.Id;
              // more code here...
            } else {
              //failure
              
              throw new ZRestException('Error with response code: '+parseZuoraError(acctresult.errors));
            }
          }
        } 
        catch( System.Exception e) {
          System.debug('ERROR: '+ e);

          throw new ZRestException('Something went wrong: '+e);
        }
      }
    }

    if(quoteToUpdate != null){
      update quoteToUpdate;
    }

    if (subQuoteSendToZBillingCount != subQuoteCount){
      throw new ZRestException('One or more sub-Quote(s) could not be sent to Z-Billing' + '} subQuoteSendToZBillingCount: ' + subQuoteSendToZBillingCount + ' } subQuoteCount: ' + subQuoteCount);
    }

    return sendSuccess;
  }

  public static String parseZuoraError(Zuora.zObject[] zuoraerrors){
      Zuora.zObject[] errors = zuoraerrors;
      String message = '';
      for (Zuora.zObject error : errors) {
        String errorCode = (String)error.getValue('Code');
        message = (String)error.getValue('Message');
        //more code here...
      }
      return message;
  }

  public static String buildZAccount(zqu__Quote__c currQuote, zqu__Quote__c originalQuote, Zuora.zApi zuoraApi, boolean isUpdate, String recentAcctId) {

    Zuora.zObject acc = new Zuora.zObject('Account');

    List<Company_Code__c> companyCodes = [SELECT Tax_Region__c from Company_Code__c where Code__c = :currQuote.Company_Code1__c];

    Company_Code__c companyCode = null;
    if(companyCodes.size() > 0) {
      companyCode = companyCodes[0];
    }

    if (isUpdate) {
      if (recentAcctId != '') {
        acc.setValue('Id', recentAcctId);
      } else {
        acc.setValue('Id', currQuote.zqu__ZuoraAccountID__c);
      }
      
    }

    Zuora.zObject pmzobj = null;
    String name = currQuote.zqu__PaymentMethod__c;
    String type = currQuote.zqu__PaymentMethod__c.replaceAll( '\\s+', '');
    String zoqlpm = 'SELECT Id from PaymentMethod where Name=\'' + name + '\' and Type = \''+type+'\'';
    List < Zuora.zObject > pmzobjs = null;

    if (!Test.isRunningTest()) {
      pmzobjs = zuoraApi.zquery(zoqlpm);
    } else {
      pmzobjs = CustomSendToZBillingTest.dummyQueryResults();
    }
    if (pmzobjs.size() == 1) pmzobj = pmzobjs[0];
 
    acc.setValue('Name', currQuote.zqu__Account__r.name);
    
    acc.setValue('BillCycleDay', 1);
    acc.setValue('PaymentTerm', currQuote.zqu__PaymentTerm__c);
    if (pmzobj != null) {
      acc.setValue('DefaultPaymentMethodId', (String) pmzobj.getValue('Id'));
    }
    List<Channel__c> channels = [SELECT Name, Channel_Type__c from Channel__c where name = :currQuote.Channel__c];
/*    if (channels[0].Channel_Type__c == 'Direct') {
      acc.setValue('Batch', 'Batch2');
      //TODO add in setting tax exempt status here, false for direct [CTH]
      //acc.setValue('TaxExemptStatus', 'Yes');
      } else {
        acc.setValue('Batch', 'Batch1');
        //TODO add in setting tax exempt status here, true for indirect [CTH]
        //acc.setValue('TaxExemptStatus', 'No');
      }
    if (!isUpdate) {
      acc.setValue('Status', 'Draft');
      acc.setValue('Currency', currQuote.zqu__Currency__c);
    }*/

    List<zqu__InvoiceTemplate__c> invoiceTemplates = [SELECT Id, Name, zqu__ZuoraId__c from zqu__InvoiceTemplate__c 
                                                WHERE Company_Code__c = :currQuote.Company_Code1__c];


    String invoiceTemplateId = null;
    if (invoiceTemplates.size() > 0) {
      invoiceTemplateId = invoiceTemplates[0].zqu__ZuoraId__c;
    } else {

      List<zqu__InvoiceTemplate__c> defaultInvoiceTemplate = 
              [SELECT Id, Name, zqu__ZuoraId__c 
               FROM zqu__InvoiceTemplate__c 
               WHERE default__c = true];

      if(defaultInvoiceTemplate.size()>0){
        invoiceTemplateId = defaultInvoiceTemplate[0].zqu__ZuoraId__c;
      }
    }

    acc.setValue('CrmId', currQuote.zqu__Account__r.Id);
    acc.setValue('Channel__c', currQuote.Channel__c);
    acc.setValue('Company_Code__c', currQuote.Company_Code1__c);
    //acc.setValue('TaxCompanyCode', currQuote.Company_Code__c);
    if(companyCode != null){
      acc.setValue('TaxCompanyCode', companyCode.Tax_Region__c);
    }
    acc.setvalue('VATId', currQuote.VAT_ID1__c);
    acc.setValue('Invoice_VATID__c', currQuote.VAT_ID1__c);
    acc.setValue('Ship_To_Last_Name__c', currQuote.Ship_To_Last_Name__c);
    acc.setValue('Ship_To_First_Name__c', currQuote.Ship_To_First_Name__c);
    acc.setValue('Ship_Contact_Email__c', currQuote.Ship_Contact_Email__c);
    acc.setValue('Ship_Contact_Address2__c', currQuote.Ship_Contact_Address2__c);
    acc.setValue('Ship_Contact_Address__c', currQuote.Ship_Contact_Address__c);
    if(invoiceTemplateId != null){
      acc.setValue('InvoiceTemplateId', invoiceTemplateId);
    }
    acc.setValue('ParentCRMID__c', currQuote.Parent_Account__c);
    acc.setValue('SalesRepName', currQuote.Owner.Name);

    // TODO: add soldto&billto company contact name
    //acc.setValue('SOLD_TO_COMPANY_NAME', currQuote.zqu__SoldToContact__r.CompanyName<-- this probably is a formula field from quote to soldto contact); 
    //acc.setValue('BILL_TO_COMPANY_NAME', currQuote.zqu__BillToContact__r.CompanyName<-- this probably is a formula field from quote to billto contact); 
    acc.setValue('SoldToCompanyName__c', currQuote.zqu__SoldToContact__r.Contact_Company__c); 
    acc.setValue('BillToCompanyName__c', currQuote.zqu__BillToContact__r.Contact_Company__c); 

    
    if (currQuote.Tax_Exempt__c) {
      acc.setValue('TaxExemptStatus', 'Yes');
      acc.setValue('TaxExemptCertificateID', currQuote.Certificate_Id1__c);
    } else {
      acc.setValue('TaxExemptStatus', 'No');
    }

    if (channels.size() > 0 && channels[0].Channel_Type__c == 'Direct') {
      acc.setValue('Batch', 'Batch2');
      //acc.setValue('TaxExemptStatus', 'No');
      } else {
        acc.setValue('Batch', 'Batch1');
        //acc.setValue('TaxExemptStatus', 'Yes');
        //acc.setValue('TaxExemptCertificateID', 'Default Indirect Id');
      }
    if (!isUpdate) {
      acc.setValue('Status', 'Draft');
      acc.setValue('Currency', currQuote.zqu__Currency__c);
    }
    
    //acc.setValue('Sold_To_Contact_Address__c', currQuote.Sold_Contact_Address__c+'\n'+currQuote.Sold_Contact_Address2__c);
    //acc.setValue('Bill_To_Contact_Address__c', currQuote.Contact_Address__c+'\n'+currQuote.Contact_Address2__c);
    acc.setValue('CRM_Sold_To_Contact_Id__c', currQuote.zqu__SoldToContact__c);
    acc.setValue('CRM_Bill_To_Contact_Id__c', currQuote.zqu__BillToContact__c);

    Zuora.zObject billToContact = new Zuora.zObject('Contact');
 
    billToContact.setValue('Address1', currQuote.zqu__BillToContact__r.MailingStreet);
    billToContact.setValue('City', currQuote.zqu__BillToContact__r.MailingCity);
    billToContact.setValue('Country', currQuote.zqu__BillToContact__r.MailingCountryCode);
    billToContact.setValue('PostalCode', currQuote.zqu__BillToContact__r.MailingPostalCode);
    billToContact.setValue('State', currQuote.zqu__BillToContact__r.MailingStateCode);
    billToContact.setValue('FirstName', currQuote.zqu__BillToContact__r.FirstName);
    billToContact.setValue('LastName', currQuote.zqu__BillToContact__r.LastName);
    billToContact.setValue('WorkEmail', currQuote.zqu__BillToContact__r.Email);
    billToContact.setValue('WorkPhone', (String) currQuote.zqu__BillToContact__r.Phone);
    billToContact.setValue('Contact_Company__c', currQuote.zqu__BillToContact__r.Contact_Company__c);

    System.debug('Work phone is: ' + (String) currQuote.zqu__BillToContact__r.Phone);

    System.debug('Bill to Contact is: ' + billToContact); 

    Zuora.zObject soldToContact = new Zuora.zObject('Contact');
 
    soldToContact.setValue('Address1', currQuote.zqu__SoldToContact__r.MailingStreet);
    soldToContact.setValue('City', currQuote.zqu__SoldToContact__r.MailingCity);
    soldToContact.setValue('Country', currQuote.zqu__SoldToContact__r.MailingCountryCode);
    soldToContact.setValue('PostalCode', currQuote.zqu__SoldToContact__r.MailingPostalCode);
    soldToContact.setValue('State', currQuote.zqu__SoldToContact__r.MailingStateCode);
    soldToContact.setValue('FirstName', currQuote.zqu__SoldToContact__r.FirstName);
    soldToContact.setValue('LastName', currQuote.zqu__SoldToContact__r.LastName);
    if(companyCode != null){
      soldToContact.setValue('TaxRegion', companyCode.Tax_Region__c);
    }
    soldToContact.setValue('WorkEmail', currQuote.zqu__SoldToContact__r.Email);
    soldToContact.setValue('WorkPhone', (String) currQuote.zqu__SoldToContact__r.Phone);
    soldToContact.setValue('Contact_Company__c', currQuote.zqu__SoldToContact__r.Contact_Company__c);


    String accountId = '';
    try {

      List<Zuora.zObject> accounts = new List<Zuora.zObject> {acc};
      List<Zuora.zApi.SaveResult> results = null;
      if (!Test.isRunningTest()) {
        if (isUpdate) {
          results = zuoraApi.zupdate(accounts);
        } else {
          results = zuoraApi.zcreate(accounts);
        }
      } else {
        results = CustomSendToZBillingTest.dummySaveResults();
      }
      
      for (Zuora.zApi.SaveResult result : results) {
        if (result.Success){
          //get the newly created id
          accountId = result.Id;
          // more code here...
        } else {
          
          throw new ZRestException('Error with response code: '+parseZuoraError(result.errors));
        }
      }

      billToContact.setValue('AccountId', accountId);
      soldToContact.setValue('AccountId', accountId);

      List<Zuora.zObject> contacts = null;

      String billToId = '';
      String soldToId = '';

      if (isUpdate) {
        String queryString = 'SELECT BillToId, SoldToId from Account where id = \'' + accountId + '\'';
        List < Zuora.zObject > queryresults = null;
        if (!Test.isRunningTest()) {
          queryresults = zuoraApi.zQuery(queryString);
        } else {
          queryresults = CustomSendToZBillingTest.dummyQueryResults();
        }
        //System.Debug(queryresults);

        for (Zuora.zObject zobj: queryresults) {
          billToId = (String) zobj.getvalue('BillToId');
          soldToId = (String) zobj.getvalue('SoldToId');
        }
        billToContact.setValue('Id', billToId);
        soldToContact.setValue('Id', soldToId);
        contacts = new List<Zuora.zObject> {billToContact, soldToContact};
        if (!Test.isRunningTest()) {
          results = zuoraApi.zupdate(contacts);
        } else {
          results = CustomSendToZBillingTest.dummySaveResults();
        }
      } else {
        contacts = new List<Zuora.zObject> {billToContact, soldToContact};
        if (!Test.isRunningTest()) {
          results = zuoraApi.zcreate(contacts);
        } else {
          results = CustomSendToZBillingTest.dummySaveResults();
        }
      }
      
      Integer counter = 0;
      
      for (Zuora.zApi.SaveResult result : results) {
        if (result.Success){
          if (counter == 0) {
            billToId = result.Id;
          } else if (counter == 1) {
            soldToId = result.Id;
          }
          counter++;
          //get the newly created id
          //accountId = result.Id;
          // more code here...
        } else {
          //failure
          
          throw new ZRestException('Error with response code: '+parseZuoraError(result.errors));
        }
      }

      
      acc = new Zuora.zObject('Account');
      if (isUpdate) {
        acc.setValue('Id', accountId);
        if (currQuote.zqu__BillingMethod__c == 'Email') {
          acc.setValue('InvoiceDeliveryPrefsEmail', 'true');
          acc.setValue('InvoiceDeliveryPrefsPrint', 'false');
        } else if (currQuote.zqu__BillingMethod__c == 'Email and Print') {
          acc.setValue('InvoiceDeliveryPrefsEmail', 'true');
          acc.setValue('InvoiceDeliveryPrefsPrint', 'true');
        }
      } else {
        acc.setValue('Id', accountId);
        acc.setValue('Status', 'Active');
        acc.setValue('BillToId', billToId);
        acc.setValue('SoldToId', soldToId);

        if (currQuote.zqu__BillingMethod__c == 'Email') {
          acc.setValue('InvoiceDeliveryPrefsEmail', 'true');
          acc.setValue('InvoiceDeliveryPrefsPrint', 'false');
        } else if (currQuote.zqu__BillingMethod__c == 'Email and Print') {
          acc.setValue('InvoiceDeliveryPrefsEmail', 'true');
          acc.setValue('InvoiceDeliveryPrefsPrint', 'true');
        }
      }

      accounts = new List<Zuora.zObject> {acc};
      if (!Test.isRunningTest()) {
        results = zuoraApi.zupdate(accounts);
      } else {
        results = CustomSendToZBillingTest.dummySaveResults();
      }
       
      for (Zuora.zApi.SaveResult result : results) {
        if (result.Success){
          //get the newly created id
          accountId = result.Id;
          // more code here...
        } else {
          //failure
          
          throw new ZRestException('Error with response code: '+parseZuoraError(result.errors));
        }
      }
    } catch( System.Exception e) {
      System.debug('ERROR: '+ e);
      ApexPages.addMessage(new ApexPages.Message(
        ApexPages.severity.ERROR, e.getMessage()));
      //anyFailed = true;
      originalQuote.Error_Message__c = e.getMessage();

      sendSuccess = false;
      update originalQuote;
      return '';
    } 

    return accountId;

  }

  public static Zuora.zApi login() {

    Zuora.zApi zuoraApi = new Zuora.zApi();

    Zuora.zApi.LoginResult loginResults = null;
    
    if (!Test.isRunningTest()) {
      loginResults = zuoraApi.zlogin();
      setEndpoints(new URL(loginResults.ServerUrl));
      
      // we need to figure out which system we are connect to for other
      // api calls to work 
    } else {
      loginResults = new Zuora.zApi.LoginResult();

      // test apisandbox
      loginResults.ServerUrl = 'https://apisandbox.zuora.com';
      setEndpoints(new URL(loginResults.ServerUrl));

      // test services451
      loginResults.ServerUrl = 'https://services451.zuora.com';
      setEndpoints(new URL(loginResults.ServerUrl));

      // test production
      loginResults.ServerUrl = 'https://www.zuora.com';
      setEndpoints(new URL(loginResults.ServerUrl));
    }
    
    return zuoraApi;
      
  }

  private static void setEndpoints(URL url) {    
      if (url.getAuthority() == 'apisandbox.zuora.com' ||
          url.getAuthority() == 'apisandbox-zforsf.zuora.com') {
              endPoints = new Map<String, String>{ 'soap' => 'https://apisandbox.zuora.com' + url.getPath(),
                  'rest' =>  'https://apisandbox-api.zuora.com/rest' };
          }
      else if (url.getAuthority() == 'services451.zuora.com' ||
          url.getAuthority() == 'service451-zforsf.zuora.com') {
              endPoints = new Map<String, String>{ 'soap' => 'https://services451.zuora.com' + url.getPath(),
                  'rest' =>  'https://services451.zuora.com/apps' };
          }
      else if (url.getAuthority() == 'www.zuora.com' ||
          url.getAuthority() == 'zforsf.zuora.com') {
              endPoints = new Map<String, String>{ 'soap' => 'https://www.zuora.com' + url.getPath(),
                  'rest' =>  'https://api.zuora.com/rest' };
          }
      else {
          throw new ZRestException('Cannot determine endpoint for [' + url + ']');
      }
  }

  // Step #3.1.1 
  // swap the selected one time charge PS rateplan with
  // usage charge PS rateplan under same product
  public static zqu__Quote__c buildPSUsageQuote(String quoteId, List < zqu__QuoteRatePlanCharge__c > charges) {
    System.debug('In buildPSUsageQuote');

    // crate a quote
    quote = getQuoteInfo(quoteId);
    subQuote = quote.clone(false, true, false, false);
    subQuote.name += ' (PS Usage Shadow)';
    if(subQuote.name.length() > 80) {
      subQuote.name = subQuote.name.subString(0,80); // quote.name field allows only 80 characters
    }
    subQuote.zqu__ZuoraSubscriptionID__c = '';
    subQuote.zqu__Status__c = 'New';
    subQuote.Subscription_Type__c = 'PS';
    subQuote.Split_Parent_Quote__c = quoteId;
    subQuote.zqu__Is_Parent_Quote__c = false;
    Schema.DescribeSObjectResult dsr = Schema.SObjectType.zqu__Quote__c;
    Schema.RecordTypeInfo defaultrtinfo;
    subQuote.zqu__SubscriptionType__c = 'New Subscription';
    subQuote.zqu__Subscription_Term_Type__c = 'Evergreen';
    defaultrtinfo = dsr.getRecordTypeInfosByName().get('Default');
    subQuote.RecordTypeId = defaultrtinfo.getRecordTypeId();
    subQuote.Primary_Quote__c = false;
    subQuote.zqu__ZuoraAccountID__c = quote.zqu__ZuoraAccountID__c;
    subQuote.PurchaseOrder__c = quote.PurchaseOrder__c;
    subQuote.ChannelOrderId__c = quote.ChannelOrderId__c;

    Date subStartDate = null;
    for (zqu__QuoteRatePlanCharge__c charge : charges) {
      Date startDate = null;
      if (charge.Start_Date__c != null && charge.Start_Date__c != '') {
        startDate = Date.valueOf(charge.Start_Date__c+' 00:00:00');
      }
      if (subStartDate == null || startDate < subStartDate) {
        subStartDate = startDate;
      }
    }

    if (subStartDate != null) {
      subQuote.zqu__Customer_Acceptance_Date__c = subStartDate;
      subQuote.zqu__Service_Activation_Date__c = subStartDate;
      subQuote.zqu__StartDate__c = subStartDate;
    } else {
      subQuote.zqu__Customer_Acceptance_Date__c = Date.today();
      subQuote.zqu__Service_Activation_Date__c = Date.today();
      subQuote.zqu__StartDate__c = Date.today();
    }

    insert subQuote;

    // add charges to the quote created above
    Set<String> ratePlanIds = new Set<String>();
    Set<String> productIds = new Set<String>();

    for (zqu__QuoteRatePlanCharge__c charge : charges) {
        productIds.add(charge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c);
    }

    List<zqu__ProductRatePlan__c> rateplans = [SELECT Id
                                FROM zqu__ProductRatePlan__c
                                WHERE zqu__Deleted__c = false and 
                                zqu__EffectiveStartDate__c <= TODAY and 
                                zqu__EffectiveEndDate__c >= TODAY and 
                                BillingPeriod__c = 'Usage' and
                                zqu__Product__r.ProductServiceCategory__c = 'Services' and
                                zqu__Product__c in :productIds];

    for (zqu__ProductRatePlan__c ratePlan : rateplans) {
        ratePlanIds.add(ratePlan.Id);
    }

    zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = quoteChargeCustomFields;
    List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(subQuote.Id, new List<String>(ratePlanIds));

    if (chargeGroups.size() > 30) {
      List<zqu.zChargeGroup> chunkedCGList = new List<zqu.zChargeGroup>();
      for (Integer i = 0 ; i < chargeGroups.size() ; i++) {
        chunkedCGList.add(chargeGroups[i]);
        if (chunkedCGList.size() == 30) {
          zqu.zQuoteUtil.addChargeGroups(chunkedCGList);
          chunkedCGList.clear();
        }
      }
      if (chunkedCGList.size() > 0) {
        zqu.zQuoteUtil.addChargeGroups(chunkedCGList);
      }
    } else {
      zqu.zQuoteUtil.addChargeGroups(chargeGroups);
    }
    
    return subQuote;
  }


  // Step #3.2 : clone and insert the quote
  public static zqu__Quote__c cloneQuote(String quoteId, List < zqu__QuoteRatePlanCharge__c > charges, String key) {
    quote = getQuoteInfo(quoteId);
    String zSubId = quote.zqu__ZuoraSubscriptionID__c;

    //this is a unique external id, need to remove it
    quote.zqu__ZuoraSubscriptionID__c = '';
    update quote;

    subQuote = quote.clone(false, true, false, false);
    subQuote.name += ' '+key;
    if(subQuote.name.length() > 80) {
      subQuote.name = subQuote.name.subString(0,80); // quote.name field allows only 80 characters
    }
    subQuote.zqu__ZuoraSubscriptionID__c = zSubId;
    subQuote.zqu__Status__c = 'New';
    subQuote.Split_Parent_Quote__c = quoteId;
    subQuote.zqu__Is_Parent_Quote__c = false;
    subQuote.Primary_Quote__c = false;

    if(Test.isRunningTest()) {
      //System.debug('Setting quote company code in clone quote.'); 
      //subQuote.Company_Code__c = 'US46'; 

      System.debug('Setting quote channel in clone quote.'); 
      subQuote.Channel__c = 'EMC-US'; 
    }

    // set subscription_type__c
    if (key != null && key.startsWith('Services-')) {
      subQuote.Subscription_Type__c = 'PS';
    } else {
      subQuote.Subscription_Type__c = 'Product';
    }

    Date subStartDate = null;
    Integer initialTerm = 0;
    for (zqu__QuoteRatePlanCharge__c charge : charges) {
      Date startDate = null;
      if (charge.Start_Date__c != null && charge.Start_Date__c != '') {
        startDate = Date.valueOf(charge.Start_Date__c+' 00:00:00');
      }
      if (subStartDate == null || startDate < subStartDate) {
        subStartDate = startDate;
        initialTerm = Integer.valueOf(charge.Initial_Term__c);
      }
    }

    if (subStartDate != null) {
      subQuote.zqu__Customer_Acceptance_Date__c = subStartDate;
      subQuote.zqu__Service_Activation_Date__c = subStartDate;
      subQuote.zqu__StartDate__c = subStartDate;
      subQuote.zqu__InitialTerm__c = initialTerm;
    } else {
      subQuote.zqu__Customer_Acceptance_Date__c = Date.today();
      subQuote.zqu__Service_Activation_Date__c = Date.today();
      subQuote.zqu__StartDate__c = Date.today();
      subQuote.zqu__InitialTerm__c = 1;
    }
    
    // set record type 
    Schema.DescribeSObjectResult dsr = Schema.SObjectType.zqu__Quote__c;
    Schema.RecordTypeInfo defaultrtinfo;
    if (subQuote.zqu__SubscriptionType__c == 'Amend Subscription') {
      defaultrtinfo = dsr.getRecordTypeInfosByName().get('Amendment'); //=> Amendment ReadOnly
    }
    else if (subQuote.zqu__SubscriptionType__c == 'Renew Subscription') {
      defaultrtinfo = dsr.getRecordTypeInfosByName().get('Renewal'); //=> Renewal ReadOnly
    }
    else {
      defaultrtinfo = dsr.getRecordTypeInfosByName().get('Default');  //=> ReadOnly
    }
    subQuote.RecordTypeId = defaultrtinfo.getRecordTypeId();

    subQuote.zqu__ZuoraAccountID__c = quote.zqu__ZuoraAccountID__c;

    insert subQuote;
    System.Debug('Quote Cloned :' + subQuote);

    // clone quote amendments, quote rateplans, and quote rateplan charges
    if (quote.zqu__SubscriptionType__c == 'New Subscription') {
      clonesubQuoteObjects(quote.Id, subQuote.Id, charges);
    }
    else{
         //cloneAmendQuoteObjects(quote.Id, subQuote.Id);
         //clonesubQuoteObjects(quote.Id, subQuote.Id, charges);
    }

    return subQuote;
  }

  /*
  Handles cloning new quote charges
  */
  private static void clonesubQuoteObjects(String oldQuoteId, String subQuoteId, List < zqu__QuoteRatePlanCharge__c > charges) {
    System.Debug('Cloning new quote objects');
    List < zqu__QuoteRatePlanCharge__c > newQcList = new List < zqu__QuoteRatePlanCharge__c > ();
    List < zqu__QuoteRatePlanCharge__c > oldQcList = new List < zqu__QuoteRatePlanCharge__c > ();

    Map<Id, zqu__QuoteRatePlanCharge__c> mapOfCharges = new Map<Id, zqu__QuoteRatePlanCharge__c>();
    Set<String> productNames = new Set<String>();
    Set<String> qrpIds = new Set<String>();
    for (zqu__QuoteRatePlanCharge__c charge : charges) {
      mapOfCharges.put(charge.Id, charge);
      productNames.add(charge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name);
      qrpIds.add(charge.zqu__QuoteRatePlan__c);
    }
    //get the quote amendment on the old quote
    List < zqu__QuoteAmendment__c > quoteAmendments = Database.query(getCreatableFieldsSOQL('zqu__QuoteAmendment__c', 'zqu__Quote__c = :oldQuoteId'));
    List<zqu__QuoteAmendment__c> qaList = new List<zqu__QuoteAmendment__c>();
    for (zqu__QuoteAmendment__c qaObject : quoteAmendments) {
      zqu__QuoteAmendment__c qa = qaObject;
      qa.zqu__Quote__c = subQuoteId;
      qa.Id = null;
      qaList.add(qa);
    }

    insert qaList;
    /*
    Map<String, List<Id>> amendmentMap = new Map<String, List<Id>>();
    for (zqu__QuoteAmendment__c qa : qaList){
      if (!amendmentMap.containsKey(qa.zqu__Type__c)){
        List<Id> ids = new List<Id>();
        ids.add(qa.Id);
        amendmentMap.put(qa.zqu__Type__c,ids);
      } else {
          amendmentMap.get(qa.zqu__Type__c).add(qa.Id);
      }
    }
*/
    Set<Id> qrpcIds = mapOfCharges.keySet();
    //get the quote rate plans on the old quote
    List < zqu__QuoteRatePlan__c > quoteRatePlans = Database.query(getCreatableFieldsSOQL('zqu__QuoteRatePlan__c', 'id in :qrpIds'));
    List<zqu__QuoteRatePlan__c> qrpList = new List<zqu__QuoteRatePlan__c>();
    for (zqu__QuoteRatePlan__c qrpObject : quoteRatePlans) {
      zqu__QuoteRatePlan__c qrp = qrpObject;
      qrp.zqu__Quote__c = subQuoteId;
      qrp.zqu__QuoteAmendment__c = qaList[0].Id; //amendmentMap.get(qrp.zqu__AmendmentType__c).remove(0);
      qrp.Old_Id__c = qrp.Id;
      qrp.Id = null;
      qrpList.add(qrp);
      
    }

    insert qrpList;

    List < sObject > quoteProdFeatures = Database.query(getCreatableFieldsSOQL('zqu__QuoteProductFeature__c', 'zqu__Quote__c = :oldQuoteId and zqu__ZProduct__r.Name in :productNames'));


    List<zqu__QuoteProductFeature__c> qpfList = new List<zqu__QuoteProductFeature__c>();
    for (sObject qpfSObject : quoteProdFeatures) {
      zqu__QuoteProductFeature__c qpf = (zqu__QuoteProductFeature__c) qpfSObject;
      qpf.zqu__Quote__c = subQuoteId;
      qpf.Id = null;
      qpf.Name = null;
      for (zqu__QuoteRatePlan__c qrp : qrpList) {
        boolean featureAlreadyAdded = false;
        if (qrp.Name == qpf.zqu__QuoteRatePlan__r.Name) {
          for (zqu__QuoteProductFeature__c qpfLoop : qpfList) {
            if (qpf.zqu__FeatureName__c == qpfLoop.zqu__FeatureName__c && qrp.Id == qpfLoop.zqu__QuoteRatePlan__c) {
              featureAlreadyAdded = true;
              break;
            }
          }
          if (!featureAlreadyAdded) {
            qpf.zqu__QuoteRatePlan__c = qrp.Id;
            qpf.zqu__ChargeGroupId__c = qrp.Id;
            break;
          }
        }
      }
      //qpf.zqu__QuoteRatePlan__c = null;
      qpfList.add(qpf);
    }

    insert qpfList;
    
    Map<String, zqu__QuoteRatePlan__c> qrpMap = new Map<String, zqu__QuoteRatePlan__c>();
    for (zqu__QuoteRatePlan__c qrp : qrpList) {
      qrpMap.put(qrp.Old_Id__c, qrp);
    }

    //get the quote charges on the old quote
    List < sObject > sObjects = Database.query(getCreatableFieldsSOQL('zqu__QuoteRatePlanCharge__c', 'Id in :qrpcIds'));
    //cast sObject as zQuoteCharge
    for (sObject obj: sObjects) {
      oldQcList.add((zqu__QuoteRatePlanCharge__c) obj);
    }

    for (zqu__QuoteRatePlanCharge__c qc: oldQcList) {
      if(mapOfCharges.get(qc.Id) != null) {
      //clone quote charges
      System.debug('previous quote charge: '+qc);
        zqu__QuoteRatePlanCharge__c temp = qc.clone(false, true, false, false);
        zqu__QuoteRatePlan__c newQrp = qrpMap.get(temp.zqu__QuoteRatePlan__c);
        
        //temp.Id = null;
        //set new quote id
        temp.zqu__QuoteRatePlan__c = newQrp.Id;
        System.debug('subquoterateplan id: '+newQrp.Id+  ' new quote charge: '+temp);
        newQcList.add(temp);
      }
    }

    if (!newQcList.isEmpty()) {
      //System.debug('quote charge list: '+newQcList);
      insert newQcList;
    }

  }

  private static zqu__Quote__c getQuoteInfo(String quoteId) {
    return (zqu__Quote__c) Database.query(getCreatableFieldsSOQL('zqu__Quote__c', 'id=\'' + quoteId + '\''));
  }


  /*
   Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
   */
  private static string getCreatableFieldsSOQL(String objectName, String whereClause) {
    String selects = '';
    if (whereClause == null || whereClause == '') {
      return null;
    }
    // Get a map of field name and field token
    Map < String, Schema.SObjectField > fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
    list < string > selectFields = new list < string > ();

    if (fMap != null) {
      // loop through all field tokens (ft)
      for (Schema.SObjectField ft: fMap.values()) {
        // describe each field (fd)
        Schema.DescribeFieldResult fd = ft.getDescribe();
        // field is creatable 
        if (fd.isCreateable()) {
            selectFields.add(fd.getName());
        }
      }
    }
    if (!selectFields.isEmpty()) {
      for (string s: selectFields) {
        selects += s + ',';
      }
      if (selects.endsWith(',')) {
        selects = selects.substring(0, selects.lastIndexOf(','));
      }
    }
    if (objectName == 'zqu__QuoteProductFeature__c') {
      selects += ',zqu__QuoteRatePlan__r.Name';
    }
    return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
  }
}