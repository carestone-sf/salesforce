public with sharing class FileDownloadLogTriggerHandler extends TriggerHandler {
    @testVisible
    private static final string LIMIT_ERROR_MESSAGE = System.label.FileDownloadLogLimitErrorMessage;
    private static final integer  FILE_DOWNLOAD_LOG_RECORDS_LIMIT=100000;
    @TestVisible
    private static final integer  FILE_DOWNLOAD_LOG_RECORDS_LIMIT_TEST=4;
    private integer getRecordsLimit{
        get{
            if(Test.isRunningTest()){
                return FILE_DOWNLOAD_LOG_RECORDS_LIMIT_TEST;
            }else{
                return FILE_DOWNLOAD_LOG_RECORDS_LIMIT;
            }
        }
    }
    private list<FileDownloadLog__c> newFileDownloadlogList;
    public FileDownloadLogTriggerHandler() {
        this.newFileDownloadlogList =(list< FileDownloadLog__c>) Trigger.new;
    }

    public override void beforeInsert(){
        this.prohibitRecordInsertionIfIsTooMuchFileDownloadLogRecords();
    }

    public void prohibitRecordInsertionIfIsTooMuchFileDownloadLogRecords(){
        integer FileDownloadLogRecordsCount=Integer.valueOf([
            SELECT count(id) quantity 
            FROM FileDownloadLog__c
        ][0].get('quantity'));

        for(FiLeDownloadLog__c log :newFileDownloadlogList){
            if(FileDownloadLogRecordsCount+newFileDownloadlogList.size()>getRecordsLimit){
                log.addError(FileDownloadLogTriggerHandler.LIMIT_ERROR_MESSAGE);
            }
        }

    }
}