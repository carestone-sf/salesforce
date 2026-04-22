@IsTest
private class AccountPotentialAnalysisBatchTest {

    @IsTest
    static void testBatchUpdatesAccountsFlag() {
        // Arrange: create a parent and one matching child (both Accounts only)
        Account parentAcc = new Account(Name = 'Parent');
        insert parentAcc;

        Account child = new Account(
            Name = 'Child',
            ParentId = parentAcc.Id,
            PotenzialanalyseStarten__c = false,
            PotenzialanalyseErfasst__c = false
        );
        insert child;

        // Point the batch to our test parent (override default hardcoded id)
        AccountPotentialAnalysisBatch.PARENT_ID = parentAcc.Id;

        // Act
        Test.startTest();
            Database.executeBatch(new AccountPotentialAnalysisBatch(), 50);
        Test.stopTest();

        // Assert
        Account reloaded = [
            SELECT PotenzialanalyseStarten__c
            FROM Account
            WHERE Id = :child.Id
        ];
        System.assertEquals(
            true,
            reloaded.PotenzialanalyseStarten__c,
            'Child account should be marked to start Potenzialanalyse.'
        );
    }

    @IsTest
    static void testScheduleMeSetsDaily10pm() {
        Test.startTest();
            String jobId = AccountPotentialAnalysisBatch.scheduleMe();
        Test.stopTest();

        CronTrigger ct = [
            SELECT CronExpression, State
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals('0 0 22 * * ?', ct.CronExpression, 'Must fire daily at 22:00.');
        System.assertEquals('WAITING', ct.State, 'Scheduled job should be queued.');
    }
}