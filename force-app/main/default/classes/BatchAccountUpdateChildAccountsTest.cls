@isTest
public class BatchAccountUpdateChildAccountsTest {

    @TestSetup
    static void setup(){
        Account acc = TestDataFactory.createAccount(false,'Parent',null);
        acc.Email__c = 'parent@carestone.com';
        insert acc;

        Account childAcc = TestDataFactory.createAccount(false);
        childAcc.ParentId = acc.Id;
        childAcc.E_Mail_bergeordneter_Makler__c = 'child@carestone.com';
        insert childAcc;
    }

    @isTest
    private static void testIfAccountsAreUpdated(){
        Account parentAcc = [SELECT Id, Email__c
                            FROM Account
                            WHERE Name = 'Parent'][0];

        List<Account> accList = new List<Account>();
        accList.add(parentAcc);
        
        Test.startTest();
        BatchAccountUpdateChildAccounts.updateChildAccounts(accList);
        Test.stopTest();

        Account childAcc = [SELECT ID, E_Mail_bergeordneter_Makler__c
                            FROM Account
                            WHERE ParentId = :parentAcc.Id][0];

        Assert.isTrue(childAcc.E_Mail_bergeordneter_Makler__c == parentAcc.Email__c,'Child Account did not change!');
    }
}