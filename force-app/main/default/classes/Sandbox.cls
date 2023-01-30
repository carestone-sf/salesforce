public class Sandbox {
    public Sandbox() {
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
        acc.Name = 'WH Maklerbetreuer - Frank Köpsell';
        acc.Email__c = 'f.witte@wirtschaftshaus.de';
        acc.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
        acc.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
        Database.insert(acc, dml);
        mb.AccountId = acc.Id;
        Database.update(mb, dml);

        // Accounts erstellen
        createAccounts(1, acc.Id, 1);

        // Interessenten erstellen
        createContacts(2, 'Interessent');

        // Makler erstellen
        createContacts(5, 'Versicherungsmakler');

        
        // Community User erstellen
        createCommunityUsers();

        // Bauträger erstellen
        Account bautraeger = new Account();
        bautraeger.Name = 'Carestone Projekt GmbH';
        bautraeger.Gesch_ftsbeziehung__c = 'Bauträger';
        bautraeger.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
        bautraeger.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
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
        Database.insert(bautraeger, dml);

        // Immobilien erstellen
        createProperties(2, bautraeger.Id);

        //Teilobjekte erstellen
        createApartments(20);

        //Provisionsvereinbarungen erstellen
        createProvisionsverhandlungen();

        //Opportunities erstellen
        createOpenOpportunities(2);
        createClosedOpportunities(1);
        
        //add to contacts email suffix '.invalid' 
        Database.executeBatch(new BatchAddSuffixToAllContactsEmails());
    }

    public static void createAccounts(Integer numAccounts, Id parentId, Integer levels) {
        List<Account> accs = new List<Account>();

        for(Integer i = 0; i < numAccounts; i++) {
            Account acc = new Account();
            if(parentId != null) {
                acc.ParentId = parentId;
            }
            Integer z = i+1;
            acc.Name = 'Makler GmbH ' + z;
            acc.Email__c = 'f.witte@wirtschaftshaus.de';
            acc.BIC__c  = 'SPKHDE2HXXX';
            acc.GeschaeftsfuehrerNeu__c = 'Sandro Pawils';
            acc.Gesetzliche_MwSt_auf_Provisionszahlung__c = 0.4;
            acc.Hinweis_zur_MwSt__c = 'Vertrag';
            acc.IBAN__c = 'DE43250501801900212158';
            acc.Rechtsform__c = 'GbR';
            acc.Unternehmensname__c = 'CareStone';
            acc.Carestone_Vertriebsvereinbarung__c = true;
            accs.add(acc);
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(accs, dml);

        for(Account acc:accs) {
            acc.isPartner = true;
        }
        Database.update(accs);

        levels = levels - 1;

        for(Account acc:accs) {
            if(levels > 0) {
                createAccounts(numAccounts, acc.Id, levels);
            }
        }
    }

    public static void createContacts(Integer numContacts, String geschaeftsbeziehung) {
        Id interessentenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                      .get('Interessent').getRecordTypeId();
        Id maklerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
                        .get('Makler').getRecordTypeId();
        List<Account> accs = [SELECT Id FROM Account WHERE Name LIKE 'Makler GmbH%'];
        List<Contact> cons = new List<Contact>();
        for(Account acc:accs) {
            for(Integer i = 0; i < numContacts; i++) {
                Contact con = new Contact();
                con.AccountId = acc.Id;
                con.Gesch_ftsbeziehung__c = geschaeftsbeziehung;
                con.FirstName = 'Max';
                con.MailingStreet = 'Teststr. 24';
                con.MailingCity = 'Hannover';
                con.MailingPostalCode = '30159';
                con.DatevDebitorenKundennummerKaeufer__c = '3000001';

                Integer z = i+1;
                if(con.Gesch_ftsbeziehung__c == 'Interessent') {
                    con.LastName = 'Interessentenmann ' + z;
                    con.RecordTypeId = interessentenRecordTypeId;
                } else {
                    con.LastName = 'Maklermann ' + z;
                    con.RecordTypeId = maklerRecordTypeId;
                }
                cons.add(con);
            }
        }

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(cons, dml);
    }

    @future
    public static void createCommunityUsers() {
        List<Account> accs = [SELECT Id, Name FROM Account WHERE Name LIKE 'Makler GmbH%'];
        if(accs.size() > 0) {
            Account acc = accs[0];
            List<Contact> cons = [SELECT Id, FirstName, LastName FROM Contact WHERE AccountId = :acc.Id AND LastName LIKE '%Makler%'];
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
            for(Integer i = 0; i < cons.size(); i++) {
                String orgId = UserInfo.getOrganizationId();
                String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
                Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
                String uniqueName = orgId + dateString + randomInt;
                Contact con = cons[i];
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
                if(i == 0) {
                    usr.Username = 'headaccount' + uniqueName + '@test.org';
                    con.LastName = 'Head-Account';
                } else if(i == 1) {
                    usr.Username = 'headassistant' +  + uniqueName + '@test.org';
                    con.LastName = 'Head-Assistant';
                } else if(i == 2) {
                    usr.Username = 'teamlead' + uniqueName + '@test.org';
                    con.LastName = 'Teamleitung';
                } else if(i == 3) {
                    usr.Username = 'salesassistant' + uniqueName + '@test.org';
                    con.LastName = 'Sales-Assistant';
                } else if(i == 4) {
                    usr.Username = 'salesaccount' + uniqueName + '@test.org';
                    usr.profileId = portalProfileUser.Id;
                    con.LastName = 'Sales-Account';
                }
                if(sbName != 'de') {
                    usr.Username += '.' + sbName;
                }
                usr.Alias = usr.Username.substring(0,6);
                usr.Email= uniqueName + '@test' + orgId + '.org';
                insert usr;
                communityUsers.add(usr);
                // PermissionSetId
                // AssigneeId
                if(i == 0) {
                    PermissionSetAssignment pma = new PermissionSetAssignment();
                    pma.AssigneeId = usr.Id;
                    pma.PermissionSetId = conPm.Id;
                    pmas.add(pma);
                    pma = new PermissionSetAssignment();
                    pma.AssigneeId = usr.Id;
                    pma.PermissionSetId = accPm.Id;
                    pmas.add(pma);
                    pma = new PermissionSetAssignment();
                    pma.AssigneeId = usr.Id;
                    pma.PermissionSetId = provPm.Id;
                    pmas.add(pma);
                } else if(i == 1) {
                    PermissionSetAssignment pma = new PermissionSetAssignment();
                    pma.AssigneeId = usr.Id;
                    pma.PermissionSetId = conPm.Id;
                    pmas.add(pma);
                    pma = new PermissionSetAssignment();
                    pma.AssigneeId = usr.Id;
                    pma.PermissionSetId = accPm.Id;
                    pmas.add(pma);
                    pma = new PermissionSetAssignment();
                    pma.AssigneeId = usr.Id;
                    pma.PermissionSetId = provPm.Id;
                    pmas.add(pma);
                } else if(i == 2) {
                    PermissionSetAssignment pma = new PermissionSetAssignment();
                    pma.AssigneeId = usr.Id;
                    pma.PermissionSetId = conPm.Id;
                    pmas.add(pma);
                    pma = new PermissionSetAssignment();
                    pma.AssigneeId = usr.Id;
                    pma.PermissionSetId = accPm.Id;
                    pmas.add(pma);
                } else if(i == 3) {
                    PermissionSetAssignment pma = new PermissionSetAssignment();
                    pma.AssigneeId = usr.Id;
                    pma.PermissionSetId = conPm.Id;
                    pmas.add(pma);
                }
                PermissionSetAssignment pma = new PermissionSetAssignment();
                pma.AssigneeId = usr.Id;
                pma.PermissionSetId = immPm.Id;
                pmas.add(pma);
            }
            insert pmas;

            List<UserRole> userRoles = [SELECT Id, Name FROM UserRole WHERE PortalAccountId = :acc.Id];
            UserRole managerRole;
            UserRole defaultRole;
            UserRole ceoRole;
            for(UserRole usrRole:userRoles) {
                if(usrRole.Name.contains('Manager')) {
                    managerRole = usrRole;
                } else if(usrRole.Name.contains('Benutzer')) {
                    defaultRole = usrRole;
                } else if(usrRole.Name.contains('Führungskraft')) {
                    ceoRole = usrRole;
                }
            }
            Id managerId;
            for(User usr:communityUsers) {
                if(usr.Username.contains('headaccount')) {
                    usr.UserRoleId = ceoRole.Id;
                    managerId = usr.Id;
                } else if(usr.Username.contains('headassistant')) {
                    usr.UserRoleId = managerRole.Id;
                } else if(usr.Username.contains('teamlead')) {
                    usr.UserRoleId = managerRole.Id;
                } else if(usr.Username.contains('salesassistant')) {
                    usr.UserRoleId = managerRole.Id;
                } else if(usr.Username.contains('salesaccount')) {
                    usr.UserRoleId = defaultRole.Id;
                }
            }
            update communityUsers;
        }
    }

    public void createProperties(Integer numProperties, Id bautraegerId) {
        List<Property__c> immobilien = new List<Property__c>();

        for(Integer i = 0; i < numProperties; i++) {
            Property__c immobilie = new Property__c();
            Integer z = i+1;
            immobilie.Name = 'Immobilie ' + z;
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
            if(Math.mod(i, 2) == 0) {
                immobilie.Collection_Id__c = '13PD6CXYIgK2Q6pK-AswOwkX6AIuCrfEk';
            } else if(Math.mod(i, 3) == 0) {
                immobilie.Collection_Id__c = '1hlv9-kGBQt2IZprDFFTZGatv8tFOzB71';
            } else {
                immobilie.Collection_Id__c = '1gfa4M4tURZK-PpbMSCXMAg5flB9q4Chb';
            }
            immobilie.Purchase_Price_sqm__c = 1500;
            immobilie.Property_Price__c = 1500000;
            immobilie.Surface_Object_sqm__c = 2500;
            immobilie.Repayment_Beginning__c = Date.Today() + 180;
            immobilie.Arrival__c = Date.Today() + 180;
            immobilie.Rent_Long_Term_sqm__c = 10.5;
            immobilie.Is_Public__c = true;
            immobilien.add(immobilie);
        }
        
        insert immobilien;
    }

    public void createApartments(Integer numApps) {
        List<Property__c> immobilien = [SELECT ID FROM Property__c WHERE Name LIKE 'Immobilie %'];
        
        List<Appartment__c> apps = new List<Appartment__c>();
        for(Property__c immobilie:immobilien) {
            for(Integer i = 0; i < numApps; i++) {
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
        }
        
        insert apps;
    }

    public void createProvisionsverhandlungen() {
        List<Account> accs = [SELECT Id FROM Account WHERE Name LIKE 'Makler GmbH%'];
        List<Property__c> immobilien = [SELECT ID FROM Property__c WHERE Name LIKE 'Immobilie %'];
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

        insert provisionsverhandlungen;
    }

    @Future(callout=true)
    public static void createOpenOpportunities(Integer numOpportunities) {
        Contact interessent = [SELECT Id FROM Contact WHERE LastName LIKE 'Interessentenmann 1' AND Gesch_ftsbeziehung__c = 'Interessent' LIMIT 1];
        Contact makler = [SELECT Id, AccountId FROM Contact WHERE LastName LIKE 'Maklermann 1' AND Gesch_ftsbeziehung__c = 'Versicherungsmakler' LIMIT 1];
        List<Appartment__c> apps = [SELECT Id, Property__c FROM Appartment__c WHERE Property__r.Name = 'Immobilie 1' AND Status__c = 'Available'];

        List<Opportunity> opps = new List<Opportunity>();

        for(Integer i = 0;i<numOpportunities;i++) {
            Opportunity opp = new Opportunity();
            opp.Name = 'Offene VKC ' + i;
            opp.AccountId = makler.AccountId;
            opp.Makler__c = makler.Id;
            opp.Potenzieller_Kunde__c = interessent.Id;
            opp.CloseDate = System.today().addDays(31);
            opp.StageName = 'Reserviert';
            opp.Immobilie__c = apps[i].Property__c;
            opp.Appartement__c = apps[i].Id;
            opp.Finanzierung__c = 'Barzahler';
            insert opp;
        }
    }

    @Future(callout=true)
    public static void createClosedOpportunities(Integer numOpportunities) {
        Contact interessent = [SELECT Id FROM Contact WHERE LastName LIKE 'Interessentenmann 2' AND Gesch_ftsbeziehung__c = 'Interessent' LIMIT 1];
        Contact makler = [SELECT Id, AccountId FROM Contact WHERE LastName LIKE 'Maklermann 5' AND Gesch_ftsbeziehung__c = 'Versicherungsmakler' LIMIT 1];
        List<Appartment__c> apps = [SELECT Id, Property__c FROM Appartment__c WHERE Property__r.Name = 'Immobilie 2' AND Status__c = 'Available'];

        List<Opportunity> opps = new List<Opportunity>();

        for(Integer i = 0;i<numOpportunities;i++) {
            Opportunity opp = new Opportunity();
            opp.Name = 'Geschlossene VKC ' + i;
            opp.AccountId = makler.AccountId;
            opp.Makler__c = makler.Id;
            opp.Immobilienberater__c = makler.Id;
            opp.Potenzieller_Kunde__c = interessent.Id;
            opp.CloseDate = System.today().addDays(31);
            opp.StageName = 'Geschlossene und gewonnene';
            opp.Kaufdatum__c = System.Today();
            opp.UrkundennummerKaufvertrag__c = 'abc';
            opp.Immobilie__c = apps[i].Property__c;
            opp.Appartement__c = apps[i].Id;
            opp.Finanzierung__c = 'Barzahler';
            insert opp;
        }
    }
}