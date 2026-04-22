@IsTest
private class ProvisionServiceTest {

    private class InternalContext {
        Contact mb;
        Opportunity opp;
    }

    private static InternalContext createInternalContext(Date notartermin) {
        Contact mb = new Contact(
            Id = Id.valueOf('003000000000001AAA'),
            Ist_Maklerbetreuer_WH__c = true,
            ErhaeltErfolgsabhaengigeProvision__c = true
        );

        Opportunity opp = new Opportunity(
            Id = Id.valueOf('006000000000001AAA'),
            Notartermin__c = notartermin,
            StageName = 'Notartermin hat stattgefunden',
            Provisionsbasis__c = 100000,
            Maklerbetreuer_WirtschaftsHaus__c = mb.Id
        );

        InternalContext ctx = new InternalContext();
        ctx.mb = mb;
        ctx.opp = opp;
        return ctx;
    }

    private static Provisionsmodell__c createProvisionModel(String name, Date gueltigVon, Date gueltigBis, Id partnermanagerId) {
        Provisionsmodell__c model = new Provisionsmodell__c(
            Name = name,
            GueltigVon__c = gueltigVon,
            GueltigBis__c = gueltigBis,
            Partnermanager__c = partnermanagerId
        );
        insert model;
        return model;
    }

    private static void addStaffel(Id modelId, String periode, Integer von, Integer bis, Decimal prozent) {
        insert new Provisionsstaffel__c(
            Provisionsmodell__c = modelId,
            Abrechnungsperiode__c = periode,
            StaffelVon__c = von,
            StaffelBis__c = bis,
            ProvisionInProzent__c = prozent
        );
    }

    private static void insertStandardStaffeln(Id modelId) {
        addStaffel(modelId, 'Monat', 0, 3, 0.25);
        addStaffel(modelId, 'Monat', 4, 6, 0.35);
        addStaffel(modelId, 'Monat', 7, 8, 0.45);
        addStaffel(modelId, 'Monat', 9, 999999, 0.50);

        addStaffel(modelId, 'Quartal', 0, 11, 0.25);
        addStaffel(modelId, 'Quartal', 12, 20, 0.35);
        addStaffel(modelId, 'Quartal', 21, 26, 0.45);
        addStaffel(modelId, 'Quartal', 27, 999999, 0.50);

        addStaffel(modelId, 'Jahr', 0, 47, 0.25);
        addStaffel(modelId, 'Jahr', 48, 83, 0.35);
        addStaffel(modelId, 'Jahr', 84, 107, 0.45);
        addStaffel(modelId, 'Jahr', 108, 999999, 0.50);
    }

    private static void insertSpecialStaffeln(Id modelId) {
        addStaffel(modelId, 'Monat', 0, 3, 0.25);
        addStaffel(modelId, 'Monat', 4, 6, 0.35);
        addStaffel(modelId, 'Monat', 7, 8, 0.45);
        addStaffel(modelId, 'Monat', 9, 10, 0.50);
        addStaffel(modelId, 'Monat', 11, 999999, 0.55);

        addStaffel(modelId, 'Quartal', 0, 11, 0.25);
        addStaffel(modelId, 'Quartal', 12, 20, 0.35);
        addStaffel(modelId, 'Quartal', 21, 26, 0.45);
        addStaffel(modelId, 'Quartal', 27, 30, 0.50);
        addStaffel(modelId, 'Quartal', 31, 999999, 0.55);

        addStaffel(modelId, 'Jahr', 0, 47, 0.25);
        addStaffel(modelId, 'Jahr', 48, 83, 0.35);
        addStaffel(modelId, 'Jahr', 84, 107, 0.45);
        addStaffel(modelId, 'Jahr', 108, 120, 0.50);
        addStaffel(modelId, 'Jahr', 121, 999999, 0.55);
    }

    private static Provision__c createProvisionStub(Decimal kaufpreis, Decimal monat, Decimal quartal, Decimal jahr) {
        return new Provision__c(
            Kaufpreis__c = kaufpreis,
            AnzahlEinheitenMonat__c = monat,
            AnzahlEinheitenQuartal__c = quartal,
            AnzahlEinheitenJahr__c = jahr
        );
    }

    private static Contact createPersistedPartnermanager() {
        return TestDataFactory.createMakler(true, 'PM-' + String.valueOf(System.now().getTime()));
    }

    @IsTest
    static void getErfolgsabhaengigeProvision_month_usesDefaultModel() {
        InternalContext ctx = createInternalContext(Date.today().addDays(-3));
        Provisionsmodell__c defaultModel = createProvisionModel('Default Month', Date.today().addYears(-1), null, null);
        insertStandardStaffeln(defaultModel.Id);

        ProvisionService ps = new ProvisionService(
            new Map<Id, Opportunity>{ ctx.opp.Id => ctx.opp },
            new Map<Id, Opportunity>(),
            'intern',
            'month'
        );
        ps.initializeProvisionModelConfigs(new List<Opportunity>{ ctx.opp }, new List<Contact>{ ctx.mb });

        Decimal value = ps.getErfolgsabhaengigeProvision(
            createProvisionStub(100000, 5, 0, 0),
            ctx.mb,
            ctx.opp.Notartermin__c
        );

        System.assertEquals(0.0035, value, 'Month scale 4-6 must produce 0.35%.');
    }

    @IsTest
    static void getErfolgsabhaengigeProvision_prefersSpecificPartnermanagerModel() {
        InternalContext ctx = createInternalContext(Date.today().addDays(-3));
        Contact specificPm = createPersistedPartnermanager();

        Provisionsmodell__c defaultModel = createProvisionModel('Default Model', Date.today().addYears(-1), null, null);
        insertStandardStaffeln(defaultModel.Id);

        Provisionsmodell__c specialModel = createProvisionModel('Special Model', Date.today().addYears(-1), null, specificPm.Id);
        insertSpecialStaffeln(specialModel.Id);

        ProvisionService ps = new ProvisionService(
            new Map<Id, Opportunity>{ ctx.opp.Id => ctx.opp },
            new Map<Id, Opportunity>(),
            'intern',
            'month'
        );
        ps.initializeProvisionModelConfigs(new List<Opportunity>{ ctx.opp }, new List<Contact>{ specificPm });

        Decimal value = ps.getErfolgsabhaengigeProvision(
            createProvisionStub(100000, 12, 0, 0),
            specificPm,
            ctx.opp.Notartermin__c
        );

        System.assertEquals(0.0055, value, 'Specific model must override default model.');
    }

    @IsTest
    static void getErfolgsabhaengigeProvision_fallsBackToDefaultIfSpecificNotValidForDate() {
        InternalContext ctx = createInternalContext(Date.today().addDays(-3));
        Contact specificPm = createPersistedPartnermanager();

        Provisionsmodell__c defaultModel = createProvisionModel('Default Fallback', Date.today().addYears(-1), null, null);
        insertStandardStaffeln(defaultModel.Id);

        Provisionsmodell__c specificOld = createProvisionModel(
            'Specific Expired',
            Date.today().addYears(-5),
            Date.today().addYears(-2),
            specificPm.Id
        );
        insertSpecialStaffeln(specificOld.Id);

        ProvisionService ps = new ProvisionService(
            new Map<Id, Opportunity>{ ctx.opp.Id => ctx.opp },
            new Map<Id, Opportunity>(),
            'intern',
            'month'
        );
        ps.initializeProvisionModelConfigs(new List<Opportunity>{ ctx.opp }, new List<Contact>{ specificPm });

        Decimal value = ps.getErfolgsabhaengigeProvision(
            createProvisionStub(100000, 11, 0, 0),
            specificPm,
            ctx.opp.Notartermin__c
        );

        System.assertEquals(0.005, value, 'Expired specific model must not be used.');
    }

    @IsTest
    static void getErfolgsabhaengigeProvision_returnsNullWhenNoMatchingModelExists() {
        InternalContext ctx = createInternalContext(Date.today().addDays(-3));
        Provisionsmodell__c futureModel = createProvisionModel(
            'Future Only',
            Date.today().addDays(30),
            null,
            null
        );
        insertStandardStaffeln(futureModel.Id);

        ProvisionService ps = new ProvisionService(
            new Map<Id, Opportunity>{ ctx.opp.Id => ctx.opp },
            new Map<Id, Opportunity>(),
            'intern',
            'month'
        );
        ps.initializeProvisionModelConfigs(new List<Opportunity>{ ctx.opp }, new List<Contact>{ ctx.mb });

        Decimal value = ps.getErfolgsabhaengigeProvision(
            createProvisionStub(100000, 5, 0, 0),
            ctx.mb,
            ctx.opp.Notartermin__c
        );

        System.assertEquals(null, value, 'Without valid model for Notartermin no provision should be returned.');
    }

    @IsTest
    static void getErfolgsabhaengigeProvision_quarterAndYearUseDifferentials() {
        InternalContext ctx = createInternalContext(Date.today().addDays(-2));
        Provisionsmodell__c defaultModel = createProvisionModel('Default Differential', Date.today().addYears(-1), null, null);
        insertStandardStaffeln(defaultModel.Id);

        Provision__c input = createProvisionStub(100000, 3, 12, 84);

        ProvisionService quarterPs = new ProvisionService(
            new Map<Id, Opportunity>{ ctx.opp.Id => ctx.opp },
            new Map<Id, Opportunity>(),
            'intern',
            'quarter'
        );
        quarterPs.initializeProvisionModelConfigs(new List<Opportunity>{ ctx.opp }, new List<Contact>{ ctx.mb });

        Decimal quarterValue = quarterPs.getErfolgsabhaengigeProvision(input, ctx.mb, ctx.opp.Notartermin__c);
        System.assertEquals(0.001, quarterValue, 'Quarter value must be (0.35 - 0.25)/100.');

        ProvisionService yearPs = new ProvisionService(
            new Map<Id, Opportunity>{ ctx.opp.Id => ctx.opp },
            new Map<Id, Opportunity>(),
            'intern',
            'year'
        );
        yearPs.initializeProvisionModelConfigs(new List<Opportunity>{ ctx.opp }, new List<Contact>{ ctx.mb });

        Decimal yearValue = yearPs.getErfolgsabhaengigeProvision(input, ctx.mb, ctx.opp.Notartermin__c);
        System.assertEquals(0.001, yearValue, 'Year value must be (0.45 - 0.25 - 0.10)/100.');
    }

    @IsTest
    static void getErfolgsabhaengigeProvision_appliesMaxAndEuroOverrides() {
        InternalContext ctx = createInternalContext(Date.today().addDays(-1));
        Provisionsmodell__c defaultModel = createProvisionModel('Default Overrides', Date.today().addYears(-1), null, null);
        insertStandardStaffeln(defaultModel.Id);

        Provision__c input = createProvisionStub(100000, 5, 0, 0);

        Contact maxContact = new Contact(Id = ctx.mb.Id);
        maxContact.ErfolgsabhaengigeMaxInProzent__c = 0.3;

        ProvisionService monthPs = new ProvisionService(
            new Map<Id, Opportunity>{ ctx.opp.Id => ctx.opp },
            new Map<Id, Opportunity>(),
            'intern',
            'month'
        );
        monthPs.initializeProvisionModelConfigs(new List<Opportunity>{ ctx.opp }, new List<Contact>{ maxContact });

        Decimal maxValue = monthPs.getErfolgsabhaengigeProvision(input, maxContact, ctx.opp.Notartermin__c);
        System.assertEquals(0.003, maxValue, 'Max override 0.3% must cap month result.');

        maxContact.ErfolgsabhaengigeMaxInProzent__c = null;
        maxContact.ErfolgsabhaengigeProvisionInEuro__c = 1000;

        monthPs.initializeProvisionModelConfigs(new List<Opportunity>{ ctx.opp }, new List<Contact>{ maxContact });
        Decimal euroValue = monthPs.getErfolgsabhaengigeProvision(input, maxContact, ctx.opp.Notartermin__c);
        System.assertEquals(0.01, euroValue, 'Euro override must be converted to percent based on Kaufpreis.');
    }

    @IsTest
    static void getErfolgsabhaengigeProvision_returnsNullForQuarterWhenManualOverrideExists() {
        InternalContext ctx = createInternalContext(Date.today().addDays(-1));
        Provisionsmodell__c defaultModel = createProvisionModel('Default Quarter Override', Date.today().addYears(-1), null, null);
        insertStandardStaffeln(defaultModel.Id);

        Contact mb = new Contact(Id = ctx.mb.Id);
        mb.ErfolgsabhaengigeMaxInProzent__c = 0.2;

        ProvisionService quarterPs = new ProvisionService(
            new Map<Id, Opportunity>{ ctx.opp.Id => ctx.opp },
            new Map<Id, Opportunity>(),
            'intern',
            'quarter'
        );
        quarterPs.initializeProvisionModelConfigs(new List<Opportunity>{ ctx.opp }, new List<Contact>{ mb });

        Decimal value = quarterPs.getErfolgsabhaengigeProvision(
            createProvisionStub(100000, 3, 12, 84),
            mb,
            ctx.opp.Notartermin__c
        );

        System.assertEquals(null, value, 'Quarter schedule with manual month override must return null.');
    }

    @IsTest
    static void dateRangeHelper_blocksOutsideRange() {
        ProvisionService ps = new ProvisionService(
            new Map<Id, Opportunity>(),
            new Map<Id, Opportunity>(),
            'intern',
            'month'
        );
        Contact c = new Contact();
        c.ErhaeltErfolgsabhaengigeProvisionVon__c = Date.newInstance(2026, 2, 1);
        c.ErhaeltErfolgsabhaengigeProvisionBis__c = Date.newInstance(2026, 2, 28);

        System.assertEquals(false, ps.isErfolgsabhaengigeProvisionDateInRange(c, Date.newInstance(2026, 1, 31)));
        System.assertEquals(true, ps.isErfolgsabhaengigeProvisionDateInRange(c, Date.newInstance(2026, 2, 15)));
        System.assertEquals(false, ps.isErfolgsabhaengigeProvisionDateInRange(c, Date.newInstance(2026, 3, 1)));
    }

    @IsTest
    static void getProvisionIntern_usesConfiguredModelAndCounts() {
        InternalContext ctx = createInternalContext(Date.today().addDays(-1));
        Provisionsmodell__c defaultModel = createProvisionModel('Default Intern Path', Date.today().addYears(-1), null, null);
        insertStandardStaffeln(defaultModel.Id);

        ProvisionService ps = new ProvisionService(
            new Map<Id, Opportunity>{ ctx.opp.Id => ctx.opp },
            new Map<Id, Opportunity>(),
            'intern',
            'month'
        );
        ps.initializeProvisionModelConfigs(new List<Opportunity>{ ctx.opp }, new List<Contact>{ ctx.mb });

        Integer yearOpp = ctx.opp.Notartermin__c.year();
        Integer monthOpp = ctx.opp.Notartermin__c.month();
        Integer quarterOpp = ps.getQuarterByMonth(monthOpp);
        ps.mbToYearToMonthOpps.put(
            ctx.mb.Id,
            new Map<Integer, Map<Integer, Integer>>{
                yearOpp => new Map<Integer, Integer>{ monthOpp => 5 }
            }
        );
        ps.mbToYearToQuarterOpps.put(
            ctx.mb.Id,
            new Map<Integer, Map<Integer, Integer>>{
                yearOpp => new Map<Integer, Integer>{ quarterOpp => 12 }
            }
        );
        ps.mbToYearOpps.put(
            ctx.mb.Id,
            new Map<Integer, Integer>{ yearOpp => 50 }
        );

        Provision__c result = ps.getProvisionIntern(ctx.opp, ctx.mb);
        System.assertNotEquals(null, result, 'Internal provision should be created for valid model + counts.');
        System.assertEquals(0.35, result.ErfolgsabhaengigeProvisionInProzent__c, 'Configured Monat scale 4-6 must apply.');
        System.assertEquals(350, result.Erfolgsabh_ngige_Provision_direkt__c, 'Direct amount should be 0.35% of 100000.');
    }

    @IsTest
    static void getErfolgsabhaengigeProvision_returnsNullIfDateOutsideContactRange() {
        InternalContext ctx = createInternalContext(Date.today().addDays(-1));
        Provisionsmodell__c defaultModel = createProvisionModel('Default DateRange', Date.today().addYears(-1), null, null);
        insertStandardStaffeln(defaultModel.Id);

        Contact mb = new Contact(Id = ctx.mb.Id);
        mb.ErhaeltErfolgsabhaengigeProvisionVon__c = ctx.opp.Notartermin__c.addDays(2);
        mb.ErhaeltErfolgsabhaengigeProvisionBis__c = ctx.opp.Notartermin__c.addDays(10);

        ProvisionService ps = new ProvisionService(
            new Map<Id, Opportunity>{ ctx.opp.Id => ctx.opp },
            new Map<Id, Opportunity>(),
            'intern',
            'month'
        );
        ps.initializeProvisionModelConfigs(new List<Opportunity>{ ctx.opp }, new List<Contact>{ mb });

        Decimal value = ps.getErfolgsabhaengigeProvision(
            createProvisionStub(100000, 5, 0, 0),
            mb,
            ctx.opp.Notartermin__c
        );

        System.assertEquals(null, value, 'Date-outside contact range must not produce internal provision.');
    }
}