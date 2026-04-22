@IsTest
private class OpportunitySetPaidToClosedWonBatchTest {

    @testSetup
    static void setupData() {
        // Custom settings your org logic / triggers might expect
        TestDataFactory.createNecessaryCustomSettings();
        TestDataFactory.createDatevSettings();
    }

    @IsTest
    static void testBatchUpdatesSingleEligibleOpp() {
        // Single Opportunity via your factory
        Opportunity opp = TestDataFactory.createOpportunity(true);
        // Make it match the batch criteria
        opp.StageName = 'Notartermin hat stattgefunden';
        opp.Kaufpreis_bezahlt__c = true;
        opp.CloseDate = Date.newInstance(2021, 1, 1); // after 2020

        // Extra fields that are likely required by your validations/flows
        opp.Kaufdatum__c = Date.today();
        opp.Maklerprovision__c = '4.5';
        opp.Verk_ufer_Beratungsprovision__c = '1.5';
        opp.Immobilienberater__c = opp.Makler__c;

        update opp;

        Test.startTest();
            // BatchSize = 1 to keep load + queries minimal
            Database.executeBatch(new OpportunitySetPaidToClosedWonBatch(), 1);
        Test.stopTest();

        // Assert: this single opp should now be closed-won
        opp = [
            SELECT StageName
            FROM Opportunity
            WHERE Id = :opp.Id
        ];
        System.assertEquals(
            'Geschlossene und gewonnene',
            opp.StageName,
            'Opp should be updated to "Geschlossen und gewonnen".'
        );
    }

    @IsTest
    static void testScheduleMeSchedulesJob() {
        Test.startTest();
            String jobId = OpportunitySetPaidToClosedWonBatch.scheduleMe();
        Test.stopTest();

        CronTrigger ct = [
            SELECT CronExpression, State
            FROM CronTrigger
            WHERE Id = :jobId
        ];

        System.assertEquals(
            '0 0 23 * * ?',
            ct.CronExpression,
            'Cron expression must fire daily at 23:00.'
        );
        System.assertEquals(
            'WAITING',
            ct.State,
            'Scheduled job should be in WAITING state.'
        );
    }
}