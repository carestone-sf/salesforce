@IsTest
public class ApprovalControllerTest {

    @testSetup static void test_setup() {
        Contact mb = new Contact();
        mb.FirstNAme = 'Frank';
        mb.LastName = 'Köpsell';
        mb.Email = 'witte@amstammtisch.de';
        mb.Salutation = 'Herr';
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
        acc3.Steuernummer__c = '24/231/123';
        acc3.BillingCity = 'Hannover';
        acc3.BillingPostalCode = '30159';
        acc3.BillingStreet = 'Lister Meile 45';
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

        DatevKreditorennummer__c datevKreditorennummer = DatevKreditorennummer__c.getOrgDefaults();
        datevKreditorennummer.DatevKreditorennummer__c = 123456;
        insert datevKreditorennummer;
    }

    private static testMethod void approveProvision() {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;

        Account acc3 = [SELECT Id FROM Account];

        Id maklerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Makler').getRecordTypeId();
        Contact con = new Contact();
        con.AccountId = acc3.Id;
        con.Gesch_ftsbeziehung__c = 'Versicherungsmakler';
        con.FirstName = 'Max';
        con.MailingStreet = 'Teststr. 24';
        con.MailingCity = 'Hannover';
        con.MailingPostalCode = '30159';
        con.LastName = 'Maklermann 6';
        con.RecordTypeId = maklerRecordTypeId;
        insert con;

        Database.insert(con, dml);

        Profile portalProfileUser = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community%User' Limit 1];
        Profile portalProfileManager = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community%Manager' Limit 1];
        List<PermissionSetAssignment> pmas = new List<PermissionSetAssignment>();
        List<PermissionSet> pms = [SELECT Id, Name FROM PermissionSet WHERE Name Like '%Community%'];
        PermissionSet accPm;
        PermissionSet conPm;
        PermissionSet provPm;
        PermissionSet immPm;
        for(PermissionSet pm:pms) {
            if(pm.Name.contains('Accounts')) { 
                accPm = pm;
            } else if(pm.Name.contains('Kontakte')) { 
                conPm = pm;
            } else if(pm.Name.contains('Provision')) { 
                provPm = pm;
            } else if(pm.Name.contains('Immobilie')) {
                immPm = pm;
            }
        }
        List<User> communityUsers = new List<User>();
        String sbName = UserInfo.getUserName().substringAfterLast('.');
        User usr = new User(
            ProfileId = portalProfileManager.Id,
            EmailEncodingKey='UTF-8',
            Firstname=con.firstName,
            Lastname=con.LastName,
            LanguageLocaleKey='de',
            LocaleSidKey='de_DE',
            TimeZoneSidKey='GMT',
            ContactId=con.Id);
    
            usr.Username = 'salesaccount5@test.de';
            usr.profileId = portalProfileUser.Id;
            con.LastName = 'Sales-Account';
        
        usr.Alias = usr.Username.substring(0,6);
        usr.Email= 'test@test.de';
        insert usr;

        Contact mb = [SELECT Id, Email FROM Contact WHERE LastName = 'Köpsell'];
        Contact potKun = [SELECT Id FROM Contact WHERE LastName = 'Tekoeeric'];
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
        provision.Verkaufschance__c = opp2.Id;
        provision.Maklerbetreuer__c = '005b0000001V30P';
        insert provision;

        User user = [SELECT Id FROM User WHERE LastName = 'Maklermann 6'];

//        TODO run in Maklerbetreuer context
//        List<ApprovalController.ProvisionApproval> pas = ApprovalController.getProvisionApprovals();
//        ApprovalController.approveProvision(pas[0].workItemId);

    }
}