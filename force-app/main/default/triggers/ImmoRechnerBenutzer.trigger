trigger ImmoRechnerBenutzer on Realty_User__c (before update, before insert, after update, after insert) {
    String pwd;
    Contact temporary = new Contact(FirstName='Test', LastName='temporaryContact', Email ='whaeveryouwant@email.com');
    insert temporary;
    List<Contact> toUpdate = new List<Contact>();
    Set<id> conID = new Set<id>();
    for(Realty_User__c immoUser:Trigger.new)
    {
        if(immoUser.Contact__c != null){
                conId.add(immoUser.Contact__c);
            }
    }
    Map<ID, Contact> con = new Map<id, contact>([SELECT Email, Maklerbetreuer_E_Mail__c FROM Contact WHERE ID in :conID]);
    if(trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            for(Realty_User__c immoUser:Trigger.new)
            {

                    if(immoUser.Herkunft__c == 'HypoServ') {
                        immoUser.Password__c = 'HypoServ' + Date.today().year();
                    }
                    immoUser.Buttons__c = 'immofinder; whtv; marketing; website; immoframe; infothek; terminplaner; ferienimmobilien; kapitalanlageimmobilien';
                                    List<Contact> contacts = [SELECT Id, Maklerbetreuer_E_Mail__c, Email, OwnerId From Contact WHERE Email =: immoUser.Email__c];
                                    if(contacts.size() == 1)
                                    {
                                        Contact relatedCon = new Contact();
                                        for(Contact cont : contacts)
                                        {
                                            relatedCon = cont;
                                        }
                                        immoUser.Contact__c = relatedCon.Id;
                                        immoUser.Active__c = true;
                                        if(relatedCon.Email == null || relatedCon.Email == ''){
                                            relatedCon.Email = immoUser.Email__c;
                                        }
                                        String[] toMails = new List<String>();
                                        toUpdate.add(relatedCon);
                                        try {
                                            immoUser.OwnerId = relatedCon.OwnerId;
                                            } catch (Exception e) {}
                            toMails.add(immoUser.Email__c);
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            Id templateId;
                            if(immoUser.Herkunft__c == 'WH Maklerportal' || immoUser.Herkunft__c == null)
                            {
                                templateId = [select id, name from EmailTemplate where developername = 'ImmoFinder_Registrierung'].id;
                            }
                            else
                            {
                                if(immoUser.Herkunft__c == 'HypoServ') {
                                    toMails.add('support@hyposerv.com');
                                }
                                try
                                {
                                    String templateName = immoUser.Herkunft__c + '_Registrierung';
                                    templateId = [select id, name from EmailTemplate where developername =: templateName].id;
                                } catch(Exception e)
                                {
                                    templateId = [select id, name from EmailTemplate where developername = 'ImmoFinder_Registrierung'].id;
                                }
                            }
                            email.setToAddresses(toMails);
                            email.setTargetObjectId(temporary.Id);
                            email.setTemplateId(templateId);
                            Savepoint sp = Database.setSavepoint();
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                            Database.rollback(sp);
                            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();

                            emailToSend.setToAddresses(email.getToAddresses());

                            String formatEmail = email.getHTMLBody();
                            formatEmail = formatEmail.replace('{Realty_User__c.Name}', immoUser.Name);
                            formatEmail = formatEmail.replace('{Realty_User__c.Login_Email__c}', immoUser.Login_Email__c);
                            formatEmail = formatEmail.replace('{Realty_User__c.Password__c}', immoUser.Password__c);

                            emailToSend.setHTMLBody(formatEmail);

                            formatEmail = email.getPlainTextBody();
                            formatEmail = formatEmail.replace('{Realty_User__c.Name}', immoUser.Name);
                            formatEmail = formatEmail.replace('{Realty_User__c.Login_Email__c}', immoUser.Login_Email__c);
                            formatEmail = formatEmail.replace('{Realty_User__c.Password__c}', immoUser.Password__c);

                            emailToSend.setPlainTextBody(formatEmail);

                            emailToSend.setSubject(email.getSubject());

                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailToSend});
                                    } else
                                    {
                                        try {
                                            User u = [SELECT Id FROM User WHERE Name = 'Anika Hein'];
                                            immoUser.OwnerId = u.Id;
                                            } catch (Exception e) {}
                                    }
                                }
        }

        if(trigger.isUpdate)
        {
            for(Realty_User__c user : trigger.new)
            {
                    if(user.Contact__c != Trigger.oldMap.get(user.Id).Contact__c && user.Contact__c != null)
                    {
                        try {
                            Contact relatedCon = con.get(user.Contact__c);
                                user.OwnerId = relatedCon.OwnerId;
                            } catch (Exception e) {}
                    }
                if(user.Passwort_vergessen__c == true)
                {
                    Integer len = 8;
                    Blob blobKey = Crypto.generateAesKey(128);
                    String key = EncodingUtil.convertToHex(blobKey);
                    pwd = key.substring(0,len);

                    user.Password__c = pwd;
                    user.Passwort_vergessen__c = false;

                    String[] toMails = new List<String>();
                    toMails.add(user.Email__c);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    Id templateId;
                    if(user.Herkunft__c == 'WH Maklerportal' || user.Herkunft__c == null)
                    {
                        templateId = [select id, name from EmailTemplate where developername = 'ImmoFinder_neue_PW'].id;
                    }
                    else
                    {
                        try
                        {
                            String templateName = user.Herkunft__c + '_Passwort_vergessen';
                            templateId = [select id, name from EmailTemplate where developername =: templateName].id;
                        }
                        catch(Exception e)
                        {
                            templateId = [select id, name from EmailTemplate where developername = 'ImmoFinder_neue_PW'].id;
                        }
                    }
                    email.setToAddresses(toMails);
                    email.setTargetObjectId(temporary.Id);
                    email.setTemplateId(templateId);

                    Savepoint sp = Database.setSavepoint();
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                    Database.rollback(sp);
                    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();

                    emailToSend.setToAddresses(email.getToAddresses());

                    String formatEmail = email.getHTMLBody();
                    formatEmail = formatEmail.replace('{Realty_User__c.Name}', user.Name);
                    formatEmail = formatEmail.replace('{Realty_User__c.Login_Email__c}', user.Login_Email__c);
                    formatEmail = formatEmail.replace('{Realty_User__c.Password__c}', user.Password__c);

                    emailToSend.setHTMLBody(formatEmail);

                    formatEmail = email.getPlainTextBody();
                    formatEmail = formatEmail.replace('{Realty_User__c.Name}', user.Name);
                    formatEmail = formatEmail.replace('{Realty_User__c.Login_Email__c}', user.Login_Email__c);
                    formatEmail = formatEmail.replace('{Realty_User__c.Password__c}', user.Password__c);

                    emailToSend.setPlainTextBody(formatEmail);

                    emailToSend.setSubject(email.getSubject());

                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailToSend});

                }
            }
        }
    }

    if(trigger.isAfter){

        if(trigger.isUpdate)
        {
            for(Realty_User__c user:Trigger.new)
            {
                if(Trigger.oldMap.get(user.id).Password__c != user.Password__c)
                {
                    String[] toMails = new List<String>();
                    toMails.add(user.Email__c);
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    Id templateId;
                    if(user.Herkunft__c == 'WH Maklerportal' || user.Herkunft__c == null)
                    {
                        templateId = [select id, name from EmailTemplate where developername = 'ImmoFinder_neue_PW'].id;
                    }
                    else
                    {
                        try
                        {
                            String templateName = user.Herkunft__c + '_Passwort_ge_ndert';
                            templateId = [select id, name from EmailTemplate where developername =: templateName].id;
                        } catch(Exception e)
                        {
                            templateId = [select id, name from EmailTemplate where developername = 'ImmoFinder_Registrierung'].id;
                        }
                    }
                    email.setToAddresses(toMails);
                    email.setTargetObjectId(temporary.Id);
                    email.setTemplateId(templateId);
                    Savepoint sp = Database.setSavepoint();
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                    Database.rollback(sp);
                    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();

                    emailToSend.setToAddresses(email.getToAddresses());

                    String formatEmail = email.getHTMLBody();
                    formatEmail = formatEmail.replace('{Realty_User__c.Name}', user.Name);
                    formatEmail = formatEmail.replace('{Realty_User__c.Login_Email__c}', user.Login_Email__c);
                    formatEmail = formatEmail.replace('{Realty_User__c.Password__c}', user.Password__c);

                    System.debug(formatEmail);

                    emailToSend.setHTMLBody(formatEmail);

                    formatEmail = email.getPlainTextBody();
                    formatEmail = formatEmail.replace('{Realty_User__c.Name}', user.Name);
                    formatEmail = formatEmail.replace('{Realty_User__c.Login_Email__c}', user.Login_Email__c);
                    formatEmail = formatEmail.replace('{Realty_User__c.Password__c}', user.Password__c);

                    emailToSend.setPlainTextBody(formatEmail);

                    emailToSend.setSubject(email.getSubject());

                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailToSend});
                }
            }
        }

        if(trigger.isUpdate || trigger.isInsert) {

            for(Realty_User__c iUser : trigger.new){
                if(iUser.Contact__c == null && iUser.Active__c == true)
                {
                    iUser.Active__c.addError('Um den Benutzer zu aktivieren, muss ihm ein Kontakt zugeordnet werden.');
                }
            }

            for(Realty_User__c immoUser : trigger.new){

                if(immoUser.Contact__c != null && immoUser.Active__c == true)
                {
                    if(Trigger.isUpdate)
                    {
                        if(Trigger.oldMap.get(immoUser.id).Active__c != immoUser.Active__c)
                        {
                            String[] toMails = new List<String>();
                            toMails.add(immoUser.Email__c);
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            Id templateId;
                            if(immoUser.Herkunft__c == 'WH Maklerportal' || immoUser.Herkunft__c == null)
                            {
                                templateId = [select id, name from EmailTemplate where developername = 'ImmoFinder_Registrierung'].id;
                            }
                            else
                            {
                                try
                                {
                                    String templateName = immoUser.Herkunft__c + '_Registrierung';
                                    templateId = [select id, name from EmailTemplate where developername =: templateName].id;
                                } catch(Exception e)
                                {
                                    templateId = [select id, name from EmailTemplate where developername = 'ImmoFinder_Registrierung'].id;
                                }
                            }
                            email.setToAddresses(toMails);
                            email.setTargetObjectId(temporary.Id);
                            email.setTemplateId(templateId);
                            Savepoint sp = Database.setSavepoint();
                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                            Database.rollback(sp);
                            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();

                            emailToSend.setToAddresses(email.getToAddresses());

                            String formatEmail = email.getHTMLBody();
                            formatEmail = formatEmail.replace('{Realty_User__c.Name}', immoUser.Name);
                            formatEmail = formatEmail.replace('{Realty_User__c.Login_Email__c}', immoUser.Login_Email__c);
                            formatEmail = formatEmail.replace('{Realty_User__c.Password__c}', immoUser.Password__c);

                            emailToSend.setHTMLBody(formatEmail);

                            formatEmail = email.getPlainTextBody();
                            formatEmail = formatEmail.replace('{Realty_User__c.Name}', immoUser.Name);
                            formatEmail = formatEmail.replace('{Realty_User__c.Login_Email__c}', immoUser.Login_Email__c);
                            formatEmail = formatEmail.replace('{Realty_User__c.Password__c}', immoUser.Password__c);

                            emailToSend.setPlainTextBody(formatEmail);

                            emailToSend.setSubject(email.getSubject());

                            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailToSend});
                        }
                    }

                    Contact contact = con.get(immoUser.Contact__c);
                    if(contact.Email == null || contact.Email == ''){
                        contact.Email = immoUser.Email__c;
                    }
                    toUpdate.add(contact);

                }

            }
        }
        if(!toUpdate.isEmpty()){
            Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
                Set<Contact> mySet = new Set<Contact>();
                mySet.addAll(toUpdate);
                toUpdate.clear();
                toUpdate.addAll(mySet);
                Database.update(toUpdate, dml);
        }
    }
    delete temporary;
}