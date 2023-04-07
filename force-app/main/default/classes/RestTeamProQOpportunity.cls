@RestResource(urlMapping='/teamproq/opportunity')
global without sharing class RestTeamProQOpportunity {
    
    @HttpPost
    global static RestTeamProQOpportunityResponse createOpportunity(RestTeamProQOpportunityRequest data) {
        RestRequest restRequest = RestContext.request;
        RestResponse restResponse = RestContext.response;

        // Account id empty error
        RestTeamProQOpportunityResponse res = new RestTeamProQOpportunityResponse();
        if(data.accountId == null) {
            res.success = false;
            RestTeamProQOpportunityError teamProQError = new RestTeamProQOpportunityError();
            teamProQError.message = 'Die "accountId" darf nicht leer sein.';
            teamProQError.code = 'AccountIdEmpty';
            res.errors.add(teamProQError);
            return res;
        }

        // No Accounts found error
        if([SELECT Id FROM Account WHERE Id = :data.accountId].size() == 0) {
            res.success = false;
            RestTeamProQOpportunityError teamProQError = new RestTeamProQOpportunityError();
            teamProQError.message = 'Zur "accountId" wurde kein Account im System gefunden.';
            teamProQError.code = 'AccountNotFound';
            res.errors.add(teamProQError);
            return res;
        }

        // First Buyer empty error
        if(data.firstBuyer == null) {
            res.success = false;
            RestTeamProQOpportunityError teamProQError = new RestTeamProQOpportunityError();
            teamProQError.message = 'Der Wert "firstBuyer" darf nicht leer sein.';
            teamProQError.code = 'FirstBuyerEmpty';
            res.errors.add(teamProQError);
            return res;
        }

        // Property not found error
        if([SELECT Id FROM Property__c WHERE TeamProQId__c = :data.propertyExternalId].size() == 0) {
            res.success = false;
            RestTeamProQOpportunityError teamProQError = new RestTeamProQOpportunityError();
            teamProQError.message = 'Zur "propertyId" wurde keine Immobilie im System gefunden.';
            teamProQError.code = 'PropertyNotFound';
            res.errors.add(teamProQError);
            return res;
        }

        // Apartment not found error
        if([SELECT Id FROM Appartment__c WHERE TeamProQId__c = :data.apartmentExternalId].size() == 0) {
            res.success = false;
            RestTeamProQOpportunityError teamProQError = new RestTeamProQOpportunityError();
            teamProQError.message = 'Zur "apartmentId" wurde kein Apartment im System gefunden.';
            teamProQError.code = 'ApartmentNotFound';
            res.errors.add(teamProQError);
            return res;
        }
        
        // Get information from custom labels
        // A dummy first buyer is being used if we can't create the contact automatically
        Id dummyFirstBuyerId = System.Label.TeamProQDummyFirstBuyerId;
        Id dummyBrokerId = System.Label.TeamProQDummyBrokerId;
        String onlineReservationStageName = System.Label.OnlineReservationStageName;

        // Query or if not found try to insert the contact
        // If duplicate rules deny the creation, the buyer will be null and thus the dummy buyer used
        Savepoint sp = Database.setSavePoint();
        Contact firstBuyer = getOrInsertContact(data.firstBuyer, data.accountId);
        Contact secondBuyer;
        if(data.secondBuyer != null) {
            secondBuyer = getOrInsertContact(data.secondBuyer, data.accountId);
        }

        List<Contact> makler = [SELECT Id FROM Contact WHERE FirstName = :data.broker.FirstName AND LastName = :data.broker.LastName AND AccountId = :data.accountId];

        // Create the opportunity with data from the request, but also default values 
        Opportunity opp = new Opportunity();
        Property__c propertyReference = new Property__c(
            TeamProQId__c=data.propertyExternalId); 
        opp.Immobilie__r = propertyReference;               

        Appartment__c apartmentReference = new Appartment__c(
            TeamProQId__c=data.apartmentExternalId); 
        opp.Appartement__r = apartmentReference;
        if(firstBuyer != null) {
            opp.Potenzieller_Kunde__c = firstBuyer.Id;
        } else {
            opp.Potenzieller_Kunde__c = dummyFirstBuyerId;
        }
        if(secondBuyer != null) {
            opp.Kunde2__c = secondBuyer.Id;
        }
        opp.AccountId = data.accountId;
        if(makler.size() == 1) {
            opp.Makler__c = makler[0].Id;
            opp.Immobilienberater__c = makler[0].Id;
        } else {
            opp.Makler__c = dummyBrokerId;
            opp.Immobilienberater__c = dummyBrokerId;
        }
        opp.StageName = onlineReservationStageName;
        opp.CloseDate = Date.today().addMonths(3);
        opp.SourceCreation__c = 'TeamProQ';
        opp.KfwWunsch__c = 'Kein KfW';

        // Fill in text area fields so that information can be checked 
        // or contacts can be created manually 
        opp.FirstBuyerInformation__c = getContactInformationString(data.firstBuyer);
        if(data.secondBuyer != null) {
            opp.SecondBuyerInformation__c = getContactInformationString(data.secondBuyer);
        }
        opp.BrokerInformation__c = getContactInformationString(data.broker);
        Database.SaveResult oppSaveResult = Database.insert(opp, false);
        
        if(oppSaveResult.isSuccess() == false) {
            Database.rollBack(sp);
        }

        // Return success true / false and if applicable error messages of the opp insert
        res.success = oppSaveResult.isSuccess();
        if(oppSaveResult.getErrors().size() > 0) {
            res.errors = new List<RestTeamProQOpportunityError>();
        }
        for(Database.Error error:oppSaveResult.getErrors()) {
            RestTeamProQOpportunityError teamProQError = new RestTeamProQOpportunityError();
            teamProQError.code = 'OpportunityNotCreated';
            teamProQError.message = error.getMessage();
            res.errors.add(teamProQError);
        }
        return res;
    }

    /**
     * Queries a contact or tries to inserts it if none is found
     */
    public static Contact getOrInsertContact(Contact buyer, Id accountId) {
        // Searches within the hierarchy of the parentId, as the contact might already exists somewhere in MLP
        List<Contact> buyerContacts = [SELECT Id FROM Contact WHERE LastName = :buyer.LastName AND FirstName = :buyer.FirstName AND AccountId = :accountId];
        
        if(buyerContacts.size() == 1) {
            buyer = buyerContacts[0];
        }

        Database.SaveResult buyerSaveResult;
        if(buyer.Id == null) {
            buyer.AccountId = accountId;
            buyer.Gesch_ftsbeziehung__c = 'Interessent';
            buyerSaveResult = Database.insert(buyer, false);
        }
        
        if((buyerSaveResult != null && buyerSaveResult.isSuccess() == false) || buyer == null) {
            return null;
        } else {
            return buyer;
        }
    }

    /**
     * Returns a string containing the contact information on new lines
     */
    public static String getContactInformationString(Contact con) {
        if(con == null) {
            return '';
        }
        String contactInformation = '';
        if(con.FirstName != null) {
            contactInformation += 'Vorname: ' + con.FirstName + '\r\n';
        }
        if(con.LastName != null) {
            contactInformation += 'Nachname: ' + con.LastName + '\r\n';
        }
        if(con.MailingStreet != null) {
            contactInformation += 'Straße: ' + con.MailingStreet + '\r\n';
        }
        if(con.MailingPostalCode != null) {
            contactInformation += 'PLZ: ' + con.MailingPostalCode + '\r\n';
        }
        if(con.MailingCity != null) {
            contactInformation += 'Stadt: ' + con.MailingCity + '\r\n';
        }
        if(con.Phone != null) {
            contactInformation += 'Telefon: ' + con.Phone + '\r\n';
        }
        if(con.Email != null) {
            contactInformation += 'E-Mail: ' + con.Email + '\r\n';
        }
        if(con.Birthdate != null) {
            contactInformation += 'Geburtsdatum: ' + con.Birthdate + '\r\n';
        }
        return contactInformation;
    }

    global class RestTeamProQOpportunityRequest {
        global String propertyExternalId;
        global String apartmentExternalId;
        global Id accountId;
        global Contact firstBuyer;
        global Contact secondBuyer;
        global Contact broker;
    }

    global class RestTeamProQOpportunityResponse {
        global Boolean success;
        global List<RestTeamProQOpportunityError> errors;

        global RestTeamProQOpportunityResponse() {
            errors = new List<RestTeamProQOpportunityError>();
        }
    }

    global class RestTeamProQOpportunityError {
        global String message;
        global String code;
    }
}