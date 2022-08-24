trigger ContentVersion on ContentVersion (before insert, after insert, before update, after update) {
    TriggerFactory.createHandler(ContentVersion.SObjectType);
}