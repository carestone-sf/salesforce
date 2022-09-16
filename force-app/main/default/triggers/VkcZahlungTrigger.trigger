trigger VkcZahlungTrigger on VKCZahlung__c (before insert, before update, after insert, after update) {
    TriggerFactory.createHandler(VKCZahlung__c.getSObjectType());
}