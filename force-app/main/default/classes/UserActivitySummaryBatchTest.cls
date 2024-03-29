@isTest
public class UserActivitySummaryBatchTest {   
    @TestSetup
    static void makeData(){
        
    }

    private static map<id,integer> getUsersIDsWithNumberOfLogins(){
        Map<id,integer> usersIDsWithNumberOfLogins = new Map<id, integer>();
        DateTime firstDayOfMonth= DateTime.newInstance(Date.today().year(),Date.today().month(),1);
        System.Debug('Date  '+ firstDayOfMonth);
        LIST<AggregateResult> results =[SELECT userID,count(id) numberOflogins
                                        from LoginHistory 
                                        WHERE LoginTime > :firstDayOfMonth 
                                        AND UserId = :UserInfo.getUserId()
                                        Group by userid];
        
        for(aggregateResult result : results){
            usersIDsWithNumberOfLogins.put(string.valueOf(result.get('userId')),integer.valueOf(result.get('numberOflogins')));
        }
        return usersIDsWithNumberOfLogins;
    }


   @isTest()
    private static void testUsersWithActiveSummaryCreated(){
        Account acc = TestDataFactory.createAccount(true);
        User testUser = TestDataFactory.createCommunityUser(acc.Id);
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c p = TestDataFactory.createProperty(true, bautraeger.Id);
        ImmobilienDMSDatei__c dmsDatei = TestDataFactory.createImmobilienDMSDatei(true, p.Id, 'Dokumente');
        TestDataFactory.createFileDownloadLog(true, con.Id);

        Map<id,integer> usersIDsWithNumberOfLogins=getusersIDsWithNumberOfLogins();
        
        List<Activity_Summary__c> summariesToInsert=new List<Activity_Summary__c>();
        for(id userId :usersIDsWithNumberOfLogins.keySet()){
            Activity_Summary__c userSummary =TestDataFactory.createActivitySummary(false, userId);
            summariesToInsert.add(userSummary);
        }
        insert summariesToInsert;

        System.Debug('summaries: '+[select count(id)from Activity_Summary__c]);
        System.debug('loginhistory: '+[select count(id) from LoginHistory]);
        
        
        Test.startTest();
        System.RunAs(testUser){
            TestDataFactory.createInteressent(true, acc.Id);
        }
        Database.executeBatch(new UserActivitySummaryBatch(usersIDsWithNumberOfLogins.keySet()));
        Test.stopTest();
        Map<id,Activity_Summary__c> summaries =new map<id, Activity_Summary__c>([select id, number_of_logins__c,userId__c 
                                                from Activity_Summary__c 
                                                where month__c =:String.valueOf(Date.Today().Month()) 
                                                and userId__c=:usersIDsWithNumberOfLogins.keyset()]);
        for(Activity_Summary__c summary :summaries.values()){
            System.Debug('updated: '+summary.number_of_logins__c+' for user '+summary.userId__c+'real: '+usersIDsWithNumberOfLogins.get(summary.userId__c));
            system.assertEquals(usersIDsWithNumberOfLogins.get(summary.userId__c), summary.number_of_logins__c);
            if(summary.userId__c == testUser.Id) {
                system.assertEquals(1, summary.number_of_downloads__c);
                system.assertEquals(1, summary.number_of_new_prospects__c);
            }
        }

    }
   @isTest()
    private static void testUsersWithoutActiveSummaryCreated(){
        Account acc = TestDataFactory.createAccount(true);
        User testUser = TestDataFactory.createCommunityUser(acc.Id);
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c p = TestDataFactory.createProperty(true, bautraeger.Id);
        ImmobilienDMSDatei__c dmsDatei = TestDataFactory.createImmobilienDMSDatei(true, p.Id, 'Dokumente');
        TestDataFactory.createFileDownloadLog(true, con.Id);

        System.Debug('summaries: '+[select count(id)from Activity_Summary__c]);
        System.debug('loginhistory: '+[select count(id) from LoginHistory]);
        System.debug('fileDownloadLogs: '+[select count(id) from FileDownloadLog__c]);
        
        Map<id,integer> usersIDsWithNumberOfLogins=getusersIDsWithNumberOfLogins();
        Map<id,user> users= new Map<id, user>([select id, name from user where contactId!=null]);
        
        Test.startTest();
        System.RunAs(testUser){
            TestDataFactory.createInteressent(true, acc.Id);
        }
        Database.executeBatch(new UserActivitySummaryBatch(new Set<Id> { UserInfo.getUserId() }));
        Test.stopTest();
        Map<id,Activity_Summary__c> summaries =new map<id, Activity_Summary__c>([select id, number_of_logins__c,number_of_downloads__c,number_of_new_prospects__c,userId__c 
                                                from Activity_Summary__c 
                                                where month__c =:String.valueOf(Date.Today().Month()) 
                                                and userId__c=:usersIDsWithNumberOfLogins.keyset()]);
        for(Activity_Summary__c summary :summaries.values()){
            System.Debug('updated: '+summary.number_of_logins__c+' for user '+summary.userId__c+'real: '+usersIDsWithNumberOfLogins.get(summary.userId__c));
            
            system.assertEquals(usersIDsWithNumberOfLogins.get(summary.userId__c), summary.number_of_logins__c);
            if(summary.userId__c == testUser.Id) {
                system.assertEquals(1, summary.number_of_downloads__c);
                system.assertEquals(1, summary.number_of_new_prospects__c);
            }
        }

    }
}