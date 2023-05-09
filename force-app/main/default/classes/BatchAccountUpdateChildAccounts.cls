public class BatchAccountUpdateChildAccounts implements Database.Batchable<sObject> {

    public Set<Id> accountIds = new Set<Id>();

    public BatchAccountUpdateChildAccounts(List<Account> accounts) {
        this.accountIds = new Map<Id,Account>(accounts).keySet();
    }

    @InvocableMethod(label='Update Child Account from Account Changes')
    public static void updateChildAccounts(List<Account> accounts) {
        Database.executeBatch(new BatchAccountUpdateChildAccounts(accounts));
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        
        return Database.getQueryLocator(
            [SELECT Id, E_Mail_bergeordneter_Makler__c, Parent.Email__c
            FROM Account 
            WHERE ParentId IN :accountIds]);
    }

    public void execute(Database.BatchableContext context, List<Account> accList) {
        List<Account> accUpdateList = new List<Account>();

        for (Account acc : accList) {
            acc.E_Mail_bergeordneter_Makler__c = acc.Parent.Email__c;
            accUpdateList.add(acc);
            
        }
        update accUpdateList;
    }

    public void finish(Database.BatchableContext context) {
        
    }
}