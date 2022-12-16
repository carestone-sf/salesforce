@IsTest
private class OpportunityTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.createDatevSettings();
    }

    /*
    @IsTest
    private static void testApartmentCannotBeReservedTwice() {
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent};

        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Kontingent');
        System.debug([SELECT StageName FROM Opportunity WHERE Id = :opp.Id]);
        System.debug([SELECT Status__c FROM Appartment__c WHERE Id = :appartment.Id]);
        Opportunity oppTwo = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Kontingent');
        
        opp.StageName = 'Reserviert';
        update opp;

        System.assertEquals(opp.Id, [SELECT ReserviertFuer__c FROM Appartment__c WHERE Id = :appartment.Id].ReserviertFuer__c);
        System.assertEquals('Reserved', [SELECT Status__c FROM Appartment__c WHERE Id = :appartment.Id].Status__c);

        Test.startTest();
        try {
            oppTwo.StageName = 'Reserviert';
            update oppTwo;
        } catch(Exception ex) {
            System.debug(ex.getMessage());
            System.debug(OpportunityTriggerHandler.APARTMENT_RESERVED_ERROR.replace('{0}', opp.Name));
            System.assert(ex.getMessage().contains(OpportunityTriggerHandler.APARTMENT_RESERVED_ERROR.replace('{0}', opp.Name)));
        }
        Test.stopTest();
    }
    */

    @IsTest
    private static void testSetProvisionOnInsert() {
        Account acc = TestDataFactory.createAccount(false);
        Account abrechnungsAccount = TestDataFactory.createAccount(false);

        insert new List<Account> {acc, abrechnungsAccount};

        Contact abrechnungsMakler = TestDataFactory.createMakler(false, abrechnungsAccount.Id);    
        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent, abrechnungsMakler};

        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);

        TestDataFactory.createProvisionsverhandlung(true, abrechnungsAccount.Id, immobilie.Id);

        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        Test.startTest();
        Opportunity opp = TestDataFactory.createOpportunity(false, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Kontingent');
        opp.Abrechnung_ber__c = abrechnungsMakler.Id;
        opp.Immobilienberater__c = makler.Id;
        insert opp;
        Test.stopTest();

        opp = [SELECT Grundprovision_Provisionsverhandlung__c, Verkaufsprovision_Provisionsverhandlung__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(5.0, opp.Grundprovision_Provisionsverhandlung__c);
        System.assertEquals(10, opp.Verkaufsprovision_Provisionsverhandlung__c);
    }

    @IsTest
    private static void testSetStageOnInsert() {
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent};

        Test.startTest();
        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, null, 'Kontingent');
        Test.stopTest();

        System.assertEquals('Nachrücker', [SELECT StageName FROM Opportunity WHERE Id = :opp.Id].StageName);
    }

    @IsTest
    private static void testSetCampaignSource() {
        Campaign campaign = TestDataFactory.createCampaign(true);
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        interessent.Kampagnenquelle__c = campaign.Id;
        insert new List<Contact> {makler, interessent};

        Test.startTest();
        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Kontingent');
        Test.stopTest();

        System.assertEquals(campaign.Id, [SELECT CampaignId FROM Opportunity WHERE Id = :opp.Id].CampaignId);
    }

    @IsTest
    private static void testSetBeratertext() {
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent};

        Test.startTest();
        Opportunity opp = TestDataFactory.createOpportunity(false, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Kontingent');
        opp.Immobilienberater__c = makler.Id;
        insert opp;
        Test.stopTest();

        System.assertEquals(makler.Id, [SELECT Berater_text__c FROM Opportunity WHERE Id = :opp.Id].Berater_text__c);
    }

    @IsTest
    private static void testSetProjektbeauftragte() {
        Account acc = TestDataFactory.createAccount(true);
        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent};

        Realty_User__c immoUser = TestDataFactory.createImmoUser(true, makler.Id);

        Property__c immobilie = TestDataFactory.createProperty(false, TestDataFactory.createBautraeger(true).Id);
        immobilie.Projektbeauftragte__c = immoUser.Id;
        insert immobilie;
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        Test.startTest();
        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Kontingent');
        Test.stopTest();
        
        System.assertEquals(makler.Id, [SELECT Projektbeauftragte__c FROM Opportunity WHERE Id = :opp.Id].Projektbeauftragte__c);
    }

    @IsTest
    private static void testSetCustomerToContinouslyProtected() {
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent};

        Test.startTest();
        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Kaufvertragsunterlagen verschickt');
        Test.stopTest();

        System.assert([SELECT Dauerhaft_gesch_tzt__c FROM Contact WHERE Id = :interessent.Id].Dauerhaft_gesch_tzt__c);
    }

    @IsTest
    private static void testUpdateProvisionsWithOppValues() {
        User user = TestDataFactory.createCommunityUser();
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent};

        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Kaufvertragsunterlagen verschickt');
        Provision__c provi1 = TestDataFactory.createProvision(false, opp.Id, user.Id, makler.Id);
        Provision__c provi2 = TestDataFactory.createProvision(false, opp.Id, user.Id, makler.Id);
        insert new List<Provision__c> { provi1, provi2 };

        Test.startTest();
        opp.Kaufpreis_bezahlt__c = true;
        update opp;
        Test.stopTest();

        System.assertEquals(2, [SELECT COUNT() FROM Provision__c WHERE Verkaufschance__c = :opp.Id AND Kaufpreis_bezahlt__c = true]);

    }

    @IsTest
    private static void testIncreaseCustomerProtection() {
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent};

        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Kontingent');
        
        Test.startTest();
        opp.StageName = 'Reserviert';
        update opp;
        Test.stopTest();

        System.assertEquals(DateTimeHelper.checkAndSetDateTimeIfWeekend(System.today().addDays(OpportunityTriggerHandler.DEFAULT_RESERVATION_DURATION)), [SELECT reserviert_bis__c FROM Opportunity WHERE Id = :opp.Id].reserviert_bis__c);
        System.assert([SELECT Kunden_Maklerschutz__c FROM Contact WHERE Id = :interessent.Id].Kunden_Maklerschutz__c);
    }

    @IsTest
    private static void testOpportunityWasWOn() {
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        Contact interessent2 = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent, interessent2};

        TestDataFactory.createProvisionsverhandlung(true, acc.Id, immobilie.Id);

        Opportunity opp = TestDataFactory.createOpportunity(false, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Kontingent');
        opp.Immobilienberater__c = makler.Id;
        opp.Kunde2__c = interessent2.Id;
        insert opp;

        Test.startTest();
        opp.StageName = 'Geschlossene und gewonnene';
        update opp;
        Test.stopTest();

        System.assertEquals(2, [SELECT COUNT() FROM Contact WHERE LetzteImmobiliennummer__c = :immobilie.Objektnummer__c]);
    }

    @IsTest
    private static void testSetApartmentFieldsOnInsert() {
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent};

        TestDataFactory.createProvisionsverhandlung(true, acc.Id, immobilie.Id);
        
        Test.startTest();
        
        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Reserviert');
        appartment = [SELECT Status__c, Customer__c, Makler__c FROM Appartment__c WHERE Id = :appartment.Id];
        System.assertEquals(interessent.Id, appartment.Customer__c);
        System.assertEquals('Reserved', appartment.Status__c);

        Test.stopTest();
    }

    @IsTest
    private static void testSetApartmentFields() {
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        Contact interessent2 = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent, interessent2};

        TestDataFactory.createProvisionsverhandlung(true, acc.Id, immobilie.Id);

        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Reserviert');

        System.debug([SELECT Status__c, Customer__c, Makler__c FROM Appartment__c WHERE Id = :appartment.Id]);

        Test.startTest();
        
        opp.StageName = 'VKC ausgelaufen';
        opp.Grund_VKC_verloren__c = 'Interessent möchte sein Kapital jetzt anlegen';
        update opp;

        System.assertEquals(null, [SELECT Customer__c FROM Appartment__c WHERE Id = :appartment.Id].Customer__c);

        Opportunity opp2 = TestDataFactory.createOpportunity(true, interessent2.Id, makler.Id, immobilie.Id, appartment.Id, 'Kontingent');


        System.assertEquals('Kontingent', [SELECT Status__c FROM Appartment__c WHERE Id = :appartment.Id].Status__c);

        opp2.StageName = 'Reserviert';
        update opp2;
        System.assertEquals('Reserved', [SELECT Status__c FROM Appartment__c WHERE Id = :appartment.Id].Status__c);
        System.assertEquals(interessent2.Id, [SELECT Customer__c FROM Appartment__c WHERE Id = :appartment.Id].Customer__c);
        Test.stopTest();
    }

    @IsTest
    private static void testCreateZahlungseingangPdfOnZahlungseingangApproval() {
        User user = TestDataFactory.createCommunityUser();
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent};

        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Kaufvertragsunterlagen verschickt');

        Test.startTest();
        opp.ZahlungseingangApproved__c = true;
        update opp;
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM ContentVersion WHERE FirstPublishLocationId = :opp.Id AND Typ__c = 'Notar-Anschreiben']);
    }

    @IsTest
    private static void testClearNotarterminOnLostOpportunity() {
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        Contact interessent2 = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent, interessent2};

        TestDataFactory.createProvisionsverhandlung(true, acc.Id, immobilie.Id);

        Opportunity opp = TestDataFactory.createOpportunity(false, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Reserviert');
        opp.Notartermin__c = Date.today().addDays(-5);
        insert opp;

        Test.startTest();        
        opp.StageName = 'VKC ausgelaufen';
        opp.Grund_VKC_verloren__c = 'Interessent möchte sein Kapital jetzt anlegen';
        update opp;
        Test.stopTest();

        System.assertEquals(null, [SELECT Notartermin__c FROM Opportunity WHERE Id = :opp.Id].Notartermin__c);
    }

    @IsTest
    private static void testCumulatedProvisionAggregation() {
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        Contact interessent2 = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent, interessent2};

        TestDataFactory.createProvisionsverhandlung(true, acc.Id, immobilie.Id);

        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Reserviert');

        opp.Provisionsbasis__c = 500;
        opp.KumulierteProvisionExtern__c = 3;
        Test.startTest();
        update opp;
        Test.stopTest();

        Assert.isNotNull([SELECT SummeWertKumulierteProvisionExtern__c FROM Property__c WHERE Id = :opp.Immobilie__c].SummeWertKumulierteProvisionExtern__c);
    }
}
