public with sharing class AccountDeduplicatorBatch implements Database.Batchable<SObject>, Database.Stateful {

    private Id parentAccountId;
    public Integer totalMerged = 0;

    public AccountDeduplicatorBatch(Id parentAccountId) {
        this.parentAccountId = parentAccountId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name
            FROM Account
            WHERE ParentId = :parentAccountId
            ORDER BY Name, CreatedDate
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        Map<String, List<Account>> nameToAccounts = new Map<String, List<Account>>();

        for (Account acc : scope) {
            if (String.isBlank(acc.Name)) continue;
            if (!nameToAccounts.containsKey(acc.Name)) {
                nameToAccounts.put(acc.Name, new List<Account>());
            }
            nameToAccounts.get(acc.Name).add(acc);
        }

        for (String name : nameToAccounts.keySet()) {
            List<Account> accounts = nameToAccounts.get(name);

            if (accounts.size() > 1) {
                // Find the oldest account as master
                Account master = accounts[0];

                // Collect all other accounts as duplicates
                List<Account> dupes = new List<Account>();
                for (Account a : accounts) {
                    if (a.Id != master.Id) {
                        dupes.add(a);
                    }
                }

                // Merge dupes into master, 3 at a time
                Integer i = 0;
                while (i < dupes.size()) {
                    List<Account> mergeGroup = new List<Account>();
                    for (Integer j = 0; j < 2 && (i + j) < dupes.size(); j++) {
                        mergeGroup.add(dupes[i + j]);
                    }
                    try {
                        merge master mergeGroup;
                        totalMerged += mergeGroup.size();
                    } catch (Exception e) {
                        System.debug('Merge failed: ' + e.getMessage());
                    }
                    i += 2;
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Total merged: ' + totalMerged);
    }
}