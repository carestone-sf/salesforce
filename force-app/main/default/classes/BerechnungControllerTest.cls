@isTest
public with sharing class BerechnungControllerTest {
    
    @TestSetup
    static void makeData(){
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        // Maklerbetreuer + Account erstellen
        Contact mb = new Contact();
        mb.FirstNAme = 'Frank';
        mb.LastName = 'Köpsell';
        mb.Email = 'f.witte@wirtschaftshaus.de';
        mb.MaklerBetreuer_E_Mail__c = 'f.witte@wirtschaftshaus.de';
        mb.Ist_Maklerbetreuer_WH__c = true;
        mb.Gesch_ftsbeziehung__c = 'Mitarbeiter WH';
        Database.insert(mb, dml);
        Account acc = new Account();
        acc.Name = 'Makler GmbH%';
        acc.Email__c = 'f.witte@wirtschaftshaus.de';
        acc.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
        acc.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
        Database.insert(acc, dml);
        mb.AccountId = acc.Id;
        Database.update(mb, dml);

        Id interessentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Interessent').getRecordTypeId();
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Gesch_ftsbeziehung__c = 'Interessent';
        con.FirstName = 'Max';
        con.MailingStreet = 'Teststr. 24';
        con.MailingCity = 'Hannover';
        con.MailingPostalCode = '30159';
        con.LastName = 'Interessentenmann 6';
        con.RecordTypeId = interessentRecordTypeId;
        insert con;
    }

    private static testMethod void insertBerechnungsApartmentsTest() {
        List<BerechnungsApartment__c> bAs = new List<BerechnungsApartment__c>();
        BerechnungController.insertBerechnungsApartments(bAs);
    }

    private static testMethod void insertBerechnungWithApartmentsTest() {
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Interessentenmann 6'];
        Verkaufsraum__c vkr = new Verkaufsraum__c();
        vkr.ErsterKaeufer__c = con.Id;
        vkr.BeratungsPortalZugangAnlegen__c = false;
        insert vkr;
        Berechnung__c b = new Berechnung__c(Name='Test', Verkaufsraum__c=vkr.Id);
        insert b;
        List<BerechnungsApartment__c> bAs = new List<BerechnungsApartment__c>();
        BerechnungController.insertBerechnungWithApartments(b.Id, bAs);
    }

    private static testMethod void insertFinanzierungsBausteineTest() {
        List<Finanzierungsbaustein__c> fBs = new List<Finanzierungsbaustein__c>();
        BerechnungController.insertFinanzierungsBausteine(fBs);
    }

    private static testMethod void deleteBerechnungsApartmentsTest() {
        List<Id> bAIds = new List<Id>();
        BerechnungController.deleteBerechnungsApartments(bAIds);
    }

    private static testMethod void deleteFinanzierungsBausteineTest() {
        List<Id> fBIds = new List<Id>();
        BerechnungController.deleteFinanzierungsBausteine(fBIds);
    }

    private static testMethod void getBerechnungTest() {
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Interessentenmann 6'];
        Verkaufsraum__c vkr = new Verkaufsraum__c();
        vkr.ErsterKaeufer__c = con.Id;
        vkr.BeratungsPortalZugangAnlegen__c = false;
        insert vkr;
        Berechnung__c b = new Berechnung__c(Name='Test', Verkaufsraum__c=vkr.Id);
        insert b;
        BerechnungController.getBerechnung(b.Id);
    }

    private static testMethod void getFinanzierungsbausteinTest() {
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Interessentenmann 6'];
        Verkaufsraum__c vkr = new Verkaufsraum__c();
        vkr.ErsterKaeufer__c = con.Id;
        vkr.BeratungsPortalZugangAnlegen__c = false;
        insert vkr;
        Berechnung__c b = new Berechnung__c(Name='Test', Verkaufsraum__c=vkr.Id);
        insert b;
        BerechnungController.getFinanzierungsbaustein(b.Id);
    }

    private static testMethod void getBerechnungSaveTest() {
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Interessentenmann 6'];
        Verkaufsraum__c vkr = new Verkaufsraum__c();
        vkr.ErsterKaeufer__c = con.Id;
        vkr.BeratungsPortalZugangAnlegen__c = false;
        insert vkr;
        Berechnung__c b = new Berechnung__c(Name='Test', Verkaufsraum__c=vkr.Id);
        insert b;
        BerechnungController.getBerechnungSave();
    }

    private static testMethod void getBerechnungSaveIdTest() {
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Interessentenmann 6'];
        Verkaufsraum__c vkr = new Verkaufsraum__c();
        vkr.ErsterKaeufer__c = con.Id;
        vkr.BeratungsPortalZugangAnlegen__c = false;
        insert vkr;
        Berechnung__c b = new Berechnung__c(Name='Test', Verkaufsraum__c=vkr.Id);
        insert b;
        BerechnungController.getBerechnungSaveWithId(b.Id);
    }
    
}