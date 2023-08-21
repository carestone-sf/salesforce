@isTest
public with sharing class ImmobilienControllerTest {
    
    private static testMethod void getPublicImmobilienTest() {
        ImmobilienController.getPublicImmobilien();
    }

    private static testMethod void getHighlightImmobilienTest() {
        ImmobilienController.getHighlightImmobilien();
    }

    private static testMethod void getMaklerImmobilienTest() {
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
    
            usr.Username = 'cs_salesaccount5@test.de.'+ sbName;
            usr.profileId = portalProfileUser.Id;
            con.LastName = 'Sales-Account';
        
        usr.Alias = usr.Username.substring(0,6);
        usr.Email= 'test@test.de';
        insert usr;

        Property__c immobilie = new Property__c();
        immobilie.Name = 'Immobilie';
        immobilie.Place__c = 'test';
        immobilie.Is_Public__c = true;
        immobilie.ImVertriebsportalSichtbar__c = true;
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

        TestDataFactory.createImmobilienDMSDatei(true, immobilie.Id, 'Dokumente');
        TestDataFactory.createImmobilienDMSDatei(true, immobilie.Id, 'Bilder');
        
        List<Appartment__c> apps = new List<Appartment__c>();
        for(Integer i = 0; i < 5; i++) {
            Appartment__c app = new Appartment__c();
            if(i > 9) {
                app.Name = 'Apartment 0' + i;
            } else {
                app.Name = 'Apartment 00' + i;
            }
            app.Property__c = immobilie.Id;
            app.Status__c = 'Available';
            app.Area_sq_m__c = 63;
            apps.add(app);
        }
        
        insert apps;


        User user = [SELECT Id FROM User WHERE LastName = 'Maklermann 6'];
        System.runAs(user) {
            ImmobilienController.getMaklerImmobilien();
            ImmobilienController.getHighlightImmobilien();
            ImmobilienController.getAllImmobilien();
        }
    }

}