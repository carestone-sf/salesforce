@IsTest
private class SendDSADVActionTest {

    private class MockEnvelopeSender implements DSAuftragsdatenverarbeitungService.EnvelopeSender {
        public Integer callCount = 0;
        public Integer envelopeCount = 0;

        public void send(List<dfsle.Envelope> envelopes) {
            callCount++;
            envelopeCount += (envelopes == null) ? 0 : envelopes.size();
        }
    }

    @IsTest
    static void action_withValidPayload_callsService() {
        Account account = TestDataFactory.createAccount(true, 'Action Account');
        Contact interessent = TestDataFactory.createInteressent(true, account.Id);
        Contact makler = TestDataFactory.createMakler(true, account.Id);
        Contact partner = TestDataFactory.createContact(true, 'Paula', 'Partner', 'action.partner@example.com');

        SendDSAuftragsdatenverarbeitungAction.Request request = new SendDSAuftragsdatenverarbeitungAction.Request();
        request.relatedRecordId = account.Id;

        request.interessentenRecordId = interessent.Id;
        request.maklerRecordId = makler.Id;
        request.partnermanagerRecordId = partner.Id;
        request.interessentName = 'Max Interessent';
        request.interessentEmail = 'interessent@example.com';

        request.maklerName = 'Maria Makler';
        request.maklerEmail = 'makler@example.com';

        request.partnermanagerName = 'Peter Partner';
        request.partnermanagerEmail = 'partner@example.com';

        MockEnvelopeSender mockSender = new MockEnvelopeSender();
        DSAuftragsdatenverarbeitungService.envelopeSender = mockSender;

        Test.startTest();
            SendDSAuftragsdatenverarbeitungAction.send(
                new List<SendDSAuftragsdatenverarbeitungAction.Request>{ request }
            );
        Test.stopTest();

        System.assertEquals(1, mockSender.callCount, 'Service sender must be called once.');
        System.assertEquals(1, mockSender.envelopeCount, 'Action should produce one envelope.');
    }

    @IsTest
    static void action_withNullAndEmptyInput_doesNothing() {
        MockEnvelopeSender mockSender = new MockEnvelopeSender();
        DSAuftragsdatenverarbeitungService.envelopeSender = mockSender;

        Test.startTest();
            SendDSAuftragsdatenverarbeitungAction.send(null);
            SendDSAuftragsdatenverarbeitungAction.send(new List<SendDSAuftragsdatenverarbeitungAction.Request>());
        Test.stopTest();

        System.assertEquals(0, mockSender.callCount, 'No sender calls expected.');
    }
}