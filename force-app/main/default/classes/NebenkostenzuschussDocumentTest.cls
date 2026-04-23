@IsTest
private class NebenkostenzuschussDocumentTest {

    @TestSetup
    static void setup() {
        TestDataFactory.createNecessaryCustomSettings();
        TestDataFactory.createDatevSettings();
    }

    @IsTest
    static void testSendNKZAsPdf_CreatesContentVersionAndLink() {
        Account acc = TestDataFactory.createAccount(true);
        Contact empfaenger = TestDataFactory.createMakler(true, acc.Id);

        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.Empfaenger__c = empfaenger.Id;
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.today();
        nkz.GenehmigungControlling__c = true;
        nkz.DatumGenehmigungControlling__c = Date.today();
        nkz.Laufnummer_Zahl__c = 1;
        insert nkz;

        Test.startTest();
        NebenkostenzuschussDocument.sendNKZAsPdf(nkz.Id);
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
        Assert.isTrue(cv.Title.startsWith('Nebenkostenzuschuss NK'), 'File title must start with Nebenkostenzuschuss NK');
        Assert.isTrue(cv.Title.endsWith('.pdf'), 'File title must end with .pdf');
        Assert.areEqual('Nebenkostenzuschuss', cv.Typ__c, 'ContentVersion Typ must be Nebenkostenzuschuss');
        Assert.areEqual('S', cv.ContentLocation, 'ContentLocation must be Salesforce');
    }

    @IsTest
    static void testSendNKZAsPdf_SetsBelegWurdeGeneriert() {
        Account acc = TestDataFactory.createAccount(true);
        Contact empfaenger = TestDataFactory.createMakler(true, acc.Id);

        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.Empfaenger__c = empfaenger.Id;
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.today();
        nkz.GenehmigungControlling__c = true;
        nkz.DatumGenehmigungControlling__c = Date.today();
        nkz.Laufnummer_Zahl__c = 2;
        insert nkz;

        Assert.isFalse(
            [SELECT BelegWurdeGeneriert__c FROM Nebenkostenzuschuss__c WHERE Id = :nkz.Id].BelegWurdeGeneriert__c,
            'BelegWurdeGeneriert must be false before generation'
        );

        Test.startTest();
        NebenkostenzuschussDocument.sendNKZAsPdf(nkz.Id);
        Test.stopTest();

        Nebenkostenzuschuss__c updated = [
            SELECT BelegWurdeGeneriert__c
            FROM Nebenkostenzuschuss__c
            WHERE Id = :nkz.Id
        ];
        Assert.isTrue(updated.BelegWurdeGeneriert__c, 'BelegWurdeGeneriert must be true after PDF generation');
    }

    @IsTest
    static void testSendNKZAsPdf_FileNameFormat() {
        Account acc = TestDataFactory.createAccount(true);
        Contact empfaenger = TestDataFactory.createMakler(true, acc.Id);

        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.Empfaenger__c = empfaenger.Id;
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.newInstance(2025, 3, 15);
        nkz.GenehmigungControlling__c = true;
        nkz.DatumGenehmigungControlling__c = Date.today();
        nkz.Laufnummer_Zahl__c = 42;
        insert nkz;

        Test.startTest();
        NebenkostenzuschussDocument.sendNKZAsPdf(nkz.Id);
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
            'Nebenkostenzuschuss NK 2025 0042.pdf',
            cv.Title,
            'File name must follow format: Nebenkostenzuschuss NK YYYY NNNN.pdf'
        );
    }

    @IsTest
    static void testSendNKZAsPdf_EmailInvocations() {
        Account acc = TestDataFactory.createAccount(true);
        Contact empfaenger = TestDataFactory.createMakler(true, acc.Id);

        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.Empfaenger__c = empfaenger.Id;
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.today();
        nkz.GenehmigungControlling__c = true;
        nkz.DatumGenehmigungControlling__c = Date.today();
        nkz.Laufnummer_Zahl__c = 3;
        insert nkz;

        Test.startTest();
        NebenkostenzuschussDocument.sendNKZAsPdf(nkz.Id);
        Test.stopTest();

        Assert.isTrue(
            Limits.getEmailInvocations() > 0,
            'At least one email invocation must occur'
        );
    }

    @IsTest
    static void testSendNKZAsPdf_HandlesMissingRecipient() {
        Nebenkostenzuschuss__c nkz = TestDataFactory.createNebenkostenzuschuss(false);
        nkz.GenehmigungBackoffice__c = true;
        nkz.DatumGenehmigungBackoffice__c = Date.today();
        nkz.GenehmigungControlling__c = true;
        nkz.DatumGenehmigungControlling__c = Date.today();
        nkz.Laufnummer_Zahl__c = 4;
        insert nkz;

        Test.startTest();
        NebenkostenzuschussDocument.sendNKZAsPdf(nkz.Id);
        Test.stopTest();

        List<ContentDocumentLink> links = [
            SELECT Id
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :nkz.Id
        ];
        Assert.isFalse(links.isEmpty(), 'ContentDocumentLink must still be created when recipient is missing');

        Nebenkostenzuschuss__c updated = [
            SELECT BelegWurdeGeneriert__c
            FROM Nebenkostenzuschuss__c
            WHERE Id = :nkz.Id
        ];
        Assert.isTrue(updated.BelegWurdeGeneriert__c, 'BelegWurdeGeneriert must be true after generation');
    }

    @IsTest
    static void testSendNKZAsPdf_NullId_NoOp() {
        Test.startTest();
        NebenkostenzuschussDocument.sendNKZAsPdf(null);
        Test.stopTest();

        Assert.areEqual(0, [SELECT COUNT() FROM ContentDocumentLink], 'No files should be linked for null input');
    }
}
