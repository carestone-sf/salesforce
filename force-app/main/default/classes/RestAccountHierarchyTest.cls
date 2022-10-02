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

		Account childAccount = TestDataFactory.createAccount(true, 'TestAccount2', null);
		childAccount.ParentId = acc.Id;
		update childAccount;

		RestAccountHierarchy.show(acc.Id);
	}

	@isTest static void TestAccountHiearchyWithTwoLevels() {
		// TestClass with multiple levels of hierarchy
		Account acc = TestDataFactory.createAccount(true);

		Account childAccount = TestDataFactory.createAccount(true, 'TestAccount2', null);
		childAccount.ParentId = acc.Id;
		update childAccount;

		Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;

		Account childChildAccount = new Account();

		childChildAccount.Name = 'TestAccount3';
		childChildAccount.Email__c = 'f.witte@wirtschaftshaus.de';
		childChildAccount.BIC__c  = 'SPKHDE2HXXX';
		childChildAccount.GeschaeftsfuehrerNeu__c = 'Sandro Pawils';
		childChildAccount.Gesetzliche_MwSt_auf_Provisionszahlung__c = 0.4;
		childChildAccount.Hinweis_zur_MwSt__c = 'Vertrag';
		childChildAccount.IBAN__c = 'DE43250501801900212158';
		childChildAccount.Rechtsform__c = 'GbR';
		childChildAccount.Unternehmensname__c = 'CareStone';
		childChildAccount.Carestone_Vertriebsvereinbarung__c = true;
		childChildAccount.Dauerhaft_gesch_tzt__c = true;
		childChildAccount.ParentId = childAccount.Id;

		Database.insert(childChildAccount, dml);

		RestAccountHierarchy.show(acc.Id);
	}

}