@isTest
public class UserUpdateController_TC{
 
 static testMethod void  testProfileID()
 {
     TestDataUtil.dataValueMapCSData(); 
    TestDataUtil.createPortalContact2();
    Profile Prof = [Select id from profile where name ='Pivotal - Community Manager'];
        User u = [SELECT Id,ProfileId
                  FROM User 
                  WHERE ProfileId = :Prof.Id limit 1];
    UserUpdateController.ProfileId(u.id);
    
 }
}