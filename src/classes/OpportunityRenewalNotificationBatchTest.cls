@isTest
public class OpportunityRenewalNotificationBatchTest {
    @testSetup
    static void testSetupData(){
    
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Type = 'Customer';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'Washington';
        insert acc;
        
      
    
    
        Opportunity parentOpp = new Opportunity();
        parentOpp.Name ='Parent';
        parentOpp.StageName = 'Value Proposition';
        parentOpp.Type  = 'New Subscription';
        parentOpp.CloseDate = System.today()+120;
        parentOpp.AccountId = acc.Id;
        
        insert parentOpp;
        
        List<Opportunity> oppLst = new List<Opportunity>();
        for(integer i=0;i<5;i++){
        Opportunity opp = new Opportunity();
        opp.Name = 'Test-'+i;
        opp.StageName = 'Value Proposition';
        opp.Type  = 'Renew Subscription';
        opp.Previous_Term_Opportunity__c = parentOpp.id;
        opp.CloseDate = System.today()+120;
        Opp.AccountId = acc.Id;
        
        oppLst.add(opp);
        }
        insert oppLst;
    }
    private static testmethod void testoppRenewalNotBatch(){
        Test.startTest();
        OpportunityRenewalNotificationBatch oppBatchObj = new OpportunityRenewalNotificationBatch();
        Database.executeBatch(oppBatchObj);
        Test.stopTest();
    }
}