@isTest
public with sharing class RestOpportunitiesWithProvisionTest {
    @isTest public static void RestOpportunitiesWithProvisionTest() {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        // TestClass with no of hierarchy
        Account acc = new Account(Name='TestAccount', Email__c='tesaat@mahil.com', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com');
        Database.insert(acc, dml);

        Test.startTest();
        RestOpportunitiesWithProvision.showOpportunities(acc.Id, null);
        Test.stopTest();
    }
    
    @isTest public static void RestOpportunitiesWithProvisionTest2() {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        // TestClass with no of hierarchy
        Account acc = new Account(Name='TestAccount', Email__c='tesaat@mahil.com', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com');
        Database.insert(acc, dml);
        
        Contact potKun = new Contact();
        potKun.FirstName = 'Tvvsta';
        potKun.LastName = 'Tekoeeric';
        insert potKun;

        Test.startTest();
        RestOpportunitiesWithProvision.showOpportunities(acc.Id, potKun.Id);
        Test.stopTest();
    }
}