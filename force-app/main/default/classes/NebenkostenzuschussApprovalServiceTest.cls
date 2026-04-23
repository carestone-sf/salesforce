@IsTest
private class NebenkostenzuschussApprovalServiceTest {

    @TestSetup
    static void setup() {
        TestDataFactory.createDatevSettings();
        TestDataFactory.createNecessaryCustomSettings();
    }

    @IsTest
    static void testBackofficeApprovalOnly() {
        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(true);

        NKZApproval__e evt = new NKZApproval__e(
            NebenkostenzuschussId__c = nkz.Id,
            ApprovalStage__c = 'Backoffice',
            Approved__c = true
        );

        Test.startTest();
        Database.SaveResult sr = EventBus.publish(evt);
        Test.stopTest();

        System.assert(sr.isSuccess(), 'Event publish should succeed');

        Nebenkostenzuschuss__c updated = [
            SELECT GenehmigungBackoffice__c, DatumGenehmigungBackoffice__c,
                   GenehmigungControlling__c, DatumGenehmigungControlling__c,
                   BelegWurdeGeneriert__c, Laufnummer_Zahl__c
            FROM Nebenkostenzuschuss__c
            WHERE Id = :nkz.Id
        ];

        Assert.isTrue(updated.GenehmigungBackoffice__c);
        Assert.areEqual(Date.today(), updated.DatumGenehmigungBackoffice__c);
        Assert.isFalse(updated.GenehmigungControlling__c);
        Assert.isNull(updated.DatumGenehmigungControlling__c);
        Assert.isFalse(updated.BelegWurdeGeneriert__c);
        Assert.isNull(updated.Laufnummer_Zahl__c);
    }

    @IsTest
    static void testFullTwoStageApproval() {
        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.today();
        insert nkz;

        NKZApproval__e controllingEvt = new NKZApproval__e(
            NebenkostenzuschussId__c = nkz.Id,
            ApprovalStage__c = 'Controlling',
            Approved__c = true
        );

        Test.startTest();
        EventBus.publish(controllingEvt);
        Test.stopTest();

        Nebenkostenzuschuss__c updated = [
            SELECT GenehmigungBackoffice__c, DatumGenehmigungBackoffice__c,
                   GenehmigungControlling__c, DatumGenehmigungControlling__c,
                   BelegWurdeGeneriert__c, Laufnummer_Zahl__c
            FROM Nebenkostenzuschuss__c
            WHERE Id = :nkz.Id
        ];

        Assert.isTrue(updated.GenehmigungBackoffice__c);
        Assert.areEqual(Date.today(), updated.DatumGenehmigungBackoffice__c);
        Assert.isTrue(updated.GenehmigungControlling__c);
        Assert.areEqual(Date.today(), updated.DatumGenehmigungControlling__c);
        Assert.isTrue(updated.BelegWurdeGeneriert__c);
        Assert.areEqual(1, updated.Laufnummer_Zahl__c);

        NKZ_Laufnummer__c setting = NKZ_Laufnummer__c.getOrgDefaults();
        Assert.areEqual(1, setting.NKZ_Laufnummer__c);
    }

    @IsTest
    static void testDoubleBackofficeApprovalIgnored() {
        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.today().addDays(-1);
        insert nkz;

        NKZApproval__e evt = new NKZApproval__e(
            NebenkostenzuschussId__c = nkz.Id,
            ApprovalStage__c = 'Backoffice',
            Approved__c = true
        );

        Test.startTest();
        EventBus.publish(evt);
        Test.stopTest();

        Nebenkostenzuschuss__c updated = [
            SELECT GenehmigungBackoffice__c, DatumGenehmigungBackoffice__c
            FROM Nebenkostenzuschuss__c
            WHERE Id = :nkz.Id
        ];

        Assert.isTrue(updated.GenehmigungBackoffice__c);
        Assert.areEqual(
            Date.today().addDays(-1),
            updated.DatumGenehmigungBackoffice__c,
            'Original approval date must not change'
        );
    }

    @IsTest
    static void testControllingWithoutBackofficeIgnored() {
        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(true);

        NKZApproval__e evt = new NKZApproval__e(
            NebenkostenzuschussId__c = nkz.Id,
            ApprovalStage__c = 'Controlling',
            Approved__c = true
        );

        Test.startTest();
        EventBus.publish(evt);
        Test.stopTest();

        Nebenkostenzuschuss__c updated = [
            SELECT GenehmigungControlling__c, BelegWurdeGeneriert__c
            FROM Nebenkostenzuschuss__c
            WHERE Id = :nkz.Id
        ];

        Assert.isFalse(
            updated.GenehmigungControlling__c,
            'Controlling approval must not be granted without Backoffice approval'
        );
        Assert.isFalse(updated.BelegWurdeGeneriert__c);
    }

    @IsTest
    static void testStorniertRecordIgnored() {
        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.Storniert__c = true;
        insert nkz;

        NKZApproval__e evt = new NKZApproval__e(
            NebenkostenzuschussId__c = nkz.Id,
            ApprovalStage__c = 'Backoffice',
            Approved__c = true
        );

        Test.startTest();
        EventBus.publish(evt);
        Test.stopTest();

        Nebenkostenzuschuss__c updated = [
            SELECT GenehmigungBackoffice__c, BelegWurdeGeneriert__c
            FROM Nebenkostenzuschuss__c
            WHERE Id = :nkz.Id
        ];

        Assert.isFalse(
            updated.GenehmigungBackoffice__c,
            'Stornierte records must not be approved'
        );
        Assert.isFalse(updated.BelegWurdeGeneriert__c);
    }

    @IsTest
    static void testAlreadyFullyApprovedIgnored() {
        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.today().addDays(-2);
        nkz.GenehmigungControlling__c = true;
        nkz.DatumGenehmigungControlling__c = Date.today().addDays(-1);
        nkz.Laufnummer_Zahl__c = 42;
        nkz.BelegWurdeGeneriert__c = true;
        insert nkz;

        NKZApproval__e evt = new NKZApproval__e(
            NebenkostenzuschussId__c = nkz.Id,
            ApprovalStage__c = 'Controlling',
            Approved__c = true
        );

        Test.startTest();
        EventBus.publish(evt);
        Test.stopTest();

        Nebenkostenzuschuss__c updated = [
            SELECT Laufnummer_Zahl__c
            FROM Nebenkostenzuschuss__c
            WHERE Id = :nkz.Id
        ];

        Assert.areEqual(
            42,
            updated.Laufnummer_Zahl__c,
            'Laufnummer must not change for already-approved records'
        );
    }

    @IsTest
    static void testBulkApprovalWithSequentialLaufnummern() {
        List<Nebenkostenzuschuss__c> records = new List<Nebenkostenzuschuss__c>();
        for (Integer i = 0; i < 5; i++) {
            Nebenkostenzuschuss__c nkz = new Nebenkostenzuschuss__c(
                Name = 'Bulk NKZ ' + i,
                Betrag__c = 500 + i,
                GenehmigungBackoffice__c = true,
                DatumGenehmigungBackoffice__c = Date.today()
            );
            records.add(nkz);
        }
        insert records;

        List<NKZApproval__e> events = new List<NKZApproval__e>();
        for (Nebenkostenzuschuss__c nkz : records) {
            events.add(new NKZApproval__e(
                NebenkostenzuschussId__c = nkz.Id,
                ApprovalStage__c = 'Controlling',
                Approved__c = true
            ));
        }

        Test.startTest();
        EventBus.publish(events);
        Test.stopTest();

        List<Nebenkostenzuschuss__c> updated = [
            SELECT Laufnummer_Zahl__c, BelegWurdeGeneriert__c
            FROM Nebenkostenzuschuss__c
            WHERE Id IN :records
            ORDER BY Laufnummer_Zahl__c ASC
        ];

        Assert.areEqual(5, updated.size());
        for (Integer i = 0; i < 5; i++) {
            Assert.areEqual(i + 1, updated[i].Laufnummer_Zahl__c);
            Assert.isTrue(updated[i].BelegWurdeGeneriert__c);
        }

        NKZ_Laufnummer__c setting = NKZ_Laufnummer__c.getOrgDefaults();
        Assert.areEqual(5, setting.NKZ_Laufnummer__c);
    }

    @IsTest
    static void testBothStagesInSameEventBatch() {
        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(true);

        List<NKZApproval__e> events = new List<NKZApproval__e>{
            new NKZApproval__e(
                NebenkostenzuschussId__c = nkz.Id,
                ApprovalStage__c = 'Backoffice',
                Approved__c = true
            ),
            new NKZApproval__e(
                NebenkostenzuschussId__c = nkz.Id,
                ApprovalStage__c = 'Controlling',
                Approved__c = true
            )
        };

        Test.startTest();
        EventBus.publish(events);
        Test.stopTest();

        Nebenkostenzuschuss__c updated = [
            SELECT GenehmigungBackoffice__c, GenehmigungControlling__c,
                   BelegWurdeGeneriert__c, Laufnummer_Zahl__c
            FROM Nebenkostenzuschuss__c
            WHERE Id = :nkz.Id
        ];

        Assert.isTrue(updated.GenehmigungBackoffice__c);
        Assert.isTrue(updated.GenehmigungControlling__c);
        Assert.isTrue(updated.BelegWurdeGeneriert__c);
        Assert.areEqual(1, updated.Laufnummer_Zahl__c);
    }

    @IsTest
    static void testMissingLaufnummerSettingIsCreated() {
        delete [SELECT Id FROM NKZ_Laufnummer__c];

        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.today();
        insert nkz;

        NKZApproval__e evt = new NKZApproval__e(
            NebenkostenzuschussId__c = nkz.Id,
            ApprovalStage__c = 'Controlling',
            Approved__c = true
        );

        Test.startTest();
        EventBus.publish(evt);
        Test.stopTest();

        Nebenkostenzuschuss__c updated = [
            SELECT BelegWurdeGeneriert__c, Laufnummer_Zahl__c
            FROM Nebenkostenzuschuss__c
            WHERE Id = :nkz.Id
        ];
        Assert.isTrue(updated.BelegWurdeGeneriert__c);
        Assert.areEqual(1, updated.Laufnummer_Zahl__c);

        NKZ_Laufnummer__c setting = NKZ_Laufnummer__c.getOrgDefaults();
        Assert.areEqual(1, setting.NKZ_Laufnummer__c);
    }

    @IsTest
    static void testNotApprovedEventIgnored() {
        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(true);

        NKZApproval__e evt = new NKZApproval__e(
            NebenkostenzuschussId__c = nkz.Id,
            ApprovalStage__c = 'Backoffice',
            Approved__c = false
        );

        Test.startTest();
        EventBus.publish(evt);
        Test.stopTest();

        Nebenkostenzuschuss__c updated = [
            SELECT GenehmigungBackoffice__c
            FROM Nebenkostenzuschuss__c
            WHERE Id = :nkz.Id
        ];

        Assert.isFalse(
            updated.GenehmigungBackoffice__c,
            'Non-approved event must not grant approval'
        );
    }
}
