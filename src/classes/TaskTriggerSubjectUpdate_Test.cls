@isTest
private class TaskTriggerSubjectUpdate_Test {

    /* Test Methods */
    static testMethod void test_TaskType_for_ISR() {
         List<Profile> lstProfile = TestDataUtil.getProfiles();
        
         List<DataValueMap__c>  csDataList =  new List<DataValueMap__c>();
        csDataList.add(new DataValueMap__c(Name = 'PortalManagerProfileId', Data_Value__c = lstProfile[0].Id));
        csDataList.add(new DataValueMap__c(Name = 'PortalUserProfileId', Data_Value__c = lstProfile[1].Id)); 
        csDataList.add(new DataValueMap__c(Name = 'ErrorOnCloseCaseUpdate', Data_Value__c = 'You can not modify closed case.'));
        csDataList.add(new DataValueMap__c(Name = 'customerCaseStatus', Data_Value__c = 'Closed,Solved,In Progress'));
        csDataList.add(new DataValueMap__c(Name = 'Expired', Data_Value__c = 'Expired'));
        csDataList.add(new DataValueMap__c(Name = 'Active', Data_Value__c = 'active'));
        csDataList.add(new DataValueMap__c(Name = 'ArticleTypes', Data_Value__c = 'a42'));
        csDataList.add(new DataValueMap__c(Name = 'bypassModifyClosedCase', Data_Value__c = 'TRUE'));
        csDataList.add(new DataValueMap__c(Name = 'EHSP support', Data_Value__c = 'ehsp.scqa@pivotal.io'));
        csDataList.add(new DataValueMap__c(Name = 'EHSP Escalations', Data_Value__c = 'ehsp-escalations.scqa@pivotal.io'));
        csDataList.add(new DataValueMap__c(Name = 'OnDemandaccountAlias', Data_Value__c = 'ondemand-support.scqa@pivotal.io')); 
        csDataList.add(new DataValueMap__c(Name='Embargo_Countries',Data_Value__c=';Iran;Cuba;North Korea;Sudan;Syria;'));
        csDataList.add(new DataValueMap__c(Name='RPS_Status',Data_Value__c=';Triple Red;Double Red;Red;Risk Country;Yellow;'));
        csDataList.add(new DataValueMap__c(Name='PortalRegisteredUserId',Data_Value__c='00eW0000000I1OOIA0'));
        
       
        csDataList.add(new DataValueMap__c(Name='PivotalSupportProfile',Data_Value__c='00eW0000000I1OmIAK'));
        csDataList.add(new DataValueMap__c(Name='Internal comments for R&D and PKS',Data_Value__c=';00eW0000000M6s9IAC;00eW0000000M7iPIAS;'));
        csDataList.add(new DataValueMap__c(Name='Closed',Data_Value__c='Closed'));
        csDataList.add(new DataValueMap__c(Name='Visibility',Data_Value__c='AllUsers'));
        csDataList.add(new DataValueMap__c(Name='Not Entitled',Data_Value__c='Not Entitled'));
        csDataList.add(new DataValueMap__c(Name='Type',Data_Value__c='TextPost'));
        csDataList.add(new DataValueMap__c(Name='QuestionPost',Data_Value__c='QuestionPost'));
        csDataList.add(new DataValueMap__c(Name='ArticleTypeNames',Data_Value__c='KnowledgeArticle__ka,Break_Fix_ka,Tools__ka,Troubleshooting_Guide__ka,Concept__ka,How_To__ka, Checklist__ka,'));
        csDataList.add(new DataValueMap__c(Name='Pivotal - AccountShare Access',Data_Value__c='0PSf0000000DNtBGAW'));
        insert csDataList;
        runTest('Message Sent: Demo for PCF', true);
    }

    static testMethod void test_TaskType_for_user() {
         List<Profile> lstProfile = TestDataUtil.getProfiles();
        
         List<DataValueMap__c>  csDataList =  new List<DataValueMap__c>();
        csDataList.add(new DataValueMap__c(Name = 'PortalManagerProfileId', Data_Value__c = lstProfile[0].Id));
        csDataList.add(new DataValueMap__c(Name = 'PortalUserProfileId', Data_Value__c = lstProfile[1].Id)); 
        csDataList.add(new DataValueMap__c(Name = 'ErrorOnCloseCaseUpdate', Data_Value__c = 'You can not modify closed case.'));
        csDataList.add(new DataValueMap__c(Name = 'customerCaseStatus', Data_Value__c = 'Closed,Solved,In Progress'));
        csDataList.add(new DataValueMap__c(Name = 'Expired', Data_Value__c = 'Expired'));
        csDataList.add(new DataValueMap__c(Name = 'Active', Data_Value__c = 'active'));
        csDataList.add(new DataValueMap__c(Name = 'ArticleTypes', Data_Value__c = 'a42'));
        csDataList.add(new DataValueMap__c(Name = 'bypassModifyClosedCase', Data_Value__c = 'TRUE'));
        csDataList.add(new DataValueMap__c(Name = 'EHSP support', Data_Value__c = 'ehsp.scqa@pivotal.io'));
        csDataList.add(new DataValueMap__c(Name = 'EHSP Escalations', Data_Value__c = 'ehsp-escalations.scqa@pivotal.io'));
        csDataList.add(new DataValueMap__c(Name = 'OnDemandaccountAlias', Data_Value__c = 'ondemand-support.scqa@pivotal.io')); 
        csDataList.add(new DataValueMap__c(Name='Embargo_Countries',Data_Value__c=';Iran;Cuba;North Korea;Sudan;Syria;'));
        csDataList.add(new DataValueMap__c(Name='RPS_Status',Data_Value__c=';Triple Red;Double Red;Red;Risk Country;Yellow;'));
        csDataList.add(new DataValueMap__c(Name='PortalRegisteredUserId',Data_Value__c='00eW0000000I1OOIA0'));
        
       
        csDataList.add(new DataValueMap__c(Name='PivotalSupportProfile',Data_Value__c='00eW0000000I1OmIAK'));
        csDataList.add(new DataValueMap__c(Name='Internal comments for R&D and PKS',Data_Value__c=';00eW0000000M6s9IAC;00eW0000000M7iPIAS;'));
        csDataList.add(new DataValueMap__c(Name='Closed',Data_Value__c='Closed'));
        csDataList.add(new DataValueMap__c(Name='Visibility',Data_Value__c='AllUsers'));
        csDataList.add(new DataValueMap__c(Name='Not Entitled',Data_Value__c='Not Entitled'));
        csDataList.add(new DataValueMap__c(Name='Type',Data_Value__c='TextPost'));
        csDataList.add(new DataValueMap__c(Name='QuestionPost',Data_Value__c='QuestionPost'));
        csDataList.add(new DataValueMap__c(Name='ArticleTypeNames',Data_Value__c='KnowledgeArticle__ka,Break_Fix_ka,Tools__ka,Troubleshooting_Guide__ka,Concept__ka,How_To__ka, Checklist__ka,'));
        csDataList.add(new DataValueMap__c(Name='Pivotal - AccountShare Access',Data_Value__c='0PSf0000000DNtBGAW'));
        insert csDataList;
        runTest('Reply: Email Sent by Customer', false);
    }
    static testMethod void test_LeadStatus_for_ISR() {
         List<Profile> lstProfile = TestDataUtil.getProfiles();
        
         List<DataValueMap__c>  csDataList =  new List<DataValueMap__c>();
        csDataList.add(new DataValueMap__c(Name = 'PortalManagerProfileId', Data_Value__c = lstProfile[0].Id));
        csDataList.add(new DataValueMap__c(Name = 'PortalUserProfileId', Data_Value__c = lstProfile[1].Id)); 
        csDataList.add(new DataValueMap__c(Name = 'ErrorOnCloseCaseUpdate', Data_Value__c = 'You can not modify closed case.'));
        csDataList.add(new DataValueMap__c(Name = 'customerCaseStatus', Data_Value__c = 'Closed,Solved,In Progress'));
        csDataList.add(new DataValueMap__c(Name = 'Expired', Data_Value__c = 'Expired'));
        csDataList.add(new DataValueMap__c(Name = 'Active', Data_Value__c = 'active'));
        csDataList.add(new DataValueMap__c(Name = 'ArticleTypes', Data_Value__c = 'a42'));
        csDataList.add(new DataValueMap__c(Name = 'bypassModifyClosedCase', Data_Value__c = 'TRUE'));
        csDataList.add(new DataValueMap__c(Name = 'EHSP support', Data_Value__c = 'ehsp.scqa@pivotal.io'));
        csDataList.add(new DataValueMap__c(Name = 'EHSP Escalations', Data_Value__c = 'ehsp-escalations.scqa@pivotal.io'));
        csDataList.add(new DataValueMap__c(Name = 'OnDemandaccountAlias', Data_Value__c = 'ondemand-support.scqa@pivotal.io')); 
        csDataList.add(new DataValueMap__c(Name='Embargo_Countries',Data_Value__c=';Iran;Cuba;North Korea;Sudan;Syria;'));
        csDataList.add(new DataValueMap__c(Name='RPS_Status',Data_Value__c=';Triple Red;Double Red;Red;Risk Country;Yellow;'));
        csDataList.add(new DataValueMap__c(Name='PortalRegisteredUserId',Data_Value__c='00eW0000000I1OOIA0'));
        
       
        csDataList.add(new DataValueMap__c(Name='PivotalSupportProfile',Data_Value__c='00eW0000000I1OmIAK'));
        csDataList.add(new DataValueMap__c(Name='Internal comments for R&D and PKS',Data_Value__c=';00eW0000000M6s9IAC;00eW0000000M7iPIAS;'));
        csDataList.add(new DataValueMap__c(Name='Closed',Data_Value__c='Closed'));
        csDataList.add(new DataValueMap__c(Name='Visibility',Data_Value__c='AllUsers'));
        csDataList.add(new DataValueMap__c(Name='Not Entitled',Data_Value__c='Not Entitled'));
        csDataList.add(new DataValueMap__c(Name='Type',Data_Value__c='TextPost'));
        csDataList.add(new DataValueMap__c(Name='QuestionPost',Data_Value__c='QuestionPost'));
        csDataList.add(new DataValueMap__c(Name='ArticleTypeNames',Data_Value__c='KnowledgeArticle__ka,Break_Fix_ka,Tools__ka,Troubleshooting_Guide__ka,Concept__ka,How_To__ka, Checklist__ka,'));
        csDataList.add(new DataValueMap__c(Name='Pivotal - AccountShare Access',Data_Value__c='0PSf0000000DNtBGAW'));
        insert csDataList;
        runTest_for_LeadStatusUpdate('Message Sent: Demo for PCF', true);
    }

    /* Test Body */
    public static void runTest(String subjectStr, Boolean isSent) {
        Lead leadObj = TestDataFactory.createLead(true);
        Task taskObj = TestDataFactory.createTask(leadObj.Id, false);

        Profile p = TestDataFactory.createProfile('Pivotal - Sales Rep');
        User u = TestDataFactory.createUser(p.Id, true);
        UserRole userRoleObj = TestDataFactory.createUserRole('AMER - ISR Regional Director');

        Test.startTest();
        TestDataFactory.assignUserRole(u.Id, userRoleObj.Id);
        Test.stopTest();

        System.runAs(u) {
            taskObj.Subject = subjectStr;
            insert taskObj;
        }

        /* Assert Statements */
        Task newTaskObj = [SELECT Id, Type FROM Task WHERE Id = :taskObj.id];
        if (isSent) {
            System.assertEquals('ISR-Email Sent', newTaskObj.Type, 'Task Object Type should be ISR-Email Sent, not ' + newTaskObj.Type);
        } else {
            System.assertEquals('ISR-Email Response Received', newTaskObj.Type, 'Task Object Type should be ISR-Email Response Received, not ' + newTaskObj.Type);
        }
    }
    public static void runTest_for_LeadStatusUpdate(String subjectStr, Boolean isSent) {

        Lead leadObj = new Lead();
        Task taskObj = new Task();

        Profile p = TestDataFactory.createProfile('Pivotal - Sales Rep');
        User u = TestDataFactory.createUser(p.Id, true);
        UserRole userRoleObj = TestDataFactory.createUserRole('AMER - ISR Regional Director');

        Test.startTest();
        TestDataFactory.assignUserRole(u.Id, userRoleObj.Id);
        Test.stopTest();

        System.runAs(u) {
            leadObj = TestDataFactory.createLead(true);
            taskObj = TestDataFactory.createTask(leadObj.Id, false);
            taskObj.Subject = subjectStr;
            insert taskObj;
        }

        /* Assert Statements */
        Task newTaskObj = [SELECT Id, Type FROM Task WHERE Id = :taskObj.id];
        Lead newLeadObj = [Select Id,Status from Lead where Id = :leadObj.id];
        if (isSent) {
            System.assertEquals('ISR-Email Sent', newTaskObj.Type, 'Task Object Type should be ISR-Email Sent, not ' + newTaskObj.Type);
        } else {
            System.assertEquals('ISR-Email Response Received', newTaskObj.Type, 'Task Object Type should be ISR-Email Response Received, not ' + newTaskObj.Type);
        }
        System.assertEquals('Working', newLeadObj.Status, 'Lead Status not updated ' + newLeadObj.Status);

    }
}