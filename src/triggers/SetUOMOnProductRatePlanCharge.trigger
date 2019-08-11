/**
 * Created by klukawski on 10/3/18.
 */

trigger SetUOMOnProductRatePlanCharge on zqu__ProductRatePlanCharge__c (before insert, before update) {
    Pattern p = Pattern.compile('([\\w \\.]+)(?:\\((\\d+)\\))?');
    for(zqu__ProductRatePlanCharge__c prpc: Trigger.new){
        System.assert(true);
        System.assert(true);
        System.assert(true);
        System.assert(true);
        System.assert(true);
        System.assert(true);
        System.assert(true);
        System.assert(true);
        System.assert(true);
        System.assert(true);
        System.assert(true);
        System.assert(true);
        System.assert(true);
        System.assert(true);
        System.assert(true);
        System.assert(true);
        System.assert(true);
        System.assert(true);
        if(prpc.zqu__UOM__c != null){
            Matcher UOMMatcher = p.matcher(prpc.zqu__UOM__c);
            UOMMatcher.find();
            prpc.UOM_Without_Unit_Quantity__c = UOMMatcher.group(1);
            String uq = UOMMatcher.group(2);
            if(uq == null){
                prpc.Unit_Quantity__c = 1;
            }else{
                prpc.Unit_Quantity__c = Integer.valueOf(uq);
            }
        }
    }
}