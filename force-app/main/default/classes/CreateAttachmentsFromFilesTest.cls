@IsTest
public with sharing class CreateAttachmentsFromFilesTest {

    @testSetup static void test_setup() {
        
        Contact mb = TestDataFactory.createContact(true, 'Frank', 'Köpsell', 'witte@amstammtisch.de');
        Account acc3 = TestDataFactory.createBautraeger(true);
        mb.AccountId = acc3.Id;
        update mb;

        Contact potKun = TestDataFactory.createContact(true, 'Tvvsta', 'Tekoeeric');

        Property__c immobilie = TestDataFactory.createProperty(true,acc3.Id,'Immobilie');

        Appartment__c app2 = TestDataFactory.createAppartment(true,immobilie.Id,'TestApp2');

        Provisionsverhandlung__c provisionsverhandlung = TestDataFactory.createProvisionsverhandlung(true,acc3.Id,immobilie.Id);

        Gutschrift_Laufnummer__c gutschriftLaufnummer = Gutschrift_Laufnummer__c.getOrgDefaults();
        gutschriftLaufnummer.Gutschrift_Laufnummer__c = 0;
        insert gutschriftLaufnummer;

        Gutschrift_Storno_Laufnummer__c gutschriftStornoLaufnummer = Gutschrift_Storno_Laufnummer__c.getOrgDefaults();
        gutschriftStornoLaufnummer.Gutschrift_Storno_Laufnummer__c = 0;
        insert gutschriftStornoLaufnummer;

        MaBVRechnungLaufnummer__c maBVRechnungLaufnummer = MaBVRechnungLaufnummer__c.getOrgDefaults();
        maBVRechnungLaufnummer.Laufnummer__c = 0;
        insert maBVRechnungLaufnummer;

        DatevDebitorennummerKaeufer__c datevDebitorennummerKaeufer = DatevDebitorennummerKaeufer__c.getOrgDefaults();
        datevDebitorennummerKaeufer.DatevDebitorennummerKaeufer__c = 123456;
        insert datevDebitorennummerKaeufer;

        Opportunity opp = TestDataFactory.createOpportunity(true, potKun.Id, mb.Id, immobilie.Id, app2.Id,'Available');
    }

    private static testMethod void testCreateAttachmentsFromFiles() {

        Property__c immobilie = [SELECT Id FROM Property__c];
        Opportunity opp = [SELECT Id FROM Opportunity];

        Id finanzierungsanfragenRecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('Finanzierungsanfragen').getRecordTypeId();

        ContentVersion cv=new Contentversion();
        cv.title='Rechnung';
        cv.PathOnClient ='Rechnung';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.Typ__c = 'Individuelle Unterlage';
        cv.RecordTypeId = finanzierungsanfragenRecordTypeId;
        insert cv;

        List<ContentVersion> files = [SELECT ContentDocumentId FROM ContentVersion];

        for(ContentVersion currentCv:files) {
            ContentDocumentLink cde = new ContentDocumentLink();
            cde.ContentDocumentId = currentCv.ContentDocumentId;
            cde.LinkedEntityId = opp.Id;
            insert cde;
        }

        List<CreateAttachmentsFromFiles.Requests> rqs = new List<CreateAttachmentsFromFiles.Requests>();
        CreateAttachmentsFromFiles.Requests rq = new CreateAttachmentsFromFiles.Requests();
        rq.recordId = opp.Id;
        rq.parentId = immobilie.Id;
        rq.isStorno = false;
        rqs.add(rq);

        Test.startTest();
        CreateAttachmentsFromFiles.createAttachmentsFromFiles(rqs);
        Test.stopTest();
    }
}