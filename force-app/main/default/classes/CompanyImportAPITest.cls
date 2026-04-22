@IsTest
private class CompanyImportAPITest {
    
    @TestSetup
    static void makeData() {
        Account acc = TestDataFactory.createAccount(true);
        
        Contact makler = TestDataFactory.createMakler(false, acc.Id);
        insert new List<Contact> { makler };
    }
    
    @IsTest
    static void testCompanyImportPost() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        // JSON payload
        String jsonBody = JSON.serialize(new Map<String, Object>{
            'company' => new Map<String, Object>{
                'accountId' => acc.Id,
                'name' => 'LeadGroup GmbH',
                'legalName' => 'LeadGroup GmbH',
                'legalForm' => 'GmbH',
                'street' => 'Georgstraße 48',
                'postalCode' => '30159',
                'city' => 'Hannover',
                'websiteUrl' => 'https://leadgroup.de',
                'facebookUrl' => 'https://facebook.com/leadgroup',
                'instagramUrl' => 'https://instagram.com/leadgroup',
                'linkedInUrl' => 'https://linkedin.com/leadgroup',
                'xingUrl' => 'https://xing.com/leadgroup',
                'trustpilotUrl' => 'https://trustpilot.com/leadgroup',
                'googleMyBusinessUrl' => 'https://google.com/business/leadgroup',
                'ratings' => 42,
                'ratingsAverage' => 4.2,
                'phone' => '+4951112345678',
                'email' => 'info@leadgroup.de',
                'foundationYear' => 2012,
                'aiSummary' => 'Potenzial vorhanden.',
                'employees' => 15,
                'newsArticles' => new List<Object>{
                    new Map<String, Object>{ 'title' => 'LeadGroup in den Nachrichten', 'url' => 'https://ntv.de/article' }
                },
                'industry' => 'Bank'
            },
            'primaryContact' => new Map<String, Object>{
                'salutation' => 'Herr',
                'firstName' => 'Florian',
                'lastName' => 'Witte',
                'email' => 'florian.witte@leadgroup.de',
                'phone' => '+491712345678',
                'role' => 'CEO',
                'existingContactId' => null
            },
            'contacts' => new List<Object>{
                new Map<String, Object>{
                    'salutation' => 'Frau',
                    'firstName' => 'Anna',
                    'lastName' => 'Müller',
                    'email' => 'anna.mueller@leadgroup.de',
                    'phone' => '+491761234567',
                    'role' => 'Assistenz',
                    'existingContactId' => null
                }
            }
        });
        
        // Simulate REST context
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/CompanyImportAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CompanyImportAPI.handlePost();
        Test.stopTest();
        
        // Assertions
        Account updated = [SELECT Id, NamePotenzialanalyse__c, Unternehmensname__c, Potenzialanalyse__c, PotenzialanalyseErfasst__c, PrimaererAnsprechpartner__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals('LeadGroup GmbH', updated.NamePotenzialanalyse__c);
        System.assertEquals('Potenzial vorhanden.', updated.Potenzialanalyse__c);
        System.assertEquals(true, updated.PotenzialanalyseErfasst__c);
        System.assertNotEquals(null, updated.PrimaererAnsprechpartner__c);
        
        Contact primary = [SELECT Id, FirstName, LastName, Email, RecordTypeId FROM Contact WHERE Id = :updated.PrimaererAnsprechpartner__c];
        System.assertEquals('Florian', primary.FirstName);
        System.assertEquals('012b0000000UV0IAAW', primary.RecordTypeId);
        
        List<Contact> others = [SELECT Id FROM Contact WHERE Email = 'anna.mueller@leadgroup.de'];
        System.assertEquals(1, others.size());
    }
    
    @IsTest
    static void testUpdateExistingContact() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        // Create existing contact
        Contact existing = new Contact(
            AccountId = acc.Id,
        RecordTypeId = '012b0000000UV0IAAW',
        FirstName = 'Max',
        LastName = 'Mustermann',
        Email = 'old.email@firma.de',
        Phone = '00000',
        Title = 'Mitarbeiter'
            );
        insert existing;
        
        String jsonBody = JSON.serialize(new Map<String, Object>{
            'company' => new Map<String, Object>{
                'accountId' => acc.Id,
                'name' => 'LeadGroup GmbH',
                'legalName' => 'LeadGroup GmbH',
                'legalForm' => 'GmbH',
                'street' => 'Georgstraße 48',
                'postalCode' => '30159',
                'city' => 'Hannover',
                'websiteUrl' => 'https://leadgroup.de',
                'facebookUrl' => 'https://facebook.com/leadgroup',
                'instagramUrl' => 'https://instagram.com/leadgroup',
                'linkedInUrl' => 'https://linkedin.com/leadgroup',
                'xingUrl' => 'https://xing.com/leadgroup',
                'trustpilotUrl' => 'https://trustpilot.com/leadgroup',
                'googleMyBusinessUrl' => 'https://google.com/business/leadgroup',
                'ratings' => 99,
                'ratingsAverage' => 4.8,
                'phone' => '+49511123123',
                'email' => 'info@leadgroup.de',
                'foundationYear' => 2005,
                'aiSummary' => 'Update-Test.',
                'employees' => 25,
                'newsArticles' => new List<Object>{},
                'industry' => 'Versicherungsmakler'
            },
            'primaryContact' => new Map<String, Object>{
                'salutation' => 'Herr',
                'firstName' => 'Maximilian',
                'lastName' => 'Mustermann',
                'email' => 'max@firma.de',
                'phone' => '+49176111111',
                'role' => 'Leitung',
                'existingContactId' => existing.Id
            },
            'contacts' => new List<Object>{}
        });
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestUri = '/services/apexrest/CompanyImportAPI/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonBody);
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        CompanyImportAPI.handlePost();
        Test.stopTest();
        
        // Assert contact was updated
        Contact updated = [SELECT Id, FirstName, LastName, Email, Phone, Title, RecordTypeId FROM Contact WHERE Id = :existing.Id];
        System.assertEquals('Maximilian', updated.FirstName);
        System.assertEquals('max@firma.de', updated.Email);
        System.assertEquals('012b0000000UV0IAAW', updated.RecordTypeId);
        System.assertEquals('Leitung', updated.Title);
        
        // Assert Account has primary contact set correctly
        Account refreshed = [SELECT PrimaererAnsprechpartner__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(updated.Id, refreshed.PrimaererAnsprechpartner__c);
    }
    
}