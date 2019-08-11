public with sharing class RoleHelper {
    public static final String STATUS_ROLE_MAPPING_ACTIVE   = 'Active';
    public static final String STATUS_ROLE_MAPPING_INACTIVE = 'Inactive';

    public static List<Role_Instance__c> findRoleInstancesByQRPCId(Id qrpcId) {
        return [
                SELECT id, Name, Total_Hours__c, Role_Quantity__c, Hours_Per_Role__c, Hourly_rate__c, List_Price__c
                FROM Role_Instance__c
                WHERE Quote_Rate_Plan_Charge__c = :qrpcId
        ];
    }

    public static Set<String> findRoleNamesAssignedToQRPCId(Id qrpcId) {
        Set<String> roleNames = new Set<String>();
        for (Role_Instance__c instance : findRoleInstancesByQRPCId(qrpcId)) {
            roleNames.add(instance.Name);
        }
        return roleNames;
    }

    public static List<Role__c> findAllRoles() {
        return [SELECT Name, Hourly_Rate__c, CreatedDate, CreatedBy.Name FROM Role__c];
    }

    public static List<Role__c> findRolesAssignableToCustomQRPC(Id qrpcId) {
        Set<String> assignedRoleNames = findRoleNamesAssignedToQRPCId(qrpcId);
        String currencyCode = getCurrency(qrpcId);
        return [
                SELECT Name, Hourly_Rate__c, CreatedDate, CreatedBy.Name, CurrencyIsoCode
                FROM Role__c
                WHERE Name NOT IN :assignedRoleNames
                AND CurrencyIsoCode = :currencyCode
        ];
    }

    public static Boolean isAddingRoleAvailable(zqu__QuoteRatePlanCharge__c quoteRatePlanCharge) {
        return true;
//        return quoteRatePlanCharge.Name.containsIgnoreCase('custom');
//                String.isBlank(quoteRatePlanCharge.Listed_Price__c) ||
//                Decimal.valueOf(quoteRatePlanCharge.Listed_Price__c) == 0;
    }

    private static String getCurrency(Id qrpcId) {
        zqu__QuoteRatePlanCharge__c qrpc = [
                SELECT Id, zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Currency__c
                FROM zqu__QuoteRatePlanCharge__c
                WHERE Id = :qrpcId
        ];
        return qrpc.zqu__QuoteRatePlan__r.zqu__Quote__r.zqu__Currency__c;
    }
}