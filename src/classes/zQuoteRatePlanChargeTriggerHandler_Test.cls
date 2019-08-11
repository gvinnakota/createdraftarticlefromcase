@IsTest
public with sharing class zQuoteRatePlanChargeTriggerHandler_Test {

    private static Account acc;
    private static Contact ctt;
    private static Opportunity opp;

    private static zqu__Quote__c testQuote;
    private static zqu__QuoteAmendment__c quoteAmend;
    private static zqu__ZProduct__c zProd;
    private static zqu__ProductRatePlan__c prp;
    private static zqu__ProductRatePlanCharge__c prpc;
    private static zqu__QuoteRatePlan__c quoteRatePlan;
    private static User u;

    static void createData() {
        TestDataUtil.dataValueMapCSData();
        u = TestUtils.createUser('testLaunchpad', TestUtils.PROFILE_SYSTEM_ADMINISTRATOR, true);
        acc = TestDataFactory.createAccount(true);
        ctt = TestDataFactory.createContact(acc.Id, true);
        opp = TestDataFactory.createOpportunity(acc.Id, true);
        testQuote = TestDataFactory.makeQuote(opp, ctt);
        quoteAmend = ZTestFactory.makeQuoteAmendment(testQuote);
        zProd = TestDataFactory.makeProduct('Test App Suite', 'SSS-12123');
        prp = TestDataFactory.makeProductRatePlan(zProd.Id, 'Annual Rate Plan');
        prpc = ZTestFactory.makeProductRatePlanCharge(prp.Id, 'One-Time', 'Per Unit Pricing');
        quoteRatePlan = TestDataFactory.makeQuoteRatePlan(testQuote, quoteAmend);
        BOE_Settings__c boe = new BOE_Settings__c();
        boe.T_E_Rate__c = 0.15;
        boe.CSC_on__c = true;
        boe.Name = 'Default Organization Level Value';
        insert boe;

    }

//    @IsTest
//    static void test01() {
//        User u = TestUtils.findUser('testLaunchpad');
//        System.runAs(u) {
//            zqu__Quote__c quote = new zqu__Quote__c();
//            insert quote;
//            zqu__QuoteAmendment__c qAm = new zqu__QuoteAmendment__c(
//                    zqu__Quote__c = quote.Id
//            );
//            insert qAm;
//            zqu__QuoteRatePlan__c qrp = new zqu__QuoteRatePlan__c(
//                    zqu__QuoteAmendment__c = qAm.Id
//            );
//            insert qrp;
//            zqu__QuoteRatePlanCharge__c qrpc = new zqu__QuoteRatePlanCharge__c(
//                    zqu__PreviewedTCV__c = 0,
//                    zqu__MRR__c = 0,
//                    MRR_USD__c = '0',
//                    zqu__QuoteRatePlan__c = qrp.Id
//            );
//            insert qrpc;
//        }
//    }

    @IsTest
    static void testListedPrice() {
        createData();
        System.runAs(u) {
            List<Role__c> roles = TestRolesBuilder.getTestRoles(3);
            insert roles;
            insert TestRoleToPrpcMapBuilder.assignRolesToPrpc(prpc.Id, roles);

            Test.startTest();
            zqu__QuoteRatePlanCharge__c quoteRatePlancCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
            Test.stopTest();

            List<Role_Instance__c> roleList =[
                SELECT List_Price__c FROM Role_Instance__c
                WHERE Quote_Rate_Plan_Charge__c=:quoteRatePlancCharge.Id];
            for (Role_Instance__c role : roleList) {
                System.assertEquals(0, role.List_Price__c);
                role.Role_Quantity__c = 1;
                role.Hours_Per_Role__c = 1;
            }
            update roleList;

            System.assertEquals('330.00', [SELECT Listed_Price__c FROM zqu__QuoteRatePlanCharge__c
            WHERE Id=:quoteRatePlancCharge.Id].Listed_Price__c);
        }
    }

    @IsTest
    static void testQRPCDeletion() {
        createData();
        System.runAs(u) {
            List<Role__c> roles = TestRolesBuilder.getTestRoles(3);
            insert roles;
            insert TestRoleToPrpcMapBuilder.assignRolesToPrpc(prpc.Id, roles);

            Test.startTest();
            zqu__QuoteRatePlanCharge__c quoteRatePlancCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
            Test.stopTest();

            List<Role_Instance__c> roleList =[
                SELECT List_Price__c FROM Role_Instance__c
                WHERE Quote_Rate_Plan_Charge__c=:quoteRatePlancCharge.Id];
            for (Role_Instance__c role : roleList) {
                System.assertEquals(0, role.List_Price__c);
                role.Role_Quantity__c = 1;
                role.Hours_Per_Role__c = 1;
            }
            update roleList;

            Id qrpcId = quoteRatePlancCharge.Id;
            delete quoteRatePlancCharge;

            System.assertEquals(0, [SELECT Id FROM Role_Instance__c WHERE Quote_Rate_Plan_Charge__c = :qrpcId].size());
        }
    }

    @IsTest
    static void testRoleInstancesNum() {
        createData();
        System.runAs(u) {
            List<Role__c> roles = TestRolesBuilder.getTestRoles(5);
            insert roles;
            List<Role_to_PRPC_Map__c> mappings = TestRoleToPrpcMapBuilder.assignRolesToPrpc(prpc.Id, new List<Role__c> {
                roles[0], roles[3], roles[4]
            });
            mappings[2].Status__c = RoleHelper.STATUS_ROLE_MAPPING_INACTIVE;
            insert mappings;

            Test.startTest();
            zqu__QuoteRatePlanCharge__c quoteRatePlancCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
            Test.stopTest();

            System.assertEquals(2, [SELECT Id FROM Role_Instance__c
            WHERE Quote_Rate_Plan_Charge__c=:quoteRatePlancCharge.Id].size());
        }
    }
    @IsTest
    static void testFeeForExpenses() {
        createData();
        System.runAs(u) {
            List<Role__c> roles = TestRolesBuilder.getTestRoles(5);
            insert roles;
            List<Role_to_PRPC_Map__c> mappings = TestRoleToPrpcMapBuilder.assignRolesToPrpc(prpc.Id, new List<Role__c> {
                roles[0], roles[3], roles[4]
            });
            mappings[2].Status__c = RoleHelper.STATUS_ROLE_MAPPING_INACTIVE;
            insert mappings;
            quoteRatePlan.SOW_Type__c = 'Daily with T&E';
            update quoteRatePlan;

            Test.startTest();
            zqu__QuoteRatePlanCharge__c quoteRatePlancCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
            zqu__QuoteRatePlanCharge__c quoteRatePlancCharge2 = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
            quoteRatePlancCharge2.Name = 'Fee for Expenses';

            update quoteRatePlancCharge2;
            update quoteRatePlancCharge;
            Test.stopTest();

            quoteRatePlancCharge = [SELECT zqu__Total__c FROM zqu__QuoteRatePlanCharge__c WHERE Id = :quoteRatePlancCharge.Id];
            System.assertEquals(0.15 * quoteRatePlancCharge.zqu__Total__c, [SELECT Id, zqu__EffectivePrice__c FROM zqu__QuoteRatePlanCharge__c WHERE Id = :quoteRatePlancCharge2.Id].zqu__EffectivePrice__c);
            System.assertEquals(2, [SELECT Id FROM Role_Instance__c
            WHERE Quote_Rate_Plan_Charge__c=:quoteRatePlancCharge.Id].size());
        }
    }

    @IsTest
    static void testListedPriceWithConversionRate() {
        createData();
        System.runAs(u) {
            Decimal convRate = 4;
            Decimal countryMultiplier = 3;
            Date today = Date.today();
            insert new Conversion_Rate__c(
                CurrencyIsoCode = testQuote.zqu__Currency__c,
                Conversion_Rate__c = convRate,
                Start_Date__c = today,
                End_Date__c = today
            );
            insert new Country_Uplift__c(
                Country_Code__c = ctt.MailingCountryCode,
                Uplift_Multiplier__c = countryMultiplier,
                Service_Multiplier__c = countryMultiplier
            );
            List<Role__c> roles = TestRolesBuilder.getTestRoles(3);
            insert roles;
            insert TestRoleToPrpcMapBuilder.assignRolesToPrpc(prpc.Id, roles);

            Test.startTest();
            zqu__QuoteRatePlanCharge__c quoteRatePlancCharge = ZTestFactory.makeQuoteRatePlanCharge(quoteRatePlan, prpc);
            Test.stopTest();

            System.debug('qrpc: ' + [SELECT Id, zqu__Total__c, zqu__EffectivePrice__c, Listed_Price__c FROM zqu__QuoteRatePlanCharge__c]);

            List<Role_Instance__c> roleList =[
                SELECT List_Price__c FROM Role_Instance__c
                WHERE Quote_Rate_Plan_Charge__c=:quoteRatePlancCharge.Id];
            for (Role_Instance__c role : roleList) {
                System.assertEquals(0, role.List_Price__c);
                role.Role_Quantity__c = 1;
                role.Hours_Per_Role__c = 1;
            }
            update roleList;

            zqu__QuoteRatePlanCharge__c qrpc = [
                SELECT zqu__Total__c, zqu__EffectivePrice__c, Listed_Price__c
                FROM zqu__QuoteRatePlanCharge__c
                WHERE Id=:quoteRatePlancCharge.Id];
            System.assertEquals(330 * convRate * countryMultiplier, qrpc.zqu__Total__c);
            System.assertEquals(330 * convRate * countryMultiplier, qrpc.zqu__EffectivePrice__c);
            System.assertEquals((330 * convRate * countryMultiplier).setScale(2).toPlainString(), qrpc.Listed_Price__c);
        }
    }
}