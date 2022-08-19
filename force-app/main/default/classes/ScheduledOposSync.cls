global without sharing class ScheduledOposSync implements Schedulable {
    global static void execute(SchedulableContext sc){
        syncOposAndInvoices();
    }

    @future
    global static void syncOposAndInvoices() {
        List<MaBVRechnung__c> mabvRechnungen = [SELECT OffenerBetragNeu__c, Name FROM MaBVRechnung__c WHERE OffenerBetragNeu__c != 0 AND OffenerBetragNeu__c != null AND Storniert__c = FALSE];
        List<Gutschrift__c> gutschriften = [SELECT Bezahlt__c, Name FROM Gutschrift__c WHERE Bezahlt__c != TRUE AND ZuDatevUebertragen__c = TRUE AND GutschriftStorniert__c = FALSE];
        List<Opportunity> opps = [SELECT Id, Appartement__r.ApartmentNummer__c, Immobilie__r.Objektnummer__c FROM Opportunity WHERE StageName = 'Geschlossene und gewonnene' AND Immobilie__r.Objektnummer__c != null AND Appartement__r.ApartmentNummer__c != null];

        DateTime dt = System.Now().addHours(-2);
        List<Document> oposDocuments = [SELECT Id, Body FROM Document WHERE Folder.Name = 'opos' AND CreatedDate >= :dt];
        Map<String, List<Opos>> rechnungsNummerToOpos = new Map<String, List<Opos>>();
        String a;
        String b;
        String c;
        String d;
        String e;
        String f;
        String g;
        String h;
        String i;
        String j;
        String a2;
        String b2;
        String c2;
        String d2;
        String e2;
        String f2;
        String g2;
        String h2;
        String i2;
        String j2;
        

        for(Document oposDocument:oposDocuments) {
            String csvString = oposDocument.Body.toString();
            Boolean skipRow = true;
            for(String row:csvString.split('\n')) {
                if(skipRow) {
                    skipRow = false;
                    continue;
                }
                List<String> columns = row.split(';');
                Opos opos = new Opos(
                    columns[5], 
                    columns[6],
                    columns[2],
                    columns[8]
                );
                String rechnungsNummer = columns[3];
                if(rechnungsNummer.startsWith('"') && rechnungsNummer.endsWith('"')) {
                    rechnungsNummer = rechnungsNummer.substring(1, rechnungsNummer.length()-1);
                }

                List<Opos> oposList = rechnungsNummerToOpos.get(rechnungsNummer);
                if(oposList == null) {
                    oposList = new List<Opos>();
                }
                oposList.add(opos);
                rechnungsNummerToOpos.put(rechnungsNummer, oposList);
            }
        }

        List<Zahlung__c> zahlungen = new List<Zahlung__c>();
        for(MaBVRechnung__c mabvRechnung:mabvRechnungen) {
            List<Opos> oposList = rechnungsNummerToOpos.get(mabvRechnung.Name);
            if(oposList != null) {
                for(Opos opos:oposList) {
                    Decimal bereitsGezahlt = 0;
                    Zahlung__c zahlung = new Zahlung__c();
                    zahlung.MabvRechnung__c = mabvRechnung.Id;
                    zahlung.Zahldatum__c = opos.zahldatum;
                    zahlung.Betrag__c = opos.soll;

                    if(zahlung.Zahldatum__c != null) {
                        zahlung.UniqueId__c = zahlung.Zahldatum__c.year() + '-' + zahlung.Zahldatum__c.month() + '-' + zahlung.Zahldatum__c.day() + '-' + mabvRechnung.Id;
                    }
                    
                    if(opos.bsnr != null) {
                        zahlung.UniqueId__c += '-' + opos.bsnr;
                    }

                    if(zahlung.Betrag__c != null && zahlung.Betrag__c != 0) {
                        zahlungen.add(zahlung);
                    }
                }
            }
        }

        List<Gutschrift__c> updateGutschriften = new List<Gutschrift__c>();
        for(Gutschrift__c gutschrift:gutschriften) {
            List<Opos> oposList = rechnungsNummerToOpos.get(gutschrift.Name);
            if(oposList != null) {
                gutschrift.Bezahlt__c = true;
                gutschrift.Zahldatum__c = oposList.get(0).zahldatum;
                updateGutschriften.add(gutschrift);
            }
        }

        List<VkcZahlung__c> vkcZahlungen = new List<VkcZahlung__c>();
        for(Opportunity opp:opps) {
            String rechnungsNummer = opp.Immobilie__r.Objektnummer__c + '-' + opp.Appartement__r.ApartmentNummer__c;
            List<Opos> oposList = rechnungsNummerToOpos.get(rechnungsNummer);
            if(oposList != null) {
                for(Opos opos:oposList) {
                    Decimal bereitsGezahlt = 0;
                    VkcZahlung__c zahlung = new VkcZahlung__c();
                    zahlung.Verkaufschance__c = opp.Id;
                    zahlung.Zahldatum__c = opos.zahldatum;
                    zahlung.Betrag__c = opos.soll;

                    if(zahlung.Zahldatum__c != null) {
                        zahlung.UniqueId__c = zahlung.Zahldatum__c.year() + '-' + zahlung.Zahldatum__c.month() + '-' + zahlung.Zahldatum__c.day() + '-' + opp.Id;
                    }
                    
                    if(opos.bsnr != null) {
                        zahlung.UniqueId__c += '-' + opos.bsnr;
                    }

                    if(zahlung.Betrag__c != null && zahlung.Betrag__c != 0) {
                        vkcZahlungen.add(zahlung);
                    }
                }
            }
        }

        if(zahlungen.size() > 0) {
            database.insert(zahlungen, false);
        }

        if(updateGutschriften.size() > 0) {
            database.update(updateGutschriften);
        }

        if(vkcZahlungen.size() > 0) {
            database.insert(vkcZahlungen, false);
        }
    }

}