/******************************************************************************
Name                :    PivLP_QuoteSplitManager
Author              :    Reid Beckett, Launchpad
Description         :    Manager for ZQuote split functionality
Date                :    09/14/2018
*******************************************************************************/
public class PivLP_QuoteSplitManager {
    static Set<String> QUOTE_CHARGE_CUSTOM_FIELDS = new Set<String>{'id', 'listed_price__c', 'listed_total__c', 'initial_term__c', 'start_date__c', 'end_date__c', 'country_uplift__c', 'calculated_discount__c', 'quote_split_number__c','psamount__c', 'rate_usd__c','tcv_usd__c', 'Start_Date_Formula__c'};
    private Map<Date, Integer> quoteSplitMap = new Map<Date, Integer>();
 	private static Boolean SPLIT_ALL_CHARGES_BY_DATE = false; //false for old split functionality, true for new


    //step 1 - call with master quote id to get map keys (each will become a quote)
    public List<PivLP_AuraModel.Quote> getSubQuotesBeforeSplit(Id quoteId) {
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>{'Id'};
        Map < Id, zqu.zChargeGroup > chargeToChargeGroupMap = getChargeToChargeGroupMap(quoteId);
        zqu__QuoteRatePlanCharge__c[] existingQuoteCharges = getQuoteCharges(chargeToChargeGroupMap.keySet());
        system.debug('num charges:'+existingQuoteCharges.size());
        system.debug('charges:'+existingQuoteCharges);
        Map <String, List<zqu__QuoteRatePlanCharge__c >> chargeMap = getSeparateChargeMap(existingQuoteCharges);
        system.debug('chargeMap size:'+chargeMap.size());
        system.debug('chargeMap:'+chargeMap);

        List<PivLP_AuraModel.Quote> lst = new List<PivLP_AuraModel.Quote>();
        for(String chargeKey : chargeMap.keySet()){
            PivLP_AuraModel.Quote q = new PivLP_AuraModel.Quote();
            q.key = chargeKey;
            q.splitStatus = 'Pending';

            List<zqu__QuoteRatePlanCharge__c > charges = chargeMap.get(chargeKey);
	        system.debug('key:'+q.key+': ' + charges.size() + ' charges');
            if(!charges.isEmpty()){
                q.startDate = charges.get(0).Start_Date_Formula__c;
            }

            q.charges = new List<PivLP_AuraModel.Charge>();
            q.ratePlans = new List<PivLP_AuraModel.RatePlan>();

            Set<Id> ratePlanIds = new Set<Id>();

            for(zqu__QuoteRatePlanCharge__c qrpc : charges){
                if(!ratePlanIds.contains(qrpc.zqu__QuoteRatePlan__c)){
                    ratePlanIds.add(qrpc.zqu__QuoteRatePlan__c);
                    PivLP_AuraModel.RatePlan ratePlan = new PivLP_AuraModel.RatePlan();
                    ratePlan.id = qrpc.zqu__QuoteRatePlan__c;
                    ratePlan.name = qrpc.zqu__QuoteRatePlan__r.Name;
                    ratePlan.productName = qrpc.zqu__QuoteRatePlan__r.Product_Name__c;
                    ratePlan.charges = new List<PivLP_AuraModel.Charge>();
                    ratePlan.charges.add(new PivLP_AuraModel.Charge(qrpc));
                    q.ratePlans.add(ratePlan);
                }else{
                    for(PivLP_AuraModel.RatePlan ratePlan : q.ratePlans){
                        if(ratePlan.id == qrpc.zqu__QuoteRatePlan__c){
		                    ratePlan.charges.add(new PivLP_AuraModel.Charge(qrpc));
                        }
                    }
                }
                q.charges.add(new PivLP_AuraModel.Charge(qrpc));
            }
            lst.add(q);
        }
        lst.sort();
        return lst;
    }

    /*
    public List<String> getChargeKeys(Id quoteId) {
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>{'Id'};
        Map < Id, zqu.zChargeGroup > chargeToChargeGroupMap = getChargeToChargeGroupMap(quoteId);
        zqu__QuoteRatePlanCharge__c[] existingQuoteCharges = getQuoteCharges(chargeToChargeGroupMap.keySet());
        return new List<String>(getSeparateChargeMap(existingQuoteCharges).keySet());
    }*/

    //step 2 - split the quote into sub-quotes
    public Id splitQuote(Id quoteId, String chargeKey){
        Map < Id, zqu.zChargeGroup > chargeToChargeGroupMap = getChargeToChargeGroupMap(quoteId);
        zqu__QuoteRatePlanCharge__c[] existingQuoteCharges = getQuoteCharges(chargeToChargeGroupMap.keySet());
        Map < String, List < zqu__QuoteRatePlanCharge__c > > separateChargeMap = getSeparateChargeMap(existingQuoteCharges);

        system.debug('chargeKey:'+chargeKey);
        system.debug('separateChargeMap:');
        system.debug(separateChargeMap);
        system.debug('separateChargeMap('+chargeKey+')');
        system.debug(separateChargeMap.get(chargeKey));

		if (chargeKey != null && chargeKey.startsWith('Services-')) {
            zqu__Quote__c shadowQuote = buildPSUsageQuote(quoteId, separateChargeMap.get(chargeKey), chargeKey);
            return shadowQuote.Id;
        }else{
          zqu__Quote__c newSubQuote = cloneQuote(quoteId, separateChargeMap.get(chargeKey), chargeKey);
          return newSubQuote.Id;
        }
    }

    //METHODS CALLED TO PREPARE SPLIT SUB-QUOTES
    private Map <String, List<zqu__QuoteRatePlanCharge__c>> getSeparateChargeMap(List<zqu__QuoteRatePlanCharge__c> existingQuoteCharges){
        Map <String, List <zqu__QuoteRatePlanCharge__c>> separateChargeMap = new Map<String, List<zqu__QuoteRatePlanCharge__c>>();

        for (zqu__QuoteRatePlanCharge__c qc: existingQuoteCharges) {
            // populate separateChargeMap for split quote
            // this map will store the charges into separate group
            // based on Quote_Split_Number
            if (separateChargeMap.get(qc.Quote_Split_Number__c) == null) {
                // if there is no map found with quote split number
                separateChargeMap.put(qc.Quote_Split_Number__c, new List<zqu__QuoteRatePlanCharge__c>{ qc });
            } else {
                boolean found = false;
                for (zqu__QuoteRatePlanCharge__c cc : separateChargeMap.get(qc.Quote_Split_Number__c)){
                    if (qc.zqu__QuoteRatePlan__c == cc.zqu__QuoteRatePlan__c){
                        found = true;
                    }
                }

                //if(!found){
                    // add charges to existing separateChargeMap
                    separateChargeMap.get(qc.Quote_Split_Number__c).add(qc);
                //}
            }
        }
        return separateChargeMap;
    }

    private Map<Id, zqu.zChargeGroup> getChargeToChargeGroupMap(Id quoteId){
		Map < Id, zqu.zChargeGroup > chargeToChargeGroupMap = new Map < Id, zqu.zChargeGroup >();
        for (zqu.zchargeGroup cg: zqu.zQuoteUtil.getChargeGroups(quoteId)) {
            System.Debug('Number of Charges:' + cg.zcharges.size());
            for (zqu.zCharge charge : cg.zcharges) {
            	chargeToChargeGroupMap.put(charge.Id, cg);
            }
        }
        return chargeToChargeGroupMap;
    }

    private List<zqu__QuoteRatePlanCharge__c> getQuoteCharges(Set<Id> chargeIds){
        return [
            SELECT
            Id, Name,
            Quote_Split_Number__c,zqu__TriggerDate__c,
            zqu__QuoteRatePlan__c,
            zqu__QuoteRatePlan__r.zqu__QuoteAmendment__c,
            Product_Rate_Plan__c,
            zqu__ProductRatePlanCharge__c,
            zqu__ProductRatePlanCharge__r.zqu__ZuoraId__c,
            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__c,
            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name,
            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.ProductServiceCategory__c,
            Start_Date__c,
            Initial_Term__c, zqu__EffectivePrice__c, zqu__ListPrice__c, zqu__Quantity__c,
            Start_Date_Formula__c, zqu__ChargeType__c, End_Date__c, zqu__Model__c, Listed_Price__c, Calculated_Discount__c,
            Effective_Price_Display__c, Quantity_Display__c, zqu__UOM__c, zqu__Period__c, zqu__Total__c,
            zqu__QuoteRatePlan__r.Name, zqu__QuoteRatePlan__r.Product_Name__c
            FROM
            zqu__QuoteRatePlanCharge__c
            WHERE
            Id IN :chargeIds
        ];
    }
    //END METHODS CALLED TO PREPARE SPLIT SUB-QUOTES

    //METHODS TO PERFORM SPLIT
	private zqu__Quote__c buildPSUsageQuote(String quoteId, List < zqu__QuoteRatePlanCharge__c > charges, String chargeKey) {
        System.debug('In buildPSUsageQuote');

        // create a quote
        zqu__Quote__c quote = getQuoteInfo(quoteId);
        zqu__Quote__c subQuote = quote.clone(false, true, false, false);
        subQuote.Quote_Split_Number__c = chargeKey;
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
        //Mar-5-2019 added this
        subQuote.zqu__InvoiceSeparately__c = true;

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
                    (zqu__Product__r.ProductServiceCategory__c = 'Services' or zqu__ZProduct__r.ProductServiceCategory__c = 'Services') and
                    zqu__Product__c in :productIds];

        for (zqu__ProductRatePlan__c ratePlan : rateplans) {
            ratePlanIds.add(ratePlan.Id);
        }

        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = QUOTE_CHARGE_CUSTOM_FIELDS;
        List<zqu.zChargeGroup> chargeGroups = null;
        if(!ratePlanIds.isEmpty()) chargeGroups = zqu.zQuoteUtil.getChargeGroups(subQuote.Id, new List<String>(ratePlanIds));
        else chargeGroups = new List<zqu.zChargeGroup>();

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

    private zqu__Quote__c cloneQuote(Id quoteId, List <zqu__QuoteRatePlanCharge__c> charges, String key){
        system.debug('cloneQuote:charges.size='+charges.size());
        system.debug('cloneQuote:charges:'+charges);
        zqu__Quote__c quote = getQuoteInfo(quoteId);
        String zSubId = quote.zqu__ZuoraSubscriptionID__c;

        //this is a unique external id, need to remove it
        quote.zqu__ZuoraSubscriptionID__c = '';
        update quote;

        zqu__Quote__c subQuote = quote.clone(false, true, false, false);
        subQuote.Quote_Split_Number__c = key;
        subQuote.name += ' '+key;
        if(subQuote.name.length() > 80) {
            subQuote.name = subQuote.name.subString(0,80); // quote.name field allows only 80 characters
        }
        subQuote.zqu__ZuoraSubscriptionID__c = zSubId;
        subQuote.zqu__Status__c = 'New';
        subQuote.Split_Parent_Quote__c = quoteId;
        subQuote.zqu__Is_Parent_Quote__c = false;
        subQuote.Primary_Quote__c = false;
        //Mar-5-2019 added this
        subQuote.zqu__InvoiceSeparately__c = false;

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
        //01/09/2019 - calculate term
        Date subEndDate = null;
        Integer initialTerm = 0;
        for (zqu__QuoteRatePlanCharge__c charge : charges) {
            Date startDate = null;
            if (charge.Start_Date__c != null && charge.Start_Date__c != '') {
                startDate = Date.valueOf(charge.Start_Date__c+' 00:00:00');
            }
            Date endDate = null;
            if (charge.End_Date__c != null && charge.End_Date__c != '') {
                endDate = Date.valueOf(charge.End_Date__c+' 00:00:00');
            }
            if (subStartDate == null || startDate < subStartDate) {
                subStartDate = startDate;
                initialTerm = Integer.valueOf(charge.Initial_Term__c);
            }
            if (subEndDate == null || endDate > subEndDate) {
                subEndDate = endDate;
            }
        }
        
        if(subStartDate != null && subEndDate != null) {
            initialTerm = calculateTerm(subStartDate,subEndDate);
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
        } else if (subQuote.zqu__SubscriptionType__c == 'Renew Subscription') {
            defaultrtinfo = dsr.getRecordTypeInfosByName().get('Renewal'); //=> Renewal ReadOnly
        } else {
            defaultrtinfo = dsr.getRecordTypeInfosByName().get('Default');  //=> ReadOnly
        }
        subQuote.RecordTypeId = defaultrtinfo.getRecordTypeId();

        subQuote.zqu__ZuoraAccountID__c = quote.zqu__ZuoraAccountID__c;

        insert subQuote;
        System.Debug('Quote Cloned :' + subQuote);

        // clone quote amendments, quote rateplans, and quote rateplan charges
        if (quote.zqu__SubscriptionType__c == 'New Subscription') {
        	clonesubQuoteObjects(subStartDate, quote.Id, subQuote.Id, charges, key);
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
    private void clonesubQuoteObjects(Date subStartDate, String oldQuoteId, String subQuoteId, List < zqu__QuoteRatePlanCharge__c > charges, String chargeKey) {
        System.Debug('Cloning new quote objects');
        List < zqu__QuoteRatePlanCharge__c > newQcList = new List < zqu__QuoteRatePlanCharge__c > ();
        List < zqu__QuoteRatePlanCharge__c > oldQcList = new List < zqu__QuoteRatePlanCharge__c > ();

        Map<Id, zqu__QuoteRatePlanCharge__c> mapOfCharges = new Map<Id, zqu__QuoteRatePlanCharge__c>();
        Set<String> productNames = new Set<String>();
        Set<String> qrpIds = new Set<String>();
        Set<Id> amendmentIds = new Set<Id>();
        for (zqu__QuoteRatePlanCharge__c charge : charges) {
            mapOfCharges.put(charge.Id, charge);
            productNames.add(charge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name);
            qrpIds.add(charge.zqu__QuoteRatePlan__c);
            amendmentIds.add(charge.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__c);
        }

        //get the quote amendment on the old quote
        List < zqu__QuoteAmendment__c > quoteAmendments = Database.query(getCreatableFieldsSOQL('zqu__QuoteAmendment__c', 'zqu__Quote__c = :oldQuoteId'));
        Map<Id, zqu__QuoteAmendment__c> qaList = new Map<Id, zqu__QuoteAmendment__c>();
        for (zqu__QuoteAmendment__c qaObject : quoteAmendments) {
            if(amendmentIds.contains(qaObject.Id)){
                zqu__QuoteAmendment__c qa = qaObject.clone(false, true, false, false);
                qa.zqu__Quote__c = subQuoteId;
                if(subStartDate != null && qa.zqu__ContractEffectiveDate__c != null && qa.zqu__ContractEffectiveDate__c < subStartDate)
                    qa.zqu__ContractEffectiveDate__c = subStartDate;
                if(subStartDate != null && qa.zqu__CustomerAcceptanceDate__c != null && qa.zqu__CustomerAcceptanceDate__c < subStartDate)
                    qa.zqu__CustomerAcceptanceDate__c = subStartDate;
                if(subStartDate != null && qa.zqu__ServiceActivationDate__c != null && qa.zqu__ServiceActivationDate__c < subStartDate)
                    qa.zqu__ServiceActivationDate__c = subStartDate;
                //qa.Id = null;
                qaList.put(qaObject.Id, qa);
            }
        }

        insert qaList.values();
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
            if(qaList.containsKey(qrpObject.zqu__QuoteAmendment__c)){
                zqu__QuoteRatePlan__c qrp = qrpObject;
                qrp.zqu__Quote__c = subQuoteId;
                //qrp.zqu__QuoteAmendment__c = qaList[0].Id; //amendmentMap.get(qrp.zqu__AmendmentType__c).remove(0);
                qrp.zqu__QuoteAmendment__c = qaList.get(qrpObject.zqu__QuoteAmendment__c).Id;
                qrp.Old_Id__c = qrp.Id;
                qrp.Id = null;
                qrpList.add(qrp);
            }
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
                if(newQrp != null){
                    temp.zqu__QuoteRatePlan__c = newQrp.Id;
                    System.debug('subquoterateplan id: '+newQrp.Id+  ' new quote charge: '+temp);
                    newQcList.add(temp);
                }
            }
        }

        if (!newQcList.isEmpty()) {
            //System.debug('quote charge list: '+newQcList);
            insert newQcList;
        }
    }

    private zqu__Quote__c getQuoteInfo(String quoteId) {
    	return (zqu__Quote__c) Database.query(getCreatableFieldsSOQL('zqu__Quote__c', 'id=\'' + quoteId + '\''));
  	}

    /*
    Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    */
    private string getCreatableFieldsSOQL(String objectName, String whereClause) {
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
    //END METHODS TO PERFORM SPLIT
    //
    private String getQuoteSplitNumber(ProductSelectorController.ChargeGroupHolder cg, zqu.ZCharge charge){
        if (cg.isServices) {
            return 'Services-' + cg.sRatePlanId + charge.ChargeObject.get('Start_Date__c');
        }else{
            return '1';
            /*
            if(SPLIT_ALL_CHARGES_BY_DATE){
                //old way
                Date enddate = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00').addMonths(Integer.valueOf(charge.ChargeObject.get('Initial_Term__c')));
                if (quoteSplitMap.containsKey(enddate)) {
                    return String.valueOf(quoteSplitMap.get(enddate));
                } else {
                    Integer increment = quoteSplitMap.size() + 1;
                    quoteSplitMap.put(enddate, increment);
                    return String.valueOf(increment);
                }
            }else{
                return '1';
            }*/
        }
    }

    public Date updateQuoteSplitNumbers(zqu__Quote__c quote, List<ProductSelectorController.ChargeGroupHolder> cghList, List<ProductSelectorController.ChargeGroupHolder> existingChargeGroupHolders, Double conversionRate) {
        return updateQuoteSplitNumbers(quote, cghList, existingChargeGroupHolders, conversionRate, false).earliestDate;
    }


    private ProductSelectorController.ChargeGroupHolder copyChargeGroupHolder(ProductSelectorController.ChargeGroupHolder chargeGroupHolder){
        ProductSelectorController.ChargeGroupHolder newChargeGroupHolder = new ProductSelectorController.ChargeGroupHolder();
        if(chargeGroupHolder.chargeGroup != null) {
            newChargeGroupHolder.chargeGroup = copyChargeGroup(chargeGroupHolder.chargeGroup);
        }
        newChargeGroupHolder.id = chargeGroupHolder.id;
        newChargeGroupHolder.display = chargeGroupHolder.display;
        newChargeGroupHolder.hasBeenUpdated = chargeGroupHolder.hasBeenUpdated;
        newChargeGroupHolder.isServices = chargeGroupHolder.isServices;
        newChargeGroupHolder.sRatePlanId = chargeGroupHolder.sRatePlanId;
        if(chargeGroupHolder.chargeWrappers != null) {
            newChargeGroupHolder.chargeWrappers = new List<ProductSelectorController.ChargeWrapper>();
            for (ProductSelectorController.ChargeWrapper wrapper : chargeGroupHolder.chargeWrappers) {
                newChargeGroupHolder.chargeWrappers.add(copyChargeWrapper(wrapper));
            }
        }
        if(chargeGroupHolder.sRatePlan != null) {
            newChargeGroupHolder.sRatePlan = copyRatePlan(chargeGroupHolder.sRatePlan);
        }
        return  newChargeGroupHolder;
    }

    private zqu__ProductRatePlan__c copyRatePlan(zqu__ProductRatePlan__c ratePlan) {
        //RatePlan isn't edited. We don't need to copy it.
        return  ratePlan;
    }

    private zqu.zChargeGroup copyChargeGroup(zqu.zChargeGroup zChargeGroup){
        return zChargeGroup.deepClone();
    }

    private ProductSelectorController.ChargeWrapper copyChargeWrapper(ProductSelectorController.ChargeWrapper chargeWrapper){
        ProductSelectorController.ChargeWrapper newChargeWrapper = new ProductSelectorController.ChargeWrapper();
        if(chargeWrapper.zcharge != null) {
            newChargeWrapper.zcharge = chargeWrapper.zcharge.clone();
        }
        newChargeWrapper.start_Date = chargeWrapper.start_Date;
        newChargeWrapper.initial_Term = chargeWrapper.initial_Term;
        newChargeWrapper.listed_Price = chargeWrapper.listed_Price;
        newChargeWrapper.calculated_Discount = chargeWrapper.calculated_Discount;
        newChargeWrapper.listed_Total = chargeWrapper.listed_Total;
        newChargeWrapper.renderListPrice = chargeWrapper.renderListPrice;
        newChargeWrapper.charge_model = chargeWrapper.charge_model;
        newChargeWrapper.oldQuantity = chargeWrapper.oldQuantity;
        newChargeWrapper.rollupType = chargeWrapper.rollupType;
        newChargeWrapper.isNotDiscountable = chargeWrapper.isNotDiscountable;
        return newChargeWrapper;
    }

    public zqu__Quote__c updateQuoteSplitNumbersPreview(zqu__Quote__c quote, List<ProductSelectorController.ChargeGroupHolder> cghList, List<ProductSelectorController.ChargeGroupHolder> existingChargeGroupHolders, Double conversionRate) {
        List<ProductSelectorController.ChargeGroupHolder> cghListCopy = new List<ProductSelectorController.ChargeGroupHolder>();
        List<ProductSelectorController.ChargeGroupHolder> existingChargeGroupHoldersCopy = new List<ProductSelectorController.ChargeGroupHolder>();
        for (ProductSelectorController.ChargeGroupHolder c : cghList) {
            cghListCopy.add(copyChargeGroupHolder(c));
        }
        for (ProductSelectorController.ChargeGroupHolder c : existingChargeGroupHolders) {
            existingChargeGroupHoldersCopy.add(copyChargeGroupHolder(c));
        }
        return updateQuoteSplitNumbers(quote, cghListCopy, existingChargeGroupHoldersCopy, conversionRate, true).updatedQuote;
    }

    class UpdateQuoteSplitNumbersResult {
        Date earliestDate;
        zqu__Quote__c updatedQuote;
    }

    //adapted from ProductSelectorController
    private UpdateQuoteSplitNumbersResult updateQuoteSplitNumbers(zqu__Quote__c quote, List<ProductSelectorController.ChargeGroupHolder> cghList, List<ProductSelectorController.ChargeGroupHolder> existingChargeGroupHolders, Double conversionRate, Boolean isPreview) {
        PivLP_Logger.put('quoteId', quote.Id);
        Map<Date, Integer> quoteSplitMap = new Map<Date, Integer>();
        //Map<String, List<zqu.zCharge>> subscriptionMap = new Map<String, List<zqu.zCharge>>();
        Map<String, List<zqu.zChargeGroup>> subscriptionMap = new Map<String, List<zqu.zChargeGroup>>();
        Map<String, String> chargeToRatePlanMap = new Map<String, String>();
        Integer increment = 1;
        Integer largestTerm = 0;
        Date earliestDate = null;
        //1/5/19 - adding "latestDate" logic instead of largestTerm
        Date latestDate = null;
        Date earliestDateForTerm = null;
        
        system.debug('***cghList:'+cghList.size());

        Set<String> chargeGroupsAdded = new Set<String>();
        
        // New charges
        for (ProductSelectorController.ChargeGroupHolder cg : cghList) {
            cg.hasBeenUpdated = true;

            for (zqu.ZCharge charge : cg.chargeGroup.zCharges) {

                chargeToRatePlanMap.put(charge.PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID, cg.chargeGroup.productRateplanZuoraID);
                if (Integer.valueOf(charge.ChargeObject.get('Initial_Term__c')) > largestTerm) {
                    largestTerm = Integer.valueOf(charge.ChargeObject.get('Initial_Term__c'));
                }

                //1/5/19 - adding "latestDate" logic instead of largestTerm
                if(charge.ChargeObject.get('Start_Date__c') != null){
                    if (earliestDateForTerm == null || earliestDateForTerm > Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00')) {
                        earliestDateForTerm = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00');
                    }
                }

                if(charge.ChargeObject.get('End_Date__c') != null){
                    if (latestDate == null || latestDate < Date.valueOf(charge.ChargeObject.get('End_Date__c') + ' 00:00:00')) {
                        latestDate = Date.valueOf(charge.ChargeObject.get('End_Date__c') + ' 00:00:00');
                    }
                }

                if (cg.isServices) {

                    charge.ChargeObject.put('PSAmount__c', Decimal.valueOf(charge.TOTAL));
                    System.debug('PS-REDESIGN : PS Amount = ' + charge.ChargeObject.get('PSAmount__c'));

                    // If it is PS charges,
                    // TCV_USD__c = PSAmount__c (GBP) / rate(0.65);
                    // MRR, ARR, ACV = 0 for PS charges
                    charge.ChargeObject.put('TCV_USD__c', String.valueOf((Decimal.valueOf(charge.TOTAL) / conversionRate).setScale(2)));


                    // Each "Services" rateplans should have unique Quote_Split_Number__c,
                    // so that each PS rateplan will be a separate subscription.
                    //String splitNumber = getQuoteSplitNumber(cg, charge);
                    //String subscriptionKey = 'Services-' + cg.sRatePlanId + charge.ChargeObject.get('Start_Date__c');
                    String subscriptionKey = getQuoteSplitNumber(cg, charge);
                    charge.ChargeObject.put('Quote_Split_Number__c', subscriptionKey);
                    //refactor subscirptionmap into map of chargegroups
                    PivLP_Logger.debug('0217 *** new PS charge:id:'+cg.id+':groupId:'+cg.chargeGroup.groupID);
                    if (!subscriptionMap.containsKey(subscriptionKey)) {
                        List<zqu.zChargeGroup> chargeList = new List<zqu.zChargeGroup>();
                        chargeList.add(cg.chargeGroup);
                        subscriptionMap.put(subscriptionKey, chargeList);
                        chargeGroupsAdded.add(String.valueOf(cg.id));
                    }
                }
                // end of PS charges
                else {
                    if (earliestDate == null) {
                        // set the earliest date to the start date of first charge
                        earliestDate = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00');
                    }

                    if (earliestDate > Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00')) {
                        earliestDate = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00');
                    }

                    Date enddate = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00').addMonths(Integer.valueOf(charge.ChargeObject.get('Initial_Term__c')));
                    Datetime dt = datetime.newInstance(enddate.year(), enddate.month(), enddate.day());
                    System.debug('end date display: ' + dt.format('yyyy-MM-dd'));
                    System.debug('end date: ' + enddate);
                    System.debug('in split, charge: ' + charge);
                    String splitNumber = getQuoteSplitNumber(cg, charge);
                    PivLP_Logger.debug('0118 *** new product charge:id:'+cg.id+':groupId:'+cg.chargeGroup.groupID);
                    if(subscriptionMap.containsKey(splitNumber)){
                        if(!chargeGroupsAdded.contains(String.valueOf(cg.id))){
                            subscriptionMap.get(splitNumber).add(cg.chargeGroup);
                            chargeGroupsAdded.add(String.valueOf(cg.id));
                        }
                        charge.ChargeObject.put('Quote_Split_Number__c', splitNumber);
                    }else{
                        subscriptionMap.put(splitNumber, new List<zqu.zChargeGroup>{cg.chargeGroup});
                        chargeGroupsAdded.add(String.valueOf(cg.id));
                        charge.ChargeObject.put('Quote_Split_Number__c', splitNumber);
                    }
                    System.debug('Start_Date__c = ' + charge.ChargeObject.get('Start_Date__c'));
                    charge.ChargeObject.put('End_Date__c', dt.format('yyyy-MM-dd'));
                    charge.ChargeObject.put('End_Date_Display__c', enddate);
                    
                    //01-11-2019 - set specific end date
                    if(enddate != null && charge.CHARGE_TYPE == 'Recurring') {
                        charge.ChargeObject.put('zqu__EndDateCondition__c', 'Specific End Date');
                        charge.ChargeObject.put('zqu__SpecificEndDate__c', enddate);
                        charge.END_DATE_CONDITION = 'Specific End Date';
                        charge.SPECIFIC_END_DATE = DateTime.newInstance(enddate.year(), enddate.month(), enddate.day()).format('yyyy-MM-dd');  
                        PivLP_Logger.debug('0217: new charge isSpecificEndDateEditable : ' + charge.isSpecificEndDateEditable );
                        PivLP_Logger.debug('0217: new charge set SPECIFIC_END_DATE='+charge.SPECIFIC_END_DATE);
                        PivLP_Logger.debug('0217: new charge set END_DATE_CONDITION='+charge.END_DATE_CONDITION);
                        PivLP_Logger.debug('0217: new charge specific end date should be '+DateTime.newInstance(enddate.year(), enddate.month(), enddate.day()).format('yyyy-MM-dd'));
                    }else{
                        //added 1/25/2019
                        PivLP_Logger.debug('0217: nulling out zqu__SpecificEndDate__c');
                        charge.ChargeObject.put('zqu__SpecificEndDate__c', null);
                        charge.SPECIFIC_END_DATE = null;
                        if(charge.CHARGE_TYPE == 'One-Time'){
                            charge.ChargeObject.put('zqu__EndDateCondition__c', 'One Time');
                            charge.END_DATE_CONDITION = 'One Time';
                        }else{
                            charge.ChargeObject.put('zqu__EndDateCondition__c', 'Subscription End Date');
                            charge.END_DATE_CONDITION = 'Subscription End Date';
                        }
                    }
                }

                increment++;

            }
        }
        System.debug('quote split map: ' + quoteSplitMap);

        system.debug('***existingChargeGroupHolders:'+existingChargeGroupHolders.size());

        Integer i=0;
        for (ProductSelectorController.ChargeGroupHolder cg : existingChargeGroupHolders) {
            PivLP_Logger.debug('charge group['+i+']:start:'+cg.chargeGroup.groupID);
            cg.hasBeenUpdated = true;
            for (zqu.ZCharge charge : cg.chargeGroup.zCharges) {
                System.debug('prp id: ' + cg.chargeGroup.productRateplanZuoraID);
                chargeToRatePlanMap.put(charge.PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID, String.valueOf(charge.ChargeObject.get('Product_Rate_Plan_ZuoraID__c')));
                if (Integer.valueOf(charge.ChargeObject.get('Initial_Term__c')) > largestTerm) {
                    largestTerm = Integer.valueOf(charge.ChargeObject.get('Initial_Term__c'));
                }
                
                if(charge.ChargeObject.get('Start_Date__c') != null){
                    if (earliestDateForTerm == null || earliestDateForTerm > Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00')) {
                        earliestDateForTerm = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00');
                    }
                }

                //1/5/19 - adding "latestDate" logic instead of largestTerm
                if(charge.ChargeObject.get('End_Date__c') != null){
                    if (latestDate == null || latestDate < Date.valueOf(charge.ChargeObject.get('End_Date__c') + ' 00:00:00')) {
                        latestDate = Date.valueOf(charge.ChargeObject.get('End_Date__c') + ' 00:00:00');
                    }
                }

                if (cg.isServices) {

                    charge.ChargeObject.put('PSAmount__c', Decimal.valueOf(charge.TOTAL));
                    System.debug('PS-REDESIGN : PS Amount = ' + charge.ChargeObject.get('PSAmount__c'));


                    // If it is PS charges,
                    // TCV_USD__c = PSAmount__c (GBP) / rate(0.65); (test and confirm if )
                    // MRR, ARR, ACV = 0 for PS charges
                    charge.ChargeObject.put('TCV_USD__c', String.valueOf((Decimal.valueOf(charge.TOTAL) / conversionRate).setScale(2)));

                    // Each "Services" rateplans should have unique Quote_Split_Number__c,
                    // so that each PS rateplan will be a separate subscription.
                    String subscriptionKey = getQuoteSplitNumber(cg, charge);
                    charge.ChargeObject.put('Quote_Split_Number__c', subscriptionKey);
                    //refactor subscirptionmap into map of chargegroups
                    PivLP_Logger.debug('0118 *** existing product charge:id:'+cg.id+':groupId:'+cg.chargeGroup.groupID);
                    PivLP_Logger.debug('charge group['+i+']:0');
                    PivLP_Logger.debug('charge group['+i+']:subscriptionKey='+subscriptionKey);
                    if (!subscriptionMap.containsKey(subscriptionKey)) {
	                    PivLP_Logger.debug('charge group['+i+']:0A');
                        List<zqu.zChargeGroup> chargeList = new List<zqu.zChargeGroup>();
                        chargeList.add(cg.chargeGroup);
				        if(!chargeGroupsAdded.contains(cg.chargeGroup.groupID)){
		                    PivLP_Logger.debug('charge group['+i+']:0B');
                            subscriptionMap.put(subscriptionKey, chargeList);
                            chargeGroupsAdded.add(cg.chargeGroup.groupID);
                        }
                    }

                } else {
                    if (earliestDate > Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00')) {
                        earliestDate = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00');
                    }

                    System.debug('Initial Term: ' + charge.ChargeObject.get('Initial_Term__c'));
                    Date enddate = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00').addMonths(Integer.valueOf(charge.ChargeObject.get('Initial_Term__c')));
                    //Date enddate = Date.today().addMonths(Integer.valueOf(charge.ChargeObject.get('Initial_Term__c')));
                    Datetime dt = datetime.newInstance(enddate.year(), enddate.month(), enddate.day());
                    //refactor subscirptionmap into map of chargegroups
                    String splitNumber = getQuoteSplitNumber(cg, charge);
                    PivLP_Logger.debug('0118 *** existing product charge:id:'+cg.id+':groupId:'+cg.chargeGroup.groupID);
		            PivLP_Logger.debug('charge group['+i+']:splitNumber='+splitNumber);
                    if(subscriptionMap.containsKey(splitNumber)){
			            PivLP_Logger.debug('charge group['+i+']:1');
                        charge.ChargeObject.put('Quote_Split_Number__c', splitNumber);
                        if(!chargeGroupsAdded.contains(cg.chargeGroup.groupID)){
				            PivLP_Logger.debug('charge group['+i+']:2');
                            subscriptionMap.get(splitNumber).add(cg.chargeGroup);
                            chargeGroupsAdded.add(cg.chargeGroup.groupID);
                        }
                    }else{
                        PivLP_Logger.debug('charge group['+i+']:3');
                        PivLP_Logger.debug('0118 *** new sub, adding charge group: '+cg.chargeGroup.groupID);
                        subscriptionMap.put(splitNumber, new List<zqu.zChargeGroup>{cg.chargeGroup});
                        charge.ChargeObject.put('Quote_Split_Number__c', splitNumber);
                        chargeGroupsAdded.add(cg.chargeGroup.groupID);
                    }
                    System.debug('Start_Date__c = ' + charge.ChargeObject.get('Start_Date__c'));
                    System.debug('end date display: ' + dt.format('yyyy-MM-dd'));
                    System.debug('end date: ' + enddate);
                    charge.ChargeObject.put('End_Date__c', dt.format('yyyy-MM-dd'));
                    charge.ChargeObject.put('End_Date_Display__c', enddate);
                    //01-11-2019 - set specific end date
                    if(enddate != null && charge.CHARGE_TYPE == 'Recurring') {
                        charge.ChargeObject.put('zqu__EndDateCondition__c', 'Specific End Date');
                        charge.ChargeObject.put('zqu__SpecificEndDate__c', enddate);
                        charge.END_DATE_CONDITION = 'Specific End Date';
                        charge.SPECIFIC_END_DATE = DateTime.newInstance(enddate.year(), enddate.month(), enddate.day()).format('yyyy-MM-dd');  
                        PivLP_Logger.debug('0217: existing charge isSpecificEndDateEditable : ' + charge.isSpecificEndDateEditable );
                        PivLP_Logger.debug('0217: existing charge set SPECIFIC_END_DATE='+charge.SPECIFIC_END_DATE);
                        PivLP_Logger.debug('0217: existing charge set END_DATE_CONDITION='+charge.END_DATE_CONDITION);
                    }else{
                        //added 1/25/2019
                        PivLP_Logger.debug('0217: nulling out SPECIFIC_END_DATE');
                        charge.ChargeObject.put('zqu__SpecificEndDate__c', null);
                        charge.SPECIFIC_END_DATE = null;
                        if(charge.CHARGE_TYPE == 'One-Time'){
                            charge.ChargeObject.put('zqu__EndDateCondition__c', 'One Time');
                            charge.END_DATE_CONDITION = 'One Time';
                        }else{
                            charge.ChargeObject.put('zqu__EndDateCondition__c', 'Subscription End Date');
                            charge.END_DATE_CONDITION = 'Subscription End Date';
                        }
                    }
                }

                increment++;
            }

            PivLP_Logger.debug('charge group['+i+']:end');
            i++;
        }
        System.debug('quote split map: ' + quoteSplitMap);
        System.debug('subscription map: ' + subscriptionMap);
        zqu__Quote__c quoteToUpdate = new zqu__Quote__c();
        quoteToUpdate.Id = quote.Id;

        //1/5/19 - debug
        system.debug('before: '+quoteToUpdate.zqu__InitialTerm__c);

        //1/5/19 - adding "latestDate" logic instead of largestTerm
        Integer initialTerm = null;
        system.debug('updateQuoteSplitNumbers earliestDateForTerm='+earliestDateForTerm);
        system.debug('updateQuoteSplitNumbers latestDate='+latestDate);
        if(latestDate != null && earliestDateForTerm != null){
            initialTerm = calculateTerm(earliestDateForTerm,latestDate);
            system.debug('updateQuoteSplitNumbers (1): set initialTerm='+initialTerm);
        }else {
            initialTerm = largestTerm;
            system.debug('updateQuoteSplitNumbers (2): set initialTerm='+initialTerm);
        }

        quoteToUpdate.zqu__InitialTerm__c = initialTerm;

        system.debug('after: '+quoteToUpdate.zqu__InitialTerm__c);

        Decimal tcv = 0;
        Decimal mrr = 0;
        Decimal subtotal = 0;
        Decimal tax = 0;
        Decimal total = 0;

        // update quote with quote metrics values
        for (String key : subscriptionMap.keySet()) {
            //create subscription
            List<zqu.zChargeGroup> chargeList = subscriptionMap.get(key);
            System.debug('chargeToRatePlanMap: ' + chargeToRatePlanMap);
            PivLP_Logger.put('chargeList-size',chargeList.size());
            PivLP_Logger.put('chargeGroupsAdded',chargeGroupsAdded);
            Map<String, Decimal> results = subscribePreviewCall(chargeList, chargeToRatePlanMap, quote);
            if (results.get('TCV') != null && results.get('MRR') != null) {
                tcv = results.get('TCV') + tcv;
                mrr = results.get('MRR') + mrr;
                subtotal = results.get('subtotal') + subtotal;
                tax = results.get('tax') + tax;
                total = subtotal + tax;
            } else {
                tcv = null;
                mrr = null;
                break;
            }
        }

        if (tcv != null && mrr != null) {
            quoteToUpdate.Calculated_Total_TCV__c = String.valueOf(tcv.setScale(2));
            quoteToUpdate.Calculated_Total_MRR__c = String.valueOf(mrr.setScale(2));
            quoteToUpdate.Calculated_SubTotal__c = String.valueOf(subtotal.setScale(2));
            quoteToUpdate.Calculated_Tax__c = String.valueOf(tax.setScale(2));
            quoteToUpdate.Calculated_Total__c = String.valueOf(total.setScale(2));
        } else {
            quoteToUpdate.Calculated_Total_TCV__c = 'Error in Calculating Metrics';
            quoteToUpdate.Calculated_Total_MRR__c = 'Error in Calculating Metrics';
            quoteToUpdate.Calculated_SubTotal__c = 'Error in Calculating Metrics';
            quoteToUpdate.Calculated_Tax__c = 'Error in Calculating Metrics';
            quoteToUpdate.Calculated_Total__c = 'Error in Calculating Metrics';
        }

        if(!isPreview) {
            update quoteToUpdate;
        }

        UpdateQuoteSplitNumbersResult result = new UpdateQuoteSplitNumbersResult();
        result.earliestDate = earliestDate;
        result.updatedQuote = quoteToUpdate;
        return result;
    }

    public Map<String, Decimal> subscribePreviewCall(List<zqu.zChargeGroup> chargeGroups, Map<String, String> chargeMap, zqu__Quote__c q) {
        Map<String, Decimal> returnValues = new Map<String, Decimal>();

        system.debug('########### ChargeMap = ' + chargeMap);

        try {
            Company_Code__c companyCode = null;

            List<Company_Code__c> companyCodes = [SELECT Tax_Region__c from Company_Code__c where Code__c = :q.Company_Code1__c];
            if (companyCodes.size() > 0) {
                companyCode = companyCodes[0];
            }

            //build dummy account and contact
            Zuora.zObject acc = new Zuora.zObject('Account');
            acc.setValue('Name', q.zqu__Account__r.name);
            acc.setValue('Currency', q.zqu__Currency__c);
            acc.setValue('BillCycleDay', 1);
            acc.setValue('PaymentTerm', q.zqu__PaymentTerm__c);
            if (q.Tax_Exempt__c) {
                acc.setValue('TaxExemptStatus', 'Yes');
                //acc.setValue('TaxExemptCertificateID', 'Dummy Cert');
                acc.setValue('TaxExemptCertificateID', q.Certificate_Id1__c);
            } else {
                acc.setValue('TaxExemptStatus', 'No');
            }
            acc.setValue('Batch', 'Batch2'); //direct is 2, indirect is 1
            if (companyCode != null) {
                acc.setValue('TaxCompanyCode', companyCode.Tax_Region__c);
            }
            acc.setvalue('VATId', q.VAT_ID1__c);
            //acc.setValue('Invoice_VATID__c', q.VAT_ID1__c);

            //build contacts
            Zuora.zObject billToContact = new Zuora.zObject('Contact');
            billToContact.setValue('Address1', q.zqu__SoldToContact__r.MailingStreet);
            billToContact.setValue('City', q.zqu__SoldToContact__r.MailingCity);
            billToContact.setValue('Country', q.zqu__SoldToContact__r.MailingCountryCode);
            billToContact.setValue('PostalCode', q.zqu__SoldToContact__r.MailingPostalCode);
            billToContact.setValue('State', q.zqu__SoldToContact__r.MailingStateCode);
            billToContact.setValue('FirstName', q.zqu__SoldToContact__r.FirstName);
            billToContact.setValue('LastName', q.zqu__SoldToContact__r.LastName);

            Zuora.zObject soldToContact = new Zuora.zObject('Contact');
            soldToContact.setValue('Address1', q.zqu__SoldToContact__r.MailingStreet);
            soldToContact.setValue('City', q.zqu__SoldToContact__r.MailingCity);
            soldToContact.setValue('Country', q.zqu__SoldToContact__r.MailingCountryCode);
            soldToContact.setValue('PostalCode', q.zqu__SoldToContact__r.MailingPostalCode);
            soldToContact.setValue('State', q.zqu__SoldToContact__r.MailingStateCode);
            soldToContact.setValue('FirstName', q.zqu__SoldToContact__r.FirstName);
            soldToContact.setValue('LastName', q.zqu__SoldToContact__r.LastName);
            //soldToContact.setValue('TaxRegion', companyCode.Tax_Region__c);

            Map<String, Zuora.zObject> rpdMap = new Map<String, Zuora.zObject>();
            List<Zuora.zObject> rpdList = new List<Zuora.zObject>();

            Integer largestTerm = 0;
            Date earliestDate = null;
            //1/5/19 - adding "latestDate" logic instead of largestTerm
            Date latestDate = null; 
            
            
            //1/9/19 - fetching product rate plan charge config
            /*Set<Id> productRatePlanChargeIds = new Set<Id>();
            for (zqu.zChargeGroup chargeGroup : chargeGroups) {
                for (zqu.zCharge charge : chargeGroup.zCharges) {
                    if(!String.isBlank(charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID)) productRatePlanChargeIds.add(charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);
                }
            }
            Map<Id, zqu__ProductRatePlanCharge__c> productRatePlanChargesById = new Map<Id, zqu__ProductRatePlanCharge__c>(
                [select Id, zqu__RecurringPeriod__c from zqu__ProductRatePlanCharge__c where Id in :productRatePlanChargeIds]
            );*/

            for (zqu.zChargeGroup chargeGroup : chargeGroups) {
                String productRateplanId = chargeMap.get(chargeGroup.zCharges[0].PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID);

                system.debug('########### productRateplanId = ' + productRateplanId);

                Zuora.zObject rp = new Zuora.zObject('RatePlan');
                rp.setValue('ProductRatePlanId', productRateplanId);
                Zuora.zObject rpd = new Zuora.zObject('RatePlanData');
                rpd.setValue('RatePlan', rp);

                for (zqu.zCharge charge : chargeGroup.zCharges) {
                    if (Integer.valueOf(charge.ChargeObject.get('Initial_Term__c')) > largestTerm) {
                        largestTerm = Integer.valueOf(charge.ChargeObject.get('Initial_Term__c'));
                    }

                    if (earliestDate == null || earliestDate > Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00')) {
                        earliestDate = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00');
                    }

		            //1/5/19 - adding "latestDate" logic instead of largestTerm
                    if(charge.ChargeObject.get('End_Date__c') != null){
                        if (latestDate == null || latestDate < Date.valueOf(charge.ChargeObject.get('End_Date__c') + ' 00:00:00')) {
                            latestDate = Date.valueOf(charge.ChargeObject.get('End_Date__c') + ' 00:00:00');
                        }
                    }
                    
                    system.debug('PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID='+charge.PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID);
                    system.debug('PRODUCT_RATE_PLAN_CHARGE_SFDC_ID='+charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);
                    system.debug('PERIOD='+charge.PERIOD); 
                    /*String billingPeriod = null;
                    if(!String.isBlank(charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID)){
                        Id prpcId = Id.valueOf(charge.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID);
                        if(productRatePlanChargesById.containsKey(prpcId)) {
                            billingPeriod = productRatePlanChargesById.get(prpcId).zqu__RecurringPeriod__c;
	                    	system.debug('zqu__RecurringPeriod__c='+billingPeriod); 
                        }
                    }*/

                    Zuora.zObject rpc = new Zuora.zObject('RatePlanCharge');
                    rpc.setValue('ProductRatePlanChargeId', charge.PRODUCT_RATE_PLAN_CHARGE_ZUORA_ID);
                    if (charge.QUANTITY != '-') {
                        rpc.setValue('Quantity', charge.QUANTITY);
                    }
                    rpc.setValue('Price', charge.EFFECTIVE_PRICE);

                    if (charge.CHARGE_TYPE == 'Recurring') {
                        Date startDate = Date.valueOf(charge.ChargeObject.get('Start_Date__c') + ' 00:00:00');
                        Datetime startDateTime = datetime.newInstance(startDate.year(), startDate.month(), startDate.day());
                        rpc.setValue('TriggerEvent', 'SpecificDate');
                        //rpc.setValue('TriggerDate', startDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss'));
                        rpc.setValue('TriggerDate', startDateTime.formatGmt('yyyy-MM-dd'));
                        //01/09/2019 - set UpToPeriods to ensure proper end date of charge and proper TCV
                        //if(billingPeriod != null && startDate != null && charge.ChargeObject.get('End_Date__c') != null){
                        if(charge.ChargeObject.get('End_Date__c') != null){
                            Date endDate = Date.valueOf(charge.ChargeObject.get('End_Date__c') + ' 00:00:00');
                            /*
                            Integer monthsBetween = startDate.monthsBetween(endDate);
                            Integer divisor = null;
                            if(billingPeriod == 'Annual') {
                                divisor = 12;
                            }
                            if(divisor != null){
                                rpc.setValue('EndDateCondition', 'FixedPeriod');
                                rpc.setValue('UpToPeriods',monthsBetween/divisor);
                            }
							*/
	                        Datetime endDateTime = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day());
                            rpc.setValue('EndDateCondition', 'SpecificEndDate');
                            rpc.setValue('SpecificEndDate', endDateTime.formatGmt('yyyy-MM-dd'));
                        }
                    }

                    Zuora.zObject rpcd = new Zuora.zObject('RatePlanChargeData');
                    rpcd.setValue('RatePlanCharge', rpc);
                    List<Zuora.zObject> existingRpcds = new List<Zuora.zObject>();
                    List < Object > exisingRpcdList = rpd.getArrayValue('RatePlanChargeData');
                    if (exisingRpcdList != null) {
                        for (Object exisingRpcd : exisingRpcdList) {
                            existingRpcds.add((Zuora.zObject) exisingRpcd);
                        }
                    }
                    existingRpcds.add(rpcd);
                    rpd.setValue('RatePlanChargeData', existingRpcds);

                }
                rpdList.add(rpd);
            }

            Datetime dt = datetime.newInstance(earliestDate.year(), earliestDate.month(), earliestDate.day());
            //String effectiveDate = dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
            String effectiveDate = dt.formatGmt('yyyy-MM-dd');
            
            //1/5/19 - adding "latestDate" logic instead of largestTerm
            Integer initialTerm = null;
            if(latestDate != null && earliestDate != null){
                initialTerm = calculateTerm(earliestDate,latestDate);
                system.debug('subscribePreview call (1): set initialTerm='+initialTerm);
            }else {
                initialTerm = largestTerm;
                system.debug('subscribePreview call (2): set initialTerm='+initialTerm);
            }

            //subscription
            Zuora.zObject sub = new Zuora.zObject('Subscription');
            sub.setValue('Name', 'subscription - SubscriptionName');
            sub.setValue('ContractEffectiveDate', effectiveDate);
            sub.setValue('ServiceActivationDate', effectiveDate);
            sub.setValue('InitialTerm', initialTerm);
            sub.setValue('RenewalTerm', 12);


            Zuora.zApi.SubscriptionData sd = new Zuora.zApi.SubscriptionData();
            sd.Subscription = sub;
            sd.RatePlanData = rpdList;

            Date todayDate = Date.today();
            Datetime invoiceDate = DateTime.newInstance(todayDate.year(), todayDate.month(), todayDate.day());


            Zuora.zApi.SubscribeInvoiceProcessingOptions sip = new Zuora.zApi.SubscribeInvoiceProcessingOptions();
            Datetime enddt = dt.addMonths(initialTerm);
            //sip.InvoiceTargetDate = enddt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
            sip.InvoiceTargetDate = enddt.formatGmt('yyyy-MM-dd');
            //sip.InvoiceDate = invoiceDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
            sip.InvoiceDate = invoiceDate.formatGmt('yyyy-MM-dd');

            //subscription options
            Zuora.zApi.SubscribeOptions so = new Zuora.zApi.SubscribeOptions();
            so.GenerateInvoice = true;
            so.ProcessPayments = false;
            so.SubscribeInvoiceProcessingOptions = sip;

            //Preview options
            //Integer numOfPeriods =
            Zuora.zApi.PreviewOptions previewOpt = new Zuora.zApi.PreviewOptions();
            previewOpt.EnablePreviewMode = true;

            //previewOpt.NumberOfPeriods = numOfPeriods;
            //subscribe request
            Zuora.zApi.SubscribeRequest subsRequest = new Zuora.zApi.SubscribeRequest();

            subsRequest.ZAccount = acc;
            subsRequest.BillToContact = billToContact;
            subsRequest.SoldToContact = soldToContact;
            subsRequest.SubscribeOptions = so;
            subsRequest.SubscriptionData = sd;

            subsRequest.PreviewOptions = previewOpt;

            List<Zuora.zApi.SubscribeRequest> subsRequestLists = new List<Zuora.zApi.SubscribeRequest>{
                    subsRequest
            };

            List<Zuora.zApi.SubscribeResult> subscribeResults = PivLP_ZSOAPClient.getInstance().zsubscribe(subsRequestLists);
            if (!Test.isRunningTest()) {
                System.debug('SOAP Request = ' + Zuora.zApi.currentLogger.request);
                System.debug('SOAP Response = ' + Zuora.zApi.currentLogger.response);
                PivLP_Logger.debug(Zuora.zApi.currentLogger.request);
                PivLP_Logger.debug(Zuora.zApi.currentLogger.response);
            }

            for (Zuora.zApi.SubscribeResult result : subscribeResults) {
                if (result.Success) {
                    //Handle with the invoice data returned by previewing subscriptions
                    System.debug('MRR: ' + result.TotalMrr);
                    System.debug('TCV: ' + result.TotalTCV);
                    returnValues.put('TCV', result.TotalTCV);
                    returnValues.put('MRR', result.TotalMrr);
                    if (result.InvoiceDatas != null) {
                        for (Zuora.zObject invData : result.InvoiceDatas) {
                            //in Preview mode, handle with the invoice data
                            Zuora.zObject invoice = (Zuora.zObject) invData.getValue('Invoice');
                            Decimal amountwithoutTax = (Decimal) invoice.getValue('AmountWithoutTax');
                            Decimal taxAmount = (Decimal) invoice.getValue('TaxAmount');
                            returnValues.put('subtotal', amountwithoutTax);
                            returnValues.put('tax', taxAmount);
                        }
                    }

                } else {
                    returnValues.put('TCV', null);
                    returnValues.put('MRR', null);
                    //failure
                    //get the errors
                    Zuora.zObject[] errors = result.errors;
                    for (Zuora.zObject error : errors) {
                        String errorCode = (String) error.getValue('Code');
                        String message = (String) error.getValue('Message');
                        //more code here...
                        System.debug('Error during the preview call: [Error Code] =' + errorCode);
                        System.debug('Error during the preview call: [Error Message] =' + message);
                    }
                }
            }

        } catch (Zuora.zRemoteException ex) {
            returnValues.put('TCV', null);
            returnValues.put('MRR', null);
        } catch (Zuora.zAPIException ex) {
            returnValues.put('TCV', null);
            returnValues.put('MRR', null);
        } catch (Zuora.zForceException ex) {
            returnValues.put('TCV', null);
            returnValues.put('MRR', null);
        }

        return returnValues;
    }

    public void cleanSplit(Id quoteId){
        delete [select Id from zqu__Quote__c where Split_Parent_Quote__c = :quoteId];
    }
    
    public Integer calculateTerm(Date startDate, Date endDate) {
        if(startDate == null || endDate == null) return null;
        if(startDate.day() < endDate.day()) return startDate.monthsBetween(endDate) + 1; //round up
        else return startDate.monthsBetween(endDate);
    }
    
}