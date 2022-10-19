@isTest
private class RestInsertContactTest {

	@isTest static void CreateContactWithoutConflict() {
		Account acc = TestDataFactory.createAccount(true);
		Contact con = new Contact(FirstName='test', LastName='tester', Email='test@mail.com',AccountId=acc.Id);
		insert con;
		Realty_User__c reu = new Realty_User__c(Password__c='test123',Name='test tester',Email__c='test@mail.com',Login_Email__c='test@mail.com',Contact__c=con.Id);
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
		Account acc = TestDataFactory.createAccount(true);
		Contact con = new Contact(FirstName='test', LastName='tester', Email='test@mail.com',Makler_E_Mail__c='test@mail.com',AccountId=acc.Id);
		insert con;
		Realty_User__c reu = new Realty_User__c(Password__c='test123',Name='test tester',Email__c='test@mail.com',Login_Email__c='test@mail.com',Contact__c=con.Id);
		insert reu;


		RestInsertContact.UserData userData = new RestInsertContact.Userdata();
		userData.loginMail='test@mail.com';
		userData.firstName='test';
		userData.lastName = 'tester';
		userData.street = 'teststr 123';
		userData.phone = '05112323';
		userData.mail = 'testmail@maili.com';

		RestInsertContact.doPost(userData);
	}

	@isTest static void CreateContactWithDuplicateEmail() {
		Account acc = TestDataFactory.createAccount(true);
		Contact con = new Contact(FirstName='test', LastName='tester', Email='test@mail.com',Makler_E_Mail__c='test@mail.com',AccountId=acc.Id,MailingStreet='teststr 123',MailingPostalCode='12345');
		insert con;
		Realty_User__c reu = new Realty_User__c(Password__c='test123',Name='test tester',Email__c='test@mail.com',Login_Email__c='test@mail.com',Contact__c=con.Id);
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
		Contact con = new Contact(FirstName='test', LastName='tester', Email='test@mail.com',Makler_E_Mail__c='test@mail.com',AccountId=acc.Id,MailingStreet='teststr 123',MailingPostalCode='12345',Kundenschutz__c=DateTime.now().addHours(24));
		insert con;
		Realty_User__c reu = new Realty_User__c(Password__c='test123',Name='test tester',Email__c='test@mail.com',Login_Email__c='test@mail.com',Contact__c=con.Id);
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