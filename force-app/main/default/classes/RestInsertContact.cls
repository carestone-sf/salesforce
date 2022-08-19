@RestResource(urlMapping='/InsertContact/*')
global with sharing class RestInsertContact {

  @HttpPost
    global static ReturnData doPost(UserData userdata)
    {

        ReturnData rd = new ReturnData();
        rd.percentage = compareData(userdata);
        Contact con = createContact(userdata);
        if(rd.percentage < 0.6)
        {
            con.Kunden_Maklerschutz__c = true;
            update con;
        }
        else if((rd.percentage > 0.6 && rd.percentage < 0.9))
        {
            inProcessMail(userdata, con);
            contactApproval(con);
        }
        else if(rd.percentage > 0.9)
        {
            denialMail(userdata, con);
            delete con;
        }

        if(con != null)
        {
            rd.id = con.Id;
        }

        return rd;
    }

    global class ReturnData {
        private Id id = null;
        private Double percentage = null;
    }

    global class Userdata
    {
        // init all params
        public Date birthdate;
        public String loginMail,
                       firstName,
                       lastName,
                       street,
                       zip,
                       city,
                       mail,
                       phone,
                       beruf,
                       salutation,
                       familienstand;
        public Double percentage;
        public String relationship = 'Interessent';
        public Integer steuernummer;
    }

    public static Contact createContact(Userdata userdata)
    {
        // Contact is being created
        Contact newCon = new Contact();
        newCon.FirstName = userdata.firstName;
        newCon.LastName = userdata.lastName;
        newCon.Phone = userdata.phone;
        newCon.Email = userdata.mail;
        newCon.Gesch_ftsbeziehung__c = userdata.relationship;
        newCon.MailingStreet = userdata.street;
        newCon.MailingPostalCode = userdata.zip;
        newCon.MailingCity = userdata.city;
        newCon.OtherStreet = userdata.street;
        newCon.OtherPostalCode = userdata.zip;
        newCon.OtherCity = userdata.city;
        newCon.Birthdate = userdata.birthdate;
        newCon.Aus_Maklerportal__c = true;
        newCon.Makler_E_Mail__c = userdata.loginMail;
        newCon.E_Mail_Portalnutzer__c = userdata.loginMail;
        Realty_User__c ref = [SELECT Contact__c FROM Realty_User__c WHERE Login_Email__c = :userdata.loginMail];
        newCon.AccountId = [SELECT Account.Id FROM Contact WHERE Id = :ref.Contact__c].Account.Id;
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.insert(newCon, dml);
        return newCon;
    }

    public static void contactApproval(Contact con)
    {
        // Contact is being send in for Approval
        // Boolean makler determines if it is a request for a broker or a normal customer
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Kontakt für Genehmigung eingereicht.');
        req1.setObjectId(con.id);
        req1.setProcessDefinitionNameOrId('Interessentenschutz');
        Approval.process(req1);
    }

    public static void denialMail(Userdata userdata, Contact con)
    {
        // Email to broker "Couldn't create"
        String[] toMails = new List<String>();
        toMails.add(con.Makler_E_Mail__c);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Id templateId;
        templateId = [select id, name from EmailTemplate where developername = 'Abgelehnter_Kontakt'].id;
        email.setToAddresses(toMails);
        email.setTargetObjectId(con.Id);
        email.setTemplateId(templateId);
        Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        Database.rollback(sp);
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();

        emailToSend.setToAddresses(email.getToAddresses());

        emailToSend.setHTMLBody(email.getHTMLBody());

        emailToSend.setPlainTextBody(email.getPlainTextBody());

        emailToSend.setSubject(email.getSubject());

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailToSend});
    }

    public static void inProcessMail(Userdata userdata, Contact con)
    {

        // Email to broker for both cases of a broker and a normal customer
        String[] toMails = new List<String>();
        toMails.add(con.Makler_E_Mail__c);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Id templateId;
        templateId = [select id, name from EmailTemplate where developername = 'Kontakt_ist_in_Genehmigung'].id;
        email.setToAddresses(toMails);
        email.setTargetObjectId(con.Id);
        email.setTemplateId(templateId);
        Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        Database.rollback(sp);
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();

        emailToSend.setToAddresses(email.getToAddresses());

        emailToSend.setHTMLBody(email.getHTMLBody());

        emailToSend.setPlainTextBody(email.getPlainTextBody());

        emailToSend.setSubject(email.getSubject());

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailToSend});
    }

    public static Double comparedata(Userdata userdata)
    {
        // Comparing the data between the contact being send in
        // and the contacts already in the system
        // The last name is used to find possible duplicates
        // At the end a number between 0 and 1 determines the highest match
        // 0 being no matches at all and 1 meaning a match of 100%

        // If there is another Contact with the same mail + relationship, don't create the contact
        List<Contact> emailCons = [SELECT Id, Kundenschutz__c FROM Contact WHERE Email =: userdata.mail AND Gesch_ftsbeziehung__c =: userdata.relationship];
        Integer counter1 = 0;
        Integer counter2 = 0;
        for(Contact con:emailCons)
        {
            if(con.Kundenschutz__c == null || datetime.now() > con.Kundenschutz__c)
            {
                // Determines if Kundenschutz__c is expired of the contact with the duplicate email
                counter1++;
            }
            else
            {
                // Determines if the email is a duplicate and the Kundenschutz__c is still intact
                counter2++;
            }
        }
        if(counter1 > 0)
        {
            return 0.8;
        }
        else if(counter2 > 0)
        {
            return 1;
        }

        // Selects all Contacts with the same LastName and compares them
        List<Contact> contacts = [SELECT FirstName, Email, LastName, Phone, MobilePhone, Gesch_ftsbeziehung__c, MailingStreet, MailingPostalCode, MailingCity, Kundenschutz__c, Dauerhaft_gesch_tzt__c FROM Contact WHERE LastName =: userdata.lastName];
        Double[] percentage = new Double[contacts.size()];
        userdata.phone = adjustNumber(userdata.phone);
        userdata.street = adjustStreet(userdata.street);
        if(contacts.size() == 0)
        {
            return 0;
        }

        Integer i = 0;
        Double currentPercentage = 0;

        for(Contact con:contacts)
        {
            if(con.MailingPostalCode == null || con.MailingStreet == null)
            {
                // If the zip code is empty, the data being compared is not reliable for a safe distinction, so the data is send in for approval
                return 0.8;
            }
            currentPercentage = 0;
            String street = adjustStreet(con.MailingStreet);
            if(con.Phone != null)
            {
                String phone = adjustNumber(con.Phone);
            }
            if(con.MailingPostalCode.length() == userdata.zip.length())
            {
                currentPercentage += 1;
            }
            if(con.FirstName != null)
            {
                if(con.FirstName.length() == userdata.firstName.length())
                {
                    currentPercentage += 1;
                }
                currentPercentage += compareString(userdata.firstName, con.FirstName) * 3;
            }
            else
            {
                currentPercentage += 4;
            }
            currentPercentage += compareString(userdata.zip, con.MailingPostalCode) * 3;
            currentPercentage += compareString(userdata.street, street) * 2;
            currentPercentage = currentPercentage / 10;
            if(con.FirstName != null)
            {
                if(currentPercentage > 0.9 && compareString(userdata.firstName, con.FirstName) < 0.8)
                {
                    return 0.8;
                }
            }
            else
            {
                return 0.8;
            }
            if(currentPercentage > 0.6 && (con.Kundenschutz__c == null || datetime.now() > con.Kundenschutz__c))
            {
                return 0.8;
            }
            percentage[i] = currentPercentage;
            i++;
        }
        percentage.sort();
        Integer highestValue = percentage.size()-1;
        Double highestPercentage = percentage[highestValue];
        return highestPercentage;
    }

    public static String adjustStreet(String street)
    {
        // Adjusts the street to match the common street pattern
        // e.g.: Strasse 3 C should be Str. 3c
        if(street.contains('Strasse'))
        {
            street = street.replace('Strasse', 'Str.');
        }
        else if(street.contains('Straße'))
        {
            street = street.replace('Straße', 'Str.');
        }
        else if(street.contains('strasse'))
        {
            street = street.replace('strasse', 'str.');
        }
        else if(street.contains('straße'))
        {
            street = street.replace('straße', 'str.');
        }
        // Check if the last character of the string is a string
        // eg: strasse 3a should be / strasse 3 a/A should not be
        Matcher hasString = Pattern.compile('\\d \\w$').matcher(street);
        if(hasString.find())
        {
            Integer index2 = hasString.start();
            String preString2 = street.substring(0, index2-1);
            String afterString2 = street.substring(index2);
            afterString2 = afterString2.toLowerCase();
            afterString2 = afterString2.replace(' ', '');
            street = preString2 + afterString2;
        }
        return street;
    }

    public static String adjustNumber(String phoneno)
    {
        // Number examples: 0711-620092-66 , +49(621)43855-214 , 05306- 93 08 08
        // Should be: 071162009266 , 062143855214 , 05306930808

        // Replace all whitespaces + dashes
        phoneno = phoneno.replace('-', '');
        phoneno = phoneno.replace(' ', '');
        // Check if string contains +49(german phone code) and replace it with 0
        if(phoneno.contains('+49'))
        {
            phoneno = phoneno.replace('+49', '0');
        }
        if(phoneno.contains('('))
        {
            String paranthesis = phoneno.substring(phoneno.indexOf('('), phoneno.indexOf(')'));
            if(paranthesis.length() > 3)
            {
                // If number contains paranthesis, replace it
                phoneno = phoneno.replace('(', '');
                phoneno = phoneno.replace(')', '');
            }
            else if(paranthesis.length() < 3)
            {
                // If the length of the paranthesis + string inside is < 3
                // eg.: 0(0)511, replace the paranthesis and the content
                phoneno = phoneno.replace(paranthesis, '');
            }
        }
        return phoneno;
    }

    public static Double compareString(String firstStr, String secondStr)
    {
        Double res = 5;
        // Compares each String character for character
        String shortStr = firstStr.split('').size() < secondStr.split('').size() ? firstStr : secondStr;
        String longStr = firstStr.split('').size() < secondStr.split('').size() ? secondStr : firstStr;
        String[] shortStrArr = shortStr.split('');
        String[] longStrArr = longStr.split('');
        Integer strSize = longStrArr.size();
        Integer diff = longStrArr.size() - shortStrArr.size();
        if(diff == 1)
        {
            try
            {
                for(Integer i = 0; i < longStrArr.size(); i++)
                {
                    if(shortStrArr[i].toLowerCase() != longStrArr[i].toLowerCase())
                    {
                        if(longStrArr[i+1].toLowerCase() == shortStrArr[i].toLowerCase())
                        {
                            String compS1 = shortStr.substring(i-1);
                            String compS2 = longStr.substring(i);
                            if(compS1 == compS2)
                            {
                                longStr = longStr.substring(0, i-1) + longStr.substring(i);
                                longStrArr = longStr.split('');
                            }
                        }
                    }
                }
            }
            catch(Exception e)
            {

            }
        }
        Double matches = 0;
        for(Integer i = 0; i < shortStrArr.size(); i++)
        {
            if(shortStrArr[i].toLowerCase() == longStrArr[i].toLowerCase())
            {
                matches += 1;
            }
        }
        res = matches/strSize;
        return res;
    }
}