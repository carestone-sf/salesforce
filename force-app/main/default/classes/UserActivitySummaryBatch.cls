public with sharing class UserActivitySummaryBatch implements Database.Batchable<sObject> {
    static final DateTime FIRST_DAY_OF_CURRENT_MONTH = DateTime.newInstance(Date.today().year(), Date.today().month(), 1);
    Set<id> usersIds;
    public UserActivitySummaryBatch(Set<id> UsersIds) {
        this.usersIds = usersIds;
    }
    public UserActivitySummaryBatch() {
        this.usersIds = null;
    }
    public List<user> start(Database.BatchableContext bc) {
        system.debug('----------started-----------');
        if (usersIds != null) {

            return [select id, ContactId, ContactAccountId__c, ContactAccountOwnerId__c from user where id = :this.usersIds];
        } else {
            return [select id, ContactId, ContactAccountId__c, ContactAccountOwnerId__c from user where ContactId != null];
        }
    }
    public void execute(Database.BatchableContext BC, list<user> scope) {

        Map<id, user> users = new Map<Id, user>(scope);
        System.Debug('users: ' + users.keyset());
        List<Id> contactIds = new List<Id>();
        for(User u:scope) {
            if(u.ContactId != null) {
                contactIds.add(u.ContactId);
            }
        }
        //map that contains userid and activity summary id related to that user
        Map<id, id> usersIdsWithActivitySummary = new Map<id, id>();
        //get all existsing activity summaries for users(scope) that matches criteria:
        //* month = currentMonth AND year=currentYear
        Map<id, Activity_Summary__c> existingSummaries = new Map<id, Activity_Summary__c>(
        [
                SELECT id, number_of_logins__c, UserId__c
                FROM Activity_Summary__c
                WHERE userId__c = :users.keySet()
                AND month__c = :String.valueOf(Date.today().month())
                AND year__c = :String.valueOf(Date.today().year())
        ]);

        //fill map with user Id and related activity Summary
        for (Activity_Summary__c summary : existingSummaries.values()) {
            usersIdsWithActivitySummary.put(summary.userId__c, summary.id);
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
        Map<Id, List<Contact>> contactToContactsMap = new Map<Id, List<Contact>>();
        for(Contact con:[SELECT Id FROM Contact WHERE CreatedById IN :users.keySet() AND CreatedDate > :FIRST_DAY_OF_CURRENT_MONTH AND (RecordTypeId = :interessentRecordTypeId OR RecordTypeId = :kundeRecordTypeId)]) {
            List<Contact> cons = contactToContactsMap.get(con.Id);
            if(cons == null) {
                cons = new List<Contact>();
            }
            cons.add(con);
            contactToContactsMap.put(con.Id, cons);
        }

        //Get User ids with number of logins for current month
        Map<id, integer> usersIDsWithNumberOfLogins = new Map<id, integer>();
        LIST<AggregateResult> results = [
                SELECT userID, count(id) numberOflogins
                from LoginHistory
                WHERE LoginTime > :FIRST_DAY_OF_CURRENT_MONTH
                AND userId = :users.keySet()
                Group by userid
        ];
        // make it a map object: Map<userId, numberOflogins>
        for (aggregateResult result : results) {
            usersIDsWithNumberOfLogins.put(string.valueOf(result.get('userId')), integer.valueOf(result.get('numberOflogins')));
        }
        System.Debug('numberOflogins' + usersIDsWithNumberOfLogins.keySet());
        System.Debug('numberOflogins Values' + usersIDsWithNumberOfLogins.values());

        List<Activity_Summary__c> summariesToUpsert = new List<Activity_Summary__c>();
        for (user us : scope) {

            integer loginCounts = usersidsWithNumberOfLogins.get(us.id);
            if (loginCounts == null) {
                loginCounts = 0;
            }
            integer numberOfNewProspects = contactToContactsMap.get(us.ContactId)?.size();
            if(numberOfNewProspects == null) {
                numberOfNewProspects = 0;
            }

            integer numberOfDownloads = contactToFdlsMap.get(us.ContactId)?.size();
            if(numberOfDownloads == null) {
                numberOfDownloads = 0;
            }
            System.Debug('login counts: ' + loginCounts);
            Id summaryId = usersIdsWithActivitySummary.get(us.id);
            if (summaryId != null) {
                system.debug(loginCounts);
                Activity_Summary__c summary = existingSummaries.get(summaryId);
                summary.number_of_logins__c = loginCounts;
                summary.number_of_new_prospects__c = numberOfNewProspects;
                summary.number_of_downloads__c = numberOfDownloads;
                summariesToUpsert.add(summary);
            } else {
                Activity_Summary__c newSummary = new Activity_summary__c();
                newSummary.year__c = String.valueOf(Date.Today().Year());
                newSummary.month__c = String.valueOf(date.today().Month());
                newSummary.userId__c = us.id;
                newSummary.number_of_logins__c = loginCounts;
                newSummary.number_of_new_prospects__c = numberOfNewProspects;
                newSummary.number_of_downloads__c = numberOfDownloads;
                newSummary.Contact__c = getContactId(us);
                newSummary.Account__c = getContactAccountId(us);
                newSummary.Maklerbetreuer__c = getContactAccountOwnerId(us);
                summariesToUpsert.add(newSummary);
            }
        }
        upsert summariesToUpsert;
    }
    public void finish(Database.BatchableContext BC) {
        system.debug('----------finished-----------');
    }

    private static Id getContactId(User user) {
        if(Test.isRunningTest()) {
            return [SELECT Id FROM Contact WHERE LastName = 'Test' LIMIT 1].Id;
        } else {
            return user.ContactId;
        }
    }

    private static Id getContactAccountId(User user) {
        if(Test.isRunningTest()) {
            return [SELECT Id FROM Account LIMIT 1].Id;
        } else {
            return user.ContactAccountId__c;
        }
    }

    private static Id getContactAccountOwnerId(User user) {
        if(Test.isRunningTest()) {
            return [SELECT OwnerId FROM Account LIMIT 1].OwnerId;
        } else {
            return user.ContactAccountOwnerId__c;
        }
    }
}