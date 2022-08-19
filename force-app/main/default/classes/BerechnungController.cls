public without sharing class BerechnungController {

    @AuraEnabled
    public static void insertBerechnungsApartments(List<BerechnungsApartment__c> berechnungsApartments) {
        Database.SaveResult[] results = Database.insert(berechnungsApartments);
    }

    @AuraEnabled 
    public static void insertFinanzierungsBausteine(List<Finanzierungsbaustein__c> finanzierungsBausteine) {
        Database.SaveResult[] results = Database.insert(finanzierungsBausteine);
    }

    @AuraEnabled
    public static void deleteBerechnungsApartments(List<Id> deletedIds) {
        delete [SELECT ID FROM BerechnungsApartment__c WHERE Id IN :deletedIds];
    }

     @AuraEnabled
     public static void insertBerechnungWithApartments(Id berechnungId, List<BerechnungsApartment__c> berechnungsApartments) {
         for(BerechnungsApartment__c ba:berechnungsApartments) {
             ba.Berechnung__c = berechnungId;
         }
         insert berechnungsApartments;
    }

    @AuraEnabled
    public static void deleteFinanzierungsBausteine(List<Id> deletedIds) {
        delete [SELECT ID FROM FinanzierungsBaustein__c WHERE Id IN :deletedIds];
    }

    @AuraEnabled(cacheable=true)
    public static Berechnung__c getBerechnung(Id recordId) {
        List<Berechnung__c> berechnungen = [SELECT Id, KreditSumme__c, Finanzierungsart__c, Hauptimmobilie__r.Repayment_Beginning__c, Hauptimmobilie__c, Hauptimmobilie__r.Name, Eigenkapital__c, Gesamtkosten__c, NebenkostenGesamt__c, ListenpreisGesamt__c, ErsterKaeufer__c, ZweiterKaeufer__c, Name, (SELECT Id, Name, Apartment__c, Apartment__r.Name, Listenpreis__c, Gesamtkosten__c, NebenkostenInEuro__c, Immobilie__c, Immobilie__r.Name FROM Berechnungs_Apartments__r ORDER BY Name ASC), (SELECT Id, Name, Art__c, Kreditsumme__c, TilgungInPercent__c, ZinsInPercent__c, TilgungProMonatInEuro__c, ZinsProMonatInEuro__c, IstEigenkapitalBaustein__c FROM Finanzierungsbausteine__r) FROM Berechnung__C WHERE Id =: recordId];
        if(berechnungen.size() == 1) {
            return berechnungen[0];
        }
        Berechnung__c berechnung = new Berechnung__c();
        return berechnung;
    }

    @AuraEnabled(cacheable=true)
    public static Finanzierungsbaustein__c getFinanzierungsbaustein(Id recordId) {
        List<Finanzierungsbaustein__c> finanzierungsbausteine = [SELECT Id, Name, Art__c, Berechnung__r.Kreditsumme__c, Berechnung__r.Gesamtkosten__c, Berechnung__r.Eigenkapital__c, Kreditsumme__c, TilgungInPercent__c, ZinsInPercent__c, TilgungProMonatInEuro__c, ZinsProMonatInEuro__c, Zinsfestschreibung__c, FesteLaufzeit__c, (SELECT Id, JahrDerAuszahlung__c, Betrag__c, Prozent__c, Name FROM Sondertilgungen__r) FROM Finanzierungsbaustein__c WHERE Id = :recordId];
        if(finanzierungsbausteine.size() >= 1) {
            return finanzierungsbausteine[0];
        }
        Finanzierungsbaustein__c finanzierungsbaustein = new Finanzierungsbaustein__c();
        return finanzierungsbaustein;
    }

    @AuraEnabled(Cacheable=true)
    public static Berechnung__c[] getBerechnungSave() {
        Id userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        Profile pf = [SELECT Name FROM Profile WHERE Id = :profileId];
        User usr = [SELECT ContactId, AccountId FROM User WHERE Id = :userId];
        Id conId = usr.ContactId;
        Id accId = usr.AccountId;
        List<Berechnung__c> berechnungen = new List<Berechnung__c>();
        if(conId == null) {
            
        } else if (pf.Name.contains('Manager')) {
            berechnungen = [
                SELECT Name, ErsterKaeufer__r.Name, ZweiterKaeufer__r.Name, Verkaufsraum__r.Name, createdDate, Id, (SELECT Name, Id FROM Berechnungs_Apartments__r)
                FROM Berechnung__c WHERE Makler__r.AccountId = :accId
            ];
        } else {
            berechnungen = [
                SELECT Name, ErsterKaeufer__r.Name, ZweiterKaeufer__r.Name, Verkaufsraum__r.Name, createdDate, Id, (SELECT Name, Id FROM Berechnungs_Apartments__r)
                FROM Berechnung__c WHERE Makler__c = :conId
            ];
        }

        return berechnungen;
    }

    @AuraEnabled(Cacheable=true)
    public static Berechnung__c[] getBerechnungSaveWithId(Id berechnungId) {
    List<Berechnung__c> berechnungSaveWithId = new List<Berechnung__c>();
        berechnungSaveWithId = [
            SELECT Id, (SELECT Name, Apartment__c FROM Berechnungs_Apartments__r)
            FROM Berechnung__c
            WHERE Id = :berechnungId
        ];
        return berechnungSaveWithId;
    }
}