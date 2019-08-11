/*
/*******************************************************************************************************************
* Apex Class Name  : PS_SubscriptionProductChargeHandler_TC
* Version          : 1.0
* Created Date     : 28 Oct 2017
* Function         : Class is used test PS_SubscriptionProductChargeHandler - Entitlement create/update
* Modification Log : 
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Deepa Lakamanhalli            28/10/2017            Test Class to test PS_SubscriptionProductChargeHandler
* ------------------------------------------------------------------------------------------------------------------
********************************************************************************************************************
*/
@isTest
public class PS_SubscriptionProductChargeHandler_TC{
    public testmethod static void entitlementCreateTest(){
        TestDataUtil.dataValueMapCSData();
        Account acc = TestDataUtil.createAccount();
        Zuora__Product__c prdt = TestDataUtil.createSubscriptionProduct();
        ProductEntitlementMap__c pMap = TestDataUtil.createProductEntitlement();
        Zuora__SubscriptionProductCharge__c subsPrdt = TestDataUtil.createSubscriptionProductCharge(acc.Id, prdt.Id);  
        List<Entitlement> entCreated = [Select Id from Entitlement where AccountId =: acc.Id];  
        System.assert(entCreated.size()>0,'Entitlement not created');   
        subsPrdt.End_Date__c ='2027-01-12';
        update subsPrdt;
        delete subsPrdt;
     
        
    }
}