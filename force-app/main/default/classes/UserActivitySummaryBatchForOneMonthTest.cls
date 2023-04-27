@isTest
public class UserActivitySummaryBatchForOneMonthTest {
    static integer nmonth = 8;
    private static string getCurrentUserId {
        get {
            return System.UserInfo.getUserId();
        }
        set;
    }

    private static integer getUserLoginsForMonth(integer customnmonth) {
        string N_MONTHS_AGO = 'N_MONTHS_AGO:' + String.valueOf(customnmonth);
        string queryFields = 'userID,count(id) numberOflogins';
        string querytable = 'LoginHistory';
        string queryWhere = 'LoginTime=' + N_MONTHS_AGO + ' And userId =:getCurrentUserId';
        string queryGroup = 'userid';
        string query = 'SELECT ' + queryFields + ' from ' + querytable + ' Where ' + queryWhere + ' Group by ' + queryGroup;
        Map<id, integer> usersIDsWithNumberOfLogins = new Map<id, integer>();
        system.debug('query : ' + query);
        LIST<AggregateResult> results = Database.query(query);
        System.debug('Assertion Query Results: ' + results);
        return results.size() > 0 ? integer.valueOf(results[0].get('numberOflogins')) : 0;
    }


    @isTest()
    private static void testCurrentUserWithNoActivitySummaryForNMonth() {
        Account acc = TestDataFactory.createAccount(true);
        User testUser = TestDataFactory.createCommunityUser(acc.Id);
        
        user currentUser = [SELECT id, name, ContactId FROM user WHERE Id = :getCurrentUserId limit 1];
        Set<id> usersIdsSet = new Set<id>();
        usersIdsSet.add(currentUser.id);

        Test.startTest();
        Database.executeBatch(new UserActivitySummaryBatchForOneMonth(usersIdsSet, nmonth));
        Test.stopTest();


        Activity_Summary__c summary = [SELECT id, number_of_logins__c FROM Activity_Summary__c limit 1];
        System.assertEquals(getUserLoginsForMonth(nmonth), summary.Number_of_Logins__c);
    }
    @isTest()
    private static void testCurrentUserWithActivitySummaryForNMonth() {
        user currentUser = [SELECT id, name, ContactId FROM user WHERE Id = :getCurrentUserId limit 1];
        Set<id> usersIdsSet = new Set<id>();
        usersIdsSet.add(currentUser.id);

        System.assertEquals(0, [SELECT id FROM Activity_Summary__c WHERE userId__c = :currentUser.id].size());
        TestDataFactory.createActivitySummary(true, currentUser.id, nmonth);

        Test.startTest();
        Database.executeBatch(new UserActivitySummaryBatchForOneMonth(usersIdsSet, nmonth));
        Test.stopTest();

        System.assertEquals(1, [SELECT id FROM Activity_Summary__c WHERE userId__c = :currentUser.id].size());

        Activity_Summary__c summary = [SELECT id, number_of_logins__c FROM Activity_Summary__c limit 1];
        System.assertEquals(getUserLoginsForMonth(nmonth), summary.Number_of_Logins__c);
    }
    @isTest()
    private static void testCurrentUserWithActivitySummaryForCurrentMonth() {
        Account acc = TestDataFactory.createAccount(true);
        User testUser = TestDataFactory.createCommunityUser(acc.Id);

        user currentUser = [SELECT id, name, ContactId FROM user WHERE Id = :getCurrentUserId limit 1];
        Set<id> usersIdsSet = new Set<id>();
        usersIdsSet.add(currentUser.id);

        System.assertEquals(0, [SELECT id FROM Activity_Summary__c WHERE Contact__c = :testUser.ContactId].size());
        TestDataFactory.createActivitySummary(true, currentUser.id, testUser.ContactId, 0);

        Test.startTest();
        Database.executeBatch(new UserActivitySummaryBatchForOneMonth(usersIdsSet, Date.today().month() - 1));
        Test.stopTest();

        System.assertEquals(2, [SELECT id FROM Activity_Summary__c WHERE Contact__c = :testUser.ContactId].size());

        Activity_Summary__c summary = [SELECT id, number_of_logins__c FROM Activity_Summary__c limit 1];
        System.assertEquals(getUserLoginsForMonth(Date.today().month() - 1), summary.Number_of_Logins__c);
    }
}