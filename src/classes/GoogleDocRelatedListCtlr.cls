public class GoogleDocRelatedListCtlr {

   public static string fields = 'Id,Name,ParentId,Url';
   public static string objectName = 'GoogleDoc';
   
   public class googleDocsWrap{
       @auraEnabled public string docName{get;set;}
       @auraEnabled public string docId{get;set;}
       @auraEnabled public string docURL{get;set;}
       @auraEnabled public string docModifiedDate{get;set;}
       public googleDocsWrap(){
       }
   }
    
    @AuraEnabled 
    public static void fetchAccounts(string Name, string URL, string parentId) {
        try {
                GoogleDoc doc =  new GoogleDoc();
                doc.Name = Name;
                doc.Url = URL;
                doc.parentID = parentId;
                 
                insert doc;
                
            } catch (Exception e) {
    
              throw new AuraHandledException(e.getMessage());   
        }
    }
    
    @AuraEnabled 
    public static list<googleDocsWrap> getGoogleDocs (string parentId){
        list<googleDocsWrap> googleWrapLst =  new list<googleDocsWrap>();
        list<googleDoc> googleDocsLSt = [select id, name, url, createddate, parentId, lastModifiedDate from googleDoc where parentId =:parentId ORDER BY lastModifiedDate DESC];
        String LongDate = ' ';
        Datetime cDT = System.now();
        LongDate = cDT.format('MMMM d, yyyy');
        system.debug(LongDate);
        for(googleDoc doc:googleDocsLSt){ 
            googleDocsWrap docsWrap =  new googleDocsWrap(); 
            docsWrap.docName= doc.Name;
            docsWrap.docId = doc.Id;
            docsWrap.docURL = doc.Url;
            docsWrap.docModifiedDate = doc.LastModifiedDate.format('MMMM d, yyyy'); 
           // docsWrap.docCreatedDate= doc.createdDate;
            googleWrapLst.add(docsWrap);
        }
        return googleWrapLst;
    }
    
}