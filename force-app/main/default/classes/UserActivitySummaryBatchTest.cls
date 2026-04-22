@isTest
public class UserActivitySummaryBatchTest {   
    @TestSetup
    static void makeData(){
        
    }

   @isTest()
    private static void testUsersWithActiveSummaryCreated(){
        Account acc = TestDataFactory.createAccount(true);
        User testUser = TestDataFactory.createCommunityUser(acc.Id);
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        con.VPBenutzerId__c = '1234';
        update con;
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c p = TestDataFactory.createProperty(true, bautraeger.Id);
        ImmobilienDMSDatei__c dmsDatei = TestDataFactory.createImmobilienDMSDatei(true, p.Id, 'Dokumente');
        TestDataFactory.createFileDownloadLog(true, con.Id);
        
        List<Activity_Summary__c> summariesToInsert=new List<Activity_Summary__c>();
        Activity_Summary__c userSummary = TestDataFactory.createActivitySummary(false, con.Id);
        summariesToInsert.add(userSummary);
        insert summariesToInsert;

        System.Debug('summaries: '+[select count(id)from Activity_Summary__c]);
        System.debug('loginhistory: '+[select count(id) from LoginHistory]);
        
        
        Test.startTest();
        System.RunAs(testUser){
            TestDataFactory.createInteressent(true, acc.Id);
        }
        Database.executeBatch(new UserActivitySummaryBatch(new List<Id>{con.Id}));
        Test.stopTest();
    }
    
   @isTest()
    private static void testUsersWithoutActiveSummaryCreated(){
        Account acc = TestDataFactory.createAccount(true);
        User testUser = TestDataFactory.createCommunityUser(acc.Id);
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        con.VPBenutzerId__c = '1234';
        update con;
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c p = TestDataFactory.createProperty(true, bautraeger.Id);
        ImmobilienDMSDatei__c dmsDatei = TestDataFactory.createImmobilienDMSDatei(true, p.Id, 'Dokumente');
        TestDataFactory.createFileDownloadLog(true, con.Id);

        System.Debug('summaries: '+[select count(id)from Activity_Summary__c]);
        System.debug('loginhistory: '+[select count(id) from LoginHistory]);
        System.debug('fileDownloadLogs: '+[select count(id) from FileDownloadLog__c]);
        
        Test.startTest();
        System.RunAs(testUser){
            TestDataFactory.createInteressent(true, acc.Id);
        }
        Database.executeBatch(new UserActivitySummaryBatch(new List<Id>{con.Id}));
        Test.stopTest();
    }
}