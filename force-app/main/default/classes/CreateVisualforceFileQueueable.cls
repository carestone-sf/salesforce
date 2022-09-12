public with sharing class CreateVisualforceFileQueueable implements Queueable, Database.AllowsCallouts {

    private List<FileCreationRequest> requests;

    private Finalizer finalizer;

    public CreateVisualforceFileQueueable(List<FileCreationRequest> requests) {
        this.requests = requests;
    }

    public CreateVisualforceFileQueueable setFinalizer(Finalizer finalizer) {
        this.finalizer = finalizer;
        return this;
    }

    public void execute(QueueableContext ctx) {
        if(this.finalizer != null) {
            System.attachFinalizer(finalizer);
        }
        List<ContentVersion> files = new List<ContentVersion>();
        for(FileCreationRequest request : requests) {

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
        }
        
        insert files;
    }

    public class FileCreationRequest {

        Id recordId;
        PageReference pageRef;
        String title;
        String fileType;
        Id contentVersionRecordTypeId;

        public FileCreationRequest(Id recordId, PageReference pageRef, String title, String fileType, Id contentVersionRecordTypeId) {
            this.recordId = recordId;
            this.pageRef = pageRef;
            this.title = title;
            this.fileType = fileType;
            this.contentVersionRecordTypeId = contentVersionRecordTypeId;
        }

        public Id getRecordId() {
            return this.recordId;
        }
    }


    public class SendEmailFinalizer implements Finalizer {

        List<SendEmailRequest> requests;

        public SendEmailFinalizer(List<SendEmailRequest> requests) {
            this.requests = requests;
        }
        
        public void execute(FinalizerContext ctx) {
            Set<String> emailTemplateDeveloperNames = new Set<String>();
            for(SendEmailRequest request : this.requests) {
                emailTemplateDeveloperNames.add(request.emailTemplateDeveloperName);
            }

            Map<String,EmailTemplate> mapTemplatesByDeveloperNames = new Map<String, EmailTemplate>();
            for(EmailTemplate template : [SELECT Id, DeveloperName, Subject, Body FROM EmailTemplate WHERE DeveloperName IN :emailTemplateDeveloperNames]) {
                mapTemplatesByDeveloperNames.put(template.DeveloperName, template);
            }

            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(SendEmailRequest request : this.requests) {
                EmailTemplate template = mapTemplatesByDeveloperNames.get(request.emailTemplateDeveloperName);

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(template.Id);
                mail.setToAddresses(request.toAddresses);
                mail.setTargetObjectId(UserInfo.getUserId());
                mail.setWhatId(request.recordId);
                mail.setSaveAsActivity(false);
                if(request.orgWideEmailAddressId != null) {
                    mail.setOrgWideEmailAddressId(request.orgWideEmailAddressId);
                }
                mails.add(mail);
            }
            
            if(Utility.checkIfDeliverabilityIsEnabled()) {
                try {
                    Messaging.sendEmail(mails, false);
                    return;
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }
            }
        }
    }

    public class SendEmailRequest {

        private String emailTemplateDeveloperName;
        private Id recordId;
        private Id orgWideEmailAddressId;
        List<String> toAddresses;
        
        public SendEmailRequest(String emailTemplateDeveloperName, Id recordId, Id orgWideEmailAddressId, List<String> toAddresses) {
            this.emailTemplateDeveloperName = emailTemplateDeveloperName;
            this.recordId = recordId;
            this.orgWideEmailAddressId = orgWideEmailAddressId;
            this.toAddresses = toAddresses;
        }
    } 
}
