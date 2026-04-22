@IsTest
private class OpportunityDeleteConsultationsBatchTest {
    private static void setCreatedDate(Id recordId, DateTime dt) {
        Test.setCreatedDate(recordId, dt);
    }

    @IsTest static void testBatchDeletesOldBeratungOpps() {
        // Arrange: use TestDataFactory for all required records
        Account acct       = TestDataFactory.createAccount(true);
        Id    bautraegerId = TestDataFactory.createBautraeger(true).Id;
        Property__c prop    = TestDataFactory.createProperty(true, bautraegerId);
        Contact makler     = TestDataFactory.createMakler(true, acct.Id);
        Contact interessent= TestDataFactory.createInteressent(true, acct.Id);

        // Old Beratung opp (>30 days)
        Opportunity oldBeratung = TestDataFactory.createOpportunity(
            true, interessent.Id, makler.Id, prop.Id, null, 'Beratung'
        );
        setCreatedDate(oldBeratung.Id, DateTime.now().addDays(-31));

        // Recent Beratung opp (≤30 days)
        Opportunity recentBeratung = TestDataFactory.createOpportunity(
            true, interessent.Id, makler.Id, prop.Id, null, 'Beratung'
        );
        setCreatedDate(recentBeratung.Id, DateTime.now().addDays(-10));

        // Act
        Test.startTest();
            Database.executeBatch(new OpportunityDeleteConsultationsBatch(), 100);
        Test.stopTest();

        // Assert
        System.assertEquals(
            0,
            [SELECT COUNT() FROM Opportunity WHERE Id = :oldBeratung.Id],
            'Old Beratung opp should have been deleted'
        );
        System.assertEquals(
            1,
            [SELECT COUNT() FROM Opportunity WHERE Id = :recentBeratung.Id],
            'Recent Beratung opp should NOT be deleted'
        );
    }

    @IsTest static void testScheduleMeSchedulesJob() {
        Test.startTest();
            String jobId = OpportunityDeleteConsultationsBatch.scheduleMe();
        Test.stopTest();

        CronTrigger ct = [ 
            SELECT CronExpression, State
            FROM CronTrigger 
            WHERE Id = :jobId 
        ];
        System.assertEquals(
            '0 0 22 * * ?',
            ct.CronExpression,
            'Cron expression must fire daily at 22:00'
        );
        System.assertEquals(
            'WAITING',
            ct.State,
            'Scheduled job should be in WAITING state'
        );
    }
}