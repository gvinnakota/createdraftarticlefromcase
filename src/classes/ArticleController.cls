/*******************************************************************************************************************
* Apex Class Name  : ArticleController 
* Version          : 1.0
* Created Date     : 08 August 2017
* Function         : class is used to auto populate values from case to artilce
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Karthik.A.S               08/03/2017            initial version
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
public class ArticleController {
    
    public ArticleController(ApexPages.KnowledgeArticleVersionStandardController ctl) {
        SObject article = ctl.getRecord();   
        
        String sourceId = ctl.getSourceId(); 
        Case c = [select subject, description,Products__c,Versions__c,Component__c, Sub_Component__c,CaseNumber from Case where id=:sourceId];
        
        article.put('title', +c.subject);   
        article.put('Product2__c',c.Products__c); 
        article.put('Product_Version__c',c.Versions__c);
        article.put('Component__c',c.Component__c); 
        article.put('Sub_Component__c',c.Sub_Component__c);
        article.put('Article_Created_from_Case__c',c.CaseNumber);
    }
}