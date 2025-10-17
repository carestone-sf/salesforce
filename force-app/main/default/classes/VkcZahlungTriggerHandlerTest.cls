@IsTest
private class VkcZahlungTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.createDatevSettings();
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(false, TestDataFactory.createBautraeger(true).Id);
        immobilie.Kaufpreiszahlung__c = 'Endfällig';
        insert immobilie;
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        TestDataFactory.createProvisionsverhandlung(true, acc.Id, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent};

        Opportunity opp = TestDataFactory.createOpportunity(false, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Notartermin hat stattgefunden', 100000);
        opp.Abrechnung_ber__c = makler.Id;
        opp.Immobilienberater__c = makler.Id;
        opp.Datum_Kaufpreisf_lligkeitsschreiben__c = Date.today().addDays(-10);
        insert opp;
    }

    @IsTest
    private static void testCalculateImmoSumOnInsert(){
        Opportunity opp = [SELECT Id, Immobilie__c, OffenerBetrag__c, Appartement__c FROM Opportunity LIMIT 1];

        List<VKCZahlung__c> zahlungen = new List<VKCZahlung__c>();
        for(Integer i = 0; i < 3; i++) {
            zahlungen.add(new VKCZahlung__c(
                Verkaufschance__c = opp.Id,
                UniqueId__c = String.valueOf(i),
                Betrag__c = 10
            ));
        }

        Test.startTest();
        insert zahlungen;
        Test.stopTest();

        System.assertEquals(opp.OffenerBetrag__c - 30, [SELECT OffenerBetragEinmalzahlungen__c FROM Property__c WHERE Id = :opp.Immobilie__c].OffenerBetragEinmalzahlungen__c);
        System.assertEquals(30, [SELECT Bezahlt__c FROM Appartment__c WHERE Id = :opp.Appartement__c].Bezahlt__c);
    }

    @IsTest
    private static void testCalculateImmoSumOnUpdate(){
        Opportunity opp = [SELECT Id, Immobilie__c, OffenerBetrag__c FROM Opportunity LIMIT 1];

        List<VKCZahlung__c> zahlungen = new List<VKCZahlung__c>();
        for(Integer i = 0; i < 3; i++) {
            zahlungen.add(new VKCZahlung__c(
                Verkaufschance__c = opp.Id,
                UniqueId__c = String.valueOf(i),
                Betrag__c = 10
            ));
        }

        Test.startTest();
        insert zahlungen;

        for(VkcZahlung__c zahlung : zahlungen) {
            zahlung.Betrag__c = 100;
        }
        update zahlungen;

        Test.stopTest();

        System.assertEquals(opp.OffenerBetrag__c - 300, [SELECT OffenerBetragEinmalzahlungen__c FROM Property__c WHERE Id = :opp.Immobilie__c].OffenerBetragEinmalzahlungen__c);
    }
    
    @IsTest
    private static void testCalculateImmoSumOnDelete(){
        Opportunity opp = [SELECT Id, Immobilie__c, OffenerBetrag__c FROM Opportunity LIMIT 1];

        List<VKCZahlung__c> zahlungen = new List<VKCZahlung__c>();
        for(Integer i = 0; i < 3; i++) {
            zahlungen.add(new VKCZahlung__c(
                Verkaufschance__c = opp.Id,
                UniqueId__c = String.valueOf(i),
                Betrag__c = 10
            ));
        }

        insert zahlungen;

        Test.startTest();
        delete zahlungen[0];
        Test.stopTest();

        System.assertEquals(opp.OffenerBetrag__c - 20, [SELECT OffenerBetragEinmalzahlungen__c FROM Property__c WHERE Id = :opp.Immobilie__c].OffenerBetragEinmalzahlungen__c);
    }
}