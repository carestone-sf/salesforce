@isTest
private class SchedulableDashboardControllingATest {

  @isTest static void test_method_one() {

    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = new Account(WHS_Maklerauftrag__c = 'Maklerauftrag beidseitig unterzeichnet', Name = 'Test Tester', Email__c ='test@test.test', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com');
        insert acc;

        Contact con = new Contact(AccountId = acc.id, Email='f.witte@wirtschaftshaus.de', FirstName='Frederik', LastName='Witte', Gesch_ftsbeziehung__c = 'Finanzmakler');
        insert con;

        Test.startTest();

        // Schedule the test job

        String jobId = System.schedule('testBasicScheduledApex',
          '0 0 0 3 9 ? 2022',
            new SchedulableDashboardControllingActivum   ());

      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals('0 0 0 3 9 ? 2022',
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-09-03 00:00:00',
         String.valueOf(ct.NextFireTime));

       Test.stopTest();
  }

}