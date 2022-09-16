@IsTest
public with sharing class AggregateVkcZahlungSchedulableTest {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.createDatevSettings();
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(false, TestDataFactory.createBautraeger(true).Id);
        immobilie.Bauart__c = 'Bestand';
        immobilie.Kaufpreiszahlung__c = 'Endfällig';
        insert immobilie;
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        TestDataFactory.createProvisionsverhandlung(true, acc.Id, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent};

        Opportunity opp = TestDataFactory.createOpportunity(false, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Geschlossene und gewonnene', 100000);
        opp.Abrechnung_ber__c = makler.Id;
        opp.Immobilienberater__c = makler.Id;
        opp.Datum_Kaufpreisf_lligkeitsschreiben__c = Date.today();
        insert opp;
    }

    @IsTest
    private static void testAggregationOnSchedule() {
        Opportunity opp = [SELECT Id, beurkundeter_Kaufpreis__c, Immobilie__c FROM Opportunity LIMIT 1];
        Test.startTest();
        SchedulableContext sc = null;
        AggregateVkcZahlungSchedulable job = new AggregateVkcZahlungSchedulable();
        job.execute(sc);
        Test.stopTest();

        System.assertEquals(opp.beurkundeter_Kaufpreis__c, [SELECT OffenerBetragEinmalzahlungen__c FROM Property__c WHERE Id = :opp.Immobilie__c].OffenerBetragEinmalzahlungen__c);
    }


    @IsTest
    private static void testAggregationScheduler() {
        Test.startTest();
        AggregateVkcZahlungSchedulable.schedule();
        Test.stopTest();
        
        System.assertEquals(1, [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :AggregateVkcZahlungSchedulable.getJobName()]);        
    }
}
