trigger Provision on Provision__c (before update, before insert, after update, after delete, after undelete) {
    if(Trigger.isBefore) {
        Gutschrift_Laufnummer__c gutschriftLaufnummer = Gutschrift_Laufnummer__c.getOrgDefaults();
        Decimal gutschriftLaufnummerZahl = gutschriftLaufnummer.Gutschrift_Laufnummer__c;

        List<Gutschrift__c> gutschriftenInsert = new List<Gutschrift__c>();
        List<Gutschrift__c> gutschriftenUpdate = new List<Gutschrift__c>();
        List<Id> stornierteProvisionen = new List<Id>();
        Set<Id> accIdsSet = new Set<Id>();

        for(Provision__c provision: Trigger.new) {
            if(Trigger.isInsert) {
                provision.OwnerId = provision.Maklerbetreuer__c;
                accIdsSet.add(provision.AccountIdEmpfaenger__c);
            }

            if(Trigger.isUpdate) {
                Provision__c oldProvision = Trigger.oldMap.get(provision.Id);
                if (String.isNotBlank(provision.FehlendeGutschriftsdaten__c) && provision.Genehmigung__c && !oldProvision.Genehmigung__c) {
                    provision.addError(provision.FehlendeGutschriftsdaten__c);
                }

                Gutschrift__c gutschrift = new Gutschrift__c();
                gutschrift.NameProvision__c = provision.Name;
                gutschrift.Empfaenger__c = provision.Makler__c;
                gutschrift.Opportunity__c = provision.Verkaufschance__c;
                gutschrift.Provision__c = provision.Id;
                gutschrift.Gesetzliche_MwSt_auf_Provisionszahlung__c = provision.Gesetzliche_MwSt_auf_Provisionszahlung__c;
                gutschrift.Wert_Maklerprovision__c = provision.Wert_Maklerprovision__c;
                gutschrift.Wert_Overhead__c = provision.Wert_Overhead__c;
                gutschrift.Wert_Verkaufsprovision__c = provision.Wert_Verk_ufer_Beratungsprovision_m_R__c;
                gutschrift.Wert_Tippprovision__c = provision.Wert_Tippprovision__c;
                gutschrift.WertMarketingzuschuss__c = provision.WertMarketingzuschuss__c;
                gutschrift.Kaufpreis__c = provision.Kaufpreis__c;
                gutschrift.Kunde__c = provision.Kunde__c;
                gutschrift.Teilobjekt__c = provision.Wohneinheit__c;
                gutschrift.Objekt__c = provision.Objekt__c;
                gutschrift.MarketingzuschussNichtAusweisen__c = provision.MarketingzuschussNichtAusweisen__c;
                gutschrift.OwnerId = provision.Maklerbetreuer__c;

                if (provision.GutschriftBestaetigt__c && !oldProvision.GutschriftBestaetigt__c) {
                    gutschrift.DatumGutschriftBestaetigt__c = Date.today();
                    gutschrift.Laufnummer_Zahl__c = gutschriftLaufnummerZahl;
                    gutschrift.GutschriftStorniert__c = false;
                    gutschriftenInsert.add(gutschrift);

                    provision.GutschriftStorniert__c = false;
                    gutschriftLaufnummerZahl++;
                }

                if (provision.GutschriftStorniert__c && !oldProvision.GutschriftStorniert__c) {
                    provision.GutschriftBestaetigt__c = false;
                    provision.Genehmigung__c = false;
                    stornierteProvisionen.add(provision.Id);
                }
            }
        }

        if(gutschriftenInsert.size() > 0) {
            insert gutschriftenInsert;
        }
    
        if(accIdsSet.size() > 0) {
            List<Id> accIds = new List<Id>();
            accIds.addAll(accIdsSet);
            GenerateDatevCreditorNumbers generateDatevCreditorNumbers = new GenerateDatevCreditorNumbers();
            generateDatevCreditorNumbers.generateDatevCreditorNumbers(accIds);
        }
    
        if(stornierteProvisionen.size() > 0) {
            List<Gutschrift__c> gutschriften = [SELECT GutschriftStorniert__c FROM Gutschrift__c WHERE Provision__c IN :stornierteProvisionen AND GutschriftStorniert__c = false];
            for(Gutschrift__c gutschrift:gutschriften) {
                gutschrift.GutschriftStorniert__c = true;
    
                gutschriftenUpdate.add(gutschrift);
            }
    
            update gutschriftenUpdate;
        }
    
        if(gutschriftLaufnummerZahl != gutschriftLaufnummer.Gutschrift_Laufnummer__c) {
            gutschriftLaufnummer.Gutschrift_Laufnummer__c = gutschriftLaufnummerZahl;
            update gutschriftLaufnummer;
        }
    }

    if(Trigger.isAfter) { 
        Map<Id, Integer> newAnzahlBestaetigteProvisionOpps = new Map<Id, Integer>();
        if(Trigger.isUpdate) {
            for(Provision__c provision: Trigger.new) {
                Provision__c oldProvision = Trigger.oldMap.get(provision.Id);
                Integer count = newAnzahlBestaetigteProvisionOpps.get(provision.Verkaufschance__c);
                if(count == null) {
                    count = 0;
                }
                if (provision.GutschriftBestaetigt__c && !oldProvision.GutschriftBestaetigt__c) {
                    count++;
                    System.debug(count);
                } else if(!provision.GutschriftBestaetigt__c && oldProvision.GutschriftBestaetigt__c) {
                    count--;
                }
                newAnzahlBestaetigteProvisionOpps.put(provision.Verkaufschance__c, count);
            }
        }

        if(Trigger.isDelete) {
            for(Provision__c provision: Trigger.old) {
                Integer count = newAnzahlBestaetigteProvisionOpps.get(provision.Verkaufschance__c);
                if(count == null) {
                    count = 0;
                }
                if (provision.GutschriftBestaetigt__c) {
                    count--;
                } 
                newAnzahlBestaetigteProvisionOpps.put(provision.Verkaufschance__c, count);
            }
        }

        if(Trigger.isUndelete) {
            for(Provision__c provision: [SELECT Id, Verkaufschance__c, GutschriftBestaetigt__c FROM Provision__c WHERE Id IN :Trigger.newmap.keyset()]) {
                Integer count = newAnzahlBestaetigteProvisionOpps.get(provision.Verkaufschance__c);
                if(count == null) {
                    count = 0;
                }
                if (provision.GutschriftBestaetigt__c) {
                    count++;
                } 
                newAnzahlBestaetigteProvisionOpps.put(provision.Verkaufschance__c, count);
            }
        }

        if(newAnzahlBestaetigteProvisionOpps.keySet().size() > 0) {
            List<Opportunity> opps = [SELECT Id, AnzahlBestaetigteProvisionen__c FROM Opportunity WHERE Id IN :newAnzahlBestaetigteProvisionOpps.keySet()];
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp:opps) {
                Integer count = newAnzahlBestaetigteProvisionOpps.get(opp.Id);
                if(count != null && count != 0) {
                    if(opp.AnzahlBestaetigteProvisionen__c == null) {
                        opp.AnzahlBestaetigteProvisionen__c = count;
                    } else {
                        opp.AnzahlBestaetigteProvisionen__c += count;
                    }
                    updateOpps.add(opp);
                }
            }

            if(updateOpps.size() > 0) {
                update updateOpps;
            }
        }
    }
}