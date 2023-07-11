@isTest
private class TestTeilobjekte {

    @testSetup static void makeData() {
        //TODO create all data for methods here, atm just partially created

        Account bautraeger = TestDataFactory.createBautraeger(true);

        Account makler = TestDataFactory.createAccount(true,'Makler GmbH');
        Contact mb = TestDataFactory.createMakler(true, 'Makler');

        Property__c prop = TestDataFactory.createProperty(true,bautraeger.Id);
        Appartment__c app = TestDataFactory.createAppartment(true,prop.Id, 'Test App');

        Contact potKun = TestDataFactory.createContact(true, 'Tvvsta', 'Tekoeric');

        Opportunity opp = TestDataFactory.createOpportunity(true, potKun.Id, mb.Id, prop.Id, app.Id, 'Reservierung angefragt');
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
        Appartment__c app = [SELECT Id, Status__c FROM Appartment__c WHERE Name = 'Test App' LIMIT 1];

        Test.startTest();
        app.Status__c = 'Reserviert';
        update app;
        Test.stopTest();
    }
}