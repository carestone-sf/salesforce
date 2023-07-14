@isTest
public with sharing class CampaignTest {
    @TestSetup
    static void makeData() {
        // Accounts erstellen
        Account acc = TestDataFactory.createAccount(true);
        // Interessenten erstellen
        Contact interessentOne = TestDataFactory.createInteressent(true, acc.Id);
    }

    @isTest
    private static void createWebinarCampaign() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Campaign c = TestDataFactory.createCampaign(false);
        c.Type = 'Webinar';
        insert c;

        Test.startTest();
        TestDataFactory.createCampaignMember(true, con.Id, c.Id);
        Test.stopTest();
    }

    @isTest
    private static void createTelefonkampagneWebinarCampaign() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Campaign c = TestDataFactory.createCampaign(false);
        c.Type = 'Webinar Telefonkampagne';
        insert c;

        Test.startTest();
        TestDataFactory.createCampaignMember(true, con.Id, c.Id);
        Test.stopTest();
    }

    @isTest
    private static void createOtherCampaigns() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        Test.startTest();
        Campaign c = TestDataFactory.createCampaign(false);
        c.Type = 'Werbung';
        insert c;
        TestDataFactory.createCampaignMember(true, con.Id, c.Id);

        Campaign cP = TestDataFactory.createCampaign(false);
        cP.Name = 'Online-Seminar';
        cP.Type = 'Oberkampagne';
        insert cP;
        Campaign c2 = TestDataFactory.createCampaign(false);
        c2.Type = 'Online - Sachwertveranstaltung';
        c2.DateTime__c = DateTime.now();
        insert c2;

        Campaign cP2 = TestDataFactory.createCampaign(false);
        cP2.Name = 'Sachwertveranstaltung';
        cP2.Type = 'Oberkampagne';
        insert cP2;
        Campaign c3 = TestDataFactory.createCampaign(false);
        c3.Type = 'Sachwertveranstaltung';
        insert c3;

        Campaign cP3 = TestDataFactory.createCampaign(false);
        cP3.Name = 'Kundenveranstaltung';
        cP3.Type = 'Oberkampagne';
        insert cP3;
        Campaign c4 = TestDataFactory.createCampaign(false);
        c4.Type = 'Kundenveranstaltung';
        insert c4;

        Campaign cP4 = TestDataFactory.createCampaign(false);
        cP4.Name = 'Mediterraner Abend';
        cP4.Type = 'Oberkampagne';
        insert cP4;
        Campaign c5 = TestDataFactory.createCampaign(false);
        c5.Type = 'Mediterraner Abend';
        insert c5;

        Campaign cP5 = TestDataFactory.createCampaign(false);
        cP5.Name = 'Maklerzirkel';
        cP5.Type = 'Oberkampagne';
        insert cP5;
        Campaign c6 = TestDataFactory.createCampaign(false);
        c6.Type = 'Maklerzirkel';
        insert c6;

        Campaign cP6 = TestDataFactory.createCampaign(false);
        cP6.Name = 'Vertriebsevent/Aktionstag';
        cP6.Type = 'Oberkampagne';
        insert cP6;
        Campaign c7 = TestDataFactory.createCampaign(false);
        c7.Name = 'Fünfklusiv';
        insert c7;

        Campaign cP7 = TestDataFactory.createCampaign(false);
        cP7.Name = 'Seminar';
        cP7.Type = 'Oberkampagne';
        insert cP7;
        Campaign c8 = TestDataFactory.createCampaign(false);
        c8.Name = 'Intensivseminar';
        insert c8;

        Campaign cP8 = TestDataFactory.createCampaign(false);
        cP8.Name = 'Online-Seminar';
        cP8.Type = 'Oberkampagne';
        insert cP8;
        Campaign c9 = TestDataFactory.createCampaign(false);
        c9.Name = 'Grundlagenwebinar';
        insert c9;
        Campaign c10 = TestDataFactory.createCampaign(false);
        c10.Name = 'Online - Seminar';
        insert c10;
        Campaign c11 = TestDataFactory.createCampaign(false);
        c11.Name = 'ASI 15+';
        insert c11;
        Campaign c12 = TestDataFactory.createCampaign(false);
        c12.Name = 'Endkunden';
        insert c12;
        Campaign c13 = TestDataFactory.createCampaign(false);
        c13.Name = 'Webinar "Maklerportal';
        insert c13;
        Test.stopTest();
    }
}