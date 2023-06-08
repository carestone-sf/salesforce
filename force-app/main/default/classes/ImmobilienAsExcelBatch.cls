global without sharing class ImmobilienAsExcelBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        
        String query = 'SELECT Id, Gesch_ftsbeziehung__c, Email, Account.Maklerbetreuer_Wirtschaftshaus_2__r.Name FROM Contact WHERE HasOptedOutOfEmail = FALSE AND Objektliste_abbestellen__c = FALSE AND Gesch_ftsbeziehung__c includes (\'Finanzmakler\',\'Finanz- und Versicherungsmakler\', \'Immobilien- oder Versicherungsmakler\', \'Versicherungsmakler\', \'Immobilienmakler\', \'Mitarbeiter WH\') AND Gesch_ftsbeziehung__c != null AND Email != null AND (Account.WHS_Maklerauftrag__c = \'Maklerauftrag beidseitig unterzeichnet\' OR Account.WHS_Maklerauftrag__c = \'Makler mit altem Vertrag\' OR Account.Carestone_Vertriebsvereinbarung__c = true) Order By AccountId';
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Contact> scope)
    {
        ImmobilienAsExcel iae = new ImmobilienAsExcel();
        iae.sendexcelfile(scope);
    }  
    global void finish(Database.BatchableContext BC)
    {
    }
}