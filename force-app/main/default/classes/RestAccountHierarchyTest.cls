@isTest
private class RestAccountHierarchyTest {

	@isTest static void TestAccountHiearchyWithZeroLevels() {
		// TestClass with no of hierarchy
		Account acc = TestDataFactory.createAccount(true);

		RestAccountHierarchy.show(acc.Id);
	}

	@isTest static void TestAccountHiearchyWithOneLevel() {
		// TestClass with one level of hierarchy
		Account acc = TestDataFactory.createAccount(true);

		Account childAccount = TestDataFactory.createAccount(true, 'TestAccount2');
		childAccount.ParentId = acc.Id;
		update childAccount;

		RestAccountHierarchy.show(acc.Id);
	}

	@isTest static void TestAccountHiearchyWithTwoLevels() {
		// TestClass with multiple levels of hierarchy
		Account acc = TestDataFactory.createAccount(true);

		Account childAccount = TestDataFactory.createAccount(true, 'TestAccount2');
		childAccount.ParentId = acc.Id;
		update childAccount;

		Account childChildAccount = TestDataFactory.createAccount(true, 'TestAccount3');
		childChildAccount.ParentId = childAccount.Id;
		update childChildAccount;

		RestAccountHierarchy.show(acc.Id);
	}

}