/*******************************************************************************************************************
* Apex Class Name  : PS_EntitlementTriggerHandler_TC
* Version          : 1.0
* Created Date     : 28 Oct 2017
* Function         : Class is used test  PS_EntitlementTriggerHandler - Entitlement create /update
* Modification Log : 
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Deepa Lakamanhalli            28/10/2017            Test Class to test  PS_EntitlementTriggerHandler
* ------------------------------------------------------------------------------------------------------------------
********************************************************************************************************************
*/
@isTest
Private Class PS_EntitlementTriggerHandler_TC{
    private testmethod static void casecountTestMethod(){
        TestDataUtil.dataValueMapCSData(); 
        Contact con = TestDataUtil.createContact();
        System.assert(con.Id != null);
        Entitlement ent1 = TestDataUtil.createEntitlement(con.AccountId);
        ent1.Support_Exception__c = true;
        update ent1;
        
        case cObj = TestDataUtil.createTechnicalCase();
        System.assert(cObj.EntitlementId!=null);
        case cObj1 = TestDataUtil.createTechnicalCase();
        cObj1.AccountId = cObj.AccountId;
        cObj1.EntitlementId = cObj.EntitlementId;        
        cObj1.Resolution_Code__c ='Not Entitled';
        Test.startTest();
        update cObj1;
        cObj1.Case_Type__c ='Escalation';
        cObj1.Related_KB_Article__c = 'KB needed';
        cObj1.Resolution__c = 'resolution';
        cObj1.Resolution_Opportunity_Root_Cause__c = 'Customer Education';
        cObj1.Steps_to_Resolve__c = 'Downgrade';
        cObj1.Status ='Solved';
        update cObj1;
        Test.stopTest();
       
        entitlement ent = new entitlement();
        ent.Id = cObj.EntitlementId;
        ent.Support_Exception__c = true;
        ent.AccountId = cObj.AccountId;     
        update ent;
        
        ent.Support_Exception__c = false;
        update ent;
  
    }
    
    private testmethod static void casecountGranted(){
        TestDataUtil.dataValueMapCSData(); 
        Contact con = TestDataUtil.createContact();
        System.assert(con.Id != null);
        Entitlement ent1 = TestDataUtil.createEntitlement(con.AccountId);
        ent1.Support_Exception__c = true;
        update ent1;
        
        case cObj = TestDataUtil.createTechnicalCase();
        System.assert(cObj.EntitlementId!=null);
        case cObj1 = TestDataUtil.createTechnicalCase();
        cObj1.AccountId = cObj.AccountId;
        cObj1.EntitlementId = cObj.EntitlementId;        
        cObj1.Resolution_Code__c ='ISV';
        Test.startTest(); 
        update cObj1;
        cObj1.Case_Type__c ='Escalation';
        cObj1.Related_KB_Article__c = 'KB needed';
        cObj1.Resolution__c = 'resolution';
        cObj1.Resolution_Opportunity_Root_Cause__c = 'Customer Education';
        cObj1.Steps_to_Resolve__c = 'Downgrade';
        cObj1.Status ='Solved';
        update cObj1;
        Test.stopTest(); 
       
        entitlement ent = new entitlement();
        ent.Id = cObj.EntitlementId;
        ent.Support_Exception__c = true;
        ent.AccountId = cObj.AccountId;     
        update ent;
        
        ent.Support_Exception__c = false;
        update ent;
  
    }
    
        static testMethod  void  countUpdate(){
        TestDataUtil.dataValueMapCSData(); 
        Contact conRecord = TestDataUtil.createContact(); 
        System.assert(conRecord.Id != null);      
        Account accRecord = TestDataUtil.createAccount();
        Entitlement ent1 = TestDataUtil.createEntitlement(accRecord.Id);
        ent1.Support_Exception__c = true;
        update ent1;
        
        case cObj = new case();
        cObj.Subject = 'Ignore Test Case';
        cObj.Description ='Ignore Test Case creation via Test Class';
        cObj.ContactId = conRecord.Id;
        cObj.AccountId = accRecord.Id;
        cObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        cObj.EntitlementId = ent1.Id;
        cObj.Products__c='Alpine Chorus for Pivotal Data Suite';
        cObj.Priority='Severity 1 - Critical'; 
        cObj.Resolution_Code__c='ISV';
        cObj.Case_Type__c ='Escalation';
        cObj.Related_KB_Article__c = 'KB needed';
        cObj.Resolution__c = 'resolution';
        cObj.Resolution_Opportunity_Root_Cause__c = 'Customer Education';
        cObj.Steps_to_Resolve__c = 'Downgrade';
        cObj.Status='Solved';
        insert cObj;
        System.assert(cObj.Id !=null , 'Failed to create Technical Case'); 
        
               
            }
       
    
}