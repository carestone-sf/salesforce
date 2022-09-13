global with sharing class FileCreationRequest {
    
    global Id recordId;
    global PageReference pageRef;
    global String title;
    global String fileType;
    global Id contentVersionRecordTypeId;
    global List<SendEmailRequest> sendEmailRequests;

    global FileCreationRequest(Id recordId, PageReference pageRef, String title, String fileType, Id contentVersionRecordTypeId) {
        this.recordId = recordId;
        this.pageRef = pageRef;
        this.title = title;
        this.fileType = fileType;
        this.contentVersionRecordTypeId = contentVersionRecordTypeId;
        this.sendEmailRequests = sendEmailRequests;
    }

    global FileCreationRequest setSendEmailRequests(List<SendEmailRequest> sendEmailRequests) {
        this.sendEmailRequests = sendEmailRequests;
        return this;
    }


    global class SendEmailRequest {

        global Id targetObjectId;
        global Boolean targetObjectIsRecipient;
        global String emailTemplateDeveloperName;
        global Id orgWideEmailAddressId;
        global List<String> toAddresses;
        
        global SendEmailRequest(Id targetObjectId, Boolean targetObjectIsRecipient, String emailTemplateDeveloperName, Id orgWideEmailAddressId, List<String> toAddresses) {
            this.targetObjectId = targetObjectId;
            this.targetObjectIsRecipient = targetObjectIsRecipient;
            this.emailTemplateDeveloperName = emailTemplateDeveloperName;
            this.orgWideEmailAddressId = orgWideEmailAddressId;
            this.toAddresses = toAddresses;
        }
    } 
}
