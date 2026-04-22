// Batch + Scheduler: runs daily at 22:00 via scheduleMe()
global class AccountPotentialAnalysisBatch
    implements Database.Batchable<SObject>, Schedulable
{
    // Default parent Id (overridable in tests)
    public static Id PARENT_ID = '0016700005mG0GVAA0';

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String soql =
            'SELECT Id, PotenzialanalyseStarten__c ' +
            'FROM Account ' +
            'WHERE ParentId = :PARENT_ID ' +
            'AND PotenzialanalyseStarten__c = false ' +
            'AND PotenzialanalyseErfasst__c = false ' +
            'LIMIT 500';
        return Database.getQueryLocator(soql);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Account> accs = (List<Account>)scope;
        for (Account a : accs) {
            a.PotenzialanalyseStarten__c = true;
        }
        if (!accs.isEmpty()) {
            update accs;
        }
    }

    global void finish(Database.BatchableContext bc) {
        // Optional: logging or notifications
    }

    // Schedulable entrypoint -> kicks off the batch
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AccountPotentialAnalysisBatch(), 200);
    }

    // Helper to schedule this job for daily 22:00 (10pm)
    public static String scheduleMe() {
        String cronExp = '0 0 22 * * ?';
        String jobName = 'DailyAccountPotentialAnalysisBatch';
        if (Test.isRunningTest()) jobName += 'Test';
        return System.schedule(jobName, cronExp, new AccountPotentialAnalysisBatch());
    }
}