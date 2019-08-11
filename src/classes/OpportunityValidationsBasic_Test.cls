@isTest
public class OpportunityValidationsBasic_Test {

    /* Test Methods */

    static void SetupCustomSettingData(){
        TestDataUtil.dataValueMapCSData();
    }
    
    static testMethod void OP031_non_bookings_user_CAN_NOT_move_opp_out_of_booked_stage() {
        SetupCustomSettingData();
        Profile userProfile = TestDataFactory.createProfile('Pivotal - Business Operations');
        User bizOpsUser = TestDataFactory.createUser(userProfile.Id, true);
        Opportunity opp = generateBookedOpportunity(bizOpsUser.Id);

        Test.startTest();

        System.runAs(bizOpsUser) {
            try {
                opp.StageName = 'Pipeline';
                update opp;
                System.assert(false, 'Only a Bookings User can move an Opportunity out of Booked status');
            } catch (DmlException ex) {
                System.assert(ex.getMessage().contains('[OP031]'));
            }
        }

        Test.stopTest();
    }

    static testMethod void OP031_bookings_user_can_move_opp_out_of_booked_stage() {
        SetupCustomSettingData();
        Profile userProfile = TestDataFactory.createProfile('Pivotal - Business Operations');
        User bookingUser = TestDataFactory.createUser(userProfile.Id, false);
        bookingUser.Bookings_User__c = true;
        insert bookingUser;

        Opportunity opp = generateBookedOpportunity(bookingUser.Id);

        Test.startTest();

        System.runAs(bookingUser) {
            opp.StageName = 'Pipeline';
            update opp;
        }

        Test.stopTest();

        Opportunity updatedOpportunity = [SELECT Id, IsWon FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(false, updatedOpportunity.IsWon, 'Opportunity IsWon not updated');
    }

    static testMethod void OP042_non_bookings_user_CAN_NOT_update_booked_opp() {
        SetupCustomSettingData();
        Profile userProfile = TestDataFactory.createProfile('Pivotal - Business Operations');
        User bizOpsUser = TestDataFactory.createUser(userProfile.Id, true);

        Opportunity opp = generateBookedOpportunity(bizOpsUser.Id);

        Test.startTest();

        System.runAs(bizOpsUser) {
            try {
                opp.Amount = 2000;
                update opp;
                System.assert(false, 'Only a Bookings User can update the Ammount of a booked opp');
            } catch (DmlException ex) {
                System.assert(ex.getMessage().contains('[OP042]'));
            }

            try {
                opp.CloseDate = System.today() + 100;
                update opp;
                System.assert(false, 'Only a Bookings User can update the close date of a booked opp');
            } catch (DmlException ex) {
                System.assert(ex.getMessage().contains('[OP042]'));
            }
        }

        Test.stopTest();
    }

    static testMethod void OP042_bookings_user_can_update_booked_opp() {
        SetupCustomSettingData();
        Profile userProfile = TestDataFactory.createProfile('Pivotal - Business Operations');
        User bookingUser = TestDataFactory.createUser(userProfile.Id, false);
        bookingUser.Bookings_User__c = true;
        insert bookingUser;

        Opportunity opp = generateBookedOpportunity(bookingUser.Id);

        Test.startTest();

        System.runAs(bookingUser) {
            opp.Amount = 10000;
            opp.CloseDate = System.today() + 100;
            update opp;
        }

        Test.stopTest();

        Opportunity updatedOpportunity = [SELECT Id, Amount, CloseDate FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(10000, updatedOpportunity.Amount, 'Opportunity Amount not updated');
        System.assertEquals(System.today() + 100, updatedOpportunity.CloseDate, 'Opportunity Close Date not updated');
    }

       /* Private Methods */

    private static Opportunity generateBookedOpportunity(Id userId) {
        Account acc = TestDataFactory.createAccount(true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, false);
        opp.StageName = 'Booked';
        opp.OwnerId = userId;
        insert opp;

        return opp;
    }
}