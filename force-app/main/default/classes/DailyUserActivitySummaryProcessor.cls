global class DailyUserActivitySummaryProcessor implements Schedulable {
    List<Id> userIds;
    public static String CRON_EXP = '0 0 23 1/1 * ? *';
    @testVisible
    private static String JOB_NAME = 'Update activity summary for current month';

    public DailyUserActivitySummaryProcessor() {
        this.userIds = Test.isRunningTest() ? new List<Id> { UserInfo.getUserId() } : null;
    }
    public DailyUserActivitySummaryProcessor(List<Id> userIds) {
        this.userIds = userIds;
    }
    private static String getJobName() {
        if (Test.isRunningTest()) return 'Test ' + JOB_NAME;
        else return JOB_NAME;
    }
    public static String scheduleMe() {
        return System.schedule(getJobName(), CRON_EXP, new DailyUserActivitySummaryProcessor());
    }
    public static String scheduleMe(List<Id> userIds) {
        return System.schedule(getJobName(), CRON_EXP, new DailyUserActivitySummaryProcessor(userIds));
    }
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new UserActivitySummaryBatch(userIds));
    }
}