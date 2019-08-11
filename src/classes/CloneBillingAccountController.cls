public with sharing class CloneBillingAccountController {
    public static final String ID_PARAM = 'id';
    public static final String QUOTE_PARAM = 'quoteId';

    private Zuora.zApi api;

    public zqu__Quote__c quote{get; set;}

    public Zuora__CustomerAccount__c acc {
        get;
        private set;
    }

    public List<ContactWrapper> billToContactWrapperList {get; private set;}
    public List<ContactWrapper> soldToContactWrapperList {get; private set;}

    public Boolean enableEdit {
        get {
            return ApexPages.currentPage().getParameters().containsKey(QUOTE_PARAM);
        }
        private set;
    }

    public Boolean showDuplicateModal{ get; set; }

    public CloneBillingAccountController() {
        showDuplicateModal = false;

        System.debug('PARAMS:' + ApexPages.currentPage().getParameters());
        // Billing Account
        String id = ApexPages.currentPage().getParameters().get(ID_PARAM);
        acc = Database.query('SELECT ' + getAllFields(Zuora__CustomerAccount__c.getSObjectType()) + ' FROM Zuora__CustomerAccount__c WHERE Id = \'' + id + '\'');
//        acc.Company_Code_Custom__c = acc.Company_Code__c;
//        acc.Custom_Channel__c = acc.Channel__c;
        // Quote
        if (enableEdit) {
            String quoteId = ApexPages.currentPage().getParameters().get(QUOTE_PARAM);
            quote = [
                SELECT
                    zqu__Opportunity__r.AccountId, zqu__Account__c
                FROM
                    zqu__Quote__c
                WHERE
                    Id = :quoteId
            ];

            // related Contacts
            fetchContacts();
        }
    }

    public void fetchContacts() {
        billToContactWrapperList = new List<ContactWrapper>();
        soldToContactWrapperList = new List<ContactWrapper>();
        for (Contact relatedContact: [
            SELECT
                Name, FirstName, LastName, Email, Phone, Fax, MailingStreet, MailingAddress, MailingCity, MailingState, MailingPostalCode, MailingCountry
            FROM
                Contact
            WHERE
                AccountId = :quote.zqu__Opportunity__r.AccountId
        ]) {
            ContactWrapper billToWrapper = new ContactWrapper(relatedContact);
            billToWrapper.selected = relatedContact.Id==acc.CRM_Bill_To_Contact__c;
            billToContactWrapperList.add(billToWrapper);
            ContactWrapper soldToWrapper = new ContactWrapper(relatedContact);
            soldToWrapper.selected = relatedContact.Id==acc.CRM_Sold_To_Contact__c;
            soldToContactWrapperList.add(soldToWrapper);
        }
    }

    private void setContacts() {
        // Bill To Contact
        for (ContactWrapper wrapper: billToContactWrapperList) {
            if (wrapper.selected == true) {
                System.debug('!!! BILL TO '+wrapper.contact.FirstName);
                acc.CRM_Bill_To_Contact__c = wrapper.contact.Id;
                acc.CRM_Bill_To_Contact_Id__c = wrapper.contact.Id;
                for(String billToKey: CloneBillingAccountHelper.BILL_TO_CONTACT_TO_BILLING_ACCOUNT_FIELD_MAP.keySet()){
                    if(billToKey=='MailingAddress'){
                        Address a =  wrapper.contact.MailingAddress;
                        acc.Zuora__BillToAddress1__c = a.street + ' ' + a.city + ' ' + a.state + ' ' + a.postalCode + ' ' + a.country;
                        continue;
                    }
                    acc.put(CloneBillingAccountHelper.BILL_TO_CONTACT_TO_BILLING_ACCOUNT_FIELD_MAP.get(billToKey),
                            wrapper.contact.get(billToKey));
                }
                break;
            }
        }

        // Sold To Contact
        for (ContactWrapper wrapper: soldToContactWrapperList) {
            if (wrapper.selected == true) {
                System.debug('!!! SOLD TO '+wrapper.contact.FirstName);
                acc.CRM_Sold_To_Contact__c = wrapper.contact.Id;
                acc.CRM_Sold_To_Contact_Id__c = wrapper.contact.Id;
                for(String soldToKey: CloneBillingAccountHelper.SOLD_TO_CONTACT_TO_BILLING_ACCOUNT_FIELD_MAP.keySet()){
                    if(soldToKey=='MailingAddress'){
                        Address a =  wrapper.contact.MailingAddress;
                        acc.Zuora__SoldToAddress1__c = a.street + a.city + a.state + a.postalCode + a.country;
                        continue;
                    }
                    acc.put(CloneBillingAccountHelper.SOLD_TO_CONTACT_TO_BILLING_ACCOUNT_FIELD_MAP.get(soldToKey),
                            wrapper.contact.get(soldToKey));
                }
                break;
            }
        }



    }

    public PageReference cloneAccount() {
        if (quote != null && !ApexPages.currentPage().getParameters().containsKey('edited')) {
            return null;

        }

        try {
            initApi();

            if (quote != null) {
                setContacts();
//                acc.Company_Code__c = acc.Company_Code_Custom__c; todo:add these fields, but idk what they're supposed to do
//                acc.Channel__c = acc.Custom_Channel__c; todo:add these fields, but idk what they're supposed to do

//                acc.CRM_Bill_To_Contact_Id__c = acc.CRM_Bill_To_Contact__c;
//                acc.CRM_Sold_To_Contact_Id__c = acc.CRM_Sold_To_Contact__c;
                String query = 'SELECT Id FROM Zuora__CustomerAccount__c WHERE ';
                for(Schema.FieldSetMember m: Schema.SObjectType.Zuora__CustomerAccount__c.fieldSets.Editable_Clone_Fields.getFields()){
                    if(m.fieldPath=='Custom_Channel__c'){
//                        query += 'Channel__c  = \'' + acc.Custom_Channel__c + '\' AND ';
                        continue;
                    }
                    if(m.fieldPath=='Company_Code_Custom__c'){
//                        query += 'Company_Code__c  = \'' + acc.Company_Code_Custom__c + '\' AND ';
                        continue;
                    }
                    query += m.fieldPath + ' = ' +
                            ((m.type==DisplayType.INTEGER||m.type==DisplayType.DOUBLE)?acc.get(m.fieldPath):
                                ('\'' + acc.get(m.fieldPath) + '\''))
                            + ' AND ';
                }
                query = query.substring(0, query.length()-5);
                System.debug(query);
                List<Zuora__CustomerAccount__c> accs = Database.query(query);
                System.debug(accs);
                System.debug(acc.Company_Code__c);
                if (!accs.isEmpty()) {
                    System.debug(accs);
                    showDuplicateModal = true;
                    System.debug(showDuplicateModal);
                    return null;
                }
            }

            String accountId = createAndInsertAccount(acc);
            String billToContactId = createAndInsertContact(acc, accountId, false);
            String soldToContactId = createAndInsertContact(acc, accountId, true);

            updateAccount(accountId, billToContactId, soldToContactId, acc);

            System.debug('Zuora ID=' + accountId);

            sync(new Set<String>{
                    accountId
            });




            if (quote != null) {
                PageReference ref = Page.CloneQuote;
                ref.getParameters().put(CloneQuoteController.QUOTE_PARAM, quote.Id);
                ref.getParameters().put(CloneQuoteController.OPTION_PARAM, 'change');
                ref.getParameters().put(CloneQuoteController.ZACC_PARAM, accountId);
                ref.getParameters().put(CloneQuoteController.BTID_PARAM, acc.CRM_Bill_To_Contact__c);
                ref.getParameters().put(CloneQuoteController.STID_PARAM, acc.CRM_Sold_To_Contact__c);
                return ref;

            } else {
                return new PageReference('/' + acc.Id);
            }

        } catch (Exception e) {
            System.debug(e);
            ApexPages.addMessages(e);
        }
        return null;
    }

    public PageReference useDuplicate(){
        PageReference ref = Page.CloneQuote;
        Zuora__CustomerAccount__c acc = [
                        SELECT Zuora__Zuora_Id__c, CRM_Bill_To_Contact__c, CRM_Sold_To_Contact__c
                        FROM Zuora__CustomerAccount__c
                        WHERE CRM_Bill_To_Contact__c = :acc.CRM_Bill_To_Contact__c
                        AND CRM_Sold_To_Contact__c = :acc.CRM_Sold_To_Contact__c
                        AND Name = :acc.Name
                        LIMIT 1
                ];
        ref.getParameters().put(CloneQuoteController.QUOTE_PARAM, quote.Id);
        ref.getParameters().put(CloneQuoteController.OPTION_PARAM, 'change');
        ref.getParameters().put(CloneQuoteController.ZACC_PARAM, acc.Zuora__Zuora_Id__c);
        ref.getParameters().put(CloneQuoteController.BTID_PARAM, acc.CRM_Bill_To_Contact__c);
        ref.getParameters().put(CloneQuoteController.STID_PARAM, acc.CRM_Sold_To_Contact__c);
        return ref;
    }

    private void initApi() {
        api = new Zuora.zApi();
        if (!Test.isRunningTest()) {
            api.zlogin();
        } else {
            //figure this out
        }

    }

    private String createAndInsertAccount(Zuora__CustomerAccount__c acc) {
        if(Test.isRunningTest()){
            return '';
        }
        Zuora.zObject account = new Zuora.zObject('Account');
        for (String field : CloneBillingAccountHelper.SALESFORCE_TO_ZUORA_ACCOUNT_FIELD_MAP.keySet()) {
            if (field == 'Zuora__Status__c') {
                account.setValue('Status', 'Draft');
                continue;
            }
            account.setValue(CloneBillingAccountHelper.SALESFORCE_TO_ZUORA_ACCOUNT_FIELD_MAP.get(field), acc.get(field));
        }
        if (quote == null) {
            account.setValue('Name', 'CLONE ' + account.getValue('Name'));
        }
        account.setValue('CrmId', acc.Zuora__Account__c);

        Zuora.zApi.SaveResult res = api.zcreate(new List<Zuora.zObject>{
                account
        }).get(0);
        if (!res.Success) {
            System.debug('Error inserting account');
            for (Zuora.zObject obj : res.Errors) {
                System.debug(obj);
                ZuoraCallException ex = new ZuoraCallException();
                ex.setMessage((String)obj.getValue('Message'));
                throw ex;
            }
        }
        return res.Id;
    }

    private void updateAccount(String accountId, String billToContactId, String soldToContactId, Zuora__CustomerAccount__c acc) {
        if(Test.isRunningTest()){
            return;
        }
        Zuora.zObject account = api.zquery('select ' + String.join(CloneBillingAccountHelper.SALESFORCE_TO_ZUORA_ACCOUNT_FIELD_MAP.values(), ',') + ' from Account where Id = \'' + accountId + '\'').get(0);

        account.setValue('BillToId', billToContactId);
        account.setValue('SoldToId', soldToContactId);
        account.setValue('Status', acc.Zuora__Status__c);
        Zuora.zApi.SaveResult res = api.zupdate(new List<Zuora.zObject>{
                account
        }).get(0);
        checkError(res, 'Error updating account');
        account = api.zquery('select ' + String.join(CloneBillingAccountHelper.SALESFORCE_TO_ZUORA_ACCOUNT_FIELD_MAP.values(), ',') + ' from Account where Id = \'' + accountId + '\'').get(0);

    }

    private String createAndInsertContact(Zuora__CustomerAccount__c acc, String accountId, Boolean isSold) {
        Zuora.zObject contact = new Zuora.zObject('Contact');
        for (String field : isSold ? CloneBillingAccountHelper.SALESFORCE_TO_ZUORA_SOLD_TO_CONTACT_FIELD_MAP.keySet() : CloneBillingAccountHelper.SALESFORCE_TO_ZUORA_BILL_TO_CONTACT_FIELD_MAP.keySet()) {
            if (field == 'Zuora__' + (isSold ? 'Sold' : 'Bill') + 'ToName__c') {
                List<String> names = ((String) acc.get(field)).split(' ');
                contact.setValue('FirstName', names.get(0));
                contact.setValue('LastName', names.get(1));
                System.debug(acc.get(field));
                continue;
            }
            contact.setValue((isSold ? CloneBillingAccountHelper.SALESFORCE_TO_ZUORA_SOLD_TO_CONTACT_FIELD_MAP : CloneBillingAccountHelper.SALESFORCE_TO_ZUORA_BILL_TO_CONTACT_FIELD_MAP).get(field), acc.get(field));
        }
        contact.setValue('Id', (String) null);
        contact.setValue('AccountId', accountId);
        if(Test.isRunningTest()){
            return '';
        }else{
            Zuora.zApi.SaveResult res = api.zcreate(new List<Zuora.zObject>{
                    contact
            }).get(0);
            checkError(res, 'Error inserting ' + (isSold ? 'sold' : 'bill') + ' contact');
            return res.Id;
        }

    }

    @TestVisible
    private void checkError(Zuora.zApi.SaveResult res, String message){
        if (!res.Success) {
            System.debug(message);
            for (Zuora.zObject obj : res.Errors) {
                System.debug(obj);
                ZuoraCallException ex = new ZuoraCallException();
                ex.setMessage((String)obj.getValue('Message'));
                throw ex;
            }
        }
    }

    private void sync(Set<String> ids) {

        Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
        syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
        syncManager.syncZuoraObjectIdSet = ids;
        syncManager.emailNotificationEnabled = false;
        List<Zuora.SyncResult> syncResult = new List<Zuora.SyncResult>();
        if(!Test.isRunningTest()){
            syncResult = syncManager.sendRequest();
        }
        for (Zuora.SyncResult res : syncResult) {
            System.debug(res.statusMessage);
        }
    }

    private static String getAllFields(SObjectType objectType) {
        List<String> fieldList = new List<String>(objectType.getDescribe().fields.getMap().keySet());
        return String.join(fieldList, ', ');
    }


    public class ZuoraCallException extends Exception {
    }

    public class ContactWrapper {
        public Boolean selected {get; set;}
        public Contact contact {get; private set;}

        public ContactWrapper(Contact contact) {
            selected = false;
            this.contact = contact;
        }
    }
}