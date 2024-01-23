@IsTest
private class BatchAggregateImmoPaymentTest {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.createDatevSettings();
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(false, TestDataFactory.createBautraeger(true).Id);
        immobilie.Kaufpreiszahlung__c = 'Endfällig';
        insert immobilie;
        Appartment__c appartment = TestDataFactory.createAppartment(false, immobilie.Id);
        appartment.Additional_Costs__c = 10000;
        insert appartment;

        TestDataFactory.createProvisionsverhandlung(true, acc.Id, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent};

        Opportunity opp = TestDataFactory.createOpportunity(false, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Geschlossene und gewonnene', 100000);
        opp.Abrechnung_ber__c = makler.Id;
        opp.Immobilienberater__c = makler.Id;
        opp.Datum_Kaufpreisf_lligkeitsschreiben__c = Date.today().addDays(-10);
        insert opp;
    }
    
    @IsTest
    private static void testAggregation() {
        Test.startTest();
        Database.executeBatch(new BatchAggregateImmoPayment());
        Test.stopTest();

        System.assertEquals(94500, [SELECT OffenerBetragGesamt__c FROM Property__c LIMIT 1].OffenerBetragGesamt__c);
    }

    @IsTest
    private static void testSchedule() {

        Test.startTest();
        SchedulableContext sc = null;
        BatchAggregateImmoPayment job = new BatchAggregateImmoPayment();
        job.execute(sc);
        Test.stopTest();

        System.assertEquals(94500, [SELECT OffenerBetragGesamt__c FROM Property__c LIMIT 1].OffenerBetragGesamt__c);
    }
}