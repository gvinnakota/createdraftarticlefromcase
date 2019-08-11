@isTest(seeAllData=false)
public class matrixControllerTests{
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
        
        //Create some certifications
        Certification__c cert1 = new Certification__C(Pivotal_Product_Version__c=pivver1.Id, Partner_Product_Version__c=partver1.Id, Status__c='Completed'); //GPDB 4.0 - Alpine Illuminator 2.7
        Certification__c cert2 = new Certification__C(Pivotal_Product_Version__c=pivver1.Id, Partner_Product_Version__c=partver2.Id, Status__c='Completed'); //GPDB 4.0 - Alpine Illuminator 2.8
        Certification__c cert3 = new Certification__C(Pivotal_Product_Version__c=pivver2.Id, Partner_Product_Version__c=partver1.Id, Status__c='Completed'); //GPDB 4.1 - Alpine Illuminator 2.7
        Certification__c cert4 = new Certification__C(Pivotal_Product_Version__c=pivver2.Id, Partner_Product_Version__c=partver2.Id, Status__c='Completed'); //GPDB 4.1 - Alpine Illuminator 2.8
        Certification__c cert5 = new Certification__C(Pivotal_Product_Version__c=pivver1.Id, Partner_Product_Version__c=partver3.Id, Status__c='Completed'); //GPDB 4.0 - Tableau Desktop 8.0
        Certification__c cert6 = new Certification__C(Pivotal_Product_Version__c=pivver2.Id, Partner_Product_Version__c=partver3.Id, Status__c='Completed'); //GPDB 4.1 - Tableau Desktop 8.0
        insert cert1;
        insert cert2;
        insert cert3;
        insert cert4;
        insert cert5;
        insert cert6;

    }           
    static testmethod void testMatrixControllerConstructor() {
        PageReference pg = Page.integratedProduct;
        Test.setCurrentPage(pg);
        //Calling matrixController constructor
        matrixController controller = new matrixController();
        //test matrixController constructor
        System.assertEquals('Matrix',controller.selectedTab); //check default tab='Matrix'
        System.assertEquals(false, controller.hasResults);  //check that no results are displayed on landing
        System.assertEquals(false, controller.showMsg);     //check "no results" msg is not showing 
        System.assertEquals('All Certifications',controller.reportName);
    }

    static testmethod void testURLparams() {
        PageReference pg1 = new PageReference('/apex/integratedProduct?selectedTab=Certification');
        Test.setCurrentPage(pg1);
        matrixController controller1 = new matrixController();
        System.assertEquals(controller1.selectedTab, 'Certification');
        
        PageReference pg2 = new PageReference('/apex/integratedProduct?selectedTab=Pivotal');
        Test.setCurrentPage(pg2);
        matrixController controller2 = new matrixController();
        System.assertEquals(controller2.selectedTab, 'Pivotal');
    }
    
    //test getProductCategories
    static testmethod void testgetProductCategories() {
        //Calling matrixController constructor
        matrixController controller = new matrixController();
        List<selectoption> list1 = controller.getProductCategories();
        List<String> sortedCats = new List<String>{'Analytics', 'Business Continuity', 'Business Intelligence', 'Cloud Service Provider', 'Data Integration', 'Data Modeling', 'Database Tools', 'Deployment/Monitoring', 'Platform/Manageability','Search', 'Security', 'Other'};
        List<selectoption> testlist = new List<selectoption>();
        testlist.add(new selectoption('', '--All--'));
        for (String str:sortedCats) {
            testlist.add(new selectoption(str, str)); 
        }
        System.assertEquals(testlist, list1);


    }

    //test getPivProdObj()
    static testMethod void testgetPivProdObj() {
        matrixController controller = new matrixController();
        createTestData();
        Id gpdbid = [SELECT Id FROM Pivotal_Integrated_Product__c WHERE Name='GPDB'][0].Id;
        Id gphdid = [SELECT Id FROM Pivotal_Integrated_Product__c WHERE Name='GPHD'][0].Id;
        List<Selectoption> optionstest = new List<selectoption>();
        optionstest.add(new selectoption('', '--All--'));
        optionstest.add(new selectoption(gpdbid, 'GPDB'));
        optionstest.add(new selectoption(gphdid, 'GPHD'));

        System.assertEquals(optionstest, controller.getPivProdObj());
   
    }



    //test public PageReference Results()
    static testMethod void testResults() {
        createTestData();
        PageReference pg = Page.integratedProduct;
        Test.setCurrentPage(pg);
        //Calling matrixController constructor
        matrixController controller = new matrixController();
        //No filters specified by user ie ALL Partner products, ALL Pivotal products, ALL Categories
        controller.Results();
        System.assertEquals(6, controller.totalResultCount);
        System.assert(true, controller.hasResults);
        
        //Only category specified
        controller.partnerProduct.Name='';
        controller.partnerProductCategory = 'Analytics';
        controller.Results();
        System.assert(true, controller.hasResults);
        System.assertEquals(6, controller.totalResultCount);
        
        //Partner Product name specifed, no category
        controller.partnerProduct.Name = 'dhafksdf';
        controller.partnerProductCategory ='';
        controller.Results();
        System.debug(controller.totalResultCount);
        System.assertEquals(0, controller.totalResultCount);
        System.assert(true, controller.showMsg);
        
        //Partner Product name partially specified as 'Alpine'. All products containing 'Alpine' should be returned in the results
        controller.partnerProduct.Name = 'Alpine';
        controller.Results();
        System.assert(true, controller.hasResults);
        System.assertEquals(4, controller.totalResultCount);
        
        //Partner Product name specifed, no results
        controller.partnerProduct.Name = 'Tableau';
        Id gpdbid = [SELECT Id FROM Pivotal_Integrated_Product__c WHERE Name='GPDB'][0].Id;
        controller.pivotalProductName = gpdbid; //GPDB 
        controller.Results();
        System.debug(controller.totalResultCount);
        System.assertEquals(2, controller.totalResultCount);

        
       
        //No partner product specified, Pivotal product specified as GPDB, no category specified
        controller.partnerProduct.Name ='';
        controller.pivotalProductName=gpdbid; //GPDB
        controller.Results();
        System.assert(true, controller.hasResults); 
        System.assertEquals(6, controller.totalResultCount);
                

        
        //Partner product, Pivotal Product, Category all specified
        controller.partnerProduct.Name ='Tableau';
        controller.pivotalProductName =gpdbid; //GPDB
        controller.partnerProductCategory = 'Analytics';
        controller.Results();
        System.assert(true, controller.hasResults);
        System.assertEquals(2, controller.totalResultCount);
    }





    //test buildQuery()





    //test buildWhereClause






}