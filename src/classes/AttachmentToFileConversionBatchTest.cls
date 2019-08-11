@isTest
public class AttachmentToFileConversionBatchTest {
    @testSetup
    static void testMakeSetupData(){
        Test.startTest();
        
        List<Legal_Doc__c> legalList = new List<Legal_Doc__c>();
        for(integer i=0;i<1;i++){
            Legal_Doc__c opp = new Legal_Doc__c();
            legalList.add(opp);
        }
        insert legalList;

        //create Attachment
        List<Attachment> attachLst = new List<Attachment>();
        
        if (legalList.size() > 0){
            for(Integer i=0;i<3;i++){
                Attachment attachObj = new Attachment();     
                attachObj.Name = 'Unit Test Attachment '+i;
                Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body '+i);
                attachObj.body = bodyBlob;
                attachObj.parentId = legalList[0].id;
                attachLst.add(attachObj);
            }
        }
        
        if (attachLst.size()>0)
        	insert attachLst;
        
        
        Test.stopTest();
        
    }
    static testMethod void testAttachments(){
        Test.startTest();
        List<Legal_Doc__c> legalList = [select id from Legal_Doc__c LIMIT 1];
        if (legalList.size()>0){
            AttachmentToFileConversionBatch AttachmentToFileConversionBatchObj = new AttachmentToFileConversionBatch('Legal_Doc__c','id=\'' + legalList[0].Id + '\'', false);
            Database.executeBatch(AttachmentToFileConversionBatchObj);
        }
        Test.stopTest();
    }
}