@isTest
public with sharing class DashboardRefreshTest {
    
    @IsTest
    static void testDashboardRefresh() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();

        // Schedule the test job

        String year = String.valueOf((Date.today().year() + 1));

        String jobId = System.schedule('testBasicScheduledApex',
          '0 0 0 3 9 ? ' + year,
            new DashboardRefresh());

      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals('0 0 0 3 9 ? ' + year,
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals(year + '-09-03 00:00:00',
         String.valueOf(ct.NextFireTime));

       Test.stopTest();
    }
    
}