@isTest
public class ApprovalItemController_Test {

    /* Test Methods */

    static testMethod void testNullApprovalProcess() {
        Id quoteId = getQuoteId();

        ApprovalItemController approvalComponent = new ApprovalItemController();
        approvalComponent.relatedRecordId = quoteId;

        System.assertEquals(0, approvalComponent.getAllApprovalStep().size(), 'Approval steps dectected when not expected');
    }

    static testMethod void testPopulatedApprovalProcess() {
        Id quoteId = getQuoteId();
        createApprovalProcess(quoteId);

        ApprovalItemController approvalComponent = new ApprovalItemController();
        approvalComponent.relatedRecordId = quoteId;

        System.assertNotEquals(0, approvalComponent.getAllApprovalStep().size(), 'Approval steps not found');
    }

    /* Helper Methods */

    private static Id getQuoteId() {
        Account acc = TestDataFactory.createAccount(true);
        Opportunity opp = TestDataFactory.createOpportunity(acc.Id, true);
        Contact ctt = TestDataFactory.createContact(acc.Id, true);
        zqu__Quote__c quote = ZTestFactory.makeQuote(opp, ctt);

        return quote.Id;
    }

    private static void createApprovalProcess(Id quoteId) {
        Approval.ProcessSubmitRequest approvalProcess = new Approval.ProcessSubmitRequest();
        approvalProcess.setObjectId(quoteId);
        Approval.ProcessResult result = Approval.Process(approvalProcess);
    }
}