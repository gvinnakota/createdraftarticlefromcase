trigger Foundations on Foundations__c ( after insert, after update ) {
 
  if(checkRecursiveUtil.runOnce()){
    
    List<Id> recordIds = new list<id>();

    for( Foundations__c foundation : trigger.new ){
                recordIds.add(foundation.id);
    }
      
    if(recordIds.size()>0){
         FoundationsHandler.HandleFoundationUpdate(recordIds);
    }
    
  }  


}