trigger ZahlungTrigger on Zahlung__c (before insert, before update, after insert, after update, after delete) {
    TriggerFactory.createHandler(Zahlung__c.getSObjectType());
}