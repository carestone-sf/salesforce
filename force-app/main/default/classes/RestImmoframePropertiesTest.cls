@isTest
private class RestImmoframePropertiesTest {
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
        RestImmoframeProperties.getImmoframeProperties();
        Test.stopTest();
    }
}