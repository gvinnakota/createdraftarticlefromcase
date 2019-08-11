@isTest(SeeAllData = true)
private class CloneObjectTest{
	private static testMethod void shouldCloneQuoteWorkProperly(){
        //TestDataUtil.dataValueMapCSData();
		Account acct = ZTestFactory.makeAccount();
        Contact contact = ZTestFactory.makeContact(acct);
        Opportunity opp = ZTestFactory.makeOpportunity(acct);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, contact);


 
        ApexPages.currentPage().getParameters().put(CloneQuoteController.QUOTE_PARAM, quote.Id);
        CloneQuoteController ctrl = new CloneQuoteController(new ApexPages.StandardController(quote));

        System.assertEquals(ctrl.cancel().getUrl(), '/'+quote.Id);

        PageReference ref = ctrl.cloneQuote();

        Id newQuoteId = ref.getUrl().substringAfterLast('/');
        zqu__Quote__c cloned = [SELECT Id, zqu__Account__c FROM zqu__Quote__c WHERE Id = :newQuoteId];

        System.assertNotEquals(quote.Id, cloned.Id);
        System.assertEquals(acct.Id, cloned.zqu__Account__c);

        ApexPages.currentPage().getParameters().put(CloneQuoteController.OPTION_PARAM, 'change');
        ctrl = new CloneQuoteController(new ApexPages.StandardController(quote));

        System.assert(ctrl.disableClone);
        System.assert(!ctrl.showBillingAccountTable);

        ctrl.setTestBillingAccounts();

		System.assert(ctrl.disableClone);
        System.assert(ctrl.showBillingAccountTable);

        ctrl.billingAccounts.get(1).selected = true;

        System.assert(!ctrl.disableClone);
        System.assert(ctrl.showBillingAccountTable);

        Zuora__PaymentTerm__c pt = new Zuora__PaymentTerm__c(Zuora__EntityID__c='',
                Zuora__External_Id__c='');
        insert pt;

        Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c(Zuora__Account__c = acct.Id,
                CRM_Bill_To_Contact__c = contact.Id,
                CRM_Sold_To_Contact__c = contact.Id,
                Zuora__Zuora_Id__c = '2c92d0f8661fabd3016645ef9a3c1f8f',
                Zuora__Payment_Term__c = pt.Id);

        insert billAcc;
        quote.zqu__ZuoraAccountID__c = billAcc.Zuora__Zuora_Id__c;
        update quote;

        ApexPages.currentPage().getParameters().clear();
        ApexPages.currentPage().getParameters().put(CloneQuoteController.QUOTE_PARAM, quote.Id);
        ApexPages.currentPage().getParameters().put(CloneQuoteController.OPTION_PARAM, 'clone');
        ctrl = new CloneQuoteController(new ApexPages.StandardController(quote));

        for(CloneQuoteController.BillingAccountWrapper wrapper: ctrl.billingAccounts){
            if(wrapper.account.Id == billAcc.Id){
                wrapper.selected = true;
            }
        }

        ref = ctrl.cloneQuote();
        ApexPages.currentPage().getParameters().clear();
        ApexPages.currentPage().getParameters().putAll(ref.getParameters());
        ApexPages.currentPage().getParameters().put('edited', 'true');
        CloneBillingAccountController ctrl2 = new CloneBillingAccountController();
        ref = ctrl2.cloneAccount();



        ApexPages.currentPage().getParameters().clear();
        ApexPages.currentPage().getParameters().putAll(ref.getParameters());
        ctrl = new CloneQuoteController(new ApexPages.StandardController(quote));
        ctrl.redirectClone();

        ctrl2.useDuplicate();

        Zuora.zApi.SaveResult res = new Zuora.zApi.SaveResult();
        res.Success = false;
        Zuora.zObject obj = new Zuora.zObject('Error');
        obj.setValue('Message', 'This is error message');
        res.Errors = new List<Zuora.zObject>{obj};
        try{
            ctrl2.checkError(res, 'message');
        }catch (CloneBillingAccountController.ZuoraCallException ex){

        }
    }

}