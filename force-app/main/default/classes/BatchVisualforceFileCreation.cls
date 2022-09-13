global class BatchVisualforceFileCreation implements Database.Batchable<FileCreationRequest> {

    List<FileCreationRequest> requests;

    public BatchVisualforceFileCreation(List<FileCreationRequest> requests) {
        this.requests = requests;
    }

    global Iterable<FileCreationRequest> start(Database.BatchableContext info){
        return new FileCreationRequestIterable(this.requests);
    }

    global void execute(Database.BatchableContext info, List<FileCreationRequest> scope){
        List<ContentVersion> files = new List<ContentVersion>();
        Set<String> emailTemplateDeveloperNames = new Set<String>();

        Map<Id,List<Messaging.EmailFileAttachment>> mapMailAttachmentsByRecordId = new Map<Id,List<Messaging.EmailFileAttachment>>();

        for(FileCreationRequest request : (List<FileCreationRequest>) scope) {

            request.pageRef.getParameters().put('id', request.recordId);

            if(request.title.length() > 255) {
                request.title = request.title.substring(0, 255);
            }
    
            ContentVersion file = new ContentVersion();
            file.VersionData = Test.isRunningTest() ? Blob.valueOf('*') : request.pageRef.getContentAsPDF();
            file.Title = request.title; 
            file.ContentLocation= 's';
            file.PathOnClient = request.title + '.pdf';
    
            file.Typ__c = request.fileType;
            file.RecordTypeId = request.contentVersionRecordTypeId;
            file.FirstPublishLocationId = request.recordId;

            files.add(file);

            for(FileCreationRequest.SendEmailRequest sendEmailRequest : request.sendEmailRequests) {
                emailTemplateDeveloperNames.add(sendEmailRequest.emailTemplateDeveloperName);
            }

            Messaging.EmailFileAttachment mailAttachment = new Messaging.EmailFileAttachment();
            mailAttachment.setContentType('application/pdf');
            mailAttachment.setFileName(file.PathOnClient);
            mailAttachment.setInline(false);
            mailAttachment.setBody(file.VersionData);
            if(mapMailAttachmentsByRecordId.containsKey(request.recordId)) {
                mapMailAttachmentsByRecordId.get(request.recordId).add(mailAttachment);
            } else {
                mapMailAttachmentsByRecordId.put(request.recordId, new List<Messaging.EmailFileAttachment> {
                    mailAttachment
                });
            }
        }
        
        insert files;

        Map<Id,Set<Id>> mapContentVersionIdsByFirstPublishLocationIds = new Map<Id,Set<Id>>();
        for(ContentVersion cv : files) {
            if(mapContentVersionIdsByFirstPublishLocationIds.containsKey(cv.FirstPublishLocationId)) {
                mapContentVersionIdsByFirstPublishLocationIds.get(cv.FirstPublishLocationId).add(cv.Id);
            } else {
                mapContentVersionIdsByFirstPublishLocationIds.put(cv.FirstPublishLocationId, new Set<Id> {cv.Id});
            }
        }

        Map<String,EmailTemplate> mapTemplatesByDeveloperNames = new Map<String, EmailTemplate>();
        for(EmailTemplate template : [SELECT Id, DeveloperName, Subject, Body FROM EmailTemplate WHERE DeveloperName IN :emailTemplateDeveloperNames]) {
            mapTemplatesByDeveloperNames.put(template.DeveloperName, template);
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(FileCreationRequest request : (List<FileCreationRequest>) scope) {
            for(FileCreationRequest.SendEmailRequest sendEmailRequest : request.sendEmailRequests) {
                EmailTemplate template = mapTemplatesByDeveloperNames.get(sendEmailRequest.emailTemplateDeveloperName);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(template.Id);
                mail.setToAddresses(sendEmailRequest.toAddresses);
                mail.setTargetObjectId(sendEmailRequest.targetObjectId);
                mail.setTreatTargetObjectAsRecipient(sendEmailRequest.targetObjectIsRecipient);
                mail.setWhatId(request.recordId);
                mail.setSaveAsActivity(false);
                if(sendEmailRequest.orgWideEmailAddressId != null) {
                    mail.setOrgWideEmailAddressId(sendEmailRequest.orgWideEmailAddressId);
                }
                if(mapMailAttachmentsByRecordId.containsKey(request.recordId)) {
                    mail.setFileAttachments(mapMailAttachmentsByRecordId.get(request.recordId));
                }
                mails.add(mail);
            }
        }

        System.debug(mails[0]);
        if(Utility.checkIfDeliverabilityIsEnabled()) {
            Messaging.sendEmail(mails, true);
        }
    }

    global void finish(Database.BatchableContext info) {

    }
}
