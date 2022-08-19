public with sharing class MaBVRechnungenBatch implements Database.Batchable<Id>, Iterable<Id>, Iterator<Id> {
    Integer counter = 0, max;
    List<Id> mabvRechnungOrStornoIds;
    Boolean storno;
    // How high to count to
    public MaBVRechnungenBatch(List<Id> mabvRechnungOrStornoIds, Boolean storno) {
        this.max = mabvRechnungOrStornoIds.size();
        this.mabvRechnungOrStornoIds = mabvRechnungOrStornoIds;
        this.storno = storno;
    }
    // Iterator to use
    public Iterator<Id> iterator() {
        return this;
    }
    // Get next MaBVRechnungMaster__c record in iterator
    public Id next() {
        return this.mabvRechnungOrStornoIds[counter++];
    }
    // Any more to do
    public Boolean hasNext() {
        return counter < max;
    }
    // Database.Batchable start method
    public Iterable<Id> start(Database.BatchableContext context) {
        return this;
    }
    // Database.Batchable execute method
    public void execute(Database.BatchableContext context, Id[] scope) {
        System.debug('upserting: ' + scope.size());
        MaBVRechnungPdf.sendRechnungenAsPdf(scope, storno);
    }
    // Database.Batchable finish method
    public void finish(Database.BatchableContext context) {

    }
}