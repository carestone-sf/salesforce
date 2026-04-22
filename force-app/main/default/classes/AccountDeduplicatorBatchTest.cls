@IsTest
private class AccountDeduplicatorBatchTest {

    static Id parentId;

    @TestSetup
    static void setupData() {
        Account parent = TestDataFactory.createAccount(true);
        parentId = parent.Id;

        List<Account> dupes = new List<Account>();

        for (Integer i = 0; i < 3; i++) {
            Account acc = TestDataFactory.createAccount(false);
            acc.Name = 'DupliCompany';
            acc.ParentId = parentId;
            dupes.add(acc);
        }

        for (Integer i = 0; i < 2; i++) {
            Account acc = TestDataFactory.createAccount(false);
            acc.Name = 'Anderer Kunde';
            acc.ParentId = parentId;
            dupes.add(acc);
        }

        Account unique = TestDataFactory.createAccount(false);
        unique.Name = 'Einzelkunde GmbH';
        unique.ParentId = parentId;
        dupes.add(unique);

        insert dupes;
    }

    @IsTest
    static void testDeduplicationWithDynamicParent() {
        Account parentAcc = [SELECT Id FROM Account WHERE ParentId = null LIMIT 1];
        Test.startTest();
        Database.executeBatch(new AccountDeduplicatorBatch(parentAcc.Id), 200);
        Test.stopTest();

        List<Account> remaining = [
            SELECT Name FROM Account WHERE ParentId = :parentAcc.Id
        ];

        // System.assertEquals(3, remaining.size(), 'Exactly 3 accounts should remain');

        // Set<String> names = new Set<String>();
        // for (Account acc : remaining) {
        //     names.add(acc.Name);
        // }

        // System.assert(names.contains('DupliCompany'));
        // System.assert(names.contains('Anderer Kunde'));
        // System.assert(names.contains('Einzelkunde GmbH'));
    }
}