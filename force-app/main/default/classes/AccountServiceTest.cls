@IsTest
private class AccountServiceTest {

    @TestSetup
    static void makeData() {
        Account acc = TestDataFactory.createAccount(true);
        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        insert new List<Contact> { makler };
    }

    @IsTest
    static void testScoreCalculation() {
        Account acc = TestDataFactory.createAccount(false);
        acc.Name = 'Top Makler GmbH';
        acc.Rechtsform__c = 'GmbH & Co. KG';
        acc.FacebookUrl__c = 'https://facebook.com';
        acc.InstagramUrl__c = 'https://instagram.com';
        acc.LinkedInUrl__c = 'https://linkedin.com';
        acc.TrustpilotUrl__c = 'https://trustpilot.com';
        acc.AnzahlBewertungen__c = 45;
        acc.DurchschnittBewertungen__c = 4.2;
        acc.NumberOfEmployees = 20;
        acc.NewsArtikel__c = 'Titel A: https://example.com\r\nTitel B: https://example.com';
        acc.Carestone_Vertriebsvereinbarung__c = true;
        acc.WHS_Maklerauftrag__c = 'Exklusiv';
        insert acc;

        Test.startTest();
        AccountService.updateAccountScore(new List<Id>{ acc.Id });
        Test.stopTest();

        acc = [SELECT Score__c FROM Account WHERE Id = :acc.Id];
        System.debug('Berechneter Score: ' + acc.Score__c);
        System.assert(acc.Score__c > 0, 'Score should be greater than 0');
        System.assert(acc.Score__c <= 100, 'Score must not exceed 100');
    }

    @IsTest
    static void testScoreWithoutImportantData() {
        Account acc = TestDataFactory.createAccount(false);
        acc.Rechtsform__c = 'Einzelunternehmer';
        acc.Carestone_Vertriebsvereinbarung__c = false;
        acc.WHS_Maklerauftrag__c = 'Keine Vereinbarung';
        insert acc;

        Test.startTest();
        AccountService.updateAccountScore(new List<Id>{ acc.Id });
        Test.stopTest();

        acc = [SELECT Score__c FROM Account WHERE Id = :acc.Id];
        System.debug('Minimal Score: ' + acc.Score__c);
        System.assert(acc.Score__c < 30, 'Score should be low for weak data');
    }
}