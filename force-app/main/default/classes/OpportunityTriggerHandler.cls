public without sharing class OpportunityTriggerHandler implements ITrigger {

    private static final String ZAHLUNGSERINNERUNG_APPROVAL_PROCESS_NAME = 'Zahlungserinnerung';
    private static final String ZAHLUNGSEINGANG_APPROVAL_PROCESS_NAME = 'Zahlungseingang';
    private static final String FIBU_MAILBOX = 'MaBV-Rechnungen@carestone.com';
    private static final String OPPORTUNITY_STAGE_RESERVIERUNG_ANGEFRAGT = 'Reservierung angefragt';
    private static final String OPPORTUNITY_STAGE_RESERVIERT = 'Reserviert';
    private static final String CAN_CHANGE_STAGE_STATUS_PERMISSION_NAME='Can_change_stage_status';
    private static string getUserId{
        get{
            return System.UserInfo.getUserId();
        }
        set;
    }
    private static List<PermissionSetAssignment> getPermissionSetAssignments{
        get{
            if(getPermissionSetAssignments==null){
                getpermissionSetAssignments=[SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :getUserId And PermissionSet.Name=:CAN_CHANGE_STAGE_STATUS_PERMISSION_NAME];
            }
            return getPermissionSetAssignments;
        }
        set;
    }

    Id orgWideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'service@carestone.com' LIMIT 1].Id;
    
    @TestVisible
    private static final Integer DEFAULT_RESERVATION_DURATION = 14;

    Set<Id> propertyIdsToRecalculateAggregatedProvision = new Set<Id>();
    Set<String> lostOpportunityStages = new Set<String>();
    Map<Id,SObject> updateMap = new Map<Id,SObject>();
    List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
    List<CreateVisualforceFileQueueable.FileCreationRequest> fileCreationRequests = new List<CreateVisualforceFileQueueable.FileCreationRequest>();
    List<FileCreationRequest> batchFileCreationRequests = new List<FileCreationRequest>();
    

    Map<Id,Appartment__c> mapApartmentsById = new Map<Id,Appartment__c>();
    Map<Id,Contact> mapRelatedContactsByIds = new Map<Id,Contact>();
    Map<Id,Account> mapAccountsByIds = new Map<Id,Account>();
    Map<Id,Property__c> mapImmobilienByIds = new Map<Id,Property__c>();    

    Map<Id,Map<Id,Provisionsverhandlung__c>> mapProvisionsverhandlungByImmoIdByAccountId = new Map<Id,Map<Id,Provisionsverhandlung__c>>();
    Map<Id,List<Provision__c>> mapProvisionenByOpportunityId = new Map<Id,List<Provision__c>>();

    Id contentVersionRecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('VKC').getRecordTypeId();

    public OpportunityTriggerHandler() {
        if(Trigger.isInsert || Trigger.isUpdate) {
            collectIdsOfRelatedRecords();
            
            getLostOpportunityStages();
            getProvisionsverhandlungen();
            getApartments();
            getRelatedContacts();
            getAccounts();
            getImmobilien();
        }
    }

    public void bulkBefore() {
        
    }
    
    public void bulkAfter() {
        if(Trigger.isInsert || Trigger.isUpdate) {
            getLostOpportunityStages();
        }

        if(Trigger.isUpdate) {
            getProvisionen();
        }
    }

    public void beforeInsert(SObject so) {
        Opportunity opp = (Opportunity) so;
        setProvisionOnInsert(opp);
        setStageOnInsert(opp);

        setOpportunityFields(opp, null);
    }

    public void beforeUpdate(SObject oldSo, SObject so) {
        Opportunity opp = (Opportunity) so;
        Opportunity oldOpp = (Opportunity) oldSo;
        
        /*
        if(stageOrApartmentHasChanged(opp)) {
            validateApartmentCanOnlyBeReservedOnce(opp);
        }
        */
        setOpportunityFields(opp, oldOpp);
    }

    public void beforeDelete(SObject so) {

    }

    public void afterInsert(SObject so) {
        Opportunity opp = (Opportunity) so;

        setFieldsOnRelatedObjects(opp, null);
    }

    public void afterUpdate(SObject oldSo, SObject so) {
        Opportunity opp = (Opportunity) so;
        Opportunity oldOpp = (Opportunity) oldSo;

        if(opp.Kaufpreis_bezahlt__c && !oldOpp.Kaufpreis_bezahlt__c) {
            createApprovalRequestIfKaufpreisBezahlt(opp);
        }

        if(opp.MahnungZurGenehmigungSenden__c && !oldOpp.MahnungZurGenehmigungSenden__c) {
            createApprovalRequestForPaymentReminder(opp);
        }

        if(opp.MahnungGenerieren__c && !oldOpp.MahnungGenerieren__c) {
            FileCreationRequest fcr = new FileCreationRequest(opp.Id, Page.BarzahlungMahnung, 'Zahlungserinnerung: ' + mapImmobilienByIds.get(opp.Immobilie__c).Name + ' / ' + mapApartmentsById.get(opp.Appartement__c).Name, 'Zahlungserinnerung', contentVersionRecordTypeId);
            fcr.setSendEmailRequests(new List<FileCreationRequest.SendEmailRequest> {new FileCreationRequest.SendEmailRequest(
                opp.Potenzieller_Kunde__c, false, 'VKC_Zahlungserinnerung', orgWideEmailAddressId, new List<String> {FIBU_MAILBOX}
            )});
            batchFileCreationRequests.add(fcr);
        }

        if(opp.ZahlungseingangApproved__c && !oldOpp.ZahlungseingangApproved__c) {
            FileCreationRequest fcr = new FileCreationRequest(opp.Id, Page.KaufpreiseingangBestaetigung, 'Notar: Bestätigung des Kaufpreiseingangs für ' + opp.Name, 'Notar-Anschreiben', contentVersionRecordTypeId);
            fcr.setSendEmailRequests(new List<FileCreationRequest.SendEmailRequest> {new FileCreationRequest.SendEmailRequest(
                opp.Potenzieller_Kunde__c, false, 'ZahlungseingangPDFAngelegt', orgWideEmailAddressId, new List<String> {FIBU_MAILBOX}
            )});
            batchFileCreationRequests.add(fcr);
        }
        
        if(opp.WertKumulierteProvisionExtern__c != null && (!oldOpp.IsWon && opp.IsWon)) {
            propertyIdsToRecalculateAggregatedProvision.add(opp.Immobilie__c);
        }

        setFieldsOnRelatedObjects(opp, oldOpp);
    }

    public void afterDelete(SObject so) {

    }

    public void andFinally() {
          if(!propertyIdsToRecalculateAggregatedProvision.isEmpty()) {
            List<Property__c> properties = new List<Property__c>();
            for (AggregateResult agRes : [SELECT SUM(WertKumulierteProvisionExtern__c) provExtern, Immobilie__c FROM Opportunity WHERE Immobilie__c IN :propertyIdsToRecalculateAggregatedProvision AND IsWon = true GROUP BY Immobilie__c]) {
                properties.add(new Property__c(Id = (Id) agRes.get('Immobilie__c'), SummeWertKumulierteProvisionExtern__c = (Double) agRes.get('provExtern')));
            }
            update properties;
        }
        if(!updateMap.isEmpty()) {
            List<SObject> updateList = updateMap.values();
            updateList.sort();
            update updateList;
        }
        if(!batchFileCreationRequests.isEmpty()) {
            Database.executeBatch(new BatchVisualforceFileCreation(batchFileCreationRequests), 20);
        }
        if(!approvalRequests.isEmpty()) {
            Approval.process(approvalRequests);
        }
    }

    /**
     * 
     * Sets the provision if there is a matching Provisionsverhandlung__c record
     * 
     * @param opp Inserted Opportunity
     */
    private void setProvisionOnInsert(Opportunity opp) {
        Id accId = opp.Abrechnung_ber__c != null ? opp.AccountIdAbrechnungUeber__c : opp.AccountId;
        if(mapProvisionsverhandlungByImmoIdByAccountId.containsKey(accId) && mapProvisionsverhandlungByImmoIdByAccountId.get(accId).containsKey(opp.Immobilie__c)) {
            Provisionsverhandlung__c proviV = mapProvisionsverhandlungByImmoIdByAccountId.get(accId).get(opp.Immobilie__c);
            opp.Grundprovision_Provisionsverhandlung__c = proviV.Grundprovision__c; 
            
            if(opp.Abrechnung_ber__c != null && opp.Makler__c == opp.Immobilienberater__c) {
                opp.Verkaufsprovision_Provisionsverhandlung__c = proviV.Verkaufsprovision__c;
            }
        }

        if(opp.Verkaufsprovision_Provisionsverhandlung__c == null && !opp.ImmobilienberaterIstIntern__c) {
            if(mapProvisionsverhandlungByImmoIdByAccountId.containsKey(opp.AccountIdImmobilienberater__c) && mapProvisionsverhandlungByImmoIdByAccountId.get(opp.AccountIdImmobilienberater__c).containsKey(opp.Immobilie__c)) {
                opp.Verkaufsprovision_Provisionsverhandlung__c = mapProvisionsverhandlungByImmoIdByAccountId.get(opp.AccountIdImmobilienberater__c).get(opp.Immobilie__c).Verkaufsprovision__c;
            }
        }
    }

    /**
     * 
     * Sets the stage of the opp if certain criteria are fulfilled
     * 
     * @param opp Inserted Opportunity
     */
    private void setStageOnInsert(Opportunity opp) {
        if(opp.Appartement__c == null || opp.Immobilie__c == null) {
            opp.StageName = 'Beratung';
        } else if(!PermissionSetsHandler.hasPermissionSet()) {
            opp.StageName = 'Reservierungsvorbereitung';
        }
    }

    /**
     * Starts an approval process for the payment confirmation
     * 
     * @param opp Opportunity Record
    */
    private void createApprovalRequestIfKaufpreisBezahlt(Opportunity opp) {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Zur Genehmigung eingereicht');
        req.setObjectId(opp.id);
        req.setSubmitterId(System.Userinfo.getUserId());
        req.setProcessDefinitionNameOrId(ZAHLUNGSEINGANG_APPROVAL_PROCESS_NAME);
        approvalRequests.add(req);
    }

    /**
     * Starts an approval process for the payment reminder
     * 
     * @param opp Opportunity Record
    */
    private void createApprovalRequestForPaymentReminder(Opportunity opp) {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Zur Genehmigung eingereicht');
        req.setObjectId(opp.id);
        req.setSubmitterId(System.Userinfo.getUserId());
        req.setProcessDefinitionNameOrId(ZAHLUNGSERINNERUNG_APPROVAL_PROCESS_NAME);
        approvalRequests.add(req);
    }

    /*
    @TestVisible
    private static String APARTMENT_RESERVED_ERROR = 'Dieses Teilobjekt ist bereits für die VKC {0} reserviert.';
    
    public void validateApartmentCanOnlyBeReservedOnce(Opportunity opp) {
        if(mapApartmentsById.containsKey(opp.Appartement__c)) {
            Appartment__c apartment = mapApartmentsById.get(opp.Appartement__c);

            if(APARTMENT_STATUS_BY_OPPORTUNITY_STAGE.get(opp.StageName) != 'Available' && apartment.ReserviertFuer__c != null && apartment.ReserviertFuer__c != opp.Id) {
                opp.addError(APARTMENT_RESERVED_ERROR.replace('{0}', apartment.ReserviertFuer__r.Name));
            }
        }
    }
    */



    public void clearApartmentReservationInformation(Appartment__c apartment) {
        apartment.Customer__c = null;
        apartment.Makler__c = null;
        apartment.Beurkundung__c = null;
        apartment.MarkedForReservation__c = false;
        apartment.Kaufpreis_gezahlt_am__c = null;
        apartment.Notartermin__c = null;
        apartment.Finanzierung__c = null;
        apartment.Maklerbetreuer_WirtschaftsHaus_lookup__c = null;
        apartment.beurkundeter_Kaufpreis__c = null;
        apartment.Provisionsbasis__c = null;
        apartment.KaufpreisFaellig__c = false;
        apartment.Bezahlt__c = 0;
        apartment.ReserviertFuer__c = null;
    }

    public Boolean stageSetToReserved(Opportunity opp, Opportunity oldOpp) {
        // TODO: Refactor to custom permission
        if(UserInfo.getUserId() == '005b0000001V30P') {
            return false;
        }
        return opp.StageName == 'Reserviert' && (Trigger.isInsert || (Trigger.isUpdate && oldOpp != null && opp.StageName != oldOpp.StageName));
    }


    /**
     * Methods for before trigger
    */

    public void setOpportunityFields(Opportunity opp, Opportunity oldOpp) {
        if(stageSetToReserved(opp, oldOpp)) {
            setReservationDate(opp);
        }
        if(maklerSetOrChanged(opp, oldOpp)) {
            setMaklerFields(opp);
        }
        if(accountSetOrChanged(opp, oldOpp)) {
            setAccountFields(opp);
        }
        if(customerSetOrChanged(opp, oldOpp)) {
            constructNewName(opp);
        }
        if(customerWithCampaignSourceSetOrChanged(opp, oldOpp)) {
            setCampaignSource(opp);
        }
        if(immobilienberaterSetOrChanged(opp, oldOpp)) {
            setBeratertext(opp);
        }
        if(finanzierungSetOrChanged(opp, oldOpp)) {
            setProvisionFinanzierung(opp);
        }
        if(immobilieChanged(opp, oldOpp)) {
            setProjektbeauftragte(opp);
        }
        if(mahnungApprovalStarted(opp, oldOpp)) {
            trackMahnungStarted(opp);
        }
        if(mahnungCreated(opp, oldOpp)) {
            trackMahnungSent(opp);
        }
        if(opportunityWasLost(opp, oldOpp)) {
            clearNotartermin(opp);
        }

        if(Trigger.isInsert) {
            if(maklerprovisionEmpty(opp)) {
                setMaklerprovision(opp);
            }
            if(tipProvisionEmpty(opp)) {
                setTipProvision(opp);
            }
            if(overheadEmpty(opp)) {
                setOverhead(opp);
            }
            if(overheadReceiverEmpty(opp)) {
                setOverheadReceiver(opp);
            }
            if(tippgeberProvisionempfaengerEmpty(opp)) {
                setTippgeberProvisionempfaenger(opp);
            }
        }
    }

    public void setReservationDate(Opportunity opp) {
        opp.reserviert_bis__c = DateTimeHelper.checkAndSetDateTimeIfWeekend(System.today().addDays(DEFAULT_RESERVATION_DURATION));
    }

    public Boolean maklerSetOrChanged(Opportunity opp, Opportunity oldOpp) {
        return opp.Makler__c != null && (Trigger.isInsert || (Trigger.isUpdate && oldOpp != null && opp.Makler__c != oldOpp.Makler__c));
    }

    public void setMaklerFields(Opportunity opp) {
        Contact makler = mapRelatedContactsByIds.get(opp.Makler__c);
        opp.AccountId = makler.AccountId;
        opp.Makler_E_Mail__c = makler.Email;
        opp.OwnerId = makler.OwnerId;
    }

    public Boolean accountSetOrChanged(Opportunity opp, Opportunity oldOpp) {
        return opp.AccountId != null && (Trigger.isInsert || (oldOpp != null && opp.AccountId != oldOpp.AccountId));
    }

    public void setAccountFields(Opportunity opp) {
        Account acc = mapAccountsByIds.get(opp.AccountId);
        if(acc.Maklerbetreuer_Wirtschaftshaus_2__c != null) {
            opp.MaklerBetreuer_E_Mail__c = acc.Maklerbetreuer_Wirtschaftshaus_2__r.Email;
            opp.Maklerbetreuer_WirtschaftsHaus__c = acc.Maklerbetreuer_Wirtschaftshaus_2__c;
        }
    }

    public Boolean customerSetOrChanged(Opportunity opp, Opportunity oldOpp) {
        return opp.Potenzieller_Kunde__c != null && (Trigger.isInsert || (oldOpp != null && opp.Potenzieller_Kunde__c != oldOpp.Potenzieller_Kunde__c));
    }

    public void constructNewName(Opportunity opp) {
        Contact customer = mapRelatedContactsByIds.get(opp.Potenzieller_Kunde__c);
        opp.Name = (customer.LastName + ', ' + customer.FirstName + '-VKC');
    }

    public Boolean customerWithCampaignSourceSetOrChanged(Opportunity opp, Opportunity oldOpp) {
        return customerSetOrChanged(opp, oldOpp) && mapRelatedContactsByIds.get(opp.Potenzieller_Kunde__c).Kampagnenquelle__c != null;
    }

    public void setCampaignSource(Opportunity opp) {
        opp.CampaignId = mapRelatedContactsByIds.get(opp.Potenzieller_Kunde__c).Kampagnenquelle__c;
    }

    public Boolean immobilienberaterSetOrChanged(Opportunity opp, Opportunity oldOpp) {
        return opp.Immobilienberater__c != null && (Trigger.isInsert || (oldOpp != null && opp.Immobilienberater__c != oldOpp.Immobilienberater__c));
    }

    public void setBeratertext(Opportunity opp) {
        // this text field really just holds the Id, not sure why
        opp.Berater_text__c = opp.Immobilienberater__c;
    }

    public Boolean finanzierungSetOrChanged(Opportunity opp, Opportunity oldOpp) {
        return Trigger.isInsert || (oldOpp != null && opp.Finanzierung__c != oldOpp.Finanzierung__c);
    }

    public void setProvisionFinanzierung(Opportunity opp) {
        opp.Provision_Thoben__c = opp.Finanzierung__c == 'HypoCare' ? '1' : '0';
    }

    public Boolean immobilieChanged(Opportunity opp, Opportunity oldOpp) {
        return opp.Immobilie__c != null && (Trigger.isInsert || (oldOpp != null && opp.Immobilie__c != oldOpp.Immobilie__c));
    }

    public void setProjektbeauftragte(Opportunity opp) {
        Property__c immo = mapImmobilienByIds.get(opp.Immobilie__c);
        if(immo.Projektbeauftragte__c != null && immo.Projektbeauftragte__r.Contact__c != null) {
            opp.Projektbeauftragte__c = immo.Projektbeauftragte__r.Contact__c;
        }
    }

    public Boolean maklerprovisionEmpty(Opportunity opp) {
        return opp.AccountId != null && opp.Maklerprovision__c == null;
    }

    public Account getAbrechnungsaccount(Opportunity opp) {
        return opp.Abrechnung_ber__c != null ? mapAccountsByIds.get(opp.AccountIdAbrechnungUeber__c) : mapAccountsByIds.get(opp.AccountId);
    }

    public void setMaklerprovision(Opportunity opp) {
        opp.Maklerprovision__c = getAbrechnungsaccount(opp).WHS_Maklerprovision__c;
    }

    public Boolean overheadEmpty(Opportunity opp) {
        return opp.AccountId != null && opp.Overhead__c == null;
    }

    public void setOverhead(Opportunity opp) {
        opp.Overhead__c = getAbrechnungsaccount(opp).Overhead_Vereinbarung__c;
    }

    public Boolean tipProvisionEmpty(Opportunity opp) {
        return opp.AccountId != null && opp.Tippprovision__c == null;
    }

    public void setTipProvision(Opportunity opp) {
        Account acc = getAbrechnungsaccount(opp);
        opp.Tippprovision__c = acc.Tippgeber_in__c != null ? String.valueOf(Double.valueOf(acc.Tippgeber_in__c)) : 'Keine';
    }

    public Boolean overheadReceiverEmpty(Opportunity opp) {
        return opp.AccountId != null && opp.Overhead_Empf_nger__c == null;
    }

    public void setOverheadReceiver(Opportunity opp) {
        opp.Overhead_Empf_nger__c = getAbrechnungsaccount(opp).Provisionsempf_nger__c;
    }

    public Boolean tippgeberProvisionempfaengerEmpty(Opportunity opp) {
        return opp.AccountId != null && opp.TippgeberProvisionEmpfaenger__c == null;
    }

    public void setTippgeberProvisionempfaenger(Opportunity opp) {
        opp.TippgeberProvisionEmpfaenger__c = getAbrechnungsaccount(opp).Tippgeber__c;
    }


    public Boolean mahnungCreated(Opportunity opp, Opportunity oldOpp) {
        return opp.MahnungGenerieren__c && (Trigger.isInsert || (oldOpp != null && !oldOpp.MahnungGenerieren__c));
    }

    public void trackMahnungSent(Opportunity opp) {
        opp.LetzteMahnungAm__c = System.today();
        opp.Mahnstufe__c = opp.Mahnstufe__c != null ? (opp.Mahnstufe__c + 1) : 1;
        opp.MahnungZurGenehmigungSenden__c = false;
    }

    public Boolean mahnungApprovalStarted(Opportunity opp, Opportunity oldOpp) {
        return opp.MahnungZurGenehmigungSenden__c && (Trigger.isInsert || (oldOpp != null && !oldOpp.MahnungZurGenehmigungSenden__c));
    }

    public void trackMahnungStarted(Opportunity opp) {
        opp.MahnungGenerieren__c = false;
    }
    
    public Boolean opportunityWasLost(Opportunity opp, Opportunity oldOpp) {
        return lostOpportunityStages.contains(opp.StageName) && (Trigger.isInsert || (oldOpp != null && oldOpp.StageName != opp.StageName));
    }

    public void clearNotartermin(Opportunity opp) {
        opp.Notartermin__c = null;
    }

    /**
     * Methods for after trigger
    */
    public void setFieldsOnRelatedObjects(Opportunity opp, Opportunity oldOpp) {
        if(stageFurtherThanReservedAndCustomerNotProtected(opp, oldOpp)) {
            setCustomerToContinouslyProtected(opp);
        }
        if(reservedUntilChanged(opp, oldOpp)) {
            increaseCustomerProtection(opp);
        }
        if(kaufpreisBezahltWasSet(opp, oldOpp) || maBvBezahltWasSet(opp, oldOpp)) {
            updateProvisionsWithOpportunityValues(opp);
        }
        if(firstReservationSet(opp, oldOpp)) {
            setReservationDateOnImmobilie(opp);
        }
        if(apartmentOrApartmentRelevantFieldChanged(opp, oldOpp)) {
            setApartmentFields(opp, oldOpp);
        }
        if(opportunityWasWon(opp, oldOpp)) {
            setLastPropertyNumberOnCustomers(opp);
        }
        if(Trigger.isUpdate) {
            if(stageOrApartmentHasChanged(opp)) {
                setNewStatusOnApartment(opp);
            }
        }
    }

    private static final Set<String> STAGES_FURTHER_THAN_RESERVED = new Set<String> {
        'Geschlossene und gewonnene', 'Kaufvertragsunterlagen verschickt', 'Kaufvertragsangebot abgegeben', 'KV wird fremd gegeben'
    };

    public Boolean stageFurtherThanReservedAndCustomerNotProtected(Opportunity opp, Opportunity oldOpp) {
        Contact customer = mapRelatedContactsByIds.get(opp.Potenzieller_Kunde__c);
        Contact makler = mapRelatedContactsByIds.get(opp.Makler__c);  
        return (
            (Trigger.isInsert || (Trigger.isUpdate && oldOpp != null && opp.StageName != oldOpp.StageName))
            &&
            (!customer.Dauerhaft_gesch_tzt__c || !makler.Dauerhaft_gesch_tzt__c)
            &&
            STAGES_FURTHER_THAN_RESERVED.contains(opp.StageName)
        );
    }

    public void setCustomerToContinouslyProtected(Opportunity opp) {
        Contact customer = updateMap.containsKey(opp.Potenzieller_Kunde__c) ? (Contact) updateMap.get(opp.Potenzieller_Kunde__c) : mapRelatedContactsByIds.get(opp.Potenzieller_Kunde__c);
        if(!customer.Dauerhaft_gesch_tzt__c) {
            customer.Dauerhaft_gesch_tzt__c = true;
            updateMap.put(customer.Id, customer);
        }
    }

    public Boolean reservedUntilChanged(Opportunity opp, Opportunity oldOpp) {
        return (
            Trigger.isInsert && opp.reserviert_bis__c != null || (
                oldOpp != null && opp.reserviert_bis__c != oldOpp.reserviert_bis__c && opp.reserviert_bis__c != null
            )
        );
    }
    
    public void increaseCustomerProtection(Opportunity opp) {
        Contact customer = updateMap.containsKey(opp.Potenzieller_Kunde__c) ? (Contact) updateMap.get(opp.Potenzieller_Kunde__c) : mapRelatedContactsByIds.get(opp.Potenzieller_Kunde__c);
        if(!customer.Dauerhaft_gesch_tzt__c) {
            customer.Kunden_Maklerschutz__c = true;

            if(customer.Kundenschutz__c != null && customer.Kundenschutz__c < opp.reserviert_bis__c) {
                customer.Kundenschutz__c = opp.reserviert_bis__c;
            } else if(customer.Kundenschutz__c == null) {
                customer.Kundenschutz__c = opp.reserviert_bis__c.addDays(DEFAULT_RESERVATION_DURATION);
            }

            updateMap.put(customer.Id, customer);
        }
    }

    public Boolean kaufpreisBezahltWasSet(Opportunity opp, Opportunity oldOpp) {
        return (
            opp.Kaufpreis_bezahlt__c && (Trigger.isInsert || (oldOpp != null && !oldOpp.Kaufpreis_bezahlt__c))
        );
    }

    public Boolean maBvBezahltWasSet(Opportunity opp, Opportunity oldOpp) {
        return (
            opp.X1_MaBV_Rate_gezahlt__c && (Trigger.isInsert || (oldOpp != null && !oldOpp.X1_MaBV_Rate_gezahlt__c))
        );
    }

    public void updateProvisionsWithOpportunityValues(Opportunity opp) {
        if(mapProvisionenByOpportunityId.containsKey(opp.Id)) {
            for(Provision__c provi : mapProvisionenByOpportunityId.get(opp.Id)) {
                if(provi.Kaufpreis_bezahlt__c != opp.Kaufpreis_bezahlt__c || provi.X1_MaBV_Rate_gezahlt__c != opp.X1_MaBV_Rate_gezahlt__c) {
                    provi.Kaufpreis_bezahlt__c = opp.Kaufpreis_bezahlt__c;
                    provi.X1_MaBV_Rate_gezahlt__c = opp.X1_MaBV_Rate_gezahlt__c;
                    updateMap.put(provi.Id, provi);
                }
            }
        }
    }

    public Boolean firstReservationSet(Opportunity opp, Opportunity oldOpp) {
        return opp.Immobilie__c != null && mapImmobilienByIds.get(opp.Immobilie__c).DatumErsteReservierung__c == null &&
        opp.StageName != 'Kontingent' && opp.StageName != 'Reservierungsvorbereitung';
    }

    public void setReservationDateOnImmobilie(Opportunity opp) {
        Property__c immo = updateMap.containsKey(opp.Immobilie__c) ? (Property__c) updateMap.get(opp.Immobilie__c) : mapImmobilienByIds.get(opp.Immobilie__c);
        immo.DatumErsteReservierung__c = System.today();
        updateMap.put(immo.Id, immo);
    }

    public Boolean opportunityWasWon(Opportunity opp, Opportunity oldOpp) {
        return opp.IsWon && (Trigger.isInsert || (oldOpp != null && !oldOpp.IsWon));
    }

    public void setLastPropertyNumberOnCustomers(Opportunity opp) {
        Property__c immobilie = mapImmobilienByIds.get(opp.Immobilie__c);
        Contact customer = updateMap.containsKey(opp.Potenzieller_Kunde__c) ? (Contact) updateMap.get(opp.Potenzieller_Kunde__c) : mapRelatedContactsByIds.get(opp.Potenzieller_Kunde__c);
        customer.LetzteImmobiliennummer__c = immobilie.Objektnummer__c;
        updateMap.put(customer.Id, customer);
        
        if(opp.Kunde2__c != null) {
            Contact customerTwo = updateMap.containsKey(opp.Kunde2__c) ? (Contact) updateMap.get(opp.Kunde2__c) : mapRelatedContactsByIds.get(opp.Kunde2__c);
            customerTwo.LetzteImmobiliennummer__c = immobilie.Objektnummer__c;
            updateMap.put(customerTwo.Id, customerTwo);
        }
    }

    public Boolean apartmentOrApartmentRelevantFieldChanged(Opportunity opp, Opportunity oldOpp) {
        return !lostOpportunityStages.contains(opp.StageName) && (Trigger.isInsert || (Trigger.isUpdate && (opp.Appartement__c != oldOpp.Appartement__c || opp.Kaufpreis_f_llig__c != oldOpp.Kaufpreis_f_llig__c || opp.reserviert_bis__c != oldOpp.reserviert_bis__c || opp.Potenzieller_Kunde__c != oldOpp.Potenzieller_Kunde__c || opp.Makler__c != oldOpp.Makler__c || opp.Datum_Kaufpreis_bezahlt__c != oldOpp.Datum_Kaufpreis_bezahlt__c || opp.Notartermin__c != oldOpp.Notartermin__c || opp.Finanzierung__c != oldOpp.Finanzierung__c || opp.Maklerbetreuer_WirtschaftsHaus__c != oldOpp.Maklerbetreuer_WirtschaftsHaus__c || opp.StageName != oldOpp.StageName || opp.beurkundeter_Kaufpreis__c != oldOpp.beurkundeter_Kaufpreis__c || opp.Provisionsbasis__c != oldOpp.Provisionsbasis__c || opp.KumulierteProvisionExtern__c != oldOpp.KumulierteProvisionExtern__c || opp.Kaufdatum__c != oldOpp.Kaufdatum__c || opp.Bezahlt__c != oldOpp.Bezahlt__c)));
    }

    public void setApartmentFields(Opportunity opp, Opportunity oldOpp) {
        Appartment__c apartment = updateMap.containsKey(opp.Appartement__c) ? (Appartment__c) updateMap.get(opp.Appartement__c) : mapApartmentsById.get(opp.Appartement__c);
        if(Trigger.isInsert) {
            if(apartment != null) {
                //Übertrag von Daten in das Appartment
                apartment.Customer__c = opp.Potenzieller_Kunde__c;
                apartment.Makler__c = opp.Makler__c;
                apartment.Kaufpreis_gezahlt_am__c = opp.Datum_Kaufpreis_bezahlt__c;
                apartment.Notartermin__c = opp.Notartermin__c;
                apartment.Finanzierung__c = opp.Finanzierung__c;
                apartment.Maklerbetreuer_WirtschaftsHaus_lookup__c = opp.Maklerbetreuer_WirtschaftsHaus__c;
                apartment.Reserviert_bis__c = opp.reserviert_bis__c;
                apartment.beurkundeter_Kaufpreis__c = opp.beurkundeter_Kaufpreis__c;
                apartment.Provisionsbasis__c = opp.Provisionsbasis__c;
                apartment.Beurkundung__c = opp.Beurkundung__c;
                apartment.Kumulierte_Provision_extern__c = opp.KumulierteProvisionExtern__c;
                apartment.KaufpreisFaellig__c = opp.Kaufpreis_f_llig__c;
                if(opp.Bezahlt__c != 0) {
                    apartment.Bezahlt__c = opp.Bezahlt__c;
                }

                updateMap.put(apartment.Id, apartment);
            }
        } else {
            Appartment__c oldApartment = updateMap.containsKey(oldOpp.Appartement__c) ? (Appartment__c) updateMap.get(oldOpp.Appartement__c) : mapApartmentsById.get(oldOpp.Appartement__c);
            if(oldApartment != null && oldApartment.Id != apartment?.Id) {
                oldApartment.Status__c = 'Available';
                oldApartment.Customer__c = null;
                oldApartment.Makler__c = null;
                oldApartment.MarkedForReservation__c = false;
                oldApartment.Kaufpreis_gezahlt_am__c = null;
                oldApartment.Notartermin__c = null;
                oldApartment.Finanzierung__c = null;
                oldApartment.Maklerbetreuer_Wirtschaftshaus__c = null;
                oldApartment.Maklerbetreuer_WirtschaftsHaus_lookup__c = null;
                oldApartment.Reserviert_bis__c = null;
                oldApartment.Beurkundung__c = opp.Beurkundung__c;
                oldApartment.beurkundeter_Kaufpreis__c = null;
                oldApartment.Provisionsbasis__c = null;
                oldApartment.Kumulierte_Provision_extern__c = null;
                oldApartment.Date_of_purchase__c = null;
                oldApartment.KaufpreisFaellig__c = false;
                oldApartment.Bezahlt__c = 0;
                updateMap.put(oldApartment.Id, oldApartment);
            } 

            if(apartment != null && (oldApartment.Id != apartment.Id || oldApartment == null)) {
                apartment.beurkundeter_Kaufpreis__c = opp.beurkundeter_Kaufpreis__c;
                apartment.Provisionsbasis__c = opp.Provisionsbasis__c;
                apartment.Customer__c = opp.Potenzieller_Kunde__c;
                apartment.Makler__c = opp.Makler__c;
                apartment.Reserviert_bis__c = opp.reserviert_bis__c;
                apartment.Kaufpreis_gezahlt_am__c = opp.Datum_Kaufpreis_bezahlt__c;
                apartment.Notartermin__c = opp.Notartermin__c;
                apartment.Finanzierung__c = opp.Finanzierung__c;
                apartment.Maklerbetreuer_WirtschaftsHaus_lookup__c = opp.Maklerbetreuer_WirtschaftsHaus__c;
                apartment.Beurkundung__c = opp.Beurkundung__c;
                apartment.Kumulierte_Provision_extern__c = opp.KumulierteProvisionExtern__c;
                apartment.Date_of_purchase__c = opp.Kaufdatum__c;
                apartment.KaufpreisFaellig__c = opp.Kaufpreis_f_llig__c;
                if(opp.Bezahlt__c != 0) {
                    apartment.Bezahlt__c = opp.Bezahlt__c;
                }

                updateMap.put(apartment.Id, apartment);
            }
        }

    }

    public Boolean stageOrApartmentHasChanged(Opportunity opp) {
        Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(opp.Id);
        return opp.StageName != oldOpp.StageName || opp.Appartement__c != oldOpp.Appartement__c; 
    }

    private static final Map<String,String> APARTMENT_STATUS_BY_OPPORTUNITY_STAGE = new Map<String,String> {
        'Reservierungsvorbereitung' => 'Reservierungsvorbereitung',
        'Reservierung angefragt' => 'Reservierung angefragt',
        'Reserviert' => 'Reserved',
        'Kaufvertragsangebot abgegeben' => 'Kaufvertragsangebot abgegeben',
        'Kaufvertragsunterlagen verschickt' => 'Kaufvertragsunterlagen verschickt -zweiseitig-',
        'KV wird fremd abgegeben' => 'KV wird fremd abgegeben',
        'Geschlossene und gewonnene' => 'Sold',
        'Auftrag zur Beurkundung vorhanden' => 'Auftrag zur Beurkundung vorhanden',
        'Kontingent' => 'Kontingent',
        'VKC ausgelaufen' => 'Available',
        'Reservierung abgelehnt' => 'Available',
        'Geschlossen und verloren' => 'Available'
    };

    public void setNewStatusOnApartment(Opportunity opp) {
        if(mapApartmentsById.containsKey(opp.Appartement__c) && APARTMENT_STATUS_BY_OPPORTUNITY_STAGE.containsKey(opp.StageName)) {
            Appartment__c apartment = updateMap.containsKey(opp.Appartement__c) ? (Appartment__c) updateMap.get(opp.Appartement__c) : mapApartmentsById.get(opp.Appartement__c);
            apartment.Status__c = APARTMENT_STATUS_BY_OPPORTUNITY_STAGE.get(opp.StageName);
            System.debug(apartment.Status__c);
            System.debug(opp.StageName);
            if(apartment.Status__c == 'Reserved') {
                apartment.ReserviertFuer__c = opp.Id;
            }
            if(lostOpportunityStages.contains(opp.StageName) && (apartment.ReserviertFuer__c == opp.Id || apartment.ReserviertFuer__c == null)) {
                clearApartmentReservationInformation(apartment);
            }
            
            updateMap.put(apartment.Id, apartment);
        }
    }

    /**
     * Cache functions
     */

    /**
     * Caches all relevant Provisionsverhandlung__c records and stores them in a map to allow easy access
     */
    private void getProvisionsverhandlungen() {
        for(Provisionsverhandlung__c proviV : [SELECT Id, Grundprovision__c, Verkaufsprovision__c, Account__c, Immobilie__c FROM Provisionsverhandlung__c WHERE Account__c IN :accountIds AND Immobilie__c IN :immoIds]) {
            if(mapProvisionsverhandlungByImmoIdByAccountId.containsKey(proviV.Account__c)) {
                mapProvisionsverhandlungByImmoIdByAccountId.get(proviV.Account__c).put(proviV.Immobilie__c, proviV);
            } else {
                mapProvisionsverhandlungByImmoIdByAccountId.put(proviV.Account__c, new Map<Id,Provisionsverhandlung__c> { proviV.Immobilie__c => proviV });
            }
        }
    }

    public void getLostOpportunityStages() {
        for(OpportunityStage oppStage : [SELECT ApiName FROM OpportunityStage WHERE IsWon = false AND IsClosed = true]) {
            lostOpportunityStages.add(oppStage.ApiName);
        }
    }

    public void getApartments() {
        mapApartmentsById = new Map<Id,Appartment__c>([SELECT Id, Status__c, ReserviertFuer__c, ReserviertFuer__r.Name, Name FROM Appartment__c WHERE Id IN :apartmentIds]);
    }

    public void getRelatedContacts() {
        if(!contactIds.isEmpty()) {
            mapRelatedContactsByIds = new Map<Id,Contact> ([SELECT Id, FirstName, LastName, Kampagnenquelle__c, AccountId, Email, OwnerId, Dauerhaft_gesch_tzt__c, Kundenschutz__c FROM Contact WHERE Id IN :contactIds]);
        }
    }

    public void getAccounts() {
        for(Contact contact : mapRelatedContactsByIds.values()) {
            accountIds.add(contact.AccountId);
        }
        
        mapAccountsByIds = new Map<Id,Account>([
            SELECT Id, Maklerbetreuer_Wirtschaftshaus_2__c, Maklerbetreuer_Wirtschaftshaus_2__r.Email, WHS_Maklerprovision__c,
            Overhead_Vereinbarung__c, Tippgeber_in__c, Provisionsempf_nger__c, Tippgeber__c
            FROM Account 
            WHERE Id IN :accountIds
        ]);
    }

    public void getProvisionen() {
        for(Provision__c provi : [SELECT Id, Verkaufschance__c, X1_MaBV_Rate_gezahlt__c, Kaufpreis_bezahlt__c FROM Provision__c WHERE Verkaufschance__c IN :Trigger.new]) {
            if(mapProvisionenByOpportunityId.containsKey(provi.Verkaufschance__c)) {
                mapProvisionenByOpportunityId.get(provi.Verkaufschance__c).add(provi);
            } else {
                mapProvisionenByOpportunityId.put(provi.Verkaufschance__c, new List<Provision__c> {provi});
            }
        }
    }

    public void getImmobilien() {
        mapImmobilienByIds = new Map<Id,Property__c>([SELECT Id, DatumErsteReservierung__c, Projektbeauftragte__r.Contact__c, Objektnummer__c, Name FROM Property__c WHERE Id IN :immoIds]);
    }

    Set<Id> accountIds = new Set<Id>();
    Set<Id> contactIds = new Set<Id>();
    Set<Id> apartmentIds  = new Set<Id>();
    Set<Id> immoIds = new Set<Id>();

    public void collectIdsOfRelatedRecords() {
        for(Opportunity opp : (List<Opportunity>) Trigger.new) {
            accountIds.add(opp.AccountId);
            apartmentIds.add(opp.Appartement__c);
            immoIds.add(opp.Immobilie__c);

            if(opp.Makler__c != null) {
                contactIds.add(opp.Makler__c);
            }
            if(opp.Potenzieller_Kunde__c != null) {
                contactIds.add(opp.Potenzieller_Kunde__c);
            }
            if(opp.Kunde2__c != null) {
                contactIds.add(opp.Kunde2__c);
            }
            if(opp.Abrechnung_ber__c != null) {
                accountIds.add(opp.AccountIdAbrechnungUeber__c);
            } 
            if(opp.AccountIdImmobilienberater__c != null) {
                accountIds.add(opp.AccountIdImmobilienberater__c);
            }

            if(Trigger.isUpdate) {
                Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(opp.Id);
                if(opp.Appartement__c != oldOpp.Appartement__c) {
                    apartmentIds.add(oldOpp.Appartement__c);
                }
            }
        }
    }
    public static void sendEmailWhenReservationAccepted(Map<Id, opportunity> oppNewMap, Map<Id, opportunity> oppOldMap) {
        List<Messaging.SingleEmailMessage> allMsgs = new List<messaging.SingleEmailMessage>();
        Map<Id, Opportunity> opps = new Map<Id, opportunity>();

        for (opportunity opp : oppNewMap.values()) {
            //checking if opportunity stage was updated from 'reservierung angefragt' to 'Reserviert'
            if (oppOldMap.get(opp.id).StageName == OPPORTUNITY_STAGE_RESERVIERUNG_ANGEFRAGT &&
                    oppNewMap.get(opp.id).StageName == OPPORTUNITY_STAGE_RESERVIERT) {
                opps.put(opp.id, opp);

            }
        }
        if (opps.size() > 0) {
            EmailTemplate mailTemplate = [
                    Select Id, Subject, Description,
                            HtmlValue, DeveloperName, Body
                    from EmailTemplate
                    where DeveloperName =
                            'ReservationIsActive'
            ];
            for (opportunity opp : opps.values()) {

                id maklerId = opp.Makler__c;
                id maklerbetreuerCarestoneId = opp.Maklerbetreuer_WirtschaftsHaus__c;

                Messaging.SingleEmailMessage mailToMakler = new Messaging.SingleEmailMessage();
                mailToMakler.setTemplateID(mailTemplate.Id);
                mailToMakler.setWhatId(opp.Id);
                mailToMakler.setTargetObjectId(maklerId);
                allMsgs.add(mailToMakler);

                Messaging.SingleEmailMessage mailToMaklBeretreuer = new Messaging.SingleEmailMessage();
                mailToMaklBeretreuer.setTemplateID(mailTemplate.Id);
                mailToMaklBeretreuer.setWhatId(opp.Id);
                mailToMaklBeretreuer.setTargetObjectId(maklerbetreuerCarestoneId);
                allMsgs.add(mailToMaklBeretreuer);

            }
        try {
            Messaging.sendEmail(allMsgs, true);
        } catch (Exception e) {
            System.debug(e.getMessage() + ' Failed to send emails');
        }
    }
    }
}