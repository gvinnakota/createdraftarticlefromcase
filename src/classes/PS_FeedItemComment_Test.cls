@isTest
public class PS_FeedItemComment_Test {
    /*static testMethod void  FeedItemCommentTriggerHandlerTest(){
    
       TestDataUtil.dataValueMapCSData();
       Case cObj = TestDataUtil.createTechnicalCase();
       system.assert(cObj.Id != null);
       FeedItem feed = TestDataUtil.createFeedItem(cObj.Id,'AllUsers');
       system.assert(feed.Id != null);
       Test.startTest();
           TestDataUtil.createPortalContact2();
           //system.assert(cont != null);
           
           Profile Prof = [Select id from profile where name ='Pivotal - Community Manager'];
        User usr = [SELECT Id,ProfileId
                  FROM User 
                  WHERE ProfileId = :Prof.Id limit 1];
          // System.debug('Contact id'+cont.id);
         //  User usr = [Select Id , ContactId , AccountId from User where isActive = true and Profile.Name='Pivotal - Community Manager'  limit 1];
           system.assert(usr != null,'Issue in creating User');
           Case cObj1;
            System.runAs(usr){
               cObj1 = TestDataUtil.createCaseByPortalUser(usr);
               System.assert(cObj1.Id != null,'Case not created');
            }
           cObj1.Status = 'Solved';
           update cObj1;
       Test.stopTest();

       System.runAs(usr){
           FeedItem ifeed = TestDataUtil.createFeedItem(cObj1.Id,'AllUsers');
           FeedItem ifeed2 = TestDataUtil.createFeedItem(cObj1.Id,'AllUsers');
           system.assert(ifeed.Id != null);
       }
    } */
    
    static testMethod void  addPostOnTechClosedCase(){
    TestDataUtil.dataValueMapCSData();
       Contact cont = TestDataUtil.createPortalContact2();
       system.assert(cont != null);
       User usr = [Select Id , contactId,AccountId from User where isActive = true and Profile.Name='Pivotal - Community Manager' limit 1];
       system.assert(usr != null,'Issue in creating User');
       Case cObj1;
        System.runAs(usr){
           cObj1 = TestDataUtil.createCaseByPortalUser(usr);
           system.assert(cObj1.Id != null);
        }
       Entitlement ent = TestDataUtil.createEntitlement(cObj1.AccountId);
       System.assert(ent!=null);
       cObj1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
       cObj1.EntitlementId = ent.Id;
         System.runAs(usr){
           FeedItem ifeed = TestDataUtil.createFeedItem(cObj1.Id,'AllUsers');
           system.assert(ifeed.Id != null);
       }
       cObj1.Status = 'Closed';
       
       update cObj1;
       
       System.runAs(usr){
           FeedItem ifeed = TestDataUtil.createFeedItem(cObj1.Id,'AllUsers');
           system.assert(ifeed.Id != null);
       }
      
 }   
    static testMethod void  addPostOnClosedCase(){
       TestDataUtil.dataValueMapCSData();
       Contact cont = TestDataUtil.createPortalContact2();
       system.assert(cont != null);
       User usr = [Select Id , ContactId , AccountId from User where isActive = true and Profile.Name='Pivotal - Community Manager' limit 1];
       system.assert(usr != null,'Issue in creating User');
       Case cObj1;
        System.runAs(usr){
           cObj1 = TestDataUtil.createCaseByPortalUser(usr);
           system.assert(cObj1.Id != null);
        }
       cObj1.Status = 'Closed';
       update cObj1;
       System.runAs(usr){
           FeedItem ifeed = TestDataUtil.createFeedItem(cObj1.Id,'AllUsers');
           system.assert(ifeed.Id != null);
       }
    }  
    
    
    static testMethod void  addPostonArticles(){
       TestDataUtil.dataValueMapCSData();
        KnowledgeArticle__kav bf = new KnowledgeArticle__kav();
        bf.Title = 'Test Articles';
        bf.UrlName = 'TestArticles';
        bf.Symptom__c = 'Test Articles';
        bf.Resolution__c = 'Test Articles';
        bf.Product2__c  = 'Alpine Chorus for Pivotal Data Suite';
        bf.Article_Author_Lookup__c= userInfo.getUserId();
        insert bf;
        System.assert(bf.Id!=null);
        String arId = [SELECT KnowledgeArticleId FROM KnowledgeArticle__kav WHERE Id = :bf.Id].KnowledgeArticleId;
        DatavalueMap__c  csDataList = DatavalueMap__c.getInstance('ArticleTypes');
        csDataList.Data_Value__c =arId.substring(0,3);
        update csDataList;
        System.assertEquals(arId.substring(0,3),csDataList.Data_Value__c , 'Not Match');
        KbManagement.PublishingService.publishArticle(arId, true);
        
        FeedItem ifeed = TestDataUtil.createFeedItem(arId,'AllUsers');
        system.assert(ifeed.Id != null);
        system.assertEquals(ifeed.ParentId ,arId);
        FeedComment cfeed = TestDataUtil.createfeedComment(ifeed.Id);
        system.assert(cfeed.Id != null);
    }
    static testMethod void profileRND(){
         TestDataUtil.dataValueMapCSData();
        User usr = [Select Id , ContactId  from User where isActive = true and Profile.Name='Pivotal - R&D'limit 1];
        system.assert(usr.Id != null);
        FeedItem feedpost=new FeedItem();
        Case cObj2 = new Case();
        Account acc1;
        acc1 = TestDataUtil.createAccount();
        acc1.OwnerId  = usr.Id;
        update acc1;
        BusinessHours busHrs = [select Id, Name FROM BusinessHours LIMIT 1];
        system.assert(busHrs.Id != null);
        
        Entitlement ent = TestDataUtil.createEntitlement(acc1.Id);
         System.runAs(usr)
        {
           Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Email = 'Test@123.com';       
        con.BusinessHours__c = busHrs.Id;
        con.AccountId = (acc1 !=null ? acc1.Id : null);
        con.mailingcountry = 'India';
        insert con;
        System.assert(con.Id != null);
                    
        cObj2.Subject = 'Ignore Test Case';
        cObj2.Description ='Ignore Test Case creation via Test Class';
        cObj2.ContactId = con.Id;
        cObj2.AccountId = acc1.Id;
        cObj2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Technical').getRecordTypeId();
        cObj2.EntitlementId = ent.Id;
        cObj2.Products__c='Alpine Chorus for Pivotal Data Suite';
        //cObj.Versions__c='2.4';
        cObj2.Priority='Severity 1 - Critical'; 
        cObj2.Resolution_Code__c='Not Entitled';
        cObj2.Related_KB_Article__c='KB Not Applicable';
        cObj2.Case_Type__c='Escalation';
        cObj2.Resolution__c='Test';
        cObj2.Steps_to_Resolve__c='Downgrade';
        cObj2.Resolution_Opportunity_Root_Cause__c='Customer Education';
        cObj2.Status ='Open';
        insert cObj2;
           system.assert(cObj2.Id != null);
        }
         System.runAs(usr)
        {
        feedpost = TestDataUtil.createFeedItem(cObj2.Id,'AllUsers');
        system.assert(feedpost.Id != null);
        }
        feedpost.Visibility='InternalUsers';
        update feedpost;
        update cObj2;
    }
}