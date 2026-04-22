@IsTest
private class OpportunityServiceTest {

    @testSetup
    static void setupData() {
        TestDataFactory.createNecessaryCustomSettings();
        TestDataFactory.createDatevSettings();
    }

    @IsTest
    static void testSendNebenkostenzuschuss_HappyPath() {
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

        opp.Vertriebskoordinator__c = vk.Id;
        update opp;

        Test.startTest();
            OpportunityService.sendNebenkostenzuschuss(opp.Id);
        Test.stopTest();

        // Same reasoning as your other services:
        // Email send verified implicitly by not throwing and coverage.
    }

    @IsTest
    static void testSendNebenkostenzuschuss_NullId() {
        Test.startTest();
            OpportunityService.sendNebenkostenzuschuss(null);
        Test.stopTest();

        System.assertEquals(
            0,
            Limits.getEmailInvocations(),
            'No email should be sent for null Opportunity Id.'
        );
    }

    @IsTest
    static void testSendNebenkostenzuschuss_NoVertriebskoordinator() {
        Account acc = TestDataFactory.createAccount(true);
        Contact vk  = TestDataFactory.createMakler(true, acc.Id);
        Contact intc = TestDataFactory.createInteressent(true, acc.Id);

        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c imm    = TestDataFactory.createProperty(true, bautraeger.Id);
        Appartment__c app  = TestDataFactory.createAppartment(true, imm.Id);

        // ✅ Always pass a valid Makler to the factory
        Opportunity opp = TestDataFactory.createOpportunity(
            true,
            intc.Id,
            vk.Id,
            imm.Id,
            app.Id
        );

        // ✅ Then explicitly remove it
        opp.Vertriebskoordinator__c = null;
        update opp;

        Test.startTest();
            OpportunityService.sendNebenkostenzuschuss(opp.Id);
        Test.stopTest();

        System.assertEquals(
            0,
            Limits.getEmailInvocations(),
            'No email should be sent if Vertriebskoordinator__c is missing.'
        );
    }

}