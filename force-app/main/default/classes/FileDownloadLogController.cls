public without sharing class FileDownloadLogController {
    public FileDownloadLogController() {

    }
    @AuraEnabled
    public static void createFileDownloadLog(string immobilenDMSDateiId ){
        User use =[select id,ContactId FROM User where id= :UserInfo.getUserId()];
        FileDownloadLog__c fdl =new FileDownloadLog__c();
        fdl.Contact__c =use.contactId;
        fdl.ImmobilienDMSDatei__c =immobilenDMSDateiId;
        insert fdl;
    }
    // public static void createFileDownloadLog(string contactId, string immobilenDMSDateiId ){
    //     FileDownloadLog__c fdl =new FileDownloadLog__c();
    //     fdl.Contact__c =contactId;
    //     fdl.ImmobilienDMSDatei__c =immobilenDMSDateiId;
    //     insert fdl;
    // }
}