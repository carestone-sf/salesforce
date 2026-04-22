@IsTest
private class DSAuftragsdatenverarbeitungServiceTest {

    private class MockEnvelopeSender implements DSAuftragsdatenverarbeitungService.EnvelopeSender {
        public Integer callCount = 0;
        public Integer envelopeCount = 0;

        public void send(List<dfsle.Envelope> envelopes) {
            callCount++;
            envelopeCount += (envelopes == null) ? 0 : envelopes.size();
        }
    }

    @IsTest
    static void send_withValidPayload_sendsEnvelope() {
        Account account = TestDataFactory.createAccount(true, 'DocuSign Account');
        Contact interessent = TestDataFactory.createInteressent(true, account.Id);
        Contact makler = TestDataFactory.createMakler(true, account.Id);
        Contact partner = TestDataFactory.createContact(true, 'Paula', 'Partner', 'partner@example.com');

        DSAuftragsdatenverarbeitung payload = new DSAuftragsdatenverarbeitung();
        payload.relatedRecordId = account.Id;

        payload.Interessent.interessentenRecordId = interessent.Id;
        payload.Interessent.maklerRecordId = makler.Id;
        payload.Interessent.partnermanagerRecordId = partner.Id;
        payload.Interessent.Name = 'Max Interessent';
        payload.Interessent.Email = 'interessent@example.com';

        payload.Makler.Name = 'Maria Makler';
        payload.Makler.Email = 'makler@example.com';

        payload.Partnermanager.Name = 'Peter Partner';
        payload.Partnermanager.Email = 'partner@example.com';

        MockEnvelopeSender mockSender = new MockEnvelopeSender();
        DSAuftragsdatenverarbeitungService.envelopeSender = mockSender;

        Test.startTest();
            DSAuftragsdatenverarbeitungService.send(payload);
        Test.stopTest();

        System.assertEquals(1, mockSender.callCount, 'Sender must be invoked once.');
        System.assertEquals(1, mockSender.envelopeCount, 'Exactly one envelope must be sent.');
    }

    @IsTest
    static void send_missingInteressentName_throwsException() {
        Account account = TestDataFactory.createAccount(true, 'DocuSign Account 2');
        Contact interessent = TestDataFactory.createInteressent(true, account.Id);
        Contact makler = TestDataFactory.createMakler(true, account.Id);
        Contact partner = TestDataFactory.createContact(true, 'Paula', 'Partner', 'partner2@example.com');

        DSAuftragsdatenverarbeitung payload = new DSAuftragsdatenverarbeitung();
        payload.relatedRecordId = account.Id;

        payload.Interessent.interessentenRecordId = interessent.Id;
        payload.Interessent.maklerRecordId = makler.Id;
        payload.Interessent.partnermanagerRecordId = partner.Id;
        payload.Interessent.Email = 'interessent@example.com';

        payload.Makler.Name = 'Maria Makler';
        payload.Makler.Email = 'makler@example.com';

        payload.Partnermanager.Name = 'Peter Partner';
        payload.Partnermanager.Email = 'partner@example.com';

        Boolean didThrow = false;
        try {
            DSAuftragsdatenverarbeitungService.send(payload);
        } catch (Exception ex) {
            didThrow = true;
        }

        System.assertEquals(true, didThrow, 'Validation error was expected.');
    }
}