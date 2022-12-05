trigger Opportunity on Opportunity(before insert, before update, after insert, after update) {

    TriggerFactory.createHandler(Opportunity.getSObjectType());

    if (Trigger.isBefore) {
        if (trigger.isInsert || trigger.isUpdate) {
            //Liste für das Updaten der Appartments

            //todo MOVE TO THE OPP TRIGGER HANDLER
            if(trigger.isUpdate) {
                OpportunityTriggerHandler.sendEmailWhenReservationAccepted(trigger.newMap,trigger.oldMap);
            }
            for (Opportunity opp : trigger.new) {
                if (opp.Risikobelehrung__c == true && opp.Beratungsprotokoll__c == True && opp.KV_eingegangen__c == True && (opp.Nachweis_Barzahler__c == True || opp.Status_Finanzierung__c == 'Zusage liegt vor')) {
                    opp.Alle_Unterlagen_vorhanden__c = true;
                }

                if (Trigger.isUpdate) {
                    OpportunityTriggerHandler.sendEmailWhenReservationAccepted(trigger.newMap,trigger.oldMap);
                    // Calculate Rabatt
                    Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                    if (opp.Rabatt_in__c != oldOpp.Rabatt_in__c && opp.Maklerrabatt_in__c == oldOpp.Maklerrabatt_in__c && opp.Rabatt_in__c != null && opp.Rabatt_in__c != 0) {
                        opp.Maklerrabatt_in__c = (opp.Rabatt_in__c / 100) * opp.Kaufpreis__c;
                    } else if (opp.Rabatt_in__c != oldOpp.Rabatt_in__c && (opp.Rabatt_in__c == null || opp.Rabatt_in__c == 0)) {
                        opp.Maklerrabatt_in__c = 0;
                    }

                    if (opp.Maklerrabatt_in__c != oldOpp.Maklerrabatt_in__c && opp.Rabatt_in__c == oldOpp.Rabatt_in__c && opp.Maklerrabatt_in__c != null && opp.Maklerrabatt_in__c != 0) {
                        opp.Rabatt_in__c = (opp.Maklerrabatt_in__c / opp.Kaufpreis__c) * 100;
                    } else if (opp.Maklerrabatt_in__c != oldOpp.Maklerrabatt_in__c && (opp.Maklerrabatt_in__c == null || opp.Maklerrabatt_in__c == 0)) {
                        opp.Rabatt_in__c = 0;
                    }

                    if (opp.WH_Rabatt_in_P__c != oldOpp.WH_Rabatt_in_P__c && opp.WH_Rabatt_in__c == oldOpp.WH_Rabatt_in__c && opp.WH_Rabatt_in_P__c != null && opp.WH_Rabatt_in_P__c != 0) {
                        opp.WH_Rabatt_in__c = (opp.WH_Rabatt_in_P__c / 100) * opp.Kaufpreis__c;
                    } else if (opp.WH_Rabatt_in_P__c != oldOpp.WH_Rabatt_in_P__c && (opp.WH_Rabatt_in_P__c == null || opp.WH_Rabatt_in_P__c == 0)) {
                        opp.WH_Rabatt_in__c = 0;
                    }

                    if (opp.WH_Rabatt_in__c != oldOpp.WH_Rabatt_in__c && opp.WH_Rabatt_in_P__c == oldOpp.WH_Rabatt_in_P__c && opp.WH_Rabatt_in__c != null && opp.WH_Rabatt_in__c != 0) {
                        opp.WH_Rabatt_in_P__c = (opp.WH_Rabatt_in__c / opp.Kaufpreis__c) * 100;
                    } else if (opp.WH_Rabatt_in__c != oldOpp.WH_Rabatt_in__c && (opp.WH_Rabatt_in__c == null || opp.WH_Rabatt_in__c == 0)) {
                        opp.WH_Rabatt_in_P__c = 0;
                    }
                } else {
                    if (opp.Rabatt_in__c != null && opp.Rabatt_in__c != 0) {
                        opp.Maklerrabatt_in__c = (opp.Rabatt_in__c / 100) * opp.Kaufpreis__c;
                    }

                    if (opp.Maklerrabatt_in__c != null && opp.Maklerrabatt_in__c != 0) {
                        opp.Rabatt_in__c = (opp.Maklerrabatt_in__c / opp.Kaufpreis__c) * 100;
                    }

                    if (opp.WH_Rabatt_in_P__c != null && opp.WH_Rabatt_in_P__c != 0) {
                        opp.WH_Rabatt_in__c = (opp.WH_Rabatt_in_P__c / 100) * opp.Kaufpreis__c;
                    }

                    if (opp.WH_Rabatt_in__c != null && opp.WH_Rabatt_in__c != 0) {
                        opp.WH_Rabatt_in_P__c = (opp.WH_Rabatt_in__c / opp.Kaufpreis__c) * 100;
                    }
                }

                // Calculate Purchase price and Provisionsbasis
                Boolean rabattHasChanged = true;
                if (Trigger.isUpdate) {
                    Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                    if (opp.WH_Rabatt_in__c == oldOpp.WH_Rabatt_in__c && opp.WH_Rabatt_in_P__c == oldOpp.WH_Rabatt_in_P__c && opp.Maklerrabatt_in__c == oldOpp.Maklerrabatt_in__c && opp.Rabatt_in__c == oldOpp.Rabatt_in__c && opp.KfW__c == oldOpp.KfW__c) {
                        rabattHasChanged = false;
                    }
                }
                if (rabattHasChanged) {
                    Decimal listenpreis = opp.Kaufpreis__c;
                    Decimal beurkundeterKaufpreis = listenpreis;
                    Decimal provisionsbasis = listenpreis;
                    if (opp.Maklerrabatt_in__c != null) {
                        beurkundeterKaufpreis -= opp.Maklerrabatt_in__c;
                    }
                    if (opp.WH_Rabatt_in__c != null) {
                        beurkundeterKaufpreis -= opp.WH_Rabatt_in__c;
                        provisionsbasis -= opp.WH_Rabatt_in__c;
                    }
                    if (opp.KfW__c != null) {
                        beurkundeterKaufpreis += opp.KfW__c;
                    }
                    opp.beurkundeter_Kaufpreis__c = beurkundeterKaufpreis;
                    opp.Provisionsbasis__c = provisionsbasis;
                }

                if (Trigger.isInsert) {
                    opp.Letztes_Phasenupdate_am__c = System.today();
                    opp.Abrechnung_ber__c = opp.Abrechnung_ber_ID__c;
                } else if (Trigger.isUpdate) {
                    if (Trigger.oldMap.get(opp.id).StageName != opp.StageName) {
                        opp.Letztes_Phasenupdate_am__c = System.today();
                    }
                }

                Boolean stageNameHasChanged = false;
                if (Trigger.isUpdate) {
                    if (Trigger.oldMap.get(opp.Id).StageName != opp.StageName) {
                        stageNameHasChanged = true;
                    }
                }

                opp.Amount = opp.Kaufpreis__c;

                Boolean stageOrAppHasChanged = true;
                if (Trigger.isUpdate) {
                    if (Trigger.oldMap.get(opp.Id).StageName != opp.StageName || Trigger.oldMap.get(opp.Id).Appartement__c != opp.Appartement__c) {
                        stageOrAppHasChanged = true;
                    } else {
                        stageOrAppHasChanged = false;
                    }
                }


                if (opp.StageName == 'Reservierung angefragt' && stageNameHasChanged) {
                    opp.reserviert_bis__c = DateTime.now().addHours(84);
                    // Create an approval request for the opportunity
                    Approval.ProcessSubmitRequest req1 =
                            new Approval.ProcessSubmitRequest();
                    req1.setComments('Zur Genehmigung eingereicht');
                    req1.setObjectId(opp.id);

                    // Submit on behalf of a specific submitter
                    req1.setSubmitterId(System.Userinfo.getUserId());

                    // Submit the record to specific process and skip the criteria evaluation
                    req1.setProcessDefinitionNameOrId('Reservierung_angefragt');
                    req1.setSkipEntryCriteria(true);

                    // Submit the approval request for the account
                    Approval.ProcessResult result = Approval.process(req1);
                }

                if (opp.StageName == 'Reservierung angefragt' && stageOrAppHasChanged) {
                } else if (opp.StageName == 'Auftrag zur Beurkundung vorhanden' && stageOrAppHasChanged) {
                    if (opp.reserviert_bis__c != null) {
                        opp.reserviert_bis__c = null;
                    }
                } else if (opp.StageName == 'Reserviert' && stageOrAppHasChanged) {
                } else if (opp.StageName == 'Kaufvertragsangebot abgegeben' && stageOrAppHasChanged) {
                    if (opp.reserviert_bis__c != null) {
                        opp.reserviert_bis__c = null;
                    }
                } else if (opp.StageName == 'Kaufvertragsunterlagen verschickt' && stageOrAppHasChanged) {
                    if (opp.reserviert_bis__c != null) {
                        opp.reserviert_bis__c = null;
                    }

                } else if (opp.StageName == 'KV wird fremd abgegeben' && stageOrAppHasChanged) {
                    if (opp.reserviert_bis__c != null) {
                        opp.reserviert_bis__c = null;
                    }
                } else if (opp.StageName == 'Geschlossene und gewonnene' && stageOrAppHasChanged) {
                    if (opp.Grundprovision_Provisionsverhandlung__c == null && !opp.MaklerIstIntern__c) {
                        opp.Grundprovision_Provisionsverhandlung__c.addError('Für diesen Makler fehlt eine verhandelte Grundprovision für das Objekt. Bitte erstelle eine Provisionsverhandlung für das Objekt und versuche es erneut.');
                    }
                    if (opp.Verkaufsprovision_Provisionsverhandlung__c == null && !opp.ImmobilienberaterIstIntern__c) {
                        opp.Verkaufsprovision_Provisionsverhandlung__c.addError('Für diesen Makler fehlt eine verhandelte Verkaufsprovision für das Objekt. Bitte erstelle eine Provisionsverhandlung für das Objekt und versuche es erneut.');
                    }
                    opp.reserviert_bis__c = null;
                    if (opp.CloseDate > date.today()) {
                        opp.CloseDate = date.today();
                    }

                    if (!PermissionSetsHandler.hasPermissionSet()) {
                        opp.StageName.addError('Änderung nicht zulässig. Bitte wenden Sie sich an Ihren Systemadministrator');
                    }
                } else if (opp.StageName == 'Geschlossen und verloren') {
                    opp.reserviert_bis__c = null;
                }
                if (Trigger.isInsert) {
                    if (opp.reserviert_bis__c != null) {
                        opp.reserviert_bis__c = DateTimeHelper.checkAndSetDateTimeIfWeekend(opp.reserviert_bis__c);
                    }
                }
                if (Trigger.isUpdate) {
                    if (opp.StageName != Trigger.OldMap.get(opp.Id).StageName && Trigger.OldMap.get(opp.Id).StageName == 'Reservierung angefragt' && opp.StageName == 'VKC ausgelaufen') {
                        opp.Grund_VKC_verloren__c = 'VKC ausgelaufen';
                    }

                    if (opp.reserviert_bis__c != null && opp.reserviert_bis__c != Trigger.oldMap.get(opp.Id).reserviert_bis__c) {
                        opp.reserviert_bis__c = DateTimeHelper.checkAndSetDateTimeIfWeekend(opp.reserviert_bis__c);
                    }
                    Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                    if (opp.StageName == 'VKC ausgelaufen' || opp.StageName == 'Reservierung abgelehnt') {
                        opp.reserviert_bis__c = null;
                    }
                }

                // Calculate Kumulierte Provisionen
                // Checken, ob sich etwas an der Provisionsmatrix geändert hat
                Boolean provDataPercentageHasChanged = false;
                if(Trigger.isInsert) {
                    provDataPercentageHasChanged = true;
                } else if(Trigger.isUpdate) {
                    // Calculate Marketingzuschuss in Euro
                    Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                    if (opp.Marketingzuschuss__c != oldOpp.Marketingzuschuss__c && opp.MarketingzuschussInEuro__c == oldOpp.MarketingzuschussInEuro__c && opp.Marketingzuschuss__c != null && opp.Marketingzuschuss__c != 0) {
                        opp.MarketingzuschussInEuro__c = (opp.Marketingzuschuss__c / 100) * opp.Provisionsbasis__c;
                    } else if (opp.Marketingzuschuss__c != oldOpp.Marketingzuschuss__c && (opp.Marketingzuschuss__c == null || opp.Marketingzuschuss__c == 0)) {
                        opp.MarketingzuschussInEuro__c = 0;
                    }

                    if (opp.MarketingzuschussInEuro__c != oldOpp.MarketingzuschussInEuro__c && opp.Marketingzuschuss__c == oldOpp.Marketingzuschuss__c && opp.MarketingzuschussInEuro__c != null && opp.MarketingzuschussInEuro__c != 0) {
                        opp.Marketingzuschuss__c = (opp.MarketingzuschussInEuro__c / opp.Provisionsbasis__c) * 100;
                    } else if (opp.MarketingzuschussInEuro__c != oldOpp.MarketingzuschussInEuro__c && (opp.MarketingzuschussInEuro__c == null || opp.MarketingzuschussInEuro__c == 0)) {
                        opp.Marketingzuschuss__c = 0;
                    }

                    if(opp.ErfolgsabhaengigeProvision__c != oldOpp.ErfolgsabhaengigeProvision__c || opp.Verkaufsprovision_nach_Nachtrag__c != oldOpp.Verkaufsprovision_nach_Nachtrag__c || opp.Wert_Maklerprovision__c != oldOpp.Wert_Maklerprovision__c || opp.Wert_Overhead__c != oldOpp.Wert_Overhead__c || opp.Wert_Tippprovision__c != oldOpp.Wert_Tippprovision__c || opp.Abrechnung_ber__c != oldOpp.Abrechnung_ber__c || opp.Makler__c != oldOpp.Makler__c || opp.Immobilienberater__c != oldOpp.Immobilienberater__c || opp.Maklerbetreuer_Wirtschaftshaus__c != oldOpp.Maklerbetreuer_Wirtschaftshaus__c || opp.Rabatt_in__c != oldOpp.Rabatt_in__c || opp.WH_Rabatt_in_P__c != oldOpp.WH_Rabatt_in_P__c || opp.Provision_Thoben__c != oldOpp.Provision_Thoben__c || opp.Marketingzuschuss__c != oldOpp.Marketingzuschuss__c) {
                        provDataPercentageHasChanged = true;
                    }
                }

                // Wenn sich etwas an der Provisionsmatrix geändert hat, kumulierte Provisionen neu berechnen
                if(provDataPercentageHasChanged) {
                    Decimal provisionsbasis = opp.Provisionsbasis__c;
                    Decimal kaufpreis = opp.Kaufpreis__c;
                    // Externe Provision berechnen
                    Decimal provExtern = 0;

                    Opportunity oppWithFormulaFields = (Opportunity) recordsWithFormulaValues.get(opp.Id);
                    if(oppWithFormulaFields.Maklerprovision_nach_Nachtrag__c != null) {
                        provExtern += oppWithFormulaFields.Maklerprovision_nach_Nachtrag__c;
                    }
                    if(oppWithFormulaFields.Verkaufsprovision_nach_Nachtrag__c != null && oppWithFormulaFields.Verkaufsprovision_Makler__c != null) {
                        provExtern += oppWithFormulaFields.Verkaufsprovision_nach_Nachtrag__c;
                    }
                    if(opp.Marketingzuschuss__c != null) {
                        provExtern += opp.Marketingzuschuss__c;
                    }
                    if(!String.isBlank(opp.Overhead__c) && opp.Overhead__c != 'Keine') {
                        provExtern += Decimal.valueOf(opp.Overhead__c);
                    }
                    if(!String.isBlank(opp.Tippprovision__c) && opp.Tippprovision__c != 'Keine') {
                        provExtern += Decimal.valueOf(opp.Tippprovision__c);
                    }
//                    if(!String.isBlank(opp.Provision_Thoben__c)) {
//                        provExtern += Decimal.valueOf(opp.Provision_Thoben__c);
//                    }
                    if(opp.Rabatt_in__c != null && opp.Rabatt_in__c != 0) {
                        provExtern += opp.Rabatt_in__c;
                    }
                    opp.KumulierteProvisionExtern__c = provExtern;

                    if (opp.KumulierteProvisionExtern__c <= 7) {
                        opp.ErfolgsabhaengigeProvision__c = 0.5;
                    } else if (opp.KumulierteProvisionExtern__c > 7 && opp.KumulierteProvisionExtern__c <= 8) {
                        opp.ErfolgsabhaengigeProvision__c = 0.45;
                    } else if (opp.KumulierteProvisionExtern__c > 8 && opp.KumulierteProvisionExtern__c <= 9) {
                        opp.ErfolgsabhaengigeProvision__c = 0.35;
                    } else if (opp.KumulierteProvisionExtern__c > 9) {
                        opp.ErfolgsabhaengigeProvision__c = 0.25;
                    }

                    // Interne Provision berechnen
                    Decimal provIntern = 0;
                    if(opp.ErfolgsabhaengigeProvision__c != null) {
                        provIntern += opp.ErfolgsabhaengigeProvision__c;
                    }
                    if(oppWithFormulaFields.Verkaufsprovision_nach_Nachtrag__c != null && oppWithFormulaFields.Verkaufsprovision_intern__c != null) {
                        provIntern += oppWithFormulaFields.Verkaufsprovision_nach_Nachtrag__c/100;
                    }

                    // WH Provision
                    Decimal whRabatt = 0;
                    if(opp.WH_Rabatt_in_P__c != null && opp.WH_Rabatt_in_P__c != 0) {
                        whRabatt = opp.WH_Rabatt_in_P__c;
                    }

                    // Gesamt Provision berechnen
                    opp.KumulierteProvision__c = provIntern + provExtern + whRabatt;
                }
            }
        }

        Map<Id, Opportunity> changedOppsIntern = new Map<Id, Opportunity>();
        Map<Id, Opportunity> changedOppsInternOldMap = new Map<Id, Opportunity>();
        Map<Id, Opportunity> changedOppsAll = new Map<Id, Opportunity>();
        Map<Id, Opportunity> changedOppsAllOldMap = new Map<Id, Opportunity>();
        if(Trigger.isUpdate) {
            for(Opportunity opp:Trigger.new) {
                Opportunity oldOpp = Trigger.oldMap.get(opp.id);
                // Logic to check if commissions can be generated
                Boolean pvNotarTermin = opp.PVNotarterminStattgefunden__c ? opp.Notartermin__c != null : true;
                Boolean pvMaBV = opp.PV1MaBVRate__c ? opp.X1_MaBV_Rate_gezahlt__c : true;
                Boolean pvBeratungsprotokoll = opp.PVBeratungsprotokoll__c ? opp.Beratungsprotokoll__c : true;
                Boolean pvFbEkUrkundeMitFinanzierung = opp.PVFbEkUrkundeMitFinanzierung__c ? opp.Finanzierung_oder_Eigenkapitalnachweis__c || opp.Nachweis_Barzahler__c || opp.UrkundeMitFinanzierungLiegtVor__c : true;
                Boolean pvKaufpreiszahlung = opp.PVKaufpreiszahlung__c ? opp.Kaufpreis_bezahlt__c : true;
                Boolean pvOriginalKV = opp.PVOriginalKV__c ? opp.KV_eingegangen__c : true;
                Boolean pvRisikobelehrung = opp.PVRisikobelehrung__c ? opp.Risikobelehrung__c : true;
                Boolean kaufdatumEingetragen = opp.Kaufdatum__c != null;
                Boolean vkcGewonnen = opp.StageName == 'Geschlossene und gewonnene';

                if(pvNotarTermin && pvMaBV && pvBeratungsprotokoll && pvFbEkUrkundeMitFinanzierung && pvKaufpreiszahlung && pvOriginalKV && pvRisikobelehrung && kaufdatumEingetragen && !opp.ProvisionsvoraussetzungenErfuellt__c && vkcGewonnen) {
                    opp.ProvisionsvoraussetzungenErfuellt__c = true;
                }

                if(opp.InterneProvisionenNeuGenerieren__c || (opp.InterneProvisionenGeneriert__c == false && opp.StageName == 'Geschlossene und gewonnene' && oldOpp.StageName != 'Geschlossene und gewonnene')) {
                    opp.InterneProvisionenNeuGenerieren__c = false;
                    opp.InterneProvisionenGeneriert__c = true;
                    changedOppsIntern.put(opp.Id, opp);
                    changedOppsInternOldMap.put(opp.Id, Trigger.oldMap.get(opp.Id));
                }
                if(opp.ExterneProvisionenGeneriert__c == false && opp.ProvisionsvoraussetzungenErfuellt__c == true && oldOpp.ProvisionsvoraussetzungenErfuellt__c == false) {
                    opp.ExterneProvisionenGeneriert__c = true;
                    changedOppsAll.put(opp.Id, opp);
                    changedOppsAllOldMap.put(opp.Id, Trigger.oldMap.get(opp.Id));
                }
            }

        }
        
        if(!AdminSettings__c.getInstance(UserInfo.getUserId()).DisableProvisionGenerationAutomatism__c) {
            if(changedOppsIntern.size() > 0) {
                GenerateProvision gPro = new GenerateProvision();
                gPro.updateProvisionen(changedOppsIntern, changedOppsInternOldMap, 'intern');
            }

            if(changedOppsAll.size() > 0) {
                GenerateProvision gPro = new GenerateProvision();
                gPro.updateProvisionen(changedOppsAll, changedOppsAllOldMap, 'all');
            }
        }

        if(changedOppsIntern.size() > 0) {
            GenerateProvision gPro = new GenerateProvision();
            gPro.updateProvisionen(changedOppsIntern, changedOppsInternOldMap, 'intern');
        }

        if(changedOppsAll.size() > 0) {
            GenerateProvision gPro = new GenerateProvision();
            gPro.updateProvisionen(changedOppsAll, changedOppsAllOldMap, 'all');
        }
    }

    // After Trigger
    if (Trigger.isAfter) {
        //Liste für das Updaten der Appartments
        List < Appartment__c > appToUpdate = new List < Appartment__c > ();
        Map<Id, Opportunity> changedOppsAll = new Map<Id, Opportunity>();
        Map<Id, Opportunity> changedOppsAllOldMap = new Map<Id, Opportunity>();
        Map<Id, Opportunity> changedOppsIntern = new Map<Id, Opportunity>();
        Map<Id, Opportunity> changedOppsInternOldMap = new Map<Id, Opportunity>();
        List<Id> oppsWonCustomersIds = new List<Id>();

        for (Opportunity opp : Trigger.new) {
            Appartment__c apps = new Appartment__c(
                    id = opp.Appartement__c);


            Boolean stageHasChanged = true;
            if (Trigger.isUpdate) {
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                if (oldOpp.StageName != opp.StageName) {
                    stageHasChanged = true;
                } else {
                    stageHasChanged = false;
                }
            }

            Boolean stageOrAppHasChanged = true;
            if (Trigger.isUpdate) {
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                if (oldOpp.StageName != opp.StageName || oldOpp.Appartement__c != opp.Appartement__c) {
                    stageOrAppHasChanged = true;
                } else {
                    stageOrAppHasChanged = false;
                }

                if(opp.ProvisionsvoraussetzungenErfuellt__c == false && opp.InterneProvisionenGeneriert__c == true && opp.StageName == 'Geschlossene und gewonnene' && (opp.Wert_Verk_ufer_Beratungsprovision_m_R__c!= oldOpp.Wert_Verk_ufer_Beratungsprovision_m_R__c || opp.ErfolgsabhaengigeProvision__c != oldOpp.ErfolgsabhaengigeProvision__c)) {

                    changedOppsIntern.put(opp.Id, opp);
                    changedOppsInternOldMap.put(opp.Id, Trigger.oldMap.get(opp.Id));
                } else if (opp.ProvisionsvoraussetzungenErfuellt__c == true && opp.ExterneProvisionenGeneriert__c == true && (opp.ErfolgsabhaengigeProvision__c != oldOpp.ErfolgsabhaengigeProvision__c || opp.Wert_Verk_ufer_Beratungsprovision_m_R__c != oldOpp.Wert_Verk_ufer_Beratungsprovision_m_R__c || opp.KumulierteProvisionExtern__c != oldOpp.KumulierteProvisionExtern__c || opp.Abrechnung_ber__c != oldOpp.Abrechnung_ber__c || opp.Makler__c != oldOpp.Makler__c || opp.Immobilienberater__c != oldOpp.Immobilienberater__c || opp.Maklerbetreuer_WirtschaftsHaus__c != oldOpp.Maklerbetreuer_WirtschaftsHaus__c || opp.WH_Rabatt_in_P__c != oldOpp.WH_Rabatt_in_P__c || opp.Provision_Thoben__c != oldOpp.Provision_Thoben__c || opp.TippgeberProvisionEmpfaenger__c != oldOpp.TippgeberProvisionEmpfaenger__c || opp.Overhead_Empf_nger__c != oldOpp.Overhead_Empf_nger__c || opp.Marketingzuschuss__c != oldOpp.Marketingzuschuss__c || opp.AbrechnungUeberNurFuerGrundprovision__c != oldOpp.AbrechnungUeberNurFuerGrundprovision__c || opp.MarketingzuschussNichtAusweisen__c != oldOpp.MarketingzuschussNichtAusweisen__c)) {
                    changedOppsAll.put(opp.Id, opp);
                    changedOppsAllOldMap.put(opp.Id, Trigger.oldMap.get(opp.Id));
                }
            }

            /* MOVED TO OpportunityTriggerHandler
            if (Trigger.isInsert) {
                //Übertrag von Daten in das Appartment
                apps.Customer__c = opp.Potenzieller_Kunde__c;
                apps.Makler__c = opp.Makler__c;
                apps.Kaufpreis_gezahlt_am__c = opp.Datum_Kaufpreis_bezahlt__c;
                apps.Notartermin__c = opp.Notartermin__c;
                apps.Finanzierung__c = opp.Finanzierung__c;
                apps.Maklerbetreuer_WirtschaftsHaus_lookup__c = opp.Maklerbetreuer_WirtschaftsHaus__c;
                apps.Reserviert_bis__c = opp.reserviert_bis__c;
                apps.beurkundeter_Kaufpreis__c = opp.beurkundeter_Kaufpreis__c;
                apps.Provisionsbasis__c = opp.Provisionsbasis__c;
                apps.Beurkundung__c = opp.Beurkundung__c;
                apps.Kumulierte_Provision_extern__c = opp.KumulierteProvisionExtern__c;
                apps.KaufpreisFaellig__c = opp.Kaufpreis_f_llig__c;
                if(opp.Bezahlt__c != 0) {
                    apps.Bezahlt__c = opp.Bezahlt__c;
                }

            } else if (Trigger.isUpdate) {
                Appartment__c oldApps = new Appartment__c(id = Trigger.oldMap.get(opp.Id).Appartement__c);
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                if (oldApps != apps && oldApps != null) {
                    oldApps.Status__c = 'Available';
                    oldApps.Customer__c = null;
                    oldApps.Makler__c = null;
                    oldApps.MarkedForReservation__c = false;
                    oldApps.Kaufpreis_gezahlt_am__c = null;
                    oldApps.Notartermin__c = null;
                    oldApps.Finanzierung__c = null;
                    oldApps.Maklerbetreuer_Wirtschaftshaus__c = null;
                    oldApps.Maklerbetreuer_WirtschaftsHaus_lookup__c = null;
                    oldApps.Reserviert_bis__c = null;
                    oldApps.Beurkundung__c = opp.Beurkundung__c;
                    oldApps.beurkundeter_Kaufpreis__c = null;
                    oldApps.Provisionsbasis__c = null;
                    oldApps.Kumulierte_Provision_extern__c = null;
                    oldApps.Date_of_purchase__c = null;
                    oldApps.KaufpreisFaellig__c = false;
                    oldApps.Bezahlt__c = 0;
                    if (oldOpp.Appartement__c != null) {
                        appToUpdate.add(oldApps);
                    }
                    apps.beurkundeter_Kaufpreis__c = opp.beurkundeter_Kaufpreis__c;
                    apps.Provisionsbasis__c = opp.Provisionsbasis__c;
                    apps.Customer__c = opp.Potenzieller_Kunde__c;
                    apps.Makler__c = opp.Makler__c;
                    apps.Reserviert_bis__c = opp.reserviert_bis__c;
                    apps.Kaufpreis_gezahlt_am__c = opp.Datum_Kaufpreis_bezahlt__c;
                    apps.Notartermin__c = opp.Notartermin__c;
                    apps.Finanzierung__c = opp.Finanzierung__c;
                    apps.Maklerbetreuer_WirtschaftsHaus_lookup__c = opp.Maklerbetreuer_WirtschaftsHaus__c;
                    apps.Beurkundung__c = opp.Beurkundung__c;
                    apps.Kumulierte_Provision_extern__c = opp.KumulierteProvisionExtern__c;
                    apps.Date_of_purchase__c = opp.Kaufdatum__c;
                    apps.KaufpreisFaellig__c = opp.Kaufpreis_f_llig__c;
                    if(opp.Bezahlt__c != 0) {
                        apps.Bezahlt__c = opp.Bezahlt__c;
                    }
                } else if (opp.reserviert_bis__c != oldOpp.reserviert_bis__c || opp.Potenzieller_Kunde__c != oldOpp.Potenzieller_Kunde__c || opp.Makler__c != oldOpp.Makler__c || opp.Datum_Kaufpreis_bezahlt__c != oldOpp.Datum_Kaufpreis_bezahlt__c || opp.Notartermin__c != oldOpp.Notartermin__c || opp.Finanzierung__c != oldOpp.Finanzierung__c || opp.Maklerbetreuer_WirtschaftsHaus__c != oldOpp.Maklerbetreuer_WirtschaftsHaus__c || opp.StageName != oldOpp.StageName || opp.beurkundeter_Kaufpreis__c != oldOpp.beurkundeter_Kaufpreis__c || opp.Provisionsbasis__c != oldOpp.Provisionsbasis__c || opp.KumulierteProvisionExtern__c != oldOpp.KumulierteProvisionExtern__c || opp.Kaufdatum__c != oldOpp.Kaufdatum__c || opp.Bezahlt__c != oldOpp.Bezahlt__c) {
                    apps.beurkundeter_Kaufpreis__c = opp.beurkundeter_Kaufpreis__c;
                    apps.Provisionsbasis__c = opp.Provisionsbasis__c;
                    apps.Customer__c = opp.Potenzieller_Kunde__c;
                    apps.Makler__c = opp.Makler__c;
                    apps.Reserviert_bis__c = opp.reserviert_bis__c;
                    apps.Kaufpreis_gezahlt_am__c = opp.Datum_Kaufpreis_bezahlt__c;
                    apps.Notartermin__c = opp.Notartermin__c;
                    apps.Finanzierung__c = opp.Finanzierung__c;
                    apps.Maklerbetreuer_WirtschaftsHaus_lookup__c = opp.Maklerbetreuer_WirtschaftsHaus__c;
                    apps.Beurkundung__c = opp.Beurkundung__c;
                    apps.Kumulierte_Provision_extern__c = opp.KumulierteProvisionExtern__c;
                    apps.Date_of_Purchase__c = opp.Kaufdatum__c;
                    apps.KaufpreisFaellig__c = opp.Kaufpreis_f_llig__c;
                    if(opp.Bezahlt__c != 0) {
                        apps.Bezahlt__c = opp.Bezahlt__c;
                    }
                }
            }
            */


            if (opp.StageName == 'Reservierungsvorbereitung' && stageOrAppHasChanged) {
                apps.Status__c = 'Reservierungsvorbereitung';
            } else if (opp.StageName == 'Reservierung angefragt' && stageOrAppHasChanged) {
                apps.Status__c = 'Reservierung angefragt';
            } else if (opp.StageName == 'Reserviert' && stageOrAppHasChanged) {
                apps.Status__c = 'Reserved';
            } else if (opp.StageName == 'Kaufvertragsangebot abgegeben' && stageOrAppHasChanged) {
                apps.Status__c = 'Kaufvertragsangebot abgegeben';
            } else if (opp.StageName == 'Kaufvertragsunterlagen verschickt' && stageOrAppHasChanged) {

                apps.Status__c = 'Kaufvertragsunterlagen verschickt -zweiseitig-';

            } else if (opp.StageName == 'KV wird fremd abgegeben' && stageOrAppHasChanged) {

                apps.Status__c = 'KV wird fremd abgegeben';

            } else if (opp.StageName == 'Geschlossene und gewonnene' && stageOrAppHasChanged) {
                apps.Status__c = 'Sold';
            } else if (opp.StageName == 'Auftrag zur Beurkundung vorhanden' && stageOrAppHasChanged) {
                apps.Status__c = 'Auftrag zur Beurkundung vorhanden';
            } else if (opp.StageName == 'Kontingent' && stageOrAppHasChanged) {
                apps.Status__c = 'Kontingent';
            }

            if ((opp.StageName == 'VKC ausgelaufen' || opp.StageName == 'Reservierung abgelehnt' || opp.StageName == 'Geschlossen und verloren') && stageOrAppHasChanged) {
                apps.Status__c = 'Available';
                apps.Customer__c = null;
                apps.Makler__c = null;
                apps.Beurkundung__c = null;
                apps.MarkedForReservation__c = false;
                apps.Kaufpreis_gezahlt_am__c = null;
                apps.Notartermin__c = null;
                apps.Finanzierung__c = null;
                apps.Maklerbetreuer_WirtschaftsHaus_lookup__c = null;
                apps.beurkundeter_Kaufpreis__c = null;
                apps.Provisionsbasis__c = null;
                apps.KaufpreisFaellig__c = false;
                apps.Bezahlt__c = 0;
            }

            //Übertragen in die Liste zum Updaten, wenn das Feld no update nicht gesetzt ist
            if (Trigger.IsUpdate) {
                Opportunity oldOpp = Trigger.OldMap.get(opp.Id);
                if (apps != null && opp.Appartement__c != null && (opp.StageName != Trigger.OldMap.get(opp.Id).StageName || opp.reserviert_bis__c != oldOpp.reserviert_bis__c || opp.Potenzieller_Kunde__c != oldOpp.Potenzieller_Kunde__c || opp.Makler__c != oldOpp.Makler__c || opp.Datum_Kaufpreis_bezahlt__c != oldOpp.Datum_Kaufpreis_bezahlt__c || opp.Notartermin__c != oldOpp.Notartermin__c || opp.Finanzierung__c != oldOpp.Finanzierung__c || opp.Maklerbetreuer_WirtschaftsHaus__c != oldOpp.Maklerbetreuer_WirtschaftsHaus__c || opp.StageName != oldOpp.StageName || opp.beurkundeter_Kaufpreis__c != oldOpp.beurkundeter_Kaufpreis__c || opp.Provisionsbasis__c != oldOpp.Provisionsbasis__c || opp.KumulierteProvisionExtern__c != oldOpp.KumulierteProvisionExtern__c || opp.Appartement__c != oldOpp.Appartement__c || opp.Kaufdatum__c != oldOpp.Kaufdatum__c)) {
                    
                    appToUpdate.add(apps);
                } 
                if (opp.StageName != Trigger.OldMap.get(opp.Id).StageName && Trigger.OldMap.get(opp.Id).StageName == 'Reservierung angefragt' && opp.StageName == 'VKC ausgelaufen') {
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    req2.setComments('Automatisch ausgelaufen, da die Zeit abgelaufen ist.');
                    req2.setAction('Reject');
                    Id workItemId = getWorkItemId(opp.Id);
                    req2.setWorkitemId(workitemid);
                    Approval.process(req2);
                }
            } else if (apps != null && Trigger.IsInsert && opp.Appartement__c != null) {
                appToUpdate.add(apps);
            }

            // Logic to create list for "Datev Debitor Number Buyers"
            if (opp.StageName == 'Geschlossene und gewonnene' && stageHasChanged) {
                oppsWonCustomersIds.add(opp.Potenzieller_Kunde__c);
            }
        }

        if (!appToUpdate.isEmpty()) {
            for(Appartment__c app : appToUpdate) {
                System.debug('In Trigger: ' + app.Status__c);
            }
            update appToUpdate;
        }

        if(changedOppsIntern.size() > 0) {
            GenerateProvision gPro = new GenerateProvision();
            gPro.updateProvisionen(changedOppsIntern, changedOppsInternOldMap, 'intern');
        }

        if(changedOppsAll.size() > 0) {
            GenerateProvision gPro = new GenerateProvision();
            gPro.updateProvisionen(changedOppsAll, changedOppsAllOldMap, 'all');
        }

        if(oppsWonCustomersIds.size() > 0) {
            GenerateDatevDebitorNumberBuyers generateDatevDebitorNumberBuyers = new GenerateDatevDebitorNumberBuyers();
            generateDatevDebitorNumberBuyers.generateDatevDebitorNumberBuyers(oppsWonCustomersIds);
        }

        // Generate MaBVRechnungen
        if(Trigger.isUpdate) {
            List<Opportunity> generateMaBVRechnungenOpps = new List<Opportunity>();
            for(Opportunity opp:Trigger.new) {
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                if(opp.Kaufpreis_f_llig__c == true && oldOpp.Kaufpreis_f_llig__c != opp.Kaufpreis_f_llig__c && !opp.KeineMaBVRechnungGenerieren__c) {
                    generateMaBVRechnungenOpps.add(opp);
                }
                if(!opp.KeineMaBVRechnungGenerieren__c && opp.Abnahmeprotokoll__c == true && opp.Abnahmeprotokoll__c != oldOpp.Abnahmeprotokoll__c) {
                    generateMaBVRechnungenOpps.add(opp);
                }
            }
            MaBVRechnungMasterUtil.createMaBVRechnung(generateMaBVRechnungenOpps);
        }
    }

    public Id getWorkItemId(Id targetObjectId) {
        Id retVal = null;
        for (ProcessInstanceWorkitem workItem : [
                Select p.Id
                from ProcessInstanceWorkitem p
                where p.ProcessInstance.TargetObjectId = :targetObjectId
        ]) {
            retVal = workItem.Id;
        }
        return retVal;
    }

}
