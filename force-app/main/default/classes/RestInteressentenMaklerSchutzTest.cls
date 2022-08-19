@isTest
public class
RestInteressentenMaklerSchutzTest {
	@isTest public static void TestDuplicate() {
		Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;

		MaklerPortalHelper mh = new MaklerPortalHelper();
		Contact con = new Contact();
		con.firstName = 'Frederik';
		con.lastName = 'Witte';
		con.MailingStreet = 'Klostergang 2';
		con.MailingCity = 'Hannover';
		con.MailingPostalCode = '31535';
		Database.insert(con, dml);
		RestInteressentenMaklerSchutz.Userdata userdata = new RestInteressentenMaklerSchutz.Userdata();

		userdata.istMaklerschutz = false;
		userdata.anrede = 'Herr';
		userdata.firstName = 'Frederik';
		userdata.lastName = 'Witte';
		userdata.mail = 'mail@witte.de';
		userdata.loginMail = 'test@mail.com';
		userdata.relationship = 'Interessent';
		userdata.meeting.type = 'Termin/Beratung';
		userdata.meeting.contactType = 'Telefonisch';
		userdata.meeting.cDate = date.parse('03.03.2017');
		userdata.mobile = '+49 173 3343434';
		userdata.phone = '+49 5123 / 232323';
		userdata.street = 'Klostergang 2';
		userdata.zip = '31535';
		userdata.city = 'Hannover';
		userdata.bic = 'SPKHDE2HXXX';
		userdata.iban = 'DE123124123';
		userdata.rechtsform = 'GbR';
		userdata.mwst = 0.3;

		Test.startTest();
		RestInteressentenMaklerSchutz.doPost(userdata);
		Test.stopTest();
	}

	@isTest public static void TestPossibleDuplicate() {
		Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;

		MaklerPortalHelper mh = new MaklerPortalHelper();
		Contact con = new Contact();
		con.firstName = 'Fred';
		con.lastName = 'Witte';
		con.MailingStreet = 'Klostergang 2';
		con.MailingCity = 'Hannover';
		con.MailingPostalCode = '31535';
		con.Kundenschutz__c = Date.parse('01.01.2017');
		Database.insert(con, dml);
		RestInteressentenMaklerSchutz.Userdata userdata = new RestInteressentenMaklerSchutz.Userdata();

		userdata.istMaklerschutz = false;
		userdata.anrede = 'Herr';
		userdata.firstName = 'Frederik';
		userdata.lastName = 'Witte';
		userdata.mail = 'mail@witte.de';
		userdata.loginMail = 'test@mail.com';
		userdata.relationship = 'Interessent';
		userdata.meeting.type = 'Termin/Beratung';
		userdata.meeting.contactType = 'Telefonisch';
		userdata.meeting.cDate = date.parse('03.03.2017');
		userdata.mobile = '+49 173 3343434';
		userdata.phone = '+49 5123 / 232323';
		userdata.street = 'Klostergang 22';
		userdata.zip = '31535';
		userdata.city = 'Hannover';
		userdata.bic = 'SPKHDE2HXXX';
		userdata.iban = 'DE123124123';
		userdata.rechtsform = 'GbR';
		userdata.mwst = 0.3;

		Test.startTest();
		RestInteressentenMaklerSchutz.doPost(userdata);
		Test.stopTest();
	}

	@isTest public static void TestNoDuplicate() {
		Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;

		MaklerPortalHelper mh = new MaklerPortalHelper();
		RestInteressentenMaklerSchutz.Userdata userdata = new RestInteressentenMaklerSchutz.Userdata();

		userdata.istMaklerschutz = false;
		userdata.anrede = 'Herr';
		userdata.firstName = 'Frederik';
		userdata.lastName = 'Witte';
		userdata.mail = 'mail@witte.de';
		userdata.loginMail = 'test@mail.com';
		userdata.relationship = 'Interessent';
		userdata.meeting.type = 'Termin/Beratung';
		userdata.meeting.contactType = 'Telefonisch';
		userdata.meeting.cDate = date.parse('03.03.2017');
		userdata.mobile = '+49 173 3343434';
		userdata.phone = '+49 5123 / 232323';
		userdata.street = 'Klostergang 2';
		userdata.zip = '31535';
		userdata.city = 'Hannover';
		userdata.bic = 'SPKHDE2HXXX';
		userdata.iban = 'DE123124123';
		userdata.rechtsform = 'GbR';
		userdata.mwst = 0.3;

		Test.startTest();
		RestInteressentenMaklerSchutz.doPost(userdata);
		Test.stopTest();
	}

	@isTest public static void TestMaklerDuplicate() {
		Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;

		MaklerPortalHelper mh = new MaklerPortalHelper();
		RestInteressentenMaklerSchutz.Userdata userdata = new RestInteressentenMaklerSchutz.Userdata();

		userdata.istMaklerschutz = true;
		userdata.anrede = 'Herr';
		userdata.firma = 'Test Account';
		userdata.hgb = false;
		userdata.firstName = 'Frederik';
		userdata.lastName = 'Witte';
		userdata.mail = 'tesaat@mahil.com';
		userdata.loginMail = 'test@mail.com';
		userdata.relationship = 'Interessent';
		userdata.meeting.type = 'Termin/Beratung';
		userdata.meeting.contactType = 'Telefonisch';
		userdata.meeting.cDate = date.parse('03.03.2017');
		userdata.mobile = '+49 173 3343434';
		userdata.phone = '+49 5123 / 232323';
		userdata.street = 'Klostergang 2';
		userdata.zip = '31535';
		userdata.city = 'Hannover';
		userdata.bic = 'SPKHDE2HXXX';
		userdata.iban = 'DE123124123';
		userdata.rechtsform = 'GbR';
		userdata.mwst = 0.3;

		Test.startTest();
		RestInteressentenMaklerSchutz.doPost(userdata);
		Test.stopTest();
	}
}