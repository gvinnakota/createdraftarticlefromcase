@IsTest
public with sharing class PACDataLoaderControllerTest {

    static zqu__ProductRatePlanCharge__c prpc;
    static zqu__ZProduct__c zProd;
    static Product2 product;

    @TestSetup
    static void createData() {
        TestDataUtil.dataValueMapCSData();
        TestUtils.createUser('testLaunchpad', TestUtils.PROFILE_SYSTEM_ADMINISTRATOR, true);
    }

    static void createCommonData() {
        Account acc = TestDataFactory.createAccount(true);
        Contact ctt = TestDataFactory.createContact(acc.Id, true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);

        product = new Product2(Name = 'Test App Suite' ,zqu__SKU__c = 'SSS-12123');
        insert product;

        zProd = [SELECT Id, Name, zqu__SKU__c FROM zqu__ZProduct__c WHERE zqu__Product__c = :product.Id];
        //zProd.Requires_VMW_Fulfillment__c = true;
        //update zProd;

        zqu__ProductRatePlan__c prp = TestDataFactory.makeProductRatePlan(zProd.Id, 'Annual Rate Plan', product.Id);

        prpc = ZTestFactory.makeProductRatePlanCharge(prp.Id, 'One-Time', 'Per Unit Pricing');
    }

    @IsTest
    static void testControllerWithSubmittingFile() {
        User u = TestUtils.findUser('testLaunchpad');
        System.runAs(u) {
            PACDataLoaderController ctrl = new PACDataLoaderController();
            String csvString =
                    'CNA-NXT-PKS-C-1yr -500\n'
                            + 'PAC for 500 NSX-T for PKS Licenses (per POD)\n'
                            + 'with 1yr Subscription\n'
                            + '2\n'
                            + 'F0012-0ZPG2-Z8KUR-A3M02-19NHN\n'
                            + 'F1092-4ZMGK-G8VUH-AKN04-0DG0N\n';
            ctrl.file.Body = Blob.valueOf(csvString);
            ctrl.file.Name = 'Test file';
            System.assert(!ctrl.isFileSelected);
            ctrl.submitFile();
            System.assert(null != ctrl.file.Id);
            System.assertEquals(2, ctrl.getPACWrappers().size());
        }
    }

    @IsTest
    static void testControllerWithFileProvided() {
        User u = TestUtils.findUser('testLaunchpad');
        System.runAs(u) {
            TestCsvPACBuilder builder = new TestCsvPACBuilder()
                    .withName('Test file')
                    .add(new TestCsvPACBuilder.PACWrp()
                            .withCode('CNA-NXT-PKS-C-1yr -500')
                            .withName('PAC for 500 NSX-T for PKS Licenses (per POD)')
                            .withSubscription('with 1yr Subscription')
                            .withProducts(new List<String> {
                                    'F0012-0ZPG2-Z8KUR-A3M02-19NHN',
                                    'F1092-4ZMGK-G8VUH-AKN04-0DG0N'
                            })
                            .build()
                    )
                    .add(new TestCsvPACBuilder.PACWrp()
                            .withCode('CNA-NXT-PCS-C-1yr -500')
                            .withName('PAC for 500 NSX-T for PKS Licenses (per POD)')
                            .withSubscription('with 1yr Subscription')
                            .withProducts(new List<String> {
                                    'Z0012-0ZPG2-Z8KUR-A3M02-19NHN',
                                    'Y0012-0ZPG2-Z8KUR-A3M02-19NHN',
                                    'K0012-0ZPG2-Z8KUR-A3M02-19NHN',
                                    'X1092-4ZMGK-G8VUH-AKN04-0DG0N'
                            })
                            .build()
                    );
            Document d = builder.build();
            ApexPages.currentPage().getParameters().put('Id', d.Id);
            PACDataLoaderController ctrl = new PACDataLoaderController();
            System.assert(ctrl.isFileSelected);
            System.assertEquals(6, ctrl.getPACWrappers().size());
        }
    }

    @IsTest
    static void testSavingRecords() {
        User u = TestUtils.findUser('testLaunchpad');
        System.runAs(u) {
            TestCsvPACBuilder builder = new TestCsvPACBuilder()
                    .withName('Test file')
                    .add(new TestCsvPACBuilder.PACWrp()
                            .withCode('CNA-NXT-PKS-C-1yr -500')
                            .withName('PAC for 500 NSX-T for PKS Licenses (per POD)')
                            .withSubscription('with 1yr Subscription')
                            .withProducts(new List<String>{
                                    'F0012-0ZPG2-Z8KUR-A3M02-19NHN',
                                    'F1092-4ZMGK-G8VUH-AKN04-0DG0N'
                            })
                            .build()
                    )
                    .add(new TestCsvPACBuilder.PACWrp()
                            .withCode('CNA-NXT-PCS-C-1yr -500')
                            .withName('PAC for 500 NSX-T for PKS Licenses (per POD)')
                            .withSubscription('with 1yr Subscription')
                            .withProducts(new List<String>{
                                    'Z0012-0ZPG2-Z8KUR-A3M02-19NHN',
                                    'Y0012-0ZPG2-Z8KUR-A3M02-19NHN',
                                    'K0012-0ZPG2-Z8KUR-A3M02-19NHN',
                                    'X1092-4ZMGK-G8VUH-AKN04-0DG0N'
                            })
                            .build()
                    );
            Document d = builder.build();
            ApexPages.currentPage().getParameters().put('Id', d.Id);
            PACDataLoaderController ctrl = new PACDataLoaderController();
            System.assert(!ctrl.getContainsDuplicates());
            ctrl.saveRecords();
            System.assertEquals(6, [SELECT id FROM PAC__c].size());
        }
    }

    @IsTest
    static void testSavingDuplicated() {
        User u = TestUtils.findUser('testLaunchpad');
        System.runAs(u) {
            List<String> existingKeys = new List<String> {
                    'Y0012-0ZPG2-Z8KUR-A3M02-19NHN',
                    'F1092-4ZMGK-G8VUH-AKN04-0DG0N',
                    'F109H-4ZMGK-G8VUH-AKN04-0DG0N',
                    'F109G-4ZMGK-G8VUH-AKN04-0DG0N'
            };
            TestPACBuilder pacBuilder = new TestPACBuilder()
                    .withCode('CNA-NXT-PKS-C-1yr -500');
            List<PAC__c> pacs = new List<PAC__c> ();
            for (String key : existingKeys) {
                pacBuilder.withKey(key);
                pacs.add(pacBuilder.buildWithoutSaveAndClone());
            }
            insert pacs;
            TestCsvPACBuilder builder = new TestCsvPACBuilder()
                    .withName('Test file')
                    .add(new TestCsvPACBuilder.PACWrp()
                            .withCode('CNA-NXT-PKS-C-1yr -500')
                            .withName('PAC for 500 NSX-T for PKS Licenses (per POD)')
                            .withSubscription('with 1yr Subscription')
                            .withProducts(new List<String>{
                                    'F0012-0ZPG2-Z8KUR-A3M02-19NHN',
                                    existingKeys[1]
                            })
                            .build()
                    )
                    .add(new TestCsvPACBuilder.PACWrp()
                            .withCode('CNA-NXT-PCS-C-1yr -500')
                            .withName('PAC for 500 NSX-T for PKS Licenses (per POD)')
                            .withSubscription('with 1yr Subscription')
                            .withProducts(new List<String>{
                                    'Z0012-0ZPG2-Z8KUR-A3M02-19NHN',
                                    existingKeys[2],
                                    'K0012-0ZPG2-Z8KUR-A3M02-19NHN',
                                    'X1092-4ZMGK-G8VUH-AKN04-0DG0N'
                            })
                            .build()
                    );
            Document d = builder.build();
            ApexPages.currentPage().getParameters().put('Id', d.Id);
            PACDataLoaderController ctrl = new PACDataLoaderController();
            System.assert(ctrl.getContainsDuplicates());
            System.assertEquals(6, ctrl.pacProvider.pacs.size());
            System.assertEquals(4, ctrl.pacProvider.pacsToInsert.size());
            ctrl.saveRecords();
            System.assertEquals(8, [SELECT id FROM PAC__c].size());
        }
    }

    @IsTest
    static void testSavingWithMapping() {
        User u = TestUtils.findUser('testLaunchpad');
        System.runAs(u) {
            createCommonData();
            Map<String, String> prod2SKUMap = new Map<String, String> {
                    'PCS' => product.Id
            };
            List<PAC_Product_Map__c> prodMap = new List<PAC_Product_Map__c>();
            for (String prod : prod2SKUMap.keySet()) {
                prodMap.add(new PAC_Product_Map__c(PAC_Product__c = prod, Product2__c = prod2SKUMap.get(prod)));
            }
            insert prodMap;
            TestCsvPACBuilder builder = new TestCsvPACBuilder()
                    .withName('Test file')
                    .add(new TestCsvPACBuilder.PACWrp()
                            .withCode('CNA-NXT-PCS-C-1yr -500')
                            .withName('PAC for 500 NSX-T for PKS Licenses (per POD)')
                            .withSubscription('with 1yr Subscription')
                            .withProducts(new List<String>{
                                    'K0012-0ZPG2-Z8KUR-A3M02-19NHN',
                                    'X1092-4ZMGK-G8VUH-AKN04-0DG0N'
                            })
                            .build()
                    )
                    .add(new TestCsvPACBuilder.PACWrp()
                            .withCode('CNA-NXT-ACS-C-1yr -500')
                            .withName('PAC for 500 NSX-T for PKS Licenses (per POD)')
                            .withSubscription('with 1yr Subscription')
                            .withProducts(new List<String>{
                                    'A0012-0ZPG2-Z8KUR-A3M02-19NHN',
                                    'A1092-4ZMGK-G8VUH-AKN04-0DG0N'
                            })
                            .build()
                    );
            Document d = builder.build();
            ApexPages.currentPage().getParameters().put('Id', d.Id);
            PACDataLoaderController ctrl = new PACDataLoaderController();
            System.debug(ctrl.pacProvider.pacsToInsert);
            ctrl.saveRecords();
            System.assertEquals(4, [SELECT id FROM PAC__c].size());
            System.assertEquals(2, [SELECT id FROM PAC__c WHERE Product__c = 'PCS'].size());
        }
    }
    @IsTest
    static void testControllerConstructor (){
        Map<Id, PAC__c> pacs = PACAllocatorTest.preparePACs();
        pacs.values()[0].Status__c = 'Assigned';
        pacs.values()[1].Status__c = 'Allocated';
        update pacs.values();
        Test.startTest();
        PACDataLoaderController ctrl = new PACDataLoaderController();
        Test.stopTest();
        System.assert(ctrl.inventoryChartLabels != null);
        System.assert(ctrl.inventoryChartValues != null);
        System.assert(ctrl.inventoryLength != null);
    }

    @IsTest
    static void testUnassign (){
        Map<Id, PAC__c> pacs = PACAllocatorTest.preparePACs();
        pacs.values()[0].Status__c = 'Assigned';
        pacs.values()[1].Status__c = 'Allocated';
        update pacs.values();
        Test.startTest();
        PACDataLoaderController ctrl = new PACDataLoaderController();
        ctrl.unassignAllocated();
        System.assertEquals(0, [SELECT Id FROM PAC__c WHERE Status__c = 'Allocated'].size());
        ctrl.unassignAssigned();
        System.assertEquals(0, [SELECT Id FROM PAC__c WHERE Status__c = 'Assigned'].size());
        ctrl.unassignAll();
        System.assertEquals(pacs.size(), [SELECT Id FROM PAC__c WHERE Status__c = 'Unassigned'].size());
        Test.stopTest();
    }

    @IsTest
    static void testDeletion (){
        Map<Id, PAC__c> pacs = PACAllocatorTest.preparePACs();
        Test.startTest();
        PACDataLoaderController ctrl = new PACDataLoaderController();
        ctrl.deletePACs();
        Test.stopTest();
        System.assert([SELECT Id FROM PAC__c].isEmpty());
    }
}