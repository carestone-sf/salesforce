public without sharing class NebenkostenzuschussApprovalService {

    public static final String STAGE_BACKOFFICE = 'Backoffice';
    public static final String STAGE_CONTROLLING = 'Controlling';

    public static void processApprovals(List<NKZApproval__e> events) {
        Set<Id> nkzIds = new Set<Id>();
        for (NKZApproval__e evt : events) {
            if (evt.NebenkostenzuschussId__c != null && evt.Approved__c) {
                nkzIds.add(evt.NebenkostenzuschussId__c);
            }
        }

        if (nkzIds.isEmpty()) {
            return;
        }

        Map<Id, Nebenkostenzuschuss__c> nkzMap = new Map<Id, Nebenkostenzuschuss__c>([
            SELECT Id, GenehmigungBackoffice__c, GenehmigungControlling__c,
                   DatumGenehmigungBackoffice__c, DatumGenehmigungControlling__c,
                   BelegWurdeGeneriert__c, Storniert__c, Laufnummer_Zahl__c
            FROM Nebenkostenzuschuss__c
            WHERE Id IN :nkzIds
        ]);

        Map<Id, Nebenkostenzuschuss__c> toUpdateById = new Map<Id, Nebenkostenzuschuss__c>();

        for (NKZApproval__e evt : events) {
            if (!evt.Approved__c) {
                continue;
            }

            Nebenkostenzuschuss__c nkz = nkzMap.get(evt.NebenkostenzuschussId__c);
            if (nkz == null) {
                continue;
            }

            if (nkz.Storniert__c || nkz.BelegWurdeGeneriert__c) {
                continue;
            }

            if (evt.ApprovalStage__c == STAGE_BACKOFFICE && !nkz.GenehmigungBackoffice__c) {
                nkz.GenehmigungBackoffice__c = true;
                nkz.DatumGenehmigungBackoffice__c = Date.today();
                toUpdateById.put(nkz.Id, nkz);
            } else if (evt.ApprovalStage__c == STAGE_CONTROLLING
                       && nkz.GenehmigungBackoffice__c
                       && !nkz.GenehmigungControlling__c) {
                nkz.GenehmigungControlling__c = true;
                nkz.DatumGenehmigungControlling__c = Date.today();
                toUpdateById.put(nkz.Id, nkz);
            }
        }

        if (!toUpdateById.isEmpty()) {
            List<Nebenkostenzuschuss__c> toUpdate = toUpdateById.values();
            assignLaufnummern(toUpdate);
            update toUpdate;
        }
    }

    private static void assignLaufnummern(List<Nebenkostenzuschuss__c> records) {
        NKZ_Laufnummer__c setting = NKZ_Laufnummer__c.getOrgDefaults();
        if (setting == null) {
            setting = new NKZ_Laufnummer__c();
        }
        Decimal currentNummer = setting.NKZ_Laufnummer__c != null
            ? setting.NKZ_Laufnummer__c
            : 0;

        Boolean settingChanged = false;

        for (Nebenkostenzuschuss__c nkz : records) {
            if (nkz.GenehmigungBackoffice__c
                && nkz.GenehmigungControlling__c
                && nkz.Laufnummer_Zahl__c == null) {
                currentNummer++;
                nkz.Laufnummer_Zahl__c = currentNummer;
                nkz.BelegWurdeGeneriert__c = true;
                settingChanged = true;
            }
        }

        if (settingChanged) {
            setting.NKZ_Laufnummer__c = currentNummer;
            upsert setting;
        }
    }
}
