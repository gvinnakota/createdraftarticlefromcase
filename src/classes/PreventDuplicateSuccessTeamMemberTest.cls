@isTest
private class PreventDuplicateSuccessTeamMemberTest {
      @isTest
      private static void testSwitchAffectedSalesforceUser() {
    
        Account acc = new Account();
        acc.Name ='Test';
    
        Success_Team__c successTeam = new Success_Team__c();
        
        successTeam.User__c = UserInfo.getUserId();
        successTeam.Role__c ='New Case Notification';
    
        Test.startTest();
        insert acc;
        successTeam.Account__c=acc.Id;
        insert successTeam;
    
        Test.stopTest();
    
        
        list<Success_Team__c> newsuccessTeam = [SELECT Id, User__c, Role__c FROM Success_Team__c WHERE User__c = :UserInfo.getUserId() AND Account__c = :acc.Id];
        
        System.assertEquals(1,newsuccessTeam.size());
     }
}