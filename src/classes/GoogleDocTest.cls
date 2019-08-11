@isTest
public class GoogleDocTest {

    @isTest
    public static void testfetchAccounts(){
    
        Legal_Doc__c legalDoc = new Legal_Doc__c();
        insert legalDoc;
    
        GoogleDocCtrl.AddGoogleDoc('tee','https://docs.google.com/document/d/1h5555/edit',legalDoc.Id);
        
    }


   
    @isTest 
    static void testgodctrl()
    {
        Legal_Doc__c legalDoc = new Legal_Doc__c();
        insert legalDoc;

        GoogleDocCtrl.createGoogleDoc('Salesforce Test google ctrl','https://docs.google.com/document/d/h555/edit?usp=sharing',legalDoc.Id);
       
        googleDoc testgdoc = new googleDoc();
         
        testgdoc.Name='salesforce test';
        testgdoc.Url='https://docs.google.com/document/d/1lllvJrLTJp5vgdB-z525F71i6rvkb-dfcrvr/edit?usp=sharing';
        testgdoc.ParentId= legalDoc.Id;
        insert testgdoc;
    
        GoogleDocCtrl.getGoogleDocs(legalDoc.Id);
        
        GoogleDocCtrl.googleDocDetails(testgdoc.id);
        
        list< GoogleDocCtrl.googleDocsWrap> gwrapLst = new list< GoogleDocCtrl.googleDocsWrap>();
        
        GoogleDocCtrl.googleDocsWrap  gWrap =  new GoogleDocCtrl.googleDocsWrap  ();
        gWrap.docId = testgdoc.id; 
        gWrap.docName = testgdoc.Name;
        gWrap.docURL = testgdoc.url;
        
        gwrapLst.add(gWrap);
        
        GoogleDocCtrl.updateDocRecord(gwrapLst);
        GoogleDocCtrl.deleteDoc(gwrapLst);
        
    }
        
    
    
}