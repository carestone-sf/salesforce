@isTest
private class RestNewAccountHierarchyTest {
	@isTest static void TestAccountHiearchyWithZeroLevels() {
		Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;
		// TestClass with no of hierarchy
		Account acc = new Account(Name='TestAccount', Email__c='tesaat@mahil.com', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com');
		Database.insert(acc, dml);

		RestNewAccountHierarchy.showWithHierarchy(acc.Id);
	}

	@isTest static void TestAccountHiearchyWithOneLevel() {
		Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;
		// TestClass with one level of hierarchy
		Account acc = new Account(Name='TestAccount', Email__c='teat@mhil.com', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com');
		Database.insert(acc, dml);

		Contact con = new Contact(AccountId=acc.Id, FirstName='test', LastName='testing');
		Database.insert(con, dml);

		Account childAccount = new Account(Name='TestAccount2', ParentId=acc.Id, Email__c='tesaat@mahil.com', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com');
		Database.insert(childAccount, dml);

		RestNewAccountHierarchy.showWithHierarchy(acc.Id);
	}

	@isTest static void TestAccountHiearchyWithTwoLevels() {
		Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;
		// TestClass with multiple levels of hierarchy
		Account acc = new Account(Name='TestAccount', Email__c='tesaat@mahil.com', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com');
		Database.insert(acc, dml);

		Account childAccount = new Account(Name='TestAccount2', ParentId=acc.Id, Email__c='tester@gmail.com', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com');
		Database.insert(childAccount, dml);

		Account childChildAccount = new Account(Name='TestAccount3', ParentId=childAccount.Id, Email__c='test@mail.com', E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com');
		Database.insert(childChildAccount, dml);

		Contact con = new Contact(AccountId=childChildAccount.Id, FirstName='test', LastName='testing');
		Database.insert(con, dml);

		RestNewAccountHierarchy.showWithHierarchy(acc.Id);
	}
}