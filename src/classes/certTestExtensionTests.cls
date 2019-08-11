@isTest(seeAllData=false)
public class certTestExtensionTests {
    Static pageReference pg;
    Static Certification_Test__c certTeststub;
    Static ApexPages.StandardController sc;
    Static certTestExtension ext;
    
    private static void init(Id certId) {
        //test successful page landing
        pg = new PageReference('/apex/newCertTest?certId=' + certId);
        Test.setCurrentPage(pg);
        certTeststub = new Certification_Test__c();
        sc = new ApexPages.StandardController(certTeststub);
        ext = new certTestExtension(sc);

    }
    
    private static void createTestData() {
        //Insert Pivotal Integrated Product data
        Pivotal_Integrated_Product__c pivprod1 = new Pivotal_Integrated_Product__c(Name='GPDB'); 
        Pivotal_Integrated_Product__c pivprod2 = new Pivotal_Integrated_Product__c(Name='GPHD'); 
        insert pivprod1;
        insert pivprod2;
        
        //Insert Pivotal Integrated Product Versions

        Pivotal_Integrated_Product_Version__c pivver1 = new Pivotal_Integrated_Product_Version__c(Name='4.0', Product_Name_Piv__c=pivprod1.Id);
        Pivotal_Integrated_Product_Version__c pivver2 = new Pivotal_Integrated_Product_Version__c(Name='4.1', Product_Name_Piv__c=pivprod1.Id);
        Pivotal_Integrated_Product_Version__c pivver3 = new Pivotal_Integrated_Product_Version__c(Name='3.0', Product_Name_Piv__c=pivprod2.Id);
        Pivotal_Integrated_Product_Version__c pivver4 = new Pivotal_Integrated_Product_Version__c(Name='3.1', Product_Name_Piv__c=pivprod2.Id);
        insert pivver1;
        insert pivver2;
        insert pivver3;
        insert pivver4;

        //Insert some Partner Accounts
        Account alpine = new Account(Name='Alpine Data Labs', Type='Partner', Partner_Type__c = 'Technology Alliance');
        Account tableau = new Account(Name='Tableau', Type='Partner', Partner_Type__c = 'Technology Alliance');
        insert alpine;
        insert tableau;

        //Insert Partner Products
        Partner_Product__c partprod1 = new Partner_Product__c(Name='Alpine Illuminator', Account__c=alpine.Id, Product_Category__c = 'Analytics');
        Partner_Product__c partprod2 = new Partner_Product__c(Name='Tableau Desktop', Account__c=tableau.Id, Product_Category__c = 'Analytics');
        Partner_Product__c partprod3 = new Partner_Product__c(Name='Alpine Miner', Account__c=alpine.Id, Product_Category__c = 'Analytics');
        Partner_Product__c partprod4 = new Partner_Product__c(Name='Alpine Studio', Account__c=alpine.Id, Product_Category__c = 'Analytics');
        insert partprod1;
        insert partprod2;
        insert partprod3;
        insert partprod4;

        // Insert Partner Product Versions
        Partner_Product_Version__c partver1 = new Partner_Product_Version__c(Name='2.7', Product_Name_Partner__c = partprod1.Id); //Alpine Illuminator 2.7
        Partner_Product_Version__c partver2 = new Partner_Product_Version__c(Name='2.8', Product_Name_Partner__c = partprod1.Id); //Alpine Illuminator 2.8
        Partner_Product_Version__c partver3 = new Partner_Product_Version__c(Name='8.0', Product_Name_Partner__c = partprod2.Id); //Tableau Desktop 8.0
        Partner_Product_Version__c partver4 = new Partner_Product_Version__c(Name='8.1', Product_Name_Partner__c = partprod2.Id); //Tableau Desktop 8.1
        Partner_Product_Version__c partver5 = new Partner_Product_Version__c(Name='3.6', Product_Name_Partner__c = partprod3.Id); //Alpine Miner 3.6
        Partner_Product_Version__c partver6 = new Partner_Product_Version__c(Name='3.7', Product_Name_Partner__c = partprod3.Id); //Alpine Miner 3.7
        Partner_Product_Version__c partver7 = new Partner_Product_Version__c(Name='4.4', Product_Name_Partner__c = partprod4.Id); //Alpine Studio 4.4
        
        //Insert
        insert partver1;
        insert partver2;
        insert partver3;
        insert partver4;
        insert partver5;
        insert partver6;
        insert partver7;        
        
    }    
    
    public static testMethod void testConstructor() {
        //set up new certification test page for certification GPDB 4.2 - Alpine Illuminator 2.7
        createTestData();
        Partner_Product_Version__c partnerVer = [SELECT Id, Product_Name_Partner__c, Product_Name_Partner__r.Account__c FROM Partner_Product_Version__c WHERE Name = '2.7' AND Product_Name_Partner__r.Name = 'Alpine Illuminator'][0];
        Pivotal_Integrated_Product_Version__c pivVer = [SELECT Id, Product_Name_Piv__c FROM Pivotal_Integrated_Product_Version__c WHERE Name = '4.0' AND Product_Name_Piv__r.Name='GPDB'][0];  
        Certification__c certstub = new Certification__c(Partner_Product_Version__c=partnerVer.Id, Pivotal_Product_Version__c=pivVer.Id, Status__c='Completed');
        insert certstub;
        init(certstub.Id);
        System.assertEquals('GPDB 4.0 - Alpine Illuminator 2.7', ext.certName);
        System.assertEquals(certstub.Id, ext.certTest.Certification__c); //current cert test record's parent is certification GPDB 4.2 - Alpine Illuminator 2.7
        System.assert(ext.showForm);
        
        pg = new PageReference('/apex/newCertTest');
        Test.setCurrentPage(pg);
        certTeststub = new Certification_Test__c();
        sc = new ApexPages.StandardController(certTeststub);
        ext = new certTestExtension(sc);
        System.assert(!ext.showForm);        

    }

    
    public static testMethod void testCancel() {
        createTestData();
        Partner_Product_Version__c partnerVer = [SELECT Id, Product_Name_Partner__c, Product_Name_Partner__r.Account__c FROM Partner_Product_Version__c WHERE Name = '2.7' AND Product_Name_Partner__r.Name = 'Alpine Illuminator'][0];
        Pivotal_Integrated_Product_Version__c pivVer = [SELECT Id, Product_Name_Piv__c FROM Pivotal_Integrated_Product_Version__c WHERE Name = '4.0' AND Product_Name_Piv__r.Name='GPDB'][0];        
        Certification__c certstub = new Certification__c(Partner_Product_Version__c=partnerVer.Id, Pivotal_Product_Version__c=pivVer.Id, Status__c='Completed');
        insert certstub;
        init(certstub.Id);
        PageReference cancelPage = ext.cancel_record();
        System.assertEquals('/'+certstub.Id, cancelPage.getUrl());
    }
    
}