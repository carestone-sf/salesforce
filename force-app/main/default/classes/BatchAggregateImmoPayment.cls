public with sharing class BatchAggregateImmoPayment implements Database.Batchable<SObject>, Schedulable {
    

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Property__c WHERE Id IN (SELECT Immobilie__c FROM Opportunity)]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        Map<Id,SObject> scopeMap = new Map<Id, SObject>(scope);
        AggregateVkcZahlungPaymentDataQueueable.updateImmobilien(scopeMap.keySet());
    }

    public void finish(Database.BatchableContext bc) {

    }
    
    public void execute(System.SchedulableContext ctx) {
        Database.executeBatch(new BatchAggregateImmoPayment());
    }
}
