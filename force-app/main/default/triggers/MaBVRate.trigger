/**
 * Created by frederikwitte on 26.05.20.
 */

trigger MaBVRate on MaBVRate__c (after insert, after update, before insert, before update) {
    List<MaBVRate__c> maBVRatenFuerRechnung = new List<MaBVRate__c>();
    if(Trigger.isAfter) {
        if (Trigger.isUpdate) {
            for (MaBVRate__c maBVRate : Trigger.new) {
                MaBVRate__c oldMaBVRate = Trigger.oldMap.get(maBVRate.Id);
                if (maBVRate.Faelligkeitsdatum__c >= Date.Today() && oldMaBVRate.Faelligkeitsdatum__c >= Date.Today() && maBVRate.Faelligkeitsdatum__c != oldMaBVRate.Faelligkeitsdatum__c) {
                    maBVRatenFuerRechnung.add(maBVRate);
                }
            }
        }

        if (Trigger.isInsert) {
            for (MaBVRate__c maBVRate : Trigger.new) {
                if (maBVRate.Faelligkeitsdatum__c != null) {
                    maBVRatenFuerRechnung.add(maBVRate);
                }
            }
        }
    }

    // Generate MaBVRechnungen
    MaBVRechnungMasterUtil.createMaBVRechnung(maBVRatenFuerRechnung);
}