public without sharing class DSAuftragsdatenverarbeitungService {

    private static final String RECIPIENT_TYPE_SIGNER = dfsle.Recipient.TYPE_SIGNER;
    private static final String RECIPIENT_TYPE_CARBON_COPY = dfsle.Recipient.TYPE_CARBON_COPY;

    @TestVisible
    private static EnvelopeSender envelopeSender = new DfsleEnvelopeSender();

    public static void send(DSAuftragsdatenverarbeitung request) {
        if (request == null) {
            return;
        }
        send(new List<DSAuftragsdatenverarbeitung>{ request });
    }

    public static void send(List<DSAuftragsdatenverarbeitung> requests) {
        if (requests == null || requests.isEmpty()) {
            return;
        }

        List<RoleBasedRequest> mappedRequests = new List<RoleBasedRequest>();
        for (DSAuftragsdatenverarbeitung request : requests) {
            if (request == null) {
                continue;
            }
            mappedRequests.add(mapAuftragsdatenverarbeitungRequest(request));
        }

        sendRoleBased(mappedRequests);
    }

    public static void sendRoleBased(List<RoleBasedRequest> requests) {
        if (requests == null || requests.isEmpty()) {
            return;
        }

        List<dfsle.Envelope> envelopes = new List<dfsle.Envelope>();
        for (RoleBasedRequest request : requests) {
            if (request == null) {
                continue;
            }
            envelopes.add(buildRoleBasedEnvelope(request));
        }

        if (!envelopes.isEmpty()) {
            envelopeSender.send(envelopes);
        }
    }

    private static RoleBasedRequest mapAuftragsdatenverarbeitungRequest(DSAuftragsdatenverarbeitung request) {
        validateAuftragsdatenverarbeitungRequest(request);

        RoleBasedRequest mappedRequest = new RoleBasedRequest();
        mappedRequest.relatedRecordId = request.relatedRecordId;
        mappedRequest.templateId = request.templateId;
        mappedRequest.emailSubject = request.emailSubject;
        mappedRequest.emailBody = request.emailBody;
        mappedRequest.documentName = 'Auftragsdatenverarbeitung';

        mappedRequest.recipients = new List<RoleBasedRecipient>{
            newRoleBasedRecipient(
                'Interessent',
                request.Interessent.Name,
                request.Interessent.Email,
                request.Interessent.interessentenRecordId,
                RECIPIENT_TYPE_SIGNER,
                buildAuftragsdatenverarbeitungPrefillTabs(request)
            ),
            newRoleBasedRecipient(
                'Makler',
                request.Makler.Name,
                request.Makler.Email,
                request.Interessent.maklerRecordId,
                RECIPIENT_TYPE_CARBON_COPY,
                null
            ),
            newRoleBasedRecipient(
                'Partnermanager',
                request.Partnermanager.Name,
                request.Partnermanager.Email,
                request.Interessent.partnermanagerRecordId,
                RECIPIENT_TYPE_CARBON_COPY,
                null
            )
        };

        return mappedRequest;
    }

    private static List<PrefillTab> buildAuftragsdatenverarbeitungPrefillTabs(DSAuftragsdatenverarbeitung request) {
        return new List<PrefillTab>{
            newPrefillTab('interessentenRecordId', String.valueOf(request.Interessent.interessentenRecordId)),
            newPrefillTab('maklerRecordId', String.valueOf(request.Interessent.maklerRecordId)),
            newPrefillTab('partnermanagerRecordId', String.valueOf(request.Interessent.partnermanagerRecordId))
        };
    }

    private static PrefillTab newPrefillTab(String dataLabel, String value) {
        PrefillTab tab = new PrefillTab();
        tab.dataLabel = dataLabel;
        tab.value = value;
        return tab;
    }

    private static RoleBasedRecipient newRoleBasedRecipient(
        String roleName,
        String name,
        String email,
        Id sourceEntityId,
        String recipientType,
        List<PrefillTab> prefillTabs
    ) {
        RoleBasedRecipient recipient = new RoleBasedRecipient();
        recipient.roleName = roleName;
        recipient.name = name;
        recipient.email = email;
        recipient.sourceEntityId = sourceEntityId;
        recipient.recipientType = recipientType;
        recipient.prefillTabs = prefillTabs;
        return recipient;
    }

    private static dfsle.Envelope buildRoleBasedEnvelope(RoleBasedRequest request) {
        validateRoleBasedRequest(request);

        dfsle.Envelope envelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(request.relatedRecordId)).withEmail(request.emailSubject, request.emailBody);

        List<dfsle.Recipient> recipients = new List<dfsle.Recipient>();
        for (RoleBasedRecipient recipientData : request.recipients) {
            dfsle.Recipient recipient = dfsle.Recipient.fromSource(
                recipientData.name,
                recipientData.email,
                null,
                recipientData.roleName,
                new dfsle.Entity(recipientData.sourceEntityId)
            );

            if (!String.isBlank(recipientData.recipientType)) {
                recipient = recipient.withType(recipientData.recipientType);
            }

            if (recipientData.prefillTabs != null && !recipientData.prefillTabs.isEmpty()) {
                recipient = recipient.withTabs(buildTabs(recipientData.prefillTabs));
            }

            recipients.add(recipient);
        }

        envelope = envelope.withRecipients(recipients);

        dfsle.Document document = dfsle.Document.fromTemplate(
            dfsle.UUID.parse(request.templateId),
            request.documentName
        );

        return envelope.withDocuments(new List<dfsle.Document>{ document });
    }

    private static List<dfsle.Tab> buildTabs(List<PrefillTab> prefillTabs) {
        List<dfsle.Tab> tabs = new List<dfsle.Tab>();

        for (PrefillTab tabData : prefillTabs) {
            if (tabData.isCheckbox == true) {
                tabs.add(
                    new dfsle.CheckboxTab().withValue(tabData.checkboxValue).withDataLabel(tabData.dataLabel)
                );
            } else {
                tabs.add(
                    new dfsle.TextTab().withValue(tabData.value).withDataLabel(tabData.dataLabel)
                );
            }
        }

        return tabs;
    }

    private static void validateAuftragsdatenverarbeitungRequest(DSAuftragsdatenverarbeitung request) {
        if (request.relatedRecordId == null) {
            throw new DSAuftragsdatenverarbeitungServiceException('relatedRecordId is required.');
        }
        if (String.isBlank(request.templateId)) {
            throw new DSAuftragsdatenverarbeitungServiceException('templateId is required.');
        }
        if (String.isBlank(request.emailSubject)) {
            throw new DSAuftragsdatenverarbeitungServiceException('emailSubject is required.');
        }
        if (String.isBlank(request.emailBody)) {
            throw new DSAuftragsdatenverarbeitungServiceException('emailBody is required.');
        }
        if (request.Interessent == null) {
            throw new DSAuftragsdatenverarbeitungServiceException('Interessent is required.');
        }
        if (request.Interessent.interessentenRecordId == null) {
            throw new DSAuftragsdatenverarbeitungServiceException('Interessent.interessentenRecordId is required.');
        }
        if (request.Interessent.maklerRecordId == null) {
            throw new DSAuftragsdatenverarbeitungServiceException('Interessent.maklerRecordId is required.');
        }
        if (request.Interessent.partnermanagerRecordId == null) {
            throw new DSAuftragsdatenverarbeitungServiceException('Interessent.partnermanagerRecordId is required.');
        }
        if (request.Makler == null) {
            throw new DSAuftragsdatenverarbeitungServiceException('Makler is required.');
        }
        if (request.Partnermanager == null) {
            throw new DSAuftragsdatenverarbeitungServiceException('Partnermanager is required.');
        }
    }

    private static void validateRoleBasedRequest(RoleBasedRequest request) {
        if (request.relatedRecordId == null) {
            throw new DSAuftragsdatenverarbeitungServiceException('relatedRecordId is required.');
        }
        if (String.isBlank(request.templateId)) {
            throw new DSAuftragsdatenverarbeitungServiceException('templateId is required.');
        }
        if (String.isBlank(request.documentName)) {
            throw new DSAuftragsdatenverarbeitungServiceException('documentName is required.');
        }
        if (String.isBlank(request.emailSubject)) {
            throw new DSAuftragsdatenverarbeitungServiceException('emailSubject is required.');
        }
        if (String.isBlank(request.emailBody)) {
            throw new DSAuftragsdatenverarbeitungServiceException('emailBody is required.');
        }
        if (request.recipients == null || request.recipients.isEmpty()) {
            throw new DSAuftragsdatenverarbeitungServiceException('At least one recipient is required.');
        }

        for (RoleBasedRecipient recipientData : request.recipients) {
            if (recipientData == null) {
                throw new DSAuftragsdatenverarbeitungServiceException('Recipient payload is required.');
            }
            if (String.isBlank(recipientData.roleName)) {
                throw new DSAuftragsdatenverarbeitungServiceException('Recipient roleName is required.');
            }
            if (String.isBlank(recipientData.name)) {
                throw new DSAuftragsdatenverarbeitungServiceException('Missing Name for role ' + recipientData.roleName + '.');
            }
            if (String.isBlank(recipientData.email)) {
                throw new DSAuftragsdatenverarbeitungServiceException('Missing Email for role ' + recipientData.roleName + '.');
            }
            if (recipientData.sourceEntityId == null) {
                throw new DSAuftragsdatenverarbeitungServiceException('Missing SourceEntityId for role ' + recipientData.roleName + '.');
            }

            if (recipientData.prefillTabs != null) {
                for (PrefillTab tabData : recipientData.prefillTabs) {
                    if (tabData == null) {
                        throw new DSAuftragsdatenverarbeitungServiceException('Prefill tab payload is invalid for role ' + recipientData.roleName + '.');
                    }
                    if (String.isBlank(tabData.dataLabel)) {
                        throw new DSAuftragsdatenverarbeitungServiceException('Prefill tab dataLabel is required for role ' + recipientData.roleName + '.');
                    }
                    if (String.isBlank(tabData.value)) {
                        throw new DSAuftragsdatenverarbeitungServiceException('Prefill tab value is required for dataLabel ' + tabData.dataLabel + '.');
                    }
                }
            }
        }
    }

    public class RoleBasedRequest {
        public Id relatedRecordId;
        public String templateId;
        public String documentName;
        public String emailSubject;
        public String emailBody;
        public List<RoleBasedRecipient> recipients;

        public RoleBasedRequest() {
            this.recipients = new List<RoleBasedRecipient>();
        }
    }

    public class RoleBasedRecipient {
        public String roleName;
        public Id sourceEntityId;
        public String name;
        public String email;
        public String recipientType;
        public List<PrefillTab> prefillTabs;
    }

    public class PrefillTab {
        public String dataLabel;
        public String value;
        public Boolean isCheckbox;
        public Boolean checkboxValue;
    }

    public interface EnvelopeSender {
        void send(List<dfsle.Envelope> envelopes);
    }

    private class DfsleEnvelopeSender implements EnvelopeSender {
        public void send(List<dfsle.Envelope> envelopes) {
            dfsle.EnvelopeService.sendEnvelopes(envelopes);
        }
    }

    public class DSAuftragsdatenverarbeitungServiceException extends Exception {
    }
}