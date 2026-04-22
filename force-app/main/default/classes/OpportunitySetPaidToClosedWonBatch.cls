global class OpportunitySetPaidToClosedWonBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful {

    private List<Opportunity> processedOpps = new List<Opportunity>();

    /**
     * Picks all Opportunities with:
     * - CloseDate >= 01.01.2020
     * - StageName = 'Notartermin hat stattgefunden'
     * - Kaufpreis_bezahlt__c = true
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, StageName
            FROM Opportunity
            WHERE CloseDate >= :Date.newInstance(2020, 1, 1)
              AND StageName = 'Notartermin hat stattgefunden'
              AND Kaufpreis_bezahlt__c = true
        ]);
    }

    /**
     * Sets StageName to 'Geschlossen und gewonnen' for all records in scope.
     */
    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        for (Opportunity opp : scope) {
            opp.StageName = 'Geschlossene und gewonnene';
        }
        update scope;
        processedOpps.addAll(scope);
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Updated ' + processedOpps.size() + 
                     ' Opportunities to "Geschlossen und gewonnen".');
    }

    /**
     * Called by the scheduler.
     */
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new OpportunitySetPaidToClosedWonBatch(), 10);
    }

    /**
     * Schedules this batch to run daily at 23:00.
     */
    public static String scheduleMe() {
        String cronExp = '0 0 23 * * ?';  // every day at 23:00 (11pm)
        String jobName = 'DailyOpportunitySetPaidToClosedWonBatchJob';
        if (Test.isRunningTest()) {
            jobName += 'Test';
        }
        return System.schedule(jobName, cronExp, new OpportunitySetPaidToClosedWonBatch());
    }
}