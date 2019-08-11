@isTest
public class PS_TaskOwnerUpdateTC {
    @isTest
    static void TC1(){
        TestDataUtil.dataValueMapCSData();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Type = 'Customer';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Email = 'Test@123.com';
        con.AccountId = (acc !=null ? acc.Id : null);
        con.MailingCountry='India';
        insert con;
        
        Case caseObj = new Case(
            ContactId = con.ID,
            AccountId = acc.Id,
            Status = 'Working',
            Origin = 'Phone');
        
        insert caseObj;
        //insert caseObj;
        

        List<Task> tasks = new List<Task>();
        tasks.add(new Task(ActivityDate = Date.today().addDays(7),Subject='Sample Task',WhatId = caseObj.Id,Task_Remains_with_Case__c=true,OwnerId = UserInfo.getUserId(),Status='In Progress'));
        
        insert tasks;
        tasks[0].Subject='Testing Error';
        update tasks;
        
    }
}