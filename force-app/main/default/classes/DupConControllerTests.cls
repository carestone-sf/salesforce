@isTest

public class DupConControllerTests {

    public static testMethod void testMyController() {
        Database.DMLOptions dml2 = new Database.DMLOptions();
        dml2.DuplicateRuleHeader.AllowSave = true;

        Contact mb = new Contact();
        mb.FirstNAme = 'Frank';
        mb.LastName = 'Köpsell';
        mb.Email = 'witte@amstammtisch.de';
        mb.MaklerBetreuer_E_Mail__c = 'witte@amstammtisch.de';
        Database.insert(mb, dml2);
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Email__c = 'test@test.de';
        acc1.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
        acc1.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
        acc1.E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com';
        acc1.BIC__c  = '1';
        acc1.Geschueftsfuehrer__c = mb.id;
        acc1.Gesetzliche_MwSt_auf_Provisionszahlung__c = 0.4;
        acc1.IBAN__c = '2';
        acc1.Rechtsform__c = 'GbR';
        acc1.Unternehmensname__c = 'CareStone';
        Database.insert(acc1, dml2);
        mb.AccountId = acc1.Id;
        Database.update(mb);

        Account account1 = new Account(Name='test account', ParentID = acc1.id, Maklerbetreuer_Wirtschaftshaus__c = 'Lars Wagner', Email__c='test@test.test',E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com', BIC__c ='1', Geschueftsfuehrer__c=mb.id, Gesetzliche_MwSt_auf_Provisionszahlung__c=0.4, IBAN__c='2', Rechtsform__c='GbR', Unternehmensname__c='CareStone');
        Database.insert(account1, dml2);

        Contact contact1 = new Contact(AccountID=account1.id, FirstName = 'test', LastName='contact1', Email='test@mail.com',Maklerbetreuer_E_Mail__c='tesssd@mail.com',Gesch_ftsbeziehung__c = 'Interessent');
        Database.insert(contact1, dml2);

        Account account2 = new Account(Name = 'test2 account', ParentID = account1.Id, Maklerbetreuer_Wirtschaftshaus_2__c = contact1.id, Email__c ='test@test.test', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com', BIC__c ='1', Geschueftsfuehrer__c=mb.id, Gesetzliche_MwSt_auf_Provisionszahlung__c=0.4, IBAN__c='2', Rechtsform__c='GbR', Unternehmensname__c='CareStone');
        Database.insert(account2, dml2);

        Contact contact2 = new Contact(AccountID = account2.id, FirstName = 'test',LastName='test2', Maklerbetreuer_E_Mail__c='tesssd@mail.com',Gesch_ftsbeziehung__c = 'Kunde');
        Database.insert(contact2, dml2);

        Contact con2 = new Contact (AccountID = account1.id, LastName ='test3', MailingCity = 'bla', MailingState ='blub');
        Database.insert(con2, dml2);

        Contact[] cons = new List<Contact>();

        cons.add(contact1);


        Contact newContact= new Contact(FirstName = 'test', LastName = 'contact1', AccountId = account2.Id, Gesch_ftsbeziehung__c = 'Interessent', Maklerbetreuer_E_Mail__c='tesssd@mail.com',Aus_Maklerportal__c = true);
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.SaveResult sr = Database.insert(newContact, dml);
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Kontakt für Genehmigung eingereicht.');
        req1.setObjectId(newContact.id);
        req1.setProcessDefinitionNameOrId('Interessentenschutz');
        Approval.process(req1);

        //Construct your pagereference
        PageReference testPage = new pagereference('/apex/dupcon');
        testPage.getParameters().put('id', newContact.Id);
        Test.setCurrentPage(testPage);

        ApexPages.StandardController ssc = new ApexPages.StandardController(newContact);
        DupConController dupCon = new DupConController(ssc);
        dupCon.getFirst();
        dupCon.getPossibleDups();
        dupCon.getPossibleDupLeads();

        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(cons);
        setCon.setSelected(cons);

        Test.startTest();
        dupCon.mergeContacts(contact1.Id);
        Test.stopTest();
        Contact aftercon = [Select AccountId FROM Contact WHERE ID = : contact1.Id];
        //System.assertEquals(account2.Id, aftercon.AccountId);

        System.debug('aftercon: ' + aftercon.AccountId);
        System.debug('account2: ' + account2.Id);


    }

    public static testMethod void testMyControllerTwo() {
        Database.DMLOptions dml2 = new Database.DMLOptions();
        dml2.DuplicateRuleHeader.AllowSave = true;

        Contact mb = new Contact();
        mb.FirstNAme = 'Frank';
        mb.LastName = 'Köpsell';
        mb.Email = 'witte@amstammtisch.de';
        mb.MaklerBetreuer_E_Mail__c = 'witte@amstammtisch.de';
        Database.insert(mb, dml2);
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Email__c = 'test@test.de';
        acc1.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
        acc1.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
        acc1.E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com';
        acc1.BIC__c  = '1';
        acc1.Geschueftsfuehrer__c = mb.id;
        acc1.Gesetzliche_MwSt_auf_Provisionszahlung__c = 0.4;
        acc1.IBAN__c = '2';
        acc1.Rechtsform__c = 'GbR';
        acc1.Unternehmensname__c = 'CareStone';
        Database.insert(acc1, dml2);
        mb.AccountId = acc1.Id;
        Database.update(mb);

        Account account1 = new Account(Name='test account', ParentID = acc1.id, Maklerbetreuer_Wirtschaftshaus__c = 'Lars Wagner', Email__c='test@test.test',E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com', BIC__c ='1', Geschueftsfuehrer__c=mb.id, Gesetzliche_MwSt_auf_Provisionszahlung__c=0.4, IBAN__c='2', Rechtsform__c='GbR', Unternehmensname__c='CareStone');
        Database.insert(account1, dml2);

        Contact contact1 = new Contact(AccountID=account1.id, FirstName = 'test', LastName='contact1', Email='test@mail.com',Maklerbetreuer_E_Mail__c='tesssd@mail.com',Gesch_ftsbeziehung__c = 'Interessent');
        Database.insert(contact1, dml2);

        Account account2 = new Account(Name = 'test2 account', ParentID = account1.Id, Maklerbetreuer_Wirtschaftshaus_2__c = contact1.id, Email__c ='test@test.test', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com', BIC__c ='1', Geschueftsfuehrer__c=mb.id, Gesetzliche_MwSt_auf_Provisionszahlung__c=0.4, IBAN__c='2', Rechtsform__c='GbR', Unternehmensname__c='CareStone');
        Database.insert(account2, dml2);

        Contact contact2 = new Contact(AccountID = account2.id, FirstName = 'test',LastName='test2', Maklerbetreuer_E_Mail__c='tesssd@mail.com',Gesch_ftsbeziehung__c = 'Kunde');
        Database.insert(contact2, dml2);

        Contact con2 = new Contact (AccountID = account1.id, LastName ='test3', MailingCity = 'bla', MailingState ='blub');
        Database.insert(con2, dml2);

        contact1.Kunden_Maklerschutz__c = false;
        con2.Kunden_Maklerschutz__c = false;
        update contact1;
        update contact2;

        Contact[] cons = new List<Contact>();

        cons.add(contact1);

        Contact newContact= new Contact(FirstName = 'test', LastName = 'contact1', AccountId = account2.Id, Gesch_ftsbeziehung__c = 'Versicherungsmakler', MaklerBetreuer_E_Mail__c = 'test@test.test', Aus_Maklerportal__c = true);
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.SaveResult sr = Database.insert(newContact, dml);

        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Kontakt für Genehmigung eingereicht.');
        req1.setObjectId(newContact.id);
        req1.setProcessDefinitionNameOrId('Maklerschutz');
        Approval.process(req1);

        //Construct your pagereference
        PageReference testPage = new pagereference('/apex/dupcon');
        testPage.getParameters().put('id', newContact.Id);
        Test.setCurrentPage(testPage);

        ApexPages.StandardController ssc = new ApexPages.StandardController(newContact);
        DupConController dupCon = new DupConController(ssc);
        dupCon.getFirst();

        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(cons);
        setCon.setSelected(cons);
        Test.startTest();
        dupCon.mergeContacts(contact1.Id);
        Test.stopTest();
        Contact aftercon = [Select AccountId FROM Contact WHERE ID = : contact1.Id];

        System.debug('aftercon: ' + aftercon.AccountId);
    }

    public static testMethod void testMyControllerThree() {
        Database.DMLOptions dml2 = new Database.DMLOptions();
        dml2.DuplicateRuleHeader.AllowSave = true;

        Contact mb = new Contact();
        mb.FirstNAme = 'Frank';
        mb.LastName = 'Köpsell';
        mb.Email = 'witte@amstammtisch.de';
        mb.MaklerBetreuer_E_Mail__c = 'witte@amstammtisch.de';
        Database.insert(mb, dml2);
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Email__c = 'test@test.de';
        acc1.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
        acc1.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
        acc1.E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com';
        acc1.BIC__c  = '1';
        acc1.Geschueftsfuehrer__c = mb.id;
        acc1.Gesetzliche_MwSt_auf_Provisionszahlung__c = 0.4;
        acc1.IBAN__c = '2';
        acc1.Rechtsform__c = 'GbR';
        acc1.Unternehmensname__c = 'CareStone';
        Database.insert(acc1, dml2);
        mb.AccountId = acc1.Id;
        Database.update(mb);

        Account account1 = new Account(Name='test account', ParentID = acc1.id, Maklerbetreuer_Wirtschaftshaus__c = 'Lars Wagner', Email__c='test@test.test',E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com', BIC__c ='1', Geschueftsfuehrer__c=mb.id, Gesetzliche_MwSt_auf_Provisionszahlung__c=0.4, IBAN__c='2', Rechtsform__c='GbR', Unternehmensname__c='CareStone');
        Database.insert(account1, dml2);

        Contact contact1 = new Contact(AccountID=account1.id, FirstName = 'test', LastName='contact1', Email='test@mail.com',Maklerbetreuer_E_Mail__c='tesssd@mail.com',Gesch_ftsbeziehung__c = 'Interessent');
        Database.insert(contact1, dml2);

        Account account2 = new Account(Name = 'test2 account', ParentID = account1.Id, Maklerbetreuer_Wirtschaftshaus_2__c = contact1.id, Email__c ='test@test.test', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com', BIC__c ='1', Geschueftsfuehrer__c=mb.id, Gesetzliche_MwSt_auf_Provisionszahlung__c=0.4, IBAN__c='2', Rechtsform__c='GbR', Unternehmensname__c='CareStone');
        Database.insert(account2, dml2);

        Contact contact2 = new Contact(AccountID = account2.id, FirstName = 'test',LastName='test2', Maklerbetreuer_E_Mail__c='tesssd@mail.com',Gesch_ftsbeziehung__c = 'Kunde');
        Database.insert(contact2, dml2);

        Contact con2 = new Contact (AccountID = account1.id, LastName ='test3', MailingCity = 'bla', MailingState ='blub');
        Database.insert(con2, dml2);

        Contact[] cons = new List<Contact>();

        cons.add(contact1);

        Contact newContact= new Contact(FirstName = 'test', LastName = 'contact1', AccountId = account2.Id, Gesch_ftsbeziehung__c = 'Interessent', Aus_Maklerportal__c = true, Maklerbetreuer_E_Mail__c='tesssd@mail.com');
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.SaveResult sr = Database.insert(newContact, dml);

        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Kontakt für Genehmigung eingereicht.');
        req1.setObjectId(newContact.id);
        req1.setProcessDefinitionNameOrId('Interessentenschutz');
        Approval.process(req1);

        //Construct your pagereference
        PageReference testPage = new pagereference('/apex/dupcon');
        testPage.getParameters().put('id', newContact.Id);
        Test.setCurrentPage(testPage);

        ApexPages.StandardController ssc = new ApexPages.StandardController(newContact);
        DupConController dupCon = new DupConController(ssc);
        dupCon.getFirst();
        dupCon.reject();
    }

}