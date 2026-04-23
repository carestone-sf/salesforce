public without sharing class ProvisionService {

    List<Provision__c> provs = new List<Provision__c>();
    Set<String> deleteProvs = new Set<String>();
    Map<Id, Set<Id>> recipientsIdsMap = new Map<Id, Set<Id>>();
    Set<Id> recipientsIds = new Set<Id>();
    Map<Id, Set<Id>> oldRecipientsIdsMap = new Map<Id, Set<Id>>();
    Map<Id, Opportunity> opps;
    Map<Id, Opportunity> oldOpps;
    List<Opportunity> allOpps;
    @TestVisible
    Map<Id, Map<Integer, Map<Integer, Integer>>> mbToYearToMonthOpps = new Map<Id, Map<Integer, Map<Integer, Integer>>>();
    @TestVisible
    Map<Id, Map<Integer, Map<Integer, Integer>>> mbToYearToQuarterOpps = new Map<Id, Map<Integer, Map<Integer, Integer>>>();
    @TestVisible
    Map<Id, Map<Integer, Integer>> mbToYearOpps = new Map<Id, Map<Integer, Integer>>();
    Map<Id, Integer> mbToOpos = new Map<Id, Integer>();
    Map<Id, Map<String, Decimal>> mbToRefunds = new Map<Id, Map<String, Decimal>>();
    @TestVisible
    private static final String DEFAULT_PROVISIONSMODELL_KEY = '__DEFAULT__';
    @TestVisible
    private static final String ABRECHNUNGSPERIODE_MONAT = 'Monat';
    @TestVisible
    private static final String ABRECHNUNGSPERIODE_QUARTAL = 'Quartal';
    @TestVisible
    private static final String ABRECHNUNGSPERIODE_JAHR = 'Jahr';
    @TestVisible
    private Map<String, List<Provisionsmodell__c>> provisionModelsByPartnermanagerKey = new Map<String, List<Provisionsmodell__c>>();
    String mode;
    String schedule;
    String pageError = 'Für diesen Makler kann keine Provision erstellt werden, dieser Makler hat keinen Vertrag. Bitte überprüfen Sie die Provisionsmatrix, ob dieser Makler über jemanden anders abgerechnet wird.';

    public ProvisionService(Map<Id, Opportunity> opps, Map<Id, Opportunity> oldOpps, String mode, String schedule) {
        this.opps = opps;
        this.oldOpps = oldOpps;
        // intern || extern
        this.mode = mode;
        // month || quarter || year
        this.schedule = schedule;
    }

    public void upsertProvisionen() {
        Map<Id, Opportunity> filtered = new Map<Id, Opportunity>();
        for (Opportunity opp : this.opps.values()) {
            if (!opp.HatAufschiebendeBedingung__c || opp.AufschiebendeBedingungErfuellt__c) {
                filtered.put(opp.Id, opp);
            }
        }
        this.opps = filtered;
        if (this.opps.isEmpty()) {
            return;
        }
        getRecipientsIds();
        Map<Id,Contact> allRecipients = new Map<Id, Contact>([
            SELECT
                Id,
                Gesch_ftsbeziehung__c,
                ErfolgsabhaengigeMaxInProzent__c,
                ErfolgsabhaengigeProvisionInEuro__c,
                ErhaeltErfolgsabhaengigeProvision__c,
                ErhaeltErfolgsabhaengigeProvisionVon__c,
                ErhaeltErfolgsabhaengigeProvisionBis__c,
                Ist_Maklerbetreuer_WH__c,
                Email,
                Maklerauftrag__c
            FROM Contact
            WHERE Id IN : this.recipientsIds
        ]);
        List<Id> mbIds = new List<Id>();
        for(Contact con:allRecipients.values()) {
            if(con.Ist_Maklerbetreuer_WH__c == true) {
                mbIds.add(con.Id);
            }
        }
        if(this.mode == 'intern') {
            Date todaysDate = Date.today();
            Integer thisMonth = todaysDate.month();
            Integer lastMonth = todaysDate.month() - 1;
            Integer thisYear = todaysDate.year();
            Integer lastYear = todaysDate.year()-1;
            Integer lastYearOrThisYear = todaysDate.year();
            if(thisMonth == 1 && todaysDate.day() <= 10) {
                lastMonth = 12;
                lastYearOrThisYear -= 1;
            }
            Integer thisQuarter = getQuarterByMonth(lastMonth);
            String query = 'SELECT Id, Notartermin__c, Datum_Kaufpreis_bezahlt__c, Vertriebskoordinator__c, ProvisionVertriebskoordination__c, Maklerbetreuer_WirtschaftsHaus__c, Maklerbetreuer_WirtschaftsHaus__r.ErfolgsabhaengigeMaxInProzent__c FROM Opportunity';
            // if(this.schedule == 'month') {
            //     if(todaysDate.day() <= 10) {
            //         query += ' WHERE ((CALENDAR_MONTH(Notartermin__c) = :lastMonth AND CALENDAR_YEAR(Notartermin__c) = :lastYearOrThisYear) OR (CALENDAR_YEAR(Notartermin__c) = :thisYear AND CALENDAR_MONTH(Notartermin__c) = :thisMonth) )';
            //     } else if(todaysDate.day() > 10) {
            //         query += ' WHERE CALENDAR_MONTH(Notartermin__c) = :thisMonth AND CALENDAR_YEAR(Notartermin__c) = :thisYear';
            //     }
            // } else if(this.schedule == 'quarter') {
            //     query += ' WHERE CALENDAR_QUARTER(Notartermin__c) = :thisQuarter AND (CALENDAR_YEAR(Notartermin__c) = :thisYear OR CALENDAR_YEAR(Notartermin__c) = :lastYearOrThisYear)';
            // } else if(this.schedule == 'year') {
            //     query += ' WHERE CALENDAR_YEAR(Notartermin__c) = :lastYearOrThisYear';
            // }
            query += ' WHERE (CALENDAR_YEAR(Notartermin__c) = :lastYear OR CALENDAR_YEAR(Notartermin__c) = :thisYear)';

            query += ' AND (StageName = \'Geschlossene und gewonnene\' OR StageName = \'Notartermin hat stattgefunden\')';
            
            List<Opportunity> allOpps = (List<Opportunity>)Database.query(query);
            for(Opportunity opp:allOpps) {
                Integer yearOpp = opp.Notartermin__c.year();
                Integer monthOpp = opp.Notartermin__c.month();
                Integer quarterOpp = getQuarterByMonth(monthOpp);

                // ===== MONTH =====
                Map<Integer, Map<Integer, Integer>> yearToMonth =
                    mbToYearToMonthOpps.get(opp.Maklerbetreuer_WirtschaftsHaus__c);
                if (yearToMonth == null) {
                    yearToMonth = new Map<Integer, Map<Integer, Integer>>();
                }

                Map<Integer, Integer> monthOpps = yearToMonth.get(yearOpp);
                if (monthOpps == null) {
                    monthOpps = new Map<Integer, Integer>();
                }

                Integer countMonthOpps = monthOpps.get(monthOpp);
                if (countMonthOpps == null) {
                    countMonthOpps = 0;
                }
                monthOpps.put(monthOpp, countMonthOpps + 1);

                yearToMonth.put(yearOpp, monthOpps);
                mbToYearToMonthOpps.put(opp.Maklerbetreuer_WirtschaftsHaus__c, yearToMonth);

                // ===== QUARTER =====
                Map<Integer, Map<Integer, Integer>> yearToQuarter =
                    mbToYearToQuarterOpps.get(opp.Maklerbetreuer_WirtschaftsHaus__c);
                if (yearToQuarter == null) {
                    yearToQuarter = new Map<Integer, Map<Integer, Integer>>();
                }

                Map<Integer, Integer> quarterOpps = yearToQuarter.get(yearOpp);
                if (quarterOpps == null) {
                    quarterOpps = new Map<Integer, Integer>();
                }

                Integer countQuarterOpps = quarterOpps.get(quarterOpp);
                if (countQuarterOpps == null) {
                    countQuarterOpps = 0;
                }
                quarterOpps.put(quarterOpp, countQuarterOpps + 1);

                yearToQuarter.put(yearOpp, quarterOpps);
                mbToYearToQuarterOpps.put(opp.Maklerbetreuer_WirtschaftsHaus__c, yearToQuarter);

                Map<Integer, Integer> yearOpps = mbToYearOpps.get(opp.Maklerbetreuer_WirtschaftsHaus__c);
                if(yearOpps == null) {
                    yearOpps = new Map<Integer, Integer>();
                }
                Integer countYearOpps = yearOpps.get(yearOpp);
                if(countYearOpps == null) {
                    countYearOpps = 0;
                }
                countYearOpps++;
                yearOpps.put(yearOpp, countYearOpps);
                mbToYearOpps.put(opp.Maklerbetreuer_WirtschaftsHaus__c, yearOpps);
            }

            Integer lastQuarter = (thisQuarter - 1) == 0 ? 4 : thisQuarter-1; 
            List<Opportunity> refundOpps = [SELECT Id, Maklerbetreuer_WirtschaftsHaus__c, Grund_VKC_verloren__c, Notartermin__c FROM Opportunity WHERE (Grund_VKC_verloren__C = 'Rückabwicklung' AND CALENDAR_QUARTER(DatumRueckabwicklung__c) = :lastQuarter AND (CALENDAR_YEAR(DatumRueckabwicklung__c) = :thisYear OR CALENDAR_YEAR(DatumRueckabwicklung__c) = :lastYearOrThisYear)) OR (CALENDAR_QUARTER(Notartermin__c) = :lastQuarter AND (CALENDAR_YEAR(Notartermin__c) = :thisYear OR CALENDAR_YEAR(Notartermin__c) = :lastYearOrThisYear) AND (IsWon = true OR StageName = 'Notartermin hat stattgefunden'))];
            List<Opportunity> oposOpps = [SELECT Id, Maklerbetreuer_WirtschaftsHaus__c, PhaseFinanzierungsanfrage__c FROM Opportunity WHERE TageUeberfaellig__c > 0 AND CreatedDate > 2023-01-01T00:00:00Z AND PhaseFinanzierungsanfrage__c != 'Bankantrag' AND PhaseFinanzierungsanfrage__c != 'Finanzierung genehmigt'];

            for(Opportunity opp:refundOpps) {
                Map<String, Decimal> refundsMap = mbToRefunds.get(opp.Maklerbetreuer_WirtschaftsHaus__c);
                if(refundsMap == null) {
                    refundsMap = new Map<String, Decimal>();
                }
                if(opp.Grund_VKC_verloren__C == 'Rückabwicklung') {
                    Decimal amount = refundsMap.get('refunds');
                    if(amount == null) {
                        amount = 0;
                    }
                    amount++;
                    refundsMap.put('refunds', amount);
                } else if(opp.Notartermin__c != null) {
                    Decimal amount = refundsMap.get('notartermine');
                    if(amount == null) {
                        amount = 0;
                    }
                    amount++;
                    refundsMap.put('notartermine', amount);
                }

                Decimal quota = 0;
                Decimal refunds = refundsMap.get('refunds');
                Decimal notartermine = refundsMap.get('notartermine');
                if(refunds != 0 && refunds != null && notartermine != 0 && notartermine != null) {
                    quota = refunds / (notartermine+refunds);
                }
                refundsMap.put('quota', quota);
                mbToRefunds.put(opp.Maklerbetreuer_WirtschaftsHaus__c, refundsMap);
            }

            for(Opportunity opp:oposOpps) {
                Integer oposAmount = mbToOpos.get(opp.Maklerbetreuer_WirtschaftsHaus__c);
                if(oposAmount == null) {
                    oposAmount = 0;
                }
                oposAmount++;
                mbToOpos.put(opp.Maklerbetreuer_WirtschaftsHaus__c, oposAmount);
            }
        }
        if(this.mode == 'intern') {
            initializeProvisionModelConfigs(this.opps.values(), allRecipients.values());
        }
        for(Opportunity opp: opps.values()) {
            //String maklerprovision = opp.Maklerprovision__c;
            Opportunity oldOpp = oldOpps.get(opp.Id);
            Set<Id> oldRecipientIds = this.oldRecipientsIdsMap.get(opp.Id);
            for(Id oldRecipientId:oldRecipientIds) {
                String uniqueId = opp.Id + '-' + oldRecipientId;
                deleteProvs.add(uniqueId);
            }
            for(Contact con:allRecipients.values()) {
                Provision__c prov = new Provision__c();
                if(
                    mode == 'intern'
                    && con.ErhaeltErfolgsabhaengigeProvision__c == true
                    && isErfolgsabhaengigeProvisionDateInRange(con, opp.Notartermin__c)
                ) {
                    prov = this.getProvisionIntern(opp, con);
                    if(prov != null) {
                        provs.add(prov);
                    }
                } else if(mode == 'intern' && con.Id == opp.Vertriebskoordinator__c) {
                    prov = this.getProvisionInternVertriebskoordinator(opp, con);
                    if(prov != null) {
                        provs.add(prov);
                    }
                } else if(mode == 'extern' && !con.Ist_Maklerbetreuer_WH__c) {
                    prov = this.getProvisionExtern(opp, con);
                    if(prov != null) {
                        provs.add(prov);
                    }
                } else if(mode == 'intern_after_sale' && con.Ist_Maklerbetreuer_WH__c == true) {
                    prov = this.getProvisionExtern(opp, con);
                    if(prov != null) {
                        provs.add(prov);
                    }
                }
            }
        }
        Schema.SObjectField provisionUniqueIdField = Provision__c.Fields.UniqueId__c;
        Database.upsert(provs, provisionUniqueIdField, true);
        delete [SELECT Id FROM Provision__c WHERE UniqueId__c IN :deleteProvs OR Provisionssumme__c = 0];
    }

    public Provision__c getProvisionExtern(Opportunity opp, Contact con) {
        Provision__c prov = new Provision__c();
        prov.UniqueId__C = opp.Id + '-' + con.Id;
        prov.Verkaufschance__c = opp.Id;
        prov.Makler__c = con.Id;
        prov.Objekt__c = opp.Immobilie__c;
        prov.Wohneinheit__c = opp.Appartement__c;
        prov.Kunde__c = opp.Potenzieller_Kunde__c;
        prov.Ausl_ser__c = con.Id;
        prov.E_Mail__c = con.Email;
        prov.Kaufpreis__c = opp.Provisionsbasis__c;
        prov.Maklerbetreuer__c = opp.OwnerId;
        prov.MarketingzuschussNichtAusweisen__c = opp.MarketingzuschussNichtAusweisen__c;
        prov.ProvisionsvoraussetzungenErfuelltAm__c = Date.today();

        if(opp.Immobilienberater__c == con.Id && opp.Makler__c != opp.Immobilienberater__c && !con.Ist_Maklerbetreuer_WH__c && (opp.Wert_Verk_ufer_Beratungsprovision_m_R__c == 0 || opp.Wert_Verk_ufer_Beratungsprovision_m_R__c == null)) {
            return null;
        }

        if(con.Gesch_ftsbeziehung__c != null) {
            if((con.Maklerauftrag__c == 'Maklerauftrag beidseitig unterzeichnet' || con.Maklerauftrag__c == 'Makler mit altem Vertrag') && !con.Ist_Maklerbetreuer_WH__c && !con.Gesch_ftsbeziehung__c.contains('Interessent') && !con.Gesch_ftsbeziehung__c.contains('Kunde')) {
                prov.Eingereicht_Check__c = true;
            } else if ((con.Maklerauftrag__c != 'Maklerauftrag beidseitig unterzeichnet' || con.Maklerauftrag__c != 'Makler mit altem Vertrag') && !con.Ist_Maklerbetreuer_WH__c && opp.Abrechnung_ber__c == null) {
                opp.addError(pageError);
            }
        }

        if(con.Id == '003b0000002p3N5') {
            prov.Wert_Provision_Thoben__c = opp.Wert_Provision_Thoben__c;
        }

        if(opp.Immobilienberater__c == con.Id && (opp.Abrechnung_ber__c == null || opp.AbrechnungUeberNurFuerGrundprovision__c)) {
            prov.Wert_Verk_ufer_Beratungsprovision_m_R__c = opp.Wert_Verk_ufer_Beratungsprovision_m_R__c;
        } else if(opp.Immobilienberater__c == con.Id && con.Ist_Maklerbetreuer_WH__c) {
            prov.Wert_Verk_ufer_Beratungsprovision_m_R__c = opp.Wert_Verk_ufer_Beratungsprovision_m_R__c;
        } else {
            prov.Wert_Verk_ufer_Beratungsprovision_m_R__c = 0;
        }   

        if(con.Ist_Maklerbetreuer_WH__c) {
            prov.ClosingBonusInEuro__c = opp.ClosingBonusInEuro__c;
            prov.ClosingBonusInProzent__c = opp.ClosingBonusInProzent__c; 
            prov.BeratungsprovisionMitPVInEuro__c = opp.BeratungsprovisionMitPVInEuro__c;
            prov.BeratungsprovisionMitPVInProzent__c = opp.BeratungsprovisionMitPVInProzent__c; 
            prov.ProvisionsverzichtInProzent__c = opp.ProvisionsverzichtInProzent__c;
            prov.ProvisionsverzichtInEuro__c = opp.ProvisionsverzichtInEuro__c; 
        }

        if(opp.Makler__c == con.Id && opp.Abrechnung_ber__c == null) {
            prov.Wert_Maklerprovision__c = opp.Wert_Maklerprovision__c;
            prov.WertMarketingzuschuss__c = opp.WertMarketingzuschuss__c;
            prov.AdditionalBrokerCommission__c = opp.AdditionalBrokerCommission__c;
        } else {
            prov.Wert_Maklerprovision__c = 0;
            prov.WertMarketingzuschuss__c = 0;
            prov.AdditionalBrokerCommission__c = 0;
        }
        
        if(opp.Abrechnung_ber__c == con.Id) {
            if(String.isBlank(opp.Verkaufsprovision_intern__c) && !opp.AbrechnungUeberNurFuerGrundprovision__c) {
                prov.Wert_Verk_ufer_Beratungsprovision_m_R__c = opp.Wert_Verk_ufer_Beratungsprovision_m_R__c;
            }
            prov.Wert_Maklerprovision__c = opp.Wert_Maklerprovision__c;
            prov.WertMarketingzuschuss__c = opp.WertMarketingzuschuss__c;
            prov.AdditionalBrokerCommission__c = opp.AdditionalBrokerCommission__c;
            prov.Makler__c = opp.Abrechnung_ber__c;
        }
        if(opp.TippgeberProvisionEmpfaenger__c == con.Id) {
            prov.Wert_Tippprovision__c = opp.Wert_Tippprovision__c;
        }
        if(opp.Overhead_Empf_nger__c == con.Id) {
            prov.Wert_Overhead__c = opp.Wert_Overhead__c;
        }
        
        return prov;
    }

    public Provision__c getProvisionIntern(Opportunity opp, Contact con) {
        Provision__c prov = new Provision__c();
        prov.UniqueId__c = opp.Id + '-' + con.Id;
        if(this.schedule != null) {
            prov.UniqueId__c += '-' + this.schedule;
        }
        prov.Verkaufschance__c = opp.Id;
        prov.Makler__c = con.Id;
        prov.Objekt__c = opp.Immobilie__c;
        prov.Wohneinheit__c = opp.Appartement__c;
        prov.Kunde__c = opp.Potenzieller_Kunde__c;
        prov.Ausl_ser__c = con.Id;
        prov.E_Mail__c = con.Email;
        prov.Kaufpreis__c = opp.Provisionsbasis__c;
        prov.Maklerbetreuer__c = opp.OwnerId;
        prov.MarketingzuschussNichtAusweisen__c = opp.MarketingzuschussNichtAusweisen__c;
        Integer monthOpp = opp.Notartermin__c.month();
        Integer yearOpp = opp.Notartermin__c.year();
        Integer quarterOpp = getQuarterByMonth(monthOpp);

        System.debug(opp.Maklerbetreuer_WirtschaftsHaus__c);
        System.debug(mbToOpos.get(opp.Maklerbetreuer_WirtschaftsHaus__c));
        System.debug(mbToRefunds.get(opp.Maklerbetreuer_WirtschaftsHaus__c));

        if(opp.Datum_Kaufpreis_bezahlt__c == null && opp.Datum_1_MaBV_Rate_gezahlt__c == null && this.schedule == 'month' && opp.Maklerbetreuer_WirtschaftsHaus__c != '00367000041nIPDAA2') {
            if(mbToOpos.get(opp.Maklerbetreuer_WirtschaftsHaus__c) != null && mbToOpos.get(opp.Maklerbetreuer_WirtschaftsHaus__c) > 5) {
                prov.ErfolgsabhaengigeProvisionInProzent__c = 0;
                prov.Erfolgsabh_ngige_Provision_direkt__c = 0;
                prov.ProvisionsvoraussetzungenErfuelltAm__c = opp.Notartermin__c;
                return prov;
            } else if(mbToRefunds.get(opp.Maklerbetreuer_WirtschaftsHaus__c) != null && mbToRefunds.get(opp.Maklerbetreuer_WirtschaftsHaus__c).get('quota') >= 0.05) {
                prov.ErfolgsabhaengigeProvisionInProzent__c = 0;
                prov.Erfolgsabh_ngige_Provision_direkt__c = 0;
                prov.ProvisionsvoraussetzungenErfuelltAm__c = opp.Notartermin__c;
                return prov;
            }
        }

        if(this.schedule == 'month') {
            if(opp.Datum_Kaufpreis_bezahlt__c != null) {
                prov.ProvisionsvoraussetzungenErfuelltAm__c = opp.Datum_Kaufpreis_bezahlt__c;
            } else if(opp.Datum_1_MaBV_Rate_gezahlt__c != null) {
                prov.ProvisionsvoraussetzungenErfuelltAm__c = opp.Datum_1_MaBV_Rate_gezahlt__c;
            } else {
                prov.ProvisionsvoraussetzungenErfuelltAm__c = opp.Notartermin__c;
            }
        } else if(this.schedule == 'quarter') {
            prov.ProvisionsvoraussetzungenErfuelltAm__c = Date.newInstance(yearOpp, quarterOpp*3, 30);
        } else if(this.schedule == 'year') {
            prov.ProvisionsvoraussetzungenErfuelltAm__c = Date.newInstance(yearOpp, 12, 30);
        }
        
        prov.Provisionszeitraum__c = 'Monat';
        prov.AnzahlEinheitenMonat__c =
            mbToYearToMonthOpps.get(opp.Maklerbetreuer_WirtschaftsHaus__c)
                ?.get(yearOpp)
                ?.get(monthOpp);

        if (schedule == 'quarter' || schedule == 'year') {
            prov.AnzahlEinheitenQuartal__c =
                mbToYearToQuarterOpps.get(opp.Maklerbetreuer_WirtschaftsHaus__c)
                    ?.get(yearOpp)
                    ?.get(quarterOpp);
        }

        if(schedule == 'quarter') {
            prov.Provisionszeitraum__c = 'Quartal';
        } else if(schedule == 'year') {
            prov.AnzahlEinheitenJahr__c = mbToYearOpps.get(opp.Maklerbetreuer_WirtschaftsHaus__c)?.get(yearOpp);
            prov.Provisionszeitraum__c = 'Jahr';
        }

        if(opp.Maklerbetreuer_WirtschaftsHaus__c == con.Id) {
            Decimal erfolgsabhaengigeProvision = getErfolgsabhaengigeProvision(prov, con, opp.Notartermin__c);
            if(erfolgsabhaengigeProvision == null) {
                return null;
            }
            prov.ErfolgsabhaengigeProvisionInProzent__c = erfolgsabhaengigeProvision*100;
            prov.Erfolgsabh_ngige_Provision_direkt__c = erfolgsabhaengigeProvision * opp.Provisionsbasis__c;
        }
        
        return prov;
    }

    public Provision__c getProvisionInternVertriebskoordinator(Opportunity opp, Contact con) {
        if(opp.Datum_Kaufpreis_bezahlt__c == null && opp.Datum_1_MaBV_Rate_gezahlt__c == null) {
            return null;
        }

        Provision__c prov = new Provision__c();
        prov.UniqueId__c = opp.Id + '-' + con.Id;
        prov.Verkaufschance__c = opp.Id;
        prov.Makler__c = con.Id;
        prov.Objekt__c = opp.Immobilie__c;
        prov.Wohneinheit__c = opp.Appartement__c;
        prov.Kunde__c = opp.Potenzieller_Kunde__c;
        prov.Ausl_ser__c = con.Id;
        prov.E_Mail__c = con.Email;
        prov.Kaufpreis__c = opp.Provisionsbasis__c;
        prov.Maklerbetreuer__c = opp.OwnerId;
        prov.MarketingzuschussNichtAusweisen__c = opp.MarketingzuschussNichtAusweisen__c;
        if(opp.Datum_1_MaBV_Rate_gezahlt__c != null) {
            prov.ProvisionsvoraussetzungenErfuelltAm__c = opp.Datum_1_MaBV_Rate_gezahlt__c;
        } else if(opp.Datum_Kaufpreis_bezahlt__c != null) {
            prov.ProvisionsvoraussetzungenErfuelltAm__c = opp.Datum_Kaufpreis_bezahlt__c;
        } 

        if (opp.Notartermin__c != null && opp.Notartermin__c < Date.newInstance(2025, 5, 1)) {
            return null;
        }
        
        prov.ProvisionVertriebskoordination__c = opp.ProvisionVertriebskoordination__c;
        if(prov.ProvisionVertriebskoordination__c == null || prov.ProvisionVertriebskoordination__c == 0) {
            return null;
        }
        return prov;
    }

    public void checkForCorrections(List<Opportunity> opps) {
        List<Id> oppIds = new List<Id>();
        for(Opportunity opp:opps) {
            oppIds.add(opp.Id);
        }
        List<Provision__c> provs = [SELECT Id, ClosingBonusInEuro__c, ClosingBonusInProzent__c, BeratungsprovisionMitPVInEuro__c, BeratungsprovisionMitPVInProzent__c, ProvisionsverzichtInProzent__c, ProvisionsverzichtInEuro__c, ErfolgsabhaengigeProvisionInProzent__c, Erfolgsabh_ngige_Provision_direkt__c, Provisionszeitraum__c, UniqueId__c, Verkaufschance__c, Makler__c, Objekt__c, Wohneinheit__c, Kunde__c, Ausl_ser__c, E_Mail__c, Kaufpreis__c, Maklerbetreuer__c, MarketingzuschussNichtAusweisen__c, ProvisionsvoraussetzungenErfuelltAm__c FROM Provision__c WHERE Makler__r.Ist_Maklerbetreuer_WH__c = true AND Verkaufschance__c IN :oppIds];
        List<Provision__c> deleteProvs = new List<Provision__c>();
        List<Provision__c> insertProvs = new List<Provision__c>();

        for(Provision__c prov:provs) {
            Date today = Date.today();
            Date firstDayOfThisMonth = today.toStartOfMonth();
            Date firstDayOfLastMonth = firstDayOfThisMonth.addMonths(-1);

            // Check if prov.ProvisionsvoraussetzungenErfuelltAm__c is in last month AND today is before the 10th of the month
            // OR if ProvisionsvoraussetzungenErfuelltAm__c is this month
            if ((prov.ProvisionsvoraussetzungenErfuelltAm__c >= firstDayOfLastMonth && prov.ProvisionsvoraussetzungenErfuelltAm__c < firstDayOfThisMonth && today.day() < 10)  || prov.ProvisionsvoraussetzungenErfuelltAm__c >= firstDayOfThisMonth) {
                deleteProvs.add(prov);
            }
            // Check if prov.ProvisionsvoraussetzungenErfuelltAm__c is before last month
            else if (prov.ProvisionsvoraussetzungenErfuelltAm__c < firstDayOfLastMonth) {
                Provision__c newProv = new Provision__c();
                newProv.Provisionszeitraum__c = prov.Provisionszeitraum__c;
                newProv.UniqueId__c = prov.UniqueId__c + '-correction';
                newProv.Verkaufschance__c = prov.Verkaufschance__c;
                newProv.Makler__c = prov.Makler__c;
                newProv.Objekt__c = prov.Objekt__c;
                newProv.Wohneinheit__c = prov.Wohneinheit__c;
                newProv.Kunde__c = prov.Kunde__c;
                newProv.Ausl_ser__c = prov.Ausl_ser__c;
                newProv.E_Mail__c = prov.E_Mail__c;
                newProv.Kaufpreis__c = prov.Kaufpreis__c;
                newProv.Maklerbetreuer__c = prov.Maklerbetreuer__c;
                newProv.MarketingzuschussNichtAusweisen__c = prov.MarketingzuschussNichtAusweisen__c;
                newProv.ProvisionsvoraussetzungenErfuelltAm__c = Date.today();

                if(prov.ClosingBonusInEuro__c != null && prov.ClosingBonusInEuro__c != 0) {
                    newProv.ClosingBonusInEuro__c = -prov.ClosingBonusInEuro__c;
                }

                if(prov.ClosingBonusInProzent__c != null && prov.ClosingBonusInProzent__c != 0) {
                    newProv.ClosingBonusInProzent__c = -prov.ClosingBonusInProzent__c;
                }

                if(prov.BeratungsprovisionMitPVInEuro__c != null && prov.BeratungsprovisionMitPVInEuro__c != 0) {
                    newProv.BeratungsprovisionMitPVInEuro__c = -prov.BeratungsprovisionMitPVInEuro__c;
                }

                if(prov.BeratungsprovisionMitPVInProzent__c != null && prov.BeratungsprovisionMitPVInProzent__c != 0) {
                    newProv.BeratungsprovisionMitPVInProzent__c = -prov.BeratungsprovisionMitPVInProzent__c;
                }

                if(prov.ProvisionsverzichtInProzent__c != null && prov.ProvisionsverzichtInProzent__c != 0) {
                    newProv.ProvisionsverzichtInProzent__c = -prov.ProvisionsverzichtInProzent__c;
                }

                if(prov.ProvisionsverzichtInEuro__c != null && prov.ProvisionsverzichtInEuro__c != 0) {
                    newProv.ProvisionsverzichtInEuro__c = -prov.ProvisionsverzichtInEuro__c;
                }

                if(prov.ErfolgsabhaengigeProvisionInProzent__c != null && prov.ErfolgsabhaengigeProvisionInProzent__c != 0) {
                    newProv.ErfolgsabhaengigeProvisionInProzent__c = -prov.ErfolgsabhaengigeProvisionInProzent__c;
                }

                if(prov.Erfolgsabh_ngige_Provision_direkt__c != null && prov.Erfolgsabh_ngige_Provision_direkt__c != 0) {
                    newProv.Erfolgsabh_ngige_Provision_direkt__c = -prov.Erfolgsabh_ngige_Provision_direkt__c;
                }
                
                insertProvs.add(newProv);
            }
        }

        if(!deleteProvs.isEmpty()) {
            delete deleteProvs;
        }

        if(!insertProvs.isEmpty()) {
            Schema.SObjectField provisionUniqueIdField = Provision__c.Fields.UniqueId__c;
            Database.upsert(insertProvs, provisionUniqueIdField, true);
        }
    }

    public void getRecipientsIds() {
        for(Opportunity opp:this.opps.values()) {
            Opportunity oldOpp = this.oldOpps?.get(opp.Id);
            Set<Id> currentRecipientsIds = this.recipientsIdsMap.get(opp.Id);
            if(currentRecipientsIds == null) {
                currentRecipientsIds = new Set<Id>();
            }
            Set<Id> currentOldRecipientsIds = this.oldRecipientsIdsMap.get(opp.Id);
            if(currentOldRecipientsIds == null) {
                currentOldRecipientsIds = new Set<Id>();
            }
            if(opp.Abrechnung_ber__c != null) {
                currentRecipientsIds.add(opp.Abrechnung_ber__c);
            } 
            if(opp.Makler__c != null) {
                currentRecipientsIds.add(opp.Makler__c);
            }
            if(opp.Maklerbetreuer_WirtschaftsHaus__c != null) {
                currentRecipientsIds.add(opp.Maklerbetreuer_WirtschaftsHaus__c);
            }
            if(opp.Immobilienberater__c != null) {
                currentRecipientsIds.add(opp.Immobilienberater__c);
            }
            if(opp.Overhead_Empf_nger__c != null) {
                currentRecipientsIds.add(opp.Overhead_Empf_nger__c);
            }
            if(opp.TippgeberProvisionEmpfaenger__c != null) {
                currentRecipientsIds.add(opp.TippgeberProvisionEmpfaenger__c);
            }
            if(opp.Vertriebskoordinator__c != null) {
                currentRecipientsIds.add(opp.Vertriebskoordinator__c);
            }
            if(opp.Provision_Thoben__c != '0' && opp.Provision_Thoben__c != null) {
                currentRecipientsIds.add('003b0000002p3N5');
            }
            if(oldOpp != null) {
                if(opp.Abrechnung_ber__c != oldOpp.Abrechnung_ber__c && oldOpp.Abrechnung_ber__c != null && oldOpp.Abrechnung_ber__c != opp.Makler__c && oldOpp.Abrechnung_ber__c != opp.Immobilienberater__c) {
                    currentOldRecipientsIds.add(oldOpp.Abrechnung_ber__c);
                }
                if(opp.Makler__c != oldOpp.Makler__c && oldOpp.Makler__c != null && oldOpp.Makler__c != opp.Immobilienberater__c && oldOpp.Makler__c != opp.Abrechnung_ber__c) {
                    currentOldRecipientsIds.add(oldOpp.Makler__c);
                }
                if(opp.Maklerbetreuer_WirtschaftsHaus__c != oldOpp.Maklerbetreuer_WirtschaftsHaus__c && oldOpp.Maklerbetreuer_WirtschaftsHaus__c != null) {
                    currentOldRecipientsIds.add(oldOpp.Maklerbetreuer_WirtschaftsHaus__c);
                }
                if(opp.Immobilienberater__c != oldOpp.Immobilienberater__c && oldOpp.Immobilienberater__c != null && oldOpp.Immobilienberater__c != opp.Makler__c && oldOpp.Immobilienberater__c != opp.Abrechnung_ber__c && oldOpp.Immobilienberater__c != opp.Maklerbetreuer_WirtschaftsHaus__c) {
                    currentOldRecipientsIds.add(oldOpp.Immobilienberater__c);
                }
                if(opp.Overhead_Empf_nger__c != oldOpp.Overhead_Empf_nger__c && oldOpp.Overhead_Empf_nger__c != null) {
                    currentOldRecipientsIds.add(oldOpp.Overhead_Empf_nger__c);
                }
                if(opp.TippgeberProvisionEmpfaenger__c != oldOpp.TippgeberProvisionEmpfaenger__c && oldOpp.TippgeberProvisionEmpfaenger__c != null) {
                    currentOldRecipientsIds.add(oldOpp.TippgeberProvisionEmpfaenger__c);
                }
            }
            this.recipientsIds.addAll(currentRecipientsIds);
            this.recipientsIdsMap.put(opp.Id, currentRecipientsIds);
            this.oldRecipientsIdsMap.put(opp.Id, currentOldRecipientsIds);
        }
    }

    public Integer getQuarterByMonth(Integer month) {
        return math.round((month+1)/3.0);
    }

    @TestVisible
    private void initializeProvisionModelConfigs(List<Opportunity> opportunities, List<Contact> contacts) {
        provisionModelsByPartnermanagerKey.clear();
        if (opportunities == null || opportunities.isEmpty()) {
            return;
        }

        Date minNotartermin;
        Date maxNotartermin;
        for (Opportunity opp : opportunities) {
            if (opp == null || opp.Notartermin__c == null) {
                continue;
            }
            if (minNotartermin == null || opp.Notartermin__c < minNotartermin) {
                minNotartermin = opp.Notartermin__c;
            }
            if (maxNotartermin == null || opp.Notartermin__c > maxNotartermin) {
                maxNotartermin = opp.Notartermin__c;
            }
        }

        if (minNotartermin == null || maxNotartermin == null) {
            return;
        }

        Set<Id> partnermanagerIds = new Set<Id>();
        if (contacts != null) {
            for (Contact con : contacts) {
                if (con != null && con.Id != null) {
                    partnermanagerIds.add(con.Id);
                }
            }
        }

        List<Provisionsmodell__c> models;
        if (partnermanagerIds.isEmpty()) {
            models = [
                SELECT
                    Id,
                    Name,
                    GueltigVon__c,
                    GueltigBis__c,
                    Partnermanager__c,
                    (
                        SELECT
                            Id,
                            Abrechnungsperiode__c,
                            StaffelVon__c,
                            StaffelBis__c,
                            ProvisionInProzent__c
                        FROM Provisionsstaffeln__r
                        ORDER BY Abrechnungsperiode__c, StaffelVon__c ASC
                    )
                FROM Provisionsmodell__c
                WHERE GueltigVon__c <= :maxNotartermin
                    AND (GueltigBis__c = null OR GueltigBis__c >= :minNotartermin)
                    AND Partnermanager__c = null
                ORDER BY GueltigVon__c DESC, LastModifiedDate DESC
            ];
        } else {
            models = [
                SELECT
                    Id,
                    Name,
                    GueltigVon__c,
                    GueltigBis__c,
                    Partnermanager__c,
                    (
                        SELECT
                            Id,
                            Abrechnungsperiode__c,
                            StaffelVon__c,
                            StaffelBis__c,
                            ProvisionInProzent__c
                        FROM Provisionsstaffeln__r
                        ORDER BY Abrechnungsperiode__c, StaffelVon__c ASC
                    )
                FROM Provisionsmodell__c
                WHERE GueltigVon__c <= :maxNotartermin
                    AND (GueltigBis__c = null OR GueltigBis__c >= :minNotartermin)
                    AND (Partnermanager__c = null OR Partnermanager__c IN :partnermanagerIds)
                ORDER BY Partnermanager__c, GueltigVon__c DESC, LastModifiedDate DESC
            ];
        }

        for (Provisionsmodell__c model : models) {
            String key = getProvisionModelMapKey(model.Partnermanager__c);
            List<Provisionsmodell__c> bucket = provisionModelsByPartnermanagerKey.get(key);
            if (bucket == null) {
                bucket = new List<Provisionsmodell__c>();
                provisionModelsByPartnermanagerKey.put(key, bucket);
            }
            bucket.add(model);
        }
    }

    @TestVisible
    private static String getProvisionModelMapKey(Id partnermanagerId) {
        return (partnermanagerId == null) ? DEFAULT_PROVISIONSMODELL_KEY : String.valueOf(partnermanagerId);
    }

    private Boolean isModelValidForDate(Provisionsmodell__c model, Date notartermin) {
        if (model == null || notartermin == null) {
            return false;
        }
        if (model.GueltigVon__c != null && model.GueltigVon__c > notartermin) {
            return false;
        }
        if (model.GueltigBis__c != null && model.GueltigBis__c < notartermin) {
            return false;
        }
        return true;
    }

    private Provisionsmodell__c findMatchingProvisionModel(Date notartermin, Id partnermanagerId) {
        if (notartermin == null) {
            return null;
        }

        List<Provisionsmodell__c> specificModels = provisionModelsByPartnermanagerKey.get(
            getProvisionModelMapKey(partnermanagerId)
        );
        if (specificModels != null) {
            for (Provisionsmodell__c model : specificModels) {
                if (isModelValidForDate(model, notartermin)) {
                    return model;
                }
            }
        }

        List<Provisionsmodell__c> defaultModels = provisionModelsByPartnermanagerKey.get(DEFAULT_PROVISIONSMODELL_KEY);
        if (defaultModels != null) {
            for (Provisionsmodell__c model : defaultModels) {
                if (isModelValidForDate(model, notartermin)) {
                    return model;
                }
            }
        }

        return null;
    }

    private Decimal getProvisionInProzentFromModel(
        Provisionsmodell__c model,
        String abrechnungsperiode,
        Decimal anzahlEinheiten
    ) {
        if (model == null || String.isBlank(abrechnungsperiode) || anzahlEinheiten == null) {
            return 0;
        }
        if (model.Provisionsstaffeln__r == null || model.Provisionsstaffeln__r.isEmpty()) {
            return 0;
        }

        Provisionsstaffel__c matchingStaffel;
        for (Provisionsstaffel__c staffel : model.Provisionsstaffeln__r) {
            if (staffel.Abrechnungsperiode__c != abrechnungsperiode) {
                continue;
            }

            Decimal staffelVon = (staffel.StaffelVon__c == null) ? 0 : staffel.StaffelVon__c;
            Decimal staffelBis = staffel.StaffelBis__c;
            Boolean inRange = anzahlEinheiten >= staffelVon && (staffelBis == null || anzahlEinheiten <= staffelBis);
            if (!inRange) {
                continue;
            }

            if (matchingStaffel == null || (staffel.StaffelVon__c != null && staffel.StaffelVon__c > matchingStaffel.StaffelVon__c)) {
                matchingStaffel = staffel;
            }
        }

        if (matchingStaffel == null || matchingStaffel.ProvisionInProzent__c == null) {
            return 0;
        }
        return matchingStaffel.ProvisionInProzent__c;
    }

    @TestVisible
    private Boolean isErfolgsabhaengigeProvisionDateInRange(Contact con, Date notartermin) {
        if (con == null || notartermin == null) {
            return false;
        }
        if (con.ErhaeltErfolgsabhaengigeProvisionVon__c != null && notartermin < con.ErhaeltErfolgsabhaengigeProvisionVon__c) {
            return false;
        }
        if (con.ErhaeltErfolgsabhaengigeProvisionBis__c != null && notartermin > con.ErhaeltErfolgsabhaengigeProvisionBis__c) {
            return false;
        }
        return true;
    }

    public Decimal getErfolgsabhaengigeProvision(Provision__c prov, Contact con, Date notartermin) {
        Decimal erfolgsabhaengigeProvision;
        Decimal erfolgsabhaengigeProvisionMonat = 0;
        Decimal erfolgsabhaengigeProvisionQuartal = 0;
        Decimal erfolgsabhaengigeProvisionJahr = 0;
        Decimal anzahlEinheitenMonat = prov.AnzahlEinheitenMonat__c;
        Decimal anzahlEinheitenQuartal = prov.AnzahlEinheitenQuartal__c;
        Decimal anzahlEinheitenJahr = prov.AnzahlEinheitenJahr__c;

        if (!isErfolgsabhaengigeProvisionDateInRange(con, notartermin)) {
            return null;
        }

        Provisionsmodell__c matchingModel = findMatchingProvisionModel(notartermin, con?.Id);
        if (matchingModel == null) {
            return null;
        }

        erfolgsabhaengigeProvisionMonat = getProvisionInProzentFromModel(
            matchingModel,
            ABRECHNUNGSPERIODE_MONAT,
            anzahlEinheitenMonat
        );

        Decimal quartalsProvisionKumuliert = getProvisionInProzentFromModel(
            matchingModel,
            ABRECHNUNGSPERIODE_QUARTAL,
            anzahlEinheitenQuartal
        );
        erfolgsabhaengigeProvisionQuartal = quartalsProvisionKumuliert - erfolgsabhaengigeProvisionMonat;
        if (erfolgsabhaengigeProvisionQuartal < 0) {
            erfolgsabhaengigeProvisionQuartal = 0;
        }

        Decimal jahresProvisionKumuliert = getProvisionInProzentFromModel(
            matchingModel,
            ABRECHNUNGSPERIODE_JAHR,
            anzahlEinheitenJahr
        );
        erfolgsabhaengigeProvisionJahr =
            jahresProvisionKumuliert - erfolgsabhaengigeProvisionMonat - erfolgsabhaengigeProvisionQuartal;
        if (erfolgsabhaengigeProvisionJahr < 0) {
            erfolgsabhaengigeProvisionJahr = 0;
        }

        if(con.ErfolgsabhaengigeMaxInProzent__c != null && (erfolgsabhaengigeProvisionMonat >= con.ErfolgsabhaengigeMaxInProzent__c)) {
            erfolgsabhaengigeProvisionMonat = con.ErfolgsabhaengigeMaxInProzent__c;
        }

        if(con.ErfolgsabhaengigeProvisionInEuro__c != null) {
            if (prov.Kaufpreis__c == null || prov.Kaufpreis__c == 0) {
                return null;
            }
            erfolgsabhaengigeProvisionMonat = con.ErfolgsabhaengigeProvisionInEuro__c / prov.Kaufpreis__c * 100;
        }

        if((con.ErfolgsabhaengigeMaxInProzent__c != null || con.ErfolgsabhaengigeProvisionInEuro__c != null) && (this.schedule == 'quarter' || this.schedule == 'year')) {
            return null;
        }
         
        if(this.schedule == 'month') {
            erfolgsabhaengigeProvision = erfolgsabhaengigeProvisionMonat / 100;
        } else if(this.schedule == 'quarter' && erfolgsabhaengigeProvisionQuartal > 0) {
            erfolgsabhaengigeProvision = erfolgsabhaengigeProvisionQuartal / 100;
        } else if(this.schedule == 'year' && erfolgsabhaengigeProvisionJahr > 0) {
            erfolgsabhaengigeProvision = erfolgsabhaengigeProvisionJahr / 100;
        }

        return erfolgsabhaengigeProvision;
    }
}