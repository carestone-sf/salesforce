@isTest
private class SchedulableImmobilienFilesTest {
  @TestSetup
  static void makeData(){
    ConnectorType__c ct = new ConnectorType__c();
    ct.Name = 'Google Drive';
    ct.AuthorizationEndpoint__c = 'https://accounts.google.com/o/oauth2/auth';
    ct.TokenEndpoint__c = 'https://accounts.google.com/o/oauth2/token';
    ct.ClientId__c = '166550496015-h41c6c5pe3jtu799iefm6gidetre397c.apps.googleusercontent.com';
    ct.ClientSecret__c = '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';
    ct.RedirectUri__c = 'https://carestone.lightning.force.com/apex/connector';
    ct.ScopeRequired__c = true;
    ct.Scope__c = 'https://www.googleapis.com/auth/drive';
    ct.ExtraUrlParameters__c = 'access_type=offline';
    insert ct;

    Connector__c c = new Connector__c();
    c.Name = 'Google Drive';
    c.ConnectorType__c = ct.Id;
    c.TokenType__c = 'Bearer';
    c.AccessToken__c = 'abc';
    insert c;
  }

  @isTest static void test_method_one() {
    new Sandbox();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();


        // Schedule the test job

        String year = String.valueOf((Date.today().year() + 1));

        String jobId = System.schedule('testBasicScheduledApex',
          '0 0 0 3 9 ? ' + year,
            new SchedulableImmobilienFiles());

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