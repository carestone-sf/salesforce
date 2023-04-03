@isTest
public with sharing class BatchSwitchPlannedCertificationValueTest {
    @TestSetup
    static void makeData() {
        List<Opportunity> opportunitiesToInsert = new List<Opportunity>();
        Account acc = TestDataFactory.createAccount(true);
        Contact makler = TestDataFactory.createMakler(true, acc.id);
        Contact interessant = TestDataFactory.createInteressent(true, acc.id);
        Account bautraeger = testDataFactory.createBautraeger(true);
        Property__c property = TestDataFactory.createProperty(true, bautraeger.id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, property.id);
        Appartment__c appartment2 = TestDataFactory.createAppartment(true, property.id);
        Appartment__c appartment3 = TestDataFactory.createAppartment(true, property.id);

        Opportunity opp1 = TestDataFactory.createOpportunity(true, interessant.id, makler.id, property.id, appartment.id);
        opp1.PlannedCertification__c = BatchSwitchPlannedCertificationValue.PLANNED_CERTIFICATION_VALUE_CURRENT_MONTH;

    }
    @isTest
    private static void testBatchWhenBatchSwitchPlannedCertificationIsCurrenthMonth() {
        Test.startTest();
        BatchSwitchPlannedCertificationValue batch = new BatchSwitchPlannedCertificationValue();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        Opportunity opportunityAfterBatch = [
                SELECT id, PlannedCertification__c
                FROM Opportunity
                Limit 1
        ];
        system.assertEquals(null, opportunityAfterBatch.PlannedCertification__c);
    }
    @isTest
    private static void testBatchWhenBatchSwitchPlannedCertificationIsNextMonth() {
        Opportunity opportunityBeforeBatch = [
                SELECT id, PlannedCertification__c
                FROM Opportunity
                Limit 1
        ];
        opportunityBeforeBatch.PlannedCertification__c = BatchSwitchPlannedCertificationValue.PLANNED_CERTIFICATION_VALUE_NEXT_MONTH;
        update opportunityBeforeBatch;
        Test.startTest();
        BatchSwitchPlannedCertificationValue batch = new BatchSwitchPlannedCertificationValue();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        Opportunity opportunityAfterBatch = [
                SELECT id, PlannedCertification__c
                FROM Opportunity
                Limit 1
        ];
        system.assertEquals(BatchSwitchPlannedCertificationValue.PLANNED_CERTIFICATION_VALUE_CURRENT_MONTH, opportunityAfterBatch.PlannedCertification__c);
    }
    @isTest
    private static void testBatchWhenBatchSwitchPlannedCertificationIsCurrenthMonthAfterNext() {
        Opportunity opportunityBeforeBatch = [
                SELECT id, PlannedCertification__c
                FROM Opportunity
                Limit 1
        ];
        opportunityBeforeBatch.PlannedCertification__c = BatchSwitchPlannedCertificationValue.PLANNED_CERTIFICATION_VALUE_MONTH_AFTER_NEXT;
        update opportunityBeforeBatch;
        Test.startTest();
        BatchSwitchPlannedCertificationValue batch = new BatchSwitchPlannedCertificationValue();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        Opportunity opportunityAfterBatch = [
                SELECT id, PlannedCertification__c
                FROM Opportunity
                Limit 1
        ];
        system.assertEquals(BatchSwitchPlannedCertificationValue.PLANNED_CERTIFICATION_VALUE_NEXT_MONTH, opportunityAfterBatch.PlannedCertification__c);
    }
}