/**
 * Created by frederikwitte on 26.05.20.
 */

trigger MaBVRechnung on MaBVRechnung__c (before insert, before update, after insert, after update) {

    
    TriggerFactory.createHandler(MaBVRechnung__c.getSObjectType());

    if(Trigger.isBefore) {
        for(MaBVRechnung__c maBVRechnung: Trigger.new) {
            MaBVRechnung__c oldMaBVRechnung = new MaBVRechnung__c();
            if(Trigger.isUpdate) {
                oldMaBVRechnung = Trigger.oldMap.get(maBVRechnung.Id);
            }
        }
    }

    if(Trigger.isAfter) {
        List<MabvRechnung__c> updateMabvRechnungen = new List<MaBVRechnung__c>();
        List<Id> mabvRechnungIds = new List<Id>();
        List<Id> mabvStornoIds = new List<Id>();
        List<Id> mabvMahnungIds = new List<Id>();

        for(MaBVRechnung__c maBVRechnung: Trigger.new) {
            MaBVRechnung__c oldMaBVRechnung = new MaBVRechnung__c();
            if(Trigger.isUpdate) {
                oldMaBVRechnung = Trigger.oldMap.get(maBVRechnung.Id);
            }
            if((Trigger.isInsert && maBVRechnung.BenoetigtGenehmigung__c == false && maBVRechnung.RechnungWurdeGeneriert__c == false) 
                || (Trigger.isUpdate && mabvRechnung.BenoetigtGenehmigung__c == true && mabvRechnung.Genehmigt__c == true && oldMaBVRechnung.Genehmigt__c == false  && maBVRechnung.RechnungWurdeGeneriert__c == false)) {
                mabvRechnungIds.add(maBVRechnung.Id);
            }
            if(Trigger.isUpdate) {
                if(maBVRechnung.Storniert__c && maBVRechnung.Storniert__c != oldMaBVRechnung.Storniert__c  && maBVRechnung.StornoWurdeGeneriert__c == false) {
                    mabvStornoIds.add(maBVRechnung.Id);
                }

                if(mabvRechnung.MahnungGenerieren__c == true && oldMaBVRechnung.MahnungGenerieren__c == false) {
                    mabvMahnungIds.add(mabvRechnung.Id);
                }
            }
        }

        if(mabvRechnungIds.size() > 0) {
            MaBVRechnungenBatch mrb = new MaBVRechnungenBatch(mabvRechnungIds, false);
            Database.executeBatch(mrb, 50);
        }
        if(mabvStornoIds.size() > 0) {
            MaBVRechnungenBatch mrb = new MaBVRechnungenBatch(mabvStornoIds, true);
            Database.executeBatch(mrb, 50);
        }
        if(mabvMahnungIds.size() > 0) {
            MaBVMahnungenBatch mmb = new MaBVMahnungenBatch(mabvMahnungIds);
            Database.executeBatch(mmb, 50);
        }
    }

}