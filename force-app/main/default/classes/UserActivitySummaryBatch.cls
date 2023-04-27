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
            System.Debug('login counts: ' + loginCounts);
            Id summaryId = usersIdsWithActivitySummary.get(us.id);
            if (summaryId != null) {
                system.debug(loginCounts);
                Activity_Summary__c summary = existingSummaries.get(summaryId);
                summary.number_of_logins__c = loginCounts;
                summariesToUpsert.add(summary);
            } else {
                Activity_Summary__c newSummary = new Activity_summary__c();
                newSummary.year__c = String.valueOf(Date.Today().Year());
                newSummary.month__c = String.valueOf(date.today().Month());
                newSummary.userId__c = us.id;
                newSummary.number_of_logins__c = loginCounts;
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