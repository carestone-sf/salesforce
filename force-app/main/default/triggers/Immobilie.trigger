trigger Immobilie on Property__c (before update, before insert, after update, after insert) {
    List<Appartment__c> appToUpdate = new List<Appartment__c>();
    Static Boolean syncedViaHauptimmobilieOnce = false;

    if(Trigger.isBefore) {

        if(Trigger.isInsert) {
            for(Property__c p:Trigger.new) {
                if(p.Hauptimmobilie__c == null) {
                    Hauptimmobilie__c h = new Hauptimmobilie__c();
                    h.Name = p.Name;
                    insert h;
                    p.Hauptimmobilie__c = h.Id;
                }
                p.DMSFolderId__c = p.Hauptimmobilie__c; 
            }
        }

    }

    if(Trigger.isAfter){

        if(Trigger.isUpdate){
            if(!syncedViaHauptimmobilieOnce) {
                List<Id> hauptimmobilieIds = new List<Id>();
                List<Property__c> updateProps = new List<Property__c>();
                for(Property__c p:Trigger.new) {
                    Property__c oldP = Trigger.oldMap.get(p.Id);
                    if(p.AktenstatusDms__c != oldP.AktenstatusDms__c && p.Hauptimmobilie__c != null) {
                        hauptimmobilieIds.add(p.Hauptimmobilie__c);
                    }
                }

                Map<Id, Property__c> propertyIdToPropertyMap = new Map<Id, Property__c>([SELECT Id, AktenstatusDms__c, Hauptimmobilie__c FROM Property__c WHERE Hauptimmobilie__c IN (SELECT Id FROM Hauptimmobilie__c WHERE Id IN :hauptimmobilieIds)]);
                for(Property__c p:propertyIdToPropertyMap.values()) { 
                    if(Trigger.newMap.get(p.Id) != null) {
                        propertyIdToPropertyMap.remove(p.Id);
                    }
                }

                for(Property__c p:Trigger.new) {
                    Property__c oldP = Trigger.oldMap.get(p.Id);
                    if(p.AktenstatusDms__c != oldP.AktenstatusDms__c && p.Hauptimmobilie__c != null) {
                        for(Property__c hP:propertyIdToPropertyMap.values()) {
                            if(hP.Hauptimmobilie__c == p.Hauptimmobilie__c) {
                                hP.AktenstatusDms__c = p.AktenstatusDms__c;
                                hP.DMSNichtUpdaten__c = true;
                                updateProps.add(hP);
                            }
                        }
                    }
                }

                if(updateProps.size() > 0) {
                    syncedViaHauptimmobilieOnce = true;
                    update updateProps;
                }
            }

            Set<id> propertyId = new Set<id>();

            for(Property__c propID : trigger.new){
                propertyId.add(propID.id);
            }

            Boolean somethingChanged = false;
            for(Property__c prop : trigger.new){

                Property__c propOlder = Trigger.OldMap.get(prop.id);
                if(propOlder.Afa_Outdoor__c != prop.Afa_Outdoor__c || propOlder.Repayment_Beginning__c != prop.Repayment_Beginning__c){
                	somethingChanged = true;
                }

            }
            List<Appartment__c> apps = new List<Appartment__c>();
            if(somethingChanged) {
            		apps = new List<Appartment__c>([SELECT Property__c, Repayment_Beginning__c, Outdoor_AFA__c FROM Appartment__c WHERE Property__c in :propertyId]);
            	}

            for(Property__c prop : trigger.new){

                Property__c propOlder = Trigger.OldMap.get(prop.id);

                for(Appartment__c app : apps){

                    if(propOlder.Afa_Outdoor__c != prop.Afa_Outdoor__c){
                        app.Outdoor_AFA__c = prop.Afa_Outdoor__c;
                    }
                    if(propOlder.Repayment_Beginning__c != prop.Repayment_Beginning__c){
                        app.Repayment_Beginning__c = prop.Repayment_Beginning__c;
                    }
                    appToUpdate.add(app);
                }

            }
            if(appToUpdate.size() > 0)
            		update appToUpdate;
        }

    }
}