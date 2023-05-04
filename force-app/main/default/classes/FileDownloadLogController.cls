public without sharing class FileDownloadLogController {

    @AuraEnabled
    public static void createFileDownloadLog(Id immobilenDMSDateiId) {
        ImmobilienDmsDatei__c idd = [SELECT Immobilie__c, Name FROM ImmobilienDMSDatei__c WHERE Id = :immobilenDMSDateiId];
        User use =[select Id, ContactId, Contact.AccountId FROM User where id= :UserInfo.getUserId()];
        FileDownloadLog__c fdl =new FileDownloadLog__c();
        fdl.Contact__c = use.contactId;
        fdl.Account__c = use.Contact.AccountId;
        fdl.Property__c = idd.Immobilie__c;
        fdl.Name = idd.Name;
        insert fdl;
    }
}