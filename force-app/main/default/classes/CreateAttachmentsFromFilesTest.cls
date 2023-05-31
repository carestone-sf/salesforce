@IsTest
public with sharing class CreateAttachmentsFromFilesTest {

    @testSetup static void test_setup() {
        User testUser = TestDataFactory.createTestUser(true, 'TestAdmin', 1);
        try{
            PermissionSet ps_status = [SELECT Id FROM PermissionSet WHERE Name = 'Can_change_stage_status'];
            PermissionSet ps_contact = [SELECT Id FROM PermissionSet WHERE Name = 'ChangeContactAccount'];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps_status.Id);
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps_contact.Id);
        }
        catch(DmlException e){
            System.debug(e.getMessage());
        }
        System.runAs(testUser){
        
            Contact mb = TestDataFactory.createContact(true,'Frank', 'Köpsell', 'witte@amstammtisch.de');
            
            Account acc3 = TestDataFactory.createBautraeger(false);
            acc3.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
            acc3.Gesch_ftsbeziehung__c = 'Bauträger';
            acc3.Geschueftsfuehrer__c = mb.id;
            insert acc3;

            mb.AccountId = acc3.Id;
            update mb;

            Contact potKun = TestDataFactory.createContact(true,'Tvvsta', 'Tekoeeric', 'test@tester.de');

            Property__c immobilie = TestDataFactory.createProperty(false, null, 'Immobilie');    
            immobilie.Gesch_ftsf_hrer__c = mb.id;
            immobilie.Amtsgericht__c = 'test';
            immobilie.HRB__c = '123';
            insert immobilie;

            Appartment__c app2 = TestDataFactory.createAppartment(true, immobilie.Id);

            Provisionsverhandlung__c provisionsverhandlung = TestDataFactory.createProvisionsverhandlung(true, acc3.Id, immobilie.Id);
            
            TestDataFactory.createDatevSettings();
            TestDataFactory.createNecessaryCustomSettings();

            Opportunity opp = Testdatafactory.createOpportunity(false, potKun.Id, mb.Id, immobilie.Id, app2.Id, 'Available', 100000);
            opp.AccountId = acc3.Id;
            insert opp;
        }
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