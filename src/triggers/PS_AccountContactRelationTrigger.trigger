/*
Trigger Name -PS_AccountContactRelationTrigger 
Created Date     : 2 Feb 2018
Function : Trigger is used to provide access to case contact entitlement whenver a contact is linked to multiple contacts
*/
trigger PS_AccountContactRelationTrigger on AccountContactRelation (after insert,after update,after delete) {

  if((Trigger.isinsert||trigger.isupdate))
    {
        PS_AccountContactRelationHelper.rollupAccountAccess(trigger.new);
    }
  
   if(Trigger.isdelete)
    {
        PS_AccountContactRelationHelper.rollupAccountAccess(trigger.old);
    }
}