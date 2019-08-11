/**
 * Created by klukawski on 9/7/18.
 */

global with sharing class PACEmailTableController {
    public Id quoteId {get; set{
        System.debug(value);
        quoteId = value;
        pacs = new List<PAC__c>([
                SELECT Key__c, Quantity__c, Product__c, Subscription_Period__c, Assigned_Product2__c,
                        Assigned_Product2__r.Name
                FROM PAC__c
                WHERE Quote__c = :value
                ORDER BY Assigned_Product2__c DESC, Quantity__c DESC
        ]);
        List<Id> prods = new List<Id>();
        for(PAC__c pac: pacs){
            if(!prods.contains(pac.Assigned_Product2__c)){
                prods.add(pac.Assigned_Product2__c);
            }
        }
        List<zqu__ProductRatePlanCharge__c> uomObjects = [
                SELECT UOM_Without_Unit_Quantity__c, zqu__ProductRatePlan__r.zqu__Product__c
                FROM zqu__ProductRatePlanCharge__c
                WHERE zqu__ProductRatePlan__r.zqu__Product__c IN :prods
        ];
        UOMs = new Map<Id, String>();
        for(zqu__ProductRatePlanCharge__c prpc: uomObjects){
            UOMs.put(prpc.zqu__ProductRatePlan__r.zqu__Product__c, prpc.UOM_Without_Unit_Quantity__c);
        }
    }}
    public List<PAC__c> pacs {get;set;}
    public Map<Id, String> UOMs {get; set;}
    public Boolean renderPACs {
        get {
            System.debug('getter');
            return (!pacs.isEmpty() && quoteId != null);
        }
        set;
    }
}