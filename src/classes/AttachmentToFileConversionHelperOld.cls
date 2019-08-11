Public class AttachmentToFileConversionHelperOld {

 public static void ConvertToFile(list < id > conids) {

  //Fetching all available attachments in the org
  List < Attachment > attachments = [Select Body, Id, Name, parentId ,OwnerId From Attachment where parentId IN: conids];
  System.debug('Attachments'+attachments);
  //Details of content version fields are given in the below link
  //https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_contentversion.htm

  //to map Attachment Id with ContentVersion record
  Map < Id, ContentVersion > attachmentCVs = new Map < Id, ContentVersion > ();
  //Map ---> Attachement - Attachment Parent Id 
  Map < Id, Id > attachementParentIds = new Map < Id, Id > ();

  //Generating file version using content version object
  for (Attachment att: attachments) {
   ContentVersion cv = new ContentVersion();
   //S - Salesforce  , check details on above link
   cv.ContentLocation = 'S';
   cv.PathOnClient = att.Name;
   //H - Chatter   , check details on above link
   cv.Origin = 'H';
   //cv.OwnerId = att.OwnerId;
   cv.Title = att.Name;
   cv.VersionData = att.Body;

   attachmentCVs.put(att.Id, cv);
   attachementParentIds.put(att.Id, att.ParentId);
  }
  //System.debug(attachmentCVs);

  //Insert the content versions from attachment data
  if (attachmentCVs.values().size() > 0) {
   insert attachmentCVs.values();
  }

  //to map ContentVersionId with AttachmentParent Id for ContentDocument Linking
  map < Id, Id > cvToAttchmtParentIdMap = new map < Id, Id > ();

  List < Id > cvIds = new List < Id > ();
  for (Id key: attachmentCVs.keySet()) {
   ContentVersion cv = attachmentCVs.get(key);
   Id attchmentParentId = attachementParentIds.get(key);
   //System.debug('cvToAttchmtParentIdMap'+cvToAttchmtParentIdMap);
   cvToAttchmtParentIdMap.put(cv.Id, attchmentParentId);
   cvIds.add(cv.Id);
   //System.debug('cvIds'+cvIds);
  }
  //Fetching contentDocumentId using contentVersionId
  List < ContentVersion > cvWithDocIds = [select Id, ContentDocumentId from ContentVersion where Id IN: cvIds];
  System.debug('cvDocIds'+cvWithDocIds);

  //to link the files (versions) to its parent records like opportunity,case etc.
  List < ContentDocumentLink > contentDocumentLinks = new List < ContentDocumentLink > ();
  for (ContentVersion cv: cvWithDocIds) {
   Id attachmentParentId = cvToAttchmtParentIdMap.get(cv.Id);
   ContentDocumentLink cl = new ContentDocumentLink(LinkedEntityId = attachmentParentId, ContentDocumentId = cv.ContentDocumentId, ShareType = 'I');
   ContentDocumentLinks.add(cl);
  }

  if (contentDocumentLinks.size() > 0) {
   insert contentDocumentLinks;
  }

  System.debug('contentDocumentLinks'+contentDocumentLinks);
  //Delete all exisiting attachments once it is converted into Files if needed.
  if (attachments.size() > 0) {
   delete attachments;
  }
 }
}