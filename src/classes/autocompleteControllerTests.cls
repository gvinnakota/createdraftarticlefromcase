@isTest(seeAllData=true)
public class autocompleteControllerTests {

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
    
    static testMethod void testSearchObjectmethod() {
        createTestData();
        //object is valid object to search
        List<sObject> results = AutocompleteController.searchObject('Partner_Product__c', 'alp', '10', 'true');
        List<sObject> expected = [ 	SELECT id, Name 
                                  	FROM Partner_Product__c
                                	WHERE Name LIKE '%alp%'
                                 	ORDER BY Name
                                 	LIMIT 10];
        System.assertEquals(expected, results);
        
        //object is not a valid object to search
        results = AutocompleteController.searchObject('Partner_And_Pivotal_Product__c', 'alp', '10', 'true');
        System.assertEquals(null, results);
        
        //catch QueryException
        results = AutocompleteController.searchObject('Partner_Product__c', 'alp', '-1', 'true');
        System.assertEquals(null, results);
        
    }
    
    
}