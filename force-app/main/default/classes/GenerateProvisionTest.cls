@isTest
private class GenerateProvisionTest {

    @testSetup static void test_setup() {
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
            mb.Gesch_ftsbeziehung__c = 'Versicherungsmakler';
            insert mb;

            Account acc3 = TestDataFactory.createAccount(false, 'WH Maklerbetreuer - Frank Köpsell', null);
            acc3.Geschueftsfuehrer__c = mb.id;
            acc3.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
            acc3.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
            acc3.Gesetzliche_MwSt_auf_Provisionszahlung__c = 0.4;
            insert acc3;

            mb.AccountId = acc3.Id;
            update mb;
                
            Contact potKun = TestDataFactory.createContact(true,'Tvvsta', 'Tekoeeric', 'test@tester.de');
        
            Property__c immobilie = TestDataFactory.createProperty(false, null, 'Immobilie');    
            immobilie.Gesch_ftsf_hrer__c = mb.id;
            immobilie.Amtsgericht__c = 'test';
            immobilie.HRB__c = '123';
            immobilie.PVNotarterminStattgefunden__c = true;
            insert immobilie;

            Appartment__c app2 = TestDataFactory.createAppartment(true, immobilie.Id);
            
            Provisionsverhandlung__c provisionsverhandlung = TestDataFactory.createProvisionsverhandlung(true, acc3.Id, immobilie.Id);
            
            TestDataFactory.createDatevSettings();
            TestDataFactory.createNecessaryCustomSettings();
        }
    }

    @isTest static void test_update_prov() {
        System.debug('test');
        User testUser = TestDataFactory.createTestUser(true, 'TestAdmin', 2);
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
        
        Account acc3 = [SELECT Id FROM Account];
        Contact mb = [SELECT Id, OwnerId FROM Contact WHERE LastName = 'Köpsell'];
        Contact potKun = [SELECT Id FROM Contact WHERE LastName != 'Köpsell'];
        Property__c immobilie = [SELECT ID From Property__c];
        Appartment__c app2 = [SELECT ID From Appartment__c];
        Opportunity opp2 = Testdatafactory.createOpportunity(false, potKun.Id, mb.Id, immobilie.Id, app2.Id, 'Reservierung angefragt', 123123.23);
        opp2.Finanzierung__c = 'Finanzierung WH';
        opp2.Kaufdatum__c = System.Today();
        opp2.Makler__c = mb.Id;
        opp2.Immobilienberater__c = mb.Id;
        opp2.Abrechnung_ber__c = mb.Id;
        opp2.Maklerprovision__c = '4.5';
        opp2.Finanzierung_oder_Eigenkapitalnachweis__c = true;
        opp2.Nachweis_Barzahler__c = true;
        opp2.KV_eingegangen__c = true;
        opp2.Beratungsprotokoll__c = true;
        opp2.Risikobelehrung__c = true;
        opp2.KfwWunsch__c = 'Bestand';
        opp2.Overhead_Empf_nger__c = mb.Id;


        Test.startTest();
        insert opp2;
        Provision__c prov = Testdatafactory.createProvision(false, opp2.Id, mb.OwnerId, opp2.Makler__c);
        prov.Objekt__c = opp2.Immobilie__c;
        prov.Wohneinheit__c = opp2.Appartement__c;
        prov.Kunde__c = opp2.Potenzieller_Kunde__c;
        prov.Kaufpreis__c = opp2.Provisionsbasis__c;
        insert prov;

        opp2.StageName = 'Geschlossene und gewonnene';
        opp2.Notartermin__c = Date.today();
        update opp2;
        Test.stopTest();
        Opportunity newOpp = [SELECT Id, Maklerprovision__c, PRovisionsbasis__c, Makler__c FROM Opportunity WHERE Id =:opp2.Id];
        newOPp.Maklerprovision__c = '5.5';
        newOpp.Provisionsbasis__c = 12323.32;
        newOpp.Makler__c = potKun.Id;
        newOpp.Immobilienberater__c = mb.Id;
        update newOpp;

        System.debug(LoggingLevel.ERROR,[SELECT Id FROM Provision__c WHERE Verkaufschance__c =: opp2.Id].size());
        }

    }

    @isTest static void test_update_prov2() {
        System.debug('test');
        User testUser = TestDataFactory.createTestUser(true, 'TestAdmin', 3);
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
        Account acc3 = [SELECT Id FROM Account];
        Contact mb = [SELECT Id, OwnerId FROM Contact WHERE LastName = 'Köpsell'];
        mb.Gesch_ftsbeziehung__c = null;
        update mb;
        Contact potKun = [SELECT Id FROM Contact WHERE LastName != 'Köpsell'];
        Property__c immobilie = [SELECT ID From Property__c];
        Appartment__c app2 = [SELECT ID From Appartment__c];
        Opportunity opp2 = Testdatafactory.createOpportunity(false, potKun.Id, mb.Id, immobilie.Id, app2.Id, 'Reservierung angefragt', 123123.23);
        opp2.Finanzierung__c = 'Finanzierung WH';
        opp2.Kaufdatum__c = System.Today();
        opp2.Makler__c = mb.Id;
        opp2.Immobilienberater__c = mb.Id;
        opp2.Abrechnung_ber__c = mb.Id;
        opp2.Maklerprovision__c = '4.5';
        opp2.Finanzierung_oder_Eigenkapitalnachweis__c = true;
        opp2.Nachweis_Barzahler__c = true;
        opp2.KV_eingegangen__c = true;
        opp2.Beratungsprotokoll__c = true;
        opp2.Risikobelehrung__c = true;
        opp2.Overhead_Empf_nger__c = mb.Id;

        Test.startTest();
        insert opp2;
        Provision__c prov = Testdatafactory.createProvision(false, opp2.Id, mb.OwnerId, opp2.Makler__c);
        prov.Objekt__c = opp2.Immobilie__c;
        prov.Wohneinheit__c = opp2.Appartement__c;
        prov.Kunde__c = opp2.Potenzieller_Kunde__c;
        prov.Kaufpreis__c = opp2.Provisionsbasis__c;
        insert prov;

        opp2.StageName = 'Geschlossene und gewonnene';
        update opp2;
        Test.stopTest();
        Opportunity newOpp = [SELECT Id, Maklerprovision__c, PRovisionsbasis__c, Makler__c FROM Opportunity WHERE Id =:opp2.Id];
        newOPp.Maklerprovision__c = '5.5';
        newOpp.Provisionsbasis__c = 12323.32;
        newOpp.Makler__c = potKun.Id;
        newOpp.Immobilienberater__c = mb.Id;
        update newOpp;

        System.debug(LoggingLevel.ERROR,[SELECT Id FROM Provision__c WHERE Verkaufschance__c =: opp2.Id].size());
        }

    }

}