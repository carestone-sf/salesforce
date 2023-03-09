@IsTest
private class EmailMessageTriggerHandlerTest {

    @TestSetup
    static void init() {
        TestDataFactory.createDatevSettings();
        User user = TestDataFactory.createCommunityUser();
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);
        Appartment__c appartment = TestDataFactory.createAppartment(true, immobilie.Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        makler.EmailForCreditNotes__c = 'test@test.dev.xyz';
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent};

        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, appartment.Id, 'Kaufvertragsunterlagen verschickt');
        Provision__c provision = TestDataFactory.createProvision(true, opp.Id, user.Id, makler.Id);
        TestDataFactory.createGutschrift(true, opp.Id, provision.Id);
    }
    
    @IsTest
    private static void testRelationCreatedForCreditNoteEmail() {
        Contact makler = [SELECT Id, Email, EmailForCreditNotes__c FROM Contact WHERE RecordType.DeveloperName = 'Makler' AND EmailForCreditNotes__c = 'test@test.dev.xyz' LIMIT 1];
        
        Test.startTest();
        EmailMessage message = new EmailMessage(
            ToAddress = makler.EmailForCreditNotes__c,
            Subject = 'Test',
            TextBody = 'Test',
            Status = '3', 
            RelatedToId = [SELECT Id FROM Gutschrift__c LIMIT 1].Id
        );
        insert message;
        Test.stopTest();

        for(EmailMessageRelation relation : [SELECT Id, EmailMessageId, RelationAddress, RelationId FROM EmailMessageRelation WHERE EmailMessageId = :message.Id AND RelationAddress = :makler.EmailForCreditNotes__c])
            System.debug(relation);

        Assert.areEqual(1, [SELECT COUNT() FROM EmailMessageRelation WHERE EmailMessageId = :message.Id AND RelationAddress = :makler.EmailForCreditNotes__c AND RelationId = :makler.Id]);

        EmailMessageTriggerHandler handler = new EmailMessageTriggerHandler();
        handler.beforeInsert(message);
        handler.beforeUpdate(message, message);
        handler.afterUpdate(message, message);
        handler.beforeDelete(message);
        handler.afterDelete(message);
    }
}
