public with sharing class PACHelper {

    public static List<PAC__c> findPacByKeys(Set<String> uniqueKeys) {
        return [
                SELECT Key__c
                FROM PAC__c
                WHERE Key__c IN :uniqueKeys
        ];
    }

//    public static List<PAC__c> findPacByQuoteId(Id quoteId) {
//        return [
//                SELECT Quote__c, Assignment_Date__c, Status__c
//                FROM PAC__c
//                WHERE Quote__c = :quoteId
//        ];
//    }

    public static Set<String> findPacKeysByKeys(Set<String> uniqueKeys) {
        Set<String> existingKeys = new Set<String>();
        for (PAC__c pac : findPacByKeys(uniqueKeys)) {
            existingKeys.add(pac.Key__c.toUpperCase());
        }
        return existingKeys;
    }

//    public static List<PAC_Product_Map__c> findPacProductMap(Set<String> products) {
//        return [
//                SELECT PAC_Product__c, ZProduct__c
//                FROM PAC_Product_Map__c
//                WHERE PAC_Product__c IN :products
//                AND Active__c = TRUE
//        ];
//    }

//    public static Map<String, PAC_Product_Map__c> getProduct2ProductMap(Set<String> products) {
//        Map<String, PAC_Product_Map__c> resultMap = new Map<String, PAC_Product_Map__c>();
//        for (PAC_Product_Map__c mapEntry : findPacProductMap(products)) {
//            resultMap.put(mapEntry.PAC_Product__c, mapEntry);
//        }
//        return resultMap;
//    }

    /*public static List<PAC__c> findAvailableToAllocateByProduct(Set<String> products) {
        return [
                SELECT Quantity__c, Duration__c, Product__c
                FROM PAC__c
                WHERE Status__c = 'Unassigned'
                AND Product__c IN :products
                ORDER BY Quantity__c DESC, Duration__c DESC
        ];
    }*/

    public static List<PAC__c> findAvailableToAllocate() {
        return [
                SELECT Quantity__c, Duration__c, Product__c
                FROM PAC__c
                WHERE Status__c = 'Unassigned'
                ORDER BY Quantity__c DESC, Duration__c DESC
        ];
    }

    public static String getPACGroupingFieldValue(PAC__c pac){
        return pac.Quantity__c + '_' + pac.Duration__c;
    }

    public class PACWrapper {
        public PAC__c pac {get; private set;}
        public Boolean duplicate {get; set;}

        public PACWrapper(PAC__c pac, Boolean duplicate) {
            this.pac = pac;
            this.duplicate = duplicate;
        }
    }
}