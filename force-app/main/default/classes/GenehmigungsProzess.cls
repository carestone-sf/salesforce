global class GenehmigungsProzess implements Messaging.InboundEmailHandler {


    Contact createContact(Userdata userdata, Boolean kundenschutz) {
    	System.debug('In Create Contact');
    	Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        // Contact is being created
        Contact newCon = new Contact();
        newCon.Title = userdata.titel;
        newCon.Salutation = userdata.anrede;
        newCon.FirstName = userdata.firstName;
        newCon.LastName = userdata.lastName;
        newCon.Phone = userdata.phone;
        if(userdata.mail != null) {
        	newCon.Email = userdata.mail;
    	} else {
    		newCon.Email = 'witte@amstammtisch2.de';
    	}
        newCon.Position_Abteilung__c = userdata.position;
        if (userdata.mobile != 'False') {
            newCon.MobilePhone = userdata.mobile;
        }
        newCon.Gesch_ftsbeziehung__c = userdata.relationship;
        newCon.MailingStreet = userdata.street;
        newCon.MailingPostalCode = userdata.zip;
        newCon.MailingCity = userdata.city;
        newCon.OtherStreet = userdata.street;
        if(userdata.relationship == 'Interessent') {
        	newCon.Kunden_Maklerschutz__c = kundenschutz;
    } else {
    	newCon.Makler_Best_tigungsmail__c = kundenschutz;
    	newCon.Kunden_Maklerschutz__c = false;
    }
        newCon.OtherPostalCode = userdata.zip;
        newCon.OtherCity = userdata.city;
        newCon.LeadSource = userdata.source;
        newCon.Meeting__c = userdata.meeting.type;
        newCon.Datum_Meeting__c = userdata.meeting.cDate;
        if (userdata.istMaklerschutz == true) {
            if (userdata.hgb == true) {
                newCon.HGBNr__c = '84';
            } else if (userdata.hgb == false) {
                newCon.HGBNr__c = '93';
            }
        }
        if (userdata.meeting.contactType != 'False') {
            newCon.Art_des_Termins__c = userdata.meeting.contactType;
        }
        if (userdata.birthdate != null) {
            newCon.Birthdate = userdata.birthdate;
        }
        newCon.Aus_Maklerportal__c = true;
        newCon.Makler_E_Mail__c = userdata.loginMail;
        newCon.E_Mail_Portalnutzer__c = userdata.loginMail;
        Realty_User__c ref = [SELECT Contact__c FROM Realty_User__c WHERE Login_Email__c = : userdata.loginMail LIMIT 1];
        if (userdata.firma != null && userdata.firma != 'False') {
            try {
            	Contact parent = [SELECT Account.Id FROM Contact WHERE Id = : ref.Contact__c];
                Account acc = [SELECT Id, ParentId, Maklerschutz_besteht__c, Dauerhaft_gesch_tzt__c FROM Account WHERE Name = : userdata.firma LIMIT 1];
                System.debug(acc.Id);
                System.debug(parent.Account.Id);
                if(parent.Account.Id != acc.ParentId) {
                	if(acc.Maklerschutz_besteht__c == false && acc.Dauerhaft_gesch_tzt__c == false) {
                		acc.ParentId = parent.Account.Id;
                		acc.Maklerschutz_besteht__c = kundenschutz;
                		Database.update(acc, dml);
                	} else {
                		newCon.Makler_Best_tigungsmail__c = false;
                		Account newAcc = new Account();
                		newAcc.Name = userdata.firma;
	                	newAcc.Maklerschutz_besteht__c = false;
	                	Database.insert(newCon, dml);
	                	Database.insert(newAcc, dml);
	                	denialMail(userdata, newAcc, newCon);
	                	delete newAcc;
	                	delete newCon;
	                	return null;
                	}
                }
                newCon.AccountId = acc.Id;
            } catch (Exception e) {
                Contact parent = [SELECT Account.Id FROM Contact WHERE Id = : ref.Contact__c];
                Account newAcc = new Account();
                newAcc.Name = userdata.firma;
                newAcc.ParentId = parent.Account.Id;
                newAcc.BillingStreet = userdata.street;
                newAcc.BillingPostalCode = userdata.zip;
                newAcc.BillingCity = userdata.city;
                newAcc.Email__c = userdata.mail;
                newAcc.Phone = userdata.phone;
                newAcc.Gesch_ftsbeziehung__c = userdata.relationship;
                newAcc.Maklerschutz_besteht__c = kundenschutz;
                newCon.Position_Abteilung__c += '; Primärer Ansprechpartner';
                try {
                	insert newAcc;
                	newCon.AccountId = newAcc.Id;
                } catch(DmlException dExc) {
                	newCon.Makler_Best_tigungsmail__c = false;
                	newAcc.Maklerschutz_besteht__c = false;
                	Database.insert(newCon, dml);
                	Database.insert(newAcc, dml);
                	denialMail(userdata, newAcc, newCon);
                	delete newAcc;
                	delete newCon;
                	return null;
                }
            }
        } else {
            try {
                newCon.AccountId = [SELECT Account.Id FROM Contact WHERE Id = : ref.Contact__c].Account.Id;
            } catch (Exception e) {

            }
        }
        Database.insert(newCon, dml);
        return newCon;
    }

    void contactApproval(Boolean makler, Contact con) {
        // Contact is being send in for Approval
        // Boolean makler determines if it is a request for a broker or a normal customer
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Kontakt für Genehmigung eingereicht.');
        req1.setObjectId(con.id);
        if (makler == true) {
            req1.setProcessDefinitionNameOrId('Maklerschutz');
        } else {
            req1.setProcessDefinitionNameOrId('Interessentenschutz');
        }
        Approval.process(req1);
    }

    void denialMail(Userdata userdata, Contact con) {
        // Email to broker "Couldn't create"
        String[] toMails = new List < String > ();
        toMails.add(con.Makler_E_Mail__c);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Id templateId;
        templateId = [select id, name from EmailTemplate where developername = 'Abgelehnter_Kontakt'].id;
        email.setToAddresses(toMails);
        email.setTargetObjectId(con.Id);
        email.setTemplateId(templateId);
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            email
        });
        Database.rollback(sp);
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        try {
        	OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'maklerbetreuung@wirtschaftshaus.de'];
	if ( owea.size() > 0 ) {
	    emailToSend.setOrgWideEmailAddressId(owea.get(0).Id);
	}
	} catch(Exception e) {}
        emailToSend.setToAddresses(email.getToAddresses());

        emailToSend.setHTMLBody(email.getHTMLBody());

        emailToSend.setPlainTextBody(email.getPlainTextBody());

        emailToSend.setSubject(email.getSubject());

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            emailToSend
        });
    }

    void denialMail(Userdata userdata, Account acc, Contact con) {
        // Email to broker "Couldn't create"
        String[] toMails = new List < String > ();
        toMails.add(con.Makler_E_Mail__c);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Id templateId;
        templateId = [select id, name from EmailTemplate where developername = 'Abgelehnter_Account'].id;
        email.setToAddresses(toMails);
        email.setTargetObjectId(con.Id);
        email.setWhatId(acc.Id);
        email.setTemplateId(templateId);
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            email
        });
        Database.rollback(sp);
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();

	try {
        	OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'maklerbetreuung@wirtschaftshaus.de'];
	if ( owea.size() > 0 ) {
	    emailToSend.setOrgWideEmailAddressId(owea.get(0).Id);
	}
	} catch(Exception e) {}

        emailToSend.setToAddresses(email.getToAddresses());

        emailToSend.setHTMLBody(email.getHTMLBody());

        emailToSend.setPlainTextBody(email.getPlainTextBody());

        emailToSend.setSubject(email.getSubject());

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            emailToSend
        });
    }

    void inProcessMail(Userdata userdata, Contact con) {

        // Email to broker for both cases of a broker and a normal customer
        String[] toMails = new List < String > ();
        toMails.add(con.Makler_E_Mail__c);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Id templateId;
        templateId = [select id, name from EmailTemplate where developername = 'Kontakt_ist_in_Genehmigung'].id;
        email.setToAddresses(toMails);
        email.setTargetObjectId(con.Id);
        email.setTemplateId(templateId);
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            email
        });
        Database.rollback(sp);
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        try {
        	OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'maklerbetreuung@wirtschaftshaus.de'];
	if ( owea.size() > 0 ) {
	    emailToSend.setOrgWideEmailAddressId(owea.get(0).Id);
	}
	} catch(Exception e) {}
        emailToSend.setToAddresses(email.getToAddresses());

        emailToSend.setHTMLBody(email.getHTMLBody());

        emailToSend.setPlainTextBody(email.getPlainTextBody());

        emailToSend.setSubject(email.getSubject());

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            emailToSend
        });
    }

    Double compareContactData(Userdata userdata) {
        // Comparing the data between the contact being send in
        // and the contacts already in the system
        // The last name is used to find possible duplicates
        // At the end a number between 0 and 1 determines the highest match
        // 0 being no matches at all and 1 meaning a match of 100%

        // Postbank Brokers are generally denied
        System.debug(userdata.firma);
        System.debug(userdata.relationship);
        if(userdata.firma != null) {
        	if(userdata.firma.contains('Postbank') && userdata.relationship != 'Interessent') {
        		return 1;
        	}
    	}

        // If there is another Contact with the same mail + relationship, don't create the contact
        List<Contact> emailCons = [SELECT Id, Kundenschutz__c, Kunden_Maklerschutz__c, Maklerschutz_besteht__c, Maklerschutz_bis__c FROM Contact WHERE Email =: userdata.mail];
        Integer counter1 = 0;
        Integer counter2 = 0;
        for(Contact con:emailCons)
        {
            if((con.Kunden_Maklerschutz__c == null || datetime.now() > con.Kundenschutz__c) && (con.Maklerschutz_besteht__c == null || datetime.now() > con.Maklerschutz_bis__c))
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
        List < Contact > contacts = [SELECT FirstName, Email, LastName, Phone, MobilePhone, Gesch_ftsbeziehung__c, Kunden_Maklerschutz__c, Maklerschutz_bis__c, Maklerschutz_besteht__c, MailingStreet, MailingPostalCode, MailingCity, Kundenschutz__c FROM Contact WHERE LastName = : userdata.lastName];
        Double[] percentage = new Double[contacts.size()];
        userdata.phone = adjustNumber(userdata.phone);
        userdata.street = adjustStreet(userdata.street);
        if (userdata.mobile != 'False') {
            userdata.mobile = adjustNumber(userdata.mobile);
        }
        if (contacts.size() == 0) {
            return 0;
        }

        Integer i = 0;
        Double currentPercentage = 0;

        for (Contact con: contacts) {
            if (con.MailingPostalCode == null || con.MailingStreet == null) {
                // If the zip code is empty, the data being compared is not reliable for a safe distinction, so the data is send in for approval
                return 0.8;
            }
            currentPercentage = 0;
            String street = adjustStreet(con.MailingStreet);
            if (con.Phone != null) {
                String phone = adjustNumber(con.Phone);
            }
            if (con.MailingPostalCode.length() == userdata.zip.length()) {
                currentPercentage += 1;
            }
            if (con.FirstName != null) {
                if (con.FirstName.length() == userdata.firstName.length()) {
                    currentPercentage += 1;
                }
                currentPercentage += compareString(userdata.firstName, con.FirstName) * 3;
            } else {
                currentPercentage += 4;
            }
            currentPercentage += compareString(userdata.zip, con.MailingPostalCode) * 3;
            currentPercentage += compareString(userdata.street, street) * 2;
            currentPercentage = currentPercentage / 10;
            if (con.FirstName != null) {
                if (currentPercentage > 0.9 && compareString(userdata.firstName, con.FirstName) < 0.8) {
                    return 0.8;
                }
            } else {
                return 0.8;
            }
            if (currentPercentage > 0.6 && (con.Kunden_Maklerschutz__c == null || datetime.now() > con.Kundenschutz__c) && (con.Maklerschutz_besteht__c == null || datetime.now() > con.Maklerschutz_bis__c)) {
                return 0.8;
            }
            percentage[i] = currentPercentage;
            i++;
        }
        percentage.sort();
        Integer highestValue = percentage.size() - 1;
        Double highestPercentage = percentage[highestValue];
        return highestPercentage;
    }

    String adjustStreet(String street) {
        // Adjusts the street to match the common street pattern
        // e.g.: Strasse 3 C should be Str. 3c
        if (street.contains('Strasse')) {
            street = street.replace('Strasse', 'Str.');
        } else if (street.contains('Straße')) {
            street = street.replace('Straße', 'Str.');
        } else if (street.contains('strasse')) {
            street = street.replace('strasse', 'str.');
        } else if (street.contains('straße')) {
            street = street.replace('straße', 'str.');
        }
        // Check if the last character of the string is a string
        // eg: strasse 3a should be / strasse 3 a/A should not be
        Matcher hasString = Pattern.compile('\\d \\w$').matcher(street);
        if (hasString.find()) {
            Integer index2 = hasString.start();
            String preString2 = street.substring(0, index2 - 1);
            String afterString2 = street.substring(index2);
            afterString2 = afterString2.toLowerCase();
            afterString2 = afterString2.replace(' ', '');
            street = preString2 + afterString2;
        }
        return street;
    }

    String adjustNumber(String phoneno) {
        // Number examples: 0711-620092-66 , +49(621)43855-214 , 05306- 93 08 08
        // Should be: 071162009266 , 062143855214 , 05306930808

        // Replace all whitespaces + dashes
        phoneno = phoneno.replace('-', '');
        phoneno = phoneno.replace(' ', '');
        // Check if string contains +49(german phone code) and replace it with 0
        if (phoneno.contains('+49')) {
            phoneno = phoneno.replace('+49', '0');
        }
        if (phoneno.contains('(')) {
            String paranthesis = phoneno.substring(phoneno.indexOf('('), phoneno.indexOf(')'));
            if (paranthesis.length() > 3) {
                // If number contains paranthesis, replace it
                phoneno = phoneno.replace('(', '');
                phoneno = phoneno.replace(')', '');
            } else if (paranthesis.length() < 3) {
                // If the length of the paranthesis + string inside is < 3
                // eg.: 0(0)511, replace the paranthesis and the content
                phoneno = phoneno.replace(paranthesis, '');
            }
        }
        return phoneno;
    }

    Double compareString(String firstStr, String secondStr) {
        Double res = 5;
        // Compares each String character for character
        String shortStr = firstStr.split('').size() < secondStr.split('').size() ? firstStr : secondStr;
        String longStr = firstStr.split('').size() < secondStr.split('').size() ? secondStr : firstStr;
        String[] shortStrArr = shortStr.split('');
        String[] longStrArr = longStr.split('');
        Integer strSize = longStrArr.size();
        Integer diff = longStrArr.size() - shortStrArr.size();
        if (diff == 1) {
            try {
                for (Integer i = 0; i < longStrArr.size(); i++) {
                    if (shortStrArr[i].toLowerCase() != longStrArr[i].toLowerCase()) {
                        if (longStrArr[i + 1].toLowerCase() == shortStrArr[i].toLowerCase()) {
                            String compS1 = shortStr.substring(i - 1);
                            String compS2 = longStr.substring(i);
                            if (compS1 == compS2) {
                                longStr = longStr.substring(0, i - 1) + longStr.substring(i);
                                longStrArr = longStr.split('');
                            }
                        }
                    }
                }
            } catch (Exception e) {

            }
        }
        Double matches = 0;
        for (Integer i = 0; i < shortStrArr.size(); i++) {
            if (shortStrArr[i].toLowerCase() == longStrArr[i].toLowerCase()) {
                matches += 1;
            }
        }
        res = matches / strSize;
        return res;
    }

    class Userdata {
        // init all params
        private Boolean istMaklerschutz, hgb;
        private Date birthdate;
        private String loginMail,
        relationship,
        anrede,
        titel,
        firstName,
        lastName,
        firma,
        street,
        zip,
        city,
        mail,
        phone,
        mobile,
        source,
        position;
        private Meeting meeting = new Meeting();
        public Userdata(String[] emailBody) {
            // The mail being send in ALWAYS has the same structure
            // so it is safe to rely on indexes purely
            this.istMaklerschutz = Boolean.valueOf(emailBody[0]);
            this.loginMail = emailBody[1];
            this.relationship = emailBody[2];
            this.anrede = emailBody[3];
            if (emailBody[4] != '' && emailBody[4] != ' ') {
                this.titel = emailBody[4];
            } else {
                this.titel = null;
            }
            this.firstName = emailBody[5];
            this.lastName = emailBody[6];
            if (emailBody[7] != 'False') {
                this.firma = emailBody[7];
            } else {
                this.firma = null;
            }
            this.street = emailBody[8] + ' ' + emailBody[9];
            this.zip = emailBody[10];
            this.city = emailBody[11];
            if (emailBody[12] != 'False' && emailBody[12] != '' && emailBody[12] != ' ') {
                this.birthdate = date.parse(emailBody[12]);
            } else {
                this.birthdate = null;
            }
            if (emailBody[13] != 'False' && emailBody[13] != '' && emailBody[13] != ' ') {
                this.mail = emailBody[13];
            } else {
                this.mail = null;
            }
            this.phone = emailBody[14];
            if (emailBody[15] != '' && emailBody[15] != ' ') {
                this.mobile = emailBody[15];
            } else {
                this.mobile = 'False';
            }
            this.source = emailBody[16];
            this.hgb = Boolean.valueOf(emailBody[17]);
            this.meeting.type = emailBody[18];
            this.meeting.cDate = date.parse(emailBody[19]);
            this.meeting.contactType = emailBody[20];
            try {
            	this.position = emailBody[21];
            } catch (Exception e) {}
        }
    }

    class Meeting {
        String type, contactType;
        Date cDate;
        public Meeting() {
            this.type = '';
            this.contactType = '';
            this.cDate = date.parse('03.03.2014');
        }
    }

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env) {
        // Mail is being handled
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String[] emailBody = email.plainTextBody.split('\n');
        // First line of the incoming email indicates if the form request is a request of type "Maklerschutz" with string "true" or "false"
        // If it is, the mail has different content and is to be handled differently
        // Later on, the variable "istMaklerschutz" is used to determine if this is a request of type "Maklerschutz"
        Userdata userdata = new Userdata(emailBody);
        Double percentage = compareContactData(userdata);
        Contact con = new Contact();
        if (percentage < 0.6 && userdata.hgb == false) {
            con = createContact(userdata, True);
        } else if ((percentage > 0.6 && percentage < 0.9) || (percentage < 0.6 && userdata.hgb == true)) {
            con = createContact(userdata, False);
            if(con != null) {
            	inProcessMail(userdata, con);
            	contactApproval(userdata.istMaklerschutz, con);
        }
        } else if (percentage > 0.9) {
            con = createContact(userdata, False);
            if(con != null) {
	            denialMail(userdata, con);
	            delete con;
	        }
        }
        if(con != null)
        {
        if(con.Email == 'witte@amstammtisch2.de') {
        	con.Email = null;
        	update con;
        }
    }

        return result;
    }

}