@isTest
private class RestInsertContactTest {

	@isTest static void CreateContactWithoutConflict() {
		Account acc = TestDataFactory.createAccount(true);

		Contact con = TestDataFactory.createContact(false);
		con.FirstName='test';
		con.LastName='tester';
		con.Email='test@mail.com';
		con.AccountId=acc.Id;
		insert con;

		Realty_User__c reu = TestDataFactory.createImmoUser(false, Con.Id);
        reu.Type__c = 'Administrator';
        reu.Email__c = 'test@mail.com';
        reu.Login_Email__c = 'test@mail.com';
        reu.Name = 'test tester';
		insert reu;

		RestInsertContact.UserData userData = new RestInsertContact.Userdata();
		userData.loginMail='test@mail.com';
		userData.firstName='Karl';
		userData.lastName = 'Otto';
		userData.street = 'teststr 123';
		userData.phone = '05112323';

		RestInsertContact.doPost(userData);
	}

	@isTest static void CreateContactWithPossibleDuplicate() {
		User testUser = TestDataFactory.createTestUser(true, 'TestAdmin', 1);
        try{
            PermissionSet ps_status = [SELECT Id FROM PermissionSet WHERE Name = 'Can_change_stage_status'];
            PermissionSet ps_contact = [SELECT Id FROM PermissionSet WHERE Name = 'ChangeContactAccount'];
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps_status.Id);
            insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = ps_contact.Id);
        }
        catch(DmlException e){
            System.debug(e.getMessage());
        }

        System.runAs(testUser){
			Account acc = TestDataFactory.createAccount(true);
			
			Contact con = TestDataFactory.createContact(false);
			con.FirstName='test';
			con.LastName='tester';
			con.Email='test@mail.com';
			con.Makler_E_Mail__c='test@mail.com';
			con.AccountId=acc.Id;
			insert con;

			Realty_User__c reu = TestDataFactory.createImmoUser(false, Con.Id);
			reu.Email__c = 'test@mail.com';
			reu.Login_Email__c = 'test@mail.com';
			reu.Name = 'test tester';
			insert reu;

			RestInsertContact.UserData userData = new RestInsertContact.Userdata();
			userData.loginMail='test@mail.com';
			userData.firstName='test';
			userData.lastName = 'tester';
			userData.street = 'teststr 123';
			userData.phone = '05112323';
			userData.mail = 'testmail@maili.com';
			userData.zip = '12345';

			RestInsertContact.doPost(userData);
		}
		
	}
		

	@isTest static void CreateContactWithDuplicateEmail() {
		Account acc = TestDataFactory.createAccount(true);

		Contact con = TestDataFactory.createContact(false);
		con.FirstName='test';
		con.LastName='tester';
		con.Email='test@mail.com';
		con.Makler_E_Mail__c='test@mail.com';
		con.AccountId=acc.Id;
		con.MailingStreet = 'teststr 123';
		con.MailingPostalCode='12345';
		insert con;

		Realty_User__c reu = TestDataFactory.createImmoUser(false, Con.Id);
        reu.Type__c = 'Administrator';
        reu.Email__c = 'test@mail.com';
        reu.Login_Email__c = 'test@mail.com';
        reu.Name = 'test tester';
		insert reu;


		RestInsertContact.UserData userData = new RestInsertContact.Userdata();
		userData.loginMail='test@mail.com';
		userData.firstName='test';
		userData.lastName = 'tester';
		userData.street = 'teststr 123';
		userData.phone = '05112323';
		userData.mail = 'testmail@maili.com';
		userData.zip = '12345';

		RestInsertContact.doPost(userData);
	}

	@isTest static void CreateContactWithDuplicate() {
		Account acc = TestDataFactory.createAccount(true);

		Contact con = TestDataFactory.createContact(false);
		con.FirstName='test';
		con.LastName='tester';
		con.Email='test@mail.com';
		con.Makler_E_Mail__c='test@mail.com';
		con.AccountId=acc.Id;
		con.MailingStreet = 'teststr 123';
		con.MailingPostalCode='12345';
		con.Kundenschutz__c=DateTime.now().addHours(24);
		insert con;

		Realty_User__c reu = TestDataFactory.createImmoUser(false, Con.Id);
        reu.Type__c = 'Administrator';
        reu.Email__c = 'test@mail.com';
        reu.Login_Email__c = 'test@mail.com';
        reu.Name = 'test tester';
		insert reu;

		RestInsertContact.UserData userData = new RestInsertContact.Userdata();
		userData.loginMail='test@mail.com';
		userData.firstName='test';
		userData.lastName = 'tester';
		userData.street = 'teststr 123';
		userData.phone = '05112323';
		userData.mail = 'testmail2@maili.com';
		userData.zip = '12345';

		RestInsertContact.doPost(userData);
	}

}