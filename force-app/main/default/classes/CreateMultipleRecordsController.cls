public without sharing class CreateMultipleRecordsController {
    @AuraEnabled(cacheable=true)
    public static List<sObject> getRecords(Id recordId, String objectApiName, String fields) {
        String query = 'SELECT ';
        String filter = 'WHERE DigitaleVsa__c = \'' + recordId + '\'';
        String fromClause = 'FROM ' + objectApiName;

        query += fields + ' ' + fromClause + ' ' + filter;

        return Database.query(query);
    }
}