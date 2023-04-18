@isTest
public class KaufpreisEingangBestaetigungExtensionT {
    @TestSetup
    static void makeData(){
        Account acc = TestDataFactory.createAccount(true);
        Property__c immobilie = TestDataFactory.createProperty(true, TestDataFactory.createBautraeger(true).Id);

        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        Contact interessent = TestDataFactory.createInteressent(false, acc.Id);
        insert new List<Contact> {makler, interessent};

        Opportunity opp = TestDataFactory.createOpportunity(true, interessent.Id, makler.Id, immobilie.Id, null, 'Kontingent');
    }

    @isTest
    private static void testControllerExtension() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		
		ApexPages.currentPage().getParameters().put('id',opp.Id);
		ApexPages.StandardController stdOpp = new ApexPages.StandardController(opp);
	    KaufpreisEingangBestaetigungExtension kaufpreisEingangBestaetigungExtension  = new KaufpreisEingangBestaetigungExtension(stdOpp);
        kaufpreisEingangBestaetigungExtension.getZahlungen();
        kaufpreisEingangBestaetigungExtension.getVkcZahlungen();
    }
}