@IsTest
private class DSAuftragsdatenverarbeitungTest {

    @IsTest
    static void constructor_setsDefaultTemplateAndRoleObjects() {
        DSAuftragsdatenverarbeitung request = new DSAuftragsdatenverarbeitung();

        System.assertEquals(
            '8b23cc54-d0dd-47cf-8193-ffb2a77dfd1b',
            request.templateId
        );
        System.assertNotEquals(null, request.Interessent);
        System.assertNotEquals(null, request.Makler);
        System.assertNotEquals(null, request.Partnermanager);
    }

    @IsTest
    static void jsonShape_matchesExpectedRoleStructure() {
        DSAuftragsdatenverarbeitung request = new DSAuftragsdatenverarbeitung();
        request.relatedRecordId = UserInfo.getUserId();
        request.Interessent.interessentenRecordId = UserInfo.getUserId();
        request.Interessent.maklerRecordId = UserInfo.getUserId();
        request.Interessent.partnermanagerRecordId = UserInfo.getUserId();
        request.Interessent.Name = 'Max Interessent';
        request.Interessent.Email = 'interessent@example.com';

        request.Makler.Name = 'Maria Makler';
        request.Makler.Email = 'makler@example.com';

        request.Partnermanager.Name = 'Peter Partner';
        request.Partnermanager.Email = 'partner@example.com';

        String jsonBody = JSON.serialize(request);
        Map<String, Object> body = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);

        System.assertEquals(
            '8b23cc54-d0dd-47cf-8193-ffb2a77dfd1b',
            (String)body.get('templateId')
        );
        System.assert(body.containsKey('Interessent'));
        System.assert(body.containsKey('Makler'));
        System.assert(body.containsKey('Partnermanager'));

        Map<String, Object> interessent = (Map<String, Object>)body.get('Interessent');
        Map<String, Object> makler = (Map<String, Object>)body.get('Makler');
        Map<String, Object> Partnermanager = (Map<String, Object>)body.get('Partnermanager');

        System.assertEquals(UserInfo.getUserId(), (String)body.get('relatedRecordId'));
        System.assertEquals('Max Interessent', (String)interessent.get('Name'));
        System.assertEquals('interessent@example.com', (String)interessent.get('Email'));
        System.assertEquals(UserInfo.getUserId(), (String)interessent.get('interessentenRecordId'));
        System.assertEquals(UserInfo.getUserId(), (String)interessent.get('maklerRecordId'));
        System.assertEquals(UserInfo.getUserId(), (String)interessent.get('partnermanagerRecordId'));

        System.assertEquals('Maria Makler', (String)makler.get('Name'));
        System.assertEquals('makler@example.com', (String)makler.get('Email'));

        System.assertEquals('Peter Partner', (String)Partnermanager.get('Name'));
        System.assertEquals('partner@example.com', (String)Partnermanager.get('Email'));
    }
}