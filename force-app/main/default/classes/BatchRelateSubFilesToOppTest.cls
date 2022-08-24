@IsTest
private class BatchRelateSubFilesToOppTest {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.createDatevSettings();

        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);
        Contact makler = TestDataFactory.createMakler(true, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(true, acc.Id);
        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, appartment.Id);
        MaBVRechnung__c rechnung = TestDataFactory.createMaBVRechnung(true, TestDataFactory.createMaBVRechnungMaster(true, opp.Id, TestDataFactory.createMaBVRate(true, immobilie.Id).Id).Id);
        Gutschrift__c gutschrift = TestDataFactory.createGutschrift(true, opp.Id, null);
    }
    
    @IsTest
    private static void testWithGutschrift() {
        Gutschrift__c gutschrift = [SELECT Id, Opportunity__c FROM Gutschrift__c LIMIT 1];
        
        ContentVersion cvAtGutschrift =new Contentversion();
        cvAtGutschrift.title = 'Some File';
        cvAtGutschrift.PathOnClient ='Some File';
        cvAtGutschrift.versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body');
        cvAtGutschrift.Typ__c = 'Personalausweis';
        cvAtGutschrift.FirstPublishLocationId = gutschrift.Id;
        insert cvAtGutschrift;
        
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvAtGutschrift.Id].ContentDocumentId;

        Test.startTest();
        BatchRelateSubFilesToOpportunity job = new BatchRelateSubFilesToOpportunity();
        Database.executeBatch(job);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocumentId AND LinkedEntityId = :gutschrift.Opportunity__c]);
    }

    @IsTest
    private static void testWithMaBV() {
        MaBVRechnung__c rechnung = [SELECT Id, MaBVRechnungMaster__r.Opportunity__c FROM MaBVRechnung__c LIMIT 1];
        
        ContentVersion cvAtMaBVRechnung =new Contentversion();
        cvAtMaBVRechnung.title = 'Some File';
        cvAtMaBVRechnung.PathOnClient = 'Some File';
        cvAtMaBVRechnung.versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body');
        cvAtMaBVRechnung.Typ__c = 'Personalausweis';
        cvAtMaBVRechnung.FirstPublishLocationId = rechnung.Id;
        insert cvAtMaBVRechnung;
        
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cvAtMaBVRechnung.Id].ContentDocumentId;

        BatchRelateSubFilesToOpportunity job = new BatchRelateSubFilesToOpportunity();

        Test.startTest();
        Database.executeBatch(job);
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE ContentDocumentId = :contentDocumentId AND LinkedEntityId = :rechnung.MaBVRechnungMaster__r.Opportunity__c]);
    }
}
