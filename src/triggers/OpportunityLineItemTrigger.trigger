trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, after insert, after delete) {
    new OpportunityLineItemTriggerHandler().run();
}