public class CreateAttachmentsFromFiles {
    @InvocableMethod(label='Create or Update DMS folder' description='Takes a list of ids.')
    public static List<Results> createAttachmentsFromFiles(List<Requests> requests) {
        List<Id> recordIds = new List<Id>();
        Map<Id, Id> recordIdsToParentIds = new Map<Id, Id>();
        Map<Id, Boolean> recordIdsToIsStorno = new Map<Id, Boolean>();
        List<Results> results = new List<Results>();

        for(Requests request: requests) {
            if(request.recordId != null) {
                recordIds.add(request.recordId);
                recordIdsToParentIds.put(request.recordId, request.parentId);
                recordIdsToIsStorno.put(request.recordId, request.isStorno);
            }
        }

        List<ContentDocumentLink> contentDocumentLinks = [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :recordIds];
        Map<Id, ContentDocumentLink> contentDocumentIdToContentDocumentLink = new Map<Id, ContentDocumentLink>();
        for(ContentDocumentLink cdl:contentDocumentLinks) {
            contentDocumentIdToContentDocumentLink.put(cdl.ContentDocumentId, cdl);
        }

        List<ContentVersion> contentVersions = [SELECT Id, PathOnClient, Title, VersionData, ContentDocumentId, FileType FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIdToContentDocumentLink.keySet()];
        

        Map<Id, ContentVersion> recordIdToContentVersion = new Map<Id, ContentVersion>();
        for(ContentVersion cv:contentVersions) {
            ContentDocumentLink cdl = contentDocumentIdToContentDocumentLink.get(cv.ContentDocumentId);
            Boolean isStorno = recordIdsToIsStorno.get(cdl.LinkedEntityId);
            if(isStorno && (cv.Title.contains('Storno') || cv.Title.contains('SB'))) {
                recordIdToContentVersion.put(cdl.LinkedEntityId, cv);
            } else if(!isStorno && (cv.Title.contains('Rechnung') || cv.Title.contains('Gutschrift'))) {
                recordIdToContentVersion.put(cdl.LinkedEntityId, cv);
            }
        }


        List<Attachment> atts = new List<attachment>();
        for(Id recordId:recordIds) {
            ContentVersion cv = recordIdToContentVersion.get(recordId);
            Attachment att = new Attachment();
            //att.ContentType = cv.FileType;
            att.Body = cv.VersionData;
            att.Name = cv.PathOnClient;
            att.ParentId = recordIdsToParentIds.get(recordId);
            atts.add(att);
        }
        insert atts;


        for(Id recordId:recordIds) {
            Results res = new Results();
            res.success = true;
            results.add(res);
        }

        return results;
    }

    public class Requests {
        @InvocableVariable(label='Record id for Input' required=true)
        public Id recordId;

        @InvocableVariable(label='parent id for Input' required=true)
        public Id parentId;

        @InvocableVariable(label='is storno?' required=true)
        public Boolean isStorno;
    }

    public class Results {
        @InvocableVariable(label='Records for Output' description='yourDescription' required=true)
        public Boolean success;
    }
}