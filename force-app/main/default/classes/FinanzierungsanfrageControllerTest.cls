@IsTest
public with sharing class FinanzierungsanfrageControllerTest {
    private static testMethod void getContentVersionsTest() {
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
        fa.WelcheUnterlagenWerdenGefordert__c = 'Personalausweis';
        insert fa;

        Id finanzierungsanfragenRecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('Finanzierungsanfragen').getRecordTypeId();

        ContentVersion cv=new Contentversion();
        cv.title='Personalausweis';
        cv.PathOnClient ='Personalausweis';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.Typ__c = 'Personalausweis';
        cv.RecordTypeId = finanzierungsanfragenRecordTypeId;
        insert cv;

        List<ContentVersion> files = [SELECT ContentDocumentId FROM ContentVersion];

        for(ContentVersion currentCv:files) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = currentCv.ContentDocumentId;
            cdl.LinkedEntityId = fa.Id;
            insert cdl;
        }

        FinanzierungsanfrageController.getContentVersions(fa.Id);
        List<Id> recordIds = new List<Id>{fa.Id};
        FinanzierungsanfrageController.getContentVersionsMap(recordIds);
    }
}