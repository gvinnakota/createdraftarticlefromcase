global class AttachmentToFileConversionBatch implements Database.Batchable<sObject> {

public string sObjectName;
public string whereCondition;
public boolean deleteAttachmentsUponConversion;
    
	public AttachmentToFileConversionBatch(string strObjectName, string strWhereCondition, boolean blnDeleteAttachmentsUponConversion) {

        sObjectName = strObjectName;
        whereCondition = strWhereCondition;
        deleteAttachmentsUponConversion = blnDeleteAttachmentsUponConversion;
        
        }
        
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Name FROM '+ sObjectName;
        
        if (!string.isBlank(whereCondition))
           		query = query + ' WHERE ' + whereCondition  ;

        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<sobject> objectList) {
    
         List<Id> IdList= new List<Id>();
    
        for(sobject obj : objectList){        
            IdList.add(obj.id);
        }   
      
        AttachmentToFileConversionHelper attTFCHelper= new AttachmentToFileConversionHelper();	
        attTFCHelper.deleteAttachmentsUponConversion = deleteAttachmentsUponConversion;
        attTFCHelper.ConvertToFile(IdList);

    }
     
    global void finish(Database.BatchableContext BC) {
    
    }
}