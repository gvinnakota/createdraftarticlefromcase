public with sharing class CustomSendToZbilling {

  private String quoteId {
    get;
    set;
  }

  public zqu__Quote__c quote {
    get;
    set;
  }

  public List < String > listofQuoteIds {
    get {
      if (listofQuoteIds == null) {
        listofQuoteIds = new List < String > ();
      }
      return listofQuoteIds;
    }
    set;
  }

  public List < zqu__Quote__c > listofSubQuotes {
    get {
      if (listofSubQuotes == null) {
        listofSubQuotes = new List < zqu__Quote__c > ();
      }
      return listofSubQuotes;
    }
    set;
  }


  public boolean readyToSend {
    get {
      System.debug('QUOTE ====> ' + quote);
      //throw new ZRestException('QUOTE: ' + quote);
      return (quote.State__c == 'New');
    }
    set;
  }

  public boolean showExistingCharges {
    get {
      if (showExistingCharges == null) {
        showExistingCharges = true;
      }
      return showExistingCharges;
    }
    set;
  }

  public Map < String, zqu.zChargeGroup > chargeToChargeGroupMap {
    get {
      if (chargeToChargeGroupMap == null) {
        chargeToChargeGroupMap = new Map < String, zqu.zChargeGroup > ();
      }
      return chargeToChargeGroupMap;
    }
    set;
  }

  public List < zqu__QuoteRatePlanCharge__c > existingQuoteCharges {
    get {
      if (existingQuoteCharges == null) {
        existingQuoteCharges = new List < zqu__QuoteRatePlanCharge__c > ();
      }
      return existingQuoteCharges;
    }
    set;
  }

  public class ChargeChargeGroupWrapper {
    public List<zqu__QuoteRatePlanCharge__c> charges {get; set;}
    public zqu.ZChargeGroup chargeGroup {get; set;}
  }

  public Map < String, List < ChargeChargeGroupWrapper > > separateChargeGroupMap {
    get {
      if (separateChargeGroupMap == null) {
        //ChargeChargeGroupWrapper wrapper = new ChargeChargeGroupWrapper();
        separateChargeGroupMap = new Map < String, List < ChargeChargeGroupWrapper > > ();
      }
      return separateChargeGroupMap;
    }
    set;

  }

  public Map < String, List < zqu__QuoteRatePlanCharge__c > > separateChargeMap {
    get {
      if (separateChargeMap == null) {
        separateChargeMap = new Map < String, List < zqu__QuoteRatePlanCharge__c > > ();
      }
      return separateChargeMap;
    }
    set;

  }

  // End variable declaration
  public CustomSendToZbilling(ApexPages.StandardController controller) {

    quoteId = controller.getId();

  }

  // Step #1 : this method is called when page is loaded.
  public PageReference checkOnLoad() {

    System.Debug('Step #0. CustomSendToZbilling.page is loaded for Quote: ' + quoteId);

    PageReference localPageRef = null;

    quote = [
      Select
        Id,
        Name,
        State__c,
        Error_Message__c,
        zqu__Opportunity__c,
        zqu__ZuoraAccountID__c,
        zqu__SubscriptionType__c,
        RecordTypeId
      FROM
        zqu__Quote__c
      WHERE
        id = : quoteId
      LIMIT 1
    ];

    System.debug('Quote.State: ' + quote.State__c);

    if (quote.Error_Message__c != null) {
      System.debug('Error_Message__c is not null => ' + quote.Error_Message__c);

      if (quote.Error_Message__c == 'Quote has been successfully sent to Zuora') {
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.severity.Confirm, 'Quote has been successfully sent to Zuora'));

        if (quote.State__c == 'Sent') {
          readyToSend = false; // disable submit button
        }         
      }
      else if (Quote.Error_Message__c == 'SubQuotes already exist for this Quote') {
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.severity.ERROR, 'SubQuotes already exist for this Quote'));
      }
      else if (Quote.Error_Message__c == 'Quote has already been sent') {
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.severity.WARNING, 'Quote has already been sent'));
      }
      else {
        ApexPages.addMessage(new ApexPages.Message(
          ApexPages.severity.ERROR, Quote.Error_Message__c));
      }

      if (quote.State__c == 'New') {
        //Quote.Error_Message__c = null;
        readyToSend = false; // disable submit button
      }
    }


    if (quote.State__c == 'RollBack') {
      System.debug('Rolling Back: Setting the quote state to "Deleting"');
      quote.State__c = 'Deleting';
      update quote;

      return localPageRef;
    }

    if (quote.State__c == 'Deleting') {
      ApexPages.addMessage(new ApexPages.Message(
          ApexPages.severity.ERROR, ''));
      
      ApexPages.addMessage(new ApexPages.Message(
          ApexPages.severity.ERROR, 'There was an issue sending this Quote to Zuora. Please contact the system admin with the error details shown above.'));
      return localPageRef;
    }

    // First step : prepare separateChargeMap with Quote_Split_Number__c
    // for splitQuote
    if (quote.State__c == 'New') {
        initNewQuote();
        readyToSend = true;
    }

    // Second step : This step is triggered when to send sub quotes to zbilling 
    if (quote.State__c == 'Sending') {
      Boolean sendSuccess;
      try {
        sendSuccess = SendToZbillingWithSplitQuotes.sendQuote(quoteId, quote, listofQuoteIds);
      }
      catch (exception e) {
        System.debug('EXCEPTION' + e);
        quote.Error_Message__c = (e.getMessage().length() > 255)? e.getMessage().substring(0,255) : e.getMessage();

        sendSuccess = false;
      }
      if (sendSuccess == true) {
        quote.State__c = 'Sent';
        update quote;

        // Force return here to refresh the page
        // before "if(quote.State__c == 'Sent')"
        // are executed. This will reset the 
        // "SOQL usage limit per page" to zero
        return getSelfReference(); 
      }
      if (sendSuccess == false) {

        quote.State__c = 'RollBack';
        update quote;

        return localPageRef;
      }

    }

    if (quote.State__c == 'Sent') {

      // set record type 
      Schema.DescribeSObjectResult dsr = Schema.SObjectType.zqu__Quote__c;
      Schema.RecordTypeInfo defaultrtinfo;
      if (quote.zqu__SubscriptionType__c == 'Amend Subscription') {
        defaultrtinfo = dsr.getRecordTypeInfosByName().get('Amendment ReadOnly'); 
      }
      else if (quote.zqu__SubscriptionType__c == 'Renew Subscription') {
        defaultrtinfo = dsr.getRecordTypeInfosByName().get('Renewal ReadOnly'); 
      }
      else {
        defaultrtinfo = dsr.getRecordTypeInfosByName().get('ReadOnly');
      }

      quote.RecordTypeId = defaultrtinfo.getRecordTypeId();


      if (!Test.isRunningTest()) {
        quote.zqu__Status__c = 'Sent to Z-Billing';

        Zuora_Custom_Setting__c setting = [SELECT Role_Name__c
                                                        FROM Zuora_Custom_Setting__c];

        UserRole userRole = [SELECT Id, Name
                              FROM UserRole
                              WHERE name = :setting.Role_Name__c];

        List<User> users = [SELECT Id, Name
                            FROM User
                            WHERE UserRoleId = :userRole.Id];

        String masterUser = users[0].Id;

        System.debug('user: '+users[0].Name);

        if (listofSubQuotes.size() > 0) {
          quote.zqu__ZuoraAccountID__c = listofSubQuotes[0].zqu__ZuoraAccountID__c;
        }

        for (zqu__Quote__c subQuote : listofSubQuotes) {
          subQuote.RecordTypeId = quote.RecordTypeId;
          subQuote.OwnerId = masterUser;
        }
        
      }

      ApexPages.addMessage(new ApexPages.Message(
        ApexPages.severity.Confirm, 'Quote has been successfully sent to Zuora'));

      Quote.Error_Message__c = 'Quote has been successfully sent to Zuora';
      update quote;
      update listofSubQuotes;

      //// This is handled in the subscriptionUpdateTrigger
      //// There should be only one primary quote. 
      //// If there is other primary quote found in the opporunity, set it to false.
      //for (zqu__Quote__c otherQuote : [SELECT Id, Primary_Quote__c 
      //                                 FROM zqu__Quote__c 
      //                                 WHERE zqu__Opportunity__c = : quote.zqu__Opportunity__c]) {
      //  if (otherQuote.Id != quote.Id && otherQuote.Primary_Quote__c == true) {
      //    otherQuote.Primary_Quote__c = false;
      //    update otherQuote;
      //  }
      //}

    }

    

    return localPageRef;
  }

  // Step #2 : this method is called when the page is loaded the first time
  public void initNewQuote() {

    System.debug('In initNewQuote() : Populate separateChargeMap with Quote_Split_Number__c as a Key');

    zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>{'Id'};

    for (zqu.zchargeGroup cg: zqu.zQuoteUtil.getChargeGroups(quoteId)) {
      System.Debug('Number of Charges:' + cg.zcharges.size());
      for (zqu.zCharge charge : cg.zcharges) {
        chargeToChargeGroupMap.put((String) charge.Id, cg);
      }      
    }

    // query charges from the quote submitted.
    existingQuoteCharges = [
      SELECT
      Id,
      Quote_Split_Number__c,
      zqu__QuoteRatePlan__c,
      Product_Rate_Plan__c,
      zqu__ProductRatePlanCharge__c,
      zqu__ProductRatePlanCharge__r.zqu__ZuoraId__c, 
      zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c, 
      zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name,
      zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.ProductServiceCategory__c,
      Start_Date__c,
      Initial_Term__c, zqu__EffectivePrice__c, zqu__ListPrice__c, zqu__Total__c, zqu__Quantity__c
      FROM
      zqu__QuoteRatePlanCharge__c
      WHERE
      Id IN: chargeToChargeGroupMap.keySet()
    ];


    for (zqu__QuoteRatePlanCharge__c qc: existingQuoteCharges) {

      // build charge group wrapper
      ChargeChargeGroupWrapper ccgWrapper = new ChargeChargeGroupWrapper();
      ccgWrapper.chargeGroup = chargeToChargeGroupMap.get(qc.Id);
      ccgWrapper.charges = new List<zqu__QuoteRatePlanCharge__c>();
      for (zqu.ZCharge charge : chargeToChargeGroupMap.get(qc.Id).zCharges) {
        ccgWrapper.charges.add((zqu__QuoteRatePlanCharge__c)charge.ChargeObject);
      }

      // populate separateChargeMap for split quote
      // this map will store the charges into separate group
      // based on Quote_Split_Number
      if (separateChargeMap.get(qc.Quote_Split_Number__c) == null) {
        // if there is no map found with quote split number
        separateChargeMap.put(qc.Quote_Split_Number__c, 
          new List < zqu__QuoteRatePlanCharge__c > { qc });
        separateChargeGroupMap.put(qc.Quote_Split_Number__c, 
          new List < ChargeChargeGroupWrapper > { ccgWrapper });

      } else {
        boolean found = false;
        for (zqu__QuoteRatePlanCharge__c cc : separateChargeMap.get(qc.Quote_Split_Number__c)){
          if (qc.zqu__QuoteRatePlan__c == cc.zqu__QuoteRatePlan__c){
            found = true;
          }
        }

        if(!found){
          // add charges to existing separateChargeMap
          separateChargeGroupMap.get(qc.Quote_Split_Number__c).add(ccgWrapper);
          separateChargeMap.get(qc.Quote_Split_Number__c).add(qc);
        }

      }

      System.Debug('SeparateChargeGroupMap: ' + separateChargeGroupMap);
      System.Debug('SeparateChargeGroupMap - SIZE: ' + separateChargeGroupMap.size());
    }
  }

  // STEP #3 : this method is called when submit button is clicked
  public PageReference callQuoteSplit() {
    System.debug('Step #1. Submit button is clicked for quote[' + quote.id + '] ' + quote.name);

    if (quote.State__c == 'New') {
      System.debug('In callQuoteSplit: Splitting quotes');

      // return list of subQuoteIds to send to Zuora
      listofQuoteIds = SendToZbillingWithSplitQuotes.quoteSplit(quoteId, separateChargeMap);

      System.debug('List of quote to send to z billing = ' + listofQuoteIds);
      if (listofQuoteIds.size() > 0) {
        if (listofQuoteIds[0] != 'Error') {
          System.debug('Quote.State__c = "Sending"');

          // after page is refreshed, sendQuote() will be called
          quote.State__c = 'Sending'; 
          update quote;
        }
      }
    }
    else{
      // TODO: shouldn't there be an error or warning message here?
      // quote cannot be splitted if quote.State__c != 'New'
      readyToSend = false; 

      quote.Error_Message__c = 'Quote is in wrong state.';
      update quote;
    }

    System.Debug('Step #2. Refreshing after Quote Split');

    return getSelfReference();
  }

  public PageReference getSelfReference() {
    System.Debug('Refreshing the page...');
    PageReference pageRef = Page.CustomSendToZBilling;
    pageRef.setRedirect(true);
    pageRef.getParameters().put('id', quoteId);
    return pageRef;
  }

  public PageReference returnToQuote() {
    System.debug('Returning to quote.');
    PageReference pageRef = new PageReference('/' + quoteId);
    pageRef.setRedirect(true);
    return pageRef;
  }
}