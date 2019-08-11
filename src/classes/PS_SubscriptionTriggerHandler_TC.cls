/*
/*******************************************************************************************************************
* Apex Class Name  : PS_SubscriptionTriggerHandler_TC
* Version          : 1.0
* Created Date     : 28 Oct 2017
* Function         : Class is used test PS_SubscriptionTriggerHandler - Subscription create/update
* Modification Log : 
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Deepa Lakamanhalli            28/10/2017            Test Class to test PS_SubscriptionTriggerHandler
* ------------------------------------------------------------------------------------------------------------------
********************************************************************************************************************
*/
@isTest
public class PS_SubscriptionTriggerHandler_TC{
    public testmethod static void subscriptionActiveTest(){
        TestDataUtil.dataValueMapCSData();
        Account acc = TestDataUtil.createAccount();
        
        Entitlement e = TestDataUtil.createEntitlement(acc.Id);
        
        Zuora__Subscription__c subs = TestDataUtil.createSubscriptions(acc.Id);
        system.assert(subs.Id!=Null , 'Subscription fail');
        e.Subscription__c = subs.Id;
        e.StartDate = System.today()+1;
        e.EndDate = System.today()+1;
        update e;
        
        subs.Zuora__Status__c ='Active';
        update subs;
        
        e.StartDate = System.today();
        e.EndDate = System.today()+1;
        update e;
        subs.Zuora__Status__c ='Cancelled';
        update subs;
    
    }
    
     public testmethod static void subscriptionActiveTest1(){
        TestDataUtil.dataValueMapCSData();
        Account acc = TestDataUtil.createAccount();
        
        Entitlement e = TestDataUtil.createEntitlement(acc.Id);
        
        Zuora__Subscription__c subs = TestDataUtil.createSubscriptions(acc.Id);
        system.assert(subs.Id!=Null , 'Subscription fail');
        e.Subscription__c = subs.Id;
        e.StartDate = System.today()+1;
        e.EndDate = System.today()+1;
        update e;
        
        subs.Zuora__Status__c ='Active';
        update subs;
        
        e.StartDate = System.today()-1;
        e.EndDate = System.today();
        update e;
        subs.Zuora__Status__c ='Cancelled';
        update subs;
        
        subs.Zuora__Status__c= 'Active';
        e.StartDate = System.today()-2;
        e.EndDate = System.today()-1;
        update e;
    
    }
         public testmethod static void subscriptionActiveTest2(){
        TestDataUtil.dataValueMapCSData();
        Account acc = TestDataUtil.createAccount();
        
        Entitlement e = TestDataUtil.createEntitlement(acc.Id);
        
        Zuora__Subscription__c subs = TestDataUtil.createSubscriptions(acc.Id);
        List<Zuora__Subscription__c> lstSub = new List<Zuora__Subscription__c>();
        lstSub.add(subs);
        system.assert(subs.Id!=Null , 'Subscription fail');
        e.Subscription__c = subs.Id;
        e.StartDate = System.today()+1;
        e.EndDate = System.today()+1;
        update e;
        PS_SubscriptionTriggerHandler.activeEntitlement(lstSub);
    
    }
    
    
}