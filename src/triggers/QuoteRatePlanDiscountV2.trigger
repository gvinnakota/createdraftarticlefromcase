trigger QuoteRatePlanDiscountV2 on zqu__QuoteRatePlan__c (After update, After insert, After delete, before delete) { 

    map<string,list<zqu__QuoteRatePlan__c>> quoteRatePlanMap = new map<string,list<zqu__QuoteRatePlan__c>>();
    set<id> quoteList= new set<id>();

    List<string> approvalTypeList= new list<string>();
    List<string> ProductKey= new list<string>(); 
    List<string> AreaKey= new list<string>();
    
     
    if((trigger.isBefore && trigger.isDelete) || (trigger.isAfter && trigger.isUpdate)){
        list<string> apprTypes = new list<string>();
        list<string> quoteIds = new list<string>();
        for(zqu__QuoteRatePlan__c quote : Trigger.old){
            quoteIds.add(quote.zqu__Quote__c);
        }
        for(zqu__QuoteRatePlan__c quote : [select Id, zqu__Quote__c, Approval_Type__c from zqu__QuoteRatePlan__c where zqu__Quote__c IN :quoteIds]){
            apprTypes.add(quote.Approval_Type__c);
        }
        if(apprTypes.size()>0){
            list<Quote_Discount_Summary__c> discountSummary = [select id, name,Approval_Type__c from Quote_Discount_Summary__c where Approval_Type__c Not IN:apprTypes];
            if(discountSummary.size()>0)
               delete discountSummary;
        }
    }
    
    string actionType = '';
    if(trigger.isAfter && trigger.isInsert || trigger.isAfter && trigger.isUpdate){

        map<string, list<zqu__QuoteRatePlan__c>> quoteIdQtRatePlanMap = new map<string, list<zqu__QuoteRatePlan__c>>();
        for(zqu__QuoteRatePlan__c quoteNew : trigger.new){
            quoteList.add(quoteNew.zqu__Quote__c);
        }
        /*
        for(zqu__QuoteRatePlan__c quote :  [select Id, zqu__Quote__c, Approval_Type__c, Product__c, ApproveDiscount__c, Product_Key__c from zqu__QuoteRatePlan__c where zqu__Quote__c IN :quoteList]){
            if(quoteIdQtRatePlanMap.containsKey(quote.zqu__Quote__c)){
                quoteIdQtRatePlanMap.get(quote.zqu__Quote__c).add(quote);
            }else{
                quoteIdQtRatePlanMap.put( quote.zqu__Quote__c, new list<zqu__QuoteRatePlan__c> { quote } );
            }
            if(quote.Approval_Type__c != null)
                approvalTypeList.add(quote.Approval_Type__c);
        }

        for(String quoteId :quoteIdQtRatePlanMap.keyset()){
           list<zqu__QuoteRatePlan__c> quoteIdRPList = quoteIdQtRatePlanMap.get(quoteId);
           quoteRatePlanMap = QuoteRatePlanTriggerHandler.getzquQuoteRatePlanMap(quoteIdRPList);
        }*/
        actionType = 'isUpsert';
    }
 
    
    if(trigger.isAfter && trigger.isDelete){
        for(zqu__QuoteRatePlan__c Qrp : Trigger.old){
            zqu__QuoteRatePlan__c QrpOldValue = trigger.oldMap.get(Qrp.Id);
            if(Qrp.zqu__Product__c != null && Qrp.zqu__Quote__c != null ){
                quoteList.add(Qrp.zqu__Quote__c);
            }  
        } 
        actionType = 'isDelete';
    } 


    /**
    if(trigger.isAfter && trigger.isDelete){
        for(zqu__QuoteRatePlan__c Qrp : Trigger.old){
            zqu__QuoteRatePlan__c QrpOldValue = trigger.oldMap.get(Qrp.Id);
            if(Qrp.Product__c != null && Qrp.zqu__Quote__c != null ){
                if(quoteRatePlanMap.containskey(Qrp.Product_Key__c)){
                    quoteRatePlanMap.get(Qrp.Product_Key__c).add(Qrp);
                    quoteList.add(Qrp.zqu__Quote__c);
                    if(Qrp.Approval_Type__c != null)
                        approvalTypeList.add(Qrp.Approval_Type__c);
                }else{
                    quoteRatePlanMap.put(Qrp.Product_Key__c,new list<zqu__QuoteRatePlan__c>{Qrp});
                    quoteList.add(Qrp.zqu__Quote__c);
                    if(Qrp.Approval_Type__c != null)
                        approvalTypeList.add(Qrp.Approval_Type__c);
                }
            }  
        } 
        actionType = 'isDelete';
    } 
    **/
           
    if(quoteList.size()>0){
        QuoteRatePlanDiscountHandlerV2.UpdateQuoteApproverAndSummary(quoteList, actionType);
    }
}