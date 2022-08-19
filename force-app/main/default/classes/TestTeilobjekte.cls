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
private class TestTeilobjekte {

@testSetup static void methodName() {
    Account account1 = new Account(Name='test account', OwnerID = '005b0000001V30P', Email__c = 'test@mail.com', E_Mail_bergeordneter_Makler__c = 'tester@test.de');
        insert account1;

        Property__c prop = new Property__c(Name = 'TestImmobilie',  Account__c = account1.id);
        insert prop;

    Appartment__c app = new Appartment__c(Name ='Test Appartment', Property__c = prop.ID, Area_sq_m__c = 15, Wert_Einrichtung_in_Euro__c=15.00,Purchase_Price__c=150000.0);
    insert app;
    Contact potKun = new Contact();
        potKun.FirstName = 'Tvvsta';
        potKun.LastName = 'Tekoeeric';
        potKun.Email ='test@tester.de';
        insert potKun;

        Account acc2 = new Account();
        acc2.Name = 'Makler';
        acc2.Email__c = 'test2@tester.de';
        acc2.E_Mail_bergeordneter_Makler__c = 'tester@test.de';
        acc2.MAklerbetreuer_Wirtschaftshaus_2__c = potKun.Id;
        insert acc2;

        Contact makler = new Contact();
        makler.FirstName = 'Test';
        makler.LastName = 'Tester';
        makler.AccountId = acc2.Id;
        insert makler;
}
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Account account1 = new Account(Name='test account', OwnerID = '005b0000001V30P', Email__c = 'test@mail.com', E_Mail_bergeordneter_Makler__c = 'tester@test.de');
        insert account1;

        Property__c prop = new Property__c(Name = 'TestImmobilie',  Account__c = account1.id);
        insert prop;

        Appartment__c app = new Appartment__c(Name ='Test Appartment', Property__c = prop.ID, Area_sq_m__c = 15, Opt_Zusatzkosten_auf_Kaufpreis_addieren__c = true, Afa_Art__c = 0, AFA_Total__c = 0, Depreciation_Value__c = 0, Admin_Costs_Increase_After_Years__c = 0, Admin_Costs_Increase_In__c = 0, Purchase_Price__c = 123, Wert_Photovoltaik_Anlage__c = 23, Value_Parking_Space__c = 0, wert_k_che__c = 0);
        insert app;

        List<Appartment__c> appToUpdate= new List<Appartment__c>();
        for(Appartment__c app2: [SELECT Status__c FROM Appartment__c WHERE Property__c = :prop.id]){
            app2.Status__c = 'Verkauft';
            appToUpdate.add(app2);

        }
        update appToUpdate;
    }

    static testMethod void testStatusChange() {
        // TO DO: implement unit test
        Account account1 = new Account(Name='test account', OwnerID = '005b0000001V30P', Email__c = 'test@mail.com', E_Mail_bergeordneter_Makler__c = 'tester@test.de');
        insert account1;

        Property__c prop = new Property__c(Name = 'TestImmobilie',  Account__c = account1.id);
        insert prop;

    Appartment__c app = new Appartment__c(Name ='Test Appartment', Property__c = prop.ID, Area_sq_m__c = 15);
    insert app;
    Contact potKun = [SELECT FirstName, LastName FROM Contact WHERE LastName = 'Tekoeeric'];
    Account acc2 = [SELECT Name FROM Account WHERE Name = 'Makler'];
    Contact makler = [SELECT FirstName, LastName, AccountId FROM Contact WHERE LastName = 'Tester'];
    Opportunity opp3 = new Opportunity();
        opp3.Name = 'Test VKC2';
        opp3.AccountId = acc2.Id;
        opp3.Potenzieller_Kunde__c = potKun.Id;
        opp3.CloseDate = System.today().addDays(1);
        opp3.StageName = 'Reservierung angefragt';
        opp3.Immobilie__c = prop.Id;
        opp3.Appartement__c = app.Id;
        opp3.Finanzierung__c = 'Barzahler';
        opp3.Makler__c = makler.Id;
        insert opp3;
    app.Status__c = 'Reserviert';
    update app;

    }
}