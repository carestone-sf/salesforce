@isTest
public class DocuSignHandlerTest {
    
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
            Account acc3 = TestDataFactory.createAccount(false, 'WH Maklerbetreuer - Frank Köpsell', null);
            acc3.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
            acc3.BIC__c  = '1';
            acc3.Geschueftsfuehrer__c = mb.id;
            insert acc3;
            
            mb.AccountId = acc3.Id;
            update mb;

            Contact potKun = TestDataFactory.createContact(true,'Tvvsta', 'Tekoeeric', 'wittetest@amstammtisch.de');
            
            Property__c immobilie = TestDataFactory.createProperty(false, null, 'Immobilie');    
            immobilie.Gesch_ftsf_hrer__c = mb.id;
            immobilie.Amtsgericht__c = 'test';
            immobilie.HRB__c = '123';
            insert immobilie;
            
            Appartment__c app2 = TestDataFactory.createAppartment(true, immobilie.Id);

            Provisionsverhandlung__c provisionsverhandlung = TestDataFactory.createProvisionsverhandlung(true, acc3.Id, immobilie.Id);

            TestDataFactory.createDatevSettings();
            TestDataFactory.createNecessaryCustomSettings();

            Opportunity opp3 = Testdatafactory.createOpportunity(true, potKun.Id, mb.Id, immobilie.Id, app2.Id, 'Available', 100000);
        }
    }

    /**
     * Test sending the envelope to a lead
     */
    static testMethod void testSendingDocuSignEnvelope() {

        User DocuSignUser = TestDataFactory.createTestUser(true, 'TestAdmin', 2);

        PermissionSet ps_sender = [SELECT Id FROM PermissionSet WHERE Name = 'DocuSign_Sender'];
        insert new PermissionSetAssignment(AssigneeId = DocuSignUser.id, PermissionSetId = ps_sender.Id);
                
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];

        List<DocuSignHandler.Variables> requestList = new List<DocuSignHandler.Variables>();
        DocuSignHandler.Variables variable = new DocuSignHandler.Variables();
        variable.docuSignTemplateId = '90869f0d-e2d7-4765-87dc-39d2290a5ac2';
        variable.ids = null;
        variable.id = o.Id;
        variable.emailSubject = 'Test subject';
        variable.emailContent = 'Test content';
        requestList.add(variable);

        System.runAs(DocuSignUser){
            Test.startTest();
        
                DocuSignHandler.sendEnvelopes(requestList);
        
            Test.stopTest();
        }
    }
}