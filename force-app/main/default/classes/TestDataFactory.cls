@isTest
public with sharing class TestDataFactory {

    public static void createDatevSettings() {
        insert new DATEV1__Settings__c(
            DATEV1__AccountLength__c = 6
        );

        insert new DatevKreditorennummer__c(
            DatevKreditorennummer__c = 12345
        ); 
    }

    public static void createNecessaryCustomSettings() {
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
    }





    // User


    //TODO Merge duplicate User Creation Methods!
    public static User createTestUser(Boolean doInsert) {
        User user = new User();
        
        if(doInsert) {
            insert user;
        }

        return user;
    }

    public static User createCommunityUser(Id accountId) {
        Contact contact = new Contact(
                AccountId = accountId,
                FirstName = 'Tim',
                LastName = 'Test',
                Email = 'mathis@test.dev.xyz'
        );
        insert contact;

        Profile commProfile = [SELECT Id FROM Profile WHERE Name = 'Partner Community Manager'];
        User user = new User(
                ProfileId = commProfile.Id,
                FirstName = 'Tim',
                LastName = 'Test',
                Email = 'mathis@test.dev',
                IsActive = true,
                ContactId = contact.Id,
                Username = 'mathis@test.dev',
                Alias = 'ttest',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
        );
        insert user;

        return user;
    }

    public static User createTestuser(Boolean doInsert,string name) {
        Id systemAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User userExample = new User();
        userExample.Username = 'testuser@carestone.com'+String.valueOf(DateTime.now().getTime());
        userExample.FirstName = name;
        userExample.LastName = 'Last';
        userExample.Alias = 'Alias';
        userExample.Email = 'emailtest@test.com';
        userExample.TimeZoneSidKey = 'America/New_York';
        userExample.LocaleSidKey = 'en_US';
        userExample.EmailEncodingKey = 'ISO-8859-1';
        userExample.ProfileId = systemAdminProfileId;
        userExample.LanguageLocaleKey = 'en_US';
        userExample.isActive=true;

        if(doInsert) {
            insert userExample;
        }

        return userExample;
    }

    public static User createStandardUser(Boolean doInsert,string name) {
        Id systemAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;

        User userExample = new User();
        userExample.Username = 'testuser@carestone.com'+String.valueOf(DateTime.now().getTime());
        userExample.FirstName = name;
        userExample.LastName = 'Last';
        userExample.Alias = 'Alias';
        userExample.Email = 'emailtest@test.com';
        userExample.TimeZoneSidKey = 'America/New_York';
        userExample.LocaleSidKey = 'en_US';
        userExample.EmailEncodingKey = 'ISO-8859-1';
        userExample.ProfileId = systemAdminProfileId;
        userExample.LanguageLocaleKey = 'en_US';
        userExample.isActive=true;

        if(doInsert) {
            insert userExample;
        }

        return userExample;
    }

    public static List<User> createStandardUsers(Boolean doInsert, Integer count) {
        List<User> users = new List<User>();

        for(Integer i = 0; i < count; i++) {
            User u = createStandardUser(false, 'User'+i);
            users.add(u);
        }

        if(doInsert) {
            insert users;
        }

        return users;
    }

    public static userRole createUserRole(boolean doInsert){
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        if(doInsert){
            insert r;
        }
        return r;
    }

    public static User createCommunityUser() {
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

        Id maklerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Makler').getRecordTypeId();
        Contact con = new Contact();
        con.AccountId = acc.Id;
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
        String accNameSelector = '%' + acc.Name + '%';
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

        return usr;
    }





    // Account

    public static Account createAccount(Boolean doInsert){
        return createAccount(doInsert, 'Makler GmbH', null);
    }

    public static Account createAccount(Boolean doInsert, String accName){
        return createAccount(doInsert, accName, null);
    }
    
    public static Account createAccount(Boolean doInsert, String accountName, String accType) {
        Id brokerageRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brokerage').getRecordTypeId();
        Account acc = new Account();

        acc.Name = accountName;
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
        acc.RecordTypeId = brokerageRecordTypeId;

        if(accType != null){
            acc.Type = accType;
        }

        if(doInsert) {
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.DuplicateRuleHeader.AllowSave = true;
            Database.insert(acc, dmlo);
        }

        return acc;
    }

    public static List<Account> createAccounts(Boolean doInsert, Id parentId, Integer numAccounts) {
        List<Account> accs = new List<Account>();
        for(Integer i = 0; i < numAccounts; i++) {
            Account acc = createAccount(false, 'Makler GmbH ' + i, null);
            acc.ParentId = parentId;
            accs.add(acc);
        }

        if(doInsert) {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.insert(accs, dml);
        }
        return accs;
    }

    public static Account createBautraeger(Boolean doInsert) {
        Id propertyDeveloperRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PropertyDeveloper').getRecordTypeId();
        Account bautraeger = new Account();
        bautraeger.Name = 'Carestone Projekt GmbH';
        bautraeger.RecordTypeId = propertyDeveloperRecordTypeId;
        bautraeger.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Müller';
        bautraeger.BillingCity = 'Test Stadt';
        bautraeger.BillingStreet = 'Test Str. 12';
        bautraeger.BillingPostalCode = '30159';
        bautraeger.Email__c = 'm.mustermann@carestone.com';
        bautraeger.Phone = '113';
        bautraeger.Fax = '113';
        bautraeger.Website = 'https://carestone.com';
        bautraeger.UStd_Id__c = 'DE12345';
        bautraeger.Steuernummer__c = '24/231/113';
        bautraeger.GeschaeftsfuehrerNeu__c = 'Gabor Kowalski';
        bautraeger.Rechtsform__c = 'GbR';
        bautraeger.Amtsgericht_bei_Kapitalgesellschaften__c = 'Amtsgericht Hannover';
        bautraeger.HRB_bei_Kapitalgesellschaften__c = 'HRB 210203';
        bautraeger.Datev_Mandantennummer__c = 113;
        bautraeger.Unternehmensname__c = 'CareStone';
        bautraeger.Dauerhaft_gesch_tzt__c = true;
        
        if(doInsert) {
            Database.DMLOptions dmlo = new Database.DMLOptions();
            dmlo.DuplicateRuleHeader.AllowSave = true;
            Database.insert(bautraeger, dmlo);
        }
        return bautraeger;
    }






    //Contact
  
    public static Contact createContact(Boolean doInsert){
        Contact con = createContact(false, 'Test First Name', 'Test Last Name', 'TestLastName@email.de');

        if(doInsert){
            insert con;
        }
        return con;
    }

    public static Contact createContact(Boolean doInsert,string firstName,string lastName){
        Contact con = createContact(false, firstName, lastName, lastName + '@email.de');
        if(doInsert){
            insert con;
        }
        return con;
    }

    public static Contact createContact(Boolean doInsert,string firstName,string lastName,  string email){
        Contact con = new Contact();
        con.FirstName=firstName;
        con.LastName=lastName;
        con.MailingStreet = 'Contactstreet 2';
        con.MailingCity = 'City';
        con.email=email;
        con.Birthdate = System.today().addYears(-30);
        con.Phone = '0123456789';

        if(doInsert){
            insert con;
        }
        return con;
    }

    public static List<Contact> createContacts(Boolean doInsert, Integer count) {
        List<Contact> contacts = new List<Contact>();

        for(Integer i = 0; i < count ;i++) {
            Contact con = createContact(false);
            contacts.add(con);
        }

        if(doInsert){
            insert contacts;
        }
        return contacts;
    }

    public static Contact createMakler(Boolean doInsert, String lastName) {
        Contact con = new Contact();
        con.Gesch_ftsbeziehung__c = 'Versicherungsmakler';
        con.FirstName = 'Max';
        con.LastName = lastName;
        con.MailingStreet = 'Teststr. 24';
        con.MailingCity = 'Hannover';
        con.MailingPostalCode = '30159';
        con.DatevDebitorenKundennummerKaeufer__c = '3000001';
        con.Maklerbetreuer_E_Mail__c = 'mathis@testx.dev';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Makler').getRecordTypeId();
        con.Birthdate = System.today().addYears(-30);
        con.Email = 'test@test.dev';
        con.Phone = '0123456789';
        
        if(doInsert) {
            insert con;
        }

        return con;
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
        con.Birthdate = System.today().addYears(-30);
        con.Email = 'test@test.dev';
        con.Phone = '0123456789';
        
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
        con.Phone = '1234';
        con.Email = 'interessent@carestone.devx';
        con.BirthDate = Date.today().addDays(-365*30);

        if(doInsert) {
            insert con;
        }

        return con;
    }





    // Opportunity

    public static Opportunity createOpportunity(Boolean doInsert) {

        Account acc = createAccount(true, 'Account'+System.currentTimeMillis());
        Id interessentId = createInteressent(true, acc.Id).Id;
        Id maklerId = createMakler(true, acc.Id).Id;

        Account bautraeger = createBautraeger(true);
        Id propertyId = createProperty(true, bautraeger.Id).Id;
        Id appartmentId = createAppartment(true, propertyId).Id;

        return createOpportunity(doInsert, interessentId, maklerId, propertyId, appartmentId);
    }

    public static Opportunity createOpportunity(Boolean doInsert, Id interessentId, Id maklerId, Id propertyId, Id appartmentId) {
        return createOpportunity(doInsert, interessentId, maklerId, propertyId, appartmentId, 'Reserviert');
    }

    public static Opportunity createOpportunity(Boolean doInsert, Id interessentId, Id maklerId, Id propertyId, Id appartmentId, String stageName) {
        return createOpportunity(doInsert, interessentId, maklerId, propertyId, appartmentId, stageName, 100000);
    }

    public static Opportunity createOpportunity(Boolean doInsert, Id interessentId, Id maklerId, Id propertyId, Id appartmentId, String stageName, Decimal beurkundeterKaufpreis) {
        Contact makler = [SELECT Id, AccountId FROM Contact WHERE Id = :maklerId];

        Opportunity opp = new Opportunity();
        opp.Name = 'Offene VKC';
        opp.AccountId = makler.AccountId;
        opp.Makler__c = makler.Id;
        opp.Potenzieller_Kunde__c = interessentId;
        opp.CloseDate = System.today().addDays(31);
        opp.StageName = stageName;
        opp.Immobilie__c = propertyId;
        opp.Appartement__c = appartmentId;
        opp.Beurkundeter_Kaufpreis__c = beurkundeterKaufpreis;
        opp.Finanzierung__c = 'Barzahler';

        if(doInsert) {
            insert opp;
        }
        
        return opp;
    }





    // Property__c

    public static Property__c createProperty(Boolean doInsert, Id bautraegerId) {
        String propertyName = 'Immobilie';
        return createProperty(doInsert, bautraegerId, propertyName);
    }

    public static Property__c createProperty(Boolean doInsert, Id bautraegerId, String propertyName) {
        Property__c immobilie = new Property__c();
        immobilie.Name = propertyName;
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
        immobilie.ImVertriebsportalSichtbar__c = true;
        
        
        if(doInsert) {
            insert immobilie;
        }
    
        return immobilie;
    }

    public static List<Property__c> createProperties(Boolean doInsert, Id bautraegerId, Integer numProperties) {
        List<Property__c> properties = new List<Property__c>();
        for(Integer i = 0; i < numProperties; i++) {
            String propertyName = 'Immobilie ' + (i+1);
            properties.add(createProperty(false, bautraegerId, propertyName));
        }
        if(doInsert) {
            insert properties;
        }
        return properties;
    }





    
    // Appartment__c

    public static Appartment__c createAppartment(Boolean doInsert, Id immobilieId) {
        String apartmentName = 'Apartment001';
        return createAppartment(doInsert, immobilieId, apartmentName);
    }

    public static Appartment__c createAppartment(Boolean doInsert, Id immobilieId, String apartmentName) {
        Appartment__c app = new Appartment__c();
        app.Name = apartmentName;
        app.Property__c = immobilieId;
        app.Status__c = 'Available';
        app.Area_sq_m__c = 63;

        if(doInsert) {
            insert app;
        }

        return app;
    }

    public static List<Appartment__c> createAppartments(Boolean doInsert, Id immobilieId, Integer numApartments) {
        List<Appartment__c> apps = new List<Appartment__c>();
        for(Integer i = 0; i < numApartments; i++) {
            String apartmentName = 'Apartment ';
            if(i > 9) {
                apartmentName += '0' + (i+1);
            } else {
                apartmentName += '00' + (i+1);
            }
            apps.add(createAppartment(doInsert, immobilieId, apartmentName));
        }

        if(doInsert) {
            insert apps;
        }

        return apps;
    }





    // MaBVRate__c

    public static MaBVRate__c createMaBVRate(Boolean doInsert, Id immobilienId) {
        return createMaBVRate(doInsert, immobilienId, 1.0);
    }

    public static MaBVRate__c createMaBVRate(Boolean doInsert, Id immobilienId, Decimal ratePercentage) {
        MaBVRate__c rate = new MaBVRate__c(
            Immobilie__c = immobilienId,
            Faelligkeitsdatum__c = Date.today().addDays(30),
            Leistung__c = 'X',
            LeistungszeitraumVon__c = Date.today().addDays(60),
            LeistungszeitraumBis__c = Date.Today().addDays(90),
            RateInPercentage__c = ratePercentage,
            RateNummer__c = '1'
        );

        if(doInsert) {
            insert rate;
        }

        return rate;
    }





    // MaBVRechnungMaster__c

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





    // MaBVRechnung__c

    public static MaBVRechnung__c createMaBVRechnung(Boolean doInsert, Id masterId) {
        return createMaBVRechnung(doInsert, '930-008-1-1', masterId);
    }

    public static MaBVRechnung__c createMaBVRechnung(Boolean doInsert, String name, Id masterId) {
        MaBVRechnung__c maBVRechnung = new MaBVRechnung__c(
            MaBVRechnungMaster__c = masterId,
            Name = name
        );

        if(doInsert) {
            insert maBVRechnung;
        }

        return maBVRechnung;
    }





    // Zahlung__c

    public static Zahlung__c createZahlung(Boolean doInsert, Double betrag, Id rechnungId) {
        Zahlung__c zahlung = new Zahlung__c(
            MaBVRechnung__c = rechnungId,
            Betrag__c = betrag
        );

        if(doInsert) {
            insert zahlung;
        }
        
        return zahlung;
    }





    // Finanzierungsanfrage__c
    
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





    //Gutschrift__c

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





    // Campaign

    public static Campaign createCampaign(Boolean doInsert) {
        Campaign campaign = new Campaign(
            Name = 'Testcampaign'
        );
        
        if(doInsert) {
            insert campaign;
        }

        return campaign;
    }


    // CampaignMember
    public static CampaignMember createCampaignMember(Boolean doInsert, Id contactId, Id campaignId) {
        CampaignMember campaignMember = new CampaignMember(
            ContactId = contactId,
            CampaignId = campaignId
        );
        
        if(doInsert) {
            insert campaignMember;
        }

        return campaignMember;
    }


    // Realty_User__c

    public static Realty_User__c createImmoUser(Boolean doInsert, Id contactId) {
    Realty_User__c immoUser = new Realty_User__c(
            Password__c = 'test123', Name = 'test tester', Email__c = 'test@mail.com', Login_Email__c = 'test@mail.com', Contact__c = contactId
        );

        if(doInsert) {
            insert immoUser;
        }

        return immoUser;
    }





    // Provision__c

    public static Provision__c createProvision(Boolean doInsert) {

        Opportunity opp = createOpportunity(true);
        User user = createStandardUser(true, 'MB');

        return createProvision(doInsert, opp.Id, user.Id, opp.Makler__c);
    }

    public static Provision__c createProvision(Boolean doInsert, Id opportunityId, Id maklerBetreuerUserId, Id empfaengerId) {

        Provision__c provi = new Provision__c(
            Verkaufschance__c = opportunityId,
            Maklerbetreuer__c = maklerBetreuerUserId,
            Makler__c = empfaengerId,
            Wert_Verk_ufer_Beratungsprovision_m_R__c = 20
        );

        if(doInsert) {
            insert provi;
        }

        return provi;
    }





    // Provisionsverhandlung__c

    public static Provisionsverhandlung__c createProvisionsverhandlung(Boolean doInsert, Id accountId, Id immoId) {
        Provisionsverhandlung__c provisionsverhandlung = new Provisionsverhandlung__c(
            Account__c = accountId,
            Immobilie__c = immoId,
            Grundprovision__c = 5.0,
            Verkaufsprovision__c = 10
        );

        if(doInsert) {
            insert provisionsverhandlung;
        }

        return provisionsverhandlung;
    }

    public static List<Provisionsverhandlung__c> createProvisionsverhandlungenForAllAccounts(Boolean doInsert) {
        Id brokerageRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Brokerage').getRecordTypeId();
        List<Account> accs = [SELECT Id FROM Account WHERE RecordTypeId = :brokerageRecordTypeId];
        List<Property__c> immobilien = [SELECT ID FROM Property__c];
        List<Provisionsverhandlung__c> provisionsverhandlungen = new List<Provisionsverhandlung__c>();

        for(Account acc:accs) {
            for(Property__c immobilie:immobilien) {
                Provisionsverhandlung__c provisionsverhandlung = new Provisionsverhandlung__c();
                provisionsverhandlung.Immobilie__c = immobilie.Id;
                provisionsverhandlung.Grundprovision__c = 6.0;
                provisionsverhandlung.Verkaufsprovision__c = 1.5;
                provisionsverhandlung.Account__c = acc.Id;
                provisionsverhandlungen.add(provisionsverhandlung);
            }
        }

        if(doInsert) {
            insert provisionsverhandlungen;
        }

        return provisionsverhandlungen;
    }

    


    
    // DigitaleVsa__c

    public static DigitaleVsa__c createDigitaleVsa(Boolean doInsert) {
        Finanzierungsanfrage__c finanzierungsanfrage = new Finanzierungsanfrage__c(
            Name = 'Testfinanzierungsanfrage'
        );
        insert finanzierungsanfrage;

        DigitaleVsa__c digitaleVsa = new DigitaleVsa__c(
        );

        if(doInsert) {
            insert digitaleVsa;
            digitaleVsa.Finanzierungsanfrage__c = finanzierungsanfrage.Id;
            update digitaleVsa;
        }

        return digitaleVsa;
    }





    // Activity_Summary__c

    public static Activity_Summary__c createActivitySummary(Boolean doInsert, string userId) {
        Activity_Summary__c summary= new Activity_Summary__c();
        summary.year__c=String.valueOf(Date.Today().Year());
        summary.month__c=String.valueOf(date.today().Month());
        summary.userId__c=userId;
        summary.number_of_logins__c=0;
        contact con= new contact();
        con.lastName='test';
        insert con;
        summary.contact__c=con.id;
        if(doInsert) {
            insert summary;
        }
        return summary;
    }


    public static Activity_Summary__c createActivitySummary(Boolean doInsert, Id userId, Id contactId, Integer nmonth) {
        Activity_Summary__c summary= new Activity_Summary__c();
        summary.year__c=String.valueOf(Date.today().addmonths(nmonth*-1).year());
        summary.month__c=String.valueOf(Date.today().addmonths(nmonth*-1).month());
        summary.userId__c=userId;
        summary.number_of_logins__c=0;
        summary.contact__c = contactId;
        if(doInsert) {
            insert summary;
        }
        return summary;
    }

    public static Activity_Summary__c createActivitySummary(Boolean doInsert, string userId, integer nmonth) {
        contact con= new contact();
        con.lastName='test';
        insert con;
        return createActivitySummary(doInsert, userId, con.Id, nmonth);
    }





    // ImmobilienDmsDatei__c

    public static ImmobilienDmsDatei__c createImmobilienDmsDatei(Boolean doInsert, Id propertyId, String fileType) {
        ImmobilienDmsDatei__c idd = new ImmobilienDmsDatei__c();
        idd.ThumbnailUrl__c = 'https://drive.google.com/thumbnail?authuser=0&sz=w320&id=13QfxKrQyGTwflCFtuQ67bHnS-CzFf-pX';
        idd.MimeType__c = 'application/pdf';
        // 'Bilder' oder 'Dokumente'
        idd.DateiTyp__c = fileType;
        idd.Name = 'Datei.pdf';
        idd.DateiUrl__c = 'https://drive.google.com/uc?id=13QfxKrQyGTwflCFtuQ67bHnS-CzFf-pX&export=download';
        idd.Immobilie__c = propertyId;
        if(doInsert) {
            insert idd;
        }
        return idd;
    }





    // FileDownloadLog__c

    public static FileDownloadLog__c createFileDownloadLog(Boolean doInsert,id contactId){
        FileDownloadLog__c fdl =new FileDownloadLog__c();
        fdl.Contact__c =contactId;
        fdl.Name = 'Test file.pdf';
        if(doInsert){
            insert fdl;
        }

        return fdl;
    }





    // Berechnung__c

    public static Berechnung__c createCalculation(Boolean doInsert, Id contactId, Id vkrId){
        Berechnung__c b = new Berechnung__c();
        b.Makler__c = contactId;
        b.Verkaufsraum__c = vkrId;
        if(doInsert){
            insert b;
        }

        return b;
    }

    public static Berechnung__c createCalculation(Boolean doInsert, Id contactId){
        Berechnung__c b = new Berechnung__c();
        b.Makler__c = contactId;
        b.Verkaufsraum__c = createVerkaufsraum(true, contactId).Id;
        if(doInsert){
            insert b;
        }

        return b;
    }





    // Verkaufsraum__c

    public static Verkaufsraum__c createVerkaufsraum(Boolean doInsert, Id contactId){
        Verkaufsraum__c vkr = new Verkaufsraum__c();
        vkr.Makler__c = contactId;
        vkr.ErsterKaeufer__c = contactId;
        if(doInsert){
            insert vkr;
        }

        return vkr;
    }





    // Task

    public static Task createTask(Boolean doInsert, Id whoId, String subject) {
        Task t = new Task();
        t.Subject = subject;
        t.WhoId = whoId;
        if(doInsert) {
            insert t;
        }

        return t;
    }




    // Lead

    public static Lead createLead(Boolean doInsert) {
        Lead lead = new Lead();
        lead.LastName = 'Test Lead';
        lead.Company = 'Test Company';
        lead.Phone = '123456';
        lead.Email = 'lead@carestone.com';

        if(doInsert) {
            insert lead;
        }

        return lead;
    }

    public static List<Lead> createLeads(Boolean doInsert, Integer count) {
        List<Lead> leads = new List<Lead>();

        for(Integer i = 0; i < count ;i++) {
            Lead lead = createLead(false);
            leads.add(lead);
        }

        if(doInsert){
            insert leads;
        }
        return leads;
    }

}