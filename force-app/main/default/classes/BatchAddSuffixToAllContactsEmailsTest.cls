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
    private static void testIfSuffixWasAdded(){
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
    @isTest
    private static void testIfContactsWithNullEmailsNotCausingErrors(){
        Map<id,contact> contacts=new Map<id,contact>([
            SELECT id,email 
            FROM Contact 
            limit 5
        ]);

        for(contact con : contacts.values()){
            con.email=null;
        }
        update contacts.values();
        Test.startTest();
        string error;
        try {       
            Database.executeBatch(new BatchAddSuffixToAllContactsEmails());
        } catch (Exception ex) {
            error=ex.getMessage();
        }
        finally{
            system.assertEquals(null,error);
        }
        Test.stopTest();
        
        List<contact> contactsToCheck=[
            SELECT id,email 
            FROM Contact 
            WHERE id = :contacts.keySet()
        ];

        for(contact con : contactsToCheck){
            con.email=null;
            System.assertEquals(null,con.email);
        }
    }
}