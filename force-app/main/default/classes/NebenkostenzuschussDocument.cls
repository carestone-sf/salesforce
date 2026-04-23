public without sharing class NebenkostenzuschussDocument {

    @Future(callout=true)
    public static void sendNKZAsPdf(Id id) {
        if (id == null) {
            return;
        }

        List<Nebenkostenzuschuss__c> records = [SELECT Id, LaufnummerNew__c, Empfaenger__c, Empfaenger__r.Email, Empfaenger__r.EmailForCreditNotes__c FROM Nebenkostenzuschuss__c WHERE Id = :id];
        if (records.isEmpty()) {
            return;
        }
        Nebenkostenzuschuss__c nkzRecord = records.get(0);
        PageReference pdf = Page.NebenkostenzuschussBeleg;
        pdf.getParameters().put('id', nkzRecord.Id);


        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.ContentType = 'application/pdf';
        Blob body;
        try {
            body = pdf.getContentAsPDF();
        } catch (Exception e) {
            body = blob.valueOf('Ein Fehler ist aufgetreten');
        }
        String fileName = 'Nebenkostenzuschuss ' + nkzRecord.LaufnummerNew__c + '.pdf';
        attach.setFileName(fileName);
        attach.setInline(false);
        attach.Body = body;

        Id templateId;
        try {
            templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'NKZ'].Id;
        } catch (Exception e) {
            templateId = null;
        }
        List<OrgWideEmailAddress> oweas = new List<OrgWideEmailAddress>([SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE Address = 'maklerbetreuung@wirtschaftshaus.de']);
        Boolean emailToRecipientSent = false;
        Messaging.SingleEmailMessage emailToEmpfaenger;

        if (nkzRecord.Empfaenger__c != null) {
            Messaging.Email[] messages = new Messaging.Email[0];
            emailToEmpfaenger = new Messaging.SingleEmailMessage();
            if (templateId != null) {
                emailToEmpfaenger.setTemplateId(templateId);
            }
            emailToEmpfaenger.setTargetObjectId(nkzRecord.Empfaenger__c);
            if(nkzRecord.Empfaenger__r.EmailForCreditNotes__c != null) {
                emailToEmpfaenger.setTreatTargetObjectAsRecipient(false);
                emailToEmpfaenger.setToAddresses(new String[]{nkzRecord.Empfaenger__r.EmailForCreditNotes__c});
            }
            emailToEmpfaenger.setWhatId(nkzRecord.Id);
            if (oweas.size() > 0) {
                emailToEmpfaenger.setOrgWideEmailAddressId(oweas.get(0).Id);
            }
            emailToEmpfaenger.setFileAttachments(new Messaging.EmailFileAttachment[]{
                    attach
            });
            messages.add(emailToEmpfaenger);
            try {
                Messaging.SendEmailResult [] r = Messaging.sendEmail(messages, false);
                emailToRecipientSent = !r.isEmpty() && r[0].isSuccess();
                System.debug(r);
            } catch (Exception e) {
                emailToRecipientSent = false;
            }
        }

        Messaging.SingleEmailMessage emailToFibu = new Messaging.SingleEmailMessage();

        String[] toMails = new List < String > ();
        toMails.add('fibu@carestone.com');
        emailToFibu.setToAddresses(toMails);
        if (oweas.size() > 0) {
            emailToFibu.setOrgWideEmailAddressId(oweas.get(0).Id);
        }

        if(emailToRecipientSent && emailToEmpfaenger != null) {
            emailToFibu.setHtmlBody(emailToEmpfaenger.getHtmlBody());

            emailToFibu.setPlainTextBody(emailToEmpfaenger.getPlainTextBody());

            emailToFibu.setSubject(emailToEmpfaenger.getSubject());

            emailToFibu.setFileAttachments(emailToEmpfaenger.getFileAttachments());
        } else {
            emailToFibu.setPlainTextBody('Für den Nebenkostenzuschuss wurde ein Beleg generiert und konnte nicht per Mail an den Empfänger zugestellt werden.');

            emailToFibu.setSubject('Nebenkostenzuschuss ' + nkzRecord.LaufnummerNew__c);

            emailToFibu.setFileAttachments(new Messaging.EmailFileAttachment[]{
                    attach
            });
        }

        if(Utility.checkIfDeliverabilityIsEnabled()) {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                emailToFibu
            });
        }
        User u = [SELECT IsActive,IsPortalEnabled,LastName FROM User WHERE Id = :UserInfo.getUserId()];
        ContentVersion file = new ContentVersion();
        file.VersionData = body;
        file.Title = fileName;
        file.ContentLocation= 's';
        file.PathOnClient=fileName;
        Id nkzRecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('Gutschriften').getRecordTypeId();
        file.Typ__c = 'Nebenkostenzuschuss';
        file.RecordTypeId = nkzRecordTypeId;
        if(u.IsPortalEnabled) {
            Id networkId = [SELECT Id FROM Network LIMIT 1].Id;
            file.NetworkId = networkId;
        }
        nkzRecord.BelegWurdeGeneriert__c = true;
        insert file;

        List<ContentVersion> files = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :file.Id];

        if(files.size() > 0) {
            file = files[0];
            ContentDocumentLink cde = new ContentDocumentLink();
            cde.ContentDocumentId = file.ContentDocumentId;
            cde.LinkedEntityId = nkzRecord.Id;
            insert cde;
            update nkzRecord;
        }
    }
}
