global with sharing class MonthlyPlannedCertificationSwitch implements Schedulable {
    Set<id> userIds;
    public static final String CRON_EXP = '0 23 0 1 * ?';
    @testVisible
    private static final String JOB_NAME = 'Switch Opportunity.PlannedCertification__c value at the end of month';

    public MonthlyPlannedCertificationSwitch() {
    }
    private static String getJobName() {
        if (Test.isRunningTest()) return 'Test ' + JOB_NAME;
        else return JOB_NAME;
    }
    public static String scheduleMe() {
        return System.schedule(getJobName(), CRON_EXP, new MonthlyPlannedCertificationSwitch());
    }
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchSwitchPlannedCertificationValue());
    }
}
