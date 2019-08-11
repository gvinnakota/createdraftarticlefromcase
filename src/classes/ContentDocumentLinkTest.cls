@IsTest
public class ContentDocumentLinkTest 
{
    static testMethod void ContentDocumentLinkTest()
    {
        
        
         string before = 'Testing base 64 encode';            
         Blob beforeblob = Blob.valueOf(before);
         //Insert contentdocument data
         ContentVersion cv = new ContentVersion();
         cv.title = 'test content trigger';      
         cv.PathOnClient ='test';           
         cv.VersionData =beforeblob;          
         insert cv;          


    }

}