public with sharing class AggregateVkcZahlungSchedulable implements Schedulable {
    
    public void execute(System.SchedulableContext ctx) {
        Map<Id,Opportunity> opportunityMap = new Map<Id, Opportunity>([SELECT Id FROM Opportunity WHERE Datum_Kaufpreisf_lligkeitsschreiben__c = :System.today()]);
        if(!opportunityMap.isEmpty()) {
            System.enqueueJob(new AggregateVkcZahlungPaymentDataQueueable(opportunityMap.keySet()));
        }
    }
    
    public static String scheduleEveryNight = '0 0 1 ? * *';

    public static String getJobName() {
        String jobName = 'Aggregation offener Einmalzahlungen auf Immobilien';
        if(Test.isRunningTest()) {
            jobName += ' - Test';
        }
        return jobName;
    }

    @AuraEnabled
    public static String schedule() {
        AggregateVkcZahlungSchedulable scheduledJob = new AggregateVkcZahlungSchedulable();
        return System.schedule(getJobName(), scheduleEveryNight, scheduledJob);
    }
}
