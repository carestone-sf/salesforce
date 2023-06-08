/**
 * Created by frederikwitte on 25.05.20.
 */

public with sharing class
MaBVRechnungMasterUtil {

    public static void createMaBVRechnung(List<Opportunity> opps) {
        if(opps.size() == 0) {
            return;
        }
        Set<Id> propertyIdsSet = new Set<Id>();
        for(Opportunity opp:opps) {
            propertyIdsSet.add(opp.Immobilie__c);
        }
        List<Id> propertyIds = new List<Id>(propertyIdsSet);
        List<MaBVRate__c> maBVRaten = [SELECT Faelligkeitsdatum__c, RateNummer__c, Immobilie__c FROM MaBVRate__c WHERE Immobilie__c IN :propertyIds AND Faelligkeitsdatum__c != NULL Order By RateNummer__c ASC];
        createMaBVRechnung(opps, maBVRaten);
    }

    public static void createMaBVRechnung(List<MaBVRate__c> maBVRaten) {
        if(maBVRaten.size() == 0) {
            return;
        }
        Set<Id> propertyIdsSet = new Set<Id>();
        for(MaBVRate__c maBVRate:maBVRaten) {
            propertyIdsSet.add(maBVRate.Immobilie__c);
        }
        List<Id> propertyIds = new List<Id>(propertyIdsSet);
        List<Opportunity> opps = [SELECT Id, Immobilie__c, Abnahmeprotokoll__c, OwnerId FROM Opportunity WHERE Kaufpreis_f_llig__c = TRUE AND Immobilie__c IN :propertyIds AND KeineMaBVRechnungGenerieren__c = FALSE];
        createMaBVRechnung(opps, maBVRaten);
    }

    public static void createMaBVRechnung(List<Opportunity> opps, List<MaBVRate__c> maBVRaten) {
        List<MaBVRechnungMaster__c> maBVRechnungenMaster = new List<MaBVRechnungMaster__c>();
        Map<Id, Map<Id, MaBVRechnungMaster__c>> oppToMaBVRateToMaBVRechnungMasterMap = getOppToMaBVRateToMaBVRechnungMasterMap(maBVRaten);

        for(Opportunity opp:opps) {
            for(MaBVRate__c maBVRate:maBVRaten) {
                if(maBVRate.Immobilie__c != opp.Immobilie__c) {
                    continue;
                }
                if(maBVRate.RateNummer__c == '7' && opp.Abnahmeprotokoll__c == false) {
                    continue;
                }
                MaBVRechnungMaster__c maBVRechnungMaster;
                if(oppToMaBVRateToMaBVRechnungMasterMap.get(opp.Id) != null && oppToMaBVRateToMaBVRechnungMasterMap.get(opp.Id).get(maBVRate.Id) != null) {
                    maBVRechnungMaster = oppToMaBVRateToMaBVRechnungMasterMap.get(opp.Id).get(maBVRate.Id);
                    maBVRechnungMaster.OwnerId = opp.OwnerId;
                    if(maBVRechnungMaster.Faelligkeitsdatum__c > Date.Today()) {
                        maBVRechnungMaster.Faelligkeitsdatum__c = maBVRate.Faelligkeitsdatum__c;
                        maBVRechnungenMaster.add(maBVRechnungMaster);
                    }
                } else {
                    maBVRechnungMaster = new MaBVRechnungMaster__c();
                    maBVRechnungMaster.OwnerId = opp.OwnerId;
                    maBVRechnungMaster.Opportunity__c = opp.Id;
                    maBVRechnungMaster.MaBVRate__c = maBVRate.Id;
                    maBVRechnungMaster.Faelligkeitsdatum__c = maBVRate.Faelligkeitsdatum__c;
                    maBVRechnungenMaster.add(maBVRechnungMaster);
                }
            }
        }

        if(maBVRechnungenMaster.size() > 0) {
            database.upsert(maBVRechnungenMaster);
        }
    }

    public static Map<Id, Map<Id, MaBVRechnungMaster__c>> getOppToMaBVRateToMaBVRechnungMasterMap(List<MaBVRate__c> maBVRaten) {
        List<Id> maBVRatenIds = new List<Id>();
        for(MaBVRate__c maBVRate:maBVRaten) {
            maBVRatenIds.add(maBVRate.Id);
        }
        List<MaBVRechnungMaster__c> maBVRechnungenMaster = [SELECT Id, Opportunity__c, MaBVRate__c, Faelligkeitsdatum__c FROM MaBVRechnungMaster__c WHERE MaBVRate__c IN :maBVRatenIds];
        Map<Id, Map<Id, MaBVRechnungMaster__c>> oppToMaBVRateToMaBVRechnungMasterMap = new Map<Id, Map<Id, MaBVRechnungMaster__c>>();

        for(MaBVRechnungMaster__c maBVRechnungMaster:maBVRechnungenMaster) {
            Id oppId = maBVRechnungMaster.Opportunity__c;
            Id maBVRateId = maBVRechnungMaster.MaBVRate__c;
            Map<Id, MaBVRechnungMaster__c> maBVRateToMaBVRechnungMasterMap = oppToMaBVRateToMaBVRechnungMasterMap.get(oppId);
            if(maBVRateToMaBVRechnungMasterMap == null) {
                maBVRateToMaBVRechnungMasterMap = new Map<Id, MaBVRechnungMaster__c>();
            }
            maBVRateToMaBVRechnungMasterMap.put(maBVRechnungMaster.MaBVRate__c, maBVRechnungMaster);
            oppToMaBVRateToMaBVRechnungMasterMap.put(oppId, maBVRateToMaBVRechnungMasterMap);
        }

        return oppToMaBVRateToMaBVRechnungMasterMap;

    }

}