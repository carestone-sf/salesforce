public class TrainstoneCertificateSender {
    
    public class FlowInput {
        @InvocableVariable(label='Kampagnen ID' required=true)
        public Id campaignId;
        
        @InvocableVariable(label='Mitglieder-Status' required=true)
        public String memberStatus;
    }

    @InvocableMethod(label='Zertifikate als PDF senden' description='Generiert VF PDFs und sendet sie an Kampagnenmitglieder')
    public static void sendCertificates(List<FlowInput> inputs) {
        if(inputs.isEmpty()) return;
        
        Id campId = inputs[0].campaignId;
        String status = inputs[0].memberStatus;
        
        // 1. Alle Kampagnenmitglieder mit dem passenden Status und einer E-Mail-Adresse abfragen
        List<CampaignMember> members = [
            SELECT Id, ContactId, Contact.Email, Contact.FirstName, Contact.LastName 
            FROM CampaignMember 
            WHERE CampaignId = :campId 
            AND Status = :status 
            AND ContactId != null 
            AND Contact.Email != null
        ];
        
        if(members.isEmpty()) return;
        
        // 2. Die organisationsweite E-Mail-Adresse abfragen
        OrgWideEmailAddress[] owa = [
            SELECT Id 
            FROM OrgWideEmailAddress 
            WHERE Address = 'weiterbildung@carestone.com' 
            LIMIT 1
        ];
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        // --- NEU: LIMIT PRÜFUNG ---
        try {
            // Wir versuchen, die Kapazität für die Anzahl der gefundenen Mitglieder zu reservieren
            Messaging.reserveSingleEmailCapacity(members.size());
        } catch (System.HandledException e) {
            // Wenn hier ein Fehler auftritt, ist das Tageslimit bereits erreicht
            System.debug('E-Mail Limit erreicht: ' + e.getMessage());
            // Optional: Hier könnte man eine Aufgabe für den Admin erstellen oder eine Fehlermeldung loggen
            return; 
        }
        
        // 3. Für jedes Mitglied das PDF generieren und die Mail bauen
        for(CampaignMember cm : members) {
            
            PageReference pdfPage = Page.TrainstoneZertifikat; 
            pdfPage.getParameters().put('id', cm.Id);
            
            Blob pdfBlob;
            if(Test.isRunningTest()) {
                pdfBlob = Blob.valueOf('Test PDF Content');
            } else {
                // Hinweis: getContentAsPDF() zählt als HTTP Callout/Zusatzlast
                pdfBlob = pdfPage.getContentAsPDF();
            }
            
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            String safeFirstName = cm.Contact.FirstName != null ? cm.Contact.FirstName : '';
            attachment.setFileName('Weiterbildungsnachweis_' + safeFirstName + '_' + cm.Contact.LastName + '.pdf');
            attachment.setBody(pdfBlob);
            attachment.setContentType('application/pdf');
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(cm.ContactId);
            email.setSaveAsActivity(true); 
            email.setSubject('Ihr Weiterbildungsnachweis - Carestone Group GmbH'); 
            
            if (owa.size() > 0) {
                email.setOrgWideEmailAddressId(owa[0].Id);
            }
            
            String body = 'Hallo ' + safeFirstName + ' ' + cm.Contact.LastName + ',\n\n'
                        + 'vielen Dank für Ihre Teilnahme. Anbei erhalten Sie als Carestone Partner Ihren Weiterbildungsnachweis als PDF für die erfolgreiche Teilnahme am Trainstone Vertriebsdialog/der Trainstone Vorlesung.\n\n'
                        + 'Viele Grüße\nIhre Carestone Group GmbH';
            email.setPlainTextBody(body);
            email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
            
            emailsToSend.add(email);
        }
        
        // 4. Alle E-Mails auf einmal versenden
        if(!emailsToSend.isEmpty()) {
            try {
                Messaging.sendEmail(emailsToSend);
            } catch (System.EmailException e) {
                System.debug('Fehler beim E-Mail Versand: ' + e.getMessage());
            }
        }
    }
}