@isTest
public class UAAJIT_TC {    
    
    
    
    static testmethod void handleUserFromUAATest(){
        UAAJITRegHandlerApexController handler = new UAAJITRegHandlerApexController();
        TestDataUtil.dataValueMapCSData();
        TestDataUtil.createAccount();
     
         TestDataUtil.createPortalContact();
        Map<String, String> attr = new Map<string, string>();
        attr.put('email', 'Testdatal2@gmail.com');
        attr.put('origin', 'uaa');
        attr.put('name', 'testipl');
        string fedrationInd = 'Testdatal2@gmail.com';
        string asser = 'Assert1';    
        string userId = '005W0000003DQH7IAO';
        
        user usr =  handler.createUser(null,null,null,fedrationInd,attr,asser); 
        handler.updateUser(userId,null,null,null,fedrationInd,attr,asser);      
        
    }
    static testmethod void handleUserUAATest(){
        UAAJITRegHandlerApexController handler = new UAAJITRegHandlerApexController();
        TestDataUtil.dataValueMapCSData();
        TestDataUtil.createAccount();
     
         TestDataUtil.createPortalContact();

        
        Map<string, string> attr1 = new Map<string, string>();
        attr1.put('email', 'Testdata_TC@123.com');
        attr1.put('origin', 'uaa');+
        attr1.put('name', 'TestContact');
        string fedrationId = 'Testdata@123.com';
        string asser1 = 'test1';
        
        user usr1 =  handler.createUser(null,null,null, fedrationId,attr1,asser1);
        
    } 
    
}