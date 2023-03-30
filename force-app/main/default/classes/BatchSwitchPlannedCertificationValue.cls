public with sharing class BatchSwitchPlannedCertificationValue implements Database.Batchable<sObject> {
    @TestVisible static final string PLANNED_CERTIFICATION_VALUE_CURRENT_MONTH = 'Current Month';
    @TestVisible static final string PLANNED_CERTIFICATION_VALUE_NEXT_MONTH = 'Next Month';
    @TestVisible static final string PLANNED_CERTIFICATION_VALUE_MONTH_AFTER_NEXT = 'Month after next';

    public List<Opportunity> start(Database.BatchableContext BC) {
        system.debug('----------started-----------');
        return [
                SELECT Id, PlannedCertification__c
                FROM Opportunity
        ];
    }

    public void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (Opportunity opp : scope) {
            if (opp.PlannedCertification__c == PLANNED_CERTIFICATION_VALUE_CURRENT_MONTH) {
                opp.PlannedCertification__c = null;
                opportunitiesToUpdate.add(opp);
            } else if (opp.PlannedCertification__c == PLANNED_CERTIFICATION_VALUE_NEXT_MONTH) {
                opp.PlannedCertification__c = PLANNED_CERTIFICATION_VALUE_CURRENT_MONTH;
                opportunitiesToUpdate.add(opp);
            } else if (opp.PlannedCertification__c == PLANNED_CERTIFICATION_VALUE_MONTH_AFTER_NEXT) {
                opp.PlannedCertification__c = PLANNED_CERTIFICATION_VALUE_NEXT_MONTH;
                opportunitiesToUpdate.add(opp);
            }
        }
        update opportunitiesToUpdate;
    }

    public void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob
                WHERE Id = :bc.getJobId()
        ];
        String emailBody = 'BatchSwitchPlannedCertificationValue batch processed ' + a.TotalJobItems + ' batches with ' + a.NumberOfErrors + ' failures.';
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toaddresses = new String[]{
                UserInfo.getUserEmail()
        };
        message.optOutPolicy = 'FILTER';
        message.subject = 'BatchSwitchPlannedCertificationValue batch status';
        message.plainTextBody = emailBody;
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
                message
        };
        if (!Test.isRunningTest()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' + results[0].errors[0].message);
            }
            system.debug('----------finished-----------');
        }

    }
}