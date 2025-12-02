@IsTest
private class FinanzierungsanfrageServiceTest {

    @testSetup
    static void setupData() {
        TestDataFactory.createNecessaryCustomSettings();
        TestDataFactory.createDatevSettings();
    }

    @IsTest
    static void testSendFinanzierungsbestaetigung_HappyPath() {
        // Arrange: minimal but valid graph using TestDataFactory

        // Account + Contacts
        Account acc = TestDataFactory.createAccount(true);
        Contact makler      = TestDataFactory.createMakler(true, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(true, acc.Id);

        // Bauträger + Immobilie + Apartment
        Account bautraeger  = TestDataFactory.createBautraeger(true);
        Property__c imm     = TestDataFactory.createProperty(true, bautraeger.Id);
        Appartment__c app   = TestDataFactory.createAppartment(true, imm.Id);

        // Opportunity that will be linked to the Finanzierungsanfrage
        Opportunity opp = TestDataFactory.createOpportunity(
            true,
            interessent.Id,
            makler.Id,
            imm.Id,
            app.Id
        );
        // Ensure Makler is set (factory does this already, but we keep it explicit)
        System.assertNotEquals(null, opp.Makler__c, 'Makler__c must not be null for the email target.');

        // Finanzierungsanfrage with ErsterKaeufer, then link to Opportunity
        Finanzierungsanfrage__c fa = TestDataFactory.createFinanzierungsanfrage(
            true,
            interessent.Id,
            'Test Unterlagen'
        );
        fa.Opportunity__c = opp.Id;
        update fa;

        Test.startTest();
            FinanzierungsanfrageService.sendFinanzierungsbestaetigung(fa.Id);
        Test.stopTest();

        // Assert: email was sent once
        System.assertEquals(
            1,
            Limits.getEmailInvocations(),
            'Exactly one email invocation expected.'
        );

        // Assert: PDF was stored and linked to both FA and Opportunity
        Set<Id> expectedLinkedIds = new Set<Id>{ fa.Id, opp.Id };
        List<ContentDocumentLink> links = [
            SELECT LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :expectedLinkedIds
        ];

        System.assertEquals(
            2,
            links.size(),
            'Expected two ContentDocumentLinks (FA + Opportunity).'
        );

        Set<Id> actualLinkedIds = new Set<Id>();
        for (ContentDocumentLink cdl : links) {
            actualLinkedIds.add(cdl.LinkedEntityId);
        }

        System.assertEquals(
            expectedLinkedIds,
            actualLinkedIds,
            'ContentDocument must be linked to FA and Opportunity.'
        );
    }

    @IsTest
    static void testSendFinanzierungsbestaetigung_NullId() {
        // Just exercise the early return; should not throw and should not send email.
        Test.startTest();
            FinanzierungsanfrageService.sendFinanzierungsbestaetigung(null);
        Test.stopTest();

        System.assertEquals(
            0,
            Limits.getEmailInvocations(),
            'No email should be sent when finanzierungsanfrageId is null.'
        );
    }
}