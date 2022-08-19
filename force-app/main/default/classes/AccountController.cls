public with sharing class AccountController {
    
    @AuraEnabled(cacheable=true)
    public static Account getAccountFromContactId(Id contactId) {
        List<Account> accs = [SELECT Id, Name FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id = :contactId)];
        if(accs.size() > 0) {
            return accs[0];
        }
        return null;
    }

}