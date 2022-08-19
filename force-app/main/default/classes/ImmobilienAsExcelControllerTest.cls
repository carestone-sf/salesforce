@isTest
private class ImmobilienAsExcelControllerTest {

	@isTest static void test_method_one() {
		Property__c immobilie = new Property__c();
		immobilie.Name = 'Immobilie';
		insert immobilie;

		Appartment__c app2 = new Appartment__c();
		app2.Name = 'TestApp2';
		app2.Property__c = immobilie.Id;
		app2.Status__c = 'Available';
		app2.Area_sq_m__c = 63;
		insert app2;

		PageReference testPage = Page.ImmobilienAsExcel;
		Test.setCurrentPage(testPage);

		ImmobilienAsExcelController iAs = new ImmobilienAsExcelController();
		iAs.getProperties();
		iAs.getTimeNow();

	}

}