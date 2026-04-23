@IsTest
private class AufschiebendeBedingungTest {

    @TestSetup
    static void makeData() {
        TestDataFactory.createNecessaryCustomSettings();
        TestDataFactory.createDatevSettings();

        Account acc = TestDataFactory.createAccount(true);
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Contact makler = TestDataFactory.createMakler(true, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(true, acc.Id);
        Property__c immobilie = TestDataFactory.createProperty(true, bautraeger.Id);
        Appartment__c app = TestDataFactory.createAppartment(true, immobilie.Id);
        TestDataFactory.createProvisionsverhandlung(true, acc.Id, immobilie.Id);
    }

    private static Opportunity createTestOpportunity(Boolean doInsert) {
        Contact makler = [SELECT Id, AccountId FROM Contact WHERE RecordType.DeveloperName = 'Makler' LIMIT 1];
        Contact interessent = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Interessent' LIMIT 1];
        Property__c immobilie = [SELECT Id FROM Property__c LIMIT 1];
        Appartment__c app = [SELECT Id FROM Appartment__c LIMIT 1];

        return TestDataFactory.createOpportunity(
            doInsert, interessent.Id, makler.Id, immobilie.Id, app.Id, 'Reserviert', 100000
        );
    }

    @IsTest
    static void testKaufdatumCannotBeInFuture() {
        Opportunity opp = createTestOpportunity(true);
        opp.Kaufdatum__c = Date.today().addDays(1);

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            update opp;
        } catch (DmlException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Validation rule should block future Kaufdatum');
    }

    @IsTest
    static void testKaufdatumCannotBeBeforeNotartermin() {
        Opportunity opp = createTestOpportunity(true);
        opp.Notartermin__c = Date.today().addDays(-5);
        opp.Kaufdatum__c = Date.today().addDays(-10);

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            update opp;
        } catch (DmlException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Validation rule should block Kaufdatum before Notartermin');
    }

    @IsTest
    static void testKaufdatumBlockedWhenConditionPending() {
        Opportunity opp = createTestOpportunity(true);
        opp.HatAufschiebendeBedingung__c = true;
        opp.Kaufdatum__c = Date.today();

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            update opp;
        } catch (DmlException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Validation rule should block Kaufdatum when condition is pending');
    }

    @IsTest
    static void testKaufdatumAllowedWhenConditionFulfilled() {
        Opportunity opp = createTestOpportunity(true);
        opp.HatAufschiebendeBedingung__c = true;
        opp.AufschiebendeBedingungErfuellt__c = true;
        opp.DatumBedingungErfuellt__c = Date.today();
        opp.Notartermin__c = Date.today().addDays(-5);
        opp.Kaufdatum__c = Date.today();

        Test.startTest();
        update opp;
        Test.stopTest();

        Opportunity result = [SELECT Kaufdatum__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(Date.today(), result.Kaufdatum__c, 'Kaufdatum should be set when condition is fulfilled');
    }

    @IsTest
    static void testKaufdatumValidOnBoundary() {
        Opportunity opp = createTestOpportunity(true);
        opp.Notartermin__c = Date.today();
        opp.Kaufdatum__c = Date.today();

        Test.startTest();
        update opp;
        Test.stopTest();

        Opportunity result = [SELECT Kaufdatum__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(Date.today(), result.Kaufdatum__c,
            'Kaufdatum equal to today and Notartermin should be valid');
    }

    @IsTest
    static void testProvisionPrerequisitesWithFulfilledCondition() {
        Opportunity opp = createTestOpportunity(true);
        opp.StageName = 'Notartermin hat stattgefunden';
        opp.Notartermin__c = Date.today().addDays(-5);
        opp.Kaufdatum__c = Date.today();
        opp.HatAufschiebendeBedingung__c = true;
        opp.AufschiebendeBedingungErfuellt__c = true;
        opp.DatumBedingungErfuellt__c = Date.today();

        Test.startTest();
        update opp;
        Test.stopTest();

        Opportunity result = [SELECT ProvisionsvoraussetzungenErfuellt__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(true, result.ProvisionsvoraussetzungenErfuellt__c,
            'Provision prerequisites should be met when condition is fulfilled');
    }

    @IsTest
    static void testProvisionPrerequisitesWithoutCondition() {
        Opportunity opp = createTestOpportunity(true);
        opp.StageName = 'Notartermin hat stattgefunden';
        opp.Notartermin__c = Date.today().addDays(-5);
        opp.Kaufdatum__c = Date.today();

        Test.startTest();
        update opp;
        Test.stopTest();

        Opportunity result = [SELECT ProvisionsvoraussetzungenErfuellt__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(true, result.ProvisionsvoraussetzungenErfuellt__c,
            'Provision prerequisites should be met without aufschiebende Bedingung');
    }

    @IsTest
    static void testProvisionServiceFiltersBlockedOpportunities() {
        Opportunity opp = createTestOpportunity(true);
        opp.HatAufschiebendeBedingung__c = true;
        update opp;

        opp = [
            SELECT Id, HatAufschiebendeBedingung__c, AufschiebendeBedingungErfuellt__c,
                   Notartermin__c, Makler__c, Maklerbetreuer_WirtschaftsHaus__c, Immobilie__c,
                   Appartement__c, Potenzieller_Kunde__c, Provisionsbasis__c, OwnerId,
                   MarketingzuschussNichtAusweisen__c, Immobilienberater__c, Abrechnung_ber__c,
                   Overhead_Empf_nger__c, TippgeberProvisionEmpfaenger__c, Vertriebskoordinator__c,
                   Provision_Thoben__c
            FROM Opportunity WHERE Id = :opp.Id
        ];

        Map<Id, Opportunity> opps = new Map<Id, Opportunity>{ opp.Id => opp };
        Map<Id, Opportunity> oldOpps = new Map<Id, Opportunity>{ opp.Id => opp };
        ProvisionService ps = new ProvisionService(opps, oldOpps, 'extern', null);

        Test.startTest();
        ps.upsertProvisionen();
        Test.stopTest();

        List<Provision__c> provisions = [SELECT Id FROM Provision__c WHERE Verkaufschance__c = :opp.Id];
        System.assertEquals(0, provisions.size(), 'No provisions should be created for blocked opportunity');
    }
}
