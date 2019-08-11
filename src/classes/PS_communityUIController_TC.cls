@isTest
public class PS_communityUIController_TC {
    static testMethod void menubarTest(){
        TestDataUtil.dataValueMapCSData();
        Contact cont = TestDataUtil.createPortalContact();
        User usr =[Select Id from User where contactId =: cont.Id];
        system.assert(usr != null,'Issue in creating User');
        System.runAs(usr){
       		PS_communityUIController.getMenuList();
        }
    }
}