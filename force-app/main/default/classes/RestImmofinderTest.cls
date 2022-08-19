@isTest
public with sharing class RestImmofinderTest {

	@isTest static void TestImmofinderWithSubquery() {
		// TestClass with subquery
		MaklerPortalHelper mh = new MaklerPortalHelper();

		Test.startTest();
		RestImmofinder.show(mh.user.Id, true);
		Test.stopTest();
	}

	@isTest static void TestImmofinderAdminWithSubquery() {
		// TestClass with subquery
		MaklerPortalHelper mh = new MaklerPortalHelper();

		Test.startTest();
		RestImmofinder.show(mh.user2.Id, true);
		Test.stopTest();
	}

	@isTest static void TestImmofinderWithoutSubquery() {
		// TestClass without subquery
		MaklerPortalHelper mh = new MaklerPortalHelper();

		Test.startTest();
		RestImmofinder.show(mh.user.Id, false);
		Test.stopTest();
	}

	@isTest static void TestImmofinderAdminWithoutSubquery() {
		// TestClass without subquery
		MaklerPortalHelper mh = new MaklerPortalHelper();

		Test.startTest();
		RestImmofinder.show(mh.user2.Id, false);
		Test.stopTest();
	}

}