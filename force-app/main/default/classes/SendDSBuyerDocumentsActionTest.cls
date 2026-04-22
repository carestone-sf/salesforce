@IsTest
private class SendDSBuyerDocumentsActionTest {

    private class MockEnvelopeSender implements DSAuftragsdatenverarbeitungService.EnvelopeSender {
        public Integer callCount = 0;
        public Integer envelopeCount = 0;

        public void send(List<dfsle.Envelope> envelopes) {
            callCount++;
            envelopeCount += (envelopes == null) ? 0 : envelopes.size();
        }
    }

    @IsTest
    static void send_notarauftrag_withValidPayload_callsService() {
        Opportunity opp = TestDataFactory.createOpportunity(true);

        Contact ersterKaeufer = TestDataFactory.createContact(true, 'Erster', 'Kaeufer', 'erster@example.com');
        Contact zweiterKaeufer = TestDataFactory.createContact(true, 'Zweiter', 'Kaeufer', 'zweiter@example.com');
        Contact makler = TestDataFactory.createContact(true, 'Maria', 'Makler', 'makler@example.com');
        Contact partnermanager = TestDataFactory.createContact(true, 'Peter', 'Partner', 'partner@example.com');

        SendDSBuyerDocumentsAction.Request request = new SendDSBuyerDocumentsAction.Request();
        request.documentType = 'Notarauftrag';
        request.relatedRecordId = opp.Id;

        request.ersterKaeuferRecordId = ersterKaeufer.Id;
        request.ersterKaeuferName = 'Erster Käufer';
        request.ersterKaeuferEmail = 'erster@example.com';
        request.ersterKaeuferTabsJson = '{\"vsaFirstName\":\"Erster\",\"vsaAge\":30,\"vsaAccepted\":true}';

        request.zweiterKaeuferRecordId = zweiterKaeufer.Id;
        request.zweiterKaeuferName = 'Zweiter Käufer';
        request.zweiterKaeuferEmail = 'zweiter@example.com';
        request.zweiterKaeuferTabsJson = '{\"vsaSecondName\":\"Zweiter\",\"vsaSecondAccepted\":false}';

        request.maklerRecordId = makler.Id;
        request.maklerName = 'Maria Makler';
        request.maklerEmail = 'makler@example.com';
        request.maklerTabsJson = '{\"brokerCode\":\"M-1001\"}';

        request.partnermanagerRecordId = partnermanager.Id;
        request.partnermanagerName = 'Peter Partner';
        request.partnermanagerEmail = 'partner@example.com';
        request.partnermanagerTabsJson = '{\"partnerCode\":\"P-2002\"}';

        MockEnvelopeSender mockSender = new MockEnvelopeSender();
        DSAuftragsdatenverarbeitungService.envelopeSender = mockSender;

        Test.startTest();
            SendDSBuyerDocumentsAction.send(new List<SendDSBuyerDocumentsAction.Request>{ request });
        Test.stopTest();

        System.assertEquals(1, mockSender.callCount, 'Service sender must be called once.');
        System.assertEquals(1, mockSender.envelopeCount, 'Action should produce one envelope.');
    }

    @IsTest
    static void send_notarauftrag_withWrongLinkedRecordType_throws() {
        Account acc = TestDataFactory.createAccount(true, 'Wrong linked record');

        Contact ersterKaeufer = TestDataFactory.createContact(true, 'Erster', 'Kaeufer', 'erster2@example.com');
        Contact zweiterKaeufer = TestDataFactory.createContact(true, 'Zweiter', 'Kaeufer', 'zweiter2@example.com');
        Contact makler = TestDataFactory.createContact(true, 'Maria', 'Makler', 'makler2@example.com');
        Contact partnermanager = TestDataFactory.createContact(true, 'Peter', 'Partner', 'partner2@example.com');

        SendDSBuyerDocumentsAction.Request request = new SendDSBuyerDocumentsAction.Request();
        request.documentType = 'Notarauftrag';
        request.relatedRecordId = acc.Id;

        request.ersterKaeuferRecordId = ersterKaeufer.Id;
        request.ersterKaeuferName = 'Erster Käufer';
        request.ersterKaeuferEmail = 'erster2@example.com';

        request.zweiterKaeuferRecordId = zweiterKaeufer.Id;
        request.zweiterKaeuferName = 'Zweiter Käufer';
        request.zweiterKaeuferEmail = 'zweiter2@example.com';

        request.maklerRecordId = makler.Id;
        request.maklerName = 'Maria Makler';
        request.maklerEmail = 'makler2@example.com';

        request.partnermanagerRecordId = partnermanager.Id;
        request.partnermanagerName = 'Peter Partner';
        request.partnermanagerEmail = 'partner2@example.com';

        Boolean didThrow = false;
        try {
            SendDSBuyerDocumentsAction.send(new List<SendDSBuyerDocumentsAction.Request>{ request });
        } catch (SendDSBuyerDocumentsAction.SendDSBuyerDocumentsActionException ex) {
            didThrow = true;
        }

        System.assertEquals(true, didThrow, 'Validation error was expected.');
    }

    @IsTest
    static void send_withoutZweiterKaeufer_callsService() {
        Opportunity opp = TestDataFactory.createOpportunity(true);

        Contact ersterKaeufer = TestDataFactory.createContact(true, 'Erster', 'Kaeufer', 'erster4@example.com');
        Contact makler = TestDataFactory.createContact(true, 'Maria', 'Makler', 'makler4@example.com');
        Contact partnermanager = TestDataFactory.createContact(true, 'Peter', 'Partner', 'partner4@example.com');

        SendDSBuyerDocumentsAction.Request request = new SendDSBuyerDocumentsAction.Request();
        request.documentType = 'Reservierung';
        request.relatedRecordId = opp.Id;

        request.ersterKaeuferRecordId = ersterKaeufer.Id;
        request.ersterKaeuferName = 'Erster Käufer';
        request.ersterKaeuferEmail = 'erster4@example.com';

        request.maklerRecordId = makler.Id;
        request.maklerName = 'Maria Makler';
        request.maklerEmail = 'makler4@example.com';

        request.partnermanagerRecordId = partnermanager.Id;
        request.partnermanagerName = 'Peter Partner';
        request.partnermanagerEmail = 'partner4@example.com';

        MockEnvelopeSender mockSender = new MockEnvelopeSender();
        DSAuftragsdatenverarbeitungService.envelopeSender = mockSender;

        Test.startTest();
            SendDSBuyerDocumentsAction.send(new List<SendDSBuyerDocumentsAction.Request>{ request });
        Test.stopTest();

        System.assertEquals(1, mockSender.callCount, 'Service sender must be called once.');
        System.assertEquals(1, mockSender.envelopeCount, 'Action should produce one envelope.');
    }

    @IsTest
    static void send_withInvalidTabsJson_throws() {
        Opportunity opp = TestDataFactory.createOpportunity(true);

        Contact ersterKaeufer = TestDataFactory.createContact(true, 'Erster', 'Kaeufer', 'erster3@example.com');
        Contact zweiterKaeufer = TestDataFactory.createContact(true, 'Zweiter', 'Kaeufer', 'zweiter3@example.com');
        Contact makler = TestDataFactory.createContact(true, 'Maria', 'Makler', 'makler3@example.com');
        Contact partnermanager = TestDataFactory.createContact(true, 'Peter', 'Partner', 'partner3@example.com');

        SendDSBuyerDocumentsAction.Request request = new SendDSBuyerDocumentsAction.Request();
        request.documentType = 'Reservierung';
        request.relatedRecordId = opp.Id;

        request.ersterKaeuferRecordId = ersterKaeufer.Id;
        request.ersterKaeuferName = 'Erster Käufer';
        request.ersterKaeuferEmail = 'erster3@example.com';
        request.ersterKaeuferTabsJson = '[\"not-an-object\"]';

        request.zweiterKaeuferRecordId = zweiterKaeufer.Id;
        request.zweiterKaeuferName = 'Zweiter Käufer';
        request.zweiterKaeuferEmail = 'zweiter3@example.com';

        request.maklerRecordId = makler.Id;
        request.maklerName = 'Maria Makler';
        request.maklerEmail = 'makler3@example.com';

        request.partnermanagerRecordId = partnermanager.Id;
        request.partnermanagerName = 'Peter Partner';
        request.partnermanagerEmail = 'partner3@example.com';

        Boolean didThrow = false;
        try {
            SendDSBuyerDocumentsAction.send(new List<SendDSBuyerDocumentsAction.Request>{ request });
        } catch (SendDSBuyerDocumentsAction.SendDSBuyerDocumentsActionException ex) {
            didThrow = true;
        }

        System.assertEquals(true, didThrow, 'Invalid tabs JSON must throw.');
    }

    @IsTest
    static void send_withPartialZweiterKaeufer_throws() {
        Opportunity opp = TestDataFactory.createOpportunity(true);

        Contact ersterKaeufer = TestDataFactory.createContact(true, 'Erster', 'Kaeufer', 'erster5@example.com');
        Contact makler = TestDataFactory.createContact(true, 'Maria', 'Makler', 'makler5@example.com');
        Contact partnermanager = TestDataFactory.createContact(true, 'Peter', 'Partner', 'partner5@example.com');

        SendDSBuyerDocumentsAction.Request request = new SendDSBuyerDocumentsAction.Request();
        request.documentType = 'Reservierung';
        request.relatedRecordId = opp.Id;

        request.ersterKaeuferRecordId = ersterKaeufer.Id;
        request.ersterKaeuferName = 'Erster Käufer';
        request.ersterKaeuferEmail = 'erster5@example.com';

        request.zweiterKaeuferName = 'Only Name';

        request.maklerRecordId = makler.Id;
        request.maklerName = 'Maria Makler';
        request.maklerEmail = 'makler5@example.com';

        request.partnermanagerRecordId = partnermanager.Id;
        request.partnermanagerName = 'Peter Partner';
        request.partnermanagerEmail = 'partner5@example.com';

        Boolean didThrow = false;
        try {
            SendDSBuyerDocumentsAction.send(new List<SendDSBuyerDocumentsAction.Request>{ request });
        } catch (SendDSBuyerDocumentsAction.SendDSBuyerDocumentsActionException ex) {
            didThrow = true;
        }

        System.assertEquals(true, didThrow, 'Partial second buyer payload must throw.');
    }

    @IsTest
    static void recipientTypeMatrix_usesExpectedTypesPerDocument() {
        System.assertEquals(
            dfsle.Recipient.TYPE_CARBON_COPY,
            SendDSBuyerDocumentsAction.getRecipientTypeForDocumentAndRole('Reservierung', 'Makler')
        );
        System.assertEquals(
            dfsle.Recipient.TYPE_CARBON_COPY,
            SendDSBuyerDocumentsAction.getRecipientTypeForDocumentAndRole('Notarauftrag', 'Partnermanager')
        );
        System.assertEquals(
            dfsle.Recipient.TYPE_CARBON_COPY,
            SendDSBuyerDocumentsAction.getRecipientTypeForDocumentAndRole('Vertrauliche Selbstauskunft', 'Makler')
        );
        System.assertEquals(
            dfsle.Recipient.TYPE_SIGNER,
            SendDSBuyerDocumentsAction.getRecipientTypeForDocumentAndRole('Beratungsprotokoll', 'Makler')
        );
        System.assertEquals(
            dfsle.Recipient.TYPE_SIGNER,
            SendDSBuyerDocumentsAction.getRecipientTypeForDocumentAndRole('Beratungsprotokoll', 'Erster Käufer')
        );
        System.assertEquals(
            dfsle.Recipient.TYPE_CARBON_COPY,
            SendDSBuyerDocumentsAction.getRecipientTypeForDocumentAndRole('Beratungsprotokoll', 'Partnermanager')
        );
    }

    @IsTest
    static void send_beratungsprotokoll_withoutZweiterKaeufer_callsService() {
        Opportunity opp = TestDataFactory.createOpportunity(true);

        Contact ersterKaeufer = TestDataFactory.createContact(true, 'Erster', 'Kaeufer', 'bp-erster@example.com');
        Contact makler = TestDataFactory.createContact(true, 'Maria', 'Makler', 'bp-makler@example.com');
        Contact partnermanager = TestDataFactory.createContact(true, 'Peter', 'Partner', 'bp-partner@example.com');

        SendDSBuyerDocumentsAction.Request request = new SendDSBuyerDocumentsAction.Request();
        request.documentType = 'Beratungsprotokoll';
        request.relatedRecordId = opp.Id;

        request.ersterKaeuferRecordId = ersterKaeufer.Id;
        request.ersterKaeuferName = 'Erster Käufer';
        request.ersterKaeuferEmail = 'bp-erster@example.com';

        request.maklerRecordId = makler.Id;
        request.maklerName = 'Maria Makler';
        request.maklerEmail = 'bp-makler@example.com';

        request.partnermanagerRecordId = partnermanager.Id;
        request.partnermanagerName = 'Peter Partner';
        request.partnermanagerEmail = 'bp-partner@example.com';

        MockEnvelopeSender mockSender = new MockEnvelopeSender();
        DSAuftragsdatenverarbeitungService.envelopeSender = mockSender;

        Test.startTest();
            SendDSBuyerDocumentsAction.send(new List<SendDSBuyerDocumentsAction.Request>{ request });
        Test.stopTest();

        System.assertEquals(1, mockSender.callCount, 'Service sender must be called once.');
        System.assertEquals(1, mockSender.envelopeCount, 'Action should produce one envelope.');
    }

    @IsTest
    static void send_beratungsprotokoll_withZweiterKaeufer_throws() {
        Opportunity opp = TestDataFactory.createOpportunity(true);

        Contact ersterKaeufer = TestDataFactory.createContact(true, 'Erster', 'Kaeufer', 'bp2-erster@example.com');
        Contact zweiterKaeufer = TestDataFactory.createContact(true, 'Zweiter', 'Kaeufer', 'bp2-zweiter@example.com');
        Contact makler = TestDataFactory.createContact(true, 'Maria', 'Makler', 'bp2-makler@example.com');
        Contact partnermanager = TestDataFactory.createContact(true, 'Peter', 'Partner', 'bp2-partner@example.com');

        SendDSBuyerDocumentsAction.Request request = new SendDSBuyerDocumentsAction.Request();
        request.documentType = 'Beratungsprotokoll';
        request.relatedRecordId = opp.Id;

        request.ersterKaeuferRecordId = ersterKaeufer.Id;
        request.ersterKaeuferName = 'Erster Käufer';
        request.ersterKaeuferEmail = 'bp2-erster@example.com';

        request.zweiterKaeuferRecordId = zweiterKaeufer.Id;
        request.zweiterKaeuferName = 'Zweiter Käufer';
        request.zweiterKaeuferEmail = 'bp2-zweiter@example.com';

        request.maklerRecordId = makler.Id;
        request.maklerName = 'Maria Makler';
        request.maklerEmail = 'bp2-makler@example.com';

        request.partnermanagerRecordId = partnermanager.Id;
        request.partnermanagerName = 'Peter Partner';
        request.partnermanagerEmail = 'bp2-partner@example.com';

        Boolean didThrow = false;
        try {
            SendDSBuyerDocumentsAction.send(new List<SendDSBuyerDocumentsAction.Request>{ request });
        } catch (SendDSBuyerDocumentsAction.SendDSBuyerDocumentsActionException ex) {
            didThrow = true;
        }

        System.assertEquals(true, didThrow, 'Beratungsprotokoll must reject Zweiter Käufer payload.');
    }
}