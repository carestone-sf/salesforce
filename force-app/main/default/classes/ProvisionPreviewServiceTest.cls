@IsTest
private class ProvisionPreviewServiceTest {

    /* ============================================================
       Test setup
       ============================================================ */
    @testSetup
    static void setupData() {
        TestDataFactory.createNecessaryCustomSettings();
        TestDataFactory.createDatevSettings();
    }

    /* ============================================================
       Helper: minimal valid external broker scenario
       ============================================================ */
    private static Opportunity createBaseOpportunity(
        Date notartermin,
        Decimal probability,
        Boolean externeProvisionenGeneriert
    ) {
        // --- Account + Broker
        Account acc = TestDataFactory.createAccount(true);

        Contact broker = TestDataFactory.createMakler(false, acc.Id);
        broker.Ist_Maklerbetreuer_WH__c = false;
        broker.ErhaeltErfolgsabhaengigeProvision__c = false;
        insert broker;

        // --- Kunde
        Contact kunde = TestDataFactory.createInteressent(true, acc.Id);

        // --- Objekt
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c imm    = TestDataFactory.createProperty(true, bautraeger.Id);
        Appartment__c app  = TestDataFactory.createAppartment(true, imm.Id);

        // --- Opportunity
        Opportunity opp = TestDataFactory.createOpportunity(
            true,
            kunde.Id,
            broker.Id,
            imm.Id,
            app.Id
        );

        opp.StageName = 'Notartermin hat stattgefunden';
        opp.Notartermin__c = notartermin;
        opp.Probability = probability;
        opp.Provisionsbasis__c = 100000;
        opp.ExterneProvisionenGeneriert__c = externeProvisionenGeneriert;

        // required for getProvisionExtern
        opp.Makler__c = broker.Id;
        opp.Immobilienberater__c = broker.Id;

        update opp;
        return opp;
    }

    private static Opportunity createBaseOpportunity(
        Account acc,
        Contact broker,
        Date notartermin,
        Decimal probability,
        Boolean externeProvisionenGeneriert
    ) {
        // --- Kunde
        Contact kunde = TestDataFactory.createInteressent(true, acc.Id);

        // --- Objekt
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c imm    = TestDataFactory.createProperty(true, bautraeger.Id);
        Appartment__c app  = TestDataFactory.createAppartment(true, imm.Id);

        Opportunity opp = TestDataFactory.createOpportunity(
            true, kunde.Id, broker.Id, imm.Id, app.Id
        );

        opp.StageName = 'Notartermin hat stattgefunden';
        opp.Notartermin__c = notartermin;
        opp.Probability = probability;
        opp.Provisionsbasis__c = 100000;
        opp.ExterneProvisionenGeneriert__c = externeProvisionenGeneriert;

        // important: these must be set to hit the new query filter
        opp.Makler__c = broker.Id;
        opp.Immobilienberater__c = broker.Id;

        update opp;
        return opp;
    }

    /* ============================================================
       1) Test: eligible opportunity is returned
       ============================================================ */
    @IsTest
static void testEligibleOpportunityReturned() {

    // --- Account drives Maklerauftrag__c
    Account acc = TestDataFactory.createAccount(true);
    acc.Carestone_Vertriebsvereinbarung__c = true;
    update acc;

    // --- Broker
    Contact broker = TestDataFactory.createMakler(true, acc.Id);

    // --- Customer
    Contact kunde = TestDataFactory.createInteressent(true, acc.Id);

    // --- Property / Appartement
    Account bautraeger = TestDataFactory.createBautraeger(true);
    Property__c imm = TestDataFactory.createProperty(true, bautraeger.Id);
    Appartment__c app = TestDataFactory.createAppartment(true, imm.Id);
    app.AdditionalBrokerCommission__c = 0;
    update app;

    // --- Opportunity
    Opportunity opp = TestDataFactory.createOpportunity(
        true,
        kunde.Id,
        broker.Id,
        imm.Id,
        app.Id
    );

    opp.StageName = 'Notartermin hat stattgefunden';
    opp.ExterneProvisionenGeneriert__c = false;
    opp.Provisionsbasis__c = 200000;

    opp.Makler__c = broker.Id;
    opp.Immobilienberater__c = null;
    opp.Abrechnung_ber__c = null;

    // Formula drivers
    opp.Maklerprovision__c = '10';
    opp.Marketingzuschuss__c = 0;

    update opp;

    Test.startTest();
        List<ProvisionPreviewDTO> res =
            ProvisionPreviewService.getOpenBrokerProvisions(broker.Id);
    Test.stopTest();

    System.assertEquals(
        1,
        res.size(),
        'Exactly one offene Provision should be returned'
    );
}


    /* ============================================================
       2) Test: excluded if ExterneProvisionenGeneriert__c = true
       ============================================================ */
    @IsTest
    static void testExcludedIfExternAlreadyGenerated() {
        Opportunity opp = createBaseOpportunity(
            Date.today().addDays(-5),
            50,
            true
        );

        Contact broker = [
            SELECT Id
            FROM Contact
            WHERE Id = :opp.Makler__c
        ];

        Test.startTest();
            List<ProvisionPreviewDTO> previews =
                ProvisionPreviewService.getOpenBrokerProvisions(broker.Id);
        Test.stopTest();

        System.assertEquals(
            0,
            previews.size(),
            'Opportunity must be excluded if ExterneProvisionenGeneriert__c = true'
        );
    }

    /* ============================================================
       3) Test: probability + weighted provision calculation
       ============================================================ */
    @IsTest
static void testProbabilityAndWeightedProvision() {

    Account acc = TestDataFactory.createAccount(true);
    acc.Carestone_Vertriebsvereinbarung__c = true;
    update acc;

    Contact broker = TestDataFactory.createMakler(true, acc.Id);

    Contact kunde = TestDataFactory.createInteressent(true, acc.Id);

    Account bautraeger = TestDataFactory.createBautraeger(true);
    Property__c imm = TestDataFactory.createProperty(true, bautraeger.Id);
    Appartment__c app = TestDataFactory.createAppartment(true, imm.Id);
    app.AdditionalBrokerCommission__c = 0;
    update app;

    Opportunity opp = TestDataFactory.createOpportunity(
        true,
        kunde.Id,
        broker.Id,
        imm.Id,
        app.Id
    );

    opp.StageName = 'Notartermin hat stattgefunden';
    opp.ExterneProvisionenGeneriert__c = false;
    opp.Probability = 50;
    opp.Provisionsbasis__c = 100000;

    opp.Makler__c = broker.Id;
    opp.Maklerprovision__c = '10';
    opp.Marketingzuschuss__c = 0;

    update opp;

    Test.startTest();
        List<ProvisionPreviewDTO> res =
            ProvisionPreviewService.getOpenBrokerProvisions(broker.Id);
    Test.stopTest();

    System.assertEquals(1, res.size());

    ProvisionPreviewDTO dto = res[0];

    System.assertEquals(50, dto.Probability);
    System.assertEquals(
        5000,
        dto.WeightedProvision,
        'WeightedProvision must equal provision * probability'
    );
}


    /* ============================================================
       4) Test: preview must NOT create Provision__c records
       ============================================================ */
    @IsTest
    static void testNoProvisionRecordsCreated() {
        Opportunity opp = createBaseOpportunity(
            Date.today().addDays(-15),
            70,
            false
        );

        Contact broker = [
            SELECT Id
            FROM Contact
            WHERE Id = :opp.Makler__c
        ];

        Test.startTest();
            ProvisionPreviewService.getOpenBrokerProvisions(broker.Id);
        Test.stopTest();

        Integer cnt = [
            SELECT COUNT()
            FROM Provision__c
            WHERE Verkaufschance__c = :opp.Id
        ];

        System.assertEquals(
            0,
            cnt,
            'Preview service must not create Provision__c records'
        );
    }

    @IsTest
static void testExistingProvisionWithUnpaidCredits() {

    Opportunity opp = createBaseOpportunity(
        Date.today().addDays(-10),
        80,
        false
    );

    Contact broker = [
        SELECT Id
        FROM Contact
        WHERE Id = :opp.Makler__c
    ];

    // Create real provision
    Provision__c prov = TestDataFactory.createProvision(false, opp.Id, UserInfo.getUserId(), broker.Id);
    prov.Wert_Maklerprovision__c = 10000;
    insert prov;

    // Unpaid credit
    Gutschrift__c g = new Gutschrift__c(
        Provision__c = prov.Id,
        Wert_Maklerprovision__c = 4000,
        Bezahlt__c = false
    );
    insert g;

    Test.startTest();
        List<ProvisionPreviewDTO> res =
            ProvisionPreviewService.getOpenBrokerProvisions(broker.Id);
    Test.stopTest();

    System.assertEquals(1, res.size());
    System.assertEquals(4000, res[0].Provisionssumme);
}

@IsTest
static void testExistingProvisionAllCreditsPaidExcluded() {

    Opportunity opp = createBaseOpportunity(
        Date.today().addDays(-10),
        80,
        false
    );

    Contact broker = [
        SELECT Id
        FROM Contact
        WHERE Id = :opp.Makler__c
    ];

    Provision__c prov = TestDataFactory.createProvision(false, opp.Id, UserInfo.getUserId(), broker.Id);
    prov.Wert_Maklerprovision__c = 6000;
    insert prov;

    // Paid credit
    insert new Gutschrift__c(
        Provision__c = prov.Id,
        Wert_Maklerprovision__c = 6000,
        Bezahlt__c = true
    );

    Test.startTest();
        List<ProvisionPreviewDTO> res =
            ProvisionPreviewService.getOpenBrokerProvisions(broker.Id);
    Test.stopTest();

    System.assertEquals(
        0,
        res.size(),
        'Provision with fully paid credits must not appear'
    );
}
@IsTest
static void testProvisionOfOtherBrokerIsExcluded() {

    Opportunity opp = createBaseOpportunity(
        Date.today().addDays(-5),
        60,
        false
    );

    Id accId = [SELECT AccountId FROM Contact WHERE Id = :opp.Makler__c].AccountId;

    Contact otherBroker = TestDataFactory.createMakler(true, accId);

    Provision__c prov = TestDataFactory.createProvision(false, opp.Id, UserInfo.getUserId(), otherBroker.Id);
    prov.Wert_Maklerprovision__c = 8000;
    insert prov;

    Test.startTest();
        List<ProvisionPreviewDTO> res =
            ProvisionPreviewService.getOpenBrokerProvisions(opp.Makler__c);
    Test.stopTest();

    System.assertEquals(
        0,
        res.size(),
        'Provisions of other brokers must not be visible'
    );
}

@IsTest
static void testAlleProvisionenRoleSeesMultipleBrokers() {

    Account acc = TestDataFactory.createAccount(true);

    Contact broker1 = TestDataFactory.createMakler(true, acc.Id);
    Contact broker2 = TestDataFactory.createMakler(true, acc.Id);

    broker1.VPRollen__c = 'Alle Provisionen';
    update broker1;

    // IMPORTANT: create opp on same account; choose one broker for opp fields
    Opportunity opp = createBaseOpportunity(
        acc, broker1, Date.today().addDays(-3), 70, false
    );

    Provision__c p1 = TestDataFactory.createProvision(false, opp.Id, UserInfo.getUserId(), broker1.Id);
    p1.Wert_Maklerprovision__c = 3000;

    Provision__c p2 = TestDataFactory.createProvision(false, opp.Id, UserInfo.getUserId(), broker2.Id);
    p2.Wert_Maklerprovision__c = 5000;

    insert new List<Provision__c>{ p1, p2 };

    Test.startTest();
        List<ProvisionPreviewDTO> res =
            ProvisionPreviewService.getOpenBrokerProvisions(broker1.Id);
    Test.stopTest();

    System.assertEquals(2, res.size());
}


@IsTest
static void testExistingProvisionSuppressesForecast() {

    Opportunity opp = createBaseOpportunity(
        Date.today().addDays(-7),
        50,
        false
    );

    Contact broker = [
        SELECT Id
        FROM Contact
        WHERE Id = :opp.Makler__c
    ];

    Provision__c prov = TestDataFactory.createProvision(false, opp.Id, UserInfo.getUserId(), broker.Id);
    prov.Wert_Maklerprovision__c = 7000;
    insert prov;

    Test.startTest();
        List<ProvisionPreviewDTO> res =
            ProvisionPreviewService.getOpenBrokerProvisions(broker.Id);
    Test.stopTest();

    System.assertEquals(
        1,
        res.size(),
        'Forecast must not be shown when real provision exists'
    );
}

@IsTest
static void testBrokerNameFromProvisionMakler() {

    Account acc = TestDataFactory.createAccount(true);

    Contact otherBroker = TestDataFactory.createMakler(false, acc.Id);
    otherBroker.FirstName = 'Max';
    otherBroker.LastName  = 'Mustermann';
    insert otherBroker;

    // IMPORTANT: opp must match query filter by having Makler__c etc. = otherBroker
    Opportunity opp = createBaseOpportunity(
        acc, otherBroker, Date.today().addDays(-5), 90, false
    );

    Provision__c prov = TestDataFactory.createProvision(false, opp.Id, UserInfo.getUserId(), otherBroker.Id);
    prov.Wert_Maklerprovision__c = 9000;
    insert prov;

    Test.startTest();
        List<ProvisionPreviewDTO> res =
            ProvisionPreviewService.getOpenBrokerProvisions(otherBroker.Id);
    Test.stopTest();

    System.assert(!res.isEmpty(), 'Expected at least one DTO');
    System.assertEquals('Max Mustermann', res[0].BrokerName);
}


}