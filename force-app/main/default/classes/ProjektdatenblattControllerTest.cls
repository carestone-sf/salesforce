@isTest
public with sharing class ProjektdatenblattControllerTest {
    
    @isTest
    private static void checkIfiImmobiliePdfDownloadNameIsCorrect() {
        Account acc = TestDataFactory.createBautraeger(true);
        Property__c property = TestDataFactory.createProperty(true, acc.id);


        Test.startTest();
        PageReference pageref = Page.Projektdatenblatt;
        pageRef.getParameters().put('id', String.valueOf(property.Id));
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(property);
        ProjektdatenblattController ext = new ProjektdatenblattController(sc);


        string immobiliePdfDownloadName = ext.immobiliePdfDownloadName();

        system.assertEquals(String.valueOf(Date.Today()) + '_' + property.Name + '_Projektdatenblatt.pdf', immobiliePdfDownloadName);
        Test.stopTest();
    }   

}