@isTest
public class CalculationQuoteControllerTest {
    
    static User insertUser(){
        Id systemAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User userExample = new User();
        userExample.Username = 'emailtest@test.com'+String.valueOf(1234);
        userExample.FirstName = 'First';
        userExample.LastName = 'Last';
        userExample.Alias = 'Alias';
        userExample.Email = 'emailtest@test.com';
        userExample.TimeZoneSidKey = 'America/New_York';
        userExample.LocaleSidKey = 'en_US';
        userExample.EmailEncodingKey = 'ISO-8859-1';
        userExample.ProfileId = systemAdminProfileId;
        userExample.LanguageLocaleKey = 'en_US';
        userExample.isActive=true;


        insert userExample;
        try{
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ChangeContactAccount'];
			insert new PermissionSetAssignment(AssigneeId = userExample.id, PermissionSetId = ps.Id);
        }
        catch(DmlException e){
            System.debug(e.getMessage());
        }
        return userExample;
    }

    @TestSetup
    static void makeData(){
        User u = insertUser();

        System.RunAs(u){
            Contact mb = new Contact();
            mb.FirstNAme = 'Frank';
            mb.LastName = 'Köpsell';
            mb.Email = 'witte@amstammtisch.de';
            mb.MaklerBetreuer_E_Mail__c = 'witte@amstammtisch.de';
            mb.Birthdate = Date.Today().addYears(-68);
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
            potKun.Birthdate = Date.Today().addYears(-68);
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
            immobilie.Arrival__c = Date.today();
            insert immobilie;

            Appartment__c app2 = new Appartment__c();
            app2.Name = 'TestApp2';
            app2.Property__c = immobilie.Id;
            app2.Status__c = 'Available';
            app2.Area_sq_m__c = 63;
            app2.Purchase_Price__c = 150000;
            insert app2;
        }

    }

    @isTest
    static void testCashCalculation() {
        List<Contact> cons = [SELECT Id FROM Contact];
        Property__c p = [SELECT Id FROM Property__c];
        Appartment__c a = [SELECT Id FROM Appartment__c];
        Afa__c afa = new Afa__c();
        afa.Name = 'AFA';
        insert afa;
        AfaWert__c afaWert = new AfaWert__c();
        afaWert.AFAInProzent__c = 2.0;
        afaWert.JahrBis__c = 50;
        afaWert.JahrVon__c = 1;
        afaWert.Berechnung__c = 'Gesamtwert';
        afaWert.Afa__c = afa.Id;
        insert afaWert;
        p.AFAAnschaffungskosten__c = afa.Id;
        update p;
        Verkaufsraum__c vkr = new Verkaufsraum__c(ErsterKaeufer__c = cons[1].Id);
        vkr.BeratungsPortalZugangAnlegen__c = false;
        insert vkr;
        Berechnung__c b = new Berechnung__c(Name='Test', Makler__c = cons[0].Id, Hauptimmobilie__c=p.Id, Verkaufsraum__c=vkr.Id);
        b.ZuVersteuerndesEinkommen__c = 100000;
        b.TaxableIncomePension__c = 50000;
        b.BetrachtungszeitraumInJahren__c = 10;
        b.Eigenkapital__c = 10000;
        b.Afa__c = afa.Id;
        insert b;
        BerechnungsApartment__c ba = new BerechnungsApartment__c(Berechnung__c = b.Id, Immobilie__c = p.Id, Apartment__c = a.Id);
        insert ba;
        PageReference pageRef = Page.CalculationQuote;
        pageRef.getParameters().put('id', b.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        ApexPages.StandardController std = new ApexPages.StandardController(b);
        CalculationQuoteController cq = new CalculationQuoteController(std);
        Test.stopTest();
    }

    @isTest
    static void testFinancedCalculation() {
        List<Contact> cons = [SELECT Id FROM Contact];
        Property__c p = [SELECT Id FROM Property__c];
        Appartment__c a = [SELECT Id, Purchase_Price__c FROM Appartment__c];
        Afa__c afa = new Afa__c();
        afa.Name = 'AFA';
        insert afa;
        AfaWert__c afaWert = new AfaWert__c();
        afaWert.AFAInProzent__c = 2.0;
        afaWert.JahrBis__c = 50;
        afaWert.JahrVon__c = 1;
        afaWert.Berechnung__c = 'Gesamtwert';
        afaWert.Afa__c = afa.Id;
        insert afaWert;
        p.AFAAnschaffungskosten__c = afa.Id;
        update p;
        Verkaufsraum__c vkr = new Verkaufsraum__c(ErsterKaeufer__c = cons[1].Id);
        vkr.BeratungsPortalZugangAnlegen__c = false;
        insert vkr;
        Berechnung__c b = new Berechnung__c(Name='Test', Makler__c = cons[0].Id, Hauptimmobilie__c=p.Id,Verkaufsraum__c=vkr.Id);
        b.ZuVersteuerndesEinkommen__c = 100000;
        b.TaxableIncomePension__c = 50000;
        b.Afa__c = afa.Id;
        b.BetrachtungszeitraumInJahren__c = 10;
        b.Eigenkapital__c = 10000;
        insert b;
        BerechnungsApartment__c ba = new BerechnungsApartment__c(Berechnung__c = b.Id, Immobilie__c = p.Id, Apartment__c = a.Id);
        insert ba;
        Finanzierungsbaustein__c fc = new Finanzierungsbaustein__c(Berechnung__c = b.Id, Kreditsumme__c = a.Purchase_Price__c/2, ZinsInPercent__c = 2, TilgungInPercent__c = 2.5);
        insert fc;
        Finanzierungsbaustein__c fc2 = new Finanzierungsbaustein__c(Berechnung__c = b.Id, Art__c = 'Endfälliges Darlehen', Kreditsumme__c = a.Purchase_Price__c/2, ZinsInPercent__c = 2, LaufzeitInJahren__c = 20, TilgungInPercent__c = 2.5);
        insert fc2;
        PageReference pageRef = Page.CalculationQuote;
        pageRef.getParameters().put('id', b.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        ApexPages.StandardController std = new ApexPages.StandardController(b);
        CalculationQuoteController cq = new CalculationQuoteController(std);
        cq.getFinanceModules();
        cq.getCumulatedYearlyValues();
        cq.getFirstYearAfterPaymentValues();
        cq.getFirstYear();
        cq.getLastYear();
        cq.getFirstFullYear();
        cq.getFirstYearAfterPayment();
        cq.getPages();
        cq.getPaginatedYearlyValues();
        cq.getSumSBetragplusFKreditsumme();
        RestQuote.attachQuoteFromId(b.Id);
        Test.stopTest();
    }

}