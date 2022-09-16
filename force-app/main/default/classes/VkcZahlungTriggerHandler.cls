public without sharing class VkcZahlungTriggerHandler implements ITrigger {
    
    Set<Id> opportunityIds = new Set<Id>();

    public VkcZahlungTriggerHandler() {

    }

    public void bulkBefore() {
        
    }

    public void bulkAfter() {
        
    }

    public void beforeInsert(SObject so) {
        
    }

    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }

    public void beforeDelete(SObject so) {

    }

    public void afterInsert(SObject so) {
        VkcZahlung__c zahlung = (VkcZahlung__c) so;
        opportunityIds.add(zahlung.Verkaufschance__c);
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        VkcZahlung__c zahlung = (VkcZahlung__c) so;
        opportunityIds.add(zahlung.Verkaufschance__c);
    }

    public void afterDelete(SObject so) {
        VkcZahlung__c zahlung = (VkcZahlung__c) so;
        opportunityIds.add(zahlung.Verkaufschance__c);
    }

    public void andFinally() {
        if(!opportunityIds.isEmpty() && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(new AggregateVkcZahlungPaymentDataQueueable(opportunityIds));
        }
    }
}
