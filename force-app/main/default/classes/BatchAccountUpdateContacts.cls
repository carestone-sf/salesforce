public class BatchAccountUpdateContacts implements Database.Batchable<sObject> {

    public Set<Id> accountIds = new Set<Id>();

    public BatchAccountUpdateContacts(List<Account> accounts) {
        this.accountIds = new Map<Id,Account>(accounts).keySet();
    }

    @InvocableMethod(label='Update Contacts from Account Changes')
    public static void updateContacts(List<Account> accounts) {
        Database.executeBatch(new BatchAccountUpdateContacts(accounts));
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        
        return Database.getQueryLocator(
            [SELECT Id, OwnerId, MaklerBetreuer_E_Mail__c, Account.OwnerId, Account.Maklerbetreuer_Wirtschaftshaus_2__r.Email
            FROM Contact 
            WHERE AccountId IN :accountIds]);
    }

    public void execute(Database.BatchableContext context, List<Contact> contactList) {
        List<Contact> contUpdateList = new List<Contact>();

        for (Contact contact : contactList) {
            if (contact.OwnerId != contact.Account.OwnerId || contact.MaklerBetreuer_E_Mail__c != contact.Account.Maklerbetreuer_Wirtschaftshaus_2__r.Email) {
                if (contact.OwnerId != contact.Account.OwnerId) {
                    contact.OwnerId = contact.Account.OwnerId;
                }
                if (contact.MaklerBetreuer_E_Mail__c != contact.Account.Maklerbetreuer_Wirtschaftshaus_2__r.Email) {
                    contact.MaklerBetreuer_E_Mail__c = contact.Account.Maklerbetreuer_Wirtschaftshaus_2__r.Email;
                }
                contUpdateList.add(contact);
            }
        }
        update contUpdateList;
    }

    public void finish(Database.BatchableContext context) {
        
    }
}