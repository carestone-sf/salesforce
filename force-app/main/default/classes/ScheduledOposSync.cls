global without sharing class ScheduledOposSync implements Schedulable {
    global static void execute(SchedulableContext sc){
        syncOposAndInvoices();
    }

    @future
    global static void syncOposAndInvoices() {
        DateTime dt = System.Now().addHours(-2);
        List<Document> oposDocuments = [SELECT Id, Body FROM Document WHERE Folder.Name = 'opos' AND CreatedDate >= :dt];
        syncOposAndInvoicesForDocuments(oposDocuments);
    }

    public static void syncOposAndInvoicesForDocuments(List<Document> oposDocuments) {
        List<MaBVRechnung__c> mabvRechnungen = [SELECT OffenerBetragNeu__c, Name FROM MaBVRechnung__c WHERE OffenerBetragNeu__c != 0 AND OffenerBetragNeu__c != null AND Storniert__c = FALSE];
        List<Gutschrift__c> gutschriften = [SELECT Bezahlt__c, Name FROM Gutschrift__c WHERE Bezahlt__c != TRUE AND ZuDatevUebertragen__c = TRUE AND GutschriftStorniert__c = FALSE];
        List<Opportunity> opps = [SELECT Id, Appartement__r.ApartmentNummer__c, Immobilie__r.Objektnummer__c FROM Opportunity WHERE StageName = 'Geschlossene und gewonnene' AND Immobilie__r.Objektnummer__c != null AND Appartement__r.ApartmentNummer__c != null];

        Map<String, List<Opos>> rechnungsNummerToOpos = new Map<String, List<Opos>>();     
        
        Integer i1;
        Integer i2;
        Integer i3;
        Integer i4;
        Integer i5;
        Integer i6;
        Integer i7;
        Integer i8;

        for(Document oposDocument:oposDocuments) {
            String csvString = oposDocument.Body.toString();
            Boolean skipRow = true;

            Utility_RowIterator rowIterator = new Utility_RowIterator(csvString, '\n');
            Iterator<String> iterator = rowIterator.iterator();
            while (iterator.hasNext()) {
                String row = iterator.next();

                if(skipRow) {
                    skipRow = false;
                    continue;
                }
                List<String> columns = row.split(';');
                String beleginfo1 = columns.get(20) != null ? columns[20] : '';
                String beleginfo2 = columns.get(22) != null ? columns[22] : '';
                String beleginfo3 = columns.get(24) != null ? columns[24] : '';
                Opos opos = new Opos(
                    columns[5], 
                    columns[6],
                    columns[2],
                    columns[8],
                    columns[10],
                    beleginfo1,
                    beleginfo2,
                    beleginfo3
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
                    zahlung.Betrag__c = opos.betrag;
                    zahlung.IBAN__c = opos.IBAN;
                    zahlung.AccountingText__c = opos.buchungstext;
                    zahlung.BusinessPartner__c = opos.businessPartner;
                    zahlung.BIC__c = opos.BIC;

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
                    zahlung.Betrag__c = opos.betrag;
                    zahlung.IBAN__c = opos.IBAN;
                    zahlung.AccountingText__c = opos.buchungstext;
                    zahlung.BusinessPartner__c = opos.businessPartner;
                    Zahlung.BIC__c = opos.BIC;

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
            Schema.SObjectField zahlungUniqueIdField = Zahlung__c.Fields.UniqueId__c;
            database.upsert(zahlungen, zahlungUniqueIdField, false);
        }

        if(updateGutschriften.size() > 0) {
            database.update(updateGutschriften);
        }

        if(vkcZahlungen.size() > 0) {
            Schema.SObjectField vkcZahlungUniqueIdField = VKCZahlung__c.Fields.UniqueId__c;
            database.upsert(vkcZahlungen, vkcZahlungUniqueIdField, false);
        }
    }
}