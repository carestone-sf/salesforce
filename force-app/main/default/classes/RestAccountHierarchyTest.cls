@isTest
private class RestAccountHierarchyTest {

	@isTest static void TestAccountHiearchyWithZeroLevels() {
		// TestClass with no of hierarchy
		Account acc = new Account(Name='TestAccount');
		insert acc;

		RestAccountHierarchy.show(acc.Id);
	}

	@isTest static void TestAccountHiearchyWithOneLevel() {
		// TestClass with one level of hierarchy
		Account acc = new Account(Name='TestAccount');
		insert acc;

		Account childAccount = new Account(Name='TestAccount2', ParentId=acc.Id);
		insert childAccount;

		RestAccountHierarchy.show(acc.Id);
	}

	@isTest static void TestAccountHiearchyWithTwoLevels() {
		// TestClass with multiple levels of hierarchy
		Account acc = new Account(Name='TestAccount');
		insert acc;

		Account childAccount = new Account(Name='TestAccount2', ParentId=acc.Id);
		insert childAccount;

		Account childChildAccount = new Account(Name='TestAccount3', ParentId=childAccount.Id);
		insert childChildAccount;

		RestAccountHierarchy.show(acc.Id);
	}

}