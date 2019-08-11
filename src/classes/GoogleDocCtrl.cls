public class GoogleDocCtrl {

    
   public static string fields = 'Id,Name,ParentId,Url';
   public static string objectName = 'GoogleDoc';
   
   public class googleDocsWrap{
       @auraEnabled public string docName{get;set;}
       @auraEnabled public string docId{get;set;}
       @auraEnabled public string docURL{get;set;}
       @auraEnabled public string docModifiedDate{get;set;}
       @auraEnabled public string createdById{get;set;}
       @auraEnabled public string createdby{get;set;}
       @auraEnabled public string createdDate{get;set;}
       @auraEnabled public string lastModifiedById{get;set;}
       @auraEnabled public string lastModifiedBy{get;set;}
       @auraEnabled public string ownerId{get;set;}
       @auraEnabled public string owner{get;set;}
       @auraEnabled public string parentId{get;set;}
       @auraEnabled public string parent{get;set;}
       public googleDocsWrap(){
       }
   }
    
    @AuraEnabled 
    public static void createGoogleDoc(string Name, string URL, string parentId) {
        try {
          list<googleDoc> gDocLst =  new list<googleDoc>();
          GoogleDoc doc =  new GoogleDoc();
          doc.Name = Name;
          doc.Url = URL;
          doc.parentID = parentId;
          
          gDocLst.add(doc);
          insert gDocLst; 
          
        }catch (Exception e) {
          throw new AuraHandledException(e.getMessage());   
        }
    }
    
    @AuraEnabled 
    public static list<googleDocsWrap> getGoogleDocs (string parentId){
        list<googleDocsWrap> googleWrapLst =  new list<googleDocsWrap>();
        list<googleDoc> googleDocsLSt = [select id, name, url, createddate, parentId, parent.name, lastModifiedDate from googleDoc where parentId =:parentId ORDER BY lastModifiedDate DESC];
        for(googleDoc doc:googleDocsLSt){ 
            googleDocsWrap docsWrap =  new googleDocsWrap(); 
            docsWrap.docName= doc.Name;
            docsWrap.docId = doc.Id;
            docsWrap.docURL = doc.Url;
            docsWrap.docModifiedDate = doc.LastModifiedDate.format('MMMM d, yyyy'); 
            docsWrap.parentId = doc.ParentId;
            docsWrap.parent = doc.Parent.Name;
            googleWrapLst.add(docsWrap);
        }
        return googleWrapLst;
    }

    @AuraEnabled
    public static googleDocsWrap googleDocDetails(string docId){
        googleDoc gDoc = new googleDoc();
        gDoc = [SELECT CreatedById,createdby.Name,CreatedDate,Id,LastModifiedById,lastModifiedBy.Name,LastModifiedDate,Name,OwnerId,owner.Name,ParentId,parent.name,Url FROM GoogleDoc where id=: docId]; 

        googleDocsWrap docsWrap =  new googleDocsWrap(); 
        docsWrap.docName= gDoc.Name;
        docsWrap.docId = gDoc.Id;
        docsWrap.docURL = gDoc.Url;
        docsWrap.docModifiedDate = gDoc.LastModifiedDate.format('MMMM d, yyyy');
        docsWrap.createdById= gDoc.CreatedById;
        docsWrap.createdby = gDoc.createdby.Name;
        docsWrap.createdDate = gDoc.CreatedDate.format('MMMM d, yyyy');
        docsWrap.lastModifiedById = gDoc.LastModifiedById;
        docsWrap.lastModifiedBy= gDoc.lastModifiedBy.Name;
        docsWrap.ownerId = gDoc.OwnerId;
        docsWrap.owner = gDoc.owner.Name;
        docsWrap.parentId = gDoc.ParentId;
        docsWrap.parent = gDoc.Parent.Name;  
        
        return docsWrap;
    }

    @AuraEnabled
    public static void updateDocRecord(list<googleDocsWrap> docLst){
      system.debug('docLst++'+docLst);
       list<googleDoc> gDocLst = new list<googleDoc>();
      for(googleDocsWrap docWrap : docLst){
        googleDoc gDoc = new googleDoc();
        gDoc.Id = docWrap.docId;
        gDoc.Name = docWrap.docName;
        gDoc.url = docWrap.docURL;
        gDocLst.add(gDoc);
      }

      update gDocLst; 
    }

    @AuraEnabled
    public static void deleteDoc(list<googleDocsWrap> docLst){
      //if(docLst!= null)
      list<googleDoc> gDocLst = new list<googleDoc>(); 
      for(googleDocsWrap docWrap : docLst){
        googleDoc gDoc = new googleDoc();
        gDoc.Id = docWrap.docId;
        gDocLst.add(gDoc);
      } 
        delete gDocLst;
    }

    
    @AuraEnabled 
    public static void AddGoogleDoc(string Name, string URL, string parentId) 
    {
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
    
    
}