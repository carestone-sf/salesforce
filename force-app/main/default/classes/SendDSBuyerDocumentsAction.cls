public without sharing class SendDSBuyerDocumentsAction {

    private static final String TYPE_NOTARAUFTRAG = 'Notarauftrag';
    private static final String TYPE_RESERVIERUNG = 'Reservierung';
    private static final String TYPE_VSA = 'Vertrauliche Selbstauskunft';
    private static final String TYPE_BERATUNGSPROTOKOLL = 'Beratungsprotokoll';

    private static final String ROLE_ERSTER_KAEUFER = 'Erster Käufer';
    private static final String ROLE_ZWEITER_KAEUFER = 'Zweiter Käufer';
    private static final String ROLE_MAKLER = 'Makler';
    private static final String ROLE_PARTNERMANAGER = 'Partnermanager';

    private static final String DEFAULT_EMAIL_BODY = 'Bitte prüfen und signieren.';
    private static final String RECIPIENT_TYPE_SIGNER = dfsle.Recipient.TYPE_SIGNER;
    private static final String RECIPIENT_TYPE_CARBON_COPY = dfsle.Recipient.TYPE_CARBON_COPY;

    private static final Map<String, String> TEMPLATE_BY_DOCUMENT_TYPE = new Map<String, String>{
        TYPE_NOTARAUFTRAG => 'd9a58507-627c-44c0-a5e4-2c8c6b976bce',
        TYPE_RESERVIERUNG => '3d9c500c-3b01-4c8f-aea4-2a2d1526fbbf',
        TYPE_VSA => 'c4ac6d1f-ae32-4027-b317-2ea50a62376c',
        TYPE_BERATUNGSPROTOKOLL => '789d4bef-8244-4001-823c-8a2d06c8ef2f'
    };

    private static final Map<String, String> LINKED_OBJECT_BY_DOCUMENT_TYPE = new Map<String, String>{
        TYPE_NOTARAUFTRAG => 'Opportunity',
        TYPE_RESERVIERUNG => 'Opportunity',
        TYPE_BERATUNGSPROTOKOLL => 'Opportunity',
        TYPE_VSA => 'DigitaleVsa__c'
    };

    private static final Map<String, Map<String, String>> RECIPIENT_TYPE_BY_DOCUMENT_AND_ROLE =
        new Map<String, Map<String, String>>{
            TYPE_NOTARAUFTRAG => new Map<String, String>{
                ROLE_ERSTER_KAEUFER => RECIPIENT_TYPE_SIGNER,
                ROLE_ZWEITER_KAEUFER => RECIPIENT_TYPE_SIGNER,
                ROLE_MAKLER => RECIPIENT_TYPE_CARBON_COPY,
                ROLE_PARTNERMANAGER => RECIPIENT_TYPE_CARBON_COPY
            },
            TYPE_RESERVIERUNG => new Map<String, String>{
                ROLE_ERSTER_KAEUFER => RECIPIENT_TYPE_SIGNER,
                ROLE_ZWEITER_KAEUFER => RECIPIENT_TYPE_SIGNER,
                ROLE_MAKLER => RECIPIENT_TYPE_CARBON_COPY,
                ROLE_PARTNERMANAGER => RECIPIENT_TYPE_CARBON_COPY
            },
            TYPE_VSA => new Map<String, String>{
                ROLE_ERSTER_KAEUFER => RECIPIENT_TYPE_SIGNER,
                ROLE_ZWEITER_KAEUFER => RECIPIENT_TYPE_SIGNER,
                ROLE_MAKLER => RECIPIENT_TYPE_CARBON_COPY,
                ROLE_PARTNERMANAGER => RECIPIENT_TYPE_CARBON_COPY
            },
            TYPE_BERATUNGSPROTOKOLL => new Map<String, String>{
                ROLE_ERSTER_KAEUFER => RECIPIENT_TYPE_SIGNER,
                ROLE_MAKLER => RECIPIENT_TYPE_SIGNER,
                ROLE_PARTNERMANAGER => RECIPIENT_TYPE_CARBON_COPY
            }
        };

    public class Request {
        @InvocableVariable(label='Document Type' required=true)
        public String documentType;

        @InvocableVariable(label='Related Record Id' required=true)
        public Id relatedRecordId;

        @InvocableVariable(label='Email Subject' required=false)
        public String emailSubject;

        @InvocableVariable(label='Email Body' required=false)
        public String emailBody;

        @InvocableVariable(label='Erster Käufer Record Id' required=true)
        public Id ersterKaeuferRecordId;
        @InvocableVariable(label='Erster Käufer Name' required=true)
        public String ersterKaeuferName;
        @InvocableVariable(label='Erster Käufer Email' required=true)
        public String ersterKaeuferEmail;
        @InvocableVariable(label='Erster Käufer Tabs JSON' required=false)
        public String ersterKaeuferTabsJson;

        @InvocableVariable(label='Zweiter Käufer Record Id' required=false)
        public Id zweiterKaeuferRecordId;
        @InvocableVariable(label='Zweiter Käufer Name' required=false)
        public String zweiterKaeuferName;
        @InvocableVariable(label='Zweiter Käufer Email' required=false)
        public String zweiterKaeuferEmail;
        @InvocableVariable(label='Zweiter Käufer Tabs JSON' required=false)
        public String zweiterKaeuferTabsJson;

        @InvocableVariable(label='Makler Record Id' required=true)
        public Id maklerRecordId;
        @InvocableVariable(label='Makler Name' required=true)
        public String maklerName;
        @InvocableVariable(label='Makler Email' required=true)
        public String maklerEmail;
        @InvocableVariable(label='Makler Tabs JSON' required=false)
        public String maklerTabsJson;

        @InvocableVariable(label='Partnermanager Record Id' required=true)
        public Id partnermanagerRecordId;
        @InvocableVariable(label='Partnermanager Name' required=true)
        public String partnermanagerName;
        @InvocableVariable(label='Partnermanager Email' required=true)
        public String partnermanagerEmail;
        @InvocableVariable(label='Partnermanager Tabs JSON' required=false)
        public String partnermanagerTabsJson;
    }

    @InvocableMethod(
        label='Send Buyer Documents'
        description='Sends Notarauftrag, Reservierung, Vertrauliche Selbstauskunft and Beratungsprotokoll templates for roles Erster Käufer, Zweiter Käufer, Makler and Partnermanager.'
    )
    public static void send(List<Request> requests) {
        if (requests == null || requests.isEmpty()) {
            return;
        }

        List<DSAuftragsdatenverarbeitungService.RoleBasedRequest> mappedRequests =
            new List<DSAuftragsdatenverarbeitungService.RoleBasedRequest>();

        for (Request request : requests) {
            if (request == null) {
                continue;
            }
            mappedRequests.add(mapRequest(request));
        }

        DSAuftragsdatenverarbeitungService.sendRoleBased(mappedRequests);
    }

    private static DSAuftragsdatenverarbeitungService.RoleBasedRequest mapRequest(Request request) {
        validateRequest(request);

        DSAuftragsdatenverarbeitungService.RoleBasedRequest mappedRequest =
            new DSAuftragsdatenverarbeitungService.RoleBasedRequest();
        mappedRequest.relatedRecordId = request.relatedRecordId;
        mappedRequest.templateId = TEMPLATE_BY_DOCUMENT_TYPE.get(request.documentType);
        mappedRequest.documentName = request.documentType;
        mappedRequest.emailSubject = String.isBlank(request.emailSubject)
            ? request.documentType
            : request.emailSubject;
        mappedRequest.emailBody = String.isBlank(request.emailBody)
            ? DEFAULT_EMAIL_BODY
            : request.emailBody;

        if (TYPE_BERATUNGSPROTOKOLL == request.documentType) {
            mappedRequest.recipients = new List<DSAuftragsdatenverarbeitungService.RoleBasedRecipient>{
                buildRecipient(
                    ROLE_MAKLER,
                    request.maklerName,
                    request.maklerEmail,
                    request.maklerRecordId,
                    getRecipientTypeForDocumentAndRole(request.documentType, ROLE_MAKLER),
                    parseTabsJson(request.maklerTabsJson, ROLE_MAKLER)
                ),
                buildRecipient(
                    ROLE_ERSTER_KAEUFER,
                    request.ersterKaeuferName,
                    request.ersterKaeuferEmail,
                    request.ersterKaeuferRecordId,
                    getRecipientTypeForDocumentAndRole(request.documentType, ROLE_ERSTER_KAEUFER),
                    parseTabsJson(request.ersterKaeuferTabsJson, ROLE_ERSTER_KAEUFER)
                ),
                buildRecipient(
                    ROLE_PARTNERMANAGER,
                    request.partnermanagerName,
                    request.partnermanagerEmail,
                    request.partnermanagerRecordId,
                    getRecipientTypeForDocumentAndRole(request.documentType, ROLE_PARTNERMANAGER),
                    parseTabsJson(request.partnermanagerTabsJson, ROLE_PARTNERMANAGER)
                )
            };
        } else {
            mappedRequest.recipients = new List<DSAuftragsdatenverarbeitungService.RoleBasedRecipient>{
                buildRecipient(
                    ROLE_ERSTER_KAEUFER,
                    request.ersterKaeuferName,
                    request.ersterKaeuferEmail,
                    request.ersterKaeuferRecordId,
                    getRecipientTypeForDocumentAndRole(request.documentType, ROLE_ERSTER_KAEUFER),
                    parseTabsJson(request.ersterKaeuferTabsJson, ROLE_ERSTER_KAEUFER)
                )
            };

            if (hasZweiterKaeufer(request)) {
                mappedRequest.recipients.add(
                    buildRecipient(
                        ROLE_ZWEITER_KAEUFER,
                        request.zweiterKaeuferName,
                        request.zweiterKaeuferEmail,
                        request.zweiterKaeuferRecordId,
                        getRecipientTypeForDocumentAndRole(request.documentType, ROLE_ZWEITER_KAEUFER),
                        parseTabsJson(request.zweiterKaeuferTabsJson, ROLE_ZWEITER_KAEUFER)
                    )
                );
            }

            mappedRequest.recipients.add(
                buildRecipient(
                    ROLE_MAKLER,
                    request.maklerName,
                    request.maklerEmail,
                    request.maklerRecordId,
                    getRecipientTypeForDocumentAndRole(request.documentType, ROLE_MAKLER),
                    parseTabsJson(request.maklerTabsJson, ROLE_MAKLER)
                )
            );

            mappedRequest.recipients.add(
                buildRecipient(
                    ROLE_PARTNERMANAGER,
                    request.partnermanagerName,
                    request.partnermanagerEmail,
                    request.partnermanagerRecordId,
                    getRecipientTypeForDocumentAndRole(request.documentType, ROLE_PARTNERMANAGER),
                    parseTabsJson(request.partnermanagerTabsJson, ROLE_PARTNERMANAGER)
                )
            );
        }

        return mappedRequest;
    }

    private static DSAuftragsdatenverarbeitungService.RoleBasedRecipient buildRecipient(
        String roleName,
        String name,
        String email,
        Id sourceEntityId,
        String recipientType,
        List<DSAuftragsdatenverarbeitungService.PrefillTab> prefillTabs
    ) {
        DSAuftragsdatenverarbeitungService.RoleBasedRecipient recipient =
            new DSAuftragsdatenverarbeitungService.RoleBasedRecipient();
        recipient.roleName = roleName;
        recipient.name = name;
        recipient.email = email;
        recipient.sourceEntityId = sourceEntityId;
        recipient.recipientType = recipientType;
        recipient.prefillTabs = prefillTabs;
        return recipient;
    }

    private static List<DSAuftragsdatenverarbeitungService.PrefillTab> parseTabsJson(
        String tabsJson,
        String roleName
    ) {
        List<DSAuftragsdatenverarbeitungService.PrefillTab> tabs =
            new List<DSAuftragsdatenverarbeitungService.PrefillTab>();

        if (String.isBlank(tabsJson)) {
            return tabs;
        }

        Object parsed = JSON.deserializeUntyped(tabsJson);
        if (!(parsed instanceof Map<String, Object>)) {
            throw new SendDSBuyerDocumentsActionException(
                roleName + ' Tabs JSON must be a JSON object with dataLabel:value pairs.'
            );
        }

        Map<String, Object> tabsMap = (Map<String, Object>)parsed;
        for (String dataLabel : tabsMap.keySet()) {
            if (String.isBlank(dataLabel)) {
                throw new SendDSBuyerDocumentsActionException(roleName + ' Tabs JSON contains an empty dataLabel.');
            }

            Object value = tabsMap.get(dataLabel);
            if (value == null) {
                continue;
            }

            DSAuftragsdatenverarbeitungService.PrefillTab tab =
                new DSAuftragsdatenverarbeitungService.PrefillTab();
            tab.dataLabel = dataLabel;
            tab.isCheckbox = false;

            if (value instanceof Boolean) {
                tab.isCheckbox = true;
                tab.checkboxValue = (Boolean)value;
                tab.value = String.valueOf(value);
            } else {
                String stringValue = String.valueOf(value);
                if ('true'.equalsIgnoreCase(stringValue) || 'false'.equalsIgnoreCase(stringValue)) {
                    tab.isCheckbox = true;
                    tab.checkboxValue = 'true'.equalsIgnoreCase(stringValue);
                }
                tab.value = stringValue;
            }
            tabs.add(tab);
        }

        return tabs;
    }

    private static void validateRequest(Request request) {
        if (request.relatedRecordId == null) {
            throw new SendDSBuyerDocumentsActionException('relatedRecordId is required.');
        }
        if (String.isBlank(request.documentType)) {
            throw new SendDSBuyerDocumentsActionException('documentType is required.');
        }
        if (!TEMPLATE_BY_DOCUMENT_TYPE.containsKey(request.documentType)) {
            throw new SendDSBuyerDocumentsActionException('Unsupported documentType: ' + request.documentType + '.');
        }

        String expectedLinkedObject = LINKED_OBJECT_BY_DOCUMENT_TYPE.get(request.documentType);
        String actualLinkedObject = request.relatedRecordId.getSObjectType().getDescribe().getName();
        if (expectedLinkedObject != actualLinkedObject) {
            throw new SendDSBuyerDocumentsActionException(
                'Invalid linked record type for ' + request.documentType +
                '. Expected ' + expectedLinkedObject + ' but got ' + actualLinkedObject + '.'
            );
        }

        validateRecipient(request.ersterKaeuferRecordId, request.ersterKaeuferName, request.ersterKaeuferEmail, ROLE_ERSTER_KAEUFER);
        validateOptionalRecipient(
            request.zweiterKaeuferRecordId,
            request.zweiterKaeuferName,
            request.zweiterKaeuferEmail,
            ROLE_ZWEITER_KAEUFER
        );
        if (TYPE_BERATUNGSPROTOKOLL == request.documentType && hasAnyZweiterKaeuferInput(request)) {
            throw new SendDSBuyerDocumentsActionException('Zweiter Käufer is not supported for documentType Beratungsprotokoll.');
        }
        validateRecipient(request.maklerRecordId, request.maklerName, request.maklerEmail, ROLE_MAKLER);
        validateRecipient(request.partnermanagerRecordId, request.partnermanagerName, request.partnermanagerEmail, ROLE_PARTNERMANAGER);
    }

    private static void validateRecipient(Id recordId, String name, String email, String roleName) {
        if (recordId == null) {
            throw new SendDSBuyerDocumentsActionException(roleName + ' Record Id is required.');
        }
        if (String.isBlank(name)) {
            throw new SendDSBuyerDocumentsActionException(roleName + ' Name is required.');
        }
        if (String.isBlank(email)) {
            throw new SendDSBuyerDocumentsActionException(roleName + ' Email is required.');
        }
    }

    private static void validateOptionalRecipient(Id recordId, String name, String email, String roleName) {
        if (recordId == null && String.isBlank(name) && String.isBlank(email)) {
            return;
        }
        validateRecipient(recordId, name, email, roleName);
    }

    private static Boolean hasZweiterKaeufer(Request request) {
        return request.zweiterKaeuferRecordId != null
            && !String.isBlank(request.zweiterKaeuferName)
            && !String.isBlank(request.zweiterKaeuferEmail);
    }

    private static Boolean hasAnyZweiterKaeuferInput(Request request) {
        return request.zweiterKaeuferRecordId != null
            || !String.isBlank(request.zweiterKaeuferName)
            || !String.isBlank(request.zweiterKaeuferEmail)
            || !String.isBlank(request.zweiterKaeuferTabsJson);
    }

    @TestVisible
    private static String getRecipientTypeForDocumentAndRole(String documentType, String roleName) {
        if (String.isBlank(documentType) || String.isBlank(roleName)) {
            throw new SendDSBuyerDocumentsActionException('documentType and roleName are required for recipient type lookup.');
        }

        Map<String, String> roleToType = RECIPIENT_TYPE_BY_DOCUMENT_AND_ROLE.get(documentType);
        if (roleToType == null) {
            throw new SendDSBuyerDocumentsActionException('No recipient type configuration found for documentType: ' + documentType + '.');
        }

        String recipientType = roleToType.get(roleName);
        if (String.isBlank(recipientType)) {
            throw new SendDSBuyerDocumentsActionException(
                'No recipient type configuration found for role ' + roleName + ' in documentType ' + documentType + '.'
            );
        }

        return recipientType;
    }

    public class SendDSBuyerDocumentsActionException extends Exception {
    }
}