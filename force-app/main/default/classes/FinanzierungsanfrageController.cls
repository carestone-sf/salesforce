public with sharing class FinanzierungsanfrageController {

    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getContentVersions(Id recordId) {
        List<ContentDocumentLink> cdls = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];

        List<Id> contentDocumentIds = new List<Id>();
        for(ContentDocumentLink cdl:cdls) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        List<ContentVersion> cvs = [SELECT Id, Typ__c FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];
        return cvs;
    }

    @AuraEnabled(cacheable=true)
    public static Map<Id, List<ContentVersion>> getContentVersionsMap(List<Id> recordIds) {
        if(recordIds.size() == 0) {
            return new Map<Id, List<ContentVersion>>();
        }
        List<ContentDocumentLink> cdls = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :recordIds];

        Map<Id, Id> contentDocumentIdToRecordId = new Map<Id, Id>();
        for(ContentDocumentLink cdl:cdls) {
            contentDocumentIdToRecordId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
        }

        Map<Id, List<ContentVersion>> recordIdToContentVersions = new Map<Id, List<ContentVersion>>();
        List<ContentVersion> cvs = [SELECT Id, Typ__c, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIdToRecordId.keySet()];
        for(ContentVersion cv:cvs) {
            Id recordId = contentDocumentIdToRecordId.get(cv.ContentDocumentId);
            List<ContentVersion> currentCvs = recordIdToContentVersions.get(recordId);
            if(currentCvs == null) {
                currentCvs = new List<ContentVersion>();
            }
            currentCvs.add(cv);
            recordIdToContentVersions.put(recordId, currentCvs);
        }
        return recordIdToContentVersions;
    }
}