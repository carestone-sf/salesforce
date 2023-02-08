public with sharing class BatchAddSuffixToAllContactsEmails implements Database.Batchable<sObject>{
    @TestVisible
    private static final string SUFFIX_TO_ADD ='.invalid';
    public BatchAddSuffixToAllContactsEmails() {

    }

    public List<Contact> start(Database.BatchableContext BC){
        system.debug('----------started-----------');
        return [
            SELECT id,email 
            FROM Contact 
        ];
    }

    public void execute(Database.BatchableContext BC, List<Contact> scope){
        List<contact> contactsToUpdate = new List<Contact>();
        for(contact contactToEdit : scope){
            if(!contactToEdit.email.endsWith(BatchAddSuffixToAllContactsEmails.SUFFIX_TO_ADD)){
                contactToEdit.email+= BatchAddSuffixToAllContactsEmails.SUFFIX_TO_ADD;
                contactsToUpdate.add(contactToEdit);
            }
        }
        update contactsToUpdate;
    }

    public void finish(Database.BatchableContext BC){
            AsyncApexJob a = [
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email 
                FROM AsyncApexJob 
                WHERE Id = :bc.getJobId()
            ];
            String emailBody ='BatchAddSuffixToAllContactsEmails batch processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.';
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toaddresses = new String[] {UserInfo.getUserEmail()};
            message.optOutPolicy = 'FILTER';
			message.subject = 'BatchAddSuffixToAllContactsEmails batch status';
            message.plainTextBody = emailBody;
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) 
			{
    			System.debug('The email was sent successfully.');
			} else 
			{
    			System.debug('The email failed to send: ' + results[0].errors[0].message);
			}
            system.debug('----------finished-----------');
    }
}