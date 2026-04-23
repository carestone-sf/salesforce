@isTest
private class NebenkostenzuschussServiceTest {

    @TestSetup
    static void setup() {
        TestDataFactory.createNecessaryCustomSettings();
    }

    @isTest
    static void createFromOpportunity_happyPath() {
        Opportunity opp = TestDataFactory.createOpportunity(true);
        opp = [
            SELECT Id, Immobilie__c, Appartement__c, Potenzieller_Kunde__c, Makler__c
            FROM Opportunity WHERE Id = :opp.Id
        ];

        Test.startTest();
        Nebenkostenzuschuss__c nkz = NebenkostenzuschussService.createFromOpportunity(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, nkz.Id, 'NKZ should have been inserted');
        System.assertEquals(opp.Id, nkz.Opportunity__c, 'Opportunity lookup');
        System.assertEquals(opp.Immobilie__c, nkz.Objekt__c, 'Objekt lookup');
        System.assertEquals(opp.Appartement__c, nkz.Teilobjekt__c, 'Teilobjekt lookup');
        System.assertEquals(opp.Potenzieller_Kunde__c, nkz.Kunde__c, 'Kunde lookup');
        System.assertEquals(opp.Makler__c, nkz.Empfaenger__c, 'Empfaenger lookup');
    }

    @isTest
    static void createFromOpportunities_bulk() {
        Account acc = TestDataFactory.createAccount(true, 'BulkAcc');
        Contact interessent = TestDataFactory.createInteressent(true, acc.Id);
        Contact makler = TestDataFactory.createMakler(true, acc.Id);
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c prop = TestDataFactory.createProperty(true, bautraeger.Id);

        List<Id> oppIds = new List<Id>();
        List<Appartment__c> apps = new List<Appartment__c>();
        for (Integer i = 0; i < 5; i++) {
            apps.add(TestDataFactory.createAppartment(false, prop.Id, 'App' + i));
        }
        insert apps;

        List<Opportunity> opps = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            opps.add(TestDataFactory.createOpportunity(false, interessent.Id, makler.Id, prop.Id, apps[i].Id));
        }
        insert opps;
        for (Opportunity o : opps) {
            oppIds.add(o.Id);
        }

        Test.startTest();
        List<Nebenkostenzuschuss__c> results = NebenkostenzuschussService.createFromOpportunities(oppIds);
        Test.stopTest();

        System.assertEquals(5, results.size(), 'Should create 5 NKZ records');
        List<Nebenkostenzuschuss__c> stored = [
            SELECT Id FROM Nebenkostenzuschuss__c WHERE Opportunity__c IN :oppIds
        ];
        System.assertEquals(5, stored.size(), 'All 5 should be persisted');
    }

    @isTest
    static void createFromOpportunity_duplicatePrevention() {
        Opportunity opp = TestDataFactory.createOpportunity(true);

        NebenkostenzuschussService.createFromOpportunity(opp.Id);

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            NebenkostenzuschussService.createFromOpportunity(opp.Id);
        } catch (NebenkostenzuschussService.NebenkostenzuschussException e) {
            exceptionThrown = true;
            System.assert(
                e.getMessage().contains('bereits ein aktiver Nebenkostenzuschuss'),
                'Expected duplicate message, got: ' + e.getMessage()
            );
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Should throw on duplicate');
    }

    @isTest
    static void createFromOpportunity_cancelledNkzAllowsNew() {
        Opportunity opp = TestDataFactory.createOpportunity(true);

        Nebenkostenzuschuss__c existing = NebenkostenzuschussService.createFromOpportunity(opp.Id);
        existing.Storniert__c = true;
        update existing;

        Test.startTest();
        Nebenkostenzuschuss__c nkz = NebenkostenzuschussService.createFromOpportunity(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, nkz.Id, 'Should allow new NKZ when previous was cancelled');
    }

    @isTest
    static void createFromOpportunity_missingAppartement() {
        Account acc = TestDataFactory.createAccount(true, 'NoAppAcc');
        Contact interessent = TestDataFactory.createInteressent(true, acc.Id);
        Contact makler = TestDataFactory.createMakler(true, acc.Id);
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c prop = TestDataFactory.createProperty(true, bautraeger.Id);
        Appartment__c app = TestDataFactory.createAppartment(true, prop.Id);

        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, prop.Id, app.Id);
        opp.Appartement__c = null;
        update opp;

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            NebenkostenzuschussService.createFromOpportunity(opp.Id);
        } catch (NebenkostenzuschussService.NebenkostenzuschussException e) {
            exceptionThrown = true;
            System.assert(
                e.getMessage().contains('kein Teilobjekt'),
                'Expected missing Teilobjekt message, got: ' + e.getMessage()
            );
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Should throw when Appartement is missing');
    }

    @isTest
    static void createFromOpportunity_nullInput() {
        Test.startTest();
        Nebenkostenzuschuss__c result = NebenkostenzuschussService.createFromOpportunity(null);
        Test.stopTest();

        System.assertEquals(null, result, 'Null input should return null');
    }

    @isTest
    static void createFromOpportunities_emptyList() {
        Test.startTest();
        List<Nebenkostenzuschuss__c> results = NebenkostenzuschussService.createFromOpportunities(new List<Id>());
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Empty input should return empty list');
    }

    @isTest
    static void createFromOpportunity_invalidId() {
        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            NebenkostenzuschussService.createFromOpportunity(UserInfo.getUserId());
        } catch (NebenkostenzuschussService.NebenkostenzuschussException e) {
            exceptionThrown = true;
            System.assert(
                e.getMessage().contains('nicht gefunden'),
                'Expected not-found message, got: ' + e.getMessage()
            );
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Should throw for non-Opportunity Id');
    }
}
