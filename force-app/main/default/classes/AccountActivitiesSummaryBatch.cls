public without sharing class AccountActivitiesSummaryBatch implements Database.Batchable<sObject> {
    static final DateTime FIRST_DAY_OF_CURRENT_YEAR = DateTime.newInstance(Date.today().year(), 1, 1);
    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('----------started-----------');
        Id brokerageRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brokerage').getRecordTypeId();
        String query = 'SELECT Id, VPUserLastLogin__c, CalculationsCurrentYear__c, CustomersCreatedCurrentYear__c, LastCalculation__c, LastIncomingCall__c, LastOutgoingCall__c, IncomingCallsCurrentYear__c, OutgoingCallsCurrentYear__c, (SELECT Id, AccountId FROM Contacts) FROM Account WHERE RecordTypeId = :brokerageRecordTypeId';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, list<Account> scope) {

        Map<Id, Account> updateAccountsMap = new Map<Id, Account>();
        Map<Id, Account> accountIdToAccounts = new Map<Id, Account>();
        Map<Id, Contact> contactIdToContacts = new Map<Id, Contact>();
        for(Account acc:scope) {
            acc.CalculationsCurrentYear__c = 0;
            acc.CustomersCreatedCurrentYear__c = 0;
            acc.IncomingCallsCurrentYear__c = 0;
            acc.OutgoingCallsCurrentYear__c = 0;
            accountIdToAccounts.put(acc.Id, acc);
            for(Contact con:acc.Contacts) {
                contactIdToContacts.put(con.Id, con);
            }
        }

        // Created Calculations and last calculation date
        for(Berechnung__c b:[SELECT Id, Account__c, CreatedDate FROM Berechnung__c WHERE Account__c IN :accountIdToAccounts.keySet() AND CreatedDate > :FIRST_DAY_OF_CURRENT_YEAR]) {
            Account acc = accountIdToAccounts.get(b.Account__c);
            acc.CalculationsCurrentYear__c++;
            if(acc.LastCalculation__c == null || (acc.LastCalculation__c != null && b.CreatedDate > acc.LastCalculation__c)) {
                acc.LastCalculation__c = b.CreatedDate;
            } 
            updateAccountsMap.put(acc.Id, acc);
        }

        // Created Customers 
        Id interessentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Interessent').getRecordTypeId();
        Id kundeRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Kunde').getRecordTypeId();
        for(Contact con:[SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIdToAccounts.keySet() AND CreatedBy.ContactId != null AND CreatedDate > :FIRST_DAY_OF_CURRENT_YEAR AND (RecordTypeId = :interessentRecordTypeId OR RecordTypeId = :kundeRecordTypeId)]) {
            Account acc = updateAccountsMap.get(con.AccountId) != null ? updateAccountsMap.get(con.AccountId) : accountIdToAccounts.get(con.AccountId);
            acc.CustomersCreatedCurrentYear__c++;
            updateAccountsMap.put(acc.Id, acc);
        }

        // Last Login Date
        for(Contact con:[SELECT Id, AccountId, VPBenutzerLetzterLogin__c FROM Contact WHERE AccountId IN :accountIdToAccounts.keySet() AND CommunityUser__c != null AND VPBenutzerLetzterLogin__c != null]) {
            Account acc = updateAccountsMap.get(con.AccountId) != null ? updateAccountsMap.get(con.AccountId) : accountIdToAccounts.get(con.AccountId);
            if(acc.VPUserLastLogin__c == null || (acc.VPUserLastLogin__c != null && con.VPBenutzerLetzterLogin__c > acc.VPUserLastLogin__c)) {
                acc.VPUserLastLogin__c = con.VPBenutzerLetzterLogin__c;
            }
            updateAccountsMap.put(acc.Id, acc);
        }

        // Tasks data
        for(Task t:[SELECT WhoId, WhatId, Subject, CreatedDate FROM Task WHERE CreatedDate > :FIRST_DAY_OF_CURRENT_YEAR AND WhatId IN :accountIdToAccounts.keySet()]) {
            Contact con = contactIdToContacts.get(t.WhoId);
            Account acc = updateAccountsMap.get(con.AccountId) != null ? updateAccountsMap.get(con.AccountId) : accountIdToAccounts.get(con.AccountId);
            if(t.Subject.toLowerCase().indexOf('eingehend') > -1 || t.Subject.toLowerCase().indexOf('incoming') > -1) {
                acc.IncomingCallsCurrentYear__c++;
                if(acc.LastIncomingCall__c == null || (acc.LastIncomingCall__c != null && t.CreatedDate > acc.LastIncomingCall__c)) {
                    acc.LastIncomingCall__c = t.CreatedDate;
                } 
            } else if(t.Subject.toLowerCase().indexOf('ausgehend') > -1 || t.Subject.toLowerCase().indexOf('outgoing') > -1) {
                acc.OutgoingCallsCurrentYear__c++;
                if(acc.LastOutgoingCall__c == null || (acc.LastOutgoingCall__c != null && t.CreatedDate > acc.LastOutgoingCall__c)) {
                    acc.LastOutgoingCall__c = t.CreatedDate;
                } 
            }
            updateAccountsMap.put(acc.Id, acc);
        }

        update updateAccountsMap.values();
    }

    public void finish(Database.BatchableContext BC) {
        system.debug('----------finished-----------');
    }
}