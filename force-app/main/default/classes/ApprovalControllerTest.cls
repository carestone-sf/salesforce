@IsTest
public class ApprovalControllerTest {

    @testSetup static void test_setup() {
        User testUser = TestDataFactory.createTestUser(true, 'TestAdmin', 345);
        User testUserRole = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];
        testUser.UserRoleId = testUserRole.UserRoleId;
        update testUser;
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
            Account acc3 = TestDataFactory.createAccount(true, 'WH Maklerbetreuer - Frank Köpsell', null);
            acc3.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
            acc3.BIC__c  = '1';
            acc3.Geschueftsfuehrer__c = mb.id;
            acc3.Steuernummer__c = '24/231/123';
            update acc3;

            mb.AccountId = acc3.Id;
            update mb;

            Contact potKun = TestDataFactory.createContact(true,'Tvvsta', 'Tekoeeric', 'test@tester.de');
            Property__c immobilie = TestDataFactory.createProperty(true, null, 'Immobilie');    
            
            Appartment__c app2 = TestDataFactory.createAppartment(true, immobilie.Id);
            
            Provisionsverhandlung__c provisionsverhandlung = TestDataFactory.createProvisionsverhandlung(true, acc3.Id, immobilie.Id);

            TestDataFactory.createDatevSettings();
            TestDataFactory.createNecessaryCustomSettings();
        }
    }

    private static testMethod void approveProvision() {
        User testUser = TestDataFactory.createTestUser(true, 'TestAdmin', 123);
        User testUserRole = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];
        testUser.UserRoleId = testUserRole.UserRoleId;
        update testUser;

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

            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;

            Account acc3 = [SELECT Id FROM Account];
            
            Id maklerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
            .get('Makler').getRecordTypeId();
            Contact con = TestDataFactory.createContact(true,'Max', 'Maklermann 6', 'wittexyz@amstammtisch.de');
            con.AccountId = acc3.Id;
            con.Gesch_ftsbeziehung__c = 'Versicherungsmakler';
            con.RecordTypeId = maklerRecordTypeId;
            update con;

            Database.insert(con, dml);

            Profile portalProfileUser = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community%User' Limit 1];
            Profile portalProfileManager = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community%Manager' Limit 1];
            
            List<PermissionSetAssignment> pmas = new List<PermissionSetAssignment>();
            List<PermissionSet> pms = [SELECT Id, Name FROM PermissionSet WHERE Name Like '%Community%'];
            PermissionSet accPm;
            PermissionSet conPm;
            PermissionSet provPm;
            PermissionSet immPm;
            for(PermissionSet pm:pms) {
                if(pm.Name.contains('Accounts')) { 
                    accPm = pm;
                } else if(pm.Name.contains('Kontakte')) { 
                    conPm = pm;
                } else if(pm.Name.contains('Provision')) { 
                    provPm = pm;
                } else if(pm.Name.contains('Immobilie')) {
                    immPm = pm;
                }
            }

            List<User> communityUsers = new List<User>();
            String sbName = UserInfo.getUserName().substringAfterLast('.');
            
            User usr = TestDataFactory.createTestUser(false);
            usr.Firstname=con.firstName;
            usr.Lastname=con.LastName;
            usr.ContactId=con.Id;
            usr.Username = 'salesaccount5@test.de';
            usr.profileId = portalProfileUser.Id;
            usr.Alias = usr.Username.substring(0,6);
            insert usr;

            Contact mb = [SELECT Id, Email, OwnerId FROM Contact WHERE LastName = 'Köpsell'];
            Contact potKun = [SELECT Id FROM Contact WHERE LastName = 'Tekoeeric'];
            Property__c immobilie = [SELECT ID From Property__c];
            Appartment__c app2 = [SELECT ID From Appartment__c];
            Opportunity opp2 = Testdatafactory.createOpportunity(false, potKun.Id, mb.Id, immobilie.Id, app2.Id, 'Reservierung angefragt', 100000);
            opp2.AccountId = acc3.Id;
            opp2.Kaufdatum__c = System.Today();
            opp2.Immobilienberater__c = mb.Id;
            opp2.Maklerprovision__c = '4.5';
            opp2.Verk_ufer_Beratungsprovision__c = '1.5';
            insert opp2;

            Test.startTest();

            opp2.StageName = 'Geschlossene und gewonnene';
            opp2.beurkundeter_Kaufpreis__c = 123123.23;
            update opp2;

            Provision__c provision = Testdatafactory.createProvision(false, opp2.Id, mb.OwnerId, opp2.Makler__c);
            provision.E_Mail__c = mb.Email;
            provision.Ausl_ser__c = mb.Id;
            provision.Kaufpreis__c = opp2.Provisionsbasis__c;
            provision.Maklerbetreuer__c = '005b0000001V30P';
            insert provision;

            User user = [SELECT Id FROM User WHERE LastName = 'Maklermann 6'];

            Test.stopTest();

    //        TODO run in Maklerbetreuer context
    //        List<ApprovalController.ProvisionApproval> pas = ApprovalController.getProvisionApprovals();
    //        ApprovalController.approveProvision(pas[0].workItemId);
        }
    }
}