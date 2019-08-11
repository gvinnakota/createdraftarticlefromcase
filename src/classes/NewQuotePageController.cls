global with sharing class NewQuotePageController extends zqu.PropertyComponentController.ParentController {
  
  public zqu.PropertyComponentOptions propertyOptions{
    get;
    set;
  }

  public zqu.LookupComponentOptions optionsForBillTo {
    get{
      if(optionsForBillTo == null){
        optionsForBillTo = makeContactOptions('BillToContact');
      }
      return optionsForBillTo;
    }
    set;

  }

  public zqu.LookupComponentOptions optionsForSoldTo {
    get{
      if(optionsForSoldTo == null){
        optionsForSoldTo = makeContactOptions('SoldToContact');
      }
      return optionsForSoldTo;
    }
    set; 

  }

  public List < zqu.zChargeGroup > existingChargeGroups {
    get {
      if (existingChargeGroups == null) {
        existingChargeGroups = new List < zqu.zChargeGroup > ();
      }
      return existingChargeGroups;
    }
    set;
  }

  public String billingMethod {
    get{
      if(billingMethod == null && billingMethodValues.size() > 0){
        billingMethod = billingMethodValues[0].getValue();
      }
      return billingMethod;
    }
    set;
  }

  public boolean hasError {get;set;}
  public boolean needRecalculateMetrics {get;set;}

  public String paymentPlanSelection {
    get{
      if (paymentPlanSelection == null && paymentPlanValues.size() > 0) {
          paymentPlanSelection = paymentPlanValues[0].getValue();
      }
      return paymentPlanSelection;
    }
    set;
  }

  public String companyCodeSelection {
    get{
      if (companyCodeSelection == null && companyCodeValues.size() > 0) {
          companyCodeSelection = companyCodeValues[0].getValue();
      }
      return companyCodeSelection;
    }
    set;
  }

  public String currencyVal {get;set;}

  public String quoteType{get;set;}

  public String quoteId{get;set;}

  public String billingAccountId{get;set;}

  public String editMode{get;set;}

  public boolean lockAccountFields{get;set;}

  public boolean deleteChargeGroups{get;set;}

  public boolean isCurrencyEditable {get;set;}
  public boolean hasPrivilege {get;set;}

  public boolean needShippingAddress {get;set;}

  public boolean paymentPlanEditable {get;set;}

  public Zuora.zObject subzobj {get;set;}

   public static final String NONE = '-- none --';

  public List<SelectOption> paymentPlanValues {
    get {
      if (paymentPlanValues == null) {
        paymentPlanValues = getFieldValues('zqu__Quote__c', 'Payment_Plan__c');
      }
      return paymentPlanValues;
    }
    set;
  }

  public List<SelectOption> companyCodeValues {
    get {
      if (companyCodeValues == null) {
        companyCodeValues = getFieldValues('zqu__Quote__c', 'Company_Code1__c');
      }
      return companyCodeValues;
    }
    set;
  }

  public List<SelectOption> billingMethodValues {
    get {
      if (billingMethodValues == null) {
        billingMethodValues = getFieldValues('zqu__Quote__c', 'zqu__BillingMethod__c');
      }
      return billingMethodValues;
    }
    set;
  }

  public List<SelectOption> currencyValues {
    get {
      if (currencyValues == null) {
        currencyValues = new List<SelectOption>();
      }
      return currencyValues;
    }
    set;
  }

  public Opportunity opp{
    get{
      if(opp == null){
        String oppId = ApexPages.currentPage().getParameters().get('oppId');
        List<Opportunity> oppList = [SELECT Id, AccountId, Name, Account.ParentId FROM Opportunity WHERE Id = :oppId LIMIT 1];
        if (oppList.size() > 0) {
          opp = oppList[0];
        }
        
      }
      return opp;
    }
    set;
  }

  public Account acct{
    get{
      if(acct == null){
        String acctId = ApexPages.currentPage().getParameters().get('crmAccountId');
        List<Account> acctList = [SELECT Id, Name, ParentId FROM Account WHERE Id = :acctId LIMIT 1];
        if (acctList.size() > 0) {
          acct = acctList[0];
        }
        
      }
      return acct;
    }
    set;
  }

  public zqu__Quote__c quote{
    get{
      if(quote == null){
        quote = new zqu__Quote__c();
      }
      return quote;
    }
    set;
  }

  public string selectedPaymentMethod{
    get;
    set;
  }

  public String selectedContact{
    get;
    set;
  }

  public String originalSelectedContact{
    get;
    set;
  }

  public zqu.NotificationOptions notificationOptions {
    get;
    set;
  }


  public List<string> oldContacts{
    get {
      if(oldContacts == null){
        oldContacts = new List<String>();
      }
      return oldContacts;
    }
    set;
  }

   public Boolean getOverridePaymentPlanVisibleForUser {
       get {
           return Product_Selector_View_Settings__c.getInstance().Exposed_Specific_Billing_Period__c;
       }
       set;
   }

  private void appendMessage(ApexPages.Severity severity, String message) {
    ApexPages.addMessage(new ApexPages.Message(severity, message));
  }

  private ApexPages.StandardController controller;

  public NewQuotePageController(ApexPages.StandardController std) {
    try {
      this.quoteType = ApexPages.currentPage().getParameters().get('quoteType');

      this.editMode = ApexPages.currentPage().getParameters().get('editMode');

      this.quoteId = ApexPages.currentPage().getParameters().get('quoteId');

      this.billingAccountId = ApexPages.currentPage().getParameters().get('billingAccountId');

      this.needRecalculateMetrics = false;

      if (String.isBlank(this.quoteType)) {
        //throw new zqu.ZQException('Need to specify the quotetype in the url.');
        this.appendMessage(ApexPages.Severity.ERROR, 'Need to specify the quotetype in the url.');
      }
      // Set the record type Id based on the quote type
      final String recordTypeName = this.quoteType == 'Subscription' ? 'Default' : this.quoteType;

      Schema.SObjectType objectType = zqu__Quote__c.sObjectType;
      Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = objectType.getDescribe().getRecordTypeInfosByName();

      this.propertyOptions = new zqu.PropertyComponentOptions();
      this.propertyOptions.recordTypeId = recordTypeInfoMap.get(recordTypeName).getRecordTypeId();

      Zuora_Custom_Setting__c customSetting = [SELECT Name, Profile_Names__c
                                              FROM Zuora_Custom_Setting__c];

      String profileNames = customSetting.Profile_Names__c;
      List<String> profileList = profileNames.split(',', 0);

      List<Profile> profiles = [SELECT id, Name
                            FROM Profile
                            WHERE name in :profileList];

      this.hasPrivilege = false;

      for (Profile profile : profiles) {
        if (UserInfo.getProfileId() == profile.Id) {
              System.debug('*****User Info: '+profile);

          this.hasPrivilege = true;
        }
      }

      System.debug('currency editable: '+this.hasPrivilege);



      if (this.editMode == 'true') {
        this.quote = [SELECT Id,
                        Name,
                        zqu__Account__r.name,
                        zqu__BillToContact__c,
                        zqu__BillToContact__r.Name,
                        zqu__BillToContact__r.MailingStreet,
                        zqu__BillToContact__r.MailingCity,
                        zqu__BillToContact__r.MailingCountryCode,
                        zqu__BillToContact__r.MailingPostalCode,
                        zqu__BillToContact__r.MailingStateCode,
                        zqu__BillToContact__r.FirstName,
                        zqu__BillToContact__r.LastName,
                        zqu__BillToContact__r.Contact_Company__c,
                        zqu__SoldToContact__c,
                        zqu__SoldToContact__r.Name,
                        zqu__SoldToContact__r.MailingStreet,
                        zqu__SoldToContact__r.MailingCity,
                        zqu__SoldToContact__r.MailingCountryCode,
                        zqu__SoldToContact__r.MailingPostalCode,
                        zqu__SoldToContact__r.MailingStateCode,
                        zqu__SoldToContact__r.FirstName,
                        zqu__SoldToContact__r.LastName,
                        zqu__SoldToContact__r.Contact_Company__c,
                        Contact_Address__c,
                        Contact_Email__c,
                        Sold_Contact_Email__c,
                        Sold_Contact_Address__c,
                        Ship_Contact_Address__c,
                        Sold_Contact_Address2__c,
                        Ship_Contact_Address2__c,
                        Contact_Address2__c,
                        Company_Code1__c,
                        Channel__c,
                        zqu__Currency__c,
                        Same_As_Bill_To_Contact__c,
                        Shipping_Address_Needed__c,
                        Payment_Plan__c,
                        Ship_To_First_Name__c,
                        Ship_To_Last_Name__c,
                        Ship_Contact_Email__c,
                        zqu__BillingMethod__c,
                        Tax_Exempt__c,
                        Certificate_Id1__c,
                        VAT_ID1__c,
                        Contact_Company__c,
                        Sold_Contact_Company__c,
                        zqu__Status__c,
                        zqu__Opportunity__c,
                      zqu__Opportunity__r.Opportunity_Number__c,
                        zqu__Account__c,
                        zqu__SubscriptionTermEndDate__c,
                        zqu__SubscriptionTermStartDate__c,
                        zqu__StartDate__c,
                        zqu__InitialTerm__c,
                        zqu__RenewalTerm__c,
                        zqu__Subscription_Term_Type__c,
                        Subscription_Type__c,
                        zqu__ZuoraAccountID__c,
                        Document_Type__c,
                        Primary_Quote__c,
                        PurchaseOrder__c,
                        Pricing_Justification__c,
                        zqu__QuoteTemplate__c,
                        ChannelOrderID__c,
                        zqu__ValidUntil__c,
                        Has_Special_Terms__c,
                        zqu__Terms__c,
                        zqu__PaymentMethod__c,
                        zqu__PaymentTerm__c,
                        zqu__SubscriptionType__c,
                        zqu__Amendment_Name__c,
                        zqu__ZuoraSubscriptionID__c,
                        Company_Address__c,
                        zqu__ExistSubscriptionID__c,
                        zqu__InvoiceSeparately__c,
                        Override_Payment_Plan__c
                FROM zqu__Quote__c
                WHERE id = :this.quoteId];

        this.paymentPlanSelection = quote.Payment_Plan__c;
        this.billingMethod = quote.zqu__BillingMethod__c;


        List<Company_Code__c> companyCodeList = [SELECT ID,
                    Code__c,
                    Currency__c,
                    Country__c,
                    City__c,
                    Currency_Picklist__c
                    FROM Company_Code__c
                    WHERE Code__c = :quote.Company_Code1__c];

        if (companyCodeList.size() > 0) {
            if (companyCodeList.size() == 1) {
              Company_Code__c companyCode = companyCodeList[0];
              this.currencyValues = getCurrencyValues(companyCode.Currency_Picklist__c);
              this.currencyVal = companyCode.Currency__c;
            } else {
              for (Company_Code__c companyCode : companyCodeList) {
                this.currencyValues = getCurrencyValues(companyCode.Currency_Picklist__c);
                this.currencyVal = companyCode.Currency__c;
              }
            }
            
          } else {

            List<Company_Code__c> ieCode = [SELECT ID,
                    Code__c,
                    Address__c,
                    Currency_Picklist__c,
                    Currency__c
                    FROM Company_Code__c
                    WHERE Code__c = 'IE19'];
            if(ieCode.size()> 0){
              this.currencyValues = getCurrencyValues(ieCode[0].Currency_Picklist__c);
              this.currencyVal = ieCode[0].Currency__c;
            }
          }

      } else {
        this.quote = new zqu__Quote__c();
        //Tax Exempt bullshit is bullshit
//        this.quote.Tax_Exempt__c = true;
//        this.quote.Certificate_ID1__c = 1111;
//        this.quote.VAT_ID1__c = 2222;
      }
      
      this.optionsForBillTo = makeContactOptions('BillToContact');
      this.optionsForSoldTo = makeContactOptions('SoldToContact');

      controller = std;

      System.debug('zqu__ZuoraAccountID__c = ' + this.quote.zqu__ZuoraAccountID__c);
      if (this.billingAccountId != null && this.billingAccountId != ''){
        System.debug('EXISTING BILLING ACCOUNT DETECTED');
        this.lockAccountFields = true;
      } else if((this.quote != null) && (this.quote.zqu__Status__c == 'Sent to Z-Billing')){
        System.debug('QUOTE HAS BEEN SENT TO Z-BILLING');
        this.lockAccountFields = true;
      } else if(this.quote.zqu__ZuoraAccountID__c != null){
        System.debug('EDITING QUOTE WITH EXISTING BILLING ACCOUNT');
        this.lockAccountFields = true;
      }else {
        System.debug('NO EXISTING BILLING ACCOUNT IDENTIFIED');
        this.lockAccountFields = false;
      }
      
      
      this.propertyOptions.objectName = 'zqu__Quote__c';
      if (this.editMode == 'true') {
        this.propertyOptions.propertyPageTitle = 'Edit Quote Details';
      } else {
        this.propertyOptions.propertyPageTitle = 'Create Quote Page';
      }
      this.propertyOptions.parentController = this;
      this.propertyOptions.instanceName = 'sampleProperty';
      
      //propertyOptions.recordTypeId = recordTypeInfoMap.get('Default').getRecordTypeId();
      //make fields read only
      this.propertyOptions.readonlyFields.add('zqu__Status__c');
      this.propertyOptions.readonlyFields.add('zqu__Opportunity__c');
      this.propertyOptions.readonlyFields.add('zqu__Account__c');
      this.propertyOptions.readonlyFields.add('zqu__Opportunity__r.Opportunity_Number__c');

      if (this.quoteType == 'Amendment') {
        this.propertyOptions.readonlyFields.add('zqu__SubscriptionTermEndDate__c');
        this.propertyOptions.readonlyFields.add('zqu__SubscriptionTermStartDate__c');
        this.propertyOptions.readonlyFields.add('zqu__InitialTerm__c');
      }
      if (this.quoteType == 'Renewal') {
        this.propertyOptions.readonlyFields.add('zqu__SubscriptionTermStartDate__c');
        this.propertyOptions.readonlyFields.add('zqu__SubscriptionTermEndDate__c');
        //this.propertyOptions.readonlyFields.add('zqu__StartDate__c');
      }

      System.debug('LOCK ACCOUNT FIELDS? ' + this.lockAccountFields);
      if(this.lockAccountFields){
        this.propertyOptions.readonlyFields.add('zqu__BillToContact__c');
        this.propertyOptions.readonlyFields.add('zqu__SoldToContact__c');
        this.propertyOptions.readonlyFields.add('Tax_Exempt__c');
        this.propertyOptions.readonlyFields.add('VAT_ID1__c');
        this.propertyOptions.readonlyFields.add('Certificate_Id1__c');
        this.propertyOptions.readonlyFields.add('zqu__PaymentTerm__c');
        this.propertyOptions.readonlyFields.add('Channel__c');
        this.propertyOptions.readonlyFields.add('zqu__BillingMethod__c');
        //this.propertyOptions.readonlyFields.add('Contact_Company__c');
        //this.propertyOptions.readonlyFields.add('Sold_Contact_Company__c');
      } else {
        this.propertyOptions.lookupFields.put('zqu__BillToContact__c' , optionsForBillTo);
        this.propertyOptions.lookupFields.put('zqu__SoldToContact__c' , optionsForSoldTo);
        //this.propertyOptions.customRenderingFields.add('Tax_Exempt__c');
        this.propertyOptions.customRenderingFields.add('Certificate_Id1__c');
        this.propertyOptions.customRenderingFields.add('Channel__c');
        this.propertyOptions.customRenderingFields.add('zqu__BillingMethod__c');
        //this.propertyOptions.customRenderingFields.add('Contact_Company__c');
        //this.propertyOptions.customRenderingFields.add('Sold_Contact_Company__c');
      }
      this.propertyOptions.customRenderingFields.add('Tax_Exempt__c');
      this.propertyOptions.customRenderingFields.add('Contact_Company__c');
      this.propertyOptions.customRenderingFields.add('Sold_Contact_Company__c');

      //hide fields
      this.propertyOptions.hiddenFields = new Set<String>{'zqu__Number__c', 'zqu__AutoRenew__c',
                                                     'zqu__Previewed_MRR__c', 'zqu__Previewed_TCV__c', 'zqu__Previewed_Tax__c',
                                                     'zqu__Previewed_Total__c', 'zqu__Previewed_SubTotal__c', 'zqu__Previewed_Discount__c',
                                                     'zqu__ZuoraAccountID__c', 'zqu__ZuoraPaymentID__c', 
                                                     'zqu__ZuoraSubscriptionID__c', 'zqu__Zuora_Account_Number__c', 'zqu__InvoiceID__c',
                                                     'zqu__Subscription_Term_Type__c'};

      this.propertyOptions.viewType = zqu.ViewConfigurationManager.VIEW_CONFIGURATION_VIEW_TYPE_CREATE;
      this.propertyOptions.isEditMode = true;
      this.propertyOptions.relatedObjectPlugin = 'NewQuotePageController.PopulateRelatedObjectFieldPlugin';
      this.propertyOptions.updatePlugin = 'NewQuotePageController.SaveRecordPlugin';

      
      if (billingaccountId == null || billingaccountId == '') {
        this.isCurrencyEditable = true;
      } else {
        this.isCurrencyEditable = false;
      }
      System.debug('currency stuff: '+this.isCurrencyEditable);
      //this.propertyOptions.lookupFields.put('zqu__BillToContact__c' , optionsForBillTo);
      //this.propertyOptions.lookupFields.put('zqu__SoldToContact__c' , optionsForSoldTo);
      //this.propertyOptions.readonlyFields.add('zqu__BillToContact__c');
      
      //Custom Rendered Fields

      this.propertyOptions.customRenderingFields.add('Pricing_Justification__c');

      //propertyOptions.customRenderingFields.add('zqu__BillToContact__c');
      this.propertyOptions.customRenderingFields.add('Contact_Address__c');
      this.propertyOptions.customRenderingFields.add('Contact_Email__c');
      this.propertyOptions.customRenderingFields.add('Sold_Contact_Email__c');
      //propertyOptions.customRenderingFields.add('Ship_To_Email__c');
      this.propertyOptions.customRenderingFields.add('Sold_Contact_Address__c');
      this.propertyOptions.customRenderingFields.add('Ship_Contact_Address__c');
      this.propertyOptions.customRenderingFields.add('Sold_Contact_Address2__c');
      this.propertyOptions.customRenderingFields.add('Ship_Contact_Address2__c');
      this.propertyOptions.customRenderingFields.add('Contact_Address2__c');
      this.propertyOptions.customRenderingFields.add('Company_Code1__c');
      //this.propertyOptions.customRenderingFields.add('Channel__c');
      if (this.quoteType == 'Subscription') {
        this.propertyOptions.customRenderingFields.add('zqu__Currency__c');
      }
      this.propertyOptions.customRenderingFields.add('Same_As_Bill_To_Contact__c');
      //this.propertyOptions.customRenderingFields.add('Tax_Exempt__c');
      this.propertyOptions.customRenderingFields.add('Shipping_Address_Needed__c');
      this.propertyOptions.customRenderingFields.add('Payment_Plan__c');
      this.propertyOptions.customRenderingFields.add('Override_Payment_Plan__c');
      this.propertyOptions.customRenderingFields.add('Ship_To_First_Name__c');
      this.propertyOptions.customRenderingFields.add('Ship_To_Last_Name__c');
      this.propertyOptions.customRenderingFields.add('Ship_Contact_Email__c');
      //this.propertyOptions.customRenderingFields.add('zqu__BillingMethod__c');
      this.propertyOptions.customRenderingFields.add('ChannelOrderID__c');
      this.propertyOptions.customRenderingFields.add('PurchaseOrder__c');
      this.propertyOptions.customRenderingFields.add('zqu__StartDate__c');
      //this.propertyOptions.customRenderingFields.add('Document_Type__c');
      
      this.propertyOptions.customRenderingFields.add('zqu__QuoteTemplate__c');
      //this.propertyOptions.customRenderingFields.add('Certificate_Id1__c');

      notificationOptions = new zqu.NotificationOptions();
      notificationOptions.isPopup = true;
      notificationOptions.continueAction = 'stayOnCurrentPage();';
      notificationOptions.continueLabel = 'Ok';

      
      //Custom rendered lookup
      
      this.propertyOptions.populateValuePlugin = 'NewQuotePageController.DefaultValuesPlugin';
      
      // propertyOptions.updatePlugin = 'PropertyComponentSampleController.UpdateRecordPlugin';
      this.propertyOptions.cancelPlugin = 'NewQuotePageController.CancelRecordPlugin';
      hasError = false;
      this.deleteChargeGroups = false;
    }
    catch (Exception e) {
      this.appendMessage(ApexPages.Severity.ERROR, 'The following error occured while loading the page: '+e.getMessage());
      hasError = true;
    }
  }

  public List<SelectOption> getFieldValues(String objectName, String fieldName) {
    List<SelectOption> options = new List<SelectOption>();
      //options.add(new Selectoption('All', 'All'));
      System.debug('populating field values: ');

    SObjectType objType = Schema.getGlobalDescribe().get(objectName);
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();       
      map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
      list<Schema.PicklistEntry> values = fieldMap.get(fieldName).getDescribe().getPickListValues();
        System.debug('values: '+values);
      for (Schema.PicklistEntry a : values)
      { 
        if ((a.getValue() == 'Monthly')||(a.getValue() == 'Quarterly')||(a.getValue() == 'Semi-Annual')) {

          if (this.hasPrivilege) {
            options.add(new SelectOption(a.getLabel(), a.getValue())); 
          }
        } else {
          options.add(new SelectOption(a.getLabel(), a.getValue()));
        }
      } 
      
    return options;

  }

  public List<SelectOption> getCurrencyValues(String values) {
    List<SelectOption> options = new List<SelectOption>();

    String[] valueArray = values.split(';');

    for (String value : valueArray)
    { 
      options.add(new SelectOption(value, value)); 
    } 
      
    return options;

  }

  public PageReference shippingCheckBoxChange() {
    if (quote.Shipping_Address_Needed__c == true) {
      needShippingAddress = true;
    } else {
      needShippingAddress = false;
    }
    return null;
  }

  public PageReference paymentPlanChange() {
    quote.Payment_Plan__c = this.paymentPlanSelection;
    return null;
  }

  public PageReference channelChange() {
    List<Channel__c> channel = [SELECT Name,
                ID, 
                Channel_Type__c,
                Tax_Exempt_Status__c,
                Indirect_Warning__c,
                Certificate_Id__c
                FROM Channel__c
                WHERE Name = :quote.Channel__c];

/*    if(quote.Channel__c != 'Pivotal Direct'){
      this.appendMessage(ApexPages.Severity.WARNING, 'You are creating a quote for an indirect deal. Please ensure that you add the Channel (EMC / VMware) contact address in the Bill To contact.');
    }*/

    //System.debug('[CTH]========> QUOTE CHANNEL NAME: ' + quote.Channel__c);
    //System.debug('[CTH]========> CHANNEL QUERY SIZE: ' + channel.size());
    //System.debug('[CTH]========> CHANNEL NAME: ' + channel[0].Name);
    //System.debug('[CTH]========> CHANNEL ID: ' + channel[0].ID);
    //System.debug('[CTH]========> CHANNEL TYPE: ' + channel[0].Channel_Type__c);
    //System.debug('[CTH]========> CHANNEL TAX EXEMPT STATUS: ' + channel[0].Tax_Exempt_Status__c);
    //System.debug('[CTH]========> CHANNEL CERT ID: ' + channel[0].Certificate_Id__c);

/*    if(channel[0].Channel_Type__c == 'Indirect'){
      if(channel[0].Name != 'Federation'){
        this.appendMessage(ApexPages.Severity.WARNING, 'You are creating a quote for an indirect deal. Please ensure that you add the Channel (EMC / VMware) contact address in the Bill To contact.');
      }
    }*/
    if(channel.size() > 0 && channel[0].Indirect_Warning__c == true){
      this.appendMessage(ApexPages.Severity.WARNING, 'You are creating a quote for an indirect deal. Please ensure that you add the Channel (EMC / VMware) contact address in the Bill To contact.');
    }

    if(channel.size() > 0 && channel[0].Tax_Exempt_Status__c == true){
      System.debug('[CTH]=======> THIS CHANNEL IS TAX EXEMPT');
      quote.Tax_Exempt__c = true;
      quote.Certificate_Id1__c = channel[0].Certificate_Id__c;
    } else {
      //quote.Tax_Exempt__c = false;
    }

    return null;
  }

  public PageReference companyCodeChange() {
    quote.Company_Code1__c = this.companyCodeSelection;
    System.debug('company code selection: '+this.companyCodeSelection);
    if (this.quoteType == 'Subscription') {
      List<Company_Code__c> companyCodeList = [SELECT ID,
                    Code__c,
                    Currency__c,
                    Country__c,
                    City__c,
                    Currency_Picklist__c,
                    Address__c
                    FROM Company_Code__c
                    WHERE Code__c = :this.companyCodeSelection];
      if(companyCodeList.size() > 0){
        this.currencyValues = getCurrencyValues(companyCodeList[0].Currency_Picklist__c);
        quote.Company_Address__c = companyCodeList[0].Address__c;
        
        //implement 
        boolean currencyExist = false;
        for (Selectoption currencyValue : this.currencyValues) {
          if (currencyValue.getValue() == this.currencyVal) {
            currencyExist = true;
            break;
          }
        }
        if (!currencyExist) {
          this.currencyVal = companyCodeList[0].Currency__c;
          currencyChange();
        }
      }
      //this.currencyVal = 
    }
    return null;
  }

  public PageReference billingMethodChange() {
    quote.zqu__BillingMethod__c = this.billingMethod;
    return null;
  }

  public PageReference currencyChange() {
    //quote.zqu__Currency__c = this.currencyVal;
    if (this.editMode == 'true' && quote.zqu__SubscriptionType__c == 'New Subscription' && this.currencyVal != quote.zqu__Currency__c) {
      deleteChargeGroups = true;
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Changing currency will delete all products selected on the quote. To ensure information does not get lost, rate plans will need to be re-added to the quote after save.'));
    } else {
      deleteChargeGroups = false;
    }
    return null;
  }

  public PageReference contactCheckBoxChange() {
    if (quote.Same_As_Bill_To_Contact__c == true) {
      quote.zqu__SoldToContact__c = quote.zqu__BillToContact__c;
      System.debug('sold to: '+quote.zqu__SoldToContact__c);

      String soldToContact = quote.zqu__SoldToContact__c;
      if (soldToContact != null && soldToContact != '') {
        Contact ctct = [SELECT Id,
                    MailingStreet,
                    Name,
                    MailingCity,
                    MailingState,
                    MailingPostalCode,
                    MailingCountry,
                    MailingCountryCode,
                    Contact_Company__c,
                    Email
                    FROM Contact
                    WHERE Id = :quote.zqu__SoldToContact__c];

        String mailingCity = '';
        String mailingState = '';
        String mailingPostalCode = '';
        String mailingCountry = '';
        String mailingStreet = '';
        String email = '';
        String contactCompany = '';

        if (ctct.MailingStreet != null) {
          mailingStreet = ctct.MailingStreet;
        }

        if (ctct.MailingCity != null) {
          mailingCity = ctct.MailingCity;
        }
        if (ctct.MailingState != null) {
          mailingState = ctct.MailingState;
        }
        if (ctct.MailingPostalCode != null) {
          mailingPostalCode = ctct.MailingPostalCode;
        }
        if (ctct.MailingCountry != null) {
          mailingCountry = ctct.MailingCountry;
        }
        if (ctct.Email != null) {
          email = ctct.Email;
        }
        if (ctct.Contact_Company__c != null){
          contactCompany = ctct.Contact_Company__c;
        }

        optionsForSoldTo.TargetId = ctct.Id;
        optionsForSoldTo.TargetName = ctct.Name;
        quote.Sold_Contact_Address__c = mailingStreet;
          
        quote.Sold_Contact_Address2__c = mailingCity+', '+mailingState+' '+mailingPostalCode+' '+mailingCountry;
        quote.Sold_Contact_Email__c = email;

        quote.Sold_Contact_Company__c = contactCompany;

        if (editMode == 'true' && quote.zqu__SubscriptionType__c == 'New Subscription') {
          Map<String, Decimal> results = updateMetrics(quote, existingChargeGroups);
          needRecalculateMetrics = true;
          if (results.get('totalTCV') != null && results.get('totalMRR') != null) {
            quote.Calculated_Total_TCV__c = String.valueOf(results.get('totalTCV').setScale(2));
            quote.Calculated_Total_MRR__c = String.valueOf(results.get('totalMRR').setScale(2));
            quote.Calculated_SubTotal__c = String.valueOf(results.get('totalSubtotal').setScale(2));
            quote.Calculated_Tax__c = String.valueOf(results.get('totalTax').setScale(2));
            quote.Calculated_Total__c = String.valueOf(results.get('totalTotal').setScale(2));
          } else {
            quote.Calculated_Total_TCV__c = 'Error in Calculating Metrics';
            quote.Calculated_Total_MRR__c = 'Error in Calculating Metrics';
            quote.Calculated_SubTotal__c = 'Error in Calculating Metrics';
            quote.Calculated_Tax__c = 'Error in Calculating Metrics';
            quote.Calculated_Total__c = 'Error in Calculating Metrics';
          }
        }
      }
    } else {
      optionsForSoldTo.TargetId = '';
      optionsForSoldTo.TargetName = '';
      quote.Sold_Contact_Address__c = '';
        
      quote.Sold_Contact_Address2__c = '';
      quote.Sold_Contact_Email__c = '';
      quote.Sold_Contact_Company__c = '';

    }
    System.debug('payment plan selection: ' + this.paymentPlanSelection);
    return null;
  }

  //Return a page reference to the next page to be navigated to
  public PageReference continueToNextPage() {
    return new PageReference('/apex/SamplePage');
  }
 
  //Return a null page reference to clear out page messages and stay on current page
  public PageReference stayOnCurrentPage() {
    return null;
  }


  public PageReference onTaxExemptChange() {
    if (editMode == 'true' && quote.zqu__SubscriptionType__c == 'New Subscription') {
      System.debug('tax exempt: '+quote.Tax_Exempt__c);
      Map<String, Decimal> results = updateMetrics(quote, existingChargeGroups);
      needRecalculateMetrics = true;
      if (results.get('totalTCV') != null && results.get('totalMRR') != null) {
        quote.Calculated_Total_TCV__c = String.valueOf(results.get('totalTCV').setScale(2));
        quote.Calculated_Total_MRR__c = String.valueOf(results.get('totalMRR').setScale(2));
        quote.Calculated_SubTotal__c = String.valueOf(results.get('totalSubtotal').setScale(2));
        quote.Calculated_Tax__c = String.valueOf(results.get('totalTax').setScale(2));
        quote.Calculated_Total__c = String.valueOf(results.get('totalTotal').setScale(2));
      } else {
        quote.Calculated_Total_TCV__c = 'Error in Calculating Metrics';
        quote.Calculated_Total_MRR__c = 'Error in Calculating Metrics';
        quote.Calculated_SubTotal__c = 'Error in Calculating Metrics';
        quote.Calculated_Tax__c = 'Error in Calculating Metrics';
        quote.Calculated_Total__c = 'Error in Calculating Metrics';
      }
    }
    return null;
  }

  public PageReference loadOriginalContacts() {
    oldContacts = originalSelectedContact.split(',');
    return null;
  }

  public PageReference onContactChange() {
    //System.debug('Contact Address: '+selectedContact+' contact: '+quote.zqu__BillToContact__c+'property id: '+optionsForBillTo);

    System.debug('Contact has been changed');

    List<String> currContacts = selectedContact.split(',');
    String currContact = '';

    Integer counter = 0;
    if (oldContacts.size() <= 0) {
      currContact = currContacts.get(0);

    } else if (currContacts.size() == 1) {
      currContact = currContacts.get(0);
      counter = 1;
    } else {
      for (Integer i = 0 ; i < currContacts.size() ; i++) {
        if (oldContacts.get(i) != currContacts.get(i)) {
          currContact = currContacts.get(i);
          break;
        }
        counter++;
      }
    }

    System.debug('Current Contact =' + currContact);

    if (currContact.trim() != '' && currContact.trim() != 'null') {

      Contact ctct = [SELECT ID,
                    MailingStreet,
                    Name,
                    MailingCity,
                    MailingState,
                    MailingStateCode,
                    MailingPostalCode,
                    MailingCountry,
                    MailingCountryCode,
                    Contact_Company__c,
                    Email
                    FROM Contact
                    WHERE Id = :currContact];

      System.debug('Contact =' + ctct);

      String mailingCity = '';
      String mailingState = '';
      String mailingStateCode = '';
      String mailingPostalCode = '';
      String mailingCountry = '';
      String mailingCountryCode = '';
      String mailingStreet = '';
      String email = '';
      String contactCompany = '';

      if (ctct.MailingStreet != null) {
        mailingStreet = ctct.MailingStreet;
      }

      if (ctct.MailingCity != null) {
        mailingCity = ctct.MailingCity;
      }
      if (ctct.MailingState != null) {
        mailingState = ctct.MailingState;
      }
      if (ctct.MailingStateCode != null) {
        mailingStateCode = ctct.MailingStateCode;
      }
      if (ctct.MailingPostalCode != null) {
        mailingPostalCode = ctct.MailingPostalCode;
      }
      if (ctct.MailingCountry != null) {
        mailingCountry = ctct.MailingCountry;
      }
      if (ctct.Email != null) {
        email = ctct.Email;
      }
      if (ctct.MailingCountryCode != null) {
        mailingCountryCode = ctct.MailingCountryCode;
      }
      if (ctct.Contact_Company__c != null) {
        contactCompany = ctct.Contact_Company__c;
      }

      if (counter < 3) {
        if (counter == 0) {

          if(ctct.Id != null){
            quote.zqu__BillToContact__c = ctct.Id;
            optionsForBillTo.TargetId = ctct.Id;
          }

          if(ctct.Name != null){
            optionsForBillTo.TargetName = ctct.Name;
          }

          quote.Contact_Address__c = mailingStreet;

          quote.Contact_Address2__c = mailingCity+', '+mailingState+' '+mailingPostalCode+' '+mailingCountry;
          if (ctct.MailingCountry == 'United States' || ctct.MailingCountry == 'US' || ctct.MailingCountry == 'USA') {
            System.debug('selected us');
            mailingCountry = '%United States%';
          } else {
            mailingCountry = '%'+mailingCountry.trim()+'%';
          }
          
          quote.Contact_Email__c = email;

          quote.Contact_Company__c = contactCompany;

          if (this.billingAccountId == null || this.billingAccountId == '') {

            List<Company_Code__c> companyCodeList = [SELECT ID,
                      Code__c,
                      Currency__c,
                      Country__c,
                      City__c,
                      Currency_Picklist__c,
                      Default__c,
                      Address__c
                      FROM Company_Code__c
                      WHERE Country__c = :mailingCountryCode];

                      System.debug('Quote.Channel__c=' + quote.Channel__c);

            Company_Code__c selectedCompanyCode = new Company_Code__c();
            if (companyCodeList.size() > 0) {
              if (companyCodeList.size() == 1) {
                selectedCompanyCode = companyCodeList[0];
              } else {
                Company_Code__c defaultCompanyCode = new Company_Code__c();
                boolean found = false;
                for (Company_Code__c companyCode : companyCodeList) {
                  if (companyCode.City__c.trim() == mailingStateCode) {
                    found = true;
                    selectedCompanyCode = companyCode;
                  }
                  if (companyCode.Default__c) {
                    defaultCompanyCode = companyCode;
                  }
                }
                if (!found) {
                  selectedCompanyCode = defaultCompanyCode;
                }
              }
              
            } else {

              List<Company_Code__c> ieCode = [SELECT ID,
                      Code__c,
                      Address__c,
                      Currency_Picklist__c,
                      Currency__c
                      FROM Company_Code__c
                      WHERE Code__c = 'IE19'];
              if(ieCode.size() > 0){
                selectedCompanyCode = ieCode[0];
              }

            }
            System.debug('selected company code: '+selectedCompanyCode);
            quote.Company_Code1__c = selectedCompanyCode.Code__c;
            
            //quote.zqu__Currency__c = defaultCompanyCode.Currency__c;
            this.currencyValues = getCurrencyValues(selectedCompanyCode.Currency_Picklist__c);
            boolean currencyExist = false;
              for (Selectoption currencyValue : this.currencyValues) {
                if (currencyValue.getValue() == this.currencyVal) {
                  currencyExist = true;
                  break;
                }
              }
              if (!currencyExist) {
                this.currencyVal = selectedCompanyCode.Currency__c;
                //currencyChange();
                //quote.zqu__Currency__c = this.currencyVal;
                if (this.editMode == 'true' && quote.zqu__SubscriptionType__c == 'New Subscription' && this.currencyVal != quote.zqu__Currency__c) {
                  deleteChargeGroups = true;
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Changing currency will delete all products selected on the quote. To ensure information does not get lost, rate plans will need to be re-added to the quote after save.'));
                } else {
                  deleteChargeGroups = false;
                }
              }
            this.companyCodeSelection = selectedCompanyCode.Code__c;
            quote.Company_Address__c = selectedCompanyCode.Address__c;
          }
          
        } else if (counter == 1) {
          quote.zqu__SoldToContact__c = ctct.Id;
          optionsForSoldTo.TargetId = ctct.Id;
          optionsForSoldTo.TargetName = ctct.Name;
          quote.Sold_Contact_Address__c = mailingStreet;
            
          quote.Sold_Contact_Address2__c = mailingCity+', '+mailingState+' '+mailingPostalCode+' '+mailingCountry;
          quote.Sold_Contact_Email__c = email;

          quote.Sold_Contact_Company__c = contactCompany;

          if (editMode == 'true' && quote.zqu__SubscriptionType__c == 'New Subscription') {
            Map<String, Decimal> results = updateMetrics(quote, existingChargeGroups);
            needRecalculateMetrics = true;
            if (results.get('totalTCV') != null && results.get('totalMRR') != null) {
              quote.Calculated_Total_TCV__c = String.valueOf(results.get('totalTCV').setScale(2));
              quote.Calculated_Total_MRR__c = String.valueOf(results.get('totalMRR').setScale(2));
              quote.Calculated_SubTotal__c = String.valueOf(results.get('totalSubtotal').setScale(2));
              quote.Calculated_Tax__c = String.valueOf(results.get('totalTax').setScale(2));
              quote.Calculated_Total__c = String.valueOf(results.get('totalTotal').setScale(2));
            } else {
              quote.Calculated_Total_TCV__c = 'Error in Calculating Metrics';
              quote.Calculated_Total_MRR__c = 'Error in Calculating Metrics';
              quote.Calculated_SubTotal__c = 'Error in Calculating Metrics';
              quote.Calculated_Tax__c = 'Error in Calculating Metrics';
              quote.Calculated_Total__c = 'Error in Calculating Metrics';
            }
          }
        }
      }
    }
    System.debug('payment plan selection: ' + this.paymentPlanSelection);

    System.debug('Quote.Company_Code1__c=' + quote.Company_Code1__c);
    System.debug('Quote.Channel__c=' + quote.Channel__c);
    System.debug('Quote.zqu__Currency__c=' + quote.zqu__Currency__c);

    oldContacts = currContacts;
    return null;
  }

  public Map<String, Decimal> updateMetrics(zqu__Quote__c quote, List<zqu.ZChargeGroup> chargeGroups) {
    Decimal totalTCV = 0;
    Decimal totalMRR = 0;
    Decimal totalSubtotal = 0;
    Decimal totalTax = 0;
    Decimal totalTotal = 0;
    try {
      Map<String, List<zqu.zChargeGroup>> subscriptionMap = new Map<String, List<zqu.zChargeGroup>>();
      Map<String, Decimal> results = new Map<String, Decimal>();
      Map<String, String> chargeToRatePlanMap = new Map<String, String>();
      for (zqu.ZChargeGroup chargeGroup : chargeGroups) {
        String key = (String) chargeGroup.zCharges[0].ChargeObject.get('Quote_Split_Number__c');
        if (subscriptionMap.containsKey(key)) {
          subscriptionMap.get(key).add(chargeGroup);
        } else {
          List<zqu.zChargeGroup> chargeList = new List<zqu.zChargeGroup>();
          chargeList.add(chargeGroup);
          subscriptionMap.put(key, chargeList);
        }
        for (zqu.ZCharge charge : chargeGroup.zCharges) {
          System.debug('prp id: '+chargeGroup.productRateplanZuoraID);
          chargeToRatePlanMap.put(charge.PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID, String.valueOf(charge.ChargeObject.get('Product_Rate_Plan_ZuoraID__c')));
        }
      }
      
      //TODO update quote with quote metrics values
      for (String key : subscriptionMap.keySet()) {
        //create subscription
        List<zqu.zChargeGroup> chargeList = subscriptionMap.get(key);
        System.debug('chargeToRatePlanMap: '+chargeToRatePlanMap);
        results = new PivLP_QuoteSplitManager().subscribePreviewCall(chargeList, chargeToRatePlanMap, quote);
        //results = ProductSelectorController.subscribePreviewCall(chargeList, chargeToRatePlanMap, quote);
        if (results.get('TCV') != null && results.get('MRR') != null) {
          totalTCV = results.get('TCV')+totalTCV;
          totalMRR = results.get('MRR')+totalMRR;
          totalSubtotal = results.get('subtotal')+totalSubtotal;
          totalTax = results.get('tax')+totalTax;
          totalTotal = totalSubtotal+totalTax;
        } else {
          totalTCV = null;
          totalMRR = null;
          break;
        }
      }

    } catch (Zuora.zRemoteException ex) {
        System.debug( 'SOAP Request = ' + Zuora.zApi.currentLogger.request );
        System.debug( 'SOAP Response = ' + Zuora.zApi.currentLogger.response );
        totalTCV = null;
        totalMRR = null;
        totalSubtotal = null;
        totalTax = null;
        totalTotal = null;
    } catch (Zuora.zAPIException ex) {
        totalTCV = null;
        totalMRR = null;
        totalSubtotal = null;
        totalTax = null;
        totalTotal = null;
    } catch (Zuora.zForceException ex) {
        totalTCV = null;
        totalMRR = null;
        totalSubtotal = null;
        totalTax = null;
        totalTotal = null;
    }
    Map<String, Decimal> returnResults = new Map<String, Decimal>();
    returnResults.put('totalTCV', totalTCV);
    returnResults.put('totalMRR', totalMRR);
    returnResults.put('totalSubtotal', totalSubtotal);
    returnResults.put('totalTax', totalTax);
    returnResults.put('totalTotal', totalTotal);
    return returnResults;
  }

  private zqu.LookupComponentOptions makeContactOptions(String id) {

      zqu.LookupComponentOptions optionsForBillTo = new zqu.LookupComponentOptions();
      optionsForBillTo.objectName = 'Contact';
      optionsForBillTo.Id = id;
      optionsForBillTo.isEditMode = true;
      optionsForBillTo.lookupComponentControllerName = 'NewQuotePageController.PropertyContactLookupController';
      optionsForBillTo.recordTypeId = Contact.SObjectType.getDescribe().getRecordTypeInfosByName().get('Master').getRecordTypeId();
      optionsForBillTo.popupWindowTitle = 'Contact';
      Id accountId = null;
    if (this.opp != null) {
      accountId = this.opp.AccountId;
    } else {
      accountId = this.acct.Id;
    }
      optionsForBillTo.soqlFragment = 'AccountId = \''+accountId+'\'';
      return optionsForBillTo;
  }
  //lookup controller
  global with sharing class PropertyContactLookupController extends zqu.LookupComponentController{
    public override String getAdditionalCondition() {

        return '';
    }
  }
  /* 
  Plugins 
  */
  public class SaveRecordPlugin implements zqu.PropertyComponentController.IUpdatePlugin{

    public PageReference doUpdate(SObject record, zqu.PropertyComponentController.ParentController parentController){
      String errorMessage = '';
      boolean saveSuccess = true;
      NewQuotePageController spcc = (NewQuotePageController)parentController;
      zqu__Quote__c quote = (zqu__Quote__c)record;
      Schema.DescribeFieldResult subIdFieldDesc = zqu__Quote__c.zqu__ZuoraSubscriptionID__c.getDescribe();
      Schema.sObjectField subIdField = subIdFieldDesc.getSObjectField();
      try {
        if (spcc.hasError) {
          System.debug('In parent controller: ' + spcc);
          throw new zqu.ZQException('There are errors preventing continuing to the next step.');
        }

        if (spcc.editMode == 'true') {
          quote.Id = spcc.quote.Id;
        }
        System.debug('update fields');
        //validate country/state
        List<String> contactIds = new List<String>();
        //need to fix the selection to have individual stuff

        List<Contact> ctcts = [SELECT ID,
                    MailingStateCode,
                    MailingCountryCode,
                    MailingPostalCode,
                    Contact_Company__c,
                    Email,
                    FirstName,
                    LastName
                    FROM Contact
                    WHERE Id = :spcc.quote.zqu__BillToContact__c];

        checkFields(ctcts, 'Bill To Contact');
        ctcts = new List<Contact>();

        ctcts = [SELECT ID,
                    MailingStateCode,
                    MailingCountryCode,
                    MailingPostalCode,
                    Contact_Company__c,
                    Email,
                    FirstName,
                    LastName
                    FROM Contact
                    WHERE Id = :quote.zqu__SoldToContact__c];

        checkFields(ctcts, 'Sold To Contact');

        quote.Company_Code1__c = spcc.quote.Company_Code1__c;
        quote.Channel__c = spcc.quote.Channel__c;
        quote.zqu__StartDate__c = spcc.quote.zqu__StartDate__c;

        
        quote.zqu__BillToContact__c = spcc.quote.zqu__BillToContact__c;
        //quote.zqu__SubscriptionTermStartDate__c = spcc.quote.zqu__SubscriptionTermStartDate__c;
        System.debug('spcc quote type: '+spcc.quote.zqu__SubscriptionType__c);
        System.debug('quote type: '+quote.zqu__SubscriptionType__c);
        if (quote.zqu__SubscriptionType__c == 'New Subscription') {
          if (spcc.billingAccountId == null || spcc.billingAccountId == '') {
            quote.zqu__Currency__c = spcc.currencyVal;
          } else {
            quote.zqu__Currency__c = spcc.quote.zqu__Currency__c;
          }
          quote.Payment_Plan__c = spcc.paymentPlanSelection;
          quote.Override_Payment_Plan__c = spcc.quote.Override_Payment_Plan__c;
          quote.zqu__BillingMethod__c = spcc.billingMethod;
          quote.zqu__BillingMethod__c = spcc.billingMethod;
        } else {
          quote.zqu__Customer_Acceptance_Date__c = quote.zqu__StartDate__c;
          quote.zqu__Service_Activation_Date__c = quote.zqu__StartDate__c;
          //quote.zqu__ZuoraSubscriptionID__c = spcc.quote.zqu__ZuoraSubscriptionID__c;
          quote.zqu__ExistSubscriptionID__c = spcc.quote.zqu__ExistSubscriptionID__c;

          quote.zqu__Currency__c = spcc.quote.zqu__Currency__c;
          quote.zqu__GenerateInvoice__c = true;

          //Check and create T&C Amendment
          System.debug('quote: '+quote.zqu__RenewalTerm__c+', '+quote.zqu__SubscriptionTermStartDate__c+', '+quote.zqu__InitialTerm__c);
          System.debug('spcc.quote: '+spcc.quote.zqu__RenewalTerm__c+', '+spcc.quote.zqu__SubscriptionTermStartDate__c+', '+spcc.quote.zqu__InitialTerm__c);

          if (quote.zqu__SubscriptionType__c == 'Renew Subscription') {

            if (spcc.editMode == 'true') {

              System.Debug('Checking TermsAndConditionChanges');

              if(quote.zqu__ExistSubscriptionID__c != null){
                    Zuora__Subscription__c originalSubscription = [Select Id, Zuora__RenewalTerm__c
                                                                   FROM Zuora__Subscription__c
                                                                   WHERE Zuora__External_Id__c =: quote.zqu__ExistSubscriptionID__c 
                                                                   Limit 1]; 

                  // if original subscription.Zuora__RenewalTerm__c is different from quote.zqu__RenewalTerm__c, 
                  // add T&C amendment to quote
                  if (Integer.valueOf(originalSubscription.Zuora__RenewalTerm__c.split(' ', 2)[0]) 
                    != quote.zqu__RenewalTerm__c && quote.zqu__RenewalTerm__c != 0) {
                    
                    System.Debug('Adding TermsAndCondition Amendment');

                    Map < String, Object > termsAndConditionChanges = new Map < String, Object > ();
                    termsAndConditionChanges.put('zqu__RenewalTerm__c', quote.zqu__RenewalTerm__c);

                    // Pass the changes to subscriptionTermsMap to be used when the quote record is upserted
                    zqu.zQuoteUtil.setSubscriptionTermChanges(new Map<String, Map<String, Object>>{quote.zqu__ExistSubscriptionID__c => termsAndConditionChanges});

                    //// recalculate metrics
                    //Map<String, Decimal> results = updateMetrics(quote, spcc.existingChargeGroups);
                    //spcc.needRecalculateMetrics = true;
                    //if (results.get('totalTCV') != null && results.get('totalMRR') != null) {
                    //  quote.Calculated_Total_TCV__c = String.valueOf(results.get('totalTCV').setScale(2));
                    //  quote.Calculated_Total_MRR__c = String.valueOf(results.get('totalMRR').setScale(2));
                    //  quote.Calculated_SubTotal__c = String.valueOf(results.get('totalSubtotal').setScale(2));
                    //  quote.Calculated_Tax__c = String.valueOf(results.get('totalTax').setScale(2));
                    //  quote.Calculated_Total__c = String.valueOf(results.get('totalTotal').setScale(2));
                    //} else {
                    //  quote.Calculated_Total_TCV__c = 'Error in Calculating Metrics';
                    //  quote.Calculated_Total_MRR__c = 'Error in Calculating Metrics';
                    //  quote.Calculated_SubTotal__c = 'Error in Calculating Metrics';
                    //  quote.Calculated_Tax__c = 'Error in Calculating Metrics';
                    //  quote.Calculated_Total__c = 'Error in Calculating Metrics';
                    //}

                  }
                }
              }
          }
        }

        

        if (quote.zqu__SubscriptionType__c == 'Amend Subscription') {
          String termType = (String) spcc.subZobj.getValue('TermType');
          if (termType != 'EVERGREEN') {
            quote.zqu__SubscriptionTermEndDate__c = quote.zqu__SubscriptionTermStartDate__c.addMonths(Integer.valueOf(quote.zqu__InitialTerm__c));
          }
        }

        quote.Pricing_Justification__c = spcc.quote.Pricing_Justification__c;

        quote.Contact_Address__c = spcc.quote.Contact_Address__c;
        quote.Sold_Contact_Address__c = spcc.quote.Sold_Contact_Address__c;
        quote.Contact_Address2__c = spcc.quote.Contact_Address2__c;
        quote.Sold_Contact_Address2__c = spcc.quote.Sold_Contact_Address2__c;
        quote.Contact_Email__c = spcc.quote.Contact_Email__c;
        quote.Sold_Contact_Email__c = spcc.quote.Sold_Contact_Email__c;
        //quote.Primary_Quote__c = spcc.quote.Primary_Quote__c;
        quote.Same_As_Bill_To_Contact__c = spcc.quote.Same_As_Bill_To_Contact__c;
        quote.Tax_Exempt__c = spcc.quote.Tax_Exempt__c;
        quote.Shipping_Address_Needed__c = spcc.quote.Shipping_Address_Needed__c;
        quote.Ship_Contact_Address__c = spcc.quote.Ship_Contact_Address__c;
        quote.Ship_Contact_Address2__c = spcc.quote.Ship_Contact_Address2__c;
        quote.Ship_Contact_Email__c = spcc.quote.Ship_Contact_Email__c;
        //quote.Ship_To_Email__c = spcc.quote.Ship_To_Email__c;
        quote.Ship_To_First_Name__c = spcc.quote.Ship_To_First_Name__c;
        quote.Ship_To_Last_Name__c = spcc.quote.Ship_To_Last_Name__c;
        quote.ChannelOrderID__c = spcc.quote.ChannelOrderID__c;
        quote.PurchaseOrder__c = spcc.quote.PurchaseOrder__c;
        if (spcc.needRecalculateMetrics) {
          quote.Calculated_Total_TCV__c = spcc.quote.Calculated_Total_TCV__c;
          quote.Calculated_Total_MRR__c = spcc.quote.Calculated_Total_MRR__c;
          quote.Calculated_SubTotal__c = spcc.quote.Calculated_SubTotal__c;
          quote.Calculated_Tax__c = spcc.quote.Calculated_Tax__c;
          quote.Calculated_Total__c = spcc.quote.Calculated_Total__c;
        }
        //quote.zqu__QuoteTemplate__c = spcc.quote.zqu__QuoteTemplate__c;

        if (spcc.deleteChargeGroups) {
          if (spcc.existingChargeGroups.size() > 0) {
            zqu.zQuoteUtil.deleteChargeGroups(spcc.existingChargeGroups);
          }
          quote.Calculated_Total_TCV__c = '0';
          quote.Calculated_Total_MRR__c = '0';
          quote.Calculated_SubTotal__c = '0';
          quote.Calculated_Tax__c = '0';
          quote.Calculated_Total__c = '0';
        }

        List<Company_Code__c> companyCode = [SELECT ID,
                    Code__c,
                    Address__c,
                    Tax_Region__c
                    FROM Company_Code__c
                    WHERE Code__c = :quote.Company_Code1__c];

        if(companyCode.size() > 0){
          quote.Company_Address__c = companyCode[0].Address__c;
        }

        System.debug('ship to first name: ' + quote.Ship_To_First_Name__c + ' last name: '+quote.Ship_To_Last_Name__c);

        quote.Approval_Status__c = 'Internal';

        System.debug('customer acceptance: '+quote.zqu__Customer_Acceptance_Date__c+' service activation: '+quote.zqu__Service_Activation_Date__c);
        System.debug('start date: '+quote.zqu__StartDate__c+' term start date: '+spcc.quote.zqu__SubscriptionTermStartDate__c);

        if (spcc.opp != null) {
          quote.Parent_Account__c = spcc.opp.Account.ParentId;
        } else {
          quote.Parent_Account__c = spcc.acct.ParentId;
        }

        if (quote.State__c == null || quote.State__c == '') {
          quote.State__c = 'New';
        }

        System.debug('Document_Type__c=' + spcc.quote.Document_Type__c);
        System.debug('spcc.Document_Type__c=' + spcc.quote.Document_Type__c);
        List<zqu__Quote_Template__c> quoteTemplates = [SELECT Id, Name from zqu__Quote_Template__c 
                                                WHERE Document_Type__c = :quote.Document_Type__c
                                                AND zqu__Quote_Type__c = :quote.zqu__SubscriptionType__c];



        if (quoteTemplates.size() > 0) {
          quote.zqu__QuoteTemplate__c = quoteTemplates[0].Id;
        }
/*
        List<zqu__InvoiceTemplate__c> invoiceTemplates = [SELECT Id, Name, zqu__ZuoraId__c from zqu__InvoiceTemplate__c 
                                                WHERE Company_Code__c = :quote.Company_Code__c];

        List<zqu__InvoiceTemplate__c> defaultInvoiceTemplate = [SELECT Id, Name, zqu__ZuoraId__c from zqu__InvoiceTemplate__c 
                                                WHERE default__c = true];

        if (invoiceTemplates.size() > 0) {
          quote.zqu__InvoiceTemplate__c = invoiceTemplates[0].Id;
          quote.Invoice_Template_Zuora_Id__c = invoiceTemplates[0].zqu__ZuoraId__c;
        } else {
          quote.zqu__InvoiceTemplate__c = defaultInvoiceTemplate[0].Id;
          quote.Invoice_Template_Zuora_Id__c = defaultInvoiceTemplate[0].zqu__ZuoraId__c;
        }
*/
        quote.Contact_Address__c = spcc.quote.Contact_Address__c;
        quote.Contact_Address2__c = spcc.quote.Contact_Address2__c;
        quote.Sold_Contact_Address__c = spcc.quote.Sold_Contact_Address__c;
        quote.Sold_Contact_Address2__c = spcc.quote.Sold_Contact_Address2__c;
        quote.Certificate_Id1__c = spcc.quote.Certificate_Id1__c;
        quote.Contact_Company__c = spcc.quote.Contact_Company__c;
        quote.Sold_Contact_Company__c = spcc.quote.Sold_Contact_Company__c;

        //field validations

        if (String.isEmpty(quote.zqu__SoldToContact__c)) {
          throw new zqu.ZQException('Sold to Contact not selected');
        }

        if (String.isEmpty(quote.Ship_To_First_Name__c)) {
          throw new zqu.ZQException('Ship To First Name not entered');
        }

        if (String.isEmpty(quote.Ship_To_Last_Name__c)) {
          throw new zqu.ZQException('Ship To Last Name not entered');
        }

        if (String.isEmpty(quote.Ship_Contact_Email__c)) {
          throw new zqu.ZQException('Shipping Email not entered');
        }

        if (quote.Tax_Exempt__c && String.isEmpty(quote.Certificate_Id1__c)) {
          throw new zqu.ZQException('Certificate Id is not entered when Tax Exempt is selected.');
        }

        /*
        if (quote.zqu__SubscriptionType__c == 'New Subscription') {
          System.debug('update quote');
          */
        if (spcc.editMode == 'true') {
          Database.SaveResult updateResult = Database.update(quote);
        } else {
          Database.SaveResult insertResult = Database.insert(quote);
        }
          /*
        } else {
          Database.UpsertResult ur = Database.upsert(quote, subIdField);
        }*/
        
      }
      catch (Exception e) {
        errorMessage = e.getMessage();
        saveSuccess = false;
      }

      if (saveSuccess) {
        if (spcc.editMode == 'true') {
          return new PageReference('/' + spcc.quoteId);
        } else {
          //return new PageReference('/apex/ZProductSelector?id=' + quote.Id);
          return zqu.QuoteWizardManager.navigateNext(new Map<String, String> {'Id' => quote.Id}, 'Subscription');
        }
        
      } else {
        if (errorMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
          errorMessage = errorMessage.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
          errorMessage = errorMessage.substringBefore(': []');
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The following error occurred while saving the page: '+errorMessage));
        return null;
      }
    }

    public void checkFields(List<Contact> contacts, String contactType) {
      if (contacts.size() > 0) {
          Integer counter = 0;
          for (Contact contact : contacts) {

            if (String.isEmpty(contact.MailingCountryCode)) {
              throw new zqu.ZQException('Country on '+contactType+' not selected. Please update contact before creating quote.');
            } else if (contact.MailingCountryCode == 'US' || contact.MailingCountryCode == 'CA') {
              if (String.isEmpty(contact.MailingStateCode)) {
                throw new zqu.ZQException('State on '+contactType+' not selected. Please update contact before creating quote.');
              }
              if (String.isEmpty(contact.MailingPostalCode)) {
                throw new zqu.ZQException('Postal Code on '+contactType+' not selected. Please update contact before creating quote.');
              }

            }

            if (String.isEmpty(contact.FirstName)) {
              throw new zqu.ZQException('First name on '+contactType+' not selected. Please update contact before creating quote.');
            }

            if (String.isEmpty(contact.LastName)) {
              throw new zqu.ZQException('Last name on '+contactType+' not selected. Please update contact before creating quote.');
            }

            if (String.isEmpty(contact.Email)) {
              throw new zqu.ZQException('Email on '+contactType+' not selected. Please update contact before creating quote.');
            }
            counter++;
          }
        } else {
          throw new zqu.ZQException(contactType+' not found.');
        }
    }

  }

  public class CancelRecordPlugin implements ICancelPlugin {
    public PageReference doCancel(SObject record, zqu.PropertyComponentController.ParentController pcc){
      NewQuotePageController acq = (NewQuotePageController)pcc;
      acq.controller.cancel();

      if (acq.editMode == 'true') {
        return new PageReference('/' + acq.quoteId);
      } else {
        if (acq.opp != null) {
          return new ApexPages.StandardController(acq.opp).view();
        } else {
          return new ApexPages.StandardController(acq.acct).view();
        }
      }

    }
  }

  //default values when loading a record
  public class DefaultValuesPlugin implements zqu.PropertyComponentController.IPopulateValuePlugin {

	  @TestVisible
      private Zuora.zApi api {
          get {
              if (api == null) {
                  api = new Zuora.zApi();
                  if (!Test.isRunningTest()) {
                      api.zlogin();
                  }
              }
              return api;
          }
          set;
      }

      public Set<String> quoteChargeCustomFields {
          get {
              if (quoteChargeCustomFields == null) {
                  //custom field names have to be lower cased
                  quoteChargeCustomFields = new Set<String>{
                          'listed_price__c', 'product_rate_plan_zuoraid__c', 'listed_total__c', 'initial_term__c', 'start_date__c', 'start_date_display__c', 'end_date__c', 'end_date_display__c', 'country_uplift__c', 'rate_usd__c', 'calculated_discount__c', 'zqu__period__c', 'zqu__specificbillingperiod__c', 'zqu__triggerdate__c', 'zqu__triggerevent__c', 'quote_split_number__c', 'psamount__c', 'product_name__c', 'tcv_usd__c', 'acv_usd__c', 'arr_usd__c', 'mrr_usd__c'
                  };
              }
              return quoteChargeCustomFields;
          }
          set;
      }


      public void populateDefaultFieldValue(SObject record, zqu.PropertyComponentController.parentController parentController) {
          NewQuotePageController spcc = (NewQuotePageController) parentController;


          zqu__Quote__c quote = (zqu__Quote__c) record;
          //quote.Location__c = 'Hello setting default value';
          spcc.paymentPlanEditable = true;

          if (spcc.opp != null && spcc.opp.Name != null) {
              if (!Test.isRunningTest()) {
                  quote.Name = spcc.opp.Name;
                  quote.zqu__Opportunity__c = spcc.opp.Id;
                  quote.zqu__Account__c = spcc.opp.AccountId;
              } else {
                  quote.Name = 'Test Quote Name';
                  quote.zqu__Opportunity__c = spcc.opp.Id;
              }
          }

          if (spcc.acct != null) {
              quote.zqu__Account__c = spcc.acct.Id;
          }

          String quoteType = ApexPages.currentPage().getParameters().get('quoteType');
          String subscriptionId = ApexPages.currentPage().getParameters().get('subscriptionId');
          Zuora.zObject subzobj = null;
          try {
              subzobj = this.getSubscription(subscriptionId);
              spcc.subZobj = subzobj;
              System.debug('setting zsub: ' + spcc.subZobj + ' id: ' + subscriptionId);
          } catch (Exception e) {
              //throw new zqu.ZQException(e.getMessage());
              spcc.hasError = true;
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The following error occurred while loading the page: ' + e.getMessage()));
          }

          if (spcc.editMode == 'true') {
              quote.Pricing_Justification__c = spcc.quote.Pricing_Justification__c;

              quote.zqu__BillToContact__c = spcc.quote.zqu__BillToContact__c;
              quote.zqu__SoldToContact__c = spcc.quote.zqu__SoldToContact__c;
              quote.Name = spcc.quote.Name;
              quote.Contact_Company__c = spcc.quote.Contact_Company__c;
              quote.Sold_Contact_Company__c = spcc.quote.Sold_Contact_Company__c;
              quote.Contact_Address__c = spcc.quote.Contact_Address__c;
              quote.Contact_Email__c = spcc.quote.Contact_Email__c;
              quote.Sold_Contact_Email__c = spcc.quote.Sold_Contact_Email__c;
              quote.Sold_Contact_Address__c = spcc.quote.Sold_Contact_Address__c;
              quote.Ship_Contact_Address__c = spcc.quote.Ship_Contact_Address__c;
              quote.Sold_Contact_Address2__c = spcc.quote.Sold_Contact_Address2__c;
              quote.Ship_Contact_Address2__c = spcc.quote.Ship_Contact_Address2__c;
              quote.Contact_Address2__c = spcc.quote.Contact_Address2__c;
              quote.Company_Code1__c = spcc.quote.Company_Code1__c;
              spcc.companyCodeSelection = quote.Company_Code1__c;
              quote.zqu__Currency__c = spcc.quote.zqu__Currency__c;
              spcc.currencyVal = spcc.quote.zqu__Currency__c;
              quote.Same_As_Bill_To_Contact__c = spcc.quote.Same_As_Bill_To_Contact__c;
              quote.Shipping_Address_Needed__c = spcc.quote.Shipping_Address_Needed__c;
              if (quote.Shipping_Address_Needed__c) {
                  spcc.needShippingAddress = true;
              }
              quote.Payment_Plan__c = spcc.quote.Payment_Plan__c;
              spcc.paymentPlanSelection = spcc.quote.Payment_Plan__c;
              System.debug('qpayment plan: ' + quote.Payment_Plan__c + ' payment selection: ' + spcc.paymentPlanSelection + ' spayment plan: ' + spcc.quote.Payment_Plan__c);
              quote.Ship_To_First_Name__c = spcc.quote.Ship_To_First_Name__c;
              quote.Ship_To_Last_Name__c = spcc.quote.Ship_To_Last_Name__c;
              quote.Ship_Contact_Email__c = spcc.quote.Ship_Contact_Email__c;
              quote.zqu__BillingMethod__c = spcc.quote.zqu__BillingMethod__c;
              spcc.billingMethod = spcc.quote.zqu__BillingMethod__c;
              quote.zqu__Status__c = spcc.quote.zqu__Status__c;
              quote.zqu__SubscriptionTermEndDate__c = spcc.quote.zqu__SubscriptionTermEndDate__c;
              quote.zqu__SubscriptionTermStartDate__c = spcc.quote.zqu__SubscriptionTermStartDate__c;
              quote.zqu__StartDate__c = spcc.quote.zqu__StartDate__c;
              quote.zqu__InitialTerm__c = spcc.quote.zqu__InitialTerm__c;
              quote.zqu__RenewalTerm__c = spcc.quote.zqu__RenewalTerm__c;
              quote.zqu__Subscription_Term_Type__c = spcc.quote.zqu__Subscription_Term_Type__c;
              quote.Subscription_Type__c = spcc.quote.Subscription_Type__c;
              quote.zqu__ZuoraAccountID__c = spcc.quote.zqu__ZuoraAccountID__c;
              quote.ChannelOrderID__c = spcc.quote.ChannelOrderID__c;
              quote.Channel__c = spcc.quote.Channel__c;
              quote.Document_Type__c = spcc.quote.Document_Type__c;
              quote.Primary_Quote__c = spcc.quote.Primary_Quote__c;
              quote.PurchaseOrder__c = spcc.quote.PurchaseOrder__c;
              quote.zqu__ZuoraSubscriptionID__c = spcc.quote.zqu__ZuoraSubscriptionID__c;
              quote.Tax_Exempt__c = spcc.quote.Tax_Exempt__c;
              quote.Certificate_Id1__c = spcc.quote.Certificate_Id1__c;
              quote.VAT_ID1__c = spcc.quote.VAT_ID1__c;
              quote.zqu__PaymentMethod__c = spcc.quote.zqu__PaymentMethod__c;
              quote.zqu__SubscriptionType__c = spcc.quote.zqu__SubscriptionType__c;
              quote.zqu__PaymentTerm__c = spcc.quote.zqu__PaymentTerm__c;
              quote.zqu__Amendment_Name__c = spcc.quote.zqu__Amendment_Name__c;
              quote.zqu__QuoteTemplate__c = spcc.quote.zqu__QuoteTemplate__c;
              quote.Company_Address__c = spcc.quote.Company_Address__c;
              quote.zqu__ValidUntil__c = spcc.quote.zqu__ValidUntil__c;
              quote.Has_Special_Terms__c = spcc.quote.Has_Special_Terms__c;
              quote.zqu__Terms__c = spcc.quote.zqu__Terms__c;
              quote.zqu__InvoiceSeparately__c = spcc.quote.zqu__InvoiceSeparately__c;
              spcc.optionsForBillTo.TargetId = spcc.quote.zqu__BillToContact__c;
              spcc.optionsForBillTo.TargetName = spcc.quote.zqu__BillToContact__r.Name;
              spcc.optionsForSoldTo.TargetId = spcc.quote.zqu__SoldToContact__c;
              spcc.optionsForSoldTo.TargetName = spcc.quote.zqu__SoldToContact__r.Name;

              if (quoteType == 'Amendment' || quoteType == 'Renewal') {
                  spcc.paymentPlanEditable = false;
              } else {
                  zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = quoteChargeCustomFields;
                  spcc.existingChargeGroups = zqu.zQuoteUtil.getChargeGroups(spcc.quote.Id);
                  if (quote.zqu__ZuoraAccountID__c == null || quote.zqu__ZuoraAccountID__c == '') {
                      spcc.isCurrencyEditable = true;
                  } else {
                      spcc.isCurrencyEditable = false;
                  }
              }

          } else {
              String billingAccountId = ApexPages.currentPage().getParameters().get('billingAccountId');
              quote.zqu__ZuoraAccountID__c = billingAccountId;
              quote.zqu__BillingMethod__c = spcc.billingMethod;
              
              //quote.Channel__c = 'Pivotal Direct';
              spcc.quote.Channel__c = 'Pivotal Direct';

              //quote.zqu__Currency__c = 'USD';
              spcc.quote.zqu__BillingMethod__c = spcc.billingMethod;
              quote.zqu__PaymentTerm__c = 'Net 30';
              quote.zqu__PaymentMethod__c = 'Check';
              quote.zqu__InvoiceSeparately__c = true;

              quote.Document_Type__c = 'Default';
              spcc.quote.Document_Type__c = 'Default';

              quote.zqu__StartDate__c = Date.today();
              spcc.quote.zqu__StartDate__c = Date.today();

              Period quarterPeriod = [SELECT EndDate FROM Period WHERE StartDate <= :Date.Today() AND EndDate >= :Date.Today() AND Type = 'Quarter'];
              quote.zqu__ValidUntil__c = quarterPeriod.EndDate;

              quote.zqu__Subscription_Term_Type__c = 'Termed';
              quote.zqu__InitialTerm__c = 12;
              quote.zqu__RenewalTerm__c = 12;

              spcc.isCurrencyEditable = true;


              Schema.SObjectType objectType = zqu__Quote__c.sObjectType;
              Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = objectType.getDescribe().getRecordTypeInfosByName();

              quote.Payment_Plan__c = spcc.paymentPlanSelection;
              spcc.quote.Payment_Plan__c = spcc.paymentPlanSelection;

              if (quote.zqu__ZuoraAccountID__c != null && quote.zqu__ZuoraAccountID__c != '') {
                  boolean contactsFound = true;
                  try {

                      Zuora.zObject acczobj = this.getBillingAccount(quote.zqu__ZuoraAccountID__c);
                      quote.zqu__Currency__c = (String) acczobj.getValue('Currency');
                      spcc.quote.zqu__Currency__c = (String) acczobj.getValue('Currency');
                      quote.zqu__PaymentTerm__c = (String) acczobj.getValue('PaymentTerm');
                      quote.Channel__c = (String) acczobj.getValue('Channel__c');
                      spcc.quote.Channel__c = (String) acczobj.getValue('Channel__c');
                      quote.Company_Code1__c = (String) acczobj.getValue('Company_Code__c');
                      spcc.quote.Company_Code1__c = (String) acczobj.getValue('Company_Code__c');
                      quote.Payment_Plan__c = (String) acczobj.getValue('Payment_Plan__c');
                      spcc.quote.Payment_Plan__c = (String) acczobj.getValue('Payment_Plan__c');
                      spcc.paymentPlanSelection = (String) acczobj.getValue('Payment_Plan__c');
                      System.debug('bill to: ' + (String) acczobj.getValue('BillToId') + ' sold to: ' + (String) acczobj.getValue('SoldToId'));
                      boolean prefEmail = (Boolean) acczobj.getValue('InvoiceDeliveryPrefsEmail');
                      boolean prefPrint = (Boolean) acczobj.getValue('InvoiceDeliveryPrefsPrint');
                      spcc.propertyOptions.readonlyFields.add('zqu__BillToContact__c');

                      if ((String) acczobj.getValue('TaxExemptStatus') == 'Yes') {
                          spcc.quote.Tax_Exempt__c = true;
                          spcc.quote.VAT_ID1__c = (String) acczobj.getValue('VATId');
                          quote.VAT_ID1__c = (String) acczobj.getValue('VATId');
                          spcc.quote.Certificate_Id1__c = (String) acczobj.getValue('TaxExemptCertificateID');
                          quote.Certificate_Id1__c = (String) acczobj.getValue('TaxExemptCertificateID');
                      }

                      if (prefEmail == true && prefPrint == true) {
                          quote.zqu__BillingMethod__c = 'Email and Print';
                          spcc.quote.zqu__BillingMethod__c = 'Email and Print';
                          spcc.billingMethod = 'Email and Print';
                      }

                      spcc.isCurrencyEditable = false;

                      if (prefEmail == true && prefPrint == false) {
                          quote.zqu__BillingMethod__c = 'Email';
                          spcc.quote.zqu__BillingMethod__c = 'Email';
                          spcc.billingMethod = 'Email';
                      }

                      //Contact billto = this.getContact((String) acczobj.getValue('BillToId'), quote.zqu__Account__c);
                      //Contact soldto = this.getContact((String) acczobj.getValue('SoldToId'), quote.zqu__Account__c);

                      Contact billto;
                      Contact soldto;

                      if (Test.isRunningTest()) {
                          billto = this.getContact2(quote.zqu__Account__c);
                          soldto = this.getContact2(quote.zqu__Account__c);
                      } else {
                          billto = this.getContact2((String) acczobj.getValue('CRM_Bill_To_Contact_Id__c'));
                          soldto = this.getContact2((String) acczobj.getValue('CRM_Sold_To_Contact_Id__c'));
                      }

                      if (billto == null || soldto == null) {
                          contactsFound = true;
                          throw new zqu.ZQException('Zuora Bill To or Sold To Contact not found in SFDC. Please edit and reselect the correct contact.');
                      }

                      String mailingCity = '';
                      String mailingState = '';
                      String mailingPostalCode = '';
                      String mailingCountry = '';
                      String mailingStreet = '';
                      String email = '';
                      String contactCompany = '';

                      if (billto.MailingStreet != null) {
                          mailingStreet = billto.MailingStreet;
                      }

                      if (billto.MailingCity != null) {
                          mailingCity = billto.MailingCity;
                      }
                      if (billto.MailingState != null) {
                          mailingState = billto.MailingState;
                      }
                      if (billto.MailingPostalCode != null) {
                          mailingPostalCode = billto.MailingPostalCode;
                      }
                      if (billto.MailingCountry != null) {
                          mailingCountry = billto.MailingCountry;
                      }
                      if (billto.MailingCountry != null) {
                          email = billto.Email;
                      }

                      if (billto.Contact_Company__c != null) {
                          contactCompany = billto.Contact_Company__c;
                      }

                      spcc.optionsForBillTo.TargetId = billto.Id;
                      spcc.optionsForBillTo.TargetName = billto.Name;
                      spcc.quote.Contact_Address__c = mailingStreet;

                      spcc.quote.zqu__BillToContact__c = billto.Id;
                      quote.zqu__BillToContact__c = billto.Id;

                      spcc.quote.Contact_Address2__c = mailingCity + ', ' + mailingState + ' ' + mailingPostalCode + ' ' + mailingCountry;
                      spcc.quote.Contact_Email__c = email;
                      spcc.quote.Contact_Company__c = contactCompany;

                      mailingCity = '';
                      mailingState = '';
                      mailingPostalCode = '';
                      mailingCountry = '';
                      mailingStreet = '';
                      email = '';
                      contactCompany = '';

                      if (soldto.MailingStreet != null) {
                          mailingStreet = soldto.MailingStreet;
                      }

                      if (soldto.MailingCity != null) {
                          mailingCity = soldto.MailingCity;
                      }
                      if (soldto.MailingState != null) {
                          mailingState = soldto.MailingState;
                      }
                      if (soldto.MailingPostalCode != null) {
                          mailingPostalCode = soldto.MailingPostalCode;
                      }
                      if (soldto.MailingCountry != null) {
                          mailingCountry = soldto.MailingCountry;
                      }
                      if (soldto.MailingCountry != null) {
                          email = soldto.Email;
                      }
                      if (soldto.Contact_Company__c != null) {
                          contactCompany = soldto.Contact_Company__c;
                      }

                      spcc.optionsForSoldTo.TargetId = soldto.Id;
                      spcc.optionsForSoldTo.TargetName = soldto.Name;
                      spcc.quote.Sold_Contact_Address__c = mailingStreet;

                      spcc.quote.zqu__SoldToContact__c = soldto.Id;
                      quote.zqu__SoldToContact__c = soldto.Id;

                      spcc.quote.Sold_Contact_Address2__c = mailingCity + ', ' + mailingState + ' ' + mailingPostalCode + ' ' + mailingCountry;
                      spcc.quote.Sold_Contact_Email__c = email;
                      spcc.quote.Sold_Contact_Company__c = contactCompany;

                  } catch (Exception e) {
                      //throw new zqu.ZQException(e.getMessage());
                      if (contactsFound) {
                          spcc.hasError = true;
                      }
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The following error occurred while loading the page: ' + e.getMessage()));
                  }
              }

              if (quoteType == 'Amendment' || quoteType == 'Renewal') {

                  spcc.paymentPlanEditable = false;

                  quote.zqu__Amendment_Name__c = spcc.opp.Name;
                  try {

                      Zuora.zObject acczobj = this.getBillingAccount(quote.zqu__ZuoraAccountID__c);
                      System.debug('account obj: ' + acczobj);
                      if (acczobj != null) {
                          quote.zqu__Currency__c = (String) acczobj.getValue('Currency');
                          System.debug('currency: ' + quote.zqu__Currency__c);
                          quote.Channel__c = (String) acczobj.getValue('Channel__c');
                          System.debug('Channel for Amendaments and Renewals: ' + quote.zqu__Currency__c);

                      }

                      System.debug('subscription: ' + subzobj);
                      System.debug('term start date: ' + ((Datetime) subzobj.getValue('TermStartDate')).dateGMT());

                      String termType = (String) subzobj.getValue('TermType');

                      if (termType == 'EVERGREEN') {
                          spcc.hasError = true;
                          throw new zqu.ZQException('Amendment or renewal on PS subscription is not allowed. Please go back and create a new subscription.');
                      }

                      System.debug('term end date: ' + ((Datetime) subzobj.getValue('TermEndDate')).dateGMT());

                      quote.Payment_Plan__c = (String) subzobj.getValue('Payment_Plan__c');
                      spcc.quote.Payment_Plan__c = (String) subzobj.getValue('Payment_Plan__c');
                      if (null != subzobj) {
                          // For amendments
                          quote.zqu__ExistSubscriptionID__c = subscriptionId;
                          spcc.quote.zqu__ExistSubscriptionID__c = subscriptionId;
                          quote.zqu__Hidden_Subscription_Name__c = (String) subzobj.getValue('Name');
                          if ('Amendment' == quoteType) {
                              quote.put('zqu__StartDate__c', ((Datetime) subzobj.getValue('TermStartDate')).dateGMT());
                              spcc.quote.put('zqu__StartDate__c', ((Datetime) subzobj.getValue('TermStartDate')).dateGMT());
                              quote.zqu__SubscriptionType__c = 'Amend Subscription';
                              quote.RecordTypeId = recordTypeInfoMap.get('Amendment').getRecordTypeId();
                          }
                          // For renewals
                          else {
                              quote.put('zqu__StartDate__c', ((Datetime) subzobj.getValue('TermEndDate')).dateGMT());
                              spcc.quote.put('zqu__StartDate__c', ((Datetime) subzobj.getValue('TermEndDate')).dateGMT());
                              quote.zqu__SubscriptionType__c = 'Renew Subscription';
                              quote.RecordTypeId = recordTypeInfoMap.get('Renewal').getRecordTypeId();
                          }
                          // Populate terms and conditions from original subscription
                          spcc.quote.put('zqu__AutoRenew__c', (Boolean) subzobj.getValue('AutoRenew'));
                          quote.put('zqu__AutoRenew__c', (Boolean) subzobj.getValue('AutoRenew'));
                          spcc.quote.put('zqu__InitialTerm__c', (Integer) subzobj.getValue('InitialTerm'));
                          quote.put('zqu__InitialTerm__c', (Integer) subzobj.getValue('InitialTerm'));
                          spcc.quote.put('zqu__RenewalTerm__c', (Integer) subzobj.getValue('RenewalTerm'));
                          quote.put('zqu__RenewalTerm__c', (Integer) subzobj.getValue('RenewalTerm'));

                          spcc.quote.put('zqu__SubscriptionTermStartDate__c', ((Datetime) subzobj.getValue('TermStartDate')).dateGMT());
                          quote.put('zqu__SubscriptionTermStartDate__c', ((Datetime) subzobj.getValue('TermStartDate')).dateGMT());
                          spcc.quote.put('zqu__ZuoraSubscriptionID__c', (String) subzobj.getValue('Id'));

                          spcc.quote.put('zqu__SubscriptionTermEndDate__c', ((Datetime) subzobj.getValue('TermEndDate')).dateGMT());
                          quote.put('zqu__SubscriptionTermEndDate__c', ((Datetime) subzobj.getValue('TermEndDate')).dateGMT());
                          spcc.quote.put('zqu__Subscription_Term_Type__c', (String) subzobj.getValue('TermType'));
                          spcc.quote.put('zqu__Hidden_Subscription_Name__c', (String) subzobj.getValue('Name'));
                          spcc.quote.put('zqu__SubscriptionVersion__c', (Integer) subzobj.getValue('Version'));
                          quote.Subscription_Type__c = (String) subzobj.getValue('Subscription_Type__c');
                          quote.Payment_Plan__c = (String) subzobj.getValue('Payment_Plan__c');
                    }
                  } catch (Exception e) {
                      //throw new zqu.ZQException(e.getMessage());
                      spcc.hasError = true;
                      System.debug('Quote type is: ' + quotetype);
                      System.debug('The following error occurred while loading the page: ' + e.getMessage());
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The following error occurred while loading the page: ' + e.getMessage()));
                  }

              } else {
                  quote.zqu__SubscriptionType__c = 'New Subscription';
                  quote.RecordTypeId = recordTypeInfoMap.get('Default').getRecordTypeId();
                  quote.zqu__Customer_Acceptance_Date__c = Date.today();
                  quote.zqu__Service_Activation_Date__c = Date.today();
              }

          }
          
          //Changes for Orders
          //quote.zqu__RenewalSetting__c = 'RENEW_TO_EVERGREEN';
          quote.zqu__RenewalSetting__c = 'RENEW_WITH_SPECIFIC_TERM';
          quote.zqu__InitialTermPeriodType__c = 'Month';
          quote.zqu__RenewalTermPeriodType__c = 'Month';
          System.debug('currency editable: ' + spcc.isCurrencyEditable);
      }

      private Zuora.zObject getSubscription(String subscriptionId) {
          final Zuora.zObject subzobj;
          final String zoqlsubscription = 'Select Id, Name, Version, AccountId, Subscription_Type__c, Payment_Plan__c, OriginalId, ContractEffectiveDate, AutoRenew, InitialTerm, TermStartDate, TermEndDate, TermType, RenewalTerm from Subscription where Id = \'' + subscriptionId + '\'';
          final List < Zuora.zObject > subzobjs = null;
          if (!Test.isRunningTest()) {
              subzobjs = api.zquery(zoqlsubscription);
          } else {
              subzobjs = NewQuotePageControllerTest.createDummySubList();
          }
          if (subzobjs.size() == 1) subzobj = subzobjs[0];
          return subzobj;
      }

      private Zuora.zObject getBillingAccount(String billingaccountId) {
          final Zuora.zObject acczobj;
          final String zoqlacc = 'SELECT BillToId,SoldToId,Currency,' +
                  'PaymentTerm,Channel__c,Company_Code__c,InvoiceDeliveryPrefsEmail,' +
                  'InvoiceDeliveryPrefsPrint,CRM_Sold_To_Contact_Id__c,CRM_Bill_To_Contact_Id__c,TaxExemptStatus,TaxExemptCertificateID,VATId ' +
                  'from Account where Id=\'' + billingaccountId + '\'';
		 system.debug('getBillingAccount:'+zoqlacc);
          final List < Zuora.zObject > acczobjs = null;
          if (!Test.isRunningTest()) {
              acczobjs = api.zquery(zoqlacc);
          } else {
			 system.debug('getBillingAccount:in test method');
              acczobjs = NewQuotePageControllerTest.createDummyAcctList();
          }
          if (acczobjs.size() == 1) acczobj = acczobjs[0];
          return acczobj;
      }

      private Contact getContact2(String contactId) {
          List<Contact> results;

          if (Test.isRunningTest()) {
              return NewQuotePageControllerTest.createContact(contactId);
          } else {
              results = [
                      SELECT
                              Id,
                              MailingStreet,
                              Name,
                              MailingCity,
                              MailingState,
                              MailingPostalCode,
                              MailingCountry,
                              Contact_Company__c,
                              Email,
                              FirstName,
                              LastName
                      FROM Contact
                      WHERE Id = :contactId
              ];
              if (results.size() > 0) {
                  return results[0];
              }
          }

          return null;
      }
  }

  public class PopulateRelatedObjectFieldPlugin implements zqu.PropertyComponentController.IRelatedObjectPlugin{
    public Map<String, SObject> getRelatedObject (zqu.PropertyComponentController.ParentController parentController){
      NewQuotePageController spcc = (NewQuotePageController)parentController;

      Map < String, SObject > relatedObjectMap = new Map < String, SObject > ();

      // Set values for related object field : Opportunity__r.AccountId, Opportunity__r.Docu_Sign_Status__c
      relatedObjectMap.put('zqu__Opportunity__r', spcc.opp);
      relatedObjectMap.put('zqu__Account__r', spcc.acct);

      return relatedObjectMap;
    }
  } 
}