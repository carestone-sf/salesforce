@isTest
private class ImmobilienAsExcelTest {

	@isTest static void test_method_one() {
		Property__c immobilie = new Property__c();
        immobilie.Name = 'Immobilie';
        insert immobilie;

        Appartment__c app2 = new Appartment__c();
        app2.Name = 'TestApp2';
        app2.Property__c = immobilie.Id;
        app2.Status__c = 'Available';
        app2.Area_sq_m__c = 63;
        insert app2;

        Account acc = new Account(WHS_Maklerauftrag__c = 'Maklerauftrag beidseitig unterzeichnet', Name = 'Test Tester', Email__c ='test@test.test', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com');
        insert acc;

        Contact con = new Contact(AccountId = acc.id, Email='f.witte@wirtschaftshaus.de', FirstName='Frederik', LastName='Witte', Gesch_ftsbeziehung__c = 'Finanzmakler');
        insert con;

        Test.startTest();

        // Schedule the test job

        String jobId = System.schedule('testBasicScheduledApex',
          '0 0 0 3 9 ? ' + getYearAhead(),
            new ImmobilienAsExcel());

      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals('0 0 0 3 9 ? ' + getYearAhead(),
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals(getYearAhead() + '-09-03 00:00:00',
         String.valueOf(ct.NextFireTime));

       Test.stopTest();
	}

    private static String getYearAhead(){
        return String.valueOf(System.Today().addYears(1).year());
    }
}