@isTest
public with sharing class ProjektdatenblattControllerTest {
    
    @isTest
    private static void test1(){
        Account acc=TestDataFactory.createBautraeger(true);
        Property__c property =TestDataFactory.createProperty(true,acc.id);
        


        Test.startTest();
        PageReference pageref=Page.Projektdatenblatt;
        pageRef.getParameters().put('id', String.valueOf(property.Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(property);     
        ProjektdatenblattController ext = new ProjektdatenblattController(sc);       


        string immobiliePdfName=ext.immobiliePdfName;
        system.assertEquals(property.Name+'Projektdatenblatt', immobiliePdfName);
        Test.stopTest();
    }   

}