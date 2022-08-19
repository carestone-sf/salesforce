@isTest
private class CreateMultipleRecordsControllerTest {
    private static testMethod void testGetRecords() {
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
        acc.Name = 'Makler GmbH%';
        acc.Email__c = 'f.witte@wirtschaftshaus.de';
        acc.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
        acc.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
        Database.insert(acc, dml);
        mb.AccountId = acc.Id;
        Database.update(mb, dml);

        Id interessentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Interessent').getRecordTypeId();
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Gesch_ftsbeziehung__c = 'Interessent';
        con.FirstName = 'Max';
        con.MailingStreet = 'Teststr. 24';
        con.MailingCity = 'Hannover';
        con.MailingPostalCode = '30159';
        con.LastName = 'Interessentenmann 6';
        con.RecordTypeId = interessentRecordTypeId;
        insert con;
        Finanzierungsanfrage__c fa = new Finanzierungsanfrage__c();
        fa.Name = 'Test';
        fa.ErsterKaeufer__c = con.Id;
        insert fa;
        DigitaleVsa__c dv = new DigitaleVsa__c();
        dv.Finanzierungsanfrage__c = fa.Id;
        insert dv;
        CreateMultipleRecordsController.getRecords(dv.Id, 'VSAImmobilie__c', 'Name');
    }
}