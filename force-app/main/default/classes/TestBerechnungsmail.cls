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
private class TestBerechnungsmail {

    static testMethod void myUnitTest() {
		Contact mb = new Contact();
		mb.FirstNAme = 'Frank';
		mb.LastName = 'Köpsell';
		mb.Email = 'witte@amstammtisch.de';
		mb.MaklerBetreuer_E_Mail__c = 'witte@amstammtisch.de';
		insert mb;
		Account acc = new Account();
		acc.Name = 'WH Maklerbetreuer - Frank Köpsell';
		acc.Email__c = 'witte@amstammtisch.de';
		acc.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
		acc.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
		acc.BIC__c  = '1';
		acc.Geschueftsfuehrer__c = mb.id;
		acc.Gesetzliche_MwSt_auf_Provisionszahlung__c = 0.4;
		acc.Hinweis_zur_MwSt__c = 'Vertrag';
		acc.IBAN__c = 'DE02120300000000202051';
		acc.Rechtsform__c = 'GbR';
		acc.Unternehmensname__c = 'CareStone';
		insert acc;
		mb.AccountId = acc.Id;
		update mb;
        
        Contact con1 = new Contact (LastName = 'test', accountID = acc.id, Email = 'test@test.test');
        insert con1;
        
        Property__c prop = new Property__c(Name = 'TestImmobilie', Place__c = 'Hannover', Zip_Code__c = '30159', Street__c = 'Am hohen Ufer 5A');
        insert prop;
        
		Appartment__c app = new Appartment__c(Name ='Test Appartment', Property__c = prop.ID, Area_sq_m__c = 15);
		insert app;
		
		Realty_User__c immoUser = new Realty_User__c(Name = 'test', Email__c = 'test@test.test', Login_Email__c = 'test@test.test', Password__c = 'test', Type__c = 'Normal Agency', Contact__c = con1.id);
		insert immoUser;
		
        Calculation__c calc = new Calculation__c(	Property__c = prop.id,
        											Appartment__c = app.id,
        											Starting__c = date.today(),
        											Sale_Price__c = 123456,
        											Repayment_Beginning__c = date.today(),
        											Agency__c = acc.id,
        											Brokers_Person__c = immoUser.id,
        											Last_Name__c = 'test',
        											First_Name__c = 'test');
    	insert calc;
    }
}