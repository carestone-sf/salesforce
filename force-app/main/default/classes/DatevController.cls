public without sharing class DatevController {

    @AuraEnabled
    public static void sendDatevStammdatenCsvAsEmail(Date startDate, Date endDate, String exportType) {
        Messaging.SingleEmailMessage email;
        string[] toAddresses = new string[]{};
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();

        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();

        email = new Messaging.SingleEmailMessage();     

        toAddresses.add(UserInfo.getUserEmail());
        email.setToAddresses(toAddresses);

        Document doc;
        if(exportType == 'debitors') {
            String csvFileName = 'Kontakte_' + startDate.format() + '-' + endDate.format() + '.csv';
            doc = new Document(Name = csvFileName, Body = createDatevStammdatenCsvFromContacts(startDate, endDate), FolderId = '005b0000001V30P', Type = 'csv', ContentType='text/csv; charset=windows-1252');
        } else if(exportType == 'creditors') {
            String csvFileName = 'Accounts_' + startDate.format() + '-' + endDate.format() + '.csv';
            doc = new Document(Name = csvFileName, Body = createDatevStammdatenCsvFromAccounts(startDate, endDate), FolderId = '005b0000001V30P', Type = 'csv', ContentType='text/csv; charset=windows-1252');
        }

        fileAttachments = new List<Messaging.Emailfileattachment>();
        efa = new Messaging.Emailfileattachment();
        efa.setContentType('text/csv; charset=UTF-8');
        efa.setFileName(doc.Name);
        efa.setBody(doc.Body);
        fileAttachments.add(efa);
        email.setFileAttachments(fileAttachments);

        email.setSubject('Datev Stammdaten CSV');
        email.setPlainTextBody('');
        Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        //delete doc;
    }

    @AuraEnabled(cacheable=true)
    public static Document testOtherName() {
        Document theDoc = [SELECT Id, Name, Url FROM Document WHERE CreatedDate = TODAY Order By CreatedDate DESC][0];
        return theDoc;
    }

    public static Blob createDatevStammdatenCsvFromContacts(Date startDate, Date endDate) {
        List<Opportunity> opps = [SELECT Potenzieller_Kunde__c, Kunde2__c FROM Opportunity WHERE CloseDate >= :startDate AND CloseDate <= :endDate];
        List<Id> conIds = new List<Id>();
        for(Opportunity opp:opps) {
            conIds.add(opp.Potenzieller_Kunde__c);
            conIds.add(opp.Kunde2__c);
        }
        endDate = endDate.addDays(1);

        List<Contact> cons = [SELECT Id, Salutation, FirstName, LastName, MailingCity, MailingPostalCode, MailingStreet, MailingCountry,  LetzteImmobiliennummer__c, DatevDebitorenKundennummerKaeufer__c, IBAN__c, SWIFT__C FROM Contact WHERE (Id IN :conIds OR (LastModifiedDate >= :startDate AND LastModifiedDate <= :endDate)) AND Ist_Maklerbetreuer_WH__c = false AND DatevDebitorenKundennummerKaeufer__c != null];
        
        String csvString = '';
        // Structure:
        String columns = 'Vorname;Nachname;Adressatentyp;Name;Letzte Immobiliennummer;Ort;Kontonummer;Kundennummer;UStIdNr.;Bankkonto;BLZ;BankName;Länderkennzeichen;IBAN;BIC;Anrede;Adresszusatz;Straße;PLZ;Steuernummer;Ansprechpartner;Telefonnummer;E-Mail;Faxnummer;Internetadresse;Land (2-stellig);UStEG-Land';
        csvString += columns;
        csvString += '\r\n';
        Integer csvColumnsCount = columns.split(';').size();
        // Create the CSV from contact data
        Integer customCounter = 0;
        for(Contact con:cons) {
            customCounter++;

            String lastName = con.LastName;
            String firstName = con.FirstName;
            String name = con.LastName;
            if(con.FirstName != null && con.LastName != null) {
                name = con.FirstName.trim() + ' ' + con.LastName.trim();
            }
            String letzteImmobiliennummer = con.LetzteImmobiliennummer__c;
            String city = con.MailingCity;
            String street = con.MailingStreet;
            String postalCode = con.MailingPostalCode;
            String country = con.MailingCountry;
            String accountNumber = con.DatevDebitorenKundennummerKaeufer__c;
            String customerNumber = con.DatevDebitorenKundennummerKaeufer__c;
            String iban = con.IBAN__c;
            String swift = con.SWIFT__c;
            String salutation = con.Salutation;

            csvString = fillCsv(csvString, csvColumnsCount, firstName, lastName, name, letzteImmobiliennummer, city, street, postalCode, country, accountNumber, customerNumber, iban, swift, salutation, false);
            
            if(customCounter != cons.size()) {
                csvString += '\r\n';
            }
        }

        if(String.isBlank(csvString)) {
            csvString = 'Keine Kontakte für den angegebenen Zeitraum gefunden.';
        }

        String urlEncoded = EncodingUtil.urlEncode(csvString, 'windows-1252');
        String[] chars = urlEncoded.replaceAll('\\+',' ').split('');

        for(Integer i = 0; i < chars.size(); i++) {
            if(chars[i] == '%') {
                chars[i] = EncodingUtil.convertToHex(EncodingUtil.convertFromHex(chars[i+1]+chars[i+2]));
                chars.remove(i+2);
                chars.remove(i+1);
            } else {
                chars[i] = EncodingUtil.convertToHex(Blob.valueOf(chars[i]));
            }
        }
        Blob csvFile = EncodingUtil.convertFromHex(String.join(chars,''));
        return csvFile;
    }

    public static Blob createDatevStammdatenCsvFromAccounts(Date startDate, Date endDate) {
        List<Gutschrift__c> gutschriften = [SELECT Empfaenger__c FROM Gutschrift__c WHERE DatumGutschriftBestaetigt__c >= :startDate AND DatumGutschriftBestaetigt__c <= :endDate AND Empfaenger__r.Gesch_ftsbeziehung__c != 'Mitarbeiter WH'];
        List<Id> conIds = new List<Id>();
        for(Gutschrift__c gs:gutschriften) {
            if(gs.Empfaenger__c != null) {
                conIds.add(gs.Empfaenger__c);
            }
        }
        endDate = endDate.addDays(1);

        List<Account> accs = [SELECT Id, BillingCity, BillingPostalCode, BillingStreet, BillingCountry, Unternehmensname__c, DatevKreditorennummer__c, IBAN__c, BIC__c FROM Account WHERE Id IN (SELECT AccountId FROM Contact WHERE Id IN :conIds) AND DatevKreditorennummer__c != null AND Unternehmensname__c != null];
        Set<Id> accountIds = new Set<Id>();
        for(Account acc:accs) {
            accountIds.add(acc.Id);
        }
        Set<Id> addedIds = new Set<Id>();

        String csvString = '';
        // Structure:
        String columns = 'Vorname (Adressattyp natürl. Person);Name (Adressattyp natürl. Person);Adressattyp;Name (Adressattyp Unternehmen);Ort;Konto;Kunden-/Lief.-Nr.;EU-UStID;Bank-Kontonummer 1;Bankleitzahl 1;Bankbezeichnung 1;Länderkennzeichen 1;IBAN-Nr. 1;SWIFT-Code 1;Anrede;Adresszusatz;Straﬂe;Postleitzahl;Steuernummer;Ansprechpartner;Telefon;E-Mail;Fax;Internet;Land;EU-Land';
        csvString += columns;
        csvString += '\r\n';
        Integer csvColumnsCount = columns.split(';').size();
        // Create the CSV from acctact data
        Integer customCounter = 0;
        for(Account acc:accs) {
            customCounter++;
            String lastName = acc.Unternehmensname__c;
            String name = acc.Unternehmensname__c;
            String city = acc.BillingCity;
            String street = acc.BillingStreet;
            String postalCode = acc.BillingPostalCode;
            String country = acc.BillingCountry;
            String accountNumber = acc.DatevKreditorennummer__c;
            String customerNumber = acc.DatevKreditorennummer__c;
            String iban = acc.IBAN__c;
            String swift = acc.BIC__c;

            csvString = fillCsv(csvString, csvColumnsCount, null, lastName, name, null, city, street, postalCode, country, accountNumber, customerNumber, iban, swift, null, true);
            if(customCounter != accountIds.size()) {
                csvString += '\r\n'; 
            }
        }

        if(String.isBlank(csvString)) {
            csvString = 'Keine Kontakte für den angegebenen Zeitraum gefunden.';
        }

        String urlEncoded = EncodingUtil.urlEncode(csvString, 'windows-1252');
        String[] chars = urlEncoded.replaceAll('\\+',' ').split('');

        for(Integer i = 0; i < chars.size(); i++) {
            if(chars[i] == '%') {
                chars[i] = EncodingUtil.convertToHex(EncodingUtil.convertFromHex(chars[i+1]+chars[i+2]));
                chars.remove(i+2);
                chars.remove(i+1);
            } else {
                chars[i] = EncodingUtil.convertToHex(Blob.valueOf(chars[i]));
            }
        }
        Blob csvFile = EncodingUtil.convertFromHex(String.join(chars,''));
        return csvFile;
    }

    public static String fillCsv(String csvString, 
                                    Integer csvColumnsCount, 
                                    String firstName, 
                                    String lastName, 
                                    String name, 
                                    String letzteImmobiliennummer, 
                                    String city, 
                                    String street, 
                                    String postalCode, 
                                    String country, 
                                    String accountNumber, 
                                    String customerNumber,
                                    String iban,
                                    String swift,
                                    String salutation,
                                    Boolean isAccount) {
        for(Integer i = 0; i < csvColumnsCount; i++) {
            switch on i {
                when 0 {
                    // FirstName
                    if(firstName != null) {
                        csvString += firstName.trim();
                    }
                }
                when 1 {
                    // LastName
                    if(lastName != null && !isAccount) {
                        csvString += lastName.trim();
                    }
                }
                when 2 {
                    String lastNameLowerCase = lastName.toLowerCase();
                    if(lastNameLowerCase.endsWith('gmbh') || 
                        lastNameLowerCase.endsWith('ug') || 
                        lastNameLowerCase.endsWith('gbr') ||
                        lastNameLowerCase.endsWith('e.k.') ||
                        lastNameLowerCase.endsWith('ohg') ||
                        lastNameLowerCase.endsWith('kg') || 
                        lastNameLowerCase.endsWith('ag') ||
                        isAccount) {
                        csvString += '2';
                    } else {
                        csvString += '1';
                    }
                }
                when 3 {
                    // Full name
                    if(name != null) {
                        csvString += name.trim();
                    }
                }
                when 4 {
                    // Immobiliennummer
                    if(letzteImmobiliennummer != null) {
                        csvString += letzteImmobiliennummer;
                    }
                }
                when 5 {
                    // City
                    if(city != null) {
                        csvString += city;
                    }
                }
                when 6 {
                    // Account no
                    if(accountNumber != null) {
                        csvString += accountNumber.trim();
                    }
                }
                when 7 {
                    // Customer no
                    if(customerNumber != null) {
                        csvString += customerNumber.trim();
                    }
                }
                when 8 {
                    // UstId
                }
                when 9 {
                    // Bank account no
                }
                when 10 {
                    // Bank code
                }
                when 11 {
                    // Bank name
                }
                when 12 {
                    // Country Code ISO
                }
                when 13 {
                    // IBAN
                    if(iban != null) {
                        csvString += iban.trim();
                    }
                }
                when 14 {
                    // BIC
                    if(swift != null) {
                        csvString += swift.trim();
                    }
                }
                when 15 {
                    // Salutation
                    if(salutation != null) {
                        csvString += salutation.trim();
                    }
                }
                when 16 {
                    // Additional address
                }
                when 17 {
                    // Street
                    if(street != null) {
                        csvString += street.trim();
                    }
                }
                when 18 {
                    // PostalCode
                    if(postalCode != null) {
                        csvString += postalCode.trim();
                    }
                }
                when 19 {
                    // Tax no
                }
                when 20 {
                    // Contact person
                }
                when 21 {
                    // Phone no
                }
                when 22 {
                    // E-Mail address
                }
                when 23 {
                    // Fax
                }
                when 24 {
                    // Website
                }
                when 25 {
                    // Country code 2 letters
                    if(country != null && (country.toLowerCase() == 'deutschland' || country.toLowerCase() == 'de' || country.toLowerCase() == 'd')) {
                        csvString += 'DE';
                    } else if(country == null) {
                        csvString += 'DE';
                    } else if(country != null) {
                        csvString += country.substring(0, 2).toUpperCase();
                    }
                }
                when 26 {
                    // UStEG-Land
                }
                when else {
                    // Nothing
                }
            }
            if(i < csvColumnsCount-1 && !(i == 4 && isAccount)) {
                csvString += ';';
            }
        }
        return csvString;
    }
}