public with sharing class MaBVRechnungTriggerHandler implements ITrigger {

    Map<Id,Opportunity> mapOpportunitiesByIds = new Map<Id,Opportunity>();

    Map<Id, MaBVRechnungMaster__c> masterByIds = new Map<Id, MaBVRechnungMaster__c>();
    Set<Id> rateIds = new Set<Id>();
    Set<Id> opportunityIds = new Set<Id>();
    
    public MaBVRechnungTriggerHandler() {

    }

    public void bulkBefore() {
        
    }

    public void bulkAfter() {
        List<MaBVRechnung__c> rechnungen;
        if(Trigger.isDelete) {
            rechnungen = (List<MaBVRechnung__c>) Trigger.old;
        } else {
            rechnungen = (List<MaBVRechnung__c>) Trigger.new;
        }
        Set<Id> masterIds = new Set<Id>();
        for(MaBVRechnung__c rechnung : rechnungen) {
            masterIds.add(rechnung.MaBVRechnungMaster__c);
        }

        masterByIds = new Map<Id, MaBVRechnungMaster__c>([SELECT Id, MaBVRate__c, Opportunity__c FROM MaBVRechnungMaster__c WHERE Id IN :masterIds]);
    }

    public void beforeInsert(SObject so) {
        
    }

    public void beforeUpdate(SObject oldSo, SObject so) {
        
    }

    public void beforeDelete(SObject so) {

    }

    public void afterInsert(SObject so) {
        MaBVRechnung__c rechnung = (MaBVRechnung__c) so;
        MaBVRechnungMaster__c master = masterByIds.get(rechnung.MaBVRechnungMaster__c);
        rateIds.add(master.MaBVRate__c);
        opportunityIds.add(master.Opportunity__c);
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        MaBVRechnung__c rechnung = (MaBVRechnung__c) so;
        MaBVRechnungMaster__c master = masterByIds.get(rechnung.MaBVRechnungMaster__c);
        rateIds.add(master.MaBVRate__c);
        opportunityIds.add(master.Opportunity__c);
    }

    public void afterDelete(SObject so) {
        MaBVRechnung__c rechnung = (MaBVRechnung__c) so;
        MaBVRechnungMaster__c master = masterByIds.get(rechnung.MaBVRechnungMaster__c);
        rateIds.add(master.MaBVRate__c);
        opportunityIds.add(master.Opportunity__c);
    }

    public void andFinally() {
        if(!rateIds.isEmpty() && Limits.getQueueableJobs() < Limits.getLimitQueueableJobs()) {
            System.enqueueJob(new AggregateRatePaymentDataQueueable(rateIds, opportunityIds));
        }
    }
}
