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
@isTest
private class
TestImmoRechnerBenutzer {

	static testMethod void testImmonutzer()
	{
        Contact contact1 = new Contact( LastName='test');
        insert contact1;

        Account account1 = TestDataFactory.createAccount(true);


        contact1.AccountId = account1.id;
        update contact1;


        Realty_User__c rUser = new Realty_User__c(Active__c = false,
                                                    Email__c = 'test@test.test',
                                                    Login_Email__c = 'test@test.test',
                                                    Password__c = '1234',
                                                    Type__c = 'Normal Agency',
                                                    Name='albertus claudius',
                                                    Herkunft__c = 'HypoServ');

        insert rUser;

        rUser.Password__c = 'a';
        update rUser;

        rUser.Passwort_vergessen__c = true;
        update rUser;
	}

	static testMethod void testImmonutzer2()
	{
        Account account1 = TestDataFactory.createAccount(true);

        Contact contact1 = TestDataFactory.createInteressent(true, account1.Id);


        Realty_User__c rUser = new Realty_User__c(Active__c = false,
                                                    Email__c = 'test@test.test',
                                                    Login_Email__c = 'test@test.test',
                                                    Password__c = '1234',
                                                    Type__c = 'Normal Agency',
                                                    Name='albertus claudius',
                                                    Herkunft__c = 'HypoServ');

        insert rUser;

        rUser.Active__c = true;
        rUser.Contact__c = contact1.id;
        update rUser;
	}

    static testMethod void testImmonutzerMatchingContactMail()
    {

        Account account1 = TestDataFactory.createAccount(true);

        Contact contact1 = TestDataFactory.createInteressent(true, account1.Id);


        Realty_User__c rUser = new Realty_User__c(Active__c = false,
                Email__c = 'test@test.test',
                Login_Email__c = 'test@test.test',
                Password__c = '1234',
                Type__c = 'Normal Agency',
                Name='albertus claudius',
                Herkunft__c = 'HypoServ');

        insert rUser;

        rUser.Active__c = true;
        rUser.Contact__c = contact1.id;
        update rUser;
    }

    static testMethod void myUnitTest() {
        Realty_User__c rUser2 = new Realty_User__c(
                                                    Email__c = 'testmail@nauk.com',
                                                    Login_Email__c = 'test@test.test',
                                                    Type__c = 'Normal Agency',Name='Lydia Claudia',Password__c='1');
        insert rUser2;

        rUser2.Passwort_vergessen__c = true;
        update rUser2;

        rUser2.Password__c = 'a';
        update rUser2;

	}
}