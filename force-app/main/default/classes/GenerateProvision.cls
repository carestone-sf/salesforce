public without sharing class GenerateProvision {
    // Create two Lists for possible updates and deletes
    List<Provision__c> deleteProvs = new List<Provision__c>();
    List<Provision__c> updateProvs = new List<Provision__c>();
    String pageError = 'Für diesen Makler kann keine Provision erstellt werden, dieser Makler hat keinen Vertrag. Bitte überprüfen Sie die Provisionsmatrix, ob dieser Makler über jemanden anders abgerechnet wird.';

    public Provision__c insertProvision(Opportunity opp, Contact con) {
        Provision__c prov = new Provision__c();
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
        if(opp.Maklerbetreuer_WirtschaftsHaus__c == con.Id) {
            prov.Erfolgsabh_ngige_Provision_direkt__c = opp.WertErfolgsabhaengigeProvision__c;
        }
        if(opp.Immobilienberater__c == con.Id && (opp.Abrechnung_ber__c == null || opp.AbrechnungUeberNurFuerGrundprovision__c)) {
            prov.Wert_Verk_ufer_Beratungsprovision_m_R__c = opp.Wert_Verk_ufer_Beratungsprovision_m_R__c;
        } else if(opp.Immobilienberater__c == con.Id && con.Ist_Maklerbetreuer_WH__c) {
            prov.Wert_Verk_ufer_Beratungsprovision_m_R__c = opp.Wert_Verk_ufer_Beratungsprovision_m_R__c;
        }
        if(opp.Makler__c == con.Id && opp.Abrechnung_ber__c == null) {
            prov.Wert_Maklerprovision__c = opp.Wert_Maklerprovision__c;
            prov.WertMarketingzuschuss__c = opp.WertMarketingzuschuss__c;
        }
        if(opp.Abrechnung_ber__c == con.Id) {
            if(String.isBlank(opp.Verkaufsprovision_intern__c) && !opp.AbrechnungUeberNurFuerGrundprovision__c) {
                prov.Wert_Verk_ufer_Beratungsprovision_m_R__c = opp.Wert_Verk_ufer_Beratungsprovision_m_R__c;
            }
            prov.Wert_Maklerprovision__c = opp.Wert_Maklerprovision__c;
            prov.WertMarketingzuschuss__c = opp.WertMarketingzuschuss__c;
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

    public Provision__c updateProvision(Opportunity opp, Opportunity oldOpp, Provision__c prov, Contact con) {
        Id oldMakler = prov.Makler__c;
        prov.Objekt__c = opp.Immobilie__c;
        prov.Wohneinheit__c = opp.Appartement__c;
        prov.Kunde__c = opp.Potenzieller_Kunde__c;
        prov.Kaufpreis__c = opp.Provisionsbasis__c;
        prov.Maklerbetreuer__c = opp.OwnerId;
        prov.MarketingzuschussNichtAusweisen__c = opp.MarketingzuschussNichtAusweisen__c;
        prov.Makler__c = null;

        if(opp.Wert_Provision_Thoben__c == 0) {
            prov.Wert_Provision_Thoben__c = 0;
        }
        if(String.valueOf(oldMakler).indexOf('003b0000002p3N5') != -1) {
            prov.Wert_Provision_Thoben__c = opp.Wert_Provision_Thoben__c;
            if(prov.Makler__c == null) {
                prov.Makler__c = '003b0000002p3N5';
            }
        }

        if(opp.WertErfolgsabhaengigeProvision__c == 0) {
            prov.Erfolgsabh_ngige_Provision_direkt__c = 0;
        }
        if(opp.Maklerbetreuer_WirtschaftsHaus__c == oldMakler) {
            prov.Erfolgsabh_ngige_Provision_direkt__c = opp.WertErfolgsabhaengigeProvision__c;
            if(prov.Makler__c == null) {
                prov.Makler__c = opp.Maklerbetreuer_WirtschaftsHaus__c;
            }
        } else if(oldOpp.Maklerbetreuer_WirtschaftsHaus__c == oldMakler) {
            prov.Erfolgsabh_ngige_Provision_direkt__c = 0;
        }

        if(opp.Wert_Verk_ufer_Beratungsprovision_m_R__c == 0) {
            prov.Wert_Verk_ufer_Beratungsprovision_m_R__c = 0;
        }
        if(opp.Immobilienberater__c == oldMakler || (opp.Abrechnung_ber__c == oldMakler && !opp.AbrechnungUeberNurFuerGrundprovision__c)) {
            prov.Wert_Verk_ufer_Beratungsprovision_m_R__c = opp.Wert_Verk_ufer_Beratungsprovision_m_R__c;
            if(prov.Makler__c == null && opp.Abrechnung_ber__c != null && !con.Ist_Maklerbetreuer_WH__c && !opp.AbrechnungUeberNurFuerGrundprovision__c) {
                prov.Makler__c = opp.Abrechnung_ber__c;
            } else if(prov.Makler__c == null) {
                prov.Makler__c = opp.Immobilienberater__c;
            }
        } else if(oldOpp.Immobilienberater__c == oldMakler || (opp.Abrechnung_ber__c == oldMakler && opp.AbrechnungUeberNurFuerGrundprovision__c)) {
            prov.Wert_Verk_ufer_Beratungsprovision_m_R__c = 0;
        }

        if(opp.Wert_Maklerprovision__c == 0) {
            prov.Wert_Maklerprovision__c = 0;
        }
        
        if((!opp.AbrechnungUeberNurFuerGrundprovision__c && opp.Makler__c == oldMakler) || 
            (opp.AbrechnungUeberNurFuerGrundprovision__c && opp.Abrechnung_ber__c == null && opp.Makler__c == oldMakler) || 
            opp.Abrechnung_ber__c == oldMakler) {
            prov.Wert_Maklerprovision__c = opp.Wert_Maklerprovision__c;
            prov.WertMarketingzuschuss__c = opp.WertMarketingzuschuss__c;
            if(prov.Makler__c == null && opp.Abrechnung_ber__c == null) {
                prov.Makler__c = opp.Makler__c;
            } else if(prov.Makler__c == null) {
                prov.Makler__c = opp.Abrechnung_ber__c;
            }
        } else if(oldOpp.Makler__c == oldMakler) {
            prov.Wert_Maklerprovision__c = 0;
            prov.WertMarketingzuschuss__c = 0;
        }

        if(opp.Wert_Tippprovision__c == 0) {
            prov.Wert_Tippprovision__c = 0;
        }
        if(opp.TippgeberProvisionEmpfaenger__c == oldMakler) {
            prov.Wert_Tippprovision__c = opp.Wert_Tippprovision__c;
            if(prov.Makler__c == null) {
                prov.Makler__c = opp.TippgeberProvisionEmpfaenger__c;
            }
        } else if(oldOpp.TippgeberProvisionEmpfaenger__c == oldMakler) {
            prov.Wert_Tippprovision__c = 0;
        }

        if(opp.Wert_Overhead__c == 0) {
            prov.Wert_Overhead__c = 0;
        }
        if(opp.Overhead_Empf_nger__c == oldMakler) {
            prov.Wert_Overhead__c = opp.Wert_Overhead__c;
            if(prov.Makler__c == null) {
                prov.Makler__c = opp.Overhead_Empf_nger__c;
            }
        } else if(oldOpp.Overhead_Empf_nger__c == oldMakler) {
            prov.Wert_Overhead__c = 0;
        }

        return prov;
    }

    public void updateProvisionen(Map<Id, Opportunity> opps, Map<Id, Opportunity> oldOpps, String type) {
        // Only put in the Opportunities where something changed
        Map<Id, Opportunity> updateOpps = new Map<Id, Opportunity>();
        Map<Id, Opportunity> oldUpdateOpps = new Map<Id, Opportunity>();
        for(Opportunity opp: opps.values()) {
            Opportunity oldOpp = oldOpps.get(opp.Id);
            updateOpps.put(opp.Id, opp);
            oldUpdateOpps.put(oldOpp.Id, oldOpp);
        }
        opps = updateOpps;
        oldOpps = oldUpdateOpps;

        // Get all Provision__c records which are related to the passed in Opportunities
        Set<Id> oppIds = opps.keySet();
        List<Provision__c> provs = [SELECT Verkaufschance__c, Wert_Provision_Thoben__c, Makler__c, Provisionssatz__c, Objekt__c, Wohneinheit__c, Kunde__c, Ausl_ser__c, E_Mail__c, Kaufpreis__c, Erfolgsabh_ngige_Provision_direkt__c, Wert_Verk_ufer_Beratungsprovision_m_R__c, Wert_Sonstige_1__c, Wert_Sonstige_2__c, JMB_Beteiligung__c, Wert_Maklerprovision__c, Wert_Beteiligung_SMB_an_JMB__c, Wert_Differenzprovision__c, Maklerbetreuer__c, Wert_Tippprovision__c, Wert_Overhead__c, Wert_Referentenverg_tung__c, WertMarketingzuschuss__c FROM Provision__c WHERE Verkaufschance__c IN : oppIds];
        // Map the Provision__c records to a single Contact Id to a single Opportunity Id to use correct List in for loop
        Map<Id, Map<Id, List<Provision__c>>> oppToMaklerToProvMap = new Map<Id, Map<Id, List<Provision__c>>>();
        for(Opportunity opp:opps.values()) {
            Map<Id, List<Provision__c>> maklerToProvMap = new Map<Id, List<Provision__c>>();
            for(Provision__c prov:provs) {
                List<Provision__c> tempProvs = maklerToProvMap.get(prov.Makler__c);
                if (tempProvs == null) tempProvs = new List<Provision__c>();
                tempProvs.add(prov);
                maklerToProvMap.put(prov.Makler__c, tempProvs);
            }
            oppToMaklerToProvMap.put(opp.Id, maklerToProvMap);
        }

        // Get all the Contacts which are Makler__c in Provision__c from old and new Opportunities
        Set<Id> empfaengerIds = getEmpfaengerIds(opps.values());
        Map<Id,Contact> provEmpfaenger = new Map<Id, Contact>([SELECT Id, Gesch_ftsbeziehung__c, Ist_Maklerbetreuer_WH__c, Email, Maklerauftrag__c FROM Contact WHERE Id IN : empfaengerIds]);

        Set<Id> oldEmpfaengerIds = getEmpfaengerIds(oldOpps.values());

        Map<Id,Contact> alleEmpfaenger = new Map<Id, Contact>([SELECT Id, Gesch_ftsbeziehung__c, Ist_Maklerbetreuer_WH__c, Email, Maklerauftrag__c FROM Contact WHERE Id IN : oldEmpfaengerIds OR Id IN : empfaengerIds]);

        for(Opportunity opp: opps.values()) {
            List<Provision__c> deleteProvs = new List<Provision__c>();
            //String maklerprovision = opp.Maklerprovision__c;
            Opportunity oldOpp = oldOpps.get(opp.Id);
            for(Contact con:alleEmpfaenger.values()) {
                Provision__c prov = new Provision__c();
                // If there is a Provision__c record in our map,
                if(oppToMaklerToProvMap.get(opp.Id).get(con.Id) != null) {
                    for(Provision__c currProv: oppToMaklerToProvMap.get(opp.Id).get(con.Id)) {
                        prov = updateProvision(opp, oldOpp, currProv, con);
                    }
                } else if(type == 'intern' || !(oldOpp.Abrechnung_ber__c == null && opp.Abrechnung_ber__c != null)) {
                    prov = insertProvision(opp, con);
                }
                if(prov.Makler__c != null) {
                    prov.Ausl_ser__c = alleEmpfaenger.get(prov.Makler__c).Id;
                    prov.E_Mail__c = alleEmpfaenger.get(prov.Makler__c).Email;
                    if(type == 'all') {
                        updateProvs.add(prov);
                    } else if(type == 'intern' && con.Ist_Maklerbetreuer_WH__c) {
                        updateProvs.add(prov);
                    }
                }
            }
            Database.upsert(updateProvs);

            deleteProvs = [SELECT Id FROM Provision__c WHERE (Makler__c NOT IN : provEmpfaenger.keySet() AND Verkaufschance__c =: opp.Id) OR Provisionssumme__c = 0];
            delete deleteProvs;
        }
    }

    public Set<Id> getEmpfaengerIds(List<Opportunity> opps) {
        Set<Id> empfaengerIds = new Set<Id>();
        for(Opportunity opp:opps) {
            if(opp.Abrechnung_ber__c != null) {
                empfaengerIds.add(opp.Abrechnung_ber__c);
            } else if(opp.Makler__c != null) {
                empfaengerIds.add(opp.Makler__c);
            }
            if(opp.Maklerbetreuer_WirtschaftsHaus__c != null) {
                empfaengerIds.add(opp.Maklerbetreuer_WirtschaftsHaus__c);
            }
            if(opp.Immobilienberater__c != null) {
                empfaengerIds.add(opp.Immobilienberater__c);
            }
            if(opp.Overhead_Empf_nger__c != null) {
                empfaengerIds.add(opp.Overhead_Empf_nger__c);
            }
            if(opp.TippgeberProvisionEmpfaenger__c != null) {
                empfaengerIds.add(opp.TippgeberProvisionEmpfaenger__c);
            }
            if(opp.Provision_Thoben__c != '0' && opp.Provision_Thoben__c != null) {
                empfaengerIds.add('003b0000002p3N5');
            }
        }
        System.debug('Empfänger Ids: ' + empfaengerIds);
        return empfaengerIds;
    }

}