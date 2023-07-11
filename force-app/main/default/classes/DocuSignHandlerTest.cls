@isTest
public class DocuSignHandlerTest {
    
    @testSetup static void test_setup() {
        
        Account acc3 = TestDataFactory.createBautraeger(true);
        Contact mb = TestDataFactory.createMakler(true, acc3.Id);

        Contact potKun = TestDataFactory.createContact(true, 'Tvvsta', 'Tekoeeric');

        Property__c immobilie = TestDataFactory.createProperty(true,acc3.Id);

        Appartment__c app2 = TestDataFactory.createAppartment(true,immobilie.Id);

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

    /**
     * Test sending the envelope to a lead
     */
    static testMethod void testSendingDocuSignEnvelope() {
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];

        List<DocuSignHandler.Variables> requestList = new List<DocuSignHandler.Variables>();
        DocuSignHandler.Variables variable = new DocuSignHandler.Variables();
        variable.docuSignTemplateId = '90869f0d-e2d7-4765-87dc-39d2290a5ac2';
        variable.ids = null;
        variable.id = o.Id;
        variable.emailSubject = 'Test subject';
        variable.emailContent = 'Test content';
        requestList.add(variable);
        
        Test.startTest();
        DocuSignHandler.sendEnvelopes(requestList);
        Test.stopTest();
    }
}