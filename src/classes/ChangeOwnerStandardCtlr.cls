public with sharing class ChangeOwnerStandardCtlr {
 public ApexPages.StandardSetController sController{get;set;}
   public ChangeOwnerStandardCtlr(ApexPages.StandardSetController Controller) {
   this.sController = Controller;
   System.debug('sController++'+sController.getSelected());
 }
}