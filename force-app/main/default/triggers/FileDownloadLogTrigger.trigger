trigger FileDownloadLogTrigger on FileDownloadLog__c (before insert) {
    new FileDownloadLogTriggerHandler().run(); 
}