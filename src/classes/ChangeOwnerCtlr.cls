public class ChangeOwnerCtlr {
  
    public List<Opportunity> memList {get;set;}
    private ApexPages.StandardSetController standardController;
    public list<Id> memIds {get; set;}
    public String listViewId {get; set;}
    public String listViewName {get; set;}
  

    public ChangeOwnerCtlr(ApexPages.StandardSetController standardController){
        memIds = new list<id>();
        listViewId = '';
        listViewName = '';
        this.standardController = standardController;
        memList = new List<Opportunity>();
        for (Opportunity mem : (List<Opportunity>)standardController.getSelected()){ 
            memIds.add(mem.Id);
        }
        listViewId = standardController.getFilterId();
        listViewName = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Opportunity' and id=: listViewId].Name;
          }
    
    
   
    @AuraEnabled
    public static List < user> fetchUser(String searchKeyWord) {
      String searchKey = searchKeyWord + '%';
      system.debug('searchKey+++'+searchKey );
      List < user > lstOfUser = [select id, Name from user where Name LIKE: searchKey limit 5];
     
        system.debug('lstOfUser +++'+lstOfUser );
     
      return lstOfUser;
    }
         
    @auraEnabled
    public static void changeOwner(string ownerId, string oppRecIds){
       
         List<String> oppRecLst =  new list<string>();
        List<String> oppRecLst1 =  new list<string>();
        oppRecLst1 = oppRecIds.trim().split(',');
        for(String a : oppRecLst1){
          oppRecLst.add(a.trim());
        }
        list<Opportunity> oppLst = [SELECT id, OwnerId FROM Opportunity  WHERE Id IN :oppRecLst];
           for(opportunity opp : oppLst){
          opp.OwnerId = ownerId;
        }
        
              update oppLst;   
    }
    
    @auraEnabled
    public static void changeOwnerOnAccount(string ownerId, string oppRecIds){
       
         List<String> accRecLst =  new list<string>();
        List<String> accRecLst1 =  new list<string>();
        accRecLst1 = oppRecIds.trim().split(',');
        for(String a : accRecLst1){
          accRecLst.add(a.trim());
        }
        list<Account> accLst = [SELECT id, OwnerId FROM Account  WHERE Id IN :accRecLst];
           for(Account opp : accLst){
          opp.OwnerId = ownerId;
        }
        
              update accLst;   
    }
    

}