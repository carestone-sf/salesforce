@isTest
public class BatchAccountUpdateStructureTest {

    @TestSetup
    static void setup(){
        //Create Dummy User
        User user = TestDataFactory.createTestuser(true, 'newOwner', 1);

        //Create Maklerbetreuer Contact
        Contact maklerbetreuer = TestDataFactory.createContact(true,'New','Maklerbetreuer','new@maklerbetreuer.de');

        //Create Parent Account
        Account acc = TestDataFactory.createAccount(false,'Parent',null);
        acc.OwnerId = user.Id;
        acc.Maklerbetreuer_Wirtschaftshaus_2__c = maklerbetreuer.Id;
        insert acc;

        //Create First Level Child Account
        Account childAcc1 = TestDataFactory.createAccount(false,'Child1',null);
        childAcc1.ParentId = acc.Id;
        insert childAcc1;

        //Create Second Level Child Account
        Account childAcc2 = TestDataFactory.createAccount(false,'Child2',null);
        childAcc2.ParentId = childAcc1.Id;
        insert childAcc2;

        

    }

    @isTest
    private static void testIfAccountsAreUpdated(){
        Account parentAcc = [SELECT Id, OwnerId, Maklerbetreuer_Wirtschaftshaus_2__c
                            FROM Account
                            WHERE Name = 'Parent'][0];
        List<Account> accList = new List<Account>();
        accList.add(parentAcc);
        
        Test.startTest();
        BatchAccountUpdateStructure.updateStructure(accList);
        Test.stopTest();

        //Check First Level Child for changes
        Account childAcc1 = [SELECT ID, OwnerId, Maklerbetreuer_Wirtschaftshaus_2__c
                            FROM Account
                            WHERE Name = 'Child1'];

        Assert.isTrue(childAcc1.OwnerId == parentAcc.OwnerId,'First Level Child Account OwnerId did not change!');

        Assert.isTrue(childAcc1.Maklerbetreuer_Wirtschaftshaus_2__c == parentAcc.Maklerbetreuer_Wirtschaftshaus_2__c,'First Level Child Account Maklerbetreuer did not change!');

        //Check Second Level Child for changes
        Account childAcc2 = [SELECT ID, OwnerId, Maklerbetreuer_Wirtschaftshaus_2__c
        FROM Account
        WHERE Name = 'Child2'];

        Assert.isTrue(childAcc2.OwnerId == parentAcc.OwnerId,'Second Level Child Account OwnerId did not change!');

        Assert.isTrue(childAcc2.Maklerbetreuer_Wirtschaftshaus_2__c == parentAcc.Maklerbetreuer_Wirtschaftshaus_2__c,'Second Level Child Account Maklerbetreuer did not change!');
    }
}