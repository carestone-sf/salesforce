@isTest
public class DatevControllerTest {
    
    testMethod static void testGenerateCsv(){
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        // Maklerbetreuer + Account erstellen
        Contact mb = new Contact();
        mb.FirstNAme = 'Frank';
        mb.LastName = 'Köpsell';
        mb.Email = 'f.witte@wirtschaftshaus.de';
        mb.MaklerBetreuer_E_Mail__c = 'f.witte@wirtschaftshaus.de';
        mb.Ist_Maklerbetreuer_WH__c = true;
        mb.Gesch_ftsbeziehung__c = 'Mitarbeiter WH';
        Database.insert(mb, dml);
        Account acc = new Account();
        acc.Name = 'WH Maklerbetreuer - Frank Köpsell';
        acc.Email__c = 'f.witte@wirtschaftshaus.de';
        acc.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
        acc.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
        Database.insert(acc, dml);
        mb.AccountId = acc.Id;
        Database.update(mb, dml);
        // Accounts erstellen
        List<Account> accs = TestDataFactory.createAccounts(true, acc.Id, 1);
        // Interessenten erstellen
        Contact interessentOne = TestDataFactory.createInteressent(false, accs[0].Id);
        interessentOne.LastName += '1';
        Database.insert(interessentOne, dml);
        Contact interessentTwo = TestDataFactory.createInteressent(false, accs[0].Id);
        interessentOne.LastName += '2';
        Database.insert(interessentTwo, dml);
        DatevController.sendDatevStammdatenCsvAsEmail(Date.today(), Date.today(), 'debitors');
        DatevController.sendDatevStammdatenCsvAsEmail(Date.today(), Date.today(), 'creditors');
    }
    
}