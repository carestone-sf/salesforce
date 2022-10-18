
List<Opportunity> updateList = new List<Opportunity>();
for(Opportunity opp : [
    SELECT Id, Provisionsbasis__c, Kaufpreis__c, Maklerprovision_nach_Nachtrag__c,
    Verkaufsprovision_nach_Nachtrag__c, Marketingzuschuss__c, Overhead__c,
    Tippprovision__c, Rabatt_in__c, ErfolgsabhaengigeProvision__c, Verkaufsprovision_intern__c,
    Verkaufsprovision_Makler__c, WH_Rabatt_in_P__c, KumulierteProvisionExtern__c, StageName
    FROM Opportunity
    WHERE IsClosed = false AND KumulierteProvisionExtern__c = 1.5
]) {
    // Externe Provision berechnen
    Decimal provExtern = 0;
    if(opp.Maklerprovision_nach_Nachtrag__c != null) {
        provExtern += opp.Maklerprovision_nach_Nachtrag__c;
    }
    if(opp.Verkaufsprovision_nach_Nachtrag__c != null && opp.Verkaufsprovision_Makler__c != null) {
        provExtern += opp.Verkaufsprovision_nach_Nachtrag__c;
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

    if(opp.Rabatt_in__c != null && opp.Rabatt_in__c != 0) {
        provExtern += opp.Rabatt_in__c;
    }

    if(provExtern != opp.KumulierteProvisionExtern__c) {
        System.debug(opp.Id + ' ' + opp.StageName);
        System.debug(provExtern);
        System.debug(opp.KumulierteProvisionExtern__c);
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
        if(opp.Verkaufsprovision_nach_Nachtrag__c != null && opp.Verkaufsprovision_intern__c != null) {
            provIntern += opp.Verkaufsprovision_nach_Nachtrag__c/100;
        }

        // WH Provision
        Decimal whRabatt = 0;
        if(opp.WH_Rabatt_in_P__c != null && opp.WH_Rabatt_in_P__c != 0) {
            whRabatt = opp.WH_Rabatt_in_P__c;
        }

        // Gesamt Provision berechnen
        opp.KumulierteProvision__c = provIntern + provExtern + whRabatt;
        updateList.add(opp);
    }
}

System.debug(updateList.size());


