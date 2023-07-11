@isTest
public class OpportunityControllerTest {
    static User insertUser(){
        Id systemAdminProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

        User userExample = new User();
        userExample.Username = 'emailtest@test.com'+String.valueOf(1234);
        userExample.FirstName = 'First';
        userExample.LastName = 'Last';
        userExample.Alias = 'Alias';
        userExample.Email = 'emailtest@test.com';
        userExample.TimeZoneSidKey = 'America/New_York';
        userExample.LocaleSidKey = 'en_US';
        userExample.EmailEncodingKey = 'ISO-8859-1';
        userExample.ProfileId = systemAdminProfileId;
        userExample.LanguageLocaleKey = 'en_US';
        userExample.isActive=true;


        insert userExample;
        try{
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SkipOpportunityValidation'];
            PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'ChangeContactAccount'];
            List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
			psa.add( new PermissionSetAssignment(AssigneeId = userExample.id, PermissionSetId = ps.Id));
            psa.add( new PermissionSetAssignment(AssigneeId = userExample.id, PermissionSetId = ps2.Id));
            insert psa;
        }
        catch(DmlException e){
            System.debug(e.getMessage());
        }
        return userExample;
    }

    @testSetup static void test_setup() {
        User u = TestDataFactory.createTestuser(true, 'Admin');

        try{
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SkipOpportunityValidation'];
            PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'ChangeContactAccount'];
            List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
			psa.add( new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id));
            psa.add( new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps2.Id));
            insert psa;
        }
        catch(DmlException e){
            System.debug(e.getMessage());
        }

        System.RunAs(u){
        
            Account acc3 = TestDataFactory.createBautraeger(true);
            Contact mb = TestDataFactory.createMakler(true, acc3.Id);

            Contact potKun = TestDataFactory.createContact(true,'Tvvsta','Tekoeeric');

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
    }

    private static testMethod void testGetMabvInvoices() {
        Opportunity opp = [SELECT Id FROM Opportunity];

        Test.startTest();
        OpportunityController.getMabvInvoices(opp.Id);
        Test.stopTest();
    }
}