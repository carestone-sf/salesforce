@IsTest
private class NebenkostenzuschussStornoTest {

    @TestSetup
    static void setup() {
        TestDataFactory.createNecessaryCustomSettings();
        TestDataFactory.createDatevSettings();
    }

    @IsTest
    static void testSendNKZStornoAsPdf_CreatesContentVersionAndLink() {
        Account acc = TestDataFactory.createAccount(true);
        Contact empfaenger = TestDataFactory.createMakler(true, acc.Id);

        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.Empfaenger__c = empfaenger.Id;
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.today();
        nkz.GenehmigungControlling__c = true;
        nkz.DatumGenehmigungControlling__c = Date.today();
        nkz.Laufnummer_Zahl__c = 1;
        nkz.Storniert__c = true;
        nkz.DatumStorniert__c = Date.today();
        nkz.StornoLaufnummerZahl__c = 1;
        insert nkz;

        Test.startTest();
        NebenkostenzuschussStorno.sendNKZStornoAsPdf(nkz.Id);
        Test.stopTest();

        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :nkz.Id
        ];
        Assert.isFalse(links.isEmpty(), 'ContentDocumentLink must be created for the NKZ record');

        ContentVersion cv = [
            SELECT Title, Typ__c, ContentLocation
            FROM ContentVersion
            WHERE ContentDocumentId = :links[0].ContentDocumentId
            LIMIT 1
        ];
        Assert.isTrue(cv.Title.startsWith('Stornobeleg SB NK'), 'File title must start with Stornobeleg SB NK');
        Assert.isTrue(cv.Title.endsWith('.pdf'), 'File title must end with .pdf');
        Assert.areEqual('Storno', cv.Typ__c, 'ContentVersion Typ must be Storno');
        Assert.areEqual('S', cv.ContentLocation, 'ContentLocation must be Salesforce');
    }

    @IsTest
    static void testSendNKZStornoAsPdf_SetsStornoWurdeGeneriert() {
        Account acc = TestDataFactory.createAccount(true);
        Contact empfaenger = TestDataFactory.createMakler(true, acc.Id);

        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.Empfaenger__c = empfaenger.Id;
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.today();
        nkz.GenehmigungControlling__c = true;
        nkz.DatumGenehmigungControlling__c = Date.today();
        nkz.Laufnummer_Zahl__c = 2;
        nkz.Storniert__c = true;
        nkz.DatumStorniert__c = Date.today();
        nkz.StornoLaufnummerZahl__c = 2;
        insert nkz;

        Assert.isFalse(
            [SELECT StornoWurdeGeneriert__c FROM Nebenkostenzuschuss__c WHERE Id = :nkz.Id].StornoWurdeGeneriert__c,
            'StornoWurdeGeneriert must be false before generation'
        );

        Test.startTest();
        NebenkostenzuschussStorno.sendNKZStornoAsPdf(nkz.Id);
        Test.stopTest();

        Nebenkostenzuschuss__c updated = [
            SELECT StornoWurdeGeneriert__c
            FROM Nebenkostenzuschuss__c
            WHERE Id = :nkz.Id
        ];
        Assert.isTrue(updated.StornoWurdeGeneriert__c, 'StornoWurdeGeneriert must be true after PDF generation');
    }

    @IsTest
    static void testSendNKZStornoAsPdf_FileNameFormat() {
        Account acc = TestDataFactory.createAccount(true);
        Contact empfaenger = TestDataFactory.createMakler(true, acc.Id);

        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.Empfaenger__c = empfaenger.Id;
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.today();
        nkz.GenehmigungControlling__c = true;
        nkz.DatumGenehmigungControlling__c = Date.today();
        nkz.Laufnummer_Zahl__c = 42;
        nkz.Storniert__c = true;
        nkz.DatumStorniert__c = Date.newInstance(2025, 6, 15);
        nkz.StornoLaufnummerZahl__c = 42;
        insert nkz;

        Test.startTest();
        NebenkostenzuschussStorno.sendNKZStornoAsPdf(nkz.Id);
        Test.stopTest();

        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :nkz.Id
        ];
        ContentVersion cv = [
            SELECT Title
            FROM ContentVersion
            WHERE ContentDocumentId = :links[0].ContentDocumentId
            LIMIT 1
        ];
        Assert.areEqual(
            'Stornobeleg SB NK 2025 0042.pdf',
            cv.Title,
            'File name must follow format: Stornobeleg SB NK YYYY NNNN.pdf'
        );
    }

    @IsTest
    static void testSendNKZStornoAsPdf_EmailInvocations() {
        Account acc = TestDataFactory.createAccount(true);
        Contact empfaenger = TestDataFactory.createMakler(true, acc.Id);

        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.Empfaenger__c = empfaenger.Id;
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.today();
        nkz.GenehmigungControlling__c = true;
        nkz.DatumGenehmigungControlling__c = Date.today();
        nkz.Laufnummer_Zahl__c = 3;
        nkz.Storniert__c = true;
        nkz.DatumStorniert__c = Date.today();
        nkz.StornoLaufnummerZahl__c = 3;
        insert nkz;

        Test.startTest();
        NebenkostenzuschussStorno.sendNKZStornoAsPdf(nkz.Id);
        Test.stopTest();

        Assert.isTrue(
            Limits.getEmailInvocations() > 0,
            'At least one email invocation must occur'
        );
    }

    @IsTest
    static void testSendNKZStornoAsPdf_HandlesMissingRecipient() {
        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.today();
        nkz.GenehmigungControlling__c = true;
        nkz.DatumGenehmigungControlling__c = Date.today();
        nkz.Laufnummer_Zahl__c = 4;
        nkz.Storniert__c = true;
        nkz.DatumStorniert__c = Date.today();
        nkz.StornoLaufnummerZahl__c = 4;
        insert nkz;

        Test.startTest();
        NebenkostenzuschussStorno.sendNKZStornoAsPdf(nkz.Id);
        Test.stopTest();

        List<ContentDocumentLink> links = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :nkz.Id
        ];
        Assert.isFalse(links.isEmpty(), 'ContentDocumentLink must still be created when recipient is missing');

        Nebenkostenzuschuss__c updated = [
            SELECT StornoWurdeGeneriert__c
            FROM Nebenkostenzuschuss__c
            WHERE Id = :nkz.Id
        ];
        Assert.isTrue(updated.StornoWurdeGeneriert__c, 'StornoWurdeGeneriert must be true after generation');
    }

    @IsTest
    static void testSendNKZStornoAsPdf_NullId_NoOp() {
        Test.startTest();
        NebenkostenzuschussStorno.sendNKZStornoAsPdf(null);
        Test.stopTest();

        Assert.areEqual(0, [SELECT COUNT() FROM ContentDocumentLink], 'No files should be linked for null input');
    }

    @IsTest
    static void testTrigger_StornoAssignsLaufnummerAndDate() {
        Account acc = TestDataFactory.createAccount(true);
        Contact empfaenger = TestDataFactory.createMakler(true, acc.Id);

        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.Empfaenger__c = empfaenger.Id;
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.today();
        nkz.GenehmigungControlling__c = true;
        nkz.DatumGenehmigungControlling__c = Date.today();
        nkz.Laufnummer_Zahl__c = 10;
        insert nkz;

        Test.startTest();
        nkz.Storniert__c = true;
        update nkz;
        Test.stopTest();

        Nebenkostenzuschuss__c updated = [
            SELECT DatumStorniert__c, StornoLaufnummerZahl__c, StornoLaufnummer__c
            FROM Nebenkostenzuschuss__c
            WHERE Id = :nkz.Id
        ];
        Assert.areEqual(Date.today(), updated.DatumStorniert__c, 'DatumStorniert must be set to today');
        Assert.areEqual(0, updated.StornoLaufnummerZahl__c, 'StornoLaufnummerZahl must be assigned from counter (starting at 0)');
        Assert.isNotNull(updated.StornoLaufnummer__c, 'StornoLaufnummer formula must be populated');
    }

    @IsTest
    static void testTrigger_StornoIncrementsCounter() {
        Account acc = TestDataFactory.createAccount(true);
        Contact empfaenger = TestDataFactory.createMakler(true, acc.Id);

        Nebenkostenzuschuss__c nkz1 = TestDataFactory.createNebenkostenzuschuss(false);
        nkz1.Empfaenger__c = empfaenger.Id;
        nkz1.GenehmigungBackoffice__c = true;
        nkz1.DatumGenehmigungBackoffice__c = Date.today();
        nkz1.GenehmigungControlling__c = true;
        nkz1.DatumGenehmigungControlling__c = Date.today();
        nkz1.Laufnummer_Zahl__c = 20;

        Nebenkostenzuschuss__c nkz2 = TestDataFactory.createNebenkostenzuschuss(false);
        nkz2.Empfaenger__c = empfaenger.Id;
        nkz2.GenehmigungBackoffice__c = true;
        nkz2.DatumGenehmigungBackoffice__c = Date.today();
        nkz2.GenehmigungControlling__c = true;
        nkz2.DatumGenehmigungControlling__c = Date.today();
        nkz2.Laufnummer_Zahl__c = 21;

        insert new List<Nebenkostenzuschuss__c>{ nkz1, nkz2 };

        Test.startTest();
        nkz1.Storniert__c = true;
        nkz2.Storniert__c = true;
        update new List<Nebenkostenzuschuss__c>{ nkz1, nkz2 };
        Test.stopTest();

        Nebenkostenzuschuss__c updated1 = [
            SELECT StornoLaufnummerZahl__c FROM Nebenkostenzuschuss__c WHERE Id = :nkz1.Id
        ];
        Nebenkostenzuschuss__c updated2 = [
            SELECT StornoLaufnummerZahl__c FROM Nebenkostenzuschuss__c WHERE Id = :nkz2.Id
        ];
        Assert.areEqual(0, updated1.StornoLaufnummerZahl__c, 'First storno must get counter 0');
        Assert.areEqual(1, updated2.StornoLaufnummerZahl__c, 'Second storno must get counter 1');

        NKZ_Storno_Laufnummer__c counter = NKZ_Storno_Laufnummer__c.getOrgDefaults();
        Assert.areEqual(2, counter.NKZ_Storno_Laufnummer__c, 'Custom setting counter must be incremented to 2');
    }

    @IsTest
    static void testTrigger_NonStornoUpdate_NoCounterChange() {
        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.today();
        nkz.GenehmigungControlling__c = true;
        nkz.DatumGenehmigungControlling__c = Date.today();
        nkz.Laufnummer_Zahl__c = 30;
        insert nkz;

        Test.startTest();
        nkz.Betrag__c = 2000.00;
        update nkz;
        Test.stopTest();

        NKZ_Storno_Laufnummer__c counter = NKZ_Storno_Laufnummer__c.getOrgDefaults();
        Assert.areEqual(0, counter.NKZ_Storno_Laufnummer__c, 'Counter must remain unchanged for non-storno updates');
    }
}
