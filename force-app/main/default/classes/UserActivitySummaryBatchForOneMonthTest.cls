@isTest
public class UserActivitySummaryBatchForOneMonthTest {
    static integer nmonth = 2;
    private static map<id, integer> getUsersIDsWithNumberOfLogins(integer customnmonth) {
        string N_MONTHS_AGO = 'N_MONTHS_AGO:' + String.valueOf(customnmonth);
        string queryFields = 'userID,count(id) numberOflogins';
        string querytable = 'LoginHistory';
        string queryWhere = 'LoginTime=' + N_MONTHS_AGO;
        string queryGroup = 'userid';
        string query = 'SELECT ' + queryFields + ' from ' + querytable + ' Where ' + queryWhere + ' Group by ' + queryGroup;
        Map<id, integer> usersIDsWithNumberOfLogins = new Map<id, integer>();
        system.debug('query : ' + query);
        LIST<AggregateResult> results = Database.query(query);
        for (aggregateResult result : results) {
            usersIDsWithNumberOfLogins.put(string.valueOf(result.get('userId')), integer.valueOf(result.get('numberOflogins')));
        }
        return usersIDsWithNumberOfLogins;
    }


    @isTest()
    private static void testUsersWithActiveSummaryCreated() {
        Map<id, integer> usersIDsWithNumberOfLogins = getusersIDsWithNumberOfLogins(nmonth);

        List<Activity_Summary__c> summariesToInsert = new List<Activity_Summary__c>();
        for (id userId : usersIDsWithNumberOfLogins.keySet()) {
            Activity_Summary__c userSummary = TestDataFactory.createActivitySummary(false, userId, nmonth);
            summariesToInsert.add(userSummary);
        }
        insert summariesToInsert;

        System.Debug('summaries: ' + [select count(id) from Activity_Summary__c]);
        System.debug('loginhistory: ' + [select count(id) from LoginHistory]);


        Test.startTest();
        Database.executeBatch(new UserActivitySummaryBatchForOneMonth(usersIDsWithNumberOfLogins.keySet(), nmonth));
        Test.stopTest();
        Map<id, Activity_Summary__c> summaries = new map<id, Activity_Summary__c>([
                select id, number_of_logins__c, userId__c
                from Activity_Summary__c
                where month__c = :String.valueOf(Date.today().addmonths(nmonth * -1).month())
                AND year__c = :String.valueOf(Date.today().addmonths(nmonth * -1).year())
                and userId__c = :usersIDsWithNumberOfLogins.keyset()
        ]);
        system.debug('month:' + String.valueOf(Date.today().addmonths(nmonth * -1).month()));
        System.Debug('summaries' + summaries.values());
        System.Debug('summarieskeys' + summaries.keySet());
        System.Debug('users' + usersIDsWithNumberOfLogins.keySet().size());
        system.assertEquals(usersIDsWithNumberOfLogins.keySet().size(), summaries.keyset().size());
        for (Activity_Summary__c summary : summaries.values()) {
            System.Debug('updated: ' + summary.number_of_logins__c + ' for user ' + summary.userId__c + 'real: ' + usersIDsWithNumberOfLogins.get(summary.userId__c));
            system.assertEquals(usersIDsWithNumberOfLogins.get(summary.userId__c), summary.number_of_logins__c);
        }

    }
    @isTest()
    private static void testUsersWithoutActiveSummaryCreated() {
        System.Debug('summaries: ' + [select count(id) from Activity_Summary__c]);
        System.debug('loginhistory: ' + [select count(id) from LoginHistory]);

        Map<id, integer> usersIDsWithNumberOfLogins = getusersIDsWithNumberOfLogins(nmonth);
        Map<id, user> users = new Map<id, user>([select id, name from user where contactId != null]);

        Test.startTest();
        Database.executeBatch(new UserActivitySummaryBatchForOneMonth(nmonth));
        Test.stopTest();
        Map<id, Activity_Summary__c> summaries = new map<id, Activity_Summary__c>([
                select id, number_of_logins__c, userId__c
                from Activity_Summary__c
                where month__c = :String.valueOf(Date.today().addmonths(nmonth * -1).month())
                AND year__c = :String.valueOf(Date.today().addmonths(nmonth * -1).year())
                and userId__c = :usersIDsWithNumberOfLogins.keyset()
        ]);
        for (Activity_Summary__c summary : summaries.values()) {
            System.Debug('updated: ' + summary.number_of_logins__c + ' for user ' + summary.userId__c + 'real: ' + usersIDsWithNumberOfLogins.get(summary.userId__c));

            system.assertEquals(usersIDsWithNumberOfLogins.get(summary.userId__c), summary.number_of_logins__c);
        }

    }

    @isTest()
    private static void testfor5months() {

        for (integer month = 0; month < 6; month++) {
            system.debug('');
            Map<id, integer> usersIDsWithNumberOfLogins = getusersIDsWithNumberOfLogins(month);

            List<Activity_Summary__c> summariesToInsert = new List<Activity_Summary__c>();
            for (id userId : usersIDsWithNumberOfLogins.keySet()) {
                Activity_Summary__c userSummary = TestDataFactory.createActivitySummary(false, userId, month);
                summariesToInsert.add(userSummary);
            }
            insert summariesToInsert;

            System.Debug('summaries: ' + [select count(id) from Activity_Summary__c]);
            System.debug('loginhistory: ' + [select count(id) from LoginHistory]);


            Test.startTest();
            Database.executeBatch(new UserActivitySummaryBatchForOneMonth(usersIDsWithNumberOfLogins.keySet(), month));
            Test.stopTest();
            Map<id, Activity_Summary__c> summaries = new map<id, Activity_Summary__c>([
                    select id, number_of_logins__c, userId__c
                    from Activity_Summary__c
                    where month__c = :String.valueOf(Date.today().addmonths(month * -1).month())
                    AND year__c = :String.valueOf(Date.today().addmonths(month * -1).year())
                    and userId__c = :usersIDsWithNumberOfLogins.keyset()
            ]);
            system.debug('month:' + String.valueOf(Date.today().addmonths(month * -1).month()));
            System.Debug('summaries' + summaries.values());
            System.Debug('summarieskeys' + summaries.keySet());
            System.Debug('users' + usersIDsWithNumberOfLogins.keySet().size());
            system.assertEquals(usersIDsWithNumberOfLogins.keySet().size(), summaries.keyset().size());
            for (Activity_Summary__c summary : summaries.values()) {
                System.Debug('updated: ' + summary.number_of_logins__c + ' for user ' + summary.userId__c + 'real: ' + usersIDsWithNumberOfLogins.get(summary.userId__c));
                system.assertEquals(usersIDsWithNumberOfLogins.get(summary.userId__c), summary.number_of_logins__c);
            }

        }
    }
}