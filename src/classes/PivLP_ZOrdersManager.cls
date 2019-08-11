/******************************************************************************
Name                :    PivLP_ZOrdersManager
Author              :    Reid Beckett, Launchpad
Description         :    Manager for ZQuotes interactions
Date                :    09/14/2018
*******************************************************************************/
public class PivLP_ZOrdersManager {
	//query and return full sub-quote details
    public zqu__Quote__c findSubQuote(Id quoteId){
    	zqu__Quote__c[] zquote = [SELECT Id,
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
          ChannelOrderId__c,
			zqu__Zuora_Account_Number__c,
          zqu__Number__c,
          zqu__Opportunity__r.Name
          FROM zqu__Quote__c
          WHERE Id = :quoteId
        ];        
        return zquote.isEmpty() ? null : zquote.get(0);
    }
    
	//query and return light quote for top-level
    public zqu__Quote__c findMasterQuote(Id quoteId){
        Set<String> queryFields = new Set<String>{
            'Id',
            'Name',
            'State__c',
            'Error_Message__c',
            'zqu__Opportunity__c',
            'zqu__ZuoraAccountID__c',
            'zqu__SubscriptionType__c',
            'zqu__Number__c',
			'RecordTypeId', 'OM_Status__c', 'Primary_Quote__c', 'Approval__c'       
        };
        queryFields.addAll(getFieldsFromFieldSet('zqu__Quote__c', 'Quote_Information_Custom'));
        queryFields.addAll(getFieldsFromFieldSet('zqu__Quote__c', 'Account_Details_Custom'));
        queryFields.addAll(getFieldsFromFieldSet('zqu__Quote__c', 'Subscription_Terms_Custom'));
            
        String soql = 'SELECT ' + String.join(new List<String>(queryFields), ',') + ' FROM zqu__Quote__c WHERE Id = :quoteId';
        zqu__Quote__c[] zquote = Database.query(soql);

        return zquote.isEmpty() ? null : zquote.get(0);
    }
    
    private List<String> getFieldsFromFieldSet(String sobjectType, String fieldSetName){
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(sobjectType).getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
        
		List<String> fields = new List<String>();
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            if(fsm.getType() == Schema.DisplayType.REFERENCE) {
                fields.add(fsm.fieldPath.replace('__c', '__r')+'.Name');
            }
            fields.add(fsm.fieldPath);
        }
        
        return fields;
    }
    
    private Company_Code__c findCompanyCode(zqu__Quote__c currQuote) {
	    List<Company_Code__c> companyCodes = [SELECT Tax_Region__c from Company_Code__c where Code__c = :currQuote.Company_Code1__c];

        if(companyCodes.size() > 0) {
          return companyCodes[0];
        }
        
        return null;
    }
    
    private Channel__c findChannel(zqu__Quote__c currQuote) {
    	List<Channel__c> channels = [SELECT Name, Channel_Type__c from Channel__c where name = :currQuote.Channel__c];

        if(channels.size() > 0) {
          return channels[0];
        }
        
        return null;
    }
    
    private String getInvoiceTemplateId(zqu__Quote__c currQuote){
        List<zqu__InvoiceTemplate__c> invoiceTemplates = [SELECT Id, Name, zqu__ZuoraId__c from zqu__InvoiceTemplate__c 
                                                    WHERE Company_Code__c = :currQuote.Company_Code1__c];
        if (invoiceTemplates.size() > 0) {
          return invoiceTemplates[0].zqu__ZuoraId__c;
        } else {
    
          List<zqu__InvoiceTemplate__c> defaultInvoiceTemplate = 
                  [SELECT Id, Name, zqu__ZuoraId__c 
                   FROM zqu__InvoiceTemplate__c 
                   WHERE default__c = true];
    
          if(defaultInvoiceTemplate.size()>0){
            return defaultInvoiceTemplate[0].zqu__ZuoraId__c;
          }else{
              return null;
          }
        }
    }

    private Zuora.zObject buildZuoraAccount(zqu__Quote__c currQuote, Zuora.zObject zPaymentMethod){
        Boolean isUpdate = !String.isBlank(currQuote.zqu__ZuoraAccountID__c);
	    Zuora.zObject acc = new Zuora.zObject('Account');
        if(isUpdate) acc.setValue('Id', currQuote.zqu__ZuoraAccountID__c);

        //TODO - see SendToZbillingWithSplitQuotes.buildZAccount(zqu__Quote__c currQuote, zqu__Quote__c originalQuote, Zuora.zApi zuoraApi, boolean isUpdate, String recentAcctId)
	    List<Company_Code__c> companyCodes = [SELECT Tax_Region__c from Company_Code__c where Code__c = :currQuote.Company_Code1__c];

        Company_Code__c companyCode = findCompanyCode(currQuote);
        acc.setValue('Name', currQuote.zqu__Account__r.name);
        
        acc.setValue('BillCycleDay', 1);
        acc.setValue('PaymentTerm', currQuote.zqu__PaymentTerm__c);
        if (zPaymentMethod != null) {
          acc.setValue('DefaultPaymentMethodId', (String) zPaymentMethod.getValue('Id'));
        }
    acc.setValue('CrmId', currQuote.zqu__Account__r.Id);
    acc.setValue('Channel__c', currQuote.Channel__c);
    acc.setValue('Company_Code__c', currQuote.Company_Code1__c);
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
    String invoiceTemplateId = getInvoiceTemplateId(currQuote);
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

        Channel__c channel = findChannel(currQuote);
    if (channel != null && channel.Channel_Type__c == 'Direct') {
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
        return acc;
    }

    private Zuora.zObject findPaymentMethod(zqu__Quote__c currQuote){
	    String name = currQuote.zqu__PaymentMethod__c;
        if(name==null) return null;
    	String type = currQuote.zqu__PaymentMethod__c.replaceAll( '\\s+', '');
    	String zoqlpm = 'SELECT Id from PaymentMethod where Name=\'' + name + '\' and Type = \''+type+'\'';
        List<Zuora.zObject> results = PivLP_ZSOAPClient.getInstance().zquery(zoqlpm);
        return results.isEmpty() ? null : results.get(0);
    }
    
    private Zuora.zObject buildBillToContact(zqu__Quote__c currQuote){
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
        if(!String.isBlank(currQuote.zqu__ZuoraAccountID__c)) billToContact.setValue('AccountId', currQuote.zqu__ZuoraAccountID__c);
        return billToContact;
    }

    private Zuora.zObject buildSoldToContact(zqu__Quote__c currQuote, Company_Code__c companyCode){
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
        if(!String.isBlank(currQuote.zqu__ZuoraAccountID__c)) soldToContact.setValue('AccountId', currQuote.zqu__ZuoraAccountID__c);
        return soldToContact;
    }
    
    private Zuora.zObject findZuoraAccountWithContactIds(String zAccountId){
        String queryString = 'SELECT BillToId, SoldToId from Account where id = \'' + zAccountId + '\'';
        List<Zuora.zObject> zobjs = PivLP_ZSOAPClient.getInstance().zquery(queryString);
        return !zobjs.isEmpty() ? zobjs.get(0) : null;
    }

    public String createZuoraAccount(zqu__Quote__c currQuote){
        String methodName = 'PivLP_ZOrdersManager.createZuoraAccount';
        PivLP_Logger.start(methodName);
        
        Zuora.zObject zPaymentMethod = findPaymentMethod(currQuote);
        Zuora.zObject zuoraAccount = buildZuoraAccount(currQuote, zPaymentMethod);
        String zuoraAccountId = currQuote.zqu__ZuoraAccountID__c;
        Boolean isCreate = true;
        Zuora.zObject billToContact = buildBillToContact(currQuote);
        Zuora.zObject soldToContact = buildSoldToContact(currQuote, findCompanyCode(currQuote));
        
        if(String.isBlank(zuoraAccountId)){
            //create path
	        zuoraAccountId = PivLP_ZSOAPClient.getInstance().zcreate(zuoraAccount);
            billToContact.setValue('AccountId', zuoraAccountId);
            soldToContact.setValue('AccountId', zuoraAccountId);
            List<String> zcontactIds = PivLP_ZSOAPClient.getInstance().zcreate(new Zuora.zObject[]{billToContact,soldToContact});
            zuoraAccount.setValue('Id', zuoraAccountId);
            zuoraAccount.setValue('Status', 'Active');
            zuoraAccount.setValue('BillToId', zcontactIds.get(0));
            zuoraAccount.setValue('SoldToId', zcontactIds.get(1));

            if (currQuote.zqu__BillingMethod__c == 'Email') {
                zuoraAccount.setValue('InvoiceDeliveryPrefsEmail', 'true');
                zuoraAccount.setValue('InvoiceDeliveryPrefsPrint', 'false');
            } else if (currQuote.zqu__BillingMethod__c == 'Email and Print') {
                zuoraAccount.setValue('InvoiceDeliveryPrefsEmail', 'true');
                zuoraAccount.setValue('InvoiceDeliveryPrefsPrint', 'true');
            }
            
            PivLP_ZSOAPClient.getInstance().zupdate(zuoraAccount);
            
        }else{
            //update path
            isCreate = false;
            PivLP_ZSOAPClient.getInstance().zupdate(zuoraAccount);
            Zuora.zObject zAccountWithContactIds = findZuoraAccountWithContactIds(zuoraAccountId);
            billToContact.setValue('Id', (String)zAccountWithContactIds.getValue('BillToId'));
            soldToContact.setValue('Id', (String)zAccountWithContactIds.getValue('SoldToId'));
            PivLP_ZSOAPClient.getInstance().zupdate(new Zuora.zObject[]{billToContact,soldToContact});
            
            zuoraAccount.setValue('Id', zuoraAccountId);
            if (currQuote.zqu__BillingMethod__c == 'Email') {
                zuoraAccount.setValue('InvoiceDeliveryPrefsEmail', 'true');
                zuoraAccount.setValue('InvoiceDeliveryPrefsPrint', 'false');
            } else if (currQuote.zqu__BillingMethod__c == 'Email and Print') {
                zuoraAccount.setValue('InvoiceDeliveryPrefsEmail', 'true');
                zuoraAccount.setValue('InvoiceDeliveryPrefsPrint', 'true');
            }
            PivLP_ZSOAPClient.getInstance().zupdate(zuoraAccount);
        }
        PivLP_Logger.debug('createZuoraAccount:returning '+zuoraAccountId);
        PivLP_Logger.finish(methodName);
        return zuoraAccountId;
    }
    
    public String createZuoraAccount(Id quoteId){
        zqu__Quote__c currQuote = findSubQuote(quoteId);
        Boolean newAccount = String.isBlank(currQuote.zqu__ZuoraAccountID__c);
        String zuoraAccountId = null;
        if (String.isBlank(currQuote.zqu__ZuoraAccountID__c)) {
            zuoraAccountId = createZuoraAccount(currQuote);
            //query to get account number
            currQuote.zqu__ZuoraAccountID__c = zuoraAccountId;
            List<Zuora.zObject> zAccounts = PivLP_ZSOAPClient.getInstance().zquery('select Id, AccountNumber from Account where Id = \''+zuoraAccountId+'\'');
            if(!zAccounts.isEmpty()){
                currQuote.zqu__Zuora_Account_Number__c = (String)zAccounts.get(0).getValue('AccountNumber');
            }          
            //update all sub-quotes
            updateQuoteAccounts(currQuote.Split_Parent_Quote__c, zuoraAccountId, currQuote.zqu__Zuora_Account_Number__c);
            return currQuote.zqu__ZuoraAccountID__c;
        }else{
            return currQuote.zqu__ZuoraAccountID__c;
        }
    }
    
    public List<String> sendToZBilling(Id quoteId){
        zqu__Quote__c currQuote = findSubQuote(quoteId);
        zqu__Quote__c masterQuote = findMasterQuote(currQuote.Split_Parent_Quote__c);
	    zqu.zQuoteUtil.ZBillingQuoteCollection quoteCollection = new zqu.zQuoteUtil.ZBillingQuoteCollection();
    	List < zqu.zQuoteUtil.ZBillingQuoteCollection > quoteCollections = new List < zqu.zQuoteUtil.ZBillingQuoteCollection > ();
	    quoteCollection.quoteRequests = new List < zqu.zQuoteUtil.ZBillingQuoteRequest > ();
        
        if(String.isBlank(currQuote.zqu__ZuoraAccountID__c)){
            throw new PivLP_Exception('Zuora Account must be created before submitting the quote');
        }
        
        Boolean newAccount = String.isBlank(currQuote.zqu__ZuoraAccountID__c);
        String zuoraAccountId = null;
        
        if (!newAccount) {
            zuoraAccountId = createZuoraAccount(currQuote);
            if (String.isBlank(currQuote.zqu__ZuoraAccountID__c)) {
                quoteCollection.zAccountId = zuoraAccountId;
            } else {
                quoteCollection.zAccountId = currQuote.zqu__ZuoraAccountID__c;
            }
        }

        zqu.zQuoteUtil.ZBillingQuoteRequest req = new zqu.zQuoteUtil.ZBillingQuoteRequest();
        req.sfdcQuoteId = currQuote.Id; // SFDC Quote ID
        req.generateInvoice = true;
        req.invoiceProcessingOption = 'Subscription';
        
        system.debug('*** 0921: currQuote.zqu__Zuora_Account_Number__c=' + currQuote.zqu__Zuora_Account_Number__c);
        system.debug('*** 0921: zqu__ZuoraAccountID__c=' + currQuote.zqu__ZuoraAccountID__c);
        system.debug('*** 0921: quoteCollection.zAccountId=' + quoteCollection.zAccountId);
        system.debug('*** 0921: req.sfdcQuoteId=' + req.sfdcQuoteId);
        
        quoteCollection.quoteRequests.add(req);

        quoteCollection.sfdcAccountId = currQuote.zqu__Account__r.Id;
        quoteCollections.add(quoteCollection);
        
        system.debug(quoteCollection);
        
        //List<zqu.zQuoteUtil.zBillingResult> results = zqu.zQuoteUtil.sendToZBilling(quoteCollections);
        List<zqu.zQuoteUtil.zBillingResult> results = PivLP_ZSOAPClient.getInstance().sendToZBilling(quoteCollections);

        System.Debug('sent to zbilling ' + results);
        if(!Test.isRunningTest()){
            for ( Zuora.zApi.Logger logger : Zuora.zApi.loggers ) {
            	System.debug( 'logger = ' + logger.toString() );
            }
            
            System.debug( 'SOAP Request = ' + Zuora.zApi.currentLogger.request );
            System.debug( 'SOAP Response = ' + Zuora.zApi.currentLogger.response );
            PivLP_Logger.debug(Zuora.zApi.currentLogger.request);
            PivLP_Logger.debug(Zuora.zApi.currentLogger.response);
        }
        
        List<String> errors = new List<String>();

        for (zqu.zQuoteUtil.zBillingResult result: results) {
            if (result.success) {      
                
                updateSubscription(currQuote.Id);
                
                currQuote.Error_Message__c = null;
                currQuote.zqu__Status__c = 'Sent to Z-Billing';
                String updateResult = updateQuote(currQuote);
                if(updateResult != null) errors.add('Sent to Z-Billing successfully but failed to update Quote record:'+updateResult);
                return errors;

            }else {      

                String message = result.message;
                errors.add(result.message);
                
                //if(newAccount){
                	//delete account (rollback)
                	//String deleteAccountResult = deleteZuoraAccount(zuoraAccountId);
                    //if(deleteAccountResult == null) errors.add('Zuora Account rolled back');
                    //else errors.add('Failed to rollback Zuora Account ' +zuoraAccountId +' - ' + deleteAccountResult);

	                currQuote.Error_Message__c = result.message;
                    String updateResult = updateQuote(currQuote);
                    if(updateResult != null) errors.add('Failed to update quote:' + updateResult);                
                //}
                
                return errors;
            }
        }
        
        return errors;
    }
    
    private String updateQuote(zqu__Quote__c q){
        try {
            update q;
            return null;
        }catch(Exception e){
            //Don't let exception get thrown.
            return e.getMessage();
        }
    }

    private String deleteZuoraAccount(String zuoraAccountId){
        try {
            PivLP_ZSOAPClient.getInstance().zdelete('Account', zuoraAccountId);
            return null;
        }catch(Exception e){
            //Don't let exception get thrown.
            return e.getMessage();
        }
    }
    
    private String updateQuoteAccounts(Id masterQuoteId, String zuoraAccountId, String zuoraAccountNumber){
        try{
            zqu__Quote__c[] quotes = [select Id, zqu__ZuoraAccountID__c from zqu__Quote__c 
                                      where (Split_Parent_Quote__c = :masterQuoteId)];
            for(zqu__Quote__c q : quotes) {
                q.zqu__ZuoraAccountID__c = zuoraAccountId;
                q.zqu__Zuora_Account_Number__c = zuoraAccountNumber;
            }        
            update quotes;
            return null;
        }catch(Exception e){
            return e.getMessage();
        }
    }

    public List<PivLP_AuraModel.Quote> findSubQuotes(zqu__Quote__c primaryQuote){
        Map<Id, Map<Id, List<zqu__QuoteRatePlanCharge__c>>> subQuoteCharges = findSubQuoteCharges(primaryQuote.Id);
        
        List<PivLP_AuraModel.Quote> lst = new List<PivLP_AuraModel.Quote>();
        for(zqu__Quote__c q : [
            	select Id, zqu__StartDate__c, zqu__Status__c, Name, Quote_Split_Number__c, Error_Message__c, zqu__ZuoraAccountID__c, 
            	zqu__Zuora_Account_Number__c, zqu__Subscription_Name__c, zqu__ZuoraSubscriptionID__c, zqu__Number__c, zqu__Opportunity__r.Name
            	from zqu__Quote__c 
            	where Split_Parent_Quote__c = :primaryQuote.Id 
            	order by Quote_Split_Number__c asc
        	]) {
            String chargeKey = q.Quote_Split_Number__c;
            PivLP_AuraModel.Quote qm = new PivLP_AuraModel.Quote();
            qm.key = q.Quote_Split_Number__c;
            qm.splitStatus = 'Done';
            qm.quoteStatus = q.zqu__Status__c;
            qm.quoteId = q.Id;
            qm.quoteErrorMessage = q.Error_Message__c;
            qm.startDate = q.zqu__StartDate__c;
            qm.zuoraAccountId = q.zqu__ZuoraAccountID__c;
			qm.zuoraAccountNumber = q.zqu__Zuora_Account_Number__c;     
            qm.zuoraSubscriptionId = q.zqu__ZuoraSubscriptionID__c;
            qm.zuoraSubscriptionName = q.zqu__Subscription_Name__c;
            
            qm.charges = new List<PivLP_AuraModel.Charge>();
            qm.ratePlans = new List<PivLP_AuraModel.RatePlan>();
                
            if(subQuoteCharges.containsKey(q.Id)){
                Map<Id, List<zqu__QuoteRatePlanCharge__c>> chargesByRatePlanId = subQuoteCharges.get(q.Id);
                for(Id ratePlanId : chargesByRatePlanId.keySet()){
                    PivLP_AuraModel.RatePlan ratePlan = new PivLP_AuraModel.RatePlan();
                    ratePlan.id = ratePlanId;
                    zqu__QuoteRatePlan__c qrp = qrpCache.get(ratePlanId);
                    if(qrp != null){
                        ratePlan.name = qrp.Name;
                        ratePlan.productName = qrp.Product_Name__c;
                    }
                    ratePlan.charges = new List<PivLP_AuraModel.Charge>();
                    for(zqu__QuoteRatePlanCharge__c qrpc : chargesByRatePlanId.get(ratePlanId)){
                        PivLP_AuraModel.Charge charge = new PivLP_AuraModel.Charge(qrpc);
                        ratePlan.charges.add(charge);
                        qm.charges.add(charge);
                    }
                    qm.ratePlans.add(ratePlan);
                }
            }

            lst.add(qm);
        }
        
        return lst;
    }
    
    private Map<Id, zqu__QuoteRatePlan__c> qrpCache;
    
    private Map<Id, Map<Id, List<zqu__QuoteRatePlanCharge__c>>> findSubQuoteCharges(Id primaryQuoteId){
        qrpCache = new Map<Id, zqu__QuoteRatePlan__c>();
        Map<Id, Map<Id, List<zqu__QuoteRatePlanCharge__c>>> m = new Map<Id, Map<Id, List<zqu__QuoteRatePlanCharge__c>>>();
        for(zqu__QuoteRatePlanCharge__c qrpc : [
            select Id, Name, Start_Date_Formula__c, zqu__ChargeType__c, Type__c, End_Date__c, zqu__Model__c,
            Listed_Price__c, Calculated_Discount__c, Effective_Price_Display__c, Quantity_Display__c, zqu__UOM__c,
            zqu__Period__c, zqu__Total__c,zqu__TriggerDate__c,
            zqu__QuoteRatePlan__r.zqu__Quote__c, zqu__QuoteRatePlan__r.zqu__Quote__r.Split_Parent_Quote__c, 
            zqu__QuoteRatePlan__r.zqu__Quote__r.Quote_Split_Number__c, zqu__QuoteRatePlan__r.Name, zqu__QuoteRatePlan__r.Product_Name__c
            from zqu__QuoteRatePlanCharge__c 
            where zqu__QuoteRatePlan__r.zqu__Quote__r.Split_Parent_Quote__c = :primaryQuoteId order by Start_Date_Formula__c asc]
       ) {
            qrpCache.put(qrpc.zqu__QuoteRatePlan__c, qrpc.zqu__QuoteRatePlan__r);
            if(m.containsKey(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__c)){
				//m.get(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__c).add(qrpc);
                if(m.get(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__c).containsKey(qrpc.zqu__QuoteRatePlan__c)){
                    m.get(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__c).get(qrpc.zqu__QuoteRatePlan__c).add(qrpc);
                }else{
                    m.get(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__c).put(qrpc.zqu__QuoteRatePlan__c, new List<zqu__QuoteRatePlanCharge__c>{ qrpc });
                }
            }else{
                m.put(qrpc.zqu__QuoteRatePlan__r.zqu__Quote__c, new Map<Id, List<zqu__QuoteRatePlanCharge__c>>{
                    qrpc.zqu__QuoteRatePlan__c => new List<zqu__QuoteRatePlanCharge__c>{ qrpc }
                });
            }
        }
        return m;
    }
    
    public void updateMasterQuoteOnSendComplete(Id subQuoteId){
        zqu__Quote__c subQuote = [select Id, Split_Parent_Quote__c from zqu__Quote__c where Id = :subQuoteId];
        if(subQuote.Split_Parent_Quote__c != null){
            Boolean allSent = true;
            Boolean anySent = false;
            for(zqu__Quote__c sq : [select Id, zqu__Status__c from zqu__Quote__c where Split_Parent_Quote__c = :subQuote.Split_Parent_Quote__c]){
                if(sq.zqu__Status__c != 'Sent to Z-Billing') {
                    allSent = false;
                }else{
                    anySent = true;
                }
            }
            
            if(allSent && anySent) {
                if(!Test.isRunningTest()) update new zqu__Quote__c(Id = subQuote.Split_Parent_Quote__c, zqu__Status__c = 'Sent to Z-Billing');
            }
        }
    }
    
    @future(callout=true)
    public static void updateSubscription(Id quoteId){
        system.debug('updateSubscription:'+ quoteId);
        zqu__Quote__c q = [select zqu__ZuoraSubscriptionID__c, zqu__Number__c, zqu__Opportunity__r.Name from zqu__Quote__c where Id = :quoteId];
        Zuora.zObject zSub = new Zuora.zObject('Subscription');
        zSub.setValue('Id', q.zqu__ZuoraSubscriptionID__c);
        zSub.setValue('OpportunityName__QT', q.zqu__Opportunity__r.Name);
        zSub.setValue('QuoteNumber__QT', q.zqu__Number__c);
        PivLP_ZSOAPClient.getInstance().zupdate(zSub);
    }
}