@IsTest
private class CreateVisualforceFileQueueableTest {
    
    @TestSetup
    static void makeData(){
        TestDataFactory.createDatevSettings();

        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);
        Contact makler = TestDataFactory.createMakler(true, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(true, acc.Id);
        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, appartment.Id);
    }

    @IsTest
    private static void testCreateKaufpreiseingangPdf() {
        Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];

        Test.startTest();
        CreateVisualforceFileQueueable.FileCreationRequest request = new CreateVisualforceFileQueueable.FileCreationRequest(
            opp.Id, Page.KaufpreiseingangBestaetigung, 'Notar: Bestätigung des Kaufpreiseingangs für ' + opp.Name, 
            'Notar-Anschreiben', Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('VKC').getRecordTypeId()
        );
        System.enqueueJob(new CreateVisualforceFileQueueable(new List<CreateVisualforceFileQueueable.FileCreationRequest> {request}));
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM ContentVersion WHERE FirstPublishLocationId = :opp.Id AND Typ__c = 'Notar-Anschreiben']);
    }

    @IsTest
    private static void testWithFinalizer() {
        Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];

        Id orgWideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'service@carestone.com' LIMIT 1].Id;
        List<CreateVisualforceFileQueueable.SendEmailRequest> emailRequests = new List<CreateVisualforceFileQueueable.SendEmailRequest>{new CreateVisualforceFileQueueable.SendEmailRequest(
            'ZahlungseingangPDFAngelegt',
            opp.Id,
            orgWideEmailAddressId,
            new List<String> {'test@test.dev'}
        )};
        CreateVisualforceFileQueueable.SendEmailFinalizer finalizer = new CreateVisualforceFileQueueable.SendEmailFinalizer(emailRequests);

        Test.startTest();
        CreateVisualforceFileQueueable.FileCreationRequest request = new CreateVisualforceFileQueueable.FileCreationRequest(
            opp.Id, Page.KaufpreiseingangBestaetigung, 'Notar: Bestätigung des Kaufpreiseingangs für ' + opp.Name, 
            'Notar-Anschreiben', Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('VKC').getRecordTypeId()
        );

        System.enqueueJob(new CreateVisualforceFileQueueable(new List<CreateVisualforceFileQueueable.FileCreationRequest> {request}).setFinalizer(finalizer));
        Test.stopTest();

        System.assertEquals(1, [SELECT COUNT() FROM ContentVersion WHERE FirstPublishLocationId = :opp.Id AND Typ__c = 'Notar-Anschreiben']);
    }
}
