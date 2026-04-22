@IsTest
private class ProvisionPreviewRestServiceTest {

    @testSetup
    static void setup() {
        TestDataFactory.createNecessaryCustomSettings();
        TestDataFactory.createDatevSettings();
    }

    @IsTest
    static void testRestEndpointCallOnly() {
        // --- Account
        Account acc = TestDataFactory.createAccount(true);
        acc.Carestone_Vertriebsvereinbarung__c = true;
        update acc;

        // --- Broker
        Contact broker = TestDataFactory.createMakler(true, acc.Id);
        broker.Ist_Maklerbetreuer_WH__c = false;
        broker.Gesch_ftsbeziehung__c = 'Makler';
        update broker;

        // --- Kunde
        Contact kunde = TestDataFactory.createInteressent(true, acc.Id);

        // --- Objekt
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c imm = TestDataFactory.createProperty(true, bautraeger.Id);
        Appartment__c app = TestDataFactory.createAppartment(true, imm.Id);
        update app;

        // --- Opportunity (minimal viable for preview)
        Opportunity opp = TestDataFactory.createOpportunity(
            true,
            kunde.Id,
            broker.Id,
            imm.Id,
            app.Id
        );

        opp.StageName = 'Notartermin hat stattgefunden';
        opp.ExterneProvisionenGeneriert__c = false;
        opp.Provisionsbasis__c = 100000;
        opp.Probability = 50;
        opp.Makler__c = broker.Id;
        opp.Immobilienberater__c = broker.Id;
        opp.Maklerprovision__c = '10';
        opp.Marketingzuschuss__c = 0;
        update opp;

        // --- REST context simulation
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestUri = '/services/apexrest/provision-preview';
        req.httpMethod = 'GET';
        req.addParameter('brokerContactId', (String)broker.Id);

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
            ProvisionPreviewRestService.getOpenBrokerProvisions();
        Test.stopTest();
    }
}