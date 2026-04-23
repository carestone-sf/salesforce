@isTest
private class CreateNebenkostenzuschussActionTest {

    @TestSetup
    static void setup() {
        TestDataFactory.createNecessaryCustomSettings();
    }

    @isTest
    static void create_happyPath() {
        Opportunity opp = TestDataFactory.createOpportunity(true);

        Test.startTest();
        List<Id> result = CreateNebenkostenzuschussAction.create(new List<Id>{ opp.Id });
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should return one NKZ Id');
        Nebenkostenzuschuss__c nkz = [
            SELECT Opportunity__c FROM Nebenkostenzuschuss__c WHERE Id = :result[0]
        ];
        System.assertEquals(opp.Id, nkz.Opportunity__c, 'NKZ should reference the Opportunity');
    }

    @isTest
    static void create_nullInput() {
        Test.startTest();
        List<Id> result = CreateNebenkostenzuschussAction.create(null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Null input should return empty list');
    }

    @isTest
    static void create_emptyInput() {
        Test.startTest();
        List<Id> result = CreateNebenkostenzuschussAction.create(new List<Id>());
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Empty input should return empty list');
    }

    @isTest
    static void create_duplicatePrevention() {
        Opportunity opp = TestDataFactory.createOpportunity(true);
        NebenkostenzuschussService.createFromOpportunity(opp.Id);

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            CreateNebenkostenzuschussAction.create(new List<Id>{ opp.Id });
        } catch (NebenkostenzuschussService.NebenkostenzuschussException e) {
            exceptionThrown = true;
            System.assert(
                e.getMessage().contains('bereits ein aktiver Nebenkostenzuschuss'),
                'Expected duplicate message, got: ' + e.getMessage()
            );
        }
        Test.stopTest();

        System.assert(exceptionThrown, 'Should throw when an active NKZ already exists');
    }
}
