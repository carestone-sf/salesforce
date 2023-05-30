@IsTest
public with sharing class TestMaBVRechnungen {

    @TestSetup
    static void makeData(){
        Sandbox sb = new Sandbox();
        sb.runApexClass(null);
        
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
        datevDebitorennummerKaeufer.DatevDebitorennummerKaeufer__c = 3000000;
        insert datevDebitorennummerKaeufer;

        DatevKreditorennummer__c datevKreditorennummer = DatevKreditorennummer__c.getOrgDefaults();
        datevKreditorennummer.DatevKreditorennummer__c = 1234567;
        insert datevKreditorennummer;

        DATEV1__Settings__c datevSettings = DATEV1__Settings__c.getOrgDefaults();
        datevSettings.DATEV1__AccountLength__c = 6;
        insert datevSettings;
    }

    // Tests missing MaBV Abrechnungsdaten 
    // Validation rule: Bautraeger_Pflichtangaben
    public static testMethod void testMissingAccountData() {
        Contact mb = new Contact();
        mb.FirstNAme = 'Frank';
        mb.LastName = 'Köpsell';
        mb.Email = 'witte@amstammtisch.de';
        mb.MaklerBetreuer_E_Mail__c = 'witte@amstammtisch.de';
        insert mb;
        Account acc = new Account();
        acc.Name = 'WH Maklerbetreuer - Frank Köpsell';
        acc.Email__c = 'witte@amstammtisch.de';
        acc.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
        acc.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
        acc.BIC__c  = '1';
        acc.GeschaeftsfuehrerNeu__c = 'Frank Köpsell';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PropertyDeveloper').getRecordTypeId();

        String message;
        Test.startTest();
        try {
            insert acc;
        } catch(Exception e) {
            message = e.getMessage();
        }
        Test.stopTest();

        System.Assert(message.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    }

    // Tests missing MaBV Abrechnungsdaten 
    // Validation rule: Veroeffentlichung_MaBV_Objekt
    public static testMethod void testMissingPropertyData() {
        Property__c immobilie = new Property__c();
        immobilie.Name = 'Essen-Kettwig – Pflege';
        immobilie.Place__c = 'test';
        immobilie.Street__c = 'test2';
        immobilie.Zip_Code__c = '12312';
        immobilie.State__c = 'Niedersachsen';
        immobilie.Bank__c = 'Sparkasse';
        immobilie.IBAN__c = 'DE124943103936283819';
        immobilie.BIC__c = 'SPKHDE2HXXX';
        immobilie.Telefon__c = '05123123';
        immobilie.E_Mail__c = 'test@test.de';
        immobilie.Website__c = 'www.test.de';
        immobilie.Purchase_Price_sqm__c = 1500;
        immobilie.Property_Price__c = 1500000;
        immobilie.Surface_Object_sqm__c = 2500;
        immobilie.Repayment_Beginning__c = Date.Today() + 180;
        immobilie.Arrival__c = Date.Today() + 180;
        immobilie.Rent_Long_Term_sqm__c = 10.5;
        immobilie.Is_Public__c = true;
        immobilie.MaBVRechnungenUeberSalesforce__c = true;
        immobilie.ZahlungszielInTagen__c = 14;

        String message;
        Test.startTest();
        try {
            insert immobilie;
        } catch(Exception e) {
            message = e.getMessage();
        }
        Test.stopTest();

        System.Assert(message.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    }

    public static testMethod void testMissingOpportunityData() {
        Opportunity opp = [SELECT Id, Immobilie__c FROM Opportunity WHERE StageName = 'Geschlossene und gewonnene' LIMIT 1];
        Property__c immobilie = [SELECT Id FROM Property__c WHERE Id = :opp.Immobilie__c];
        immobilie.MaBVRechnungenUeberSalesforce__c = true;
        update immobilie;

        opp.Kaufpreis_f_llig__c = true;
        String message;
        Test.startTest();
        try {
            update opp;
        } catch(Exception e) {
            message = e.getMessage();
        }
        Test.stopTest();

        System.Assert(message.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
    }

    public static testMethod void testMaBVRechnungCreation() {
        Opportunity opp = [SELECT Id, Immobilie__c, Immobilie__r.Objektnummer__c, Appartement__r.ApartmentNummer__c FROM Opportunity WHERE StageName = 'Geschlossene und gewonnene' LIMIT 1];
        String rechnungsNummer = opp.Immobilie__r.Objektnummer__c + '-' + opp.Appartement__r.ApartmentNummer__c;
        Property__c immobilie = [SELECT Id FROM Property__c WHERE Id = :opp.Immobilie__c];
        immobilie.MaBVRechnungenUeberSalesforce__c = true;
        update immobilie;

        MaBVRate__c maBVRate = new MaBVRate__c();
        maBVRate.Faelligkeitsdatum__c = Date.Today() - 1;
        maBVRate.Immobilie__c = immobilie.Id;
        maBVRate.Leistung__c = 'Test Leistung';
        maBVRate.LeistungszeitraumVon__c = Date.Today()-32;
        maBVRate.LeistungszeitraumBis__c = Date.Today()-2;
        maBVRate.Name = '1. MaBV Rate';
        maBVRate.RateInPercentage__c = 5.0;
        maBVRate.RateNummer__c = '1';
        maBVRate.SicherheitseinbehaltInPercentage__c = 3;

        MaBVRate__c maBVRate2 = new MaBVRate__c();
        maBVRate2.Faelligkeitsdatum__c = Date.Today() - 1;
        maBVRate2.Immobilie__c = immobilie.Id;
        maBVRate2.Leistung__c = 'Test Leistung 2';
        maBVRate2.LeistungszeitraumVon__c = Date.Today()-32;
        maBVRate2.LeistungszeitraumBis__c = Date.Today()-2;
        maBVRate2.Name = '2. MaBV Rate';
        maBVRate2.PreisanpassungInPercent__c = -3.0;
        maBVRate2.RateInPercentage__c = 4.0;
        maBVRate2.RateNummer__c = '2';

        MaBVRate__c maBVRate3 = new MaBVRate__c();
        maBVRate3.Faelligkeitsdatum__c = Date.Today() + 32;
        maBVRate3.Immobilie__c = immobilie.Id;
        maBVRate3.Leistung__c = 'Test Leistung 3';
        maBVRate3.LeistungszeitraumVon__c = Date.Today()+1;
        maBVRate3.LeistungszeitraumBis__c = Date.Today()+31;
        maBVRate3.Name = '3. MaBV Rate';
        maBVRate3.RateInPercentage__c = 7.0;
        maBVRate3.RateNummer__c = '3';

        MaBVRate__c maBVRate4 = new MaBVRate__c();
        maBVRate4.Faelligkeitsdatum__c = Date.Today() - 1;
        maBVRate4.Immobilie__c = immobilie.Id;
        maBVRate4.Leistung__c = 'Test Leistung 4';
        maBVRate4.LeistungszeitraumVon__c = Date.Today()-32;
        maBVRate4.LeistungszeitraumBis__c = Date.Today()-2;
        maBVRate4.Name = '4. MaBV Rate';
        maBVRate4.RateInPercentage__c = 5.0;
        maBVRate4.RateNummer__c = '4';
        maBVRate4.SicherheitPlusInPercentage__c = 3;

        opp.Kaufdatum__c = Date.today();
        opp.Notartermin__c = Date.today();
        opp.UrkundennummerKaufvertrag__c = 'UR 119/132';
        opp.Kaufpreis_f_llig__c = true;

        Document doc;
        doc = new Document();
        doc.Name = 'opos.csv';
        doc.Body =  Blob.valueOf('Konto;Gegenkonto;Belegdatum;Belegfeld 1;Belegfeld 2;Umsatz Soll;Umsatz Haben;Stapel-Nr.;BSNr;BU-Schl¸ssel;Buchungstext;Steuersatz;WKZ eingeg. Umsatz;Eingeg. Umsatz;Kurs;Herkunft-Kz;Buchungs GUID;Leistungsdatum;Generalumkehr (GU);Beleginfo - Art 1;Beleginfo - Inhalt 1;Beleginfo - Art 2;Beleginfo - Inhalt 2;Beleginfo - Art 3;Beleginfo - Inhalt 3;Beleginfo - Inhalt 4\n122000;3000204;24.01.2022;"' + rechnungsNummer + '-1-1";"3000204";44.904,50;0,00;"01-2022/0004";2;"";"Weyhausen/ZE/1. Rate/WE 001 Maras";0,00;"EUR";0,00;0,000000;"RE";"765b2085-9333-4352-b7be-401c141df77c";;0;"D_KontoauszugText";"EREF+2301021445-0000001    KREF+2301021445            SVWZ+RNR 108/2022 DATUM 08.12.2022 OBJEKT LEUNA";"D_KontoauszugText";"Bu.Tag 02.01.2023 Valuta 02.01.2023 Umsatz EUR-365000,00 AB EUR+3239905,92 EB EUR+2972821,98 Gesch.partner ""TERRAFORM CONSTRUKTION GMBH"" BLZ 80053762 Konto ""1894113264"" GVCode ""116""";"D_KontoauszugText";"GV ""SEPA Credit Transfer (Einzelbuchung-Soll)"" PN ""       930"" Kd.Ref. ""NONREF"" Text ""EINZELUEBERWEISUNG"" IBAN ""DE03800537621894113264"" BIC ""NOLADE21HAL""";""\n122000;3000204;24.01.2022;"476-001-2-1";"3000204";50.293,04;0,00;"01-2022/0004";3;"";"Weyhausen/ZE/2. Rate/WE 001 Maras";0,00;"EUR";0,00;0,000000;"RE";"fc520912-323a-4cf7-8786-3c9dbace5e83";;0;"D_KontoauszugText";"EREF+2301021445-0000001    KREF+2301021445            SVWZ+RNR 108/2022 DATUM 08.12.2022 OBJEKT LEUNA";"D_KontoauszugText";"D_KontoauszugText";"Bu.Tag 02.01.2023 Valuta 02.01.2023 Umsatz EUR-365000,00 AB EUR+3239905,92 EB EUR+2972821,98 Gesch.partner ""TERRAFORM CONSTRUKTION GMBH"" BLZ 80053762 Konto ""1894113264"" GVCode ""116""";"D_KontoauszugText";"GV ""SEPA Credit Transfer (Einzelbuchung-Soll)"" PN ""       930"" Kd.Ref. ""NONREF"" Text ""EINZELUEBERWEISUNG"" IBAN ""DE03800537621894113264"" BIC ""NOLADE21HAL""";""\n120011;172250;31.05.2022;"'+ rechnungsNummer + '-2-1";"3001896";26.614,00;0,00;"05-2022/0002";32;"";"ZE Anteil/Nörten-Hardenberg/WE 030 Racs";0,00;"EUR";0,00;0,000000;"RE";"9c596ca6-b03d-4c2d-aad6-c739d2031275";;0;"D_KontoauszugText";"EREF+2301021445-0000001    KREF+2301021445            SVWZ+RNR 108/2022 DATUM 08.12.2022 OBJEKT LEUNA";"D_KontoauszugText";"Bu.Tag 02.01.2023 Valuta 02.01.2023 Umsatz EUR-365000,00 AB EUR+3239905,92 EB EUR+2972821,98 Gesch.partner ""TERRAFORM CONSTRUKTION GMBH"" BLZ 80053762 Konto ""1894113264"" GVCode ""116""";"D_KontoauszugText";"GV ""SEPA Credit Transfer (Einzelbuchung-Soll)"" PN ""       930"" Kd.Ref. ""NONREF"" Text ""EINZELUEBERWEISUNG"" IBAN ""DE03800537621894113264"" BIC ""NOLADE21HAL""";""');
        doc.FolderId = '00l67000001J3k7';//Live
        doc.Type = 'csv';
        doc.ContentType='text/csv; charset=utf-8';
        insert doc;
        
        Test.startTest();
        insert maBVRate;
        insert maBVRate2;
        insert maBVRate3;
        update opp;
        insert maBVRate4;
        ScheduledOposSync.syncOposAndInvoices();
        Test.stopTest();

        List<MaBVRechnung__c> maBVRechnungen = [SELECT Id, MaBVRechnungMaster__r.MaBVRate__c FROM MaBVRechnung__c];
        System.assertEquals(3, mabvRechnungen.size());

        for(MaBVRechnung__c mabvRechnung:maBVRechnungen) {
            mabvRechnung.ZuDatevUebertragen__c = true;
            if(mabvRechnung.MaBVRechnungMaster__r.MaBVRate__c == mabvRate2.Id) {
                mabvRechnung.Rechnungsdatum__c = Date.today() - 50;
            }
        }
        update maBVRechnungen;
        DateTime dt = System.Now().addHours(-2);
        List<Document> oposDocuments = [SELECT Id, Body FROM Document WHERE Folder.Name = 'opos' AND CreatedDate >= :dt];
        ScheduledOposSync.syncOposAndInvoicesForDocuments(oposDocuments);

        MaBVRechnungMaster__c maBVRechnungMaster = [SELECT RechnungWurdeStorniert__c FROM MaBVRechnungMaster__c LIMIT 1];
        maBVRechnungMaster.RechnungWurdeStorniert__c = true;
        update maBVRechnungMaster;

        List<Id> mabvRechnungIds = new List<Id>{maBVRechnungen[1].Id};
        MaBVMahnungenBatch mmb = new MaBVMahnungenBatch(mabvRechnungIds);
        Database.executeBatch(mmb, 50);

        maBVRate3.Faelligkeitsdatum__c = Date.Today() + 33;
        update maBVRate3;

        Zahlung__c zahlung = [SELECT ID, IBAN__c, BIC__c, BusinessPartner__c, AccountingText__c FROM Zahlung__c LIMIT 1];
        System.assertEquals('DE03800537621894113264', zahlung.IBAN__c);
        System.assertEquals('NOLADE21HAL', zahlung.BIC__c);
        System.assertEquals('TERRAFORM CONSTRUKTION GMBH', zahlung.BusinessPartner__c);
    }
}