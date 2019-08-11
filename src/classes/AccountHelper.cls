/*******************************************************************************************************************
* Apex Class Name  : AccountHelper 
* Test Class Name  : AccountHelper_TC
* Version          : 1.0
* Function         : 
* Modification Log :
*
* Developer                   Date                    Description
* ------------------------------------------------------------------------------------------------------------------
* Amit                        09/22/2017              intial version
* --------------------------------------------------------------------------------------------------------------------
*******************************************************************************************************************/
public without Sharing class AccountHelper {
    public account acc; 
/***
Method Name : AccountHelper
Purpose : Constructor
***/    
    public AccountHelper( ApexPages.StandardController stdController ){
        acc = (account)stdController.getRecord();        
    }
/***    
Method Name : rollupOppContacts
Purpose : Used to roll up Account access
***/
    public void rollupOppContacts(){
        AccountHelper.rollupAccountAccess(acc.Id );   
    }
    
/***
Method Name : rollupAccountAccess
Purpose : Used to roll up Account access
***/
    public static void rollupAccountAccess(Id accId){
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(-10);
        List<accountContactRole> contactRoleRec = [SELECT ContactId,Role,Contact.AccountID,Contact.Customer_Admin__c,Contact.View_Account_Cases__c,Contact.Enable_Portal_User__c ,lastModifiedDate, isDeleted FROM accountContactRole WHERE accountId =: accId and lastModifiedDate >: sysTime and contact.AccountID !=:accId Order By lastModifiedDate asc limit 1 ALL ROWS];
        
        if(!contactRoleRec.isEmpty()){
            List<Contact> contactToUpdate = new List<contact>();
            Map<String,PortalObjectAccess__c> portalObjectAccessMap = PortalObjectAccess__c.getAll();
            Map<Id,AccountContactRole> mapAccountContactRole = new Map<Id,AccountContactRole>();            
            for(accountContactRole acR : contactRoleRec){
                mapAccountContactRole.put(acR.ContactID,acR);
            }
            if(!portalObjectAccessMap.isEmpty()){                
                Map<Id,AccountContactRole> userIds = new Map<Id,AccountContactRole>();
                Map<Id,User> userTobeRemovedMap = new Map<Id,User>();
                Map<Id,portalObjectAccess__c> userToUpsertMap = new Map<Id,portalObjectAccess__c>();
                List<AccountShare> accShareToCreate = new List<AccountShare>();                
                for(User usr :[SELECT Id,isActive,ProfileId,ContactID,AccountId FROM user WHERE contactID =:mapAccountContactRole.KeySet()]){
                    AccountContactRole acR = mapAccountContactRole.get(usr.ContactID);                    
                    if(acR.isDeleted){
                        userTobeRemovedMap.put(usr.Id,usr);
                        userIds.put(usr.id,acR);
                    }else{
                        String contactRole = String.ValueOf(acR.Role).remove('-');
                        String key = usr.ProfileId+ContactRole.deleteWhitespace();
                        System.debug('key ---->'+key );
                        portalObjectAccess__c objAccess = portalObjectAccessMap.get(key);
                        System.debug('objAccess ---->'+objAccess );
                        if(objAccess != null){
                            AccountShare accShare = new AccountShare();
                            accShare.AccountAccessLevel = objAccess.Account__c;
                            accShare.ContactAccessLevel= objAccess.Contact__c;
                            accShare.CaseAccessLevel= objAccess.Case__c;
                            accShare.OpportunityAccessLevel= objAccess.Opportunity__c;
                            accShare.AccountId = accId;
                            accShare.Userorgroupid = usr.id;
                            accShareToCreate.add(accShare);
                            userIds.put(usr.id,acR);
                            userToUpsertMap.put(usr.Id, objAccess);
                        }
                    }
                }
                
                List<AccountShare> accShareToUpdate = new List<AccountShare>();
                List<AccountShare> accShareToDelete = new List<AccountShare>();
                Boolean isShareexists = false;
                for(AccountShare accShare :[SELECT Id,AccountId, AccountAccessLevel,UserOrGroupId,ContactAccessLevel,CaseAccessLevel FROM AccountShare WHERE AccountId =: accId and UserOrGroupId =:userIds.KeySet()]){
                    Id usrId = accShare.UserOrGroupId;                    
                    if(userTobeRemovedMap.containsKey(usrId)){
                        isShareexists = true;
                        accShareToDelete.add(accShare);
                    }
                    if(userToUpsertMap.containsKey(usrId)){
                        portalObjectAccess__c objAccess = userToUpsertMap.get(usrId);
                        String shareKey = accShare.AccountAccessLevel+accShare.ContactAccessLevel+accShare.CaseAccessLevel;
                        String masterKey = objAccess.Account__c+objAccess.Contact__c+objAccess.Case__c;
                        if(shareKey != masterKey){
                            isShareexists = true;
                            accShare.AccountAccessLevel = objAccess.Account__c;
                            accShare.ContactAccessLevel = objAccess.Contact__c;
                            accShare.CaseAccessLevel = objAccess.Case__c;
                            accShareToUpdate.add(accShare);
                        }                        
                    }
                }
                try{
                    if(isShareexists && !accShareToUpdate.isEmpty()){
                        update accShareToUpdate;
                    }                    
                    if(!accShareToDelete.isEmpty()){
                        delete accShareToDelete;
                    }
                    if(!isShareexists && !accShareToCreate.isEmpty()){
                        insert accShareToCreate;
                    }
                }
                Catch(Exception e){
                    ErrorLog.CreateER(e);//Exception captured in Utility Class Errorlog
                }
            }
        }
    }
/***
Method Name : UpdateCaseCommentOnContact
Purpose : To insert caseComment in case object
***/
   /* public static void UpdateCaseCommentOnContact(List<Contact> lstContact){
        set<ID> contactId = new set<ID>();
        set<ID> caseId = new set<ID>();
        
        List<FeedItem> lstFeedItem = new List<FeedItem>();
        String OnHold = DataValueMap__c.getInstance('On Hold').Data_Value__c;
        for(Contact con : lstContact){
            if(!con.Cleared_by_Compliance__c && String.isNotBlank(con.Notes_From_Compliance_Team__c) && (con.RPS_Status__c == 'red' || con.RPS_Status__c == 'yellow')){
                contactId.add(con.id);
            }
        }
        for(Contact con : [select id,(Select id,status from cases where status = :OnHold) from contact where id IN :contactId]){
            for(case cas : con.cases){
                caseId.add(cas.id);
            }
        }
        for(ID Feed : CaseId){
            feedItem fi = new FeedItem();
            fi.ParentId = Feed;
            fi.body = 'Contact not Cleared by Compliance';
            lstFeedItem.add(fi);
        }
        if(!lstFeedItem.isEmpty()){
            try{
                insert lstFeedItem;
            }
            Catch(Exception e){
                ErrorLog.CreateER(e);//Exception captured in Utility Class Errorlog
            }
        }
    } */
}