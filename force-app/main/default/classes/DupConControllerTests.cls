@isTest

public class DupConControllerTests {

    public static testMethod void testMyController() {
        Database.DMLOptions dml2 = new Database.DMLOptions();
        dml2.DuplicateRuleHeader.AllowSave = true;
        
        User testUser = TestDataFactory.createTestUser(true, 'TestAdmin', 1);
        try{
            PermissionSet ps_status = [SELECT Id FROM PermissionSet WHERE Name = 'Can_change_stage_status'];
            PermissionSet ps_contact = [SELECT Id FROM PermissionSet WHERE Name = 'ChangeContactAccount'];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps_status.Id);
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps_contact.Id);
        }
        catch(DmlException e){
            System.debug(e.getMessage());
        }
        
        System.runAs(testUser){
        
            Contact mb = TestDataFactory.createContact(false,'Frank', 'Köpsell', 'witte@amstammtisch.de');
            Database.insert(mb, dml2);

            Account acc1 = TestDataFactory.createAccount(false, 'test name', null);
            acc1.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
            acc1.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
            acc1.Geschueftsfuehrer__c = mb.id;
            Database.insert(acc1, dml2);

            mb.AccountId = acc1.Id;
            Database.update(mb, dml2);

            Account account1 = TestDataFactory.createAccount(false, 'testxyz account2', null);
            account1.ParentID = acc1.id;
            account1.Maklerbetreuer_Wirtschaftshaus__c = 'Lars Wagner';
            account1.Email__c='test@testabc.test';
            account1.E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com'; 
            Database.insert(account1, dml2);

            Contact contact1 = TestDataFactory.createContact(false,'Mike', 'Vacation', 'tesss456d@mail.com');
            contact1.AccountID=account1.id;
            contact1.Gesch_ftsbeziehung__c = 'Interessent';
            Database.insert(contact1, dml2);

            Account account2 = TestDataFactory.createAccount(false, 'Greg Holiday', null);
            account2.ParentID = account1.Id;
            account2.Maklerbetreuer_Wirtschaftshaus_2__c = contact1.id;
            account2.Email__c ='testdev@test.test';
            account2.E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com';
            account2.BIC__c ='1';
            account2.Geschueftsfuehrer__c=mb.id;
            Database.insert(account2, dml2);

            Contact contact2 = TestDataFactory.createContact(false,'Paul', 'Fastest', 'tesss123d@mail.com');
            contact2.AccountID = account2.id;
            contact2.Gesch_ftsbeziehung__c = 'Kunde';
            Database.insert(contact2, dml2);

            Contact con2 = TestDataFactory.createContact(false,'Paul', 'Smith', 'tesss123d@mail.com');
            con2.AccountID = account1.id;
            Database.insert(con2, dml2);

            Contact[] cons = new List<Contact>();

            cons.add(contact1);
            Contact newContact = TestDataFactory.createContact(false,'Lars', 'Slow', 'tesssd01@mail.com');
            newContact.AccountId = account2.Id;
            newContact.Gesch_ftsbeziehung__c = 'Interessent';
            newContact.Aus_Maklerportal__c = true;
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
    }

    public static testMethod void testMyControllerTwo() {

        Database.DMLOptions dml2 = new Database.DMLOptions();
        dml2.DuplicateRuleHeader.AllowSave = true;

        Contact mb = TestDataFactory.createContact(false,'Frank', 'Köpsell', 'witte@amstammtisch.de');
        Database.insert(mb, dml2);

        Account acc1 = TestDataFactory.createAccount(false, 'test name', null);
        acc1.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
        acc1.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
        acc1.Geschueftsfuehrer__c = mb.id;
        Database.insert(acc1, dml2);

        mb.AccountId = acc1.Id;
        Database.update(mb, dml2);

        Account account1 = TestDataFactory.createAccount(false, 'testxyz account2', null);
        account1.ParentID = acc1.id;
        account1.Maklerbetreuer_Wirtschaftshaus__c = 'Lars Wagner';
        account1.Email__c='test@testabc.test';
        account1.E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com'; 
        Database.insert(account1, dml2);
        

        Contact contact1 = TestDataFactory.createContact(false,'Mike', 'Vacation', 'tesss456d@mail.com');
        contact1.AccountID=account1.id;
        contact1.Gesch_ftsbeziehung__c = 'Interessent';
        Database.insert(contact1, dml2);

        Account account2 = TestDataFactory.createAccount(false, 'Greg Holiday', null);
        account2.ParentID = account1.Id;
        account2.Maklerbetreuer_Wirtschaftshaus_2__c = contact1.id;
        account2.Email__c ='testdev@test.test';
        account2.E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com';
        account2.BIC__c ='1';
        account2.Geschueftsfuehrer__c=mb.id;
        Database.insert(account2, dml2);

        Contact contact2 = TestDataFactory.createContact(false,'Paul', 'Fastest', 'tesss123d@mail.com');
        contact2.AccountID = account2.id;
        contact2.Gesch_ftsbeziehung__c = 'Kunde';
        Database.insert(contact2, dml2);

        Contact con2 = TestDataFactory.createContact(false,'Paul', 'Smith', 'tesss123d@mail.com');
        con2.AccountID = account1.id;
        Database.insert(con2, dml2);

        contact1.Kunden_Maklerschutz__c = false;
        con2.Kunden_Maklerschutz__c = false;
        update contact1;
        update contact2;

        Contact[] cons = new List<Contact>();

        cons.add(contact1);
        Contact newContact = TestDataFactory.createContact(false,'Lars', 'Slow', 'tesssd01@mail.com');
        newContact.AccountId = account2.Id;
        newContact.Gesch_ftsbeziehung__c = 'Versicherungsmakler';
        newContact.Aus_Maklerportal__c = true;

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

        User testUser = TestDataFactory.createTestUser(true, 'TestAdmin', 1);

        try{
            PermissionSet ps_status = [SELECT Id FROM PermissionSet WHERE Name = 'Can_change_stage_status'];
            PermissionSet ps_contact = [SELECT Id FROM PermissionSet WHERE Name = 'ChangeContactAccount'];
            PermissionSet ps_reparent = [SELECT Id FROM PermissionSet WHERE Name = 'ReparentAccount'];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps_status.Id);
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps_contact.Id);
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps_reparent.Id);
        }
        catch(DmlException e){
            System.debug(e.getMessage());
        }

        System.runAs(testUser){
            Contact mb = TestDataFactory.createContact(false,'Frank', 'Köpsell', 'witte@amstammtisch.de');
            Database.insert(mb, dml2);

            Account acc1 = TestDataFactory.createAccount(false, 'test name', null);
            acc1.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
            acc1.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
            acc1.Geschueftsfuehrer__c = mb.id;
            Database.insert(acc1, dml2);

            mb.AccountId = acc1.Id;
            Database.update(mb, dml2);

            Account account1 = TestDataFactory.createAccount(false, 'testxyz account2', null);
            account1.ParentID = acc1.id;
            account1.Maklerbetreuer_Wirtschaftshaus__c = 'Lars Wagner';
            account1.Email__c='test@testabc.test';
            account1.E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com'; 
            Database.insert(account1, dml2);

            Contact contact1 = TestDataFactory.createContact(false,'Mike', 'Vacation', 'tesss456d@mail.com');
            contact1.AccountID=account1.id;
            contact1.Gesch_ftsbeziehung__c = 'Interessent';
            Database.insert(contact1, dml2);

            Account account2 = TestDataFactory.createAccount(false, 'Greg Holiday', null);
            account2.ParentID = account1.Id;
            account2.Maklerbetreuer_Wirtschaftshaus_2__c = contact1.id;
            account2.Email__c ='testdev@test.test';
            account2.E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com';
            account2.BIC__c ='1';
            account2.Geschueftsfuehrer__c=mb.id;
            Database.insert(account2, dml2);

            Contact contact2 = TestDataFactory.createContact(false,'Paul', 'Fastest', 'tesss123d@mail.com');
            contact2.AccountID = account2.id;
            contact2.Gesch_ftsbeziehung__c = 'Kunde';
            Database.insert(contact2, dml2);

            Contact con2 = TestDataFactory.createContact(false,'Paul', 'Smith', 'tesss123d@mail.com');
            con2.AccountID = account1.id;
            Database.insert(con2, dml2);

            Contact[] cons = new List<Contact>();

            cons.add(contact1);
            Contact newContact = TestDataFactory.createContact(false,'Lars', 'Slow', 'tesssd01@mail.com');
            newContact.AccountId = account2.Id;
            newContact.Gesch_ftsbeziehung__c = 'Interessent';
            newContact.Aus_Maklerportal__c = true;
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
}