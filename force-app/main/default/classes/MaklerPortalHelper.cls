// This class initizes the "MaklerPortalHelper"-object
// so that you don't need to insert all of  these records
// for each class that you write by hand

global class MaklerPortalHelper {

    global Account acc;
    global Contact con;
    global Realty_User__c user;
    global Realty_User__c user2;

    global MaklerPortalHelper() {
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;

        acc = new Account();
        acc.Name = 'Test Account';
        acc.Email__c='tesaat@mahil.com';
        acc.E_Mail_bergeordneter_Makler__c = 'tesaat@mahil.com';
        Database.insert(acc, dml);

        con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Kontakt';
        con.AccountID = acc.Id;
        con.Gesch_ftsbeziehung__c = 'Interessent';
        Database.insert(con, dml);

        user = new Realty_User__c();
        user.Name = 'Test Nutzer';
        user.Email__c = 'test@mail.com';
        user.Login_Email__c = 'test@mail.com';
        user.Password__c = 'testpw';
        user.Type__c = 'Normal Agency';
        user.Contact__c = con.Id;
        Database.insert(user, dml);

        user2 = new Realty_User__c();
        user2.Name = 'Test Nutzer';
        user2.Email__c = 'test2@mail.com';
        user2.Login_Email__c = 'test2@mail.com';
        user2.Password__c = 'testpw';
        user2.Type__c = 'Admin';
        user2.Contact__c = con.Id;
        Database.insert(user2, dml);
    }
}