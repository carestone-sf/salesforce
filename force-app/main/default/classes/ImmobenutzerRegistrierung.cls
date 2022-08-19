global class ImmobenutzerRegistrierung implements Messaging.InboundEmailHandler {
	
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,
																Messaging.InboundEnvelope env) {
 
		// Create an InboundEmailResult object for returning the result of the
		// Apex Email Service
		
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
		
		String[] emailBody = email.plainTextBody.split('\n');

		String type = emailBody[0];

		if(type == 'register')
		{
			// Generate Random Password for User
			Integer len = 8;
			Blob blobKey = Crypto.generateAesKey(128);
			String key = EncodingUtil.convertToHex(blobKey);
			String pwd = key.substring(0,len);

			Realty_User__c newImmobenutzer = new Realty_User__c();

			newImmobenutzer.Name = emailBody[1];
			newImmobenutzer.Email__c = emailBody[2];
			newImmobenutzer.Login_Email__c = emailBody[2];
			newImmobenutzer.Telefonnummer__c = emailBody[3];
			newImmobenutzer.Herkunft__c =  emailBody[4];
			newImmobenutzer.Type__c = 'Normal Agency';
			newImmobenutzer.Password__c = pwd;
			newImmobenutzer.Active__c = false;
			newImmobenutzer.Datenschutzerkl_rung_angenommen__c = TRUE;
			newImmobenutzer.AGBs_angenommen__c = TRUE;
			newImmobenutzer.lb_AGB_angenommen__c = TRUE;

			insert newImmobenutzer;
		}
		else if(type == 'password')
		{
			String mail = emailBody[1];
			try
			{
				Realty_User__c immoBenutzer = [SELECT Passwort_vergessen__c FROM Realty_User__c WHERE Login_Email__c =: mail];
				immoBenutzer.Passwort_vergessen__c = true;

				update immoBenutzer;
			}
			catch(Exception e){}
		}
		
		result.success = true;
		return result;
	}
}