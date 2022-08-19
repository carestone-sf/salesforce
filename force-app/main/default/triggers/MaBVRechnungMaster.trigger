/**
 * Created by frederikwitte on 26.05.20.
 */

trigger MaBVRechnungMaster on MaBVRechnungMaster__c (before insert, before update, after insert, after update) {

    if(Trigger.isBefore) {
        for(MaBVRechnungMaster__c maBVRechnungMaster: Trigger.new) {
            Boolean sendRechnung = false;
            if(Trigger.isUpdate) {
                MaBVRechnungMaster__c oldMaBVRechnungMaster = Trigger.oldMap.get(maBVRechnungMaster.Id);

                if(maBVRechnungMaster.Faelligkeitsdatum__c <= Date.today() && maBVRechnungMaster.Faelligkeitsdatum__c != oldMaBVRechnungMaster.Faelligkeitsdatum__c) {
                    maBVRechnungMaster.RechnungWurdeAusgeloest__c = true;
                }

                if (maBVRechnungMaster.RechnungWurdeAusgeloest__c && !oldMaBVRechnungMaster.RechnungWurdeAusgeloest__c) {
                    sendRechnung = true;
                    maBVRechnungMaster.RechnungWurdeStorniert__c = false;
                }

                if (maBVRechnungMaster.RechnungWurdeStorniert__c && !oldMaBVRechnungMaster.RechnungWurdeStorniert__c) {
                    maBVRechnungMaster.RechnungWurdeAusgeloest__c = false;
                }
            }
            if(Trigger.isInsert) {
                if(maBVRechnungMaster.Faelligkeitsdatum__c <= Date.today()) {
                    maBVRechnungMaster.RechnungWurdeAusgeloest__c = true;
                }

                if(maBVRechnungMaster.RechnungWurdeAusgeloest__c) {
                    sendRechnung = true;
                }
            }
            if(sendRechnung) {
                maBVRechnungMaster.Rechnungsdatum__c = Date.today();
            }
        }
    }

    if(Trigger.isAfter) {
        List<MaBVRechnung__c> neueMabvRechnungen = new List<MaBVRechnung__c>();
        List<Id> stornierteRechnungenIds = new List<Id>();
        for(MaBVRechnungMaster__c maBVRechnungMaster: Trigger.new) {
            Boolean sendRechnung = false;
            if(Trigger.isUpdate) {
                MaBVRechnungMaster__c oldMaBVRechnungMaster = Trigger.oldMap.get(maBVRechnungMaster.Id);

                if (maBVRechnungMaster.RechnungWurdeAusgeloest__c && !oldMaBVRechnungMaster.RechnungWurdeAusgeloest__c) {
                    sendRechnung = true;
                }

                if (maBVRechnungMaster.RechnungWurdeStorniert__c && !oldMaBVRechnungMaster.RechnungWurdeStorniert__c) {
                    stornierteRechnungenIds.add(maBVRechnungMaster.Id);
                }
            }
            if(Trigger.isInsert) {
                if(maBVRechnungMaster.RechnungWurdeAusgeloest__c) {
                    sendRechnung = true;
                }
            }
            if(sendRechnung) {
                neueMabvRechnungen.add(new MaBVRechnung__c(MaBVRechnungMaster__c = maBVRechnungMaster.Id));
            }
        }

        if(stornierteRechnungenIds.size() > 0) {
            List<MaBVRechnung__c> mabvRechnungenUpdate = new List<MaBVRechnung__c>();
            List<MaBVRechnung__c> mabvRechnungen = [SELECT DatumStorniert__c, Storniert__c, StornoLaufnummer__c, Name FROM MaBVRechnung__c WHERE MaBVRechnungMaster__c IN :stornierteRechnungenIds AND Storniert__c = FALSE];
            for(MaBVRechnung__c mabvRechnung:mabvRechnungen) {
                mabvRechnung.DatumStorniert__c = Date.today();
                mabvRechnung.Storniert__c = true;
                mabvRechnung.StornoLaufnummer__c = 'SB' + mabvRechnung.Name;
                mabvRechnungenUpdate.add(mabvRechnung);
            }
            update mabvRechnungenUpdate;
        }

        insert neueMabvRechnungen;
    }
}