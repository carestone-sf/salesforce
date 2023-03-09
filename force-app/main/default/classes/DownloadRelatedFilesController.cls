public with sharing class DownloadRelatedFilesController {
    
    @AuraEnabled
    public static List<Id> getRelatedContentVersionIds(Id recordId) {
        List<Id> relatedVersionIds = new List<Id>();
        for(ContentVersion cv : [SELECT Id FROM ContentVersion WHERE IsLatest = true AND ContentDocumentId IN :getRelatedDocumentIds(recordId)]) {
            relatedVersionIds.add(cv.Id);
        }
        return relatedVersionIds;
    }

    @AuraEnabled
    public static List<FileWrapper> getRelatedContentVersions(Id recordId){
        List<FileWrapper> files = new List<FileWrapper>();
        for(ContentVersion cv : [SELECT Id, VersionData, Title, FileExtension FROM ContentVersion WHERE IsLatest = true AND ContentDocumentId IN :getRelatedDocumentIds(recordId)]) {
            files.add(new FileWrapper(cv));
        }
        return files;
    }

    public static List<Id> getRelatedDocumentIds(Id recordId) {
        Set<Id> documentIds = new Set<Id>();
        for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId]) {
            documentIds.add(cdl.ContentDocumentId);
        }
        return new List<Id>(documentIds);
    }

    public class FileWrapper {
        @AuraEnabled public String title {get;set;}
        @AuraEnabled public String data {get;set;}
        @AuraEnabled public String extension {get;set;}

        public FileWrapper(ContentVersion cv ){
            this.title = cv.title;
            this.data = EncodingUtil.base64Encode(cv.VersionData);
            this.extension = cv.FileExtension;
        }
    }
}
