global class MaBVMahnungenBatch implements Database.Batchable<Id>, Iterable<Id>, Iterator<Id> {
    Integer counter = 0, max;
    List<Id> mabvRechnungenIds;
    // How high to count to
    public MaBVMahnungenBatch(List<Id> mabvRechnungenIds) {
        this.max = mabvRechnungenIds.size();
        this.mabvRechnungenIds = mabvRechnungenIds;
    }
    // Iterator to use
    public Iterator<Id> iterator() {
        return this;
    }
    // Get next MaBVRechnungMaster__c record in iterator
    public Id next() {
        return this.mabvRechnungenIds[counter++];
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
        MaBVMahnungPdf.sendMahnungenAsPdf(mabvRechnungenIds);
    }
    // Database.Batchable finish method
    public void finish(Database.BatchableContext context) {

    }
}