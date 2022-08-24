@IsTest
public with sharing class TestDataFactory {

    public static void createDatevSettings() {
        insert new DATEV1__Settings__c(
            DATEV1__AccountLength__c = 6
        );
    }

    public static User createTestuser(Boolean doInsert) {
        User user = new User();

        if(doInsert) {
            insert user;
        }

        return user;
    }
    
    public static Account createAccount(Boolean doInsert) {
        Account acc = new Account();

        acc.Name = 'Makler GmbH ';
        acc.Email__c = 'f.witte@wirtschaftshaus.de';
        acc.BIC__c  = 'SPKHDE2HXXX';
        acc.GeschaeftsfuehrerNeu__c = 'Sandro Pawils';
        acc.Gesetzliche_MwSt_auf_Provisionszahlung__c = 0.4;
        acc.Hinweis_zur_MwSt__c = 'Vertrag';
        acc.IBAN__c = 'DE43250501801900212158';
        acc.Rechtsform__c = 'GbR';
        acc.Unternehmensname__c = 'CareStone';
        acc.Carestone_Vertriebsvereinbarung__c = true;
        acc.Dauerhaft_gesch_tzt__c = true;

        if(doInsert) {
            insert acc;
        }

        return acc;
    }

    public static Account createBautraeger(Boolean doInsert) {
        Account bautraeger = new Account();
        bautraeger.Name = 'Carestone Projekt GmbH';
        bautraeger.Gesch_ftsbeziehung__c = 'Bauträger';
        bautraeger.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
        bautraeger.BillingCity = 'Test Stadt';
        bautraeger.BillingStreet = 'Test Str. 12';
        bautraeger.BillingPostalCode = '30159';
        bautraeger.Email__c = 'f.witte@wirtschaftshaus.de';
        bautraeger.Phone = '113';
        bautraeger.Fax = '113';
        bautraeger.Website = 'https://carestone.com';
        bautraeger.UStd_Id__c = 'DE12345';
        bautraeger.Steuernummer__c = '24/231/113';
        bautraeger.GeschaeftsfuehrerNeu__c = 'Sandro Pawils';
        bautraeger.Rechtsform__c = 'GbR';
        bautraeger.Amtsgericht_bei_Kapitalgesellschaften__c = 'Amtsgericht Hannover';
        bautraeger.HRB_bei_Kapitalgesellschaften__c = 'HRB 210203';
        bautraeger.Datev_Mandantennummer__c = 113;
        bautraeger.Unternehmensname__c = 'CareStone';
        bautraeger.Dauerhaft_gesch_tzt__c = true;
        
        if(doInsert) {
            insert bautraeger;
        }
        return bautraeger;
    }

    public static Opportunity createOpportunity(Boolean doInsert, Id interessentId, Id maklerId, Id propertyId, Id appartmentId) {
        Contact makler = [SELECT Id, AccountId FROM Contact WHERE Id = :maklerId];

        Opportunity opp = new Opportunity();
        opp.Name = 'Offene VKC ';
        opp.AccountId = makler.AccountId;
        opp.Makler__c = makler.Id;
        opp.Potenzieller_Kunde__c = interessentId;
        opp.CloseDate = System.today().addDays(31);
        opp.StageName = 'Reserviert';
        opp.Immobilie__c = propertyId;
        opp.Appartement__c = appartmentId;
        opp.Finanzierung__c = 'Barzahler';

        if(doInsert) {
            insert opp;
        }
        
        return opp;
    }

    public static Contact createMakler(Boolean doInsert, Id accountId) {
        Contact con = new Contact();
        con.AccountId = accountId;
        con.Gesch_ftsbeziehung__c = 'Versicherungsmakler';
        con.FirstName = 'Max';
        con.MailingStreet = 'Teststr. 24';
        con.MailingCity = 'Hannover';
        con.MailingPostalCode = '30159';
        con.DatevDebitorenKundennummerKaeufer__c = '3000001';
        con.Maklerbetreuer_E_Mail__c = 'mathis@testx.dev';
        con.LastName = 'Maklermann ';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Makler').getRecordTypeId();
        
        if(doInsert) {
            insert con;
        }

        return con;
    }

    public static Contact createInteressent(Boolean doInsert, Id accountId) {
        Contact con = new Contact();
        con.AccountId = accountId;
        con.Gesch_ftsbeziehung__c = 'Interessent';
        con.FirstName = 'Max';
        con.MailingStreet = 'Teststr. 24';
        con.MailingCity = 'Hannover';
        con.MailingPostalCode = '30159';
        con.Maklerbetreuer_E_Mail__c = 'mathis@testx.dev';
        con.DatevDebitorenKundennummerKaeufer__c = '3000001';
        con.LastName = 'Interessentenmann ';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Interessent').getRecordTypeId();
        
        if(doInsert) {
            insert con;
        }

        return con;
    }

    public static Property__c createProperty(Boolean doInsert, Id bautraegerId) {
        Property__c immobilie = new Property__c();
        immobilie.Name = 'Immobilie ';
        immobilie.Place__c = 'test';
        immobilie.Street__c = 'test2';
        immobilie.Zip_Code__c = '12312';
        immobilie.State__c = 'Niedersachsen';
        immobilie.Unternehmen__c = bautraegerId;
        immobilie.Bank__c = 'Sparkasse';
        immobilie.IBAN__c = 'DE124943103936283819';
        immobilie.BIC__c = 'SPKHDE2HXXX';
        immobilie.Telefon__c = '05123123';
        immobilie.E_Mail__c = 'test@test.de';
        immobilie.Website__c = 'www.test.de';
        immobilie.Objektnummer__c = '1234';
        immobilie.ZahlungszielInTagen__c = 14;
        immobilie.ParagraphKaufpreisfaelligkeit__c = 'Test Paragraph';
        immobilie.Collection_Id__c = '13PD6CXYIgK2Q6pK-AswOwkX6AIuCrfEk';
        immobilie.Purchase_Price_sqm__c = 1500;
        immobilie.Property_Price__c = 1500000;
        immobilie.Surface_Object_sqm__c = 2500;
        immobilie.Repayment_Beginning__c = Date.Today() + 180;
        immobilie.Arrival__c = Date.Today() + 180;
        immobilie.Rent_Long_Term_sqm__c = 10.5;
        immobilie.Is_Public__c = true;
        
        
        if(doInsert) {
            insert immobilie;
        }
    
        return immobilie;
    }

    public static Appartment__c createAppartment(Boolean doInsert, Id immobilieId) {
        Appartment__c app = new Appartment__c();
        app.Name = 'Apartment001';
        app.Property__c = immobilieId;
        app.Status__c = 'Available';
        app.Area_sq_m__c = 63;

        if(doInsert) {
            insert app;
        }

        return app;
    }

    public static MaBVRate__c createMaBVRate(Boolean doInsert, Id immobilienId) {
        MaBVRate__c rate = new MaBVRate__c(
            Immobilie__c = immobilienId,
            Faelligkeitsdatum__c = Date.today().addDays(30),
            Leistung__c = 'X',
            LeistungszeitraumVon__c = Date.today().addDays(60),
            LeistungszeitraumBis__c = Date.Today().addDays(90),
            RateInPercentage__c = 0.1,
            RateNummer__c = '1'
        );

        if(doInsert) {
            insert rate;
        }

        return rate;
    }

    public static MaBVRechnungMaster__c createMaBVRechnungMaster(Boolean doInsert, Id opportunityId, Id mabvRateId) {
        MaBVRechnungMaster__c master = new MaBVRechnungMaster__c(
            Opportunity__c = opportunityId,
            MaBVRate__c = mabvRateId
        );

        if(doInsert) {
            insert master;
        }

        return master;
    }

    public static MaBVRechnung__c createMaBVRechnung(Boolean doInsert, Id masterId) {
        MaBVRechnung__c maBVRechnung = new MaBVRechnung__c(
            MaBVRechnungMaster__c = masterId,
            Name = '930-008-1-1'
        );

        if(doInsert) {
            insert maBVRechnung;
        }

        return maBVRechnung;
    }
    
    public static Finanzierungsanfrage__c createFinanzierungsanfrage(Boolean doInsert, Id contactId, String geforderteUnterlagen) {
        Finanzierungsanfrage__c fa = new Finanzierungsanfrage__c();
        fa.Name = 'Test';
        fa.ErsterKaeufer__c = contactId;
        fa.WelcheUnterlagenWerdenGefordert__c = geforderteUnterlagen;

        if(doInsert) {
            insert fa;
        }

        return fa;
    }

    public static Gutschrift__c createGutschrift(Boolean doInsert, Id opportunityId, Id provisionId) {
        Gutschrift__c gutschrift = new Gutschrift__c(
            Opportunity__c = opportunityId,
            Provision__c = provisionId,
            DatumGutschriftBestaetigt__c = Date.today(),
            Wert_Verkaufsprovision__c = 1000
        );
        
        if(doInsert) {
            insert gutschrift;
        }

        return gutschrift;
    }
}
