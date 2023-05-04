@isTest
public class DailyDeletionOfDownloadFileLogsTest {
    @isTest()
    private static void testUsersWithActiveSummaryCreated(){
        List<AsyncApexJob> jobsBefore = [select Id, ApexClassID, CronTriggerId, Status, JobType from AsyncApexJob];
        System.assertEquals(0, jobsBefore.size(), 'not expecting any asyncjobs');

        Test.startTest();
        String jobId = DailyDeletionOfDownloadFileLogs.scheduleme();
        Test.stopTest();

        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID,CronTriggerId, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
        System.assertEquals(jobId, jobsScheduled[0].CronTriggerId, 'expecting specific scheduled job');

    }  
}