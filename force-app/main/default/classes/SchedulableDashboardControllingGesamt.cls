global class SchedulableDashboardControllingGesamt implements Schedulable {
    public List<Property__c> properties {get;set;}
    public List<Contact> contacts {get;set;}
    public String subject { get; set; }
    public String body { get; set; }

    global void execute(SchedulableContext sc) {
        sendPdfFile();
    }

    @future(callout=true)
    public static void sendPdfFile(){
        PageReference pdf = Page.controlling_gesamt_aktuelles_jahr;

        // Blob und E-Mail Anhang aus dem String generieren
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.ContentType = 'application/pdf';
        Blob body;
        try {
            body = pdf.getContentAsPDF();
        } catch(Exception e) {
            body = blob.valueOf('Ein Fehler ist aufgetreten');
        }
        Id templateId = [SELECT id, name FROM EmailTemplate WHERE developername = 'Dashboard_Controlling_gesamt'].id;
        // Random contact for sending mail and rolling back
        Contact cnt = [SELECT id, Email FROM Contact WHERE email != null LIMIT 1];
        // Dateiname der PDF
        String fileName = 'Dashboard - Controlling gesamt ' + '.pdf';
        attach.setFileName(fileName);
        attach.setInline(false);
        attach.Body = body;


        // Contact con = [SELECT Id FROM Contact WHERE Email = 'f.witte@wirtschaftshaus.de' LIMIT 1];
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Messaging.singleEmailMessage emailwithattach = new Messaging.singleEmailMessage();
        emailwithattach.setTemplateId(templateId);
        emailwithattach.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
        emailwithattach.setTargetObjectId(cnt.id);
        emailwithattach.setToAddresses(new List<String>{'DAhrendt@asg-advisory.com', 'smohr@asg-advisory.com', 'Mario.Liebermann@web.de', 'aabulaban@activumsg.com'});
        messages.add(emailwithattach);

        // Send the emails in a transaction, then roll it back
        Savepoint sp = Database.setSavepoint();

        Messaging.sendEmail(messages); // Dummy email send

        Database.rollback(sp); // Email will not send as it is rolled Back

        // Send Actual email
        List<Messaging.SingleEmailMessage> msgListToBeSend = new List<Messaging.SingleEmailMessage>();
        for (Messaging.SingleEmailMessage email : messages) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setPlainTextBody(email.getPlainTextBody());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSubject(email.getSubject());
            emailToSend.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            msgListToBeSend.add(emailToSend);
        }

        Messaging.sendEmail(msgListToBeSend);

    }
}