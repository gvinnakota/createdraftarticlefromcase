///////////////////////////////
//https://www.pivotaltracker.com/story/show/159511945
//Stolen and modified from https://help.salesforce.com/articleView?id=entitlements_milestones_trigger.htm&type=5
//to allow Milestones and First response time to be automatically set when a case is closed/resolved by specific profiles
//
//Test class:  MilestoneTest
//
//Revision History
//May 2019 - Created by Shane
//////////////////////////////
@isTest
private class MilestoneTest {

static testMethod void TestCompleteMilestoneCase(){


/*
List<Account> acts = new List<Account>();
Account myAcc = new Account(Name='TestAct', phone='1001231234');
acts.add(myAcc);

Account busAcc = new Account(Name = 'TestForMS', phone='4567890999');
acts.add(busAcc);
insert acts;
Contact cont = new Contact(FirstName = 'Test', LastName = 'LastName', phone='4567890999', accountid = busAcc.id);
insert(cont);

Id contactId = cont.Id;

Entitlement entl = new Entitlement(Name='TestEntitlement', AccountId=busAcc.Id);
insert entl;

*/
//added as process a builder failed.

TestDataUtil.dataValueMapCSData();
Account acc = TestDataUtil.createAccount();
System.assert(acc.Id!=null);
Contact pCont = TestDataUtil.createPortalContact();

System.assert(pCont.Id!=null);
TestDataUtil.createAccountContactRole(acc.Id,pCont.Id);
Entitlement entl = TestDataUtil.createEntitlement(pCont.AccountId);
System.assert(entl.Id != null);
User usr = [Select Id ,AccountId,ProfileId from User where contactId =: pCont.Id];     
System.assert(usr != null);
System.assertEquals(pCont.AccountId,usr.AccountId);
System.assert(usr.AccountId != acc.Id);
DataValueMap__c csData = DataValueMap__c.getInstance('PortalManagerProfileId');
csData.Data_Value__c = usr.ProfileId;
update csData;
System.assertEquals(usr.ProfileId,csData.Data_Value__c);

String entlId;
if (entl != null)
entlId = entl.Id; 

List<Case> cases = new List<Case>{};
if (entlId != null){
Case c = new Case(Subject = 'Test Case with Entitlement ', 
EntitlementId = entlId, ContactId = pCont.Id);
cases.add(c);
}
if (cases.isEmpty()==false){
insert cases;
List<Id> caseIds = new List<Id>();
for (Case cL : cases){
caseIds.add(cL.Id);
}
milestoneUtils.completeMilestone(caseIds, 'First Response', System.now());
}
}

static testMethod void testCompleteMilestoneViaCase(){


/*
List<Account> acts = new List<Account>();
Account myAcc = new Account(Name='TestAct', phone='1001231234');
acts.add(myAcc);

Account busAcc = new Account(Name = 'TestForMS', phone='4567890999');
acts.add(busAcc);
insert acts;
Contact cont = new Contact(FirstName = 'Test', LastName = 'LastName', phone='4567890999', accountid = busAcc.id);
insert(cont);

Id contactId = cont.Id;

Entitlement entl = new Entitlement(Name='TestEntitlement', AccountId=busAcc.Id);
insert entl;

*/
//added as process a builder failed.

TestDataUtil.dataValueMapCSData();
Account acc = TestDataUtil.createAccount();
System.assert(acc.Id!=null);
Contact pCont = TestDataUtil.createPortalContact();

System.assert(pCont.Id!=null);
TestDataUtil.createAccountContactRole(acc.Id,pCont.Id);
Entitlement entl = TestDataUtil.createEntitlement(pCont.AccountId);
System.assert(entl.Id != null);
User usr = [Select Id ,AccountId,ProfileId from User where contactId =: pCont.Id];     
System.assert(usr != null);
System.assertEquals(pCont.AccountId,usr.AccountId);
System.assert(usr.AccountId != acc.Id);
DataValueMap__c csData = DataValueMap__c.getInstance('PortalManagerProfileId');
csData.Data_Value__c = usr.ProfileId;
update csData;
System.assertEquals(usr.ProfileId,csData.Data_Value__c);

String entlId;
if (entl != null)
entlId = entl.Id; 

List<Case> cases = new List<Case>{};
for(Integer i = 0; i < 1; i++){
Case c = new Case(Subject = 'Test Case ' + i, Status='Resolved');
cases.add(c);
if (entlId != null){
c = new Case(Subject = 'Test Case with Entitlement ' + i, 
EntitlementId = entlId, Status='Resolved');
cases.add(c);
}
}
}
}