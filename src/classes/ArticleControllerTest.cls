@isTest(SeeAlldata=True)
public class ArticleControllerTest{
Static testMethod void Testmethod1()
{
//ApexPages.StandardSetController setCon;
Case cobj =new Case();
cobj.Subject= 'Test Subject';
cobj.Description= 'Test Description';
cobj.Products__c= 'Alpine Chorus for Pivotal Data Suite'; 
cobj.Versions__c= '6'; 
insert cobj;
String caseId = cobj.id;
    
ApexPages.currentPage().getParameters().put('sourceId', caseId);
ApexPages.currentPage().getParameters().put('sfdc.override', '1');
         
ApexPages.KnowledgeArticleVersionStandardController ctl = 
new ApexPages.KnowledgeArticleVersionStandardController(new KnowledgeArticle__kav());
         
new ArticleController(ctl);

//ApexPages.StandardController sc = new ApexPages.StandardController(cobj);
//ApexPages.KnowledgeArticleVersionStandardController ctl = new ApexPages.KnowledgeArticleVersionStandardController(cobj);
//ArticleController ac = new ArticleController();
//ac.ArticleController(ctl);
}
}