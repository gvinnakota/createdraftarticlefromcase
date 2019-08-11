public with sharing class PACKeyAllocator {
    class ChargeWrapper implements Comparable{
        protected zqu__QuoteRatePlanCharge__c charge;

        public ChargeWrapper(zqu__QuoteRatePlanCharge__c charge){
            this.charge = charge;
        }

        public Integer compareTo(Object param1) {
            zqu__QuoteRatePlanCharge__c other = ((ChargeWrapper)param1).charge;
            System.debug('This:');
            System.debug(this.charge.Start_Date__c);
            System.debug('Other:');
            System.debug(other.Start_Date__c);
            return Date.valueOf(other.Start_Date__c).daysBetween(Date.valueOf(this.charge.Start_Date__c));
        }
    }

    public static final List<PAC_Product_Map__c> productMaps = [
            SELECT PAC_Product__c, Product2__c
            FROM PAC_Product_Map__c
            WHERE Active__c = TRUE
    ];

    private Map<String, List<PAC__c>> availableToAllocate = new Map<String, List<PAC__c>>();

    public PACKeyAllocator(){
        for(PAC__c pac : PACHelper.findAvailableToAllocate()) {
            if(!availableToAllocate.containsKey(pac.Product__c)){
                availableToAllocate.put(pac.Product__c, new List<PAC__c>());
            }
            availableToAllocate.get(pac.Product__c).add(pac);
        }
    }

    public List<PAC__c> allocatePACKeys(zqu__Quote__c quote, List<zqu__QuoteRatePlanCharge__c> charges){
        Map<Id, String> pacProductsByProduct2Ids = new Map<Id, String>();
        for(PAC_Product_Map__c productMap: productMaps){
            pacProductsByProduct2Ids.put(productMap.Product2__c, productMap.PAC_Product__c);
        }

        List<PAC__c> available = new List<PAC__c>();
        for(zqu__QuoteRatePlanCharge__c charge: charges){
            String product = pacProductsByProduct2Ids.get(charge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c);
            if(availableToAllocate.containsKey(product)){
                available.addAll(availableToAllocate.get(product));
            }
        }
        /*
        Set<String> products = new Set<String>();

        for(zqu__QuoteRatePlanCharge__c charge: charges){
            products.add(pacProductsByProduct2Ids.get(charge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c));
        }

        List<PAC__c> available = PACHelper.findAvailableToAllocateByProduct(products);
*/


        List<PAC__c> toUpdate = new List<PAC__c>();
        List<PAC__c> toUpdateStep = new List<PAC__c>();

        Map<Id, List<ChargeWrapper>> chargesOverZproducts = new Map<Id, List<ChargeWrapper>>();

        for(zqu__QuoteRatePlanCharge__c charge: charges){
            if(!chargesOverZproducts.containsKey(charge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c)){
                chargesOverZproducts.put(charge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c, new List<ChargeWrapper>());
            }
            chargesOverZproducts.get(charge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__c).add(new ChargeWrapper(charge));
        }

        for(Id product: chargesOverZproducts.keySet()){
            chargesOverZproducts.get(product).sort();
        }

        Map<Id, Integer> maxQuantitiesOverZproducts = new Map<Id, Integer>();
        Map<Id, Integer> initialTermsOverZproducts = new Map<Id, Integer>();
        Map<Id, Date> startDatesOverZproducts = new Map<Id, Date>();
        System.debug('productids: ' + chargesOverZproducts.keySet());
        for(Id product: chargesOverZproducts.keySet()){
            List<ChargeWrapper> chargeWrappers = chargesOverZproducts.get(product);

            if (chargeWrappers.size() == 1){
                ChargeWrapper charge = chargeWrappers.get(0);
                System.debug('syf');
                System.debug(product);
                System.debug(charge.charge);
                System.debug(charge.charge.Total_Unit_Quantity__c);
                maxQuantitiesOverZproducts.put(product, charge.charge.Total_Unit_Quantity__c.intValue());
                initialTermsOverZproducts.put(product, charge.charge.Initial_Term__c.intValue());
                startDatesOverZproducts.put(product, Date.valueOf(charge.charge.Start_Date__c));
                continue;
            }

            List<zqu__QuoteRatePlanCharge__c> subtracted = new List<zqu__QuoteRatePlanCharge__c>();
            Integer maxQuantity = 0;
            Integer quantity = 0;
            Date firstChargeDate = Date.valueOf(chargeWrappers[0].charge.Start_Date__c);
            Date lastEndDate = firstChargeDate;

            for(Integer i=0;i<chargeWrappers.size();++i){
                Date currentStartDate = Date.valueOf(chargeWrappers[i].charge.Start_Date__c);
                Date currentEndDate = currentStartDate.addMonths(chargeWrappers[i].charge.Initial_Term__c.intValue());
                quantity += chargeWrappers[i].charge.Total_Unit_Quantity__c.intValue();
                if(lastEndDate.monthsBetween(currentEndDate)>0){
                    lastEndDate = currentEndDate;
                }
                for(Integer j = 0; j<i;++j){
                    zqu__QuoteRatePlanCharge__c previousCharge = chargeWrappers[j].charge;
                    if(Date.valueOf(previousCharge.Start_Date__c).addMonths(previousCharge.Initial_Term__c.intValue()).addDays(-1).daysBetween(currentStartDate)>0 && !subtracted.contains(previousCharge) /*&& charges.size()>1*/){
                        subtracted.add(previousCharge);
                        quantity -= previousCharge.Total_Unit_Quantity__c.intValue();
                    }
                }
                if(quantity>maxQuantity){
                    maxQuantity = quantity;
                }
            }
            startDatesOverZproducts.put(product, firstChargeDate);
            initialTermsOverZproducts.put(product, firstChargeDate.monthsBetween(lastEndDate));
            maxQuantitiesOverZproducts.put(product, maxQuantity);
        }
        System.debug('NEW CALC TEST:');
        System.debug(startDatesOverZproducts);
        System.debug(initialTermsOverZproducts);
        System.debug(maxQuantitiesOverZproducts);
        //Return here

        for(Id product: chargesOverZproducts.keySet()){
            Integer quantity = maxQuantitiesOverZproducts.get(product);
            System.debug('quantity: ' + quantity);
            for(PAC__c pac: available){
                if(pac.Quantity__c<=quantity
                        && pac.Product__c == pacProductsByProduct2Ids.get(product)
                        && ((pac.Duration__c == 1 && initialTermsOverZproducts.get(product) <= 12)
                            || pac.Duration__c == 3 && (initialTermsOverZproducts.get(product) > 12))){
                    pac.Status__c = 'Allocated';
                    pac.Quote__c = quote.Id;
                    pac.Allocation_Date__c = Datetime.now();
                    pac.Subscription_Period_Start_Date__c = startDatesOverZproducts.get(product);
                    pac.Subscription_Period_End_Date__c = pac.Subscription_Period_Start_Date__c.addMonths(initialTermsOverZproducts.get(product)).addDays(-1);
                    pac.Assigned_Product2__c = product;
                    toUpdateStep.add(pac);
                    quantity -= pac.Quantity__c.intValue();
                }
            }
            for(PAC__c pac: toUpdateStep){
                available.remove(available.indexOf(pac));
                List<PAC__c> pacList = availableToAllocate.get(pacProductsByProduct2Ids.get(product));
                pacList.remove(pacList.indexOf(pac));
            }
            toUpdate.addAll(toUpdateStep);
            toUpdateStep.clear();
            System.debug(quantity);
            System.debug(toUpdate);
            if(quantity != 0){
                return null;
            }

        }
        if(quote.zqu__Status__c == 'Sent to Z-Billing'){
            for(PAC__c pac: toUpdate){
                pac.Status__c = 'Assigned';
                pac.Assignment_Date__c = Datetime.now();
            }
        }
        return toUpdate;
    }

    public static void unallocatePACKeys(List<PAC__c> pacs){
        List<PAC__c> toUpdate = new List<PAC__c>();
        for(PAC__c pac: pacs){
            pac.Quote__c = null;
            pac.Allocation_Date__c = null;
            pac.Subscription_Period_Start_Date__c = null;
            pac.Subscription_Period_End_Date__c = null;
            pac.Assigned_Product2__c = null;
            pac.Status__c = 'Unassigned';
            pac.Assignment_Date__c = null;
            toUpdate.add(pac);
        }
        update toUpdate;
    }
}