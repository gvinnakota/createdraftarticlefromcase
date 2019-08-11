/*******************************************************************************************************************
* Apex Class Name  : PS_SubscriptionProductChargeHandler
* Test Class Name  : PS_SubscriptionProductChargeHandler_TC
* Version          : 1.0
* Created Date     : 01 August 2017
* Function         : class is used to create entitlement when SubscriptionProductCharge Sku Matches product SKU 
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Karthik.A.S               08/28/2017            intial version
* Rohan M Kolvekar          27/03/2018            Created Method to Update the Entitlement start date and End date whenever the SPC start date and end date is changed
* Sun                       01/18/2019            Added SOQL condition to filter out Inactive productions on product Entitlement Map object. 
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
public class PS_SubscriptionProductChargeHandler{
    
    //this method is used to create entitelment when SubscriptionProductCharge Sku Matches product SKU
    public static void Entitlementcreation(list<Zuora__SubscriptionProductCharge__c> subscriptionList){
        
        list<Entitlement>entitelementcreation= new list<Entitlement>();
        Set<String> skuSet = new Set<String>();
        for(Zuora__SubscriptionProductCharge__c sub :subscriptionList){
            skuSet.add(sub.Zuora__ProductSKU_Product__c);   
        }
        if(!skuSet.isEmpty()){
            Map<String,list<ProductEntitlementMap__c>> skuWithProductMap = new Map<String,list<ProductEntitlementMap__c>>();
            Set<string> entProcess = new Set<string>();
            for(ProductEntitlementMap__c prod :[select id,Name,Product_SKU__c,Entitlement_Process__c,SFDC_Product_Name__c, Inactive__c  from ProductEntitlementMap__c WHERE Product_SKU__c =: skuSet AND Inactive__c=FALSE]){
                
                system.debug('sun:Name: ' + prod.Name);
                system.debug('sun:Product_SKU__c: ' + prod.Product_SKU__c);
                system.debug('sun:Inactive__c: ' + prod.Inactive__c);
                
                if(!skuWithProductMap.containsKey(prod.Product_SKU__c)){
                    skuWithProductMap.put(prod.Product_SKU__c, new list<ProductEntitlementMap__c> {prod});
                }else{
                    skuWithProductMap.get(prod.Product_SKU__c).add(prod);
                }
                entProcess.add(prod.Entitlement_Process__c);
            }
            Map<String,String> slaMap = new Map<String,String>();
            for(SlaProcess slaProc : [SELECT Id ,Name,IsActive From SlaProcess Where Name=: entProcess and IsActive = true]){
                slaMap.put(slaProc.Name,slaProc.Id);
            }
            
            for(Zuora__SubscriptionProductCharge__c sub : subscriptionList){
                if(sub.Zuora__ProductSKU_Product__c != null && !skuWithProductMap.isEMpty() &&skuWithProductMap.containsKey(sub.Zuora__ProductSKU_Product__c)){
                    for(ProductEntitlementMap__c prod : skuWithProductMap.get(sub.Zuora__ProductSKU_Product__c)){
                        Entitlement ent= new Entitlement();
                        ent.Name = prod.Name;
                        if(!slaMap.isEmpty() && slaMap.containsKey(prod.Entitlement_Process__c)){
                            ent.slaprocessid = slaMap.get(prod.Entitlement_Process__c);
                            ent.Name = prod.SFDC_Product_Name__c +' - '+prod.Entitlement_Process__c;
                        }                       
                        // ent.startdate=date.newinstance(sub.createddate.year(), sub.createddate.month(), sub.createddate.day());
                        //ent.Enddate=date.newinstance(sub.createddate.year(), sub.createddate.month(), sub.createddate.day())+365;
                        ent.startdate = Date.valueOf(sub.Start_Date__c);
                        ent.Enddate = Date.valueOf(sub.End_Date__c);
                        ent.accountid=sub.Zuora__Account__c; 
                        ent.Subscription__c=sub.Zuora__Subscription__c;
                        //ent.Products__c=sub.Zuora__Product__c;
                        ent.ProductEntitlementMap__c = prod.Id;
                        ent.Subscription_Product_Charge__c = sub.id;
                        ent.Product_Descriptions__c=sub.Zuora__Description__c;
                        entitelementcreation.add(ent);                      
                    }
                }
            }
            if(!entitelementcreation.isempty()){
                try{
                    insert entitelementcreation;
                }
                catch(Exception e){
                    ErrorLog.CreateER(e);// Catches Exception in Utility Class ErrorLog
                }
            }
        }
    }
    // WR #2259,#2260,#2261,#2262 Starts
    // Method to Update the Entitlement start date and End date whenever the SPC start date and end date is changed 
    public static void Entitlementupdation(list<Zuora__SubscriptionProductCharge__c> subscriptionList){
        
        Set<String> subscriptionProductChargeIdSet = new Set<String>();
        list<Entitlement>entitelementupdate= new list<Entitlement>();
        String Expired = DataValueMap__c.getInstance('Expired').Data_Value__c;
        for(Zuora__SubscriptionProductCharge__c sub :subscriptionList){
            subscriptionProductChargeIdSet.add(sub.Id);   
        }
        
        list<Entitlement>lstent=[select id, StartDate,EndDate,Product_SKU__c,Status from Entitlement where Subscription_Product_Charge__c in:subscriptionProductChargeIdSet AND ProductEntitlementMap__r.Inactive__c=FALSE];
        
        if(!lstent.isempty()){
            for(Zuora__SubscriptionProductCharge__c SubcriptionProduct :subscriptionList){
                for(Entitlement ent:lstent){
                    if(Trigger.isUpdate && Trigger.isAfter)
                    {
                        ent.startdate=Date.valueOf(SubcriptionProduct.Start_Date__c);
                        ent.enddate=Date.valueOf(SubcriptionProduct.End_Date__c);
                        entitelementupdate.add(ent);
                    }   
                    if(Trigger.isDelete)
                    {
                        if(ent.Status !=Expired)
                        {
                            ent.startdate=system.today()-2;
                            ent.enddate=system.today()-1;    
                            entitelementupdate.add(ent);
                        }
                    }
                    
                }
            }
        }
        if(!entitelementupdate.isempty()){
            
            try{
                update entitelementupdate;
            }
            catch(Exception e){
                ErrorLog.CreateER(e);// Catches Exception in Utility Class ErrorLog
            }
        }       
        
        
    }
    //WR #2259,#2260,#2261,#2262 Ends   
}