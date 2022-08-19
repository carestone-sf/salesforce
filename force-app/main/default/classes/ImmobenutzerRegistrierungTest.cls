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
private class ImmobenutzerRegistrierungTest {
    static testMethod void testMe() {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;

        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

        // setup the data for the email

        email.subject = 'Test Job Applicant';
        email.fromname = 'FirstName LastName';
        env.fromAddress = 'witte@amstammtisch.de';

        email.plainTextBody = 'register\nFrederik Witte\nwitte@amstammtisch.de\n051512515215\nHyposerv';
        ImmobenutzerRegistrierung emailProcess = new ImmobenutzerRegistrierung();
        emailProcess.handleInboundEmail(email, env);

        Messaging.InboundEmail email2 = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env2 = new Messaging.InboundEnvelope();

        // setup the data for the email

        email2.subject = 'Test Job Applicant';
        email2.fromname = 'FirstName LastName';
        env2.fromAddress = 'witte@amstammtisch.de';

        email2.plainTextBody = 'password\nwitte@amstammtisch.de';
        ImmobenutzerRegistrierung emailProcess2 = new ImmobenutzerRegistrierung();
        emailProcess2.handleInboundEmail(email2, env2);
        
     

    }
}