@isTest
public without sharing class GutschriftApprovalControllerTest {
    private static Id provId;

    @TestSetup
    static void setup(){
        TestDataFactory.createDatevSettings();
        TestDataFactory.createNecessaryCustomSettings();
        TestDataFactory.createProvision(true);
        AutomationController__c ac = new AutomationController__c(GutschriftFlows__c = false);
        insert ac;
    }

    @isTest
    static void testGutschriftApproval() {
        Provision__c prov = TestDataFactory.createProvision(true);

        PageReference pageRef = Page.GutschriftApproval;
        pageRef.getParameters().put('gutschriftId', prov.Id);
        pageRef.getParameters().put('accepted', 'true');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        GutschriftApprovalController gap = new GutschriftApprovalController();
        gap.approveGutschrift();
        
        //Check status message
        Assert.areEqual('Gutschrift erfolgreich bestätigt!', gap.status);

        //TODO Adapt to new event-driven architecture
        // //Check record update
        // Provision__c updatedProv = [SELECT GutschriftBestaetigt__c FROM Provision__c WHERE Id = :prov.Id];
        // Assert.isTrue(updatedProv.GutschriftBestaetigt__c);

        Test.stopTest();

    }

    @isTest
    static void testGutschriftRejection() {
        Provision__c prov = TestDataFactory.createProvision(true);

        PageReference pageRef = Page.GutschriftApproval;
        pageRef.getParameters().put('gutschriftId', prov.Id);
        pageRef.getParameters().put('accepted', 'false');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        GutschriftApprovalController gap = new GutschriftApprovalController();
        gap.approveGutschrift();
        
        //Check status message
        Assert.areEqual('Gutschrift erfolgreich abgelehnt!', gap.status);

/*         //Can't check record change since WOrkflow rule immediately unchecks field
        Provision__c updatedProv = [SELECT GutschriftBestaetigt__c, GutschriftAbgelehnt__c FROM Provision__c WHERE Id = :prov.Id];
        System.debug('Bestätigt? ' + updatedProv.GutschriftBestaetigt__c + ' || Abgelehnt? ' + updatedProv.GutschriftAbgelehnt__c);
        Assert.isTrue(updatedProv.GutschriftAbgelehnt__c); */

        Test.stopTest();
    }

    // @isTest
    // static void testGutschriftAlreadyApproved() {
    //     Provision__c prov = TestDataFactory.createProvision(true);

    //     // Provision__c prov = [SELECT ID FROM Provision__c];
    //     // prov.GutschriftBestaetigt__c = true;
    //     // update prov;

    //     PageReference pageRef = Page.GutschriftApproval;
    //     pageRef.getParameters().put('gutschriftId', prov.Id);
    //     pageRef.getParameters().put('accepted', 'true');
    //     Test.setCurrentPage(pageRef);

    //     Test.startTest();
    //     GutschriftApprovalController gap = new GutschriftApprovalController();
    //     gap.approveGutschrift();
    //     gap.approveGutschrift();

    //     Test.stopTest();

    //      //Check status message
    //      Assert.areEqual('Diese Gutschrift wurde bereits bearbeitet.', gap.status);
    // }

    @isTest
    static void testCorruptedGutschriftParameter() {

        Provision__c prov = [SELECT ID FROM Provision__c];

        PageReference pageRef = Page.GutschriftApproval;
        pageRef.getParameters().put('gutschriftId', '12345');
        pageRef.getParameters().put('accepted', 'true');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        GutschriftApprovalController gap = new GutschriftApprovalController();
        gap.approveGutschrift();
        
        //Check status message
        Assert.areEqual('Fehler! Bitte wenden Sie sich an Ihren Maklerbetreuer. <br/>(Fehlercode e3)', gap.status);

        Test.stopTest();
    }

    @isTest
    static void testCorruptedAcceptedParameter() {

        Provision__c prov = [SELECT ID FROM Provision__c];

        PageReference pageRef = Page.GutschriftApproval;
        pageRef.getParameters().put('gutschriftId', prov.Id);
        pageRef.getParameters().put('accepted', 'test');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        GutschriftApprovalController gap = new GutschriftApprovalController();
        gap.approveGutschrift();
        
        //Check status message
        Assert.areEqual('Fehler! Bitte wenden Sie sich an Ihren Maklerbetreuer. <br/>(Fehlercode e2)', gap.status);

        Test.stopTest();
    }

}