public without sharing class FinanzierungsanfrageService {

    public static void sendFinanzierungsbestaetigung(Id finanzierungsanfrageId) {
        if (finanzierungsanfrageId == null) {
            return;
        }

        Finanzierungsanfrage__c fa = [
            SELECT Id,
                   Name,
                   Opportunity__c,
                   Opportunity__r.Makler__c
            FROM Finanzierungsanfrage__c
            WHERE Id = :finanzierungsanfrageId
            LIMIT 1
        ];

        // If there is no Opportunity or Makler, we can't send the email
        if (fa.Opportunity__c == null || fa.Opportunity__r.Makler__c == null) {
            return;
        }

        // Build PDF from Visualforce page
        PageReference pdfPage = Page.Finanzierungsbestaetigung;
        pdfPage.getParameters().put('id', fa.Id);

        Blob pdfBody;
        if (Test.isRunningTest()) {
            // getContentAsPDF is not allowed in tests
            pdfBody = Blob.valueOf('Test PDF content');
        } else {
            try {
                pdfBody = pdfPage.getContentAsPDF();
            } catch (Exception e) {
                pdfBody = Blob.valueOf('Fehler beim Generieren des PDFs.');
            }
        }

        String fileName = 'Finanzierungsbestaetigung ' + fa.Name + '.pdf';
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setContentType('application/pdf');
        attachment.setFileName(fileName);
        attachment.setInline(false);
        attachment.setBody(pdfBody);

        // Try to get the email template, but make tests robust if it doesn't exist
        Id templateId = null;
        if (!Test.isRunningTest()) {
            try {
                templateId = [
                    SELECT Id
                    FROM EmailTemplate
                    WHERE DeveloperName = 'VSA_genehmigt'
                    AND IsActive = true
                    LIMIT 1
                ].Id;
            } catch (Exception e) {
                // leave templateId = null
            }
        }

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        if (templateId != null) {
            email.setTemplateId(templateId);
        } else {
            // Fallback for test / missing template
            email.setSubject('Finanzierungsbestätigung');
            email.setPlainTextBody('Ihre Finanzierungsbestätigung befindet sich im Anhang.');
        }

        email.setTargetObjectId(fa.Opportunity__r.Makler__c);
        email.setWhatId(fa.Opportunity__c);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        email.setSaveAsActivity(true);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email }, false);

        ContentVersion file = new ContentVersion();
        file.VersionData = pdfBody;
        file.Title = fileName; 
        file.ContentLocation= 's';
        file.PathOnClient=fileName;
        Id finanzierungsanfragenRecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('Finanzierungsanfragen').getRecordTypeId();
        file.Typ__c = 'Finanzierungsbestätigung (FB)';
        file.RecordTypeId = finanzierungsanfragenRecordTypeId;
        insert file;
        
        List<ContentVersion> files = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :file.Id];

        if(files.size() > 0) {
            file = files[0];
            ContentDocumentLink cdeFa = new ContentDocumentLink();
            cdeFa.ContentDocumentId = file.ContentDocumentId;
            cdeFa.LinkedEntityId = fa.Id;

            ContentDocumentLink cdeOpportunity = new ContentDocumentLink();
            cdeOpportunity.ContentDocumentId = file.ContentDocumentId;
            cdeOpportunity.LinkedEntityId = fa.Opportunity__c;
            insert new List<ContentDocumentLink>{cdeFa, cdeOpportunity};
        }
    }
}