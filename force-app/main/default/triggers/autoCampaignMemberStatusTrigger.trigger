Trigger autoCampaignMemberStatusTrigger on Campaign (before insert, after insert) {
    if(Trigger.isBefore)
    {
            Map < String, Campaign > campaigns = new Map < String, Campaign > ();

            for (Campaign c: [SELECT Name, Type, Id FROM Campaign WHERE Type = 'Oberkampagne']) {
                campaigns.put(c.Name, c);
            }
            List<Campaign> campaignsToInsert = new List<Campaign>();
        for(Campaign c:Trigger.new)
        {
            if(c.StartDate == NULL && c.EndDate == NULL && c.DateTime__c != NULL)
            {
                c.StartDate = Date.newInstance(c.DateTime__c.year(), c.DateTime__c.month(), c.DateTime__c.day());
                c.EndDate = Date.newInstance(c.DateTime__c.year(), c.DateTime__c.month(), c.DateTime__c.day());
            }
            if (c.Name.indexOf('Online - Sachwertveranstaltung') > -1 || c.Name.indexOf('Sachwertwebinare') > -1) {
                try {
                    c.Type = 'Online-Seminar';
                    c.ParentId = campaigns.get('Online-Sachwertveranstaltung').Id;
                } catch (Exception e) {
                }
            }else if (c.Name.indexOf('SWV') > -1 || c.Name.indexOf('Sachwertveranstaltung') > -1 || c.Name.indexOf('Beratungstag') > -1 || c.Name.indexOf('Sachwert-VA') > -1) {
                try {
                    c.Type = 'Sachwertveranstaltung';
                    c.ParentId = campaigns.get('Sachwertveranstaltung').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('Kundenveranstaltung') > -1 || c.Name.indexOf('Infoveranstaltung') > -1) {
                try {
                    c.Type = 'Kundenveranstaltung';
                    c.ParentId = campaigns.get('Kundenveranstaltung').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('Mediterraner Abend') > -1 || c.Name.indexOf('Mediterrane Abend') > -1) {
                try {
                    c.Type = 'Mediterraner Abend';
                    c.ParentId = campaigns.get('Mediterraner Abend').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('Maklerzirkel') > -1) {
                try {
                    c.Type = 'Maklerzirkel';
                    c.ParentId = campaigns.get('Maklerzirkel').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('Fünfklusiv') > -1 || c.Name.indexOf('Jahresauftakt 2016') > -1 || c.Name.indexOf('Objektvorstellung') > -1 || c.Name.indexOf('Beyreuther') > -1 || c.Name.indexOf('stornofreies Geschäft') > -1 || c.Name.indexOf('Vortrag') > -1) {
                try {
                    c.Type = 'Vertriebsevent/Aktionstag';
                    c.ParentId = campaigns.get('Vertriebsevent/Aktionstag').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('Intensivseminar') > -1 || c.Name.indexOf('Mitarbeiterschulung') > -1 || c.Name.indexOf('Profiverkaufstraining') > -1 || c.Name.indexOf('Verkaufsschulung') > -1 || c.Name.indexOf('Verkaufstraining') > -1 || c.Name.indexOf('Verkaufs-Workshop') > -1) {
                try {
                    c.Type = 'Seminar';
                    c.ParentId = campaigns.get('Maklerseminar').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('Grundlagenwebinar') > -1) {
                try {
                    c.Type = 'Online-Seminar';
                    c.ParentId = campaigns.get('Grundlagenwebinar').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('Online - Seminar') > -1 || c.Name.indexOf('Webinar "Kick Off') > -1 || c.Name.indexOf('Webinar "Objektvorstellung') > -1) {
                try {
                    c.Type = 'Online-Seminar';
                    c.ParentId = campaigns.get('Objektvorstellung').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('ASI 15+') > -1 || c.Name.indexOf('Webinar "Ausblick') > -1 || c.Name.indexOf('Webinar "Erfolg') > -1) {
                try {
                    c.Type = 'Online-Seminar';
                    c.ParentId = campaigns.get('Maklerwebinar').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('Endkunden') > -1 || c.Name.indexOf('Kapitalanlage mit dem demographischen Wandel') > -1) {
                try {
                    c.Type = 'Online-Seminar';
                    c.ParentId = campaigns.get('Endkundenwebinar').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('Webinar "Maklerportal') > -1 || c.Name.indexOf('Webinar Maklerportal') > -1 || c.Name.indexOf('Maklerportalschulung') > -1) {
                try {
                    c.Type = 'Online-Seminar';
                    c.ParentId = campaigns.get('Online-Maklerportalschulung').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('DKM') > -1) {
                try {
                    c.Type = 'Mese';
                    c.ParentId = campaigns.get('DKM').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('Roadshow') > -1) {
                try {
                    c.Type = 'Roadshow';
                    c.ParentId = campaigns.get('Roadshow').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('Sommerfest') > -1) {
                try {
                    c.Type = 'Fest/Feier';
                    c.ParentId = campaigns.get('Fest/Feier').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('Abnahme') > -1 || c.Name.indexOf('Übergabe') > -1) {
                try {
                    c.Type = 'Abnahme';
                    c.ParentId = campaigns.get('Abnahme').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('Besichtigung') > -1) {
                try {
                    c.Type = 'Besichtigung';
                    c.ParentId = campaigns.get('Besichtigung').Id;
                } catch (Exception e) {
                }
            } else if (c.Name.indexOf('Einzelberatung') > -1) {
                try {
                    c.Type = 'Beratungstage';
                    c.ParentId = campaigns.get('Beratungstage').Id;
                } catch (Exception e) {
                }
            }
        }
    }
    if(Trigger.isAfter)
    {
        List<CampaignMemberStatus> cms = new List<CampaignMemberStatus>();
        Set<Id> camps = new Set<Id>();
        List<CampaignMemberStatus> cms2Delete = new List<CampaignMemberStatus>();
        List<CampaignMemberStatus> cms2Insert = new List<CampaignMemberStatus>();

        for(Campaign camp : Trigger.new){
            camps.add(camp.Id);
            if(camp.Type == 'Werbung' || camp.Type == 'E-Mailing' || camp.Type == 'Post-Mailing' || camp.Type == 'Telemarketing' || camp.Type == 'Bannerwerbung' || camp.Type == 'PR Aktion' || camp.Type == 'Partner' || camp.Type == 'Weiterempfehlungsprogramm' || camp.Type == 'Andere')
            {
                CampaignMemberStatus cms1 = new CampaignMemberStatus(CampaignId = camp.Id, HasResponded=false,
                                                                     Label = 'Ohne', SortOrder = 3, isDefault = true);
                cms2Insert.add(cms1);

                CampaignMemberStatus cms2 = new CampaignMemberStatus(CampaignId = camp.Id, HasResponded=false,
                                                                     Label = 'Erhalten', SortOrder = 4);
                cms2Insert.add(cms2);

                CampaignMemberStatus cms3 = new CampaignMemberStatus(CampaignId = camp.Id, HasResponded=true,
                                                                     Label = 'Reagiert', SortOrder = 5);
                cms2Insert.add(cms3);
            }
            else
            {
                CampaignMemberStatus cms1 = new CampaignMemberStatus(CampaignId = camp.Id, HasResponded=false,
                                                                     Label = 'Ohne', SortOrder = 3, isDefault = true);
                cms2Insert.add(cms1);

                CampaignMemberStatus cms2 = new CampaignMemberStatus(CampaignId = camp.Id, HasResponded=false,
                                                                     Label = 'Eingeladen', SortOrder = 4);
                cms2Insert.add(cms2);

                CampaignMemberStatus cms3 = new CampaignMemberStatus(CampaignId = camp.Id, HasResponded=true,
                                                                     Label = 'Interessiert', SortOrder = 5);
                cms2Insert.add(cms3);

                CampaignMemberStatus cms4 = new CampaignMemberStatus(CampaignId = camp.Id, HasResponded=true,
                                                                     Label = 'Angemeldet', SortOrder = 6);
                cms2Insert.add(cms4);

                CampaignMemberStatus cms5 = new CampaignMemberStatus(CampaignId = camp.Id, HasResponded=true,
                                                                     Label = 'Teilgenommen', SortOrder = 7);
                cms2Insert.add(cms5);

                CampaignMemberStatus cms6 = new CampaignMemberStatus(CampaignId = camp.Id, HasResponded=false,
                                                                     Label = 'Abgesagt', SortOrder = 8);
                cms2Insert.add(cms6);

                CampaignMemberStatus cms7 = new CampaignMemberStatus(CampaignId = camp.Id, HasResponded=false,
                                                                     Label = 'Nicht erschienen', SortOrder = 9);
                cms2Insert.add(cms7);
            }
        }


        for(CampaignMemberStatus cm : [select Id, Label, CampaignId from CampaignMemberStatus where CampaignId IN :camps]) {
            if(cm.Label == 'Geantwortet') {
                cms2Delete.add(cm);
            }
            if(cm.Label == 'Gesendet') {
                cms2Delete.add(cm);
            }
        }


        insert cms2Insert;
        delete cms2Delete;
    }
}