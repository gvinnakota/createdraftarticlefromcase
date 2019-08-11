@isTest(seeAllData=false)
public class certExtensionTests {
    
    Static pageReference pg;
    Static Certification__c testcert;
    Static ApexPages.StandardController sc;
    Static certExtension ext;

    
    private static void init() {
        pg = Page.newCertification;
        Test.setCurrentPage(pg);
        testcert = new Certification__c();
        sc = new ApexPages.StandardController(testcert);
        ext = new certExtension(sc);
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
    //test checkURL() method
    static testMethod void testUrlparam() {
        createTestData(); //create test data in DB
        Id partnerVer = [SELECT Id FROM Partner_Product_Version__c WHERE Name = '2.7' AND Product_Name_Partner__r.Name = 'Alpine Illuminator'][0].id;
        Id partAcct = [SELECT Id FROM Account WHERE Name='Alpine Data Labs'][0].Id;
        Id partProd = [SELECT Id FROM Partner_Product__c WHERE Name = 'Alpine Illuminator'][0].Id;
        Id pivVer = [SELECT Id FROM Pivotal_Integrated_Product_Version__c WHERE Name = '4.0' AND Product_Name_Piv__r.Name='GPDB'][0].id;
        Id pivProd = [SELECT Id FROM Pivotal_Integrated_Product__c WHERE Name='GPDB'][0].Id;
        PageReference pg1 = new PageReference('/apex/integratedProduct?partnerVer=' + partnerVer);
        PageReference pg2 = new PageReference('/apex/integratedProduct?pivVer=' + pivVer);
        Test.setCurrentPage(pg1);
        Certification__c testcert1 = new Certification__c();
        ApexPages.StandardController sc1 = new ApexPages.StandardController(testcert1);
        certExtension ext1 = new certExtension(sc1);
        System.assertEquals(testcert1, ext1.certification);
        //certification created from Partner product version record ie. Partner prod version passed in URL
        System.assertEquals(partAcct, ext1.partnerAcct);
        System.assertEquals(partProd, ext1.partnerProduct);   
        System.assertEquals(partnerVer, ext1.partnerProductVersion);
        //certification created from Pivotal integrated product version record ie. Pivotal prod versin passed in URL
        Test.setCurrentPage(pg2);
        Certification__c testcert2 = new Certification__c();
        ApexPages.StandardController sc2 = new ApexPages.StandardController(testcert2);
        certExtension ext2 = new certExtension(sc2);
        System.assertEquals(pivProd, ext2.pivProduct);
        System.assertEquals(pivVer, ext2.pivProdVersion);
        //certification created from Certification list page ie. No params passed in URL
        init();
        System.assertEquals(NULL, ext.partnerAcct);
        System.assertEquals(NULL, ext.partnerProduct);
        System.assertEquals(NULL, ext.pivProduct);
    }
    
    //test getPivProdObj() method
    static testMethod void testgetPivProdObj() {
        init();
        createTestData();
        Id gpdbid = [SELECT Id FROM Pivotal_Integrated_Product__c WHERE Name='GPDB'][0].Id;
        Id gphdid = [SELECT Id FROM Pivotal_Integrated_Product__c WHERE Name='GPHD'][0].Id;
        List<Selectoption> optionstest = new List<selectoption>();
        optionstest.add(new selectoption('', '--Select--'));
        optionstest.add(new selectoption(gpdbid, 'GPDB'));
        optionstest.add(new selectoption(gphdid, 'GPHD'));

        System.assertEquals(optionstest, ext.getPivProdObj());
        
    }

    //test getPivProdVersion() method
    static testMethod void testGetPivProdVersions () {
        init();
        createTestData();
        Pivotal_Integrated_Product_Version__c pivstub1 = [SELECT Id FROM Pivotal_Integrated_Product_Version__c WHERE Name='4.0' AND product_name_piv__r.Name='GPDB'][0];
        Pivotal_Integrated_Product_Version__c pivstub2 = [SELECT Id FROM Pivotal_Integrated_Product_Version__c WHERE Name='4.1' AND product_name_piv__r.Name='GPDB'][0];

        ext.pivProduct = [SELECT Id FROM Pivotal_Integrated_Product__c WHERE Name='GPDB'][0].Id;
        List<Selectoption> optionstest = new List<selectoption>();
        
        optionstest.add(new selectoption('', '--Select--'));
        optionstest.add(new selectoption(pivstub2.Id, '4.1'));
        optionstest.add(new selectoption(pivstub1.Id, '4.0'));
    
        System.assertEquals(optionstest, ext.getPivProdVersionObj());    

    }    
    
     //test getPartnerAcctObj(), getPartnerProdObj() method, and getPartnerProdVersionObj() methods
    static testMethod void testgetPartnerInfo() {
        init();
        createTestData();
        Partner_Product_Version__c partnerstub1 = [SELECT Id, product_name_partner__c, product_name_partner__r.Account__c FROM Partner_Product_Version__c WHERE Name = '2.7'][0]; //Alpine Illuminator 2.7
        Partner_Product_Version__c partnerstub2 = [SELECT Id, product_name_partner__c, product_name_partner__r.Account__c FROM Partner_Product_Version__c WHERE Name = '8.0'][0]; //Tableau Desktop 8.0
        List<Selectoption> optionstest = new List<selectoption>();
        optionstest.add(new selectoption('', '--Select--'));
        optionstest.add(new selectoption(partnerstub1.product_name_partner__r.Account__c, 'Alpine Data Labs'));
        optionstest.add(new selectoption(partnerstub2.product_name_partner__r.Account__c, 'Tableau'));

        System.assertEquals(optionstest, ext.getPartnerAcctObj());
        

        ext.partnerAcct = partnerstub1.product_name_partner__r.Account__c; //set partner account to Alpine Data Labs
        ID id1 = [SELECT Id FROM Partner_Product__c WHERE Name='Alpine Miner'][0].id;
        ID id2 = [SELECT Id FROM Partner_Product__c WHERE Name='Alpine Studio'][0].id;

        List<Selectoption> optionstest2 = new List<selectoption>();
        optionstest2.add(new selectoption('', '--Select--'));
        optionstest2.add(new selectoption(partnerstub1.product_name_partner__c, 'Alpine Illuminator'));
        optionstest2.add(new selectoption(id1, 'Alpine Miner'));
        optionstest2.add(new selectoption(id2, 'Alpine Studio'));
        System.assertEquals(optionstest2, ext.getPartnerProdObj());

    
    //test getPartnerProdVersionObj() method
        ext.partnerProduct = partnerstub1.product_name_partner__c; //set partner product to Alpine Illuminator
        Partner_Product_Version__c partnerstub3 = [SELECT Id, product_name_partner__c, product_name_partner__r.Account__c FROM Partner_Product_Version__c WHERE Name = '2.8'][0]; //Alpine Illuminator 2.7

        List<Selectoption> optionstest3 = new List<selectoption>();
        optionstest3.add(new selectoption('', '--Select--'));
        optionstest3.add(new selectoption(partnerstub3.Id, '2.8'));
        optionstest3.add(new selectoption(partnerstub1.Id, '2.7'));

        System.assertEquals(optionstest3, ext.getPartnerProdVersionObj());
    }   

    static testMethod void testCancelmethod() {
        createTestData();
        Id partnerVer = [SELECT Id FROM Partner_Product_Version__c WHERE Name = '2.7' AND Product_Name_Partner__r.Name = 'Alpine Illuminator'][0].id;
        Id pivVer = [SELECT Id FROM Pivotal_Integrated_Product_Version__c WHERE Name = '4.0' AND Product_Name_Piv__r.Name='GPDB'][0].id;

        PageReference pg1 = new PageReference('/apex/integratedProduct?partnerVer=' + partnerVer);
        PageReference pg2 = new PageReference('/apex/integratedProduct?pivVer=' + pivVer);
        PageReference pg3 = new PageReference('/apex/newCertification');
        
        //CASE 1: Click back takes user back to the partner version detail record
        Test.setCurrentPage(pg1);
        testcert = new Certification__c();
        sc = new ApexPages.StandardController(testcert);
        ext = new certExtension(sc);
        PageReference backPage = ext.cancel_record();
        System.assertEquals('/'+partnerVer, backPage.getUrl());
        
        //CASE 2: Click back takes user back to ther pivotal version detail record
        Test.setCurrentPage(pg2);
        testcert = new Certification__c();
        sc = new ApexPages.StandardController(testcert);
        ext = new certExtension(sc);
        backPage = ext.cancel_record();
        System.assertEquals('/' + pivVer, backPage.getUrl());
        
        //CASE 3: Click back takes user back to new cert list page
        Test.setCurrentPage(pg3);
        testcert = new Certification__c();
        sc = new ApexPages.StandardController(testcert);
        ext = new certExtension(sc);
        backPage = ext.cancel_record();
        System.assertEquals('/apex/integratedProduct?selectedTab=Certification', backPage.getUrl());
    }
    
    static testMethod void testSaveMethod() {
        //instantiate controller and form params on new cert page
        init();
        createTestData();
        Partner_Product_Version__c partnerVer = [SELECT Id, Product_Name_Partner__c, Product_Name_Partner__r.Account__c FROM Partner_Product_Version__c WHERE Name = '2.7' AND Product_Name_Partner__r.Name = 'Alpine Illuminator'][0];
        Pivotal_Integrated_Product_Version__c pivVer = [SELECT Id, Product_Name_Piv__c FROM Pivotal_Integrated_Product_Version__c WHERE Name = '4.0' AND Product_Name_Piv__r.Name='GPDB'][0];
        //test successful insert
        ext.pivProduct = pivVer.Product_Name_Piv__c; // Pivotal Product: GPDB
        ext.pivProdVersion = pivVer.Id; // Piv Version 4.0
        ext.partnerAcct = partnerVer.Product_Name_Partner__r.Account__c; //Partner acct Alpine Data Labs
        ext.partnerProduct = partnerVer.Product_Name_Partner__c; // Partner Product Alpine Illuminator
        ext.partnerProductVersion=partnerVer.Id; //Partner version 2.7
        ext.certification.Status__c = 'Completed';
        String nextPage = ext.save_record().getURL();
        
        Certification__c[] newCert = [SELECT Certification_Name__c, Id
                                     FROM Certification__c
                                     WHERE Pivotal_Product_Version__c =: ext.pivProdVersion
                                     AND Partner_Product_Version__c =: ext.partnerProductVersion];
        ID newCertID = newCert[0].Id;    
        System.assertEquals('/' + newCertID, nextPage); //check record was inserted and resulting page is the page of the newly inserted record
    
        //test failed insert - blank record
        init();
        PageReference result = ext.save_record();
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean hasMsgs = false;
        if (msgs != null) {
            hasMsgs = true;
        }
        System.assertEquals(NULL, result);
        System.assert(hasMsgs);
    
        //test failed insert - partner account and partner prod version don't match
        init();
        Id wrongpartAcct = [SELECT Id FROM Account WHERE Name='Tableau'][0].Id;
        ext.pivProduct = pivVer.Product_Name_Piv__c; // Pivotal Product: GPDB
        ext.pivProdVersion = pivVer.Id; // Piv Version 4.0
        ext.partnerAcct = wrongpartAcct; //Partner acct Datameer
        ext.partnerProduct = partnerVer.Product_Name_Partner__c; // Partner Product Alpine Illuminator
        ext.partnerProductVersion=partnerVer.Id; //Partner version 2.7
        ext.certification.Status__c = 'Completed';
        result = ext.save_record();
        msgs = ApexPages.getMessages();
        hasMsgs = false;
        if (msgs != null) {
            hasMsgs = true;
        }
        System.assertEquals(NULL, result);
        System.assert(hasMsgs);
        
    }
}