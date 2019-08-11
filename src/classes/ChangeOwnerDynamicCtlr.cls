public class ChangeOwnerDynamicCtlr {

 public boolean init;
  public apexpages.standardSetcontroller Controller{get;set;}
 // private ApexPages.StandardSetController standardController;
  public list<Id> selectRecIds{get; set;}
  public String listViewId {get; set;}
  public String listViewName {get; set;}
  public string  sobjectName {get; set;} 

  public ChangeOwnerDynamicCtlr() {
    init = false;
  }

  public void setsController(ApexPages.standardSetcontroller con) {
    if(init) {
      return;
    }
    this.controller = con;
    getDynamicObjectRecord();
    // do more initialization here.
  }

  public ApexPages.standardSetcontroller getsController() {
    return controller; // Required for component to be happy.
  }
  
  public void getDynamicObjectRecord() {
        selectRecIds = new list<id>();
        listViewId = '';
        listViewName = '';
        for (sObject rec: (List<sObject>)Controller.getSelected()){ 
            selectRecIds.add(rec.Id);
        }
        System.debug('Controller++'+Controller.getRecord());
        listViewId = Controller.getFilterId();
        sobjectName = string.valueOf(Controller.getRecord()).split(':')[0];
        listViewName = [SELECT Id, Name FROM ListView WHERE SobjectType =: sobjectName  and id=: listViewId].Name;
        
  }

    @AuraEnabled
    public static List < user> fetchUser(String searchKeyWord) {
      String searchKey = searchKeyWord + '%';
      system.debug('searchKey+++'+searchKey );
      List < user > lstOfUser = [select id, Name from user where Name LIKE: searchKey limit 5];
        return lstOfUser;
    }

    @auraEnabled
    public static void changeOwner(string ownerId, string recIds, String objName){
       
        //Query the opportunity with those OppRecIds and change the owner to OwnerId
        //update the opportunity Record
        system.debug('ownerId ++'+ownerId+'++'+recIds);
        List<String> recLst =  new list<string>();
        List<String> recLst1 =  new list<string>();
        recLst1 = recIds.trim().split(',');
        for(String a : recLst1){
          recLst.add(a.trim());
        }
       String query =  'SELECT Id, OwnerId FROM '+ objName + ' WHERE Id IN : recLst';
        list<sObject> sObjLst = Database.query(query);
        system.debug('sObjLst ++'+sObjLst);
        for(sObject sObj : sObjLst){
          //opp.OwnerId = ownerId;
          sObj.put('OwnerId',ownerId);
        }
        
        system.debug('OwnerId OwnerId ++'+sObjLst);
        //update case Ownerid with loggedin userid.
        update sObjLst;   
    }

}