global class FoundationsHandler {

  public static Boolean hasAlreadyExecuted = false;

  @future
  public static void HandleFoundationUpdate(List<Id> recordIds) {
  

        if(checkRecursiveUtil.runOnce() || Test.isRunningTest()){
         
            List< Foundations__c > foundationsList = [Select Id, Month_Consumption_Collected__c, Previous_Month_Consumption_Collected__c from Foundations__c Where Id IN :recordIds];
            
            List<Foundations__c> foundationsUpdateList = new list<Foundations__c>();
            for( Foundations__c foundation : foundationsList ){
                if ( ! string.IsBlank(foundation.Month_Consumption_Collected__c)){
                    foundation.Previous_Month_Consumption_Collected__c = foundation.Month_Consumption_Collected__c;
                    foundation.Month_Consumption_Collected__c =null;
                    foundationsUpdateList.add(foundation);
                }
            
            }
            
            if(foundationsUpdateList.size()>0)
            {
                 update foundationsUpdateList;
            }
        
    }
  }
}