@isTest
public with sharing class DigitaleVSAControllerTest {

    @testSetup
    static void makeData() {

        // Create a test DigitaleVsa__c record
        DigitaleVsa__c digitaleVsa = TestDataFactory.createDigitaleVsa(true);

        // Create a VsaVerbindlichkeit__c record
        VsaVerbindlichkeit__c verbindlichkeit = new VsaVerbindlichkeit__c(
                DigitaleVsa__c = digitaleVsa.Id
        );
        insert verbindlichkeit;

        // create a VsaVermoegenswert__c record
        VsaVermoegenswert__c vermogenswert = new VsaVermoegenswert__c(
                DigitaleVsa__c = digitaleVsa.Id
        );
        insert vermogenswert;

        // create a VSAImmobilie__c record
        VSAImmobilie__c immobilie = new VSAImmobilie__c(
                DigitaleVsa__c = digitaleVsa.Id
        );
        insert immobilie;
    }

    //testGetVSA();
    @isTest
    private static void testGetVSA() {



        DigitaleVsa__c dv = [SELECT Id FROM DigitaleVsa__c LIMIT 1];
        PageReference pageRef = Page.Digitale_VSA_PDF;
        pageRef.getParameters().put('id', dv.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        ApexPages.StandardController std = new ApexPages.StandardController(dv);
        DigitaleVSAController dvc = new DigitaleVSAController(std);

        System.assertEquals(1, dvc.immobilie.size());
        System.assertEquals(1, dvc.verbindlichkeiten.size());
        System.assertEquals(1, dvc.vermoegenswert.size());
        System.assert(dvc.digitaleVSAName.contains('.pdf'));
    }

}