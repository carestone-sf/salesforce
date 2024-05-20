public without sharing class ProvisionService {

    List<Provision__c> provs = new List<Provision__c>();
    Set<String> deleteProvs = new Set<String>();
    Map<Id, Set<Id>> recipientsIdsMap = new Map<Id, Set<Id>>();
    Set<Id> recipientsIds = new Set<Id>();
    Map<Id, Set<Id>> oldRecipientsIdsMap = new Map<Id, Set<Id>>();
    Map<Id, Opportunity> opps;
    Map<Id, Opportunity> oldOpps;
    List<Opportunity> allOpps;
    Map<Id, Map<Integer, Integer>> mbToMonthOpps = new Map<Id, Map<Integer, Integer>>();
    Map<Id, Map<Integer, Integer>> mbToQuarterOpps = new Map<Id, Map<Integer, Integer>>();
    Map<Id, Map<Integer, Integer>> mbToYearOpps = new Map<Id, Map<Integer, Integer>>();
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
        getRecipientsIds();
        Map<Id,Contact> allRecipients = new Map<Id, Contact>([SELECT Id, Gesch_ftsbeziehung__c, ErhaeltErfolgsabhaengigeProvision__c, Ist_Maklerbetreuer_WH__c, Email, Maklerauftrag__c FROM Contact WHERE Id IN : this.recipientsIds]);
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
            Integer lastYearOrThisYear = todaysDate.year();
            if(thisMonth == 1 && todaysDate.day() <= 10) {
                lastMonth = 12;
                lastYearOrThisYear -= 1;
            }
            Integer lastQuarter = getQuarterByMonth(lastMonth);
            String query = 'SELECT Id, Notartermin__c, Maklerbetreuer_WirtschaftsHaus__c FROM Opportunity';
            if(this.schedule == 'month') {
                if(todaysDate.day() <= 10) {
                    query += ' WHERE ((CALENDAR_MONTH(Notartermin__c) = :lastMonth AND CALENDAR_YEAR(Notartermin__c) = :lastYearOrThisYear) OR (CALENDAR_YEAR(Notartermin__c) = :thisYear AND CALENDAR_MONTH(Notartermin__c) = :thisMonth))';
                } else if(todaysDate.day() > 10) {
                    query += ' WHERE CALENDAR_MONTH(Notartermin__c) = :thisMonth AND CALENDAR_YEAR(Notartermin__c) = :thisYear';
                }
            } else if(this.schedule == 'quarter') {
                query += ' WHERE CALENDAR_QUARTER(Notartermin__c) = :lastQuarter AND (CALENDAR_YEAR(Notartermin__c) = :thisYear OR CALENDAR_YEAR(Notartermin__c) = :lastYearOrThisYear)';
            } else if(this.schedule == 'year') {
                query += ' WHERE CALENDAR_YEAR(Notartermin__c) = :lastYearOrThisYear';
            }

            query += ' AND StageName = \'Geschlossene und gewonnene\'';
            
            List<Opportunity> allOpps = (List<Opportunity>)Database.query(query);
            for(Opportunity opp:allOpps) {
                Integer monthOpp = opp.Notartermin__c.month();
                Map<Integer, Integer> monthOpps = mbToMonthOpps.get(opp.Maklerbetreuer_WirtschaftsHaus__c);
                if(monthOpps == null) {
                    monthOpps = new Map<Integer, Integer>();
                }
                Integer countMonthOpps = monthOpps.get(monthOpp);
                if(countMonthOpps == null) {
                    countMonthOpps = 0;
                }
                countMonthOpps++;
                monthOpps.put(monthOpp, countMonthOpps);
                mbToMonthOpps.put(opp.Maklerbetreuer_WirtschaftsHaus__c, monthOpps);
                
                Integer quarterOpp = getQuarterByMonth(monthOpp);
                Map<Integer, Integer> quarterOpps = mbToQuarterOpps.get(opp.Maklerbetreuer_WirtschaftsHaus__c);
                if(quarterOpps == null) {
                    quarterOpps = new Map<Integer, Integer>();
                }
                Integer countQuarterOpps = quarterOpps.get(quarterOpp);
                if(countQuarterOpps == null) {
                    countQuarterOpps = 0;
                }
                countQuarterOpps++;
                quarterOpps.put(quarterOpp, countQuarterOpps);
                mbToQuarterOpps.put(opp.Maklerbetreuer_WirtschaftsHaus__c, quarterOpps);

                Integer yearOpp = opp.Notartermin__c.year();
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
                if(mode == 'intern' && con.ErhaeltErfolgsabhaengigeProvision__c == true ) {
                    prov = this.getProvisionIntern(opp, con);
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

        if(con.Gesch_ftsbeziehung__c != null) {
            if((con.Maklerauftrag__c == 'Maklerauftrag beidseitig unterzeichnet' || con.Maklerauftrag__c == 'Makler mit altem Vertrag') && !con.Ist_Maklerbetreuer_WH__c && !con.Gesch_ftsbeziehung__c.contains('Interessent') && !con.Gesch_ftsbeziehung__c.contains('Kunde')) {
                prov.Eingereicht_Check__c = true;
            } else if (((con.Maklerauftrag__c != 'Maklerauftrag beidseitig unterzeichnet' || con.Maklerauftrag__c != 'Makler mit altem Vertrag') && !con.Ist_Maklerbetreuer_WH__c && opp.Abrechnung_ber__c == null)) {
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
        if(this.schedule == 'month') {
            prov.ProvisionsvoraussetzungenErfuelltAm__c = opp.Notartermin__c;
        } else if(this.schedule == 'quarter') {
            prov.ProvisionsvoraussetzungenErfuelltAm__c = Date.newInstance(yearOpp, quarterOpp*3, 30);
        } else if(this.schedule == 'year') {
            prov.ProvisionsvoraussetzungenErfuelltAm__c = Date.newInstance(yearOpp, 12, 30);
        }
        
        prov.AnzahlEinheitenMonat__c = mbToMonthOpps.get(opp.Maklerbetreuer_WirtschaftsHaus__c)?.get(monthOpp);
        prov.Provisionszeitraum__c = 'Monat';
        if(schedule == 'quarter' || schedule == 'year') { 
            prov.AnzahlEinheitenQuartal__c = mbToQuarterOpps.get(opp.Maklerbetreuer_WirtschaftsHaus__c)?.get(quarterOpp);
            prov.Provisionszeitraum__c = 'Quartal';
        }
        if(schedule == 'year') {
            prov.AnzahlEinheitenJahr__c = mbToYearOpps.get(opp.Maklerbetreuer_WirtschaftsHaus__c)?.get(yearOpp);
            prov.Provisionszeitraum__c = 'Jahr';
        }

        if(opp.Maklerbetreuer_WirtschaftsHaus__c == con.Id) {
            Decimal erfolgsabhaengigeProvision = getErfolgsabhaengigeProvision(prov);
            if(erfolgsabhaengigeProvision == null) {
                return null;
            }
            prov.ErfolgsabhaengigeProvisionInProzent__c = erfolgsabhaengigeProvision*100;
            prov.Erfolgsabh_ngige_Provision_direkt__c = erfolgsabhaengigeProvision * opp.Provisionsbasis__c;
        }
        
        return prov;
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

    public Decimal getErfolgsabhaengigeProvision(Provision__c prov) {
        Decimal erfolgsabhaengigeProvision;
        Decimal erfolgsabhaengigeProvisionMonat = 0;
        Decimal erfolgsabhaengigeProvisionQuartal = 0;
        Decimal erfolgsabhaengigeProvisionJahr = 0;
        Decimal anzahlEinheitenMonat = prov.AnzahlEinheitenMonat__c;
        Decimal anzahlEinheitenQuartal = prov.AnzahlEinheitenQuartal__c;
        Decimal anzahlEinheitenJahr = prov.AnzahlEinheitenJahr__c;
        
        if(anzahlEinheitenMonat >= 0 && anzahlEinheitenMonat <= 3) {
            erfolgsabhaengigeProvisionMonat = 0.25;
        } else if(anzahlEinheitenMonat >= 4 && anzahlEinheitenMonat <= 6) {
            erfolgsabhaengigeProvisionMonat = 0.35;
        } else if(anzahlEinheitenMonat >= 7 && anzahlEinheitenMonat <= 8) {
            erfolgsabhaengigeProvisionMonat = 0.45;
        } else if(anzahlEinheitenMonat >= 9) {
            erfolgsabhaengigeProvisionMonat = 0.5;
        }

        if(anzahlEinheitenQuartal >= 0 && anzahlEinheitenQuartal <= 11) {
            erfolgsabhaengigeProvisionQuartal = 0.25 - erfolgsabhaengigeProvisionMonat;
        } else if(anzahlEinheitenQuartal >= 12 && anzahlEinheitenQuartal <= 20) {
            erfolgsabhaengigeProvisionQuartal = 0.35 - erfolgsabhaengigeProvisionMonat;
        } else if(anzahlEinheitenQuartal >= 21 && anzahlEinheitenQuartal <= 26) {
            erfolgsabhaengigeProvisionQuartal = 0.45 - erfolgsabhaengigeProvisionMonat;
        } else if(anzahlEinheitenQuartal >= 27) {
            erfolgsabhaengigeProvisionQuartal = 0.5 - erfolgsabhaengigeProvisionMonat;
        }

        if(anzahlEinheitenJahr >= 0 && anzahlEinheitenJahr <= 47) {
            erfolgsabhaengigeProvisionJahr = 0.25 - erfolgsabhaengigeProvisionMonat - erfolgsabhaengigeProvisionQuartal;
        } else if(anzahlEinheitenJahr >= 48 && anzahlEinheitenJahr <= 83) {
            erfolgsabhaengigeProvisionJahr = 0.35 - erfolgsabhaengigeProvisionMonat - erfolgsabhaengigeProvisionQuartal;
        } else if(anzahlEinheitenJahr >= 84 && anzahlEinheitenJahr <= 107) {
            erfolgsabhaengigeProvisionJahr = 0.45 - erfolgsabhaengigeProvisionMonat - erfolgsabhaengigeProvisionQuartal;
        } else if(anzahlEinheitenJahr >= 108) {
            erfolgsabhaengigeProvisionJahr = 0.5 - erfolgsabhaengigeProvisionMonat - erfolgsabhaengigeProvisionQuartal;
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