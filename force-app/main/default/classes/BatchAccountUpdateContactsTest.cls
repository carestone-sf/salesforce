@isTest
public class BatchAccountUpdateContactsTest {

    @TestSetup
    static void setup(){
        Account acc = TestDataFactory.createAccount(true);
        contact con= TestDataFactory.createMakler(true,acc.Id);
        Contact mb = TestDataFactory.createContact(true, 'Makler', 'Betreuer', 'mb@carestone.com');

    }

    @isTest
    private static void testIfContactsAreUpdated(){
        Account acc = [SELECT Id, OwnerId, Maklerbetreuer_Wirtschaftshaus_2__c
        FROM Account][0];
        
        Assert.isNull(acc.Maklerbetreuer_Wirtschaftshaus_2__c,'Maklerbetreuer should be empty at start.');

        //Set new Owner of Account
        User user = TestDataFactory.createTestuser(true, 'test');
        acc.OwnerId = user.Id;

        //Set Maklerbetreuer of Account
        Contact mb = [SELECT ID FROM Contact WHERE Email = 'mb@carestone.com'][0];
        acc.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
        update acc;

        List<Account> accList = new List<Account>();
        accList.add(acc);
        
        Test.startTest();
        BatchAccountUpdateContacts.updateContacts(accList);
        Test.stopTest();

        Contact con = [SELECT ID, OwnerId, MaklerBetreuer_E_Mail__c FROM Contact WHERE AccountId = :acc.Id][0];
        Assert.isTrue(con.MaklerBetreuer_E_Mail__c == 'mb@carestone.com','Contact Maklerbetreuer did not change!');
        Assert.isTrue(con.OwnerId == user.Id,'Contact Owner did not change!');

    }
}