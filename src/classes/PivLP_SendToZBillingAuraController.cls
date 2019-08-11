/******************************************************************************
Name                :    PivLP_SendToZBillingAuraController
Author              :    Reid Beckett, Launchpad
Description         :    Aura controller for SendToZBilling component
Date                :    09/14/2018
*******************************************************************************/
public class PivLP_SendToZBillingAuraController {
    public static PivLP_QuoteSplitManager quoteSplitManagerInstance;

    private static PivLP_QuoteSplitManager getQuoteSplitManager(){
        if(quoteSplitManagerInstance == null){
            quoteSplitManagerInstance = new PivLP_QuoteSplitManager();
        }
        return quoteSplitManagerInstance;
    }

    public static PivLP_ZOrdersManager zordersManagerInstance;

    private static PivLP_ZOrdersManager getZOrdersManager(){
        if(zordersManagerInstance == null){
            zordersManagerInstance = new PivLP_ZOrdersManager();
        }
        return zordersManagerInstance;
    }

    @AuraEnabled
    public static List<PivLP_AuraModel.Quote> getChargeKeys(Id quoteId) {
        String methodName = 'PivLP_SendToZBillingAuraController.getChargeKeys';
        PivLP_Logger.start(methodName);
        PivLP_Logger.put('quoteId',quoteId);
        try{
	        return getQuoteSplitManager().getSubQuotesBeforeSplit(quoteId);
        }catch(Exception e){
            PivLP_Logger.error(e);
            throw new AuraHandledException(e.getMessage());
        }finally{
	        PivLP_Logger.finish(methodName);
            PivLP_Logger.flush();
        }
  	}
    
    @AuraEnabled
    public static Id splitQuote(Id quoteId, String chargeKey){
        String methodName = 'PivLP_SendToZBillingAuraController.splitQuote';
        PivLP_Logger.start(methodName);
        PivLP_Logger.put('quoteId',quoteId);
        PivLP_Logger.put('chargeKey',chargeKey);
        try{
	        return getQuoteSplitManager().splitQuote(quoteId, chargeKey);
        }catch(Exception e){
            PivLP_Logger.error(e);
            throw new AuraHandledException(e.getMessage());
        }finally{
	        PivLP_Logger.finish(methodName);
            PivLP_Logger.flush();
        }
    }
    
    @AuraEnabled
    public static Map<String,Object> initAction(Id quoteId){
        String methodName = 'PivLP_SendToZBillingAuraController.initAction';
        PivLP_Logger.start(methodName);
        PivLP_Logger.put('quoteId',quoteId);
        try{
            PivLP_ZOrdersManager mgr = getZOrdersManager();
            zqu__Quote__c primaryQuote = mgr.findMasterQuote(quoteId);
            
            List<String> errors = new List<String>();
            if(primaryQuote.OM_Status__c != 'Accepted') errors.add('OM Status must be Accepted');
            if(!primaryQuote.Primary_Quote__c ) errors.add('Must be a primary quote');
            if(primaryQuote.Approval__c != 'Approved') errors.add('Quote must be approved');
            
	        //PivLP_Logger.put('primaryQuote',primaryQuote);
            return new Map<String,Object>{
                'primaryQuote' => primaryQuote,
                'subQuotes' => mgr.findSubQuotes(primaryQuote),
                'errors' => errors
            };
        }catch(Exception e){
            PivLP_Logger.error(e);
            throw new AuraHandledException(e.getMessage());
        }finally{
	        PivLP_Logger.finish(methodName);
            PivLP_Logger.flush();
        }
    }

    @AuraEnabled
    public static void cleanSplit(Id quoteId){
        String methodName = 'PivLP_SendToZBillingAuraController.cleanSplit';
        PivLP_Logger.start(methodName);
        PivLP_Logger.put('quoteId',quoteId);
        try{
	        getQuoteSplitManager().cleanSplit(quoteId);
        }catch(Exception e){
            PivLP_Logger.error(e);
            throw new AuraHandledException(e.getMessage());
        }finally{
	        PivLP_Logger.finish(methodName);
            PivLP_Logger.flush();
        }
    }
    
    @AuraEnabled
    public static String createZuoraAccount(Id quoteId){
        String methodName = 'PivLP_SendToZBillingAuraController.createZuoraAccount';
        PivLP_Logger.start(methodName);
        PivLP_Logger.put('quoteId',quoteId);
        try{
            PivLP_ZOrdersManager mgr = getZOrdersManager();
            return mgr.createZuoraAccount(quoteId);
        }catch(Exception e){
            PivLP_Logger.error(e);
            throw new AuraHandledException(e.getMessage());
        }finally{
	        PivLP_Logger.finish(methodName);
            PivLP_Logger.flush();
        }
    }

    @AuraEnabled
    public static String sendToZBilling(Id quoteId){
        String methodName = 'PivLP_SendToZBillingAuraController.sendToZBilling';
        PivLP_Logger.start(methodName);
        PivLP_Logger.put('quoteId',quoteId);
        try{
	        PivLP_ZOrdersManager mgr = getZOrdersManager();
            List<String> errors = mgr.sendToZBilling(quoteId);
            
            if(errors.isEmpty()) {
                //if completed all subquotes, update the top-level quote
                mgr.updateMasterQuoteOnSendComplete(quoteId);
            }
            
            return String.join(errors, '|');
        }catch(AuraHandledException e){
            PivLP_Logger.error(e);
            throw e;
        }catch(Exception e){
            PivLP_Logger.error(e);
            throw new AuraHandledException(e.getMessage());
        }finally{
	        PivLP_Logger.finish(methodName);
            PivLP_Logger.flush();
        }
    }

}