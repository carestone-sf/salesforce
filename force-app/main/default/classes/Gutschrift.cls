/**
 * Created by frederikwitte on 29.03.20.
 */

public without sharing class Gutschrift {

    @Future(callout=true)
    public static void sendGutschriftAsPdf(Id id) {
        List<Gutschrift__c> gutschriften = [SELECT Id, LaufnummerNew__c, Empfaenger__c FROM Gutschrift__c WHERE Id = :id];
        Gutschrift__c gutschriftRecord = gutschriften.get(0);
        PageReference pdf = Page.Gutschrift;
        pdf.getParameters().put('id', gutschriftRecord.Id);


        // Blob und E-Mail Anhang aus dem String generieren
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.ContentType = 'application/pdf';
        Blob body;
        try {
            body = pdf.getContentAsPDF();
        } catch (Exception e) {
            body = blob.valueOf('Ein Fehler ist aufgetreten');
        }
        // Dateiname der CSV
        String fileName = 'Gutschrift ' + gutschriftRecord.LaufnummerNew__c + '.pdf';
        attach.setFileName(fileName);
        attach.setInline(false);
        attach.Body = body;

        Id templateId = [SELECT id, name FROM EmailTemplate WHERE developername = 'Gutschrift'].id;
        List<OrgWideEmailAddress> oweas = new List<OrgWideEmailAddress>([SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE Address = 'maklerbetreuung@wirtschaftshaus.de']);
        Messaging.Email[] messages = new Messaging.Email[0];
        // SingleEmailMessage erstellen
        Messaging.SingleEmailMessage emailToBroker = new Messaging.SingleEmailMessage();
        emailToBroker.setTemplateId(templateId);
        emailToBroker.setTargetObjectId(gutschriftRecord.Empfaenger__c);
        emailToBroker.setWhatId(gutschriftRecord.Id);
        if (oweas.size() > 0) {
            emailToBroker.setOrgWideEmailAddressId(oweas.get(0).Id);
        }
        emailToBroker.setFileAttachments(new Messaging.EmailFileAttachment[]{
                attach
        });
        // Sends the email
        messages.add(emailToBroker);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(messages, false);
        System.debug(r);
        
        //Send Email to Fibu
        Messaging.SingleEmailMessage emailToFibu = new Messaging.SingleEmailMessage();

        String[] toMails = new List < String > ();
        toMails.add('fibu@carestone.com');
        //toMails.add('f.witte@carestone.com');
        emailToFibu.setToAddresses(toMails);
        if (oweas.size() > 0) {
            emailToFibu.setOrgWideEmailAddressId(oweas.get(0).Id);
        }

        if(r[0].isSuccess()) {
            emailToFibu.setHtmlBody(emailToBroker.getHtmlBody());

            emailToFibu.setPlainTextBody(emailToBroker.getPlainTextBody());

            emailToFibu.setSubject(emailToBroker.getSubject());

            emailToFibu.setFileAttachments(emailToBroker.getFileAttachments());
        } else {
            emailToFibu.setPlainTextBody('Für die Gutschrift wurde eine Gutschrift generiert und konnte nicht per Mail an den Makler zugestellt werden.');

            emailToFibu.setSubject('Gutschrift ' + gutschriftRecord.LaufnummerNew__c);

            emailToFibu.setFileAttachments(new Messaging.EmailFileAttachment[]{
                    attach
            });
        }

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                emailToFibu
        });
        User u = [SELECT IsActive,IsPortalEnabled,LastName FROM User WHERE Id = :UserInfo.getUserId()];
        ContentVersion file = new ContentVersion();
        file.VersionData = body;
        file.Title = fileName; 
        file.ContentLocation= 's';
        file.PathOnClient=fileName;
        Id gutschriftenRecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('Gutschriften').getRecordTypeId();
        file.Typ__c = 'Gutschrift';
        file.RecordTypeId = gutschriftenRecordTypeId;
        if(u.IsPortalEnabled) {
            Id networkId = [SELECT Id FROM Network LIMIT 1].Id;
            file.NetworkId = networkId;
        }
        //gutschriftRecord.StornoWurdeGeneriert__c = true;
        gutschriftRecord.GutschriftWurdeGeneriert__c = true;
        insert file;
        
        List<ContentVersion> files = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :file.Id];

        if(files.size() > 0) {
            file = files[0];
            ContentDocumentLink cde = new ContentDocumentLink();
            cde.ContentDocumentId = file.ContentDocumentId;
            cde.LinkedEntityId = gutschriftRecord.Id;
            insert cde;
            update gutschriftRecord;
        }
    }
}