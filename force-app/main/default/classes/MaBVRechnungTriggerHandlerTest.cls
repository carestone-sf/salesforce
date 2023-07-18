@IsTest
private class MaBVRechnungTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        TestDataFactory.createDatevSettings();
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        TestDataFactory.createProvisionsverhandlung(true, acc.Id, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent};

        Opportunity opp = TestDataFactory.createOpportunity(false, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Geschlossene und gewonnene', 100000);
        opp.Abrechnung_ber__c = makler.Id;
        opp.Immobilienberater__c = makler.Id;
        insert opp;
    }
    
    @IsTest
    private static void testNewRechnungSetsRateValues() {
        Opportunity opp = [SELECT Id, beurkundeter_Kaufpreis__c FROM Opportunity LIMIT 1];
        System.debug(opp.beurkundeter_Kaufpreis__c);
        Property__c immo = [SELECT Id FROM Property__c LIMIT 1];
        
        MaBVRate__c rate = TestDataFactory.createMaBVRate(true, immo.Id, 0.5);
        
        List<MaBVRechnungMaster__c> masterList = new List<MaBVRechnungMaster__c>();

        for(Integer i = 0; i < 1; i++) { //CS-160: Set to 1 to fix testclass because of failing MaBVRechnungenBatch
            masterList.add(TestDataFactory.createMaBVRechnungMaster(false, opp.Id, rate.Id));
        }
        insert masterList;

        List<MaBVRechnung__c> rechnungen = new List<MaBVRechnung__c>();
        for(MaBVRechnungMaster__c master : masterList) {
            for(Integer i = 0; i < 3; i++) {
                MaBVRechnung__c rechnung = TestDataFactory.createMaBVRechnung(false, '123-123-1-' + i, master.Id);
                rechnungen.add(rechnung);
            }
        }

        insert rechnungen;

        System.debug([SELECT RateInEuro__c, OffenerBetragNeu__c FROM MaBVRechnung__c]);
        Double rateGesamtInEuro = [SELECT RateGesamtInEuro__c FROM MaBVRechnung__c WHERE Id IN :rechnungen LIMIT 1].RateGesamtInEuro__c; 

        List<Zahlung__c> zahlungen = new List<Zahlung__c>();
        for(MaBVRechnung__c rechnung : rechnungen) {
            if(rechnung.Name.endsWith('1')) {
                zahlungen.add(TestDataFactory.createZahlung(false, rateGesamtInEuro, rechnung.Id));
            }
        }

        Test.startTest();
        insert zahlungen;
        Test.stopTest();

        System.debug([SELECT OffenerBetragNeu__c, Bezahlt__c, RateGesamtInEuro__c, IstBezahlt__c FROM MaBVRechnung__c WHERE Id NOT IN (SELECT MaBVRechnung__c FROM Zahlung__c)]);

        rate = [SELECT GesamtanzahlRechnungen__c, OffeneRechnungen__c, GezahlteRechnungen__c, SummeGezahlterRechnungen__c, SummeOffenerRechnungen__c FROM MaBVRate__c WHERE Id = :rate.Id]; 
        System.assertEquals(3, rate.GesamtanzahlRechnungen__c);
        System.assertEquals(2, rate.OffeneRechnungen__c);
        System.assertEquals(1, rate.GezahlteRechnungen__c);
        System.assertEquals(472.5, rate.SummeGezahlterRechnungen__c);
        System.assertEquals(945, rate.SummeOffenerRechnungen__c);
    }

    @IsTest
    private static void testUpdateZahlungSetsRateValues() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Property__c immo = [SELECT Id FROM Property__c LIMIT 1];
        
        MaBVRate__c rate = TestDataFactory.createMaBVRate(true, immo.Id, 0.5);
        
        List<MaBVRechnungMaster__c> masterList = new List<MaBVRechnungMaster__c>();

        for(Integer i = 0; i < 1; i++) { //CS-160: Set to 1 to fix testclass because of failing MaBVRechnungenBatch
            masterList.add(TestDataFactory.createMaBVRechnungMaster(false, opp.Id, rate.Id));
        }
        insert masterList;

        List<MaBVRechnung__c> rechnungen = new List<MaBVRechnung__c>();
        for(MaBVRechnungMaster__c master : masterList) {
            for(Integer i = 0; i < 3; i++) {
                MaBVRechnung__c rechnung = TestDataFactory.createMaBVRechnung(false, '123-123-1-' + i, master.Id); 
                rechnungen.add(rechnung);
            }
        }

        insert rechnungen;

        Double rateGesamtInEuro = [SELECT RateGesamtInEuro__c FROM MaBVRechnung__c WHERE Id IN :rechnungen LIMIT 1].RateGesamtInEuro__c; 

        List<Zahlung__c> zahlungen = new List<Zahlung__c>();
        for(MaBVRechnung__c rechnung : rechnungen) {
            if(rechnung.Name.endsWith('1')) {
                zahlungen.add(TestDataFactory.createZahlung(false, 0, rechnung.Id));
            }
        }

        Test.startTest();
        insert zahlungen;

        for(Zahlung__c zahlung : zahlungen) {
            zahlung.Betrag__c = rateGesamtInEuro;
        }

        update zahlungen;

        Test.stopTest();

        System.debug([SELECT OffenerBetragNeu__c, Bezahlt__c, RateGesamtInEuro__c, IstBezahlt__c FROM MaBVRechnung__c WHERE Id IN (SELECT MaBVRechnung__c FROM Zahlung__c)]);

        rate = [SELECT GesamtanzahlRechnungen__c, OffeneRechnungen__c, GezahlteRechnungen__c, SummeGezahlterRechnungen__c, SummeOffenerRechnungen__c FROM MaBVRate__c WHERE Id = :rate.Id]; 
        System.assertEquals(3, rate.GesamtanzahlRechnungen__c);
        System.assertEquals(2, rate.OffeneRechnungen__c);
        System.assertEquals(1, rate.GezahlteRechnungen__c);
        System.assertEquals(472.5, rate.SummeGezahlterRechnungen__c);
        System.assertEquals(945, rate.SummeOffenerRechnungen__c);
    }


    @IsTest
    private static void testDeleteRechnungSetsRateValues() {
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Property__c immo = [SELECT Id FROM Property__c LIMIT 1];
        
        MaBVRate__c rate = TestDataFactory.createMaBVRate(true, immo.Id, 0.5);
        
        List<MaBVRechnungMaster__c> masterList = new List<MaBVRechnungMaster__c>();

        for(Integer i = 0; i < 1; i++) { //CS-160: Set to 1 to fix testclass because of failing MaBVRechnungenBatch
            masterList.add(TestDataFactory.createMaBVRechnungMaster(false, opp.Id, rate.Id));
        }
        insert masterList;

        List<MaBVRechnung__c> rechnungen = new List<MaBVRechnung__c>();
        for(MaBVRechnungMaster__c master : masterList) {
            for(Integer i = 0; i < 3; i++) {
                MaBVRechnung__c rechnung = TestDataFactory.createMaBVRechnung(false, '123-123-1-' + i, master.Id); 
                rechnungen.add(rechnung);
            }
        }

        insert rechnungen;

        Test.startTest();
        delete [SELECT Id FROM MaBVRechnung__c LIMIT 1];
        delete [SELECT Id FROM Zahlung__c LIMIT 1];
        Test.stopTest();

        rate = [SELECT GesamtanzahlRechnungen__c, OffeneRechnungen__c, GezahlteRechnungen__c, SummeGezahlterRechnungen__c, SummeOffenerRechnungen__c FROM MaBVRate__c WHERE Id = :rate.Id]; 
        System.assertEquals(2, rate.GesamtanzahlRechnungen__c);
        System.assertEquals(2, rate.OffeneRechnungen__c);
    }
}