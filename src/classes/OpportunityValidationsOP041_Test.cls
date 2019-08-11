@isTest
public class OpportunityValidationsOP041_Test {
    
    /* Test Methods */
    
    static void SetupCustomSettingData(){
        TestDataUtil.dataValueMapCSData();
    }    
    
    static testMethod void non_bizopps_CAN_NOT_alter_forecast_status_close_date_amount_on_renewal_opps() {
        SetupCustomSettingData();
        Profile userProfile = TestDataFactory.createProfile('Pivotal - Sales Rep');
        User salesUser = TestDataFactory.createUser(userProfile.Id, true);
        Opportunity opp = setupTestOpportunity(salesUser.Id);

        Test.startTest();

        System.runAs(salesUser) {
            try {
                opp.Forecast_Status__c = 'Pipeline';
                update opp;
                System.assert(false, 'Only Business Operations Users should be able to change Renewal Opportunity Forecast Status out of commit');
            } catch (DmlException ex) {
                System.assert(ex.getMessage().contains('[OP041]'));
            }

            try {
                opp.CloseDate = System.today();
                update opp;
                System.assert(false, 'Only Business Operations Users should be able to change Renewal Opportunity Close Date');
            } catch (DmlException ex) {
                System.assert(ex.getMessage().contains('[OP041]'));
            }

            try {
                opp.Amount = 1;
                update opp;
                System.assert(false, 'Only Business Operations Users should be able to change Renewal Opportunity Ammounts');
            } catch (DmlException ex) {
                System.assert(ex.getMessage().contains('[OP041]'));
            }
        }

        Test.stopTest();
    }

    static testMethod void non_bizopps_can_alter_other_fields_on_renewal_opps() {
        SetupCustomSettingData();
        Profile userProfile = TestDataFactory.createProfile('Pivotal - Sales Rep');
        User salesUser = TestDataFactory.createUser(userProfile.Id, true);
        Opportunity opp = setupTestOpportunity(salesUser.Id);

        Test.startTest();

        System.runAs(salesUser) {
            try {
                opp.Next_Step__c = 'Make Money!';
                update opp;
            } catch (DmlException ex) {
                System.assert(false, 'Non Biz Opps users should be able to change non important fields on Renewal Opportunities');
            }
        }

        Test.stopTest();
    }

    static testMethod void non_bizopps_with_renewal_booking_flag_can_alter_forecast_status_on_renewal_opp() {
        SetupCustomSettingData();
        Profile userProfile = TestDataFactory.createProfile('Pivotal - Sales Rep');

        User salesUser = TestDataFactory.createUser(userProfile.Id, false);
        salesUser.Renewal_Booking__c = true;
        insert salesUser;

        Opportunity opp = setupTestOpportunity(salesUser.Id);

        Test.startTest();

        System.runAs(salesUser) {
            try {
                opp.Forecast_Status__c = 'Pipeline';
                update opp;
            } catch (DmlException ex) {
                System.assert(false, 'Non Biz Opps users should be able to change non important fields on Renewal Opportunities');
            }
        }

        Test.stopTest();
    }

    static testMethod void bizopps_can_alter_commit_on_renewal_opps() {
        SetupCustomSettingData();
        Profile userProfile = TestDataFactory.createProfile('Pivotal - Business Operations');
        User bizOpsUser = TestDataFactory.createUser(userProfile.Id, true);
        Opportunity opp = setupTestOpportunity(bizOpsUser.Id);

        Test.startTest();

        System.runAs(bizOpsUser) {
            opp.Forecast_Status__c = 'Pipeline';
            update opp;
        }

        Test.stopTest();

        Opportunity updatedOpportunity = [SELECT Id, Forecast_Status__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Pipeline', updatedOpportunity.Forecast_Status__c, 'Business Operations Users should be able to change Renewal Opportunity Forecast Status out of commit');
    }

    static testMethod void sysAdmin_can_alter_commit_on_renewal_opps() {
        SetupCustomSettingData();
        Profile userProfile = TestDataFactory.createProfile('System Administrator');
        User sysAdminUser = TestDataFactory.createUser(userProfile.Id, true);
        Opportunity opp = setupTestOpportunity(sysAdminUser.Id);

        Test.startTest();

        System.runAs(sysAdminUser) {
            opp.Forecast_Status__c = 'Pipeline';
            update opp;
        }

        Test.stopTest();

        Opportunity updatedOpportunity = [SELECT Id, Forecast_Status__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Pipeline', updatedOpportunity.Forecast_Status__c, 'System Administrators should be able to change Renewal Opportunity Forecast Status out of commit');
    }

    private static Opportunity setupTestOpportunity(Id userId) {
        Account acc = TestDataFactory.createAccount(true);

        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, false);
        opp.Type = 'Renew Subscription';
        opp.StageName = 'Business Validation';
        opp.Forecast_Status__c = 'Commit';
        opp.PCF_Consumption_Milestone__c = 'test text';
        opp.PCF_Consumption_Validated_By_Tech_Lead__c = 'Yes';
        opp.The_Play_Tracker_Link__c = 'test text';
        opp.Play_Validated_by_PA_Management__c = 'Yes';
        opp.OwnerId = userId;
        insert opp;

        Product2 product = TestDataFactory.createProduct2(true);

        PricebookEntry pbEntry = TestDataFactory.createPricebookEntry(product.Id, 1, true);

        OpportunityLineItem oppLine = TestDataFactory.createOpportunityLineItem(opp.Id, pbEntry.Id, 20, true);

        opp.StageName = 'Prospecting';
        return opp;
    }
}