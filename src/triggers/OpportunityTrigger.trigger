trigger OpportunityTrigger on Opportunity (before insert, before update, after update) {
    new OpportunityTriggerHandler().run();
}