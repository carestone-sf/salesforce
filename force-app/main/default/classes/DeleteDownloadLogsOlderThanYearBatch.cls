public with sharing class DeleteDownloadLogsOlderThanYearBatch implements Database.Batchable<sObject>{
    @TestVisible
    static final Date CURRENT_DATE_MINUS_YEAR = Date.newInstance(Date.today().year()-1,Date.today().month(),Date.today().day());

    public DeleteDownloadLogsOlderThanYearBatch(){

       
    }

    public List<FileDownloadLog__c> start(Database.BatchableContext BC){
        system.debug('----------started-----------');
        return [
            SELECT id 
            FROM FileDownloadLog__c 
            WHERE createdDate <: CURRENT_DATE_MINUS_YEAR
        ];
    }

    public void execute(Database.BatchableContext BC, List<FileDownloadLog__c> scope){
       delete scope;
    }

    public void finish(Database.BatchableContext BC){
        system.debug('----------finished-----------');
    }
}