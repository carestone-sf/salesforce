public without sharing class OpportunityService {

    public static void sendNebenkostenzuschuss(Id opportunityId) {
        if (opportunityId == null) {
            return;
        }

        Opportunity opp = [
            SELECT Id,
                   Name,
                   Vertriebskoordinator__c,
                   Immobilie__r.Name,
                   Appartement__r.Name,
                   Potenzieller_Kunde__r.LastName
            FROM Opportunity
            WHERE Id = :opportunityId
            LIMIT 1
        ];

        // We need a recipient
        if (opp.Vertriebskoordinator__c == null) {
            return;
        }

        /* =========================
           PDF GENERATION
           ========================= */
        PageReference pdfPage = Page.Nebenkostenzuschuss; // VF page
        pdfPage.getParameters().put('id', opp.Id);

        Blob pdfBody;
        if (Test.isRunningTest()) {
            pdfBody = Blob.valueOf('Test PDF content');
        } else {
            try {
                pdfBody = pdfPage.getContentAsPDF();
            } catch (Exception e) {
                pdfBody = Blob.valueOf('Fehler beim Generieren des PDFs.');
            }
        }

        String fileName =
            opp.Immobilie__r.Name + '_' +
            opp.Appartement__r.Name + '_' +
            opp.Potenzieller_Kunde__r.LastName +
            '_Erstattung.pdf';

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setContentType('application/pdf');
        attachment.setFileName(fileName);
        attachment.setInline(false);
        attachment.setBody(pdfBody);

        /* =========================
           EMAIL TEMPLATE
           ========================= */
        Id templateId = null;
        if (!Test.isRunningTest()) {
            try {
                templateId = [
                    SELECT Id
                    FROM EmailTemplate
                    WHERE DeveloperName = 'Nebenkostenzuschuss'
                    AND IsActive = true
                    LIMIT 1
                ].Id;
            } catch (Exception e) {
                // fallback below
            }
        }

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        if (templateId != null) {
            email.setTemplateId(templateId);
        } else {
            email.setSubject('Nebenkostenzuschuss');
            email.setPlainTextBody('Informationen zum Nebenkostenzuschuss.');
        }

        email.setTargetObjectId(opp.Vertriebskoordinator__c);
        email.setWhatId(opp.Id);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        email.setSaveAsActivity(true);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email }, false);

        /* =========================
           FILE STORAGE
           ========================= */
        ContentVersion file = new ContentVersion();
        file.VersionData     = pdfBody;
        file.Title           = fileName;
        file.PathOnClient    = fileName;
        file.ContentLocation = 's';
        file.Typ__c = 'Nebenkostenzuschuss';
        file.RecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('VKC').getRecordTypeId();

        insert file;

        ContentVersion storedFile = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :file.Id
            LIMIT 1
        ];

        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = storedFile.ContentDocumentId;
        link.LinkedEntityId    = opp.Id;
        link.ShareType         = 'V';
        link.Visibility        = 'AllUsers';

        insert link;
    }
}