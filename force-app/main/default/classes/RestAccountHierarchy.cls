@RestResource(urlMapping='/AccountHierarchy')
global with sharing class RestAccountHierarchy  {

    @HttpPost
    global static List<Account> show(Id accId) {

    // Dynamic query to dynamically set the amount of levels
    // level 1 = ChildAccounts
    // level 2 = ChildAccounts + the ChildAccounts of each of those, etc
    String queryString = 'SELECT Id, Name, WHS_Maklerprovision__c, WHS_Maklerauftrag__c, (SELECT Id, Name, WHS_Maklerprovision__c, WHS_Maklerauftrag__c FROM ChildAccounts) FROM Account WHERE Id =: accId';
        List<Account> accs = Database.query(queryString);

        return accs;

    }

}