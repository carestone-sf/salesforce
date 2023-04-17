@isTest
private class ImmoframePropertiesServiceTest {
    @TestSetup
    static void makeData() {
        Account bautraeger = TestDataFactory.createBautraeger(true);
        Property__c property = TestDataFactory.createProperty(true, bautraeger.Id);
        Appartment__c app = TestDataFactory.createAppartment(true, property.Id);
        TestDataFactory.createImmobilienDmsDatei(true, property.Id, 'Dokumente');
        TestDataFactory.createImmobilienDmsDatei(true, property.Id, 'Bilder');
    }

    @isTest
    private static void testGetImmoframeProperties() {
        Test.startTest();
        ImmoframePropertiesService.getImmoframeProperties();
        Test.stopTest();
    }
}