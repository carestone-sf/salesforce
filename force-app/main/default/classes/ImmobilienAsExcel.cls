global class ImmobilienAsExcel implements Schedulable {
	public List<Property__c> properties {get;set;}
	public List<Contact> contacts {get;set;}
	public String subject { get; set; }
	public String body { get; set; }

	global void execute(SchedulableContext sc) {
		ImmobilienAsExcelBatch iaeb = new ImmobilienAsExcelBatch();
		Database.executebatch(iaeb, 800);
	}

	public void sendexcelfile(List<Contact> contacts){
		// Liste aller Objekte mit Apartments
		properties = [SELECT Name, Property__c, (SELECT Name, Area_sq_m__c, Monthly_rent_sq_m__c,Zimmerart__c, Monthly_rent__c, Purchase_Price__c, Status__c FROM Appartments__r WHERE Status__c='Available' OR Status__c = 'Reservierung angefragt' OR Status__c = 'Reservierungsvorbereitung' OR Status__c = 'Reserved' ORDER BY Name) FROM Property__c WHERE (Is_Public__c = true AND Status_Reason__c = 'Aktiv') ORDER BY Name];

		// Die Header Columns der CSV Datei
		string header ='Objekt;Objektart;Apartment;Größe m²;Zimmerart;Miete / m²;Miete / Monat;Kaufpreis \n';//;Status
		String finalstr = header;

		PageReference pdf = Page.ImmobilienAsExcel;

		// Blob und E-Mail Anhang aus dem String generieren
		Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
		attach.ContentType = 'application/pdf';
		Blob body;
		try {
			body = pdf.getContentAsPDF();
		} catch(Exception e) {
			body = blob.valueOf('Ein Fehler ist aufgetreten');
		}
		// Dateiname der CSV
		String fileName = 'Carestone Objekte ' + String.valueOf(Date.today().format()) + '.pdf';
		attach.setFileName(fileName);
		attach.setInline(false);
		attach.Body = body;

		Id templateId = [select id, name from EmailTemplate where developername = 'Excel_Objekte'].id;
		Set<OrgWideEmailAddress> oweas = new Set<OrgWideEmailAddress>([select Id, DisplayName from OrgWideEmailAddress]);
		Map<String, Id> oweaStringToId = new Map<String, Id>();
		for(OrgWideEmailAddress owea:oweas) {
			oweaStringToId.put(owea.DisplayName, owea.Id);
		}
		// Contact con = [SELECT Id FROM Contact WHERE Email = 'f.witte@wirtschaftshaus.de' LIMIT 1];
		Messaging.Email[] messages = new Messaging.Email[0];
		Set<String> mails = new Set<String>();
		for(Contact con:contacts) {
			if(!mails.contains(con.Email)) {
				// SingleEmailMessage erstellen
				Messaging.singleEmailMessage Emailwithattch = new Messaging.singleEmailMessage();
				Emailwithattch.setTemplateId(templateId);
				Emailwithattch.setTargetObjectId(con.Id);
				if ( oweas.size() > 0 ) {
					if(con.Account.Maklerbetreuer_Wirtschaftshaus_2__c != null && oweaStringToId.containsKey(con.Account.Maklerbetreuer_Wirtschaftshaus_2__r.Name) && con.Account.Maklerbetreuer_Wirtschaftshaus_2__r.Name != 'Mirco Buchholz') {
						Emailwithattch.setOrgWideEmailAddressId(oweaStringToId.get(con.Account.Maklerbetreuer_Wirtschaftshaus_2__r.Name));
					} else {
						Emailwithattch.setOrgWideEmailAddressId(oweaStringToId.get('Carestone Service'));
					}
				}
				Emailwithattch.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
				// Sends the email
				messages.add(Emailwithattch);
				mails.add(con.Email);
			}
		}

		Messaging.SendEmailResult [] r = Messaging.sendEmail(messages, false);
	}
}