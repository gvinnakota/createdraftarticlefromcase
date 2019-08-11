@isTest
Private class PS_UpdateUserCreateDate_Test {
    static testMethod  void  createUser(){
        TestDataUtil.dataValueMapCSData();
        Profile pfile = TestDataFactory.createProfile('Pivotal - Sales Rep');
        User usr = TestDataFactory.createUser(pfile.Id, true);

    }
    
}