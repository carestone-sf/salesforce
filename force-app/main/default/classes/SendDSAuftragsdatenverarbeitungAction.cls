public without sharing class SendDSAuftragsdatenverarbeitungAction {

    public class Request {
        @InvocableVariable(
            label='Related Record Id'
            description='Salesforce record id used as envelope source entity.'
            required=true
        )
        public Id relatedRecordId;

        @InvocableVariable(
            label='Template Id'
            description='Optional DocuSign template id. Default is the ADV template.'
            required=false
        )
        public String templateId;

        @InvocableVariable(
            label='Email Subject'
            description='Optional email subject. Default: Auftragsdatenverarbeitung.'
            required=false
        )
        public String emailSubject;

        @InvocableVariable(
            label='Email Body'
            description='Optional email body.'
            required=false
        )
        public String emailBody;

        @InvocableVariable(label='Interessenten Record Id' required=true)
        public Id interessentenRecordId;
        @InvocableVariable(label='Makler Record Id' required=true)
        public Id maklerRecordId;
        @InvocableVariable(label='Partnermanager Record Id' required=true)
        public Id partnermanagerRecordId;
        @InvocableVariable(label='Interessent Name' required=true)
        public String interessentName;
        @InvocableVariable(label='Interessent Email' required=true)
        public String interessentEmail;
        @InvocableVariable(label='Makler Name' required=true)
        public String maklerName;
        @InvocableVariable(label='Makler Email' required=true)
        public String maklerEmail;
        @InvocableVariable(label='Partnermanager Name' required=true)
        public String partnermanagerName;
        @InvocableVariable(label='Partnermanager Email' required=true)
        public String partnermanagerEmail;
    }

    @InvocableMethod(
        label='Send Auftragsdatenverarbeitung'
        description='Sends DocuSign template 8b23cc54-d0dd-47cf-8193-ffb2a77dfd1b for roles Interessent, Makler and Partnermanager.'
    )
    public static void send(List<Request> requests) {
        if (requests == null || requests.isEmpty()) {
            return;
        }

        List<DSAuftragsdatenverarbeitung> payloads = new List<DSAuftragsdatenverarbeitung>();
        for (Request request : requests) {
            if (request == null) {
                continue;
            }
            payloads.add(mapToPayload(request));
        }

        DSAuftragsdatenverarbeitungService.send(payloads);
    }

    private static DSAuftragsdatenverarbeitung mapToPayload(Request request) {
        DSAuftragsdatenverarbeitung payload = new DSAuftragsdatenverarbeitung();
        payload.relatedRecordId = request.relatedRecordId;

        if (!String.isBlank(request.templateId)) {
            payload.templateId = request.templateId;
        }
        if (!String.isBlank(request.emailSubject)) {
            payload.emailSubject = request.emailSubject;
        }
        if (!String.isBlank(request.emailBody)) {
            payload.emailBody = request.emailBody;
        }

        payload.Interessent.interessentenRecordId = request.interessentenRecordId;
        payload.Interessent.maklerRecordId = request.maklerRecordId;
        payload.Interessent.partnermanagerRecordId = request.partnermanagerRecordId;
        payload.Interessent.Name = request.interessentName;
        payload.Interessent.Email = request.interessentEmail;

        payload.Makler.Name = request.maklerName;
        payload.Makler.Email = request.maklerEmail;

        payload.Partnermanager.Name = request.partnermanagerName;
        payload.Partnermanager.Email = request.partnermanagerEmail;

        return payload;
    }
}