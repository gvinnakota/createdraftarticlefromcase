trigger TaskTrigger on Task (before insert,after insert ) {
    new TaskTriggerHandler().run();
}