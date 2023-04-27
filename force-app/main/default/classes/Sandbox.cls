global class Sandbox implements SandboxPostCopy {

    global Sandbox() {
        //Implementations of SandboxPostCopy must have a no-arg constructor.
        //This constructor is used during the sandbox copy process.
        //You can also implement constructors with arguments, but be aware that
        //they won’t be used by the sandbox copy process (unless as part of the
        //no-arg constructor).
        // this(some_args);
    }

    global void runApexClass(SandboxContext context) {
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
        List<Account> accs = TestDataFactory.createAccounts(true, acc.Id, 1);
        for(Account currentAcc:accs) {
            currentAcc.isPartner = true;
        }
        Database.update(accs);

        // Interessenten erstellen
        createContacts(2, 'Interessent');

        // Makler erstellen
        createContacts(5, 'Versicherungsmakler');

        // Community User erstellen
        createCommunityUsers();

        Account bautraeger = TestDataFactory.createBautraeger(true);

        // Immobilien erstellen
        List<Property__c> properties = TestDataFactory.createProperties(true, bautraeger.Id, 2);

        List<Appartment__c> apps = new List<Appartment__c>();
        for(Property__c property:properties) {
            apps.addAll(TestDataFactory.createAppartments(false, property.Id, 30));
        }
        //Teilobjekte erstellen
        insert apps; 

        //Provisionsvereinbarungen erstellen
        TestDataFactory.createProvisionsverhandlungenForAllAccounts(true);

        //Opportunities erstellen
        createOpenOpportunities(2);
        createClosedOpportunities(1);

        //add to contacts email suffix '.invalid'
        Database.executeBatch(new BatchAddSuffixToAllContactsEmails());
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
                Integer z = i+1;
                if(geschaeftsbeziehung == 'Interessent') {
                    con = TestDataFactory.createInteressent(false, acc.Id);
                    con.LastName = 'Interessentenmann ' + z;
                } else {
                    con = TestDataFactory.createMakler(false, acc.Id);
                    con.LastName = 'Maklermann ' + z;
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