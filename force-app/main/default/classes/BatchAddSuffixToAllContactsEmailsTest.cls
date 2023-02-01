@isTest
public class BatchAddSuffixToAllContactsEmailsTest {
    @TestSetup
    static void makeData(){
        List<Contact> contactsToInsert =new List<Contact>();
        for(integer i=0; i<200; i++){
            contact con= TestDataFactory.createContact(
                false,
                'Test First '+String.valueOf(i),
                'Test Last '+String.valueOf(i),
                'TestEmail'+String.valueOf(i)+'@example.com'
            );
            contactsToInsert.add(con);
        }
        insert contactsToInsert;
    }   
    @isTest
    private static void test1(){
        Test.startTest();
        Database.executeBatch(new BatchAddSuffixToAllContactsEmails());
        Test.stopTest();
        
        List<contact> contactsToCheck=[
            SELECT id,email 
            FROM Contact 
        ];

        for(contact con : contactsToCheck){
            // System.Debug('email: '+con.email);
            System.assert(con.email.endsWith(BatchAddSuffixToAllContactsEmails.SUFFIX_TO_ADD));
        }
    }
}