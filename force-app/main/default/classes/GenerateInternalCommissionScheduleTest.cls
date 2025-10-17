@isTest
private class GenerateInternalCommissionScheduleTest {
    @testSetup static void test_setup() {
        Contact mb = new Contact();
        mb.FirstNAme = 'Frank';
        mb.LastName = 'Köpsell';
        mb.Email = 'witte@amstammtisch.de';
        mb.MaklerBetreuer_E_Mail__c = 'witte@amstammtisch.de';
        mb.Gesch_ftsbeziehung__c = 'Versicherungsmakler';
        mb.Phone = '0511123123';
        mb.MailingStreet = 'Lister Meile 45';
        mb.MailingPostalCode = '30159';
        mb.MailingCity = 'Hannover';
        mb.BirthDate = Date.today()-12000;
        mb.Ist_Maklerbetreuer_WH__c = true;
        mb.ErhaeltErfolgsabhaengigeProvision__c = true;
        insert mb;
        Account acc3 = new Account();
        acc3.Name = 'WH Maklerbetreuer - Frank Köpsell';
        acc3.Email__c = 'witte@amstammtisch.de';
        acc3.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
        acc3.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
        acc3.BIC__c  = '1';
        acc3.Geschueftsfuehrer__c = mb.id;
        acc3.Gesetzliche_MwSt_auf_Provisionszahlung__c = 0.4;
        acc3.IBAN__c = 'DE43250501801900212158';
        acc3.Rechtsform__c = 'GbR';
        acc3.Unternehmensname__c = 'CareStone';
        insert acc3;
        mb.AccountId = acc3.Id;
        update mb;

        Contact potKun = new Contact();
        potKun.FirstName = 'Tvvsta';
        potKun.LastName = 'Tekoeeric';
        potKun.Email = 'test@tester.de';
        potKun.Phone = '0511123123';
        potKun.MailingStreet = 'Lister Meile 45';
        potKun.MailingPostalCode = '30159';
        potKun.MailingCity = 'Hannover';
        potKun.BirthDate = Date.today()-12000;
        insert potKun;

        Property__c immobilie = new Property__c();
        immobilie.Name = 'Immobilie';
        immobilie.Place__c = 'test';
        immobilie.Street__c = 'test2';
        immobilie.Zip_Code__c = '12312';
        immobilie.Unternehmensname__c = 'asd';
        immobilie.Gesch_ftsf_hrer__c = mb.id;
        immobilie.BIC__c = '123';
        immobilie.Amtsgericht__c = 'test';
        immobilie.HRB__c = '123';
        immobilie.Telefon__c = '05123123';
        immobilie.E_Mail__c = 'test@test.de';
        immobilie.Website__c = 'www.test.de';
        immobilie.PVNotarterminStattgefunden__c = true;
        insert immobilie;

        Appartment__c app2 = new Appartment__c();
        app2.Name = 'TestApp2';
        app2.Property__c = immobilie.Id;
        app2.Status__c = 'Available';
        app2.Area_sq_m__c = 63;
        insert app2;

        Provisionsverhandlung__c provisionsverhandlung = new Provisionsverhandlung__c();
        provisionsverhandlung.Immobilie__c = immobilie.Id;
        provisionsverhandlung.Grundprovision__c = 5.0;
        provisionsverhandlung.Verkaufsprovision__c = 1.5;
        provisionsverhandlung.Account__c = acc3.Id;
        insert provisionsverhandlung;

        Gutschrift_Laufnummer__c gutschriftLaufnummer = Gutschrift_Laufnummer__c.getOrgDefaults();
        gutschriftLaufnummer.Gutschrift_Laufnummer__c = 0;
        insert gutschriftLaufnummer;

        Gutschrift_Storno_Laufnummer__c gutschriftStornoLaufnummer = Gutschrift_Storno_Laufnummer__c.getOrgDefaults();
        gutschriftStornoLaufnummer.Gutschrift_Storno_Laufnummer__c = 0;
        insert gutschriftStornoLaufnummer;

        MaBVRechnungLaufnummer__c maBVRechnungLaufnummer = MaBVRechnungLaufnummer__c.getOrgDefaults();
        maBVRechnungLaufnummer.Laufnummer__c = 0;
        insert maBVRechnungLaufnummer;

        DatevDebitorennummerKaeufer__c datevDebitorennummerKaeufer = DatevDebitorennummerKaeufer__c.getOrgDefaults();
        datevDebitorennummerKaeufer.DatevDebitorennummerKaeufer__c = 123456;
        insert datevDebitorennummerKaeufer;

        DatevKreditorennummer__c datevKreditorennummer = DatevKreditorennummer__c.getOrgDefaults();
        datevKreditorennummer.DatevKreditorennummer__c = 123456;
        insert datevKreditorennummer;
    }

    @isTest static void testMonthlyProv() {
        System.debug('test');
        Account acc3 = [SELECT Id FROM Account];
        Contact mb = [SELECT Id, OwnerId FROM Contact WHERE LastName = 'Köpsell'];
        Contact potKun = [SELECT Id FROM Contact WHERE LastName != 'Köpsell'];
        Property__c immobilie = [SELECT ID From Property__c];
        Appartment__c app2 = [SELECT ID From Appartment__c];
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test VKC2';
        opp2.AccountId = acc3.Id;
        opp2.Potenzieller_Kunde__c = potKun.Id;
        opp2.CloseDate = System.today().addDays(1);
        opp2.StageName = 'Reservierung angefragt';
        opp2.Immobilie__c = immobilie.Id;
        opp2.Appartement__c = app2.Id;
        opp2.Finanzierung__c = 'Finanzierung WH';
        opp2.Kaufdatum__c = System.Today();
        opp2.Makler__c = mb.Id;
        opp2.Immobilienberater__c = mb.Id;
        opp2.Abrechnung_ber__c = mb.Id;
        opp2.Maklerprovision__c = '4.5';
        opp2.Finanzierung_oder_Eigenkapitalnachweis__c = true;
        opp2.Nachweis_Barzahler__c = true;
        opp2.KV_eingegangen__c = true;
        opp2.Beratungsprotokoll__c = true;
        opp2.Risikobelehrung__c = true;

        opp2.Overhead_Empf_nger__c = mb.Id;
        opp2.beurkundeter_Kaufpreis__c = 123123.23;

        insert opp2;
        Provision__c prov = new Provision__c();
        prov.Verkaufschance__c = opp2.Id;
        prov.Makler__c = opp2.Makler__c;
        prov.Maklerbetreuer__c = mb.OwnerId;
        prov.Objekt__c = opp2.Immobilie__c;
        prov.Wohneinheit__c = opp2.Appartement__c;
        prov.Kunde__c = opp2.Potenzieller_Kunde__c;
        prov.Kaufpreis__c = opp2.Provisionsbasis__c;
        insert prov;
        opp2.StageName = 'Notartermin hat stattgefunden';
        opp2.Notartermin__c = Date.today();
        update opp2;
        Opportunity newOpp = [SELECT Id, Maklerprovision__c, PRovisionsbasis__c, Makler__c FROM Opportunity WHERE Id =:opp2.Id];
        newOPp.Maklerprovision__c = '5.5';
        newOpp.Provisionsbasis__c = 12323.32;
        newOpp.Makler__c = potKun.Id;
        newOpp.Immobilienberater__c = mb.Id;
        newOpp.Datum_Kaufpreis_bezahlt__c = Date.today();
        newOpp.Kaufpreis_bezahlt__c = true;
        update newOpp;

        Test.startTest();
        GenerateInternalCommissionSchedulable gcs = new GenerateInternalCommissionSchedulable('month');
        gcs.scheduleMe();
        Test.stopTest();
    }

    @isTest static void testYearlyProv() {
        System.debug('test');
        Account acc3 = [SELECT Id FROM Account];
        Contact mb = [SELECT Id, OwnerId FROM Contact WHERE LastName = 'Köpsell'];
        Contact potKun = [SELECT Id FROM Contact WHERE LastName != 'Köpsell'];
        Property__c immobilie = [SELECT ID From Property__c];
        Appartment__c app2 = [SELECT ID From Appartment__c];
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test VKC2';
        opp2.AccountId = acc3.Id;
        opp2.Potenzieller_Kunde__c = potKun.Id;
        opp2.CloseDate = System.today().addDays(1);
        opp2.StageName = 'Reservierung angefragt';
        opp2.Immobilie__c = immobilie.Id;
        opp2.Appartement__c = app2.Id;
        opp2.Finanzierung__c = 'Finanzierung WH';
        opp2.Kaufdatum__c = System.Today();
        opp2.Makler__c = mb.Id;
        opp2.Immobilienberater__c = mb.Id;
        opp2.Abrechnung_ber__c = mb.Id;
        opp2.Maklerprovision__c = '4.5';
        opp2.Finanzierung_oder_Eigenkapitalnachweis__c = true;
        opp2.Nachweis_Barzahler__c = true;
        opp2.KV_eingegangen__c = true;
        opp2.Beratungsprotokoll__c = true;
        opp2.Risikobelehrung__c = true;

        opp2.Overhead_Empf_nger__c = mb.Id;
        opp2.beurkundeter_Kaufpreis__c = 123123.23;

        insert opp2;
        Provision__c prov = new Provision__c();
        prov.Verkaufschance__c = opp2.Id;
        prov.Makler__c = opp2.Makler__c;
        prov.Maklerbetreuer__c = mb.OwnerId;
        prov.Objekt__c = opp2.Immobilie__c;
        prov.Wohneinheit__c = opp2.Appartement__c;
        prov.Kunde__c = opp2.Potenzieller_Kunde__c;
        prov.Kaufpreis__c = opp2.Provisionsbasis__c;
        insert prov;
        opp2.StageName = 'Notartermin hat stattgefunden';
        opp2.Notartermin__c = Date.today();
        update opp2;
        Opportunity newOpp = [SELECT Id, Maklerprovision__c, PRovisionsbasis__c, Makler__c FROM Opportunity WHERE Id =:opp2.Id];
        newOPp.Maklerprovision__c = '5.5';
        newOpp.Provisionsbasis__c = 12323.32;
        newOpp.Makler__c = potKun.Id;
        newOpp.Immobilienberater__c = mb.Id;
        update newOpp;

        Test.startTest();
        GenerateInternalCommissionSchedulable gcs = new GenerateInternalCommissionSchedulable('year');
        gcs.scheduleMe();
        Test.stopTest();
    }

    @isTest static void testQuarterlyProv() {
        System.debug('test');
        Account acc3 = [SELECT Id FROM Account];
        Contact mb = [SELECT Id, OwnerId FROM Contact WHERE LastName = 'Köpsell'];
        Contact potKun = [SELECT Id FROM Contact WHERE LastName != 'Köpsell'];
        Property__c immobilie = [SELECT ID From Property__c];
        Appartment__c app2 = [SELECT ID From Appartment__c];
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test VKC2';
        opp2.AccountId = acc3.Id;
        opp2.Potenzieller_Kunde__c = potKun.Id;
        opp2.CloseDate = System.today().addDays(1);
        opp2.StageName = 'Reservierung angefragt';
        opp2.Immobilie__c = immobilie.Id;
        opp2.Appartement__c = app2.Id;
        opp2.Finanzierung__c = 'Finanzierung WH';
        opp2.Kaufdatum__c = System.Today();
        opp2.Makler__c = mb.Id;
        opp2.Immobilienberater__c = mb.Id;
        opp2.Abrechnung_ber__c = mb.Id;
        opp2.Maklerprovision__c = '4.5';
        opp2.Finanzierung_oder_Eigenkapitalnachweis__c = true;
        opp2.Nachweis_Barzahler__c = true;
        opp2.KV_eingegangen__c = true;
        opp2.Beratungsprotokoll__c = true;
        opp2.Risikobelehrung__c = true;

        opp2.Overhead_Empf_nger__c = mb.Id;
        opp2.beurkundeter_Kaufpreis__c = 123123.23;

        insert opp2;
        Provision__c prov = new Provision__c();
        prov.Verkaufschance__c = opp2.Id;
        prov.Makler__c = opp2.Makler__c;
        prov.Maklerbetreuer__c = mb.OwnerId;
        prov.Objekt__c = opp2.Immobilie__c;
        prov.Wohneinheit__c = opp2.Appartement__c;
        prov.Kunde__c = opp2.Potenzieller_Kunde__c;
        prov.Kaufpreis__c = opp2.Provisionsbasis__c;
        insert prov;
        opp2.StageName = 'Notartermin hat stattgefunden';
        opp2.Notartermin__c = Date.today();
        update opp2;
        Opportunity newOpp = [SELECT Id, Maklerprovision__c, PRovisionsbasis__c, Makler__c FROM Opportunity WHERE Id =:opp2.Id];
        newOPp.Maklerprovision__c = '5.5';
        newOpp.Provisionsbasis__c = 12323.32;
        newOpp.Makler__c = potKun.Id;
        newOpp.Immobilienberater__c = mb.Id;
        update newOpp;

        Test.startTest();
        GenerateInternalCommissionSchedulable gcs = new GenerateInternalCommissionSchedulable('quarter');
        gcs.scheduleMe();
        Test.stopTest();
    }

    @isTest static void test_update_prov2() {
        System.debug('test');
        Account acc3 = [SELECT Id FROM Account];
        Contact mb = [SELECT Id, OwnerId FROM Contact WHERE LastName = 'Köpsell'];
        mb.Gesch_ftsbeziehung__c = null;
        update mb;
        Contact potKun = [SELECT Id FROM Contact WHERE LastName != 'Köpsell'];
        Property__c immobilie = [SELECT ID From Property__c];
        Appartment__c app2 = [SELECT ID From Appartment__c];
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test VKC2';
        opp2.AccountId = acc3.Id;
        opp2.Potenzieller_Kunde__c = potKun.Id;
        opp2.CloseDate = System.today().addDays(1);
        opp2.StageName = 'Reservierung angefragt';
        opp2.Immobilie__c = immobilie.Id;
        opp2.Appartement__c = app2.Id;
        opp2.Finanzierung__c = 'Finanzierung WH';
        opp2.Kaufdatum__c = System.Today();
        opp2.Makler__c = mb.Id;
        opp2.Immobilienberater__c = mb.Id;
        opp2.Maklerprovision__c = '4.5';
        opp2.Finanzierung_oder_Eigenkapitalnachweis__c = true;
        opp2.Nachweis_Barzahler__c = true;
        opp2.KV_eingegangen__c = true;
        opp2.Beratungsprotokoll__c = true;
        opp2.Risikobelehrung__c = true;

        opp2.Overhead_Empf_nger__c = mb.Id;
        opp2.beurkundeter_Kaufpreis__c = 123123.23;

        Test.startTest();
        insert opp2;
        Provision__c prov = new Provision__c();
        prov.Verkaufschance__c = opp2.Id;
        prov.Makler__c = opp2.Makler__c;
        prov.Objekt__c = opp2.Immobilie__c;
        prov.Maklerbetreuer__c = mb.OwnerId;
        prov.Wohneinheit__c = opp2.Appartement__c;
        prov.Kunde__c = opp2.Potenzieller_Kunde__c;
        prov.Kaufpreis__c = opp2.Provisionsbasis__c;
        insert prov;
        opp2.StageName = 'Notartermin hat stattgefunden';
        update opp2;
        Test.stopTest();
        Opportunity newOpp = [SELECT Id, Maklerprovision__c, PRovisionsbasis__c, Makler__c FROM Opportunity WHERE Id =:opp2.Id];
        newOPp.Maklerprovision__c = '5.5';
        newOpp.Provisionsbasis__c = 12323.32;
        newOpp.Makler__c = potKun.Id;
        newOpp.Immobilienberater__c = mb.Id;
        update newOpp;

        System.debug(LoggingLevel.ERROR,[SELECT Id FROM Provision__c WHERE Verkaufschance__c =: opp2.Id].size());

    }

    @isTest static void testProvisionDeletion() {
        Account acc3 = [SELECT Id FROM Account];
        Contact mb = [SELECT Id, OwnerId FROM Contact WHERE LastName = 'Köpsell'];
        Contact potKun = [SELECT Id FROM Contact WHERE LastName != 'Köpsell'];
        Property__c immobilie = [SELECT ID From Property__c];
        Appartment__c app2 = [SELECT ID From Appartment__c];
    
        Opportunity opp2 = new Opportunity(
            Name = 'Test VKC Delete',
            AccountId = acc3.Id,
            Potenzieller_Kunde__c = potKun.Id,
            CloseDate = System.today().addDays(1),
            StageName = 'Reservierung angefragt',
            Immobilie__c = immobilie.Id,
            Appartement__c = app2.Id,
            Finanzierung__c = 'Finanzierung WH',
            Kaufdatum__c = System.Today(),
            Makler__c = mb.Id,
            Immobilienberater__c = mb.Id,
            Abrechnung_ber__c = mb.Id,
            Maklerprovision__c = '4.5',
            Finanzierung_oder_Eigenkapitalnachweis__c = true,
            Nachweis_Barzahler__c = true,
            KV_eingegangen__c = true,
            Beratungsprotokoll__c = true,
            Risikobelehrung__c = true,
            Overhead_Empf_nger__c = mb.Id,
            beurkundeter_Kaufpreis__c = 123123.23
        );
        insert opp2;
    
        opp2.StageName = 'Notartermin hat stattgefunden';
        opp2.Notartermin__c = Date.today();
        update opp2;
    
        // Create provision manually
        Provision__c prov = new Provision__c(
            Verkaufschance__c = opp2.Id,
            Makler__c = opp2.Makler__c,
            Maklerbetreuer__c = mb.OwnerId,
            Objekt__c = opp2.Immobilie__c,
            Wohneinheit__c = opp2.Appartement__c,
            Kunde__c = opp2.Potenzieller_Kunde__c,
            Kaufpreis__c = opp2.beurkundeter_Kaufpreis__c,
            ErfolgsabhaengigeProvisionInProzent__c = 3,
            Erfolgsabh_ngige_Provision_direkt__c = 5000,
            ProvisionsvoraussetzungenErfuelltAm__c = Date.today()
        );
        insert prov;
    
        Test.startTest();
        opp2.StageName = 'Geschlossen und verloren';
        opp2.Grund_VKC_verloren__c = 'Aus TeamProQ storniert';
        update opp2;
        Test.stopTest();
    
        List<Provision__c> provs = [SELECT Id FROM Provision__c WHERE Verkaufschance__c = :opp2.Id];
        System.assertEquals(0, provs.size(), 'Provision should have been deleted.');
    }
    

    @isTest static void testProvisionCorrectionInsert() {
        Account acc3 = [SELECT Id FROM Account];
        Contact mb = [SELECT Id, OwnerId FROM Contact WHERE LastName = 'Köpsell'];
        Contact potKun = [SELECT Id FROM Contact WHERE LastName != 'Köpsell'];
        Property__c immobilie = [SELECT ID From Property__c];
        Appartment__c app2 = [SELECT ID From Appartment__c];
    
        Opportunity opp2 = new Opportunity(
            Name = 'Test VKC Insert',
            AccountId = acc3.Id,
            Potenzieller_Kunde__c = potKun.Id,
            CloseDate = System.today().addDays(1),
            StageName = 'Reservierung angefragt',
            Immobilie__c = immobilie.Id,
            Appartement__c = app2.Id,
            Finanzierung__c = 'Finanzierung WH',
            Kaufdatum__c = System.Today(),
            Makler__c = mb.Id,
            Immobilienberater__c = mb.Id,
            Abrechnung_ber__c = mb.Id,
            Maklerprovision__c = '4.5',
            Finanzierung_oder_Eigenkapitalnachweis__c = true,
            Nachweis_Barzahler__c = true,
            KV_eingegangen__c = true,
            Beratungsprotokoll__c = true,
            Risikobelehrung__c = true,
            Overhead_Empf_nger__c = mb.Id,
            beurkundeter_Kaufpreis__c = 123123.23
        );
        insert opp2;
    
        opp2.StageName = 'Notartermin hat stattgefunden';
        opp2.Notartermin__c = Date.today();
        update opp2;
    
        // Create provision manually
        Provision__c prov = new Provision__c(
            Verkaufschance__c = opp2.Id,
            Makler__c = opp2.Makler__c,
            Maklerbetreuer__c = mb.OwnerId,
            Objekt__c = opp2.Immobilie__c,
            Wohneinheit__c = opp2.Appartement__c,
            Kunde__c = opp2.Potenzieller_Kunde__c,
            Kaufpreis__c = opp2.beurkundeter_Kaufpreis__c,
            ErfolgsabhaengigeProvisionInProzent__c = 3,
            Erfolgsabh_ngige_Provision_direkt__c = 5000,
            ProvisionsvoraussetzungenErfuelltAm__c = Date.today().addMonths(-2)
        );
        insert prov;
    
        Test.startTest();
        opp2.StageName = 'Geschlossen und verloren';
        opp2.Grund_VKC_verloren__c = 'Aus TeamProQ storniert';
        update opp2;
        Test.stopTest();
    
        List<Provision__c> provs = [SELECT Id, UniqueId__c FROM Provision__c WHERE Verkaufschance__c = :opp2.Id];
        System.assertEquals(2, provs.size(), 'There should be two provisions now: original and correction.');
    
        Boolean correctionExists = false;
        for (Provision__c p : provs) {
            if (p.UniqueId__c != null && p.UniqueId__c.contains('-correction')) {
                correctionExists = true;
            }
        }
        System.assert(correctionExists, 'Correction provision should exist.');
    }
    
    
}