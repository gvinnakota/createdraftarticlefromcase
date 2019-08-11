@isTest
public class CaseCommentListControllerTC {
    @isTest
    static void TC1(){
        TestDataUtil.dataValueMapCSData();
        Case cse = TestDataUtil.createNonTechnicalCase(); 
        CaseCommentListController c= new CaseCommentListController();
        c.setCaseID(cse.Id);
        FeedItem feed = new FeedItem (parentid = cse.id,Body='Test', type = 'TextPost',Visibility='AllUsers');
        insert feed;
        c.getCaseID();
        c.caseNumber = cse.CaseNumber;
        c.message = true;
        c.setCaseID(cse.Id);
        c.getFeedLst();
        TestDataUtil.removeDataValueMapCSData();
        c.setCaseID(cse.Id);
   }
}