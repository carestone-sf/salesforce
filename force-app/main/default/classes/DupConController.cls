public with sharing class DupConController {

    private ApexPages.StandardController StandardController;
    Integer offset = 0;
    Integer size = 0;

    public DupConController(ApexPages.StandardController stdController) {
        this.StandardController = stdController;
    }

    private Contact displayCon = [SELECT Id, Position_Abteilung__c, AccountID, Account.Name, OwnerId, LastName, FirstName, Phone, MobilePhone, Firma__c, MailingStreet, MailingPostalCode, MailingCity, Meeting__c, Datum_Meeting__c, LeadSource, Email, Birthdate, Title, Salutation, Art_des_Termins__c, Makler_E_Mail__c, Kundenschutz__c, E_Mail_Portalnutzer__c, Gesch_ftsbeziehung__c FROM Contact
        WHERE Id = : ApexPages.currentPage().getParameters().get('id')
    ];

    private ID uid = UserInfo.getUserId();

    public String contIdChosen {
        get;
        set;
    }

    // The List for the possible duplicate contacts
    public List < Contact > setCon {
        get {
            if (setCon == null) {
                setCon = [SELECT id, LastName, Maklerschutz_besteht__c, Gesch_ftsbeziehung__c, Account.Name, FirstName, phone, Firma__c, MailingStreet, MailingPostalCode, MailingCity, Email, Kundenschutz__c, Dauerhaft_gesch_tzt__c FROM Contact Where LastName = : displayCon.LastName AND id != : displayCon.id];
            }
            return setCon;
        }
        set;
    }

    // Make displayCon availbe for visualforce
    public Contact getFirst() {
        return displayCon;
    }

    // Make the duplicate contact list availble for visualforce
    public List < Contact > getPossibleDups() {
        return setCon;
    }

    public List < Lead > getPossibleDupLeads() {
        return [SELECT CreatedDate, FirstName, LastName, bergeordneter_Account__c, Street, PostalCode, City, Email, Phone FROM Lead Where LastName = : displayCon.LastName];
    }

    public PageReference mergeCont() {
        mergeContacts(contIdChosen);
        return redUrl();
    }

    // Approve the contact (used by commandButton on the page)
    public PageReference approve() {
        processApproval('approve', displayCon.Id);
        return redurl();
    }

    public PageReference reject() {
        try {
            processApproval('dismiss', displayCon.Id);
            delete displayCon;
        } catch(Exception ex) {
            System.debug(ex.getMessage());
        }
        return redurl();
    }

    public PageReference redurl() {
        try {
            ProcessInstanceWorkitem process = [SELECT p.ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem p WHERE p.ProcessInstance.Status = 'Pending'
                AND p.ProcessInstance.TargetObjectId != : ApexPages.currentPage().getParameters().get('id') AND p.ProcessInstance.TargetObject.Type = 'Contact'
                AND ActorId = : uid LIMIT 1
            ];
            Id tid = process.ProcessInstance.TargetObjectId;
            return new PageReference(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/dupcon?id=' + tid);
        } catch (Exception e) {
            return new PageReference(URL.getSalesforceBaseUrl().toExternalForm());
        }

    }

    public void mergeContacts(String id) {
        Contact conToMerge = [SELECT OwnerID, AccountID, Makler_E_Mail__c, Meeting__c, Datum_Meeting__c, LeadSource, Email, Birthdate, Title, Salutation, Art_des_Termins__c, Position_Abteilung__c, Phone, MobilePhone, Kundenschutz__c, Kunden_Maklerschutz__c, MailingStreet, MailingPostalCode, MailingCity, OtherStreet, OtherPostalCode, OtherCity, E_Mail_Portalnutzer__c, Gesch_ftsbeziehung__c FROM Contact WHERE id = : id];
        Database.DMLOptions dml = new Database.DMLOptions();
    dml.DuplicateRuleHeader.AllowSave = true;
        if(displayCon.Phone != null)
        	conToMerge.Phone = displayCon.Phone;
        conToMerge.E_Mail_Portalnutzer__c = displayCon.E_Mail_Portalnutzer__c;
        if(displayCon.MobilePhone != null)
        	conToMerge.MobilePhone = displayCon.MobilePhone;
        conToMerge.Position_Abteilung__c = displayCon.Position_Abteilung__c;
        conToMerge.Art_des_Termins__c = displayCon.Art_des_Termins__c;
        if(displayCon.Salutation != null)
        	conToMerge.Salutation = displayCon.Salutation;
        if(displayCon.Title != null)
        	conToMerge.Title = displayCon.Title;
        if(displayCon.Birthdate != null)
        	conToMerge.Birthdate = displayCon.Birthdate;
        if(displayCon.Email != null)
        	conToMerge.Email = displayCon.Email;
        conToMerge.LeadSource = displayCon.LeadSource;
        conToMerge.Datum_Meeting__c = displayCon.Datum_Meeting__c;
        conToMerge.Meeting__c = displayCon.Meeting__c;
        conToMerge.In_GenehmigungsProzess__c = true;
        try {
            conToMerge.MailingStreet = displayCon.MailingStreet;
            conToMerge.OtherStreet = displayCon.MailingStreet;
            conToMerge.MailingPostalCode = displayCon.MailingPostalCode;
            conToMerge.OtherPostalCode = displayCon.MailingPostalCode;
            conToMerge.MailingCity = displayCon.MailingCity;
            conToMerge.OtherCity = displayCon.MailingCity;
        } catch (Exception e) {}
        String accId = displayCon.AccountID;
        conToMerge.AccountId = accId;
        Database.update(conToMerge, dml);
         try {
        	processApproval('approve', conToMerge.Id);
        } catch(Exception e) {}
        //conToMerge.accountId = accId;
        //Database.SaveResult sr = Database.update(conToMerge, dml);
        //if(!sr.isSuccess())
        //System.debug(sr.getErrors());
        System.debug('AccId After: ' + conToMerge.AccountId);
        Database.delete(displayCon);

    }

    // Processing the approval. Enter "approve" or "dismiss"
    public void processApproval(String val, String id) {
        Contact con = [SELECT Kundenschutz__c, Kunden_Maklerschutz__c, Gesch_ftsbeziehung__c, AccountId FROM Contact WHERE id = : id];
        Account acc = [SELECT Maklerschutz_besteht__c, Maklerschutz_bis__c, (SELECT ID FROM Contacts) FROM Account WHERE Id =: con.AccountId];
        Approval.ProcessWorkitemRequest req2 =
            new Approval.ProcessWorkitemRequest();
        if (val == 'approve') {
        	con.In_GenehmigungsProzess__c = false;
           if (con.Gesch_ftsbeziehung__c.contains('Interessent')) {

        } else if(acc.Contacts.size() == 1) {
            acc.Maklerschutz_bis__c = datetime.now().addMonths(3);
        }
        if(con.Kunden_Maklerschutz__c != true && con.Gesch_ftsbeziehung__c.contains('Interessent')) {
        	con.Kunden_Maklerschutz__c = true;
        } else if(acc.Maklerschutz_besteht__c != true && acc.Contacts.size() == 1) {
        	acc.Maklerschutz_besteht__c = true;
        }
        Database.DMLOptions dml = new Database.DMLOptions();
    dml.DuplicateRuleHeader.AllowSave = true;
            Database.update(acc, dml);
            Database.update(con, dml);
            req2.setComments('Keine Duplikate entdeckt.');
            req2.setAction('Approve');
        } else if (val == 'dismiss') {
            req2.setComments('Duplikat entdeckt.');
            req2.setAction('Reject');
        }
        Id workitemid = getWorkItemId(displayCon.id);
        req2.setWorkitemId(workitemid);
        Approval.process(req2);
    }

    // Get the WorkItemId for the process of the contact
    public Id getWorkItemId(Id targetObjectId) {
        Id retVal = null;
        for (ProcessInstanceWorkitem workItem: [Select p.Id from ProcessInstanceWorkitem p
                where p.ProcessInstance.TargetObjectId = : targetObjectId
            ]) {
            retVal = workItem.Id;
        }
        return retVal;
    }

}