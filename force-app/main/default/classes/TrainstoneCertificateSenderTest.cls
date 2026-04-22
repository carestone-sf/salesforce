@isTest
private class TrainstoneCertificateSenderTest {
    
    @isTest
    static void testSendCertificates() {
        // 1. Testdaten vorbereiten
        Campaign camp = new Campaign(Name='Test Kampagne', IsActive=true);
        insert camp;
        
        Contact con = new Contact(FirstName='Max', LastName='Mustermann', Email='test@example.com');
        insert con;
        
        // Status muss exakt mit dem Input übereinstimmen
        CampaignMember cm = new CampaignMember(
            CampaignId = camp.Id, 
            ContactId = con.Id, 
            Status = 'Teilgenommen'
        );
        insert cm;
        
        // 2. Input vorbereiten
        TrainstoneCertificateSender.FlowInput input = new TrainstoneCertificateSender.FlowInput();
        input.campaignId = camp.Id;
        input.memberStatus = 'Teilgenommen';
        
        List<TrainstoneCertificateSender.FlowInput> inputList = new List<TrainstoneCertificateSender.FlowInput>{input};
        
        // 3. Test starten
        Test.startTest();
        TrainstoneCertificateSender.sendCertificates(inputList);
        
        // Innerhalb von Test.startTest/stopTest werden E-Mails "virtuell" versendet
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        // 4. Verifizierung
        // Wir prüfen, ob mindestens ein E-Mail-Versand-Aufruf registriert wurde
        System.assertEquals(1, emailInvocations, 'Es sollte genau ein E-Mail-Versand-Aufruf stattgefunden haben.');
    }
    
    @isTest
    static void testEmptyInput() {
        List<TrainstoneCertificateSender.FlowInput> emptyList = new List<TrainstoneCertificateSender.FlowInput>();
        
        Test.startTest();
        TrainstoneCertificateSender.sendCertificates(emptyList);
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        // Es sollten keine E-Mails versendet worden sein
        System.assertEquals(0, emailInvocations, 'Bei leerem Input darf kein E-Mail-Versand stattfinden.');
    }

    @isTest
    static void testNoMembersFound() {
        // Testfall: Kampagne existiert, aber keine Mitglieder mit dem Status
        Campaign camp = new Campaign(Name='Leere Kampagne', IsActive=true);
        insert camp;
        
        TrainstoneCertificateSender.FlowInput input = new TrainstoneCertificateSender.FlowInput();
        input.campaignId = camp.Id;
        input.memberStatus = 'Teilgenommen';
        
        Test.startTest();
        TrainstoneCertificateSender.sendCertificates(new List<TrainstoneCertificateSender.FlowInput>{input});
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        System.assertEquals(0, emailInvocations, 'Wenn keine Mitglieder gefunden werden, darf nichts gesendet werden.');
    }
}