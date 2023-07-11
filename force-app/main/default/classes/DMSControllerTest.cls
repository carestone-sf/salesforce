@IsTest
public with sharing class DMSControllerTest {

    @testSetup static void test_setup() {
        
        Contact mb = TestDataFactory.createContact(true, 'Frank', 'Köpsell', 'witte@amstammtisch.de');
        Account acc3 = TestDataFactory.createBautraeger(true);
        mb.AccountId = acc3.Id;
        update mb;

        Contact potKun = TestDataFactory.createContact(true, 'Tvvsta', 'Tekoeeric');

        Property__c immobilie = TestDataFactory.createProperty(true,acc3.Id);

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

        Opportunity opp = TestDataFactory.createOpportunity(true, potKun.Id, mb.Id, immobilie.Id, app2.Id);
    }

    private static testMethod void testDmsCalls() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Property__c immobilie = [SELECT Id FROM Property__c];
        Opportunity opp = [SELECT Id FROM Opportunity];

        Id finanzierungsanfragenRecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('Finanzierungsanfragen').getRecordTypeId();

        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.Typ__c = 'Individuelle Unterlage';
        cv.RecordTypeId = finanzierungsanfragenRecordTypeId;
        insert cv;

        Test.startTest();
        DMSController.login();
        DMSController.getDocuments('abc', 1);
        DMSController.getDocument('1234');
        DMSController.getDocumentTypes('1234');
        DMSController.uploadDocument('1234', 'aaa', '{"json": "json"}');
        Test.stopTest();
    }
    private static testMethod void testDmsCalls2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        DMSController.updateFolder('1234', '{"json": "json"}');
        Test.stopTest();
    }

    private static testMethod void testDmsCalls3() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Property__c immobilie = [SELECT Id FROM Property__c];

        Test.startTest();
        DMSController.Requests dmr = new DMSController.Requests();
        dmr.recordId = immobilie.Id;
        dmr.updateFolder = true;
        List<DMSController.Requests> dmrs = new List<DMSController.Requests>();
        dmrs.add(dmr);
        DMSController.createUpdateFoldersFromRecordIdsApexAction(dmrs);
        Test.stopTest();
    }

    private static testMethod void testDmsCalls4() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Opportunity opp = [SELECT Id FROM Opportunity];

        Id finanzierungsanfragenRecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('Finanzierungsanfragen').getRecordTypeId();

        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.Typ__c = 'Individuelle Unterlage';
        cv.RecordTypeId = finanzierungsanfragenRecordTypeId;
        insert cv;

        Test.startTest();
        DMSController.Requests dmr2 = new DMSController.Requests();
        dmr2.recordId = opp.Id;
        dmr2.updateFolder = false;
        List<DMSController.Requests> dmrs2 = new List<DMSController.Requests>();
        dmrs2.add(dmr2);
        DMSController.createUpdateFoldersFromRecordIdsApexAction(dmrs2);
        DMSController.uploadDocumentFromContentVersionId('1234', cv.Id, '111');
        Test.stopTest();
    }
}