public with sharing class UserActivitySummaryBatch implements Database.Batchable<sObject> {
    static final DateTime FIRST_DAY_OF_CURRENT_MONTH = DateTime.newInstance(Date.today().year(), Date.today().month(), 1);
    List<id> contactsIds;
    public UserActivitySummaryBatch(List<id> ContactsIds) {
        this.contactsIds = contactsIds;
    }
    public UserActivitySummaryBatch() {
        this.contactsIds = null;
    }
    public List<contact> start(Database.BatchableContext bc) {
        system.debug('----------started-----------');
        if (contactsIds != null) {
            return [SELECT Id, AccountId, Account.OwnerId FROM Contact WHERE Id = :this.contactsIds];
        } else {
            return [SELECT Id, AccountId, Account.OwnerId FROM Contact WHERE HatVPZugang__c = true];
        }
    }
    public void execute(Database.BatchableContext BC, list<contact> scope) {

        Map<id, contact> contacts = new Map<Id, contact>(scope);
        Set<Id> accIds = new Set<Id>();
        System.Debug('contacts: ' + contacts.keyset());
        List<Id> contactIds = new List<Id>();
        for(Contact con:scope) {
            contactIds.add(con.Id);
            accIds.add(con.AccountId);
        }
        //map that contains contactid and activity summary id related to that contact
        Map<id, id> contactsIdsWithActivitySummary = new Map<id, id>();
        //get all existsing activity summaries for contacts(scope) that matches criteria:
        //* month = currentMonth AND year=currentYear
        Map<id, Activity_Summary__c> existingSummaries = new Map<id, Activity_Summary__c>(
        [
                SELECT id, number_of_logins__c, Contact__c
                FROM Activity_Summary__c
                WHERE Contact__c = :contacts.keySet()
                AND month__c = :String.valueOf(Date.today().month())
                AND year__c = :String.valueOf(Date.today().year())
        ]);

        //fill map with contact Id and related activity Summary
        for (Activity_Summary__c summary : existingSummaries.values()) {
            contactsIdsWithActivitySummary.put(summary.Contact__c, summary.id);
        }

        Map<Id, List<FileDownloadLog__c>> contactToFdlsMap = new Map<Id, List<FileDownloadLog__c>>();
        for(FileDownloadLog__c fdl:[SELECT Contact__c FROM FileDownloadLog__c WHERE Contact__c IN :contactIds AND CreatedDate > :FIRST_DAY_OF_CURRENT_MONTH]) {
            List<FileDownloadLog__c> fdls = contactToFdlsMap.get(fdl.Contact__c);
            if(fdls == null) {
                fdls = new List<FileDownloadLog__c>();
            }
            fdls.add(fdl);
            contactToFdlsMap.put(fdl.Contact__c, fdls);
        }

        Id interessentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Interessent').getRecordTypeId();
        Id kundeRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Kunde').getRecordTypeId();
        Map<Id, List<Contact>> accountToContactsMap = new Map<Id, List<Contact>>();
        for(Contact con:[SELECT Id, AccountId FROM Contact WHERE AccountId IN :accIds AND CreatedDate > :FIRST_DAY_OF_CURRENT_MONTH AND (RecordTypeId = :interessentRecordTypeId OR RecordTypeId = :kundeRecordTypeId)]) {
            List<Contact> cons = accountToContactsMap.get(con.AccountId);
            if(cons == null) {
                cons = new List<Contact>();
            }
            cons.add(con);
            accountToContactsMap.put(con.AccountId, cons);
        }

        List<Activity_Summary__c> summariesToUpsert = new List<Activity_Summary__c>();
        for (Contact con : scope) {

            integer numberOfNewProspects = accountToContactsMap.get(con.AccountId)?.size();
            if(numberOfNewProspects == null) {
                numberOfNewProspects = 0;
            }

            integer numberOfDownloads = contactToFdlsMap.get(con.Id)?.size();
            if(numberOfDownloads == null) {
                numberOfDownloads = 0;
            }

            Id summaryId = contactsIdsWithActivitySummary.get(con.id);
            if (summaryId != null) {
                Activity_Summary__c summary = existingSummaries.get(summaryId);
                summary.number_of_new_prospects__c = numberOfNewProspects;
                summary.number_of_downloads__c = numberOfDownloads;
                summariesToUpsert.add(summary);
            } else {
                Activity_Summary__c newSummary = new Activity_summary__c();
                newSummary.year__c = String.valueOf(Date.Today().Year());
                newSummary.month__c = String.valueOf(date.today().Month());
                newSummary.number_of_new_prospects__c = numberOfNewProspects;
                newSummary.number_of_downloads__c = numberOfDownloads;
                newSummary.Contact__c = con.Id;
                newSummary.Account__c = con.AccountId;
                newSummary.Maklerbetreuer__c = con.Account.OwnerId;
                summariesToUpsert.add(newSummary);
            }
        }
        upsert summariesToUpsert;
    }
    public void finish(Database.BatchableContext BC) {
        system.debug('----------finished-----------');
    }
}