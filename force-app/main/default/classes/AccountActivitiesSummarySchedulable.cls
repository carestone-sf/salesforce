global class AccountActivitiesSummarySchedulable implements Schedulable {
    public static String CRON_EXP = '0 0 23 1/1 * ? *';
    @testVisible
    private static String JOB_NAME = 'Update account activities for current year';

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new AccountActivitiesSummaryBatch());
    }   

    private static String getJobName() {
        if (Test.isRunningTest()) return 'Test ' + JOB_NAME;
        else return JOB_NAME;
    }

    public static String scheduleMe() {
        return System.schedule(getJobName(), CRON_EXP, new AccountActivitiesSummarySchedulable());
    }
}