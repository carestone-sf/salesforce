/**
 * Created by frederikwitte on 06.05.2022
 */

public without sharing class MaBVMahnungPdf {
    
    //@Future(callout=true)
    public static void sendMahnungenAsPdf(List<Id> maBVRechnungenIds) {
        String reminderFileName = 'Zahlungserinnerung ';
        String emailTemplateName = 'MaBVMahnungPDF';

        List<MaBVRechnung__c> maBVRechnungen = [SELECT Id, Name, IDKunde__c FROM MaBVRechnung__c WHERE Id IN :maBVRechnungenIds];
        Id templateId = [SELECT Id, Name FROM EmailTemplate WHERE developername = :emailTemplateName].id;
        List<OrgWideEmailAddress> oweas = new List<OrgWideEmailAddress>([SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE Address = 'support@carestone.com']);
        Messaging.Email[] messages = new Messaging.Email[0];
        Map<Id, ContentVersion> maBVRechnungIdToFile = new Map<Id, ContentVersion>();
        List<ContentDocumentLink> fileLinks = new List<ContentDocumentLink>();

        for(MaBVRechnung__c maBVRechnung:maBVRechnungen) {
            PageReference pdf = Page.MaBVMahnung;
            pdf.getParameters().put('id', maBVRechnung.Id);
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
            String fileName = reminderFileName + maBVRechnung.Name + '.pdf';
            attach.setFileName(fileName);
            attach.setInline(false);
            attach.Body = body;
            // SingleEmailMessage erstellen
            Messaging.SingleEmailMessage Emailwithattch = new Messaging.SingleEmailMessage();
            Emailwithattch.setTemplateId(templateId);
            Emailwithattch.setTargetObjectId(maBVRechnung.IDKunde__c);
            Emailwithattch.setWhatId(maBVRechnung.Id);
            Emailwithattch.treatTargetObjectAsRecipient = false;
            // Email to broker "Couldn't create"
            String[] toMails = new List < String > ();
            toMails.add('MaBV-Rechnungen@carestone.com');
            //toMails.add('frederik.witte93@gmail.com');
            Emailwithattch.setToAddresses(toMails);
            if (oweas.size() > 0) {
                Emailwithattch.setOrgWideEmailAddressId(oweas.get(0).Id);
            }
            Emailwithattch.setFileAttachments(new Messaging.EmailFileAttachment[]{
                    attach
            });
            messages.add(Emailwithattch);

            ContentVersion file = new ContentVersion();
            file.VersionData = body;
            file.Title = fileName; 
            file.ContentLocation= 's';
            file.PathOnClient=fileName;
            Id mabvRecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('MaBV').getRecordTypeId();
            file.Typ__c = 'Mahnung';
            file.RecordTypeId = mabvRecordTypeId;
            maBVRechnungIdToFile.put(maBVRechnung.Id, file);
            maBVRechnung.MahnungVersendetAm__c = Date.today();
        }
        // Sends the email
        Messaging.SendEmailResult [] r = Messaging.sendEmail(messages, false);
        System.debug(r);

        insert maBVRechnungIdToFile.values();

        List<Id> fileIds = new List<Id>();
        for(MaBVRechnung__c maBVRechnung:maBVRechnungen) {
            ContentVersion file = maBVRechnungIdToFile.get(maBVRechnung.Id);
            fileIds.add(file.Id);
        }

        Map<Id, ContentVersion> files = new Map<Id, ContentVersion>([SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :fileIds]);

        for(MaBVRechnung__c maBVRechnung:maBVRechnungen) {
            Id fileId = maBVRechnungIdToFile.get(maBVRechnung.Id).Id;
            ContentVersion file = files.get(fileId);
            ContentDocumentLink cde = new ContentDocumentLink();
            cde.ContentDocumentId = file.ContentDocumentId;
            cde.LinkedEntityId = mabvRechnung.Id;
            fileLinks.add(cde);
        }
        insert fileLinks;
        update maBVRechnungen;
    }
}