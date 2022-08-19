trigger ContentDocumentLink on ContentDocumentLink (after insert) {
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            Set<Id> recordIdsSet = new Set<Id>();
            for(ContentDocumentLink cdl:Trigger.new) {
                String sObjName = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
                if(sObjName != 'Finanzierungsanfrage__c') {
                    continue;
                }
                recordIdsSet.add(cdl.LinkedEntityId);
            }

            List<Id> recordIds = new List<Id>(recordIdsSet);
            Map<Id, Finanzierungsanfrage__c> fas = new Map<Id, Finanzierungsanfrage__c>([SELECT WelcheUnterlagenWerdenGefordert__c FROM Finanzierungsanfrage__c WHERE Id IN :recordIds]);
            Map<Id, List<ContentVersion>> recordIdToContentVersions = FinanzierungsanfrageController.getContentVersionsMap(recordIds);
            List<Finanzierungsanfrage__c> updateFas = new List<Finanzierungsanfrage__c>();
            for(Finanzierungsanfrage__c fa:fas.values()) {
                if(fa.WelcheUnterlagenWerdenGefordert__c != null) {
                    String[] requiredDocuments = fa.WelcheUnterlagenWerdenGefordert__c.split(';');
                    Integer count = 0;
                    Boolean allRequiredDocumentsPresent = false;
                    for(ContentVersion cv:recordIdToContentVersions.get(fa.Id)) {
                        if(requiredDocuments.indexOf(cv.Typ__c) > -1) {
                            count++;
                        }
                        if(count == requiredDocuments.size()) {
                            allRequiredDocumentsPresent = true;
                        }
                    }

                    if(allRequiredDocumentsPresent) {
                        fa.Phase__c = 'In Bearbeitung';
                        updateFas.add(fa);
                    }
                }
            }
            update updateFas;
        }
    }
}