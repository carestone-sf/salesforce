@isTest
private class
TestOpportunity {

    @testSetup static void test_setup() {
        Contact mb = new Contact();
        mb.FirstNAme = 'Frank';
        mb.LastName = 'Köpsell';
        mb.Email = 'witte@amstammtisch.de';
        mb.MaklerBetreuer_E_Mail__c = 'witte@amstammtisch.de';
        mb.Phone = '0511123123';
        mb.MailingStreet = 'Lister Meile 45';
        mb.MailingPostalCode = '30159';
        mb.MailingCity = 'Hannover';
        mb.BirthDate = Date.today()-12000;
        insert mb;
        Account acc3 = new Account();
        acc3.Name = 'WH Maklerbetreuer - Frank Köpsell';
        acc3.Email__c = 'witte@amstammtisch.de';
        acc3.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
        acc3.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
        acc3.BIC__c  = '1';
        acc3.Geschueftsfuehrer__c = mb.id;
        acc3.Gesetzliche_MwSt_auf_Provisionszahlung__c = 0.4;
        acc3.Hinweis_zur_MwSt__c = 'Vertrag';
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
        immobilie.Purchase_Price_sqm__c = 1500;
        immobilie.Property_Price__c = 1500000;
        immobilie.Surface_Object_sqm__c = 2500;
        immobilie.Repayment_Beginning__c = Date.Today() + 180;
        immobilie.Arrival__c = Date.Today() + 180;
        immobilie.Rent_Long_Term_sqm__c = 10.5;
        immobilie.GutschriftenSachkonto__c = '159350';
        insert immobilie;

        immobilie.AktenStatusDms__c = 'Entwicklung (Aktiv)';
        update immobilie;

        Appartment__c app2 = new Appartment__c();
        app2.Name = 'TestApp2';
        app2.Property__c = immobilie.Id;
        app2.Status__c = 'Available';
        app2.Area_sq_m__c = 63;
        app2.Purchase_Price__c = 150000;
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
        datevDebitorennummerKaeufer.DatevDebitorennummerKaeufer__c = 3000000;
        insert datevDebitorennummerKaeufer;

        DatevKreditorennummer__c datevKreditorennummer = DatevKreditorennummer__c.getOrgDefaults();
        datevKreditorennummer.DatevKreditorennummer__c = 8500000;
        insert datevKreditorennummer;

        DATEV1__Settings__c datevSettings = DATEV1__Settings__c.getOrgDefaults();
        datevSettings.DATEV1__AccountLength__c = 6;
        insert datevSettings;
    }

    @isTest static void test_method_one() {
        Account acc3 = [SELECT Id FROM Account];
        Contact mb = [SELECT Id FROM Contact WHERE LastName = 'Köpsell'];
        Contact potKun = [SELECT Id FROM Contact WHERE LastName != 'Köpsell'];
        Property__c immobilie = [SELECT ID From Property__c];
        Appartment__c app2 = [SELECT ID From Appartment__c];

        Opportunity opp = new Opportunity();
        opp.Name = 'Test VKC';
        opp.AccountId = acc3.Id;
        opp.Makler__c = mb.Id;
        opp.Potenzieller_Kunde__c = potKun.Id;
        opp.CloseDate = System.today().addDays(1);
        opp.StageName = 'Available';
        opp.Immobilie__c = immobilie.Id;
        opp.Appartement__c = app2.Id;
        opp.Finanzierung__c = 'Barzahler';
        Test.startTest();
        insert opp;
        Test.stopTest();

        Provisionsverhandlung__c provisionsverhandlung = [SELECT Grundprovision__c, Verkaufsprovision__c FROM Provisionsverhandlung__c];
        provisionsverhandlung.Grundprovision__c = 4.5;
        provisionsverhandlung.Verkaufsprovision__c = 2.0;
        update provisionsverhandlung;

        opp.StageName = 'VKC ausgelaufen';
        opp.Grund_VKC_verloren__c = 'Durch WH auf anderes Objekt umgestellt';
        update opp;

    }

    @isTest static void test_method_two() {
        Account acc3 = [SELECT Id FROM Account];
        List<Contact> cons = [SELECT Id, FirstName FROM Contact];
        Contact mb = new Contact();
        Contact potKun = new Contact();
        for(Contact con:cons)
        {
            if(con.FirstName == 'Frank')
            {
                mb = con;
            }
            else {
                potKun = con;
            }
        }

        Property__c immobilie = [SELECT ID From Property__c];
        Appartment__c app = [SELECT ID From Appartment__c];
        Appartment__c app3 = new Appartment__c();
        app3.Name = 'TestApp3';
        app3.Property__c = immobilie.Id;
        app3.Status__c = 'Available';
        app3.Area_sq_m__c = 63;
        insert app3;

        Test.startTest();
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test VKC2';
        opp2.AccountId = acc3.Id;
        opp2.Makler__c = mb.Id;
        opp2.Potenzieller_Kunde__c = potKun.Id;
        opp2.CloseDate = System.today().addDays(1);
        opp2.StageName = 'Reservierung angefragt';
        opp2.Immobilie__c = immobilie.Id;
        opp2.Appartement__c = app.Id;
        opp2.Finanzierung__c = 'Barzahler';
        opp2.Kaufdatum__c = System.Today();
        insert opp2;

        opp2.StageName = 'VKC ausgelaufen';
        opp2.Grund_VKC_verloren__c = 'Durch WH auf anderes Objekt umgestellt';
        update opp2;

        opp2.Appartement__c = app3.Id;
        update opp2;
        Test.stopTest();

    }

    @isTest static void test_method_three() {

        Account acc3 = [SELECT Id FROM Account];
        Contact mb = [SELECT Id, Email FROM Contact WHERE LastName = 'Köpsell'];
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
        opp2.Finanzierung__c = 'Barzahler';
        opp2.Kaufdatum__c = System.Today();
        opp2.Makler__c = mb.Id;
        opp2.Immobilienberater__c = mb.Id;
        opp2.Maklerprovision__c = '4.5';
        opp2.Verk_ufer_Beratungsprovision__c = '1.5';
        insert opp2;

        Test.startTest();

        opp2.StageName = 'Geschlossene und gewonnene';
        opp2.beurkundeter_Kaufpreis__c = 123123.23;
        update opp2;

        Provision__c provision = new Provision__c();
        provision.Makler__c = mb.Id;
        provision.E_Mail__c = mb.Email;
        provision.Ausl_ser__c = mb.Id;
        provision.Kaufpreis__c = opp2.Provisionsbasis__c;
        provision.Wert_Maklerprovision__c = 8500;
        provision.Verkaufschance__c = opp2.Id;
        provision.Maklerbetreuer__c = '005b0000001V30P';
        insert provision;

        provision.GutschriftBestaetigt__c = true;
        update provision;

        List<ResolveApprovalRequest.Requests> requests = new List<ResolveApprovalRequest.Requests>();
        ResolveApprovalRequest.Requests req = new ResolveApprovalRequest.Requests();
        req.action = 'Approve';
        req.comments = 'Test Comments';
        req.recordId = provision.Id;
        req.objName = 'Provision__c';
        List<ProcessInstanceWorkitem> workItems = [Select p.Id, p.ProcessInstance.TargetObjectId from ProcessInstanceWorkitem p];
        req.approvalRequestId = workItems[0].Id;

        // Add req to requests
        requests.add(req);

        // Run Test
        ResolveApprovalRequest.execute(requests);

        Gutschrift__c gs = [SELECT Id FROM Gutschrift__c];
        gs.ZuDatevUebertragen__c = true;
        update gs;

        Document doc;
        doc = new Document();
        doc.Name = 'opos.csv';
        doc.Body =  Blob.valueOf('Konto;Gegenkonto;Belegdatum;Belegfeld 1;Belegfeld 2;Umsatz Soll;Umsatz Haben;Stapel-Nr.;BSNr;BU-Schl¸ssel;Buchungstext;Steuersatz;WKZ eingeg. Umsatz;Eingeg. Umsatz;Kurs;Herkunft-Kz;Buchungs GUID;Leistungsdatum;Generalumkehr (GU);Beleginfo - Art 1;Beleginfo - Inhalt 1;Beleginfo - Art 2;Beleginfo - Inhalt 2;Beleginfo - Art 3;Beleginfo - Inhalt 3;Beleginfo - Inhalt 4\n120000;8100002;06.01.2022;"GS20220019";"001";0,00;19.408,31;"01-2022/0003";1;"";"";0,00;"EUR";0,00;0,000000;"RE";"f5d43f89-88e5-457f-992d-a0d62eba3731";;0;"D_KontoauszugText";"EREF+2301021445-0000001    KREF+2301021445            SVWZ+RNR 108/2022 DATUM 08.12.2022 OBJEKT LEUNA";"D_KontoauszugText";"Bu.Tag 02.01.2023 Valuta 02.01.2023 Umsatz EUR-365000,00 AB EUR+3239905,92 EB EUR+2972821,98 Gesch.partner ""TERRAFORM CONSTRUKTION GMBH"" BLZ 80053762 Konto ""1894113264"" GVCode ""116""";"D_KontoauszugText";"GV ""SEPA Credit Transfer (Einzelbuchung-Soll)"" PN ""       930"" Kd.Ref. ""NONREF"" Text ""EINZELUEBERWEISUNG"" IBAN ""DE03800537621894113264"" BIC ""NOLADE21HAL""";""');
        doc.FolderId = '00l67000001J3k7';
        //doc.FolderId = '00l5E000000YP3X';
        doc.Type = 'csv';
        doc.ContentType='text/csv; charset=utf-8';
        insert doc;

        ScheduledOposSync.syncOposAndInvoices();

        provision.GutschriftStorniert__c = true;
        update provision;

//        List<Provision__c> provisionen = [SELECT GutschriftBestaetigt__c FROM Provision__c];
//        Provision__c provision = provisionen.get(0);
//        provision.GutschriftBestaetigt__c = true;
//        update provision;
        Test.stopTest();

    }

    @isTest static void test_method_four() {
        Account acc3 = [SELECT Id FROM Account];
        List<Contact> cons = [SELECT Id, FirstName FROM Contact];
        Contact mb = new Contact();
        Contact potKun = new Contact();
        for(Contact con:cons)
        {
            if(con.FirstName == 'Frank')
            {
                mb = con;
            }
            else {
                potKun = con;
            }
        }
        Test.startTest();
        Property__c immobilie = [SELECT ID From Property__c];
        Appartment__c app = [SELECT ID From Appartment__c];

        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test VKC2';
        opp2.AccountId = acc3.Id;
        opp2.Makler__c = mb.Id;
        opp2.Potenzieller_Kunde__c = potKun.Id;
        opp2.CloseDate = System.today().addDays(1);
        opp2.StageName = 'Closed and won';
        opp2.Immobilie__c = immobilie.Id;
        opp2.Appartement__c = app.Id;
        opp2.Finanzierung__c = 'Barzahler';
        opp2.Kaufdatum__c = System.Today();
        insert opp2;

        opp2.StageName = 'Kaufvertragsangebot abgegeben';
        update opp2;
        Test.stopTest();

    }


}