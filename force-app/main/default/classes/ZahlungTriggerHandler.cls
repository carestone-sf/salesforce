public without sharing class ZahlungTriggerHandler implements ITrigger {
    
    
    Map<Id, MaBVRechnung__c> rechnungenByIds = new Map<Id, MaBVRechnung__c>();
    Set<Id> rateIds = new Set<Id>();
    Set<Id> opportunityIds = new Set<Id>();
    
    public ZahlungTriggerHandler() {

    }

    public void bulkBefore() {
        
    }

    public void bulkAfter() {
        List<Zahlung__c> zahlungen;
        if(Trigger.isDelete) {
            zahlungen = (List<Zahlung__c>) Trigger.old;
        } else {
            zahlungen = (List<Zahlung__c>) Trigger.new;
        }
        Set<Id> rechnungIds = new Set<Id>();
        for(Zahlung__c zahlung : zahlungen) {
            rechnungIds.add(zahlung.MaBVRechnung__c);
        }

        rechnungenByIds = new Map<Id, MaBVRechnung__c>([SELECT Id, MaBVRechnungMaster__r.MaBVRate__c, MaBVRechnungMaster__r.Opportunity__c FROM MaBVRechnung__c WHERE Id IN :rechnungIds]);
    }

    public void beforeInsert(SObject so) {
        
    }

    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }

    public void beforeDelete(SObject so) {

    }

    public void afterInsert(SObject so) {
        Zahlung__c zahlung = (Zahlung__c) so;
        MaBVRechnung__c rechnung = rechnungenByIds.get(zahlung.MaBVRechnung__c);
        rateIds.add(rechnung.MaBVRechnungMaster__r.MaBVRate__c);
        opportunityIds.add(rechnung.MaBVRechnungMaster__r.Opportunity__c);
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        Zahlung__c zahlung = (Zahlung__c) so;
        MaBVRechnung__c rechnung = rechnungenByIds.get(zahlung.MaBVRechnung__c);
        rateIds.add(rechnung.MaBVRechnungMaster__r.MaBVRate__c);
        opportunityIds.add(rechnung.MaBVRechnungMaster__r.Opportunity__c);
    }

    public void afterDelete(SObject so) {
        Zahlung__c zahlung = (Zahlung__c) so;
        MaBVRechnung__c rechnung = rechnungenByIds.get(zahlung.MaBVRechnung__c);
        rateIds.add(rechnung.MaBVRechnungMaster__r.MaBVRate__c);
        opportunityIds.add(rechnung.MaBVRechnungMaster__r.Opportunity__c);
    }

    public void andFinally() {
        if(!rateIds.isEmpty() && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(new AggregateRatePaymentDataQueueable(rateIds, opportunityIds));
        }
    }
}
