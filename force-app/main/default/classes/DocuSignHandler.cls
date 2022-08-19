public without sharing class DocuSignHandler {
    
    @InvocableMethod
    public static void sendEnvelopes(List<Variables> requestList) {
        List<Id> oppIds = new List<Id>();
        String emailSubject;
        String emailContent;
        String docuSignTemplateId;
        for(Variables requestItem:requestList) {
            if(requestItem.ids != null && requestItem.ids.size() > 0) {
                if(String.valueOf(requestItem.ids[0]).startsWith('006')) {
                    oppIds.addAll(requestItem.ids);
                }
            }
            if(requestItem.id != null) {
                oppIds.add(requestItem.id);
            }
            emailSubject = requestItem.emailSubject;
            emailContent = requestItem.emailContent;
            docuSignTemplateId = requestItem.docuSignTemplateId;
        }

        if(oppIds.size() > 0) {
            handleOpportunities(docuSignTemplateId, oppIds, emailSubject, emailContent);
        }
    }

    public class Variables {
        @InvocableVariable(label='DocuSign Template ID' description='Use the DocuSign gen template ID within salesforce' required=true)
        public String docuSignTemplateId;
        
        @InvocableVariable(label='Record ids' description='Record ids, currently supporting only Opportunity')
        public List<Id> ids;

        @InvocableVariable(label='Record id' description='Record id, currently supporting only Opportunity')
        public Id id;

        @InvocableVariable(label='Email subject' description='The subject of the email to be sent' required=true)
        public String emailSubject; 

        @InvocableVariable(label='Email content' description='The content of the email to be sent' required=true)
        public String emailContent;
    }

    @future(callout=true)
    public static void handleOpportunities(String docuSignTemplateId, List<Id> ids, String emailSubject, String emailContent) {
        List<dfsle.Envelope> envelopes = new List<dfsle.Envelope>();
        List<Opportunity> opps = [SELECT Id, Potenzieller_Kunde__c, Potenzieller_Kunde__r.Name, Potenzieller_Kunde__r.Email, Kunde2__c, Kunde2__r.Name, Kunde2__r.Email FROM Opportunity WHERE Id IN :ids];
        for(Opportunity opp:opps) {
            // Create an empty envelope.
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
                new dfsle.Entity(opp.Id)).withEmail(emailSubject, emailContent);
            // The initiating Salesforce entity.
            
            
            List<dfsle.Recipient> recipients = new List<dfsle.Recipient>();
            if(opp.Potenzieller_Kunde__c != null) {
                //use the Recipient.fromSource method to create the Recipient
                dfsle.Recipient ersterKaeufer = dfsle.Recipient.fromSource(
                    opp.Potenzieller_Kunde__r.Name, // Recipient name
                    opp.Potenzieller_Kunde__r.Email, // Recipient email
                    null, //Optional phone number
                    'Käufer', //Role Name. Specify the exact role name from template
                    new dfsle.Entity(opp.Potenzieller_Kunde__c)); //source object for the Recipient
                recipients.add(ersterKaeufer);
            }

            if(opp.Kunde2__c != null) {
                //use the Recipient.fromSource method to create the Recipient
                dfsle.Recipient zweiterKaeufer = dfsle.Recipient.fromSource(
                    opp.Kunde2__r.Name, // Recipient name
                    opp.Kunde2__r.Email, // Recipient email
                    null, //Optional phone number
                    '2. Käufer', //Role Name. Specify the exact role name from template
                    new dfsle.Entity(opp.Kunde2__c)); //source object for the Recipient
                recipients.add(zweiterKaeufer);
            }
            

            //add Recipient to the Envelope
            myEnvelope = myEnvelope.withRecipients(recipients);
            //myTemplateId contains the DocuSign Id of the DocuSign Template
            dfsle.UUID myTemplateId = dfsle.UUID.parse(docuSignTemplateId);
            
            //create a new document for the Envelope
            dfsle.Document myDocument = dfsle.Document.fromTemplate(
                myTemplateId, 'Reservierungsschein'); // templateId in dfsle.UUID format
            
            //add document to the Envelope
            myEnvelope = myEnvelope.withDocuments(new List<dfsle.Document> { myDocument });
            envelopes.add(myEnvelope);
        }

            // Send the envelope.
        try {
            dfsle.EnvelopeService.sendEnvelopes(envelopes); // Send now?
        } catch(Exception e) {

        }
    }

}