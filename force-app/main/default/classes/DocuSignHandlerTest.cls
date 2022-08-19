@isTest
public class DocuSignHandlerTest {
    
    @testSetup static void test_setup() {
        
        Contact mb = new Contact();
        mb.FirstNAme = 'Frank';
        mb.LastName = 'Köpsell';
        mb.Email = 'witte@amstammtisch.de';
        mb.MaklerBetreuer_E_Mail__c = 'witte@amstammtisch.de';
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
        insert immobilie;

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
        datevDebitorennummerKaeufer.DatevDebitorennummerKaeufer__c = 123456;
        insert datevDebitorennummerKaeufer;

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
        insert opp;
    }

    /**
     * Test sending the envelope to a lead
     */
    static testMethod void testSendingDocuSignEnvelope() {
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];

        List<DocuSignHandler.Variables> requestList = new List<DocuSignHandler.Variables>();
        DocuSignHandler.Variables variable = new DocuSignHandler.Variables();
        variable.docuSignTemplateId = '90869f0d-e2d7-4765-87dc-39d2290a5ac2';
        variable.ids = null;
        variable.id = o.Id;
        variable.emailSubject = 'Test subject';
        variable.emailContent = 'Test content';
        requestList.add(variable);
        
        Test.startTest();
        DocuSignHandler.sendEnvelopes(requestList);
        Test.stopTest();
    }
}