@isTest
                    
public class GlobalSearchControllerTest {

    public static testMethod void testControllerWithRecords() {

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;

        Account acc1 = new Account(Name = 'test', Email__c ='test@test.test');
        Database.insert(acc1, dml);
        
        Account account1 = new Account(Name='test', ParentID = acc1.id, OwnerID = '005b0000000YeZDAA0', Maklerbetreuer_Wirtschaftshaus__c = 'Lars Wagner');
        Database.insert(account1, dml);

        Contact contact1 = new Contact(AccountID=account1.id, FirstName = 'test', LastName='contact1', Gesch_ftsbeziehung__c = 'Interessent');
        Database.insert(contact1, dml);
        
        Lead lead1 = new Lead(LastName = 'test');
        Database.insert(lead1, dml);
        
        GlobalSearchController gS = new GlobalSearchController();
        
        gS.searchValue = 'test';
        gS.search();
        
        gS.getPossibleDups();
        gS.getPossibleDupLeads();
        gS.getPossibleDupAccounts();

    }    
    
    public static testMethod void testControllerWithout() {

        GlobalSearchController gS = new GlobalSearchController();
        
        gS.getPossibleDups();
        gS.getPossibleDupLeads();
        gS.getPossibleDupAccounts();

    }    
    
}