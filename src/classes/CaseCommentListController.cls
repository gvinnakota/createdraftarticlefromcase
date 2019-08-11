/*******************************************************************************************************************
* Apex Class Name  : CaseCommentListController
* Test Class Naem  : CaseCommentListControllerTC      
* Version          : 1.0
* Function         : Used to Case Comments for Case Records
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Richa Gupta                 10/03/2017              intial version
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
/*Used to Case Comments for Case Records*/
Global without sharing class CaseCommentListController{
    public String caseNumber{get;set;}
    public Id caseId;
    public List<FeedItem> feedLst{get;set;}
    public Boolean message {get; set;}
    /* Method to get the ID */
    public ID getCaseID(){ return caseId; }
    /* Method to set the ID */
    public void setCaseID(ID s){
        caseId= s;
        CaseCommentListController();
    }
    
    /*Used to get case comments from Cases */
    public void CaseCommentListController(){
        try{
        feedLst = new List<FeedItem>();
        String TextPost = DataValueMap__c.getInstance('Type').Data_Value__c;
        String AllUsers = DataValueMap__c.getInstance('Visibility').Data_Value__c;
        feedLst = [Select Id, ParentId, body , createdBy.Name, createdDate ,HasContent from FeedItem where ParentId =: caseID and type=:TextPost and Visibility=:AllUsers order by createdDate asc limit 5];
        message= true;
        if(feedLst.isEmpty()){
            message= false;
        }
        }catch(Exception e){
                        ErrorLog.CreateER(e);
                        }
    } 
    /* Method to display the List of dropdown */
    public list<FeedItem> getFeedLst(){
        return feedLst;
    }
}