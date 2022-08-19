@isTest
public with sharing class RestDashboardTest {
	@isTest static void RestDashboardTest() {
		// TestClass with subquery
		MaklerPortalHelper mh = new MaklerPortalHelper();

		Test.startTest();
		RestDashboard.show(mh.user.Id);
		Test.stopTest();
	}
}