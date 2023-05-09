public class BatchAccountUpdateStructure implements Database.Batchable<sObject> {

    public Account sourceAccount = new Account();
    public Set<Id> sourceAccountId = new Set<Id>();

    public BatchAccountUpdateStructure(List<Account> accounts) {
        this.sourceAccount = accounts[0];
        this.sourceAccountId = new Map<Id,Account>(accounts).keySet();
    }

    @InvocableMethod(label='Update Structure/Hierarchy of Accounts')
    public static void updateStructure(List<Account> accounts) {
        Database.executeBatch(new BatchAccountUpdateStructure(accounts));
    }

    public List<Account> start(Database.BatchableContext context) {
        List<Id> parentAccs = new List<Id>();
        parentAccs.addAll(sourceAccountId);
        List<Account> childAccs = new List<Account>();
        List<Account> children;

        do {
            children = [SELECT Id, OwnerId, Maklerbetreuer_Wirtschaftshaus_2__c FROM Account WHERE ParentId IN :parentAccs];
            childAccs.addAll(children);
            parentAccs.clear();
            for (Account child : children) {
                parentAccs.add(child.Id);
            }
        } while (children.size() > 0);
        
        return childAccs;
    }

    public void execute(Database.BatchableContext context, List<Account> accList) {
        List<Account> accUpdateList = new List<Account>();
        Account parentAcc = sourceAccount;

        for (Account acc : accList) {
            acc.OwnerId = parentAcc.OwnerId;
            acc.Maklerbetreuer_Wirtschaftshaus_2__c = parentAcc.Maklerbetreuer_Wirtschaftshaus_2__c;
            accUpdateList.add(acc);
            
        }
        update accUpdateList;
    }

    public void finish(Database.BatchableContext context) {
        
    }
}