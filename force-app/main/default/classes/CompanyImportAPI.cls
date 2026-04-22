@RestResource(urlMapping='/CompanyImportAPI/*')
global with sharing class CompanyImportAPI {
    
    global class NewsArticle {
        public String title;
        public String url;
    }

    global class CompanyDTO {
        public String accountId;
        public String name;
        public String legalName;
        public String legalForm;
        public String street;
        public String postalCode;
        public String city;
        public String websiteUrl;
        public String facebookUrl;
        public String instagramUrl;
        public String linkedInUrl;
        public String xingUrl;
        public String trustpilotUrl;
        public String googleMyBusinessUrl;
        public Integer ratings;
        public Decimal ratingsAverage;
        public String phone;
        public String email;
        public Integer foundationYear;
        public String aiSummary;
        public Integer employees;
        public List<NewsArticle> newsArticles;
        public String industry;
    }

    global class ContactDTO {
        public String salutation;
        public String firstName;
        public String lastName;
        public String email;
        public String phone;
        public String role;
        public String existingContactId;
    }

    global class RequestWrapper {
        public CompanyDTO company;
        public ContactDTO primaryContact;
        public List<ContactDTO> contacts;
    }

    @HttpPost
    global static void handlePost() {
        RestRequest req = RestContext.request;
        RequestWrapper input = (RequestWrapper) JSON.deserialize(req.requestBody.toString(), RequestWrapper.class);

        if (input == null || input.company == null) {
            throw new AuraHandledException('Invalid payload');
        }

        String changeLog = '';
        Account acc = [SELECT Id, NamePotenzialanalyse__c, Unternehmensname__c, Rechtsform__c, BillingStreet, BillingPostalCode,
                       BillingCity, Website, FacebookUrl__c, InstagramUrl__c, LinkedInUrl__c, XingUrl__c,
                       TrustpilotUrl__c, GoogleMyBusinessUrl__c, AnzahlBewertungen__c, DurchschnittBewertungen__c,
                       Phone, Email__c, Gruendungsjahr__c, NumberOfEmployees, Industry
                       FROM Account WHERE Id = :input.company.accountId LIMIT 1];

        // Set RecordType and Industry
        acc.RecordTypeId = '01267000000OmcUAAS';
        List<String> allowedIndustries = new List<String>{
            'Immobilienmakler', 'Finanzmakler', 'Versicherungsmakler', 'Bank', 'Pflegeimmobilienspezialist'
        };
        String industryInput = input.company.industry;
        if (String.isNotBlank(industryInput) && allowedIndustries.contains(industryInput)) {
            acc.Industry = industryInput;
        } else {
            acc.Industry = 'Andere';
        }

        // Track and update fields
        changeLog += compareAndUpdate(acc, 'NamePotenzialanalyse__c', acc.NamePotenzialanalyse__c, input.company.name);
        changeLog += compareAndUpdate(acc, 'Unternehmensname__c', acc.Unternehmensname__c, input.company.legalName);
        changeLog += compareAndUpdate(acc, 'Rechtsform__c', acc.Rechtsform__c, input.company.legalForm);
        changeLog += compareAndUpdate(acc, 'BillingStreet', acc.BillingStreet, input.company.street);
        changeLog += compareAndUpdate(acc, 'BillingPostalCode', acc.BillingPostalCode, input.company.postalCode);
        changeLog += compareAndUpdate(acc, 'BillingCity', acc.BillingCity, input.company.city);
        changeLog += compareAndUpdate(acc, 'Website', acc.Website, input.company.websiteUrl);
        changeLog += compareAndUpdate(acc, 'FacebookUrl__c', acc.FacebookUrl__c, input.company.facebookUrl);
        changeLog += compareAndUpdate(acc, 'InstagramUrl__c', acc.InstagramUrl__c, input.company.instagramUrl);
        changeLog += compareAndUpdate(acc, 'LinkedInUrl__c', acc.LinkedInUrl__c, input.company.linkedInUrl);
        changeLog += compareAndUpdate(acc, 'XingUrl__c', acc.XingUrl__c, input.company.xingUrl);
        changeLog += compareAndUpdate(acc, 'TrustpilotUrl__c', acc.TrustpilotUrl__c, input.company.trustpilotUrl);
        changeLog += compareAndUpdate(acc, 'GoogleMyBusinessUrl__c', acc.GoogleMyBusinessUrl__c, input.company.googleMyBusinessUrl);
        changeLog += compareAndUpdate(acc, 'Phone', acc.Phone, input.company.phone);
        changeLog += compareAndUpdate(acc, 'Email__c', acc.Email__c, input.company.email);
        changeLog += compareAndUpdate(acc, 'Gruendungsjahr__c', acc.Gruendungsjahr__c != null ? acc.Gruendungsjahr__c : null, input.company.foundationYear != null ? input.company.foundationYear : null);
        changeLog += compareAndUpdate(acc, 'NumberOfEmployees', acc.NumberOfEmployees != null ? acc.NumberOfEmployees : null, input.company.employees != null ? input.company.employees : null);
        changeLog += compareAndUpdate(acc, 'AnzahlBewertungen__c', acc.AnzahlBewertungen__c != null ? acc.AnzahlBewertungen__c : null, input.company.ratings != null ? input.company.ratings : null);
        changeLog += compareAndUpdate(acc, 'DurchschnittBewertungen__c', acc.DurchschnittBewertungen__c != null ? acc.DurchschnittBewertungen__c : null, input.company.ratingsAverage != null ? input.company.ratingsAverage : null);

        acc.Potenzialanalyse__c = input.company.aiSummary;
        acc.PotenzialanalyseErfasst__c = true;
        acc.PotenzialanalyseErfasstAm__c = Date.today();

        if (input.company.newsArticles != null && !input.company.newsArticles.isEmpty()) {
            List<String> articleStrings = new List<String>();
            for (NewsArticle a : input.company.newsArticles) {
                articleStrings.add(a.title + ': ' + a.url);
            }
            acc.NewsArtikel__c = String.join(articleStrings, '\r\n');
        }

        acc.Feldaenderungen__c = changeLog.trim();
        update acc;

        // Primary Contact
        Contact primary;
        if (String.isNotBlank(input.primaryContact?.existingContactId)) {
            primary = [SELECT Id, Salutation, FirstName, LastName, Email, Phone, Title FROM Contact WHERE Id = :input.primaryContact.existingContactId LIMIT 1];
            primary.RecordTypeId = '012b0000000UV0IAAW';
            String contactChange = '';
            contactChange += compareAndUpdate(primary, 'Salutation', primary.Salutation, input.primaryContact.salutation);
            contactChange += compareAndUpdate(primary, 'FirstName', primary.FirstName, input.primaryContact.firstName);
            contactChange += compareAndUpdate(primary, 'LastName', primary.LastName, input.primaryContact.lastName);
            contactChange += compareAndUpdate(primary, 'Email', primary.Email, input.primaryContact.email);
            contactChange += compareAndUpdate(primary, 'Phone', primary.Phone, input.primaryContact.phone);
            contactChange += compareAndUpdate(primary, 'Title', primary.Title, input.primaryContact.role);
            primary.Feldaenderungen__c = contactChange.trim();
            update primary;
        } else if(input.primaryContact != null && input.primaryContact?.LastName != null) {
            primary = new Contact(
                AccountId = acc.Id,
                RecordTypeId = '012b0000000UV0IAAW',
                Salutation = input.primaryContact.salutation,
                FirstName = input.primaryContact.firstName,
                LastName = input.primaryContact.lastName,
                Email = input.primaryContact.email,
                Phone = input.primaryContact.phone,
                Title = input.primaryContact.role,
                Position_Abteilung__c = 'Sonstige',
                Gesch_ftsbeziehung__c = 'Mitarbeiter'
            );
            insert primary;
        }

        if(primary != null) {
            acc.PrimaererAnsprechpartner__c = primary.Id;
            update acc;
        }

        // Other contacts
        List<Contact> newContacts = new List<Contact>();
        if(input.contacts != null) {
            for (ContactDTO c : input.contacts) {
                if (String.isNotBlank(c.existingContactId)) {
                    Contact con = [SELECT Id, Salutation, FirstName, LastName, Email, Phone, Title FROM Contact WHERE Id = :c.existingContactId LIMIT 1];
                    con.RecordTypeId = '012b0000000UV0IAAW';
                    con.Salutation = c.salutation;
                    con.FirstName = c.firstName;
                    con.LastName = c.lastName;
                    con.Email = c.email;
                    con.Phone = c.phone;
                    con.Title = c.role;
                    update con;
                } else if(String.isNotBlank(c.lastName)) {
                    newContacts.add(new Contact(
                        AccountId = acc.Id,
                        RecordTypeId = '012b0000000UV0IAAW',
                        Salutation = c.salutation,
                        FirstName = c.firstName,
                        LastName = c.lastName,
                        Email = c.email,
                        Phone = c.phone,
                        Title = c.role,
                        Position_Abteilung__c = 'Sonstige',
                        Gesch_ftsbeziehung__c = 'Mitarbeiter'
                    ));
                }
            }
        }

        if (!newContacts.isEmpty()) {
            insert newContacts;
        }

        AccountService.updateAccountScore(new List<Id>{ acc.Id });
    }

    private static String compareAndUpdate(SObject obj, String field, Object oldValRaw, Object newValRaw) {
        String oldValue = oldValRaw == null ? null : String.valueOf(oldValRaw);
        String newValue = newValRaw == null ? null : String.valueOf(newValRaw);
        
        if (newValue == null || oldValue == newValue) return '';
        obj.put(field, newValRaw); // set with original data type

        if (String.isBlank(oldValue)) {
            return fieldLabel(field) + ' von leer auf "' + newValue + '" geupdated\r\n';
        } else {
            return fieldLabel(field) + ' von "' + oldValue + '" auf "' + newValue + '" geupdated\r\n';
        }
    }


    private static String fieldLabel(String apiName) {
        Map<String, String> labels = new Map<String, String>{
            'NamePotenzialanalyse__c' => 'Name Potenzialanalyse',
            'Unternehmensname__c' => 'Unternehmensname',
            'Rechtsform__c' => 'Rechtsform',
            'BillingStreet' => 'Straße',
            'BillingPostalCode' => 'PLZ',
            'BillingCity' => 'Stadt',
            'Website' => 'Website',
            'FacebookUrl__c' => 'Facebook URL',
            'InstagramUrl__c' => 'Instagram URL',
            'LinkedInUrl__c' => 'LinkedIn URL',
            'XingUrl__c' => 'Xing URL',
            'TrustpilotUrl__c' => 'Trustpilot URL',
            'GoogleMyBusinessUrl__c' => 'Google Business URL',
            'Phone' => 'Telefon',
            'Email__c' => 'E-Mail',
            'Gruendungsjahr__c' => 'Gründungsjahr',
            'NumberOfEmployees' => 'Mitarbeiteranzahl',
            'AnzahlBewertungen__c' => 'Anzahl Bewertungen',
            'DurchschnittBewertungen__c' => 'Durchschnitt Bewertungen',
            'Salutation' => 'Anrede',
            'FirstName' => 'Vorname',
            'LastName' => 'Nachname',
            'Email' => 'E-Mail',
            'Title' => 'Rolle'
        };
        return labels.containsKey(apiName) ? labels.get(apiName) : apiName;
    }
}