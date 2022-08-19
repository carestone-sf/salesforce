/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@
isTest
private class TestGenehmigungsProzess {
    static testMethod void testMe() {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Account acc = new Account(Name = 'Test Tester', Email__c ='test@test.test', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com');
        insert acc;

        Contact con = new Contact(FirstName = 'Frederik', LastName = 'Otto', AccountID = acc.ID, MailingStreet = 'Teststraße 33b', MailingCity = 'Garbsen', MailingPostalCode = '30827', Firma__c = 'keineFirma', LeadSource = 'FWS Lead', Gesch_ftsbeziehung__c = 'Interessent');
        Database.insert(con, dml);

        Contact realtyCon = new Contact(FirstName = 'Frederik', LastName = 'Otto', AccountID = acc.Id, MailingStreet = 'Teststraße', MailingCity = 'Garbsen', MailingPostalCode = '30827', Firma__c = 'keineFirma', LeadSource = 'FWS Lead');

        Database.insert(realtyCon, dml);

        Realty_User__c immoNutzer = new Realty_User__c(Name = 'Frederik Otto', Email__c = 'witte@amstammtisch.de', Login_Email__c = 'witte@amstammtisch.de', Password__c = 'test123 ', Type__c = 'Administrator', Contact__c = realtyCon.Id);
        insert immoNutzer;


        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // setup the data for the email

        email.subject = 'Test Job Applicant';
        email.fromname = 'FirstName LastName';
        env.fromAddress = 'witte@amstammtisch.de';

        email.plainTextBody = 'False\nwitte@amstammtisch.de\nInteressent\nHerr\nDr.\nFriedrich\nOtton\nStammtisch\nFrerrerer\n33 B\n30449\nHannover\nFalse\nwitte@amstammtisch.de\n0(511)33434\n+49173-6556973\nWH Landingpage\nFalse\nAn Kundenveranstaltung teilgenommen\n03.03.2015\nFalse';
        Genehmigungsprozess emailProcess = new Genehmigungsprozess();
        emailProcess.handleInboundEmail(email, env);

        Messaging.InboundEmail email2 = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();

        // setup the data for the email

        email2.subject = 'Test Job Applicant';
        email2.fromname = 'FirstName LastName';
        env2.fromAddress = 'witte@amstammtisch.de';

        email2.plainTextBody = 'True\nwitte@amstammtisch.de\nInteressent\nHerr\nDr.\nFrederik\nOtto\nStammtisch\nTeststraße\n33 B\n30827\nHannover\nFalse\nwitte@amstammtisch.de\n0(511)33434\n+49173-6556973\nWH Landingpage\nTrue\nAn Kundenveranstaltung teilgenommen\n03.03.2015\nFalse';
        Genehmigungsprozess emailProcess2 = new Genehmigungsprozess();
        emailProcess2.handleInboundEmail(email2, env2);

        // 80% Con

        Contact conD = new Contact(FirstName = 'Friedrich', LastName = 'Witte', AccountID = acc.ID, MailingStreet = 'Teststraße 33', MailingCity = 'Gerbsen', MailingPostalCode = '30827', Firma__c = 'keineFirma', LeadSource = 'FWS Lead', Gesch_ftsbeziehung__c = 'Interessent');
        Database.insert(conD, dml);

        System.debug(conD.MailingPostalCode + ' ' + conD.MailingStreet);


        Messaging.InboundEmail email3 = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env3 = new Messaging.InboundEnvelope();

        // setup the data for the email

        email3.subject = 'Test Job Applicant';
        email3.fromname = 'FirstName LastName';
        env3.fromAddress = 'witte@amstammtisch.de';

        email3.plainTextBody = 'False\nwitte@amstammtisch.de\nInteressent\nHerr\nDr.\nFriederik\nWitte\nStammtisch\nTesststraße\n33\n30827\nGaerbsen\nFalse\nwitter@amstammtisch.de\n0(511)33434\n+49173-6556973\nWH Landingpage\nTrue\nAn Kundenveranstaltung teilgenommen\n03.03.2015\nFalse';
        Genehmigungsprozess emailProcess3 = new Genehmigungsprozess();
        emailProcess3.handleInboundEmail(email3, env3);

    }

    static testMethod void testMe2() {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Account acc = new Account(Name = 'Test Tester', Email__c ='test@test.test', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com');
        insert acc;

        Contact con = new Contact(FirstName = 'Frederik', LastName = 'Otto', AccountID = acc.ID, MailingStreet = 'Teststraße 33b', MailingCity = 'Garbsen', MailingPostalCode = '30827', Firma__c = 'keineFirma', LeadSource = 'FWS Lead', Gesch_ftsbeziehung__c = 'Interessent');
        Database.insert(con, dml);

        Contact realtyCon = new Contact(FirstName = 'Frederik', LastName = 'Otto', AccountID = acc.Id, MailingStreet = 'Teststraße', MailingCity = 'Garbsen', MailingPostalCode = '30827', Firma__c = 'keineFirma', LeadSource = 'FWS Lead');

        Database.insert(realtyCon, dml);

        Realty_User__c immoNutzer = new Realty_User__c(Name = 'Frederik Otto', Email__c = 'witte@amstammtisch.de', Login_Email__c = 'witte@amstammtisch.de', Password__c = 'test123 ', Type__c = 'Administrator', Contact__c = realtyCon.Id);
        insert immoNutzer;


        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // setup the data for the email

        email.subject = 'Test Job Applicant';
        email.fromname = 'FirstName LastName';
        env.fromAddress = 'witte@amstammtisch.de';

        email.plainTextBody = 'False\nwitte@amstammtisch.de\nInteressent\nHerr\nDr.\nFriedrich\nOtton\nStammtisch\nFrerrerer\n33 B\n30449\nHannover\nFalse\nwitte@amstammtisch.de\n0(511)33434\n+49173-6556973\nWH Landingpage\nFalse\nAn Kundenveranstaltung teilgenommen\n03.03.2015\nFalse';
        Genehmigungsprozess emailProcess = new Genehmigungsprozess();
        emailProcess.handleInboundEmail(email, env);

        Messaging.InboundEmail email2 = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();

        // setup the data for the email

        email2.subject = 'Test Job Applicant';
        email2.fromname = 'FirstName LastName';
        env2.fromAddress = 'witte@amstammtisch.de';

        email2.plainTextBody = 'True\nwitte@amstammtisch.de\nVersicherungsmakler\nHerr\nDr.\nFrederik\nOtto\nTest tester\nTeststraße\n33 B\n30827\nHannover\nFalse\ntestmail@mail.com\n0(511)33434\n+49173-6556973\nWH Landingpage\nTrue\nAn Kundenveranstaltung teilgenommen\n03.03.2015\nFalse';
        Genehmigungsprozess emailProcess2 = new Genehmigungsprozess();
        emailProcess2.handleInboundEmail(email2, env2);

        // 80% Con

        Contact conD = new Contact(FirstName = 'Friedrich', LastName = 'Witte', AccountID = acc.ID, MailingStreet = 'Teststraße 33', MailingCity = 'Gerbsen', MailingPostalCode = '30827', Firma__c = 'keineFirma', LeadSource = 'FWS Lead', Gesch_ftsbeziehung__c = 'Interessent');
        Database.insert(conD, dml);

        System.debug(conD.MailingPostalCode + ' ' + conD.MailingStreet);


        Messaging.InboundEmail email3 = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env3 = new Messaging.InboundEnvelope();

        // setup the data for the email

        email3.subject = 'Test Job Applicant';
        email3.fromname = 'FirstName LastName';
        env3.fromAddress = 'witte@amstammtisch.de';

        email3.plainTextBody = 'True\nwitte@amstammtisch.de\nInteressent\nHerr\nDr.\nFriederik\nWitte\nStammtisch\nTesststraße\n33\n30827\nGaerbsen\nFalse\nwitter@amstammtisch.de\n0(511)33434\n+49173-6556973\nWH Landingpage\nTrue\nAn Kundenveranstaltung teilgenommen\n03.03.2015\nFalse';
        Genehmigungsprozess emailProcess3 = new Genehmigungsprozess();
        emailProcess3.handleInboundEmail(email3, env3);

    }

    static testMethod void testPostbankMakler() {
Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Account acc = new Account(Name = 'Test Tester', Email__c ='test@test.test', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com');
        insert acc;

        Contact con = new Contact(FirstName = 'Frederik', LastName = 'Otto', AccountID = acc.ID, MailingStreet = 'Teststraße 33b', MailingCity = 'Garbsen', MailingPostalCode = '30827', Firma__c = 'keineFirma', LeadSource = 'FWS Lead', Gesch_ftsbeziehung__c = 'Interessent');
        Database.insert(con, dml);

        Contact realtyCon = new Contact(FirstName = 'Frederik', LastName = 'Otto', AccountID = acc.Id, MailingStreet = 'Teststraße', MailingCity = 'Garbsen', MailingPostalCode = '30827', Firma__c = 'keineFirma', LeadSource = 'FWS Lead');

        Database.insert(realtyCon, dml);

        Realty_User__c immoNutzer = new Realty_User__c(Name = 'Frederik Otto', Email__c = 'witte@amstammtisch.de', Login_Email__c = 'witte@amstammtisch.de', Password__c = 'test123 ', Type__c = 'Administrator', Contact__c = realtyCon.Id);
        insert immoNutzer;

        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // setup the data for the email

        email.subject = 'Test Job Applicant';
        email.fromname = 'FirstName LastName';
        env.fromAddress = 'witte@amstammtisch.de';

        email.plainTextBody = 'False\nwitte@amstammtisch.de\nVersicherungsmakler\nHerr\nDr.\nFriedrich\nOtton\nPostbank\nFrerrerer\n33 B\n30449\nHannover\nFalse\nwitte@amstammtisch.de\n0(511)33434\n+49173-6556973\nWH Landingpage\nFalse\nAn Kundenveranstaltung teilgenommen\n03.03.2015\nFalse';
        Genehmigungsprozess emailProcess = new Genehmigungsprozess();
        emailProcess.handleInboundEmail(email, env);
    }

}