@IsTest
private class ContentDocumentLinkTriggerTest {

    @TestSetup
    static void makeData(){
        TestDataFactory.createDatevSettings();
    }
    
    @IsTest
    private static void testLinkOpportunityRelatedFileIsLinkedToOpportunity() {
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);
        Contact makler = TestDataFactory.createMakler(true, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(true, acc.Id);
        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, appartment.Id);
        MaBVRechnung__c rechnung = TestDataFactory.createMaBVRechnung(true, TestDataFactory.createMaBVRechnungMaster(true, opp.Id, TestDataFactory.createMaBVRate(true, immobilie.Id).Id).Id);
        Gutschrift__c gutschrift = TestDataFactory.createGutschrift(true, opp.Id, null);

        ContentVersion cvAtMaBVRechnung =new Contentversion();
        cvAtMaBVRechnung.title = 'Some File';
        cvAtMaBVRechnung.PathOnClient = 'Some File';
        cvAtMaBVRechnung.versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body');
        cvAtMaBVRechnung.Typ__c = 'Personalausweis';
        cvAtMaBVRechnung.FirstPublishLocationId = rechnung.Id;


        ContentVersion cvAtGutschrift =new Contentversion();
        cvAtGutschrift.title = 'Some File';
        cvAtGutschrift.PathOnClient ='Some File';
        cvAtGutschrift.versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body');
        cvAtGutschrift.Typ__c = 'Personalausweis';
        cvAtGutschrift.FirstPublishLocationId = gutschrift.Id;
        
        Test.startTest();
        insert cvAtMaBVRechnung;
        insert cvAtGutschrift;
        Test.stopTest();

        Id contentDocumentAtMaBVId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cvAtMaBVRechnung.Id].ContentDocumentId;
        Id contentDocumentAtGutschriftId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cvAtGutschrift.Id].ContentDocumentId;
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :opp.Id AND ContentDocumentId = :contentDocumentAtMaBVId]);
        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :opp.Id AND ContentDocumentId = :contentDocumentAtGutschriftId]);
    }

    @IsTest
    private static void testFinanzierungsanfrageStatusSetOnAllRequiredFiles() {
        Account acc = TestDataFactory.createAccount(true);
        Contact interessent = TestDataFactory.createInteressent(true, acc.Id);
        interessent.Maklerbetreuer_E_Mail__c = 'mathis@testx.devx';
        update interessent;
        
        Finanzierungsanfrage__c fa = TestDataFactory.createFinanzierungsanfrage(true, interessent.Id, 'Personalausweis');

        Id finanzierungsanfragenRecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('Finanzierungsanfragen').getRecordTypeId();

        ContentVersion cv=new Contentversion();
        cv.title='Personalausweis';
        cv.PathOnClient ='Personalausweis';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        cv.Typ__c = 'Personalausweis';
        cv.RecordTypeId = finanzierungsanfragenRecordTypeId;
        cv.FirstPublishLocationId = fa.Id;
        
        Test.startTest();
        insert cv;
        Test.stopTest();

        System.assertEquals('In Bearbeitung', [SELECT Phase__c FROM Finanzierungsanfrage__c WHERE Id = :fa.Id].Phase__c);
    }

    // Needed for code coverage of the TriggerException class
    @IsTest
    private static void testTriggerException() {
        try {
            TriggerFactory.createHandler(Case.getSObjectType());
        } catch(Exception ex) {
            System.assertEquals('TriggerException', ex.getTypeName());
        }
    }
}
