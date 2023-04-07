@isTest
private class RestTeamProQOpportunityTest {
    @TestSetup
    static void makeData() {
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c property = TestDataFactory.createProperty(false, bautraeger.Id);
        property.TeamProQId__c = '1234';
        insert property;
        Appartment__c app = TestDataFactory.createAppartment(false, property.Id);
        app.TeamProQId__c = '5678';
        insert app;
        Account acc = TestDataFactory.createAccount(true);
        Contact broker = TestDataFactory.createMakler(false, acc.Id);
        broker.Phone = '0511 - 153434';
        broker.Birthdate = Date.today()-12000;
        broker.Email = 'test@tester.de';
        insert broker;
    }

    @isTest
    private static void testSuccessfulOpportunityCreation() {
        RestTeamProQOpportunity.RestTeamProQOpportunityRequest data = getFullTestData();
        Test.startTest();
        RestTeamProQOpportunity.RestTeamProQOpportunityResponse res = RestTeamProQOpportunity.createOpportunity(data);
        Test.stopTest();

        // Verify Data
        List<Opportunity> opps = [SELECT Makler__r.FirstName, Makler__r.LastName, AccountId, Potenzieller_Kunde__c, Potenzieller_Kunde__r.FirstName, Potenzieller_Kunde__r.LastName, Kunde2__r.FirstName, Kunde2__r.LastName, Appartement__r.TeamProQId__c, Immobilie__r.TeamProQId__c FROM Opportunity LIMIT 1];
        System.assertEquals(1, opps.size(), 'There should be exactly one opportunity.');
        Opportunity opp = opps[0];
        System.assertEquals(true, res.success, 'The returned status code is false, should be true.');
        System.assertEquals(0, res.errors.size(), 'There should be 0 errors returned.');
        System.assertEquals(data.accountId, opp.AccountId, 'The accountId is different from payload.');
        System.assertEquals(data.propertyExternalId, opp.Immobilie__r.TeamProQId__C, 'The external propertyId is different from payload.');
        System.assertEquals(data.apartmentExternalId, opp.Appartement__r.TeamProQId__c, 'The external apartmentId is different from payload.');
        System.assertEquals(data.firstBuyer.FirstName, opp.Potenzieller_Kunde__r.FirstName, 'The first name of the first buyer is different from payload.');
        System.assertEquals(data.firstBuyer.LastName, opp.Potenzieller_Kunde__r.LastName, 'The last name of the first buyer is different from payload.');
        System.assertEquals(data.secondBuyer.FirstName, opp.Kunde2__r.FirstName, 'The first name of the second buyer is different from payload.');
        System.assertEquals(data.secondBuyer.LastName, opp.Kunde2__r.LastName, 'The last name of the second buyer is different from payload.');
        System.assertEquals(data.broker.FirstName, opp.Makler__r.FirstName, 'The first name of the broker is different from payload.');
        System.assertEquals(data.broker.LastName, opp.Makler__r.LastName, 'The last name of the broker is different from payload.');
    }

    @isTest
    private static void testMissingAccountId() {
        RestTeamProQOpportunity.RestTeamProQOpportunityRequest data = new RestTeamProQOpportunity.RestTeamProQOpportunityRequest();
        Test.startTest();
        RestTeamProQOpportunity.RestTeamProQOpportunityResponse res = RestTeamProQOpportunity.createOpportunity(data);
        Test.stopTest();

        // Verify Data
        System.assertEquals(false, res.success, 'The returned status code is true, should be false.');
        System.assertEquals(1, res.errors.size(), 'There should be 1 error returned.');
        System.assertEquals('AccountIdEmpty', res.errors[0].code, 'The error code is other than expected.');
    }

    @isTest
    private static void testWrongAccountId() {
        RestTeamProQOpportunity.RestTeamProQOpportunityRequest data = new RestTeamProQOpportunity.RestTeamProQOpportunityRequest();
        data.accountId = '0016700005ScvRiAAJ';
        Test.startTest();
        RestTeamProQOpportunity.RestTeamProQOpportunityResponse res = RestTeamProQOpportunity.createOpportunity(data);
        Test.stopTest();

        // Verify Data
        System.assertEquals(false, res.success, 'The returned status code is true, should be false.');
        System.assertEquals(1, res.errors.size(), 'There should be 1 error returned.');
        System.assertEquals('AccountNotFound', res.errors[0].code, 'The error code is other than expected.');
    }

    @isTest
    private static void testWrongPropertyId() {
        RestTeamProQOpportunity.RestTeamProQOpportunityRequest data = new RestTeamProQOpportunity.RestTeamProQOpportunityRequest();
        data = getFullTestData();
        data.propertyExternalId = '1111';
        Test.startTest();
        RestTeamProQOpportunity.RestTeamProQOpportunityResponse res = RestTeamProQOpportunity.createOpportunity(data);
        Test.stopTest();

        // Verify Data
        System.assertEquals(false, res.success, 'The returned status code is true, should be false.');
        System.assertEquals(1, res.errors.size(), 'There should be 1 error returned.');
        System.assertEquals('PropertyNotFound', res.errors[0].code, 'The error code is other than expected.');
    }

    @isTest
    private static void testWrongApartmentId() {
        RestTeamProQOpportunity.RestTeamProQOpportunityRequest data = new RestTeamProQOpportunity.RestTeamProQOpportunityRequest();
        data = getFullTestData();
        data.apartmentExternalId = '2222';
        Test.startTest();
        RestTeamProQOpportunity.RestTeamProQOpportunityResponse res = RestTeamProQOpportunity.createOpportunity(data);
        Test.stopTest();

        // Verify Data
        System.assertEquals(false, res.success, 'The returned status code is true, should be false.');
        System.assertEquals(1, res.errors.size(), 'There should be 1 error returned.');
        System.assertEquals('ApartmentNotFound', res.errors[0].code, 'The error code is other than expected.');
    }

    @isTest
    private static void testMissingFirstBuyer() {
        Account acc = [SELECT Id FROM Account WHERE Gesch_ftsbeziehung__c != 'Bauträger' LIMIT 1];
        RestTeamProQOpportunity.RestTeamProQOpportunityRequest data = new RestTeamProQOpportunity.RestTeamProQOpportunityRequest();
        data.accountId = acc.Id;
        Test.startTest();
        RestTeamProQOpportunity.RestTeamProQOpportunityResponse res = RestTeamProQOpportunity.createOpportunity(data);
        Test.stopTest();

        // Verify Data
        System.assertEquals(false, res.success, 'The returned status code is true, should be false.');
        System.assertEquals(1, res.errors.size(), 'There should be 1 error returned.');
        System.assertEquals('FirstBuyerEmpty', res.errors[0].code, 'The error code is other than expected.');
    }

    @isTest
    private static void testApartmentAlreadyReserved() {
        Account acc = [SELECT Id FROM Account WHERE Gesch_ftsbeziehung__c != 'Bauträger' LIMIT 1];
        Contact broker = [SELECT FirstName, LastName FROM Contact LIMIT 1];
        Property__c property = [SELECT Id FROM Property__c LIMIT 1];
        Appartment__c app = [SELECT Id FROM Appartment__c LIMIT 1];
        app.Status__c = 'Reservierungsvorbereitung';
        update app;
        RestTeamProQOpportunity.RestTeamProQOpportunityRequest data = getFullTestData();
        Test.startTest();
        RestTeamProQOpportunity.RestTeamProQOpportunityResponse res = RestTeamProQOpportunity.createOpportunity(data);
        Test.stopTest();

        // Verify Data
        System.assertEquals(false, res.success, 'The returned status code is true, should be false.');
        System.assertEquals(1, res.errors.size(), 'There should be 1 error returned.');
        System.assertEquals('OpportunityNotCreated', res.errors[0].code, 'The error code is other than expected.');
    }

    public static RestTeamProQOpportunity.RestTeamProQOpportunityRequest getFullTestData() {
        Account acc = [SELECT Id FROM Account WHERE Gesch_ftsbeziehung__c != 'Bauträger' LIMIT 1];
        Contact broker = [SELECT FirstName, LastName FROM Contact LIMIT 1];
        Property__c property = [SELECT Id, TeamProQId__c FROM Property__c LIMIT 1];
        Appartment__c app = [SELECT Id, TeamProQId__c FROM Appartment__c LIMIT 1];
        RestTeamProQOpportunity.RestTeamProQOpportunityRequest data = new RestTeamProQOpportunity.RestTeamProQOpportunityRequest();
        data.propertyExternalId = property.TeamProQId__c;
        data.apartmentExternalId = app.TeamProQId__c;
        data.accountId = acc.Id;
        data.firstBuyer = new Contact();
        data.firstBuyer.FirstName = 'Frederik';
        data.firstBuyer.LastName = 'Witte';
        data.firstBuyer.MailingStreet = 'Lister Meile 45';
        data.firstBuyer.MailingCity = 'Hannover';
        data.firstBuyer.MailingPostalCode = '30161';
        data.firstBuyer.Phone = '0511123123';
        data.firstBuyer.Email = 'frederik.witte93@gmail.com';
        data.firstBuyer.BirthDate = Date.today() - 12000;
        data.secondBuyer = new Contact();
        data.secondBuyer.FirstName = 'Elise';
        data.secondBuyer.LastName = 'Witte';
        data.secondBuyer.MailingStreet = 'Lister Meile 45';
        data.secondBuyer.MailingCity = 'Hannover';
        data.secondBuyer.MailingPostalCode = '30161';
        data.secondBuyer.Phone = '0511123113';
        data.secondBuyer.Email = 'elise.witte@gmail.com';
        data.secondBuyer.BirthDate = Date.today() - 11000;
        data.broker = new Contact();
        data.broker.FirstName = broker.FirstName;
        data.broker.LastName = broker.LastName;
        return data;
    }
}