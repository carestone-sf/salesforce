public without sharing class NewFileEmailNotificationJob implements Database.Batchable<SObject>, Schedulable {

    public static String scheduleEveryEvening = '0 0 18 ? * *';

    public void execute(System.SchedulableContext ctx) {
        if(!NewFileOverviewController.getFiles().isEmpty()) {
            Database.executeBatch(new NewFileEmailNotificationJob(), 10);
        }
    }

    public NewFileEmailNotificationJob() {

    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM Contact 
            WHERE Email != null 
            AND Id IN (SELECT ContactId FROM User WHERE IsPortalEnabled = true AND IsActive = true AND Contact.VPDateiUebersichtAbbestellen__c	= false)]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Dateienuebersicht'];
        Id orgWideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'service@carestone.com' LIMIT 1].Id;
        for(Contact contact : (List<Contact>) scope) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(template.Id);
            mail.setTargetObjectId(contact.Id);
            mail.setTreatTargetObjectAsRecipient(true);
            mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
            mails.add(mail);
        }

        if(Utility.checkIfDeliverabilityIsEnabled()) {
            Messaging.sendEmail(mails, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        
    }

    @AuraEnabled
    public static String schedule() {
        NewFileEmailNotificationJob scheduledJob = new NewFileEmailNotificationJob();
        return System.schedule('Dateienübersicht an Community User' + (Test.isRunningTest() ? ' - Test' : ''), scheduleEveryEvening, scheduledJob);
    }
}