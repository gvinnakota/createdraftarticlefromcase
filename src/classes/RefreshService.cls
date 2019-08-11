public class RefreshService {
    public static void refresh() {
        List<String> users = new List<String>{'TA Sales Rep','TA Business Operations','TA SysAdmin'};
        refresh(users);
    }

    public static void refresh(List<String> users) {
        activateAndSetPasswords(users);
        fixTaxRegions();
        maskContactEmails();
        maskLeadEmails();
        maskQuoteEmails();
    }

    @future
    private static void activateAndSetPasswords(List<String> users) {
        for(User u : [SELECT Id FROM User WHERE Name IN :users]) {
            u.isActive = true;
            update u;
            System.setPassword(u.Id, 'zK1LP9jL7xgI');
        }
    }

    private static void fixTaxRegions() {
        List<Company_Code__c> companyCodes = [SELECT Id, Tax_Region__c FROM Company_Code__c];

        for(Company_Code__c code : companyCodes) {
            if (!code.Tax_Region__c.contains('TEST-')) {
                code.Tax_Region__c = 'TEST-' + code.Tax_Region__c;
            }
        }

        update companyCodes;
    }

    private static void maskContactEmails() {
        ContactEmailMasker emailMasker = new ContactEmailMasker();
        Database.executeBatch(emailMasker);
    }

    private static void maskLeadEmails() {
        LeadEmailMasker emailMasker = new LeadEmailMasker();
        Database.executeBatch(emailMasker);
    }

    private static void maskQuoteEmails() {
        ZQuoteEmailMasker emailMasker = new ZQuoteEmailMasker();
        Database.executeBatch(emailMasker);
    }
}