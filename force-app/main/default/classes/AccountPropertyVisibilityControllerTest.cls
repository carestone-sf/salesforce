@IsTest
private class AccountPropertyVisibilityControllerTest {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.createDatevSettings();
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
    }
    
    @IsTest
    private static void testGetProperties() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.startTest();
        Assert.areEqual([SELECT COUNT() FROM Property__c WHERE Is_Public__c = true], AccountPropertyVisibilityController.getProperties(accountId).size());
        Test.stopTest();
    }

    @IsTest
    private static void testHideProperty() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id propertyId = [SELECT Id FROM Property__c WHERE Is_Public__c = true LIMIT 1].Id;
        Test.startTest();
        AccountPropertyVisibilityController.hideProperty(accountId, propertyId);
        Assert.areEqual(1, [SELECT COUNT() FROM HiddenProperty__c WHERE Account__c = :accountId AND Property__c = :propertyId]);
        Test.stopTest();
    }

    @IsTest
    private static void testUnhideProperty() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Id propertyId = [SELECT Id FROM Property__c WHERE Is_Public__c = true LIMIT 1].Id;
        insert new HiddenProperty__c(Account__c = accountId, Property__c = propertyId);
        Test.startTest();
        AccountPropertyVisibilityController.unhideProperty(accountId, propertyId);
        Assert.areEqual(0, [SELECT COUNT() FROM HiddenProperty__c WHERE Account__c = :accountId AND Property__c = :propertyId]);
        Test.stopTest();
    }
}
