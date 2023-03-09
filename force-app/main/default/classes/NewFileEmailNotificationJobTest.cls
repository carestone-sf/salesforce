@IsTest
private class NewFileEmailNotificationJobTest {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.createDatevSettings();
        Account acc = TestDataFactory.createAccount(true);
        TestDataFactory.createCommunityUser(acc.Id);
        TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
    }

    @IsTest
    private static void test() {
        Id immoId = [SELECT Id FROM Property__c LIMIT 1].Id;

        insert new ImmobilienDmsDatei__c(
            Name = 'Testdatei',
            Immobilie__c = immoId,
            DateiUrl__c = 'https://www.google.com/Test.pdf',
            DateiTyp__c = 'Dokumente',
            FileLastModifiedDate__c = DateTime.now().addHours(-5)
        );

        Test.startTest();
        NewFileEmailNotificationJob.schedule();
        Test.stopTest();

        System.assertEquals(1, new NewFileOverviewController().files.size());
    }
}
