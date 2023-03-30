@isTest
public class OpportunityControllerTest {
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
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SkipOpportunityValidation'];
            PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'ChangeContactAccount'];
            List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
			psa.add( new PermissionSetAssignment(AssigneeId = userExample.id, PermissionSetId = ps.Id));
            psa.add( new PermissionSetAssignment(AssigneeId = userExample.id, PermissionSetId = ps2.Id));
            insert psa;
        }
        catch(DmlException e){
            System.debug(e.getMessage());
        }
        return userExample;
    }

    @testSetup static void test_setup() {
        User u = insertUser();

        System.RunAs(u){
            Contact mb = new Contact();
            mb.FirstNAme = 'Frank';
            mb.LastName = 'Köpsell';
            mb.Email = 'witte@amstammtisch.de';
                mb.Birthdate=Date.today();
                mb.Phone='111 222 333';
            mb.MaklerBetreuer_E_Mail__c = 'witte@amstammtisch.de';
            insert mb;
            Account acc3 = new Account();
            acc3.Name = 'Carestone Projekt GmbH';
            acc3.Gesch_ftsbeziehung__c = 'Bauträger';
            acc3.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
            acc3.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
            acc3.BillingCity = 'Test Stadt';
            acc3.BillingStreet = 'Test Str. 12';
            acc3.BillingPostalCode = '30159';
            acc3.Email__c = 'f.witte@wirtschaftshaus.de';
            acc3.Phone = '113';
            acc3.Fax = '113';
            acc3.Website = 'https://carestone.com';
            acc3.UStd_Id__c = 'DE12345';
            acc3.Steuernummer__c = '24/231/113';
            acc3.GeschaeftsfuehrerNeu__c = 'Sandro Pawils';
            acc3.Rechtsform__c = 'GbR';
            acc3.Amtsgericht_bei_Kapitalgesellschaften__c = 'Amtsgericht Hannover';
            acc3.HRB_bei_Kapitalgesellschaften__c = 'HRB 210203';
            acc3.Datev_Mandantennummer__c = 113;
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
            immobilie.Unternehmen__c = acc3.Id;
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
    }

    private static testMethod void testGetMabvInvoices() {
        Opportunity opp = [SELECT Id FROM Opportunity];

        Test.startTest();
        OpportunityController.getMabvInvoices(opp.Id);
        Test.stopTest();
    }
}