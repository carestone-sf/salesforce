public with sharing class UserActivitySummaryBatchForOneMonth implements Database.Batchable<sObject> {
    static final DateTime FIRST_DAY_OF_CURRENT_MONTH = DateTime.newInstance(Date.today().year(), Date.today().month(), 1);
    Set<id> usersIds;
    integer nmonth = 0;
    public UserActivitySummaryBatchForOneMonth(Set<id> UsersIds, integer nmonth) {
        this.usersIds = usersIds;
        this.nmonth = nmonth;
    }
    public UserActivitySummaryBatchForOneMonth(integer nmonth) {
        this.usersIds = null;
        this.nmonth = nmonth;
    }
    public UserActivitySummaryBatchForOneMonth() {
        this.usersIds = null;
        this.nmonth = 0;
    }
    public List<user> start(Database.BatchableContext bc) {
        system.debug('----------started-----------');
        if (usersIds != null) {

            return [select id, ContactId from user where id = :this.usersIds];
        } else {
            return [select id, ContactId from user where ContactId != null];
        }
    }
    public void execute(Database.BatchableContext BC, list<user> scope) {


        Map<id, user> users = new map<Id, user>(scope);
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
                AND month__c = :String.valueOf(Date.today().addmonths(nmonth * -1).month())
                AND year__c = :String.valueOf(Date.today().addmonths(nmonth * -1).year())
        ]);

        //fill map with user Id and related activity Summary
        for (Activity_Summary__c summary : existingSummaries.values()) {
            usersIdsWithActivitySummary.put(summary.userId__c, summary.id);
        }


        //Get User ids with number of logins for today().month()-n month
        Set<id> userIdsList = users.keySet();
        string N_MONTHS_AGO = 'N_MONTHS_AGO:' + String.valueOf(nmonth);
        string queryFields = 'userID,count(id) numberOflogins';
        string querytable = 'LoginHistory';
        string queryWhere = 'LoginTime=' + N_MONTHS_AGO + ' and userId =:userIdsList';
        string queryGroup = 'userid';
        string query = 'SELECT ' + queryFields + ' from ' + querytable + ' Where ' + queryWhere + ' Group by ' + queryGroup;
        Map<id, integer> usersIDsWithNumberOfLogins = new Map<id, integer>();
        system.debug('query : ' + query);
        LIST<AggregateResult> results = Database.query(query);
        system.debug('query ids:' + users.keyset());
        system.debug('query results:' + results);
        for (aggregateResult result : results) {
            usersIDsWithNumberOfLogins.put(string.valueOf(result.get('userId')), integer.valueOf(result.get('numberOflogins')));
        }
        System.Debug('numberOflogins' + usersIDsWithNumberOfLogins.keySet());

        List<Activity_Summary__c> summariesToUpsert = new List<Activity_Summary__c>();
        for (user us : scope) {

            integer loginCounts = usersidsWithNumberOfLogins.get(us.id);
            if (loginCounts == null) {
                loginCounts = 0;
            }
            System.Debug('login counts: ' + loginCounts);
            id summaryId = usersIdsWithActivitySummary.get(us.id);
            if (summaryId != null) {
                system.debug(loginCounts);
                Activity_Summary__c summary = existingSummaries.get(summaryId);
                summary.number_of_logins__c = loginCounts;
                summariesToUpsert.add(summary);
            } else {
                Activity_Summary__c newSummary = new Activity_summary__c();
                newSummary.year__c = String.valueOf(Date.Today().addmonths(nmonth * -1).Year());
                newSummary.month__c = String.valueOf(Date.today().addmonths(nmonth * -1).month());
                newSummary.userId__c = us.id;
                newSummary.number_of_logins__c = loginCounts;
                newSummary.Contact__c = us.ContactID;
                summariesToUpsert.add(newSummary);

            }
        }
        System.Debug('summToUpsert:  ' + summariesToUpsert.size());
        upsert summariesToUpsert;
    }
    public void finish(Database.BatchableContext BC) {
        system.debug('----------finished-----------');
    }
}