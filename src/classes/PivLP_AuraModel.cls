/******************************************************************************
Name                :    PivLP_AuraModel
Author              :    Reid Beckett, Launchpad
Description         :    Data model for SendToZBilling component
Date                :    09/23/2018
*******************************************************************************/
public class PivLP_AuraModel {
    public class Quote implements Comparable {
        @AuraEnabled
        public String key {get;set;}
        @AuraEnabled
        public String splitStatus {get;set;}
        @AuraEnabled
        public String quoteStatus {get;set;}
        @AuraEnabled
        public Id quoteId {get;set;}
        @AuraEnabled
        public String quoteErrorMessage {get;set;}
        @AuraEnabled
        public Date startDate {get;set;}
        @AuraEnabled
        public String zuoraAccountId {get;set;}
        @AuraEnabled
        public String zuoraAccountNumber {get;set;}
        @AuraEnabled
        public String zuoraSubscriptionId {get;set;}
        @AuraEnabled
        public String zuoraSubscriptionName {get;set;}
        @AuraEnabled
        public List<Charge> charges {get;set;}
        @AuraEnabled
        public List<RatePlan> ratePlans {get;set;}
        
        public Integer compareTo(Object thatObj){
            return this.key.compareTo(((Quote)thatObj).key);
        }
    }

    public class RatePlan {
        @AuraEnabled
        public String id {get;set;}

        @AuraEnabled
        public String name {get;set;}

        @AuraEnabled
        public String productName {get;set;}

        @AuraEnabled
        public List<Charge> charges {get;set;}
    }

    public class Charge {
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public Date startDate {get;set;}
        @AuraEnabled
        public String chargeType {get;set;}
        @AuraEnabled
        public String endDate {get;set;}
        @AuraEnabled
        public String model {get;set;}
        @AuraEnabled
        public String listPrice {get;set;}
        @AuraEnabled
        public String discount {get;set;}
        @AuraEnabled
        public Decimal effectivePrice {get;set;}
        @AuraEnabled
        public Decimal quantity {get;set;}
        @AuraEnabled
        public String uom {get;set;}
        @AuraEnabled
        public String period {get;set;}
        @AuraEnabled
        public Decimal total {get;set;}
        
        public Charge(){}
        
        public Charge(zqu__QuoteRatePlanCharge__c qrpc){
            this.name = qrpc.Name;
            //this.startDate = qrpc.Start_Date_Formula__c;
            this.startDate = qrpc.zqu__TriggerDate__c;
            this.chargeType = qrpc.zqu__ChargeType__c;
			this.endDate = qrpc.End_Date__c;
            this.model = qrpc.zqu__Model__c;
            this.listPrice = qrpc.Listed_Price__c;
            this.discount = qrpc.Calculated_Discount__c;
            this.effectivePrice = qrpc.Effective_Price_Display__c;
            this.quantity = qrpc.Quantity_Display__c;
            this.uom = qrpc.zqu__UOM__c;
            this.period = qrpc.zqu__Period__c;
            this.total = qrpc.zqu__Total__c;
	    }
    }
}