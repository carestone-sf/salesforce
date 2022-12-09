trigger EmailMessage on EmailMessage (before insert, after insert) {
    TriggerFactory.createHandler(EmailMessage.getSObjectType());
}