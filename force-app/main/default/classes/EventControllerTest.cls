@IsTest
public with sharing class EventControllerTest {
    private static testMethod void getCampaignsAndEventsTest() {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        // Maklerbetreuer + Account erstellen
        Contact mb = new Contact();
        mb.FirstNAme = 'Frank';
        mb.LastName = 'Köpsell';
        mb.Email = 'f.witte@wirtschaftshaus.de';
        mb.MaklerBetreuer_E_Mail__c = 'f.witte@wirtschaftshaus.de';
        mb.Ist_Maklerbetreuer_WH__c = true;
        mb.Gesch_ftsbeziehung__c = 'Mitarbeiter WH';
        Database.insert(mb, dml);
        Account acc = new Account();
        acc.Name = 'CS Maklerbetreuer GmbH';
        acc.Email__c = 'f.witte@wirtschaftshaus.de';
        acc.Maklerbetreuer_Wirtschaftshaus__c = 'Frank Köpsell';
        acc.Maklerbetreuer_Wirtschaftshaus_2__c = mb.Id;
        Database.insert(acc, dml);
        mb.AccountId = acc.Id;
        Database.update(mb, dml);

        Id maklerRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Makler').getRecordTypeId();
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.Gesch_ftsbeziehung__c = 'Versicherungsmakler';
        con.FirstName = 'Max';
        con.MailingStreet = 'Teststr. 24';
        con.MailingCity = 'Hannover';
        con.MailingPostalCode = '30159';
        con.LastName = 'Maklermann 6';
        con.RecordTypeId = maklerRecordTypeId;
        insert con;

        Database.insert(con, dml);

        Profile portalProfileUser = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community%User' Limit 1];
        Profile portalProfileManager = [SELECT Id FROM Profile WHERE Name LIKE '%Partner Community%Manager' Limit 1];
        String accNameSelector = '%' + acc.Name + '%';
        List<PermissionSetAssignment> pmas = new List<PermissionSetAssignment>();
        List<PermissionSet> pms = [SELECT Id, Name FROM PermissionSet WHERE Name Like '%Community%'];
        PermissionSet accPm;
        PermissionSet conPm;
        PermissionSet provPm;
        PermissionSet immPm;
        for(PermissionSet pm:pms) {
            if(pm.Name.contains('Accounts')) { 
                accPm = pm;
            } else if(pm.Name.contains('Kontakte')) { 
                conPm = pm;
            } else if(pm.Name.contains('Provision')) { 
                provPm = pm;
            } else if(pm.Name.contains('Immobilie')) {
                immPm = pm;
            }
        }
        List<User> communityUsers = new List<User>();
        String sbName = UserInfo.getUserName().substringAfterLast('.');
        User usr = new User(
            ProfileId = portalProfileManager.Id,
            EmailEncodingKey='UTF-8',
            Firstname=con.firstName,
            Lastname=con.LastName,
            LanguageLocaleKey='de',
            LocaleSidKey='de_DE',
            TimeZoneSidKey='GMT',
            ContactId=con.Id);
    
            usr.Username = 'salesaccount5@test.de';
            usr.profileId = portalProfileUser.Id;
            con.LastName = 'Sales-Account';
        
        usr.Alias = usr.Username.substring(0,6);
        usr.Email= 'test@test.de';
        insert usr;

        Event e = new Event();
        e.Subject = 'Test';
        e.WhoId = con.Id;
        e.StartDateTime = DateTime.now();
        e.EndDateTime = DateTime.now() + 1;
        insert e;

        //Create Campaigns
        List<Campaign> campInsert = new List<Campaign>();
        Campaign campReg = new Campaign(Name='Registered',Type='Webinar',Organizer__c=acc.Id,DateTime__c=DateTime.now()+2);
        campInsert.add(campReg);
        Campaign campUnreg = new Campaign(Name='Unregistered',Type='Webinar',Organizer__c=acc.Id,DateTime__c=DateTime.now()+2);
        campInsert.add(campUnreg);
        Database.insert(campInsert,dml);

        //Create Campaign Member
        CampaignMember cm1 = new CampaignMember(ContactId=con.Id,CampaignId=campReg.Id);
        CampaignMember cm2 = new CampaignMember(ContactId=con.Id,CampaignId=campUnreg.Id);
        Database.insert(cm2);

        
        EventController.createCampaignMember(cm1);
        EventController.deleteCampaignMember(cm2);

        User user = [SELECT Id FROM User WHERE LastName = 'Maklermann 6'];
        System.runAs(user) {
            EventController.getCampaignsAndEvents();
        }
    }
}