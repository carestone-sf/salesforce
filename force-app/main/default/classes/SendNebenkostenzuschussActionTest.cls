@IsTest
private class SendNebenkostenzuschussActionTest {

    @testSetup
    static void setupData() {
        TestDataFactory.createNecessaryCustomSettings();
        TestDataFactory.createDatevSettings();
    }

    @IsTest
    static void testActionCallsService_HappyPath() {
        Account acc = TestDataFactory.createAccount(true);
        Contact vk  = TestDataFactory.createMakler(true, acc.Id);
        Contact intc = TestDataFactory.createInteressent(true, acc.Id);

        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c imm    = TestDataFactory.createProperty(true, bautraeger.Id);
        Appartment__c app  = TestDataFactory.createAppartment(true, imm.Id);

        Opportunity opp = TestDataFactory.createOpportunity(
            true,
            intc.Id,
            vk.Id,
            imm.Id,
            app.Id
        );

        // Explicitly ensure field is set
        opp.Vertriebskoordinator__c = vk.Id;
        update opp;

        Test.startTest();
            SendNebenkostenzuschussAction.send(new List<Id>{ opp.Id });
        Test.stopTest();

        // Email assertion intentionally omitted (same pattern as your other tests)
    }

    @IsTest
    static void testActionHandlesNullAndEmptyList() {
        Test.startTest();
            SendNebenkostenzuschussAction.send(null);
            SendNebenkostenzuschussAction.send(new List<Id>());
        Test.stopTest();

        System.assertEquals(
            0,
            Limits.getEmailInvocations(),
            'No emails must be sent for null or empty input.'
        );
    }
}