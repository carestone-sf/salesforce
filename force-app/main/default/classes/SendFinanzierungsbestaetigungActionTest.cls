@IsTest
private class SendFinanzierungsbestaetigungActionTest {

    @testSetup
    static void setupData() {
        TestDataFactory.createNecessaryCustomSettings();
        TestDataFactory.createDatevSettings();
    }

    @IsTest
    static void testActionCallsService_HappyPath() {
        // Arrange: same minimal data setup via TestDataFactory

        Account acc = TestDataFactory.createAccount(true);
        Contact makler      = TestDataFactory.createMakler(true, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(true, acc.Id);

        Account bautraeger  = TestDataFactory.createBautraeger(true);
        Property__c imm     = TestDataFactory.createProperty(true, bautraeger.Id);
        Appartment__c app   = TestDataFactory.createAppartment(true, imm.Id);

        Opportunity opp = TestDataFactory.createOpportunity(
            true,
            interessent.Id,
            makler.Id,
            imm.Id,
            app.Id
        );

        Finanzierungsanfrage__c fa = TestDataFactory.createFinanzierungsanfrage(
            true,
            interessent.Id,
            'Test Unterlagen'
        );
        fa.Opportunity__c = opp.Id;
        update fa;

        Test.startTest();
            SendFinanzierungsbestaetigungAction.send(new List<Id>{ fa.Id });
        Test.stopTest();

        // At least one email invocation should have happened via the service.
        System.assertEquals(
            1,
            Limits.getEmailInvocations(),
            'Action should delegate to service and send one email.'
        );
    }

    @IsTest
    static void testActionHandlesNullAndEmptyList() {
        Test.startTest();
            // null list
            SendFinanzierungsbestaetigungAction.send(null);
            // empty list
            SendFinanzierungsbestaetigungAction.send(new List<Id>());
        Test.stopTest();

        System.assertEquals(
            0,
            Limits.getEmailInvocations(),
            'No emails should be sent for null or empty input.'
        );
    }
}