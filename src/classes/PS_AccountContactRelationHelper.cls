/*
/*******************************************************************************************************************
* Apex Class Name  : PS_AccountContactRelationHelper
* Version          : 1.0
* Created Date     : 19 Feb 2018
* Function         : Class is used for- account share create/update/delete
* Modification Log : 
*
* Developer                        Date                       Description
* ------------------------------------------------------------------------------------------------------------------
* Rohan Kolvekar            19/02/2018            PS_AccountContactRelationHelper used for Account Share User story #1729
* ------------------------------------------------------------------------------------------------------------------
********************************************************************************************************************
*/public class PS_AccountContactRelationHelper {
    public static void rollupAccountAccess(List<AccountContactRelation> lstAccCon)
    {        
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id,AccountContactRelation> accMap = new Map<Id,AccountContactRelation>();
        Map<Id,AccountContactRelation> userIds = new Map<Id,AccountContactRelation>();
        Map<Id,User> userTobeRemovedMap = new Map<Id,User>();
        List<AccountShare> accShareToCreate = new List<AccountShare>(); 
        //Map<String,PortalObjectAccess__c> portalObjectAccessMap = PortalObjectAccess__c.getAll();
        Map<Id,portalObjectAccess__c> userToUpsertMap = new Map<Id,portalObjectAccess__c>();        
        
        for( AccountContactRelation acc:lstAccCon){ contactIds.add(acc.ContactId);
            accMap.put(acc.ContactId,acc);
            accountIds.add(acc.AccountId);
        }
        if(!PortalObjectAccess__c.getAll().isEmpty()){  for(User usr :[Select Id ,ProfileId, ContactId  from User where contactId =:contactIds]){ AccountContactRelation acR = accMap.get(usr.ContactID);                    
                if(trigger.isdelete){ userTobeRemovedMap.put(usr.Id,usr);
                    userIds.put(usr.id,acR);
                }
                
                else{ String key = usr.ProfileId + accMap.get(usr.ContactId).Roles;
                    key=key.deleteWhiteSpace();
                    portalObjectAccess__c objAccess = PortalObjectAccess__c.getAll().get(key);
                    if(objAccess != null){ accShareToCreate.add(new AccountShare(AccountAccessLevel = objAccess.Account__c, ContactAccessLevel= objAccess.Contact__c, CaseAccessLevel= objAccess.Case__c, OpportunityAccessLevel= objAccess.Opportunity__c, UserOrGroupId= usr.Id, AccountId = accMap.get(usr.ContactId).AccountId));                         
                        userIds.put(usr.id,acR);
                        userToUpsertMap.put(usr.Id, objAccess);                        
                    }
                } 
            }          
            
            List<AccountShare> accShareToUpdate = new List<AccountShare>();
            List<AccountShare> accShareToDelete = new List<AccountShare>();
            Boolean isShareexists = false;
            for(AccountShare accShare :[SELECT Id,AccountId, AccountAccessLevel,UserOrGroupId,ContactAccessLevel,CaseAccessLevel FROM AccountShare WHERE AccountId =: accountIds and UserOrGroupId =:userIds.KeySet()]){ Id usrId = accShare.UserOrGroupId;                    
                if(userTobeRemovedMap.containsKey(usrId)){ isShareexists = true;
                    accShareToDelete.add(accShare);
                } 
                if(userToUpsertMap.containsKey(usrId)){ portalObjectAccess__c objAccess = userToUpsertMap.get(usrId);
                    if(accShare.AccountAccessLevel+accShare.ContactAccessLevel+accShare.CaseAccessLevel != (objAccess.Account__c+objAccess.Contact__c+objAccess.Case__c)){ isShareexists = true;
                        accShare.AccountAccessLevel = objAccess.Account__c;
                        accShare.ContactAccessLevel = objAccess.Contact__c;
                        accShare.CaseAccessLevel = objAccess.Case__c;
                        accShareToUpdate.add(accShare);
                    }                        
                }
            }
            try{
                if(isShareexists && !accShareToUpdate.isEmpty()) update accShareToUpdate;                  
                if(!accShareToDelete.isEmpty()) delete accShareToDelete;
                if(!isShareexists && !accShareToCreate.isEmpty()) insert accShareToCreate;
            }
            Catch(Exception e){ ErrorLog.CreateER(e);}
        }
    }   
}