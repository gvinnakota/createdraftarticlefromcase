/**
 * Created by bvadlamani on 2017-09-12.
 */

global with sharing class ZQuote_EmailTemplate_Controller {

    global String queryString { get; set; }
    global String approvalType { get; set; }
    global String quoteId { get; set; }
   
    global List<zqu__QuoteChargeSummary__c> results {
        get {
        queryString = 'SELECT Id,Name,zqu__Product_Name__c, zqu__TotalPrice__c ,SKU__c,zqu__Quantity__c,zqu__UOM__c,Accounting_Code__c, '+
                                    'ACV_USD_Formula__c, zqu__TCV__c , ApproveDiscount__c , Custom_TCV_Formula__c ,Billing_Period__c,ConfDateRange__c, zqu__Discount__c ,ConfYears__c,Quote_ID__c, '+
                                    'Start_Date__c FROM zqu__QuoteChargeSummary__c';
                                    
     if (!String.isEmpty(queryString)) {
      queryString += ' Where Quote_ID__c = \''+ quoteId +'\'';
    }

    if (!String.isEmpty(approvalType)) {
      queryString += ' AND Approval_Type__c = \'' + approvalType + '\'';
    }
    List<zqu__QuoteChargeSummary__c> result = Database.Query(queryString);
    return result;
        }
        set;
    }
}