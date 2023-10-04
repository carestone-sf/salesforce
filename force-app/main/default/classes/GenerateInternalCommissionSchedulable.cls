global with sharing class GenerateInternalCommissionSchedulable implements Schedulable  {
    String cronExp;
    String jobName = 'Generate internal comissions, schedule: ';
    // month || quarter || year
    String schedule;
    global GenerateInternalCommissionSchedulable(String schedule) {
        this.schedule = schedule;
        this.jobName += this.schedule;
        if(this.schedule == 'month') {
            this.cronExp = '0 0 21 1/1 * ? *';
        } else if(this.schedule == 'quarter') {
            this.cronExp = '0 0 22 10 1/3 ? *';
        } else if(this.schedule == 'year') {
            this.cronExp = '0 0 23 10 1 ? *';
        }
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new GenerateInternalCommissionBatch(this.schedule), 10);
    }   

    private String getJobName() {
        if (Test.isRunningTest()) return 'Test ' + this.jobName;
        else return this.jobName;
    }

    public String scheduleMe() {
        return System.schedule(getJobName(), this.cronExp, new GenerateInternalCommissionSchedulable(this.schedule));
    }
}