@isTest
public class PS_EmailMessageTriggerHandler_Test {
   //static TestDataUtil utilObj = new TestDataUtil();
    
    static testMethod void createEmailMessage(){
         TestDataUtil.dataValueMapCSData(); 
         Case cObj = TestDataUtil.createNonTechnicalCase();
         EmailMessage mail1 = TestDataUtil.createEmailMessage(cObj,'0',true,'testing@testData.com');
         System.assertEquals(mail1.ParentId,cObj.Id); 
       
         cObj.Customer_Service_Category__c='Entitlement';
         cObj.Customer_Service_Sub_Category_1__c='Cannot locate PCN';
         cObj.Related_KB_Article__c='KB Not Applicable';
         cObj.Status='Solved';
         update cObj;
       
        test.starttest();
         cObj.Status='Closed';
         //cObj.Products__c = 'CSR';
         update cObj;
         EmailMessage mail5 = TestDataUtil.createEmailMessage(cObj,'2',true,';testing@testData.com;');
         System.assertEquals(mail5.ParentId,cObj.Id);
         
         test.stoptest();
         
    }
        
    static testMethod void createEmailMessage1(){
         TestDataUtil.dataValueMapCSData(); 
         Case cObj = TestDataUtil.createNonTechnicalCase();
         EmailMessage mail1 = TestDataUtil.createEmailMessage(cObj,'0',true,'testing@testData.com');
         System.assertEquals(mail1.ParentId,cObj.Id); 
         EmailMessage mail2 = TestDataUtil.createEmailMessage(cObj,'0',false,';testing@testData.com;');
         System.assertEquals(mail2.ParentId,cObj.Id); 
         cObj.Status='Pending';
         update cObj;
    }
         
         static testMethod void createEmailMessage2(){
         TestDataUtil.dataValueMapCSData(); 
         Case cObj = TestDataUtil.createNonTechnicalCase();
             
         EmailMessage mail3 = TestDataUtil.createEmailMessage(cObj,'2',true,';testing@testData.com;'); 
         System.assertEquals(mail3.ParentId,cObj.Id); 
        
         cObj.Status='In Progress';
         update cObj;
  
         EmailMessage mail5 = TestDataUtil.createEmailMessage(cObj,'2',true,';testing@testData.com;'); 
         System.assertEquals(mail5.ParentId,cObj.Id); 
             
         cObj.Status='Pending';
         update cObj;

         EmailMessage mail4 = TestDataUtil.createEmailMessage(cObj,'2',true,';testing@testData.com;'); 
         System.assertEquals(mail4.ParentId,cObj.Id); 
             
         cObj.Customer_Service_Category__c='Entitlement';
         cObj.Customer_Service_Sub_Category_1__c='Cannot locate PCN';
         cObj.Related_KB_Article__c='KB Not Applicable';             
         cObj.Status='Solved';
         update cObj;
             
   }
         
         static testMethod void createEmailMessage3(){
         TestDataUtil.dataValueMapCSData(); 
         Case cObj = TestDataUtil.createNonTechnicalCase();
         EmailMessage mail4 = TestDataUtil.createEmailMessage(cObj,'2',true,';testing@testData.com;');
         System.assertEquals(mail4.ParentId,cObj.Id);
         
         EmailMessage mail6 = TestDataUtil.createEmailMessage(cObj,'2',true,';ondemand-support.scqa@pivotal.io;');
         EmailMessage mail7 = TestDataUtil.createEmailMessage(cObj,'2',false,';testing@testData.com;');

         System.assertEquals(mail7.ParentId,cObj.Id);
         system.debug('Email Message : '+ mail6.Toaddress);
         }
}