global class OpportunityDeleteConsultationsBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful {
    // Holds the opportunities processed, in case you want to log or perform additional logic in finish()
    private List<Opportunity> processedOpps;

    public OpportunityDeleteConsultationsBatch() {
        this.processedOpps = new List<Opportunity>();
    }

    /**
     * Returns all Opportunities older than 30 days in the 'Beratung' stage.
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String soql = 'SELECT Id FROM Opportunity '
                    + 'WHERE CreatedDate < LAST_N_DAYS:30 '
                    + 'AND StageName = \'Beratung\'';
        return Database.getQueryLocator(soql);
    }

    /**
     * Deletes each batch of Opportunities returned by start().
     */
    global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        this.processedOpps.addAll(scope);
        delete scope;
    }

    /**
     * Finish method—could be used to log results or notify.
     */
    global void finish(Database.BatchableContext bc) {
        System.debug('Deleted ' + processedOpps.size() + ' Beratung opportunities older than 30 days.');
    }

    /**
     * Called by the scheduler. Executes the batch at the configured batch size.
     */
    global void execute(SchedulableContext sc) {
        // You can adjust the batch size as needed
        Database.executeBatch(new OpportunityDeleteConsultationsBatch(), 10);
    }

    /**
     * Schedules this batch to run daily at 10pm.
     */
    public static String scheduleMe() {
        // Cron: second minute hour day-of-month month day-of-week
        String cronExp = '0 0 22 * * ?';  // every day at 22:00 (10pm)
        String jobName = 'DailyOpportunityDeleteConsultationsBatchJob';
        if (Test.isRunningTest()) {
            jobName += 'Test';
        }
        return System.schedule(jobName, cronExp, new OpportunityDeleteConsultationsBatch());
    }
}