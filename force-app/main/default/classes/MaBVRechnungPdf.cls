/**
 * Created by frederikwitte on 26.05.20.
 */

public with sharing class MaBVRechnungPdf {
    
    //@Future(callout=true)
    public static void sendRechnungenAsPdf(List<Id> maBVRechnungenIds, Boolean storno) {
        String invoiceFileName = 'MaBV Rechnung ';
        String emailTemplateName = 'MaBVRechnungPDF';
        if(storno) {
            invoiceFileName = 'MaBV Storno ';
            emailTemplateName = 'MaBVStornoPDF';
        }
        List<MaBVRechnung__c> maBVRechnungen = [SELECT Id, Name, IDKunde__c, StornoLaufnummer__c, Rechnungsdatum__c, MaBVRechnungMaster__r.MaBVRate__c FROM MaBVRechnung__c WHERE Id IN :maBVRechnungenIds];
        Id templateId = [SELECT Id, Name FROM EmailTemplate WHERE developername = :emailTemplateName].id;
        List<OrgWideEmailAddress> oweas = new List<OrgWideEmailAddress>([SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE Address = 'maklerbetreuung@wirtschaftshaus.de']);
        Messaging.Email[] messages = new Messaging.Email[0];
        Map<Id, ContentVersion> maBVRechnungIdToFile = new Map<Id, ContentVersion>();
        List<ContentDocumentLink> fileLinks = new List<ContentDocumentLink>();
        Set<Id> mabvRateIds = new Set<Id>();

        for(MaBVRechnung__c maBVRechnung:maBVRechnungen) {
            mabvRateIds.add(maBVRechnung.MaBVRechnungMaster__r.MaBVRate__c);
        }

        Map<Id, MaBVRate__c> mabvRaten = new Map<Id, MaBVRate__c>([SELECT DateFirstInvoice__c, DateLastInvoice__c FROM MaBVRate__c WHERE Id IN :mabvRateIds]);
        Map<Id, MaBVRate__c> updateMaBVRaten = new Map<Id, MaBVRate__c>();

        for(MaBVRechnung__c maBVRechnung:maBVRechnungen) {
            PageReference pdf = Page.MaBVRechnung;
            pdf.getParameters().put('id', maBVRechnung.Id);
            if(storno) {
                pdf.getParameters().put('type', 'Storno');
            } else {
                pdf.getParameters().put('type', 'Rechnung');
            }
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
            String fileName = invoiceFileName + maBVRechnung.Name + '.pdf';
            if(storno) {
                fileName = invoiceFileName + maBVRechnung.StornoLaufnummer__c + '.pdf';
            }
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
            file.Typ__c = 'MaBV Rechnung';
            if(storno) { 
                file.Typ__c = 'Storno';
            }
            file.RecordTypeId = mabvRecordTypeId;
            maBVRechnungIdToFile.put(maBVRechnung.Id, file);
            if(storno) {
                maBVRechnung.StornoWurdeGeneriert__c = true;
            } else {
                maBVRechnung.RechnungWurdeGeneriert__c = true;
            }

            Boolean updateMabvRate = false;
            MaBVRate__c mabvRate = mabvRaten.get(maBVRechnung.MaBVRechnungMaster__r.MaBVRate__c);
            if(!storno && (mabvRate.DateFirstInvoice__c == null || mabvRate.DateFirstInvoice__c != null && mabvRate.DateFirstInvoice__c > mabvRechnung.Rechnungsdatum__c)) {
                mabvRate.DateFirstInvoice__c = mabvRechnung.Rechnungsdatum__c;
                updateMabvRate = true;
            }

            if(!storno && (mabvRate.DateLastInvoice__c == null || mabvRate.DateLastInvoice__c != null && mabvRate.DateLastInvoice__c < mabvRechnung.Rechnungsdatum__c)) {
                mabvRate.DateLastInvoice__c = mabvRechnung.Rechnungsdatum__c;
                updateMabvRate = true;
            }

            if(updateMabvRate) {
                updateMaBVRaten.put(mabvRate.Id, mabvRate);
            }
        }
        // Sends the email
        Messaging.SendEmailResult [] r = Messaging.sendEmail(messages, false);
        System.debug(r);

        insert maBVRechnungIdToFile.values();

        List<Id> fileIds = new List<Id>();
        for(MaBVRechnung__c maBVRechnung:maBVRechnungen) {
            ContentVersion file = maBVRechnungIdToFile.get(maBVRechnung.Id);
            System.debug(file);
            fileIds.add(file.Id);
        }

        Map<Id, ContentVersion> files = new Map<Id, ContentVersion>([SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :fileIds]);

        for(MaBVRechnung__c maBVRechnung:maBVRechnungen) {
            Id fileId = maBVRechnungIdToFile.get(maBVRechnung.Id).Id;
            ContentVersion file = files.get(fileId);
            System.debug(file);
            ContentDocumentLink cde = new ContentDocumentLink();
            cde.ContentDocumentId = file.ContentDocumentId;
            cde.LinkedEntityId = mabvRechnung.Id;
            fileLinks.add(cde);
        }
        insert fileLinks;
        update maBVRechnungen;
        update updateMaBVRaten.values();
    }
}