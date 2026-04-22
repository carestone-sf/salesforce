public with sharing class AccountService {
    public static void updateAccountScore(List<Id> accountIds) {
        if (accountIds.isEmpty()) return;

        Map<Id, Account> accountMap = new Map<Id, Account>([
            SELECT Id, Rechtsform__c, FacebookUrl__c, InstagramUrl__c, LinkedInUrl__c, XingUrl__c,
                   TrustpilotUrl__c, GoogleMyBusinessUrl__c, AnzahlBewertungen__c, DurchschnittBewertungen__c,
                   NumberOfEmployees, NewsArtikel__c, Carestone_Vertriebsvereinbarung__c, WHS_Maklerauftrag__c
            FROM Account
            WHERE Id IN :accountIds
        ]);

        Map<Id, Integer> oppCounts = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT AccountId accId, COUNT(Id) oppCount
            FROM Opportunity
            WHERE AccountId IN :accountIds
            GROUP BY AccountId
        ]) {
            oppCounts.put((Id)ar.get('accId'), (Integer)ar.get('oppCount'));
        }

        List<Account> toUpdate = new List<Account>();
        for (Account acc : accountMap.values()) {
            Integer score = 0;

            // Legal form
            if (acc.Rechtsform__c != null) {
                String form = acc.Rechtsform__c.toLowerCase();
                if (form.contains('gmbh') || form.contains('kg') || form.contains('ag')) {
                    score += 30;
                } else if (form.contains('einzel') || form.contains('freiberuf')) {
                    score += 5;
                } else {
                    score += 10;
                }
            }

            // Social links (5 points per)
            List<String> links = new List<String>{
                acc.FacebookUrl__c, acc.InstagramUrl__c, acc.LinkedInUrl__c, acc.XingUrl__c,
                acc.TrustpilotUrl__c, acc.GoogleMyBusinessUrl__c
            };
            Integer socialCount = 0;
            for (String link : links) {
                if (!String.isBlank(link)) socialCount++;
            }
            score += Math.min(socialCount * 5, 20); // Max 20

            // Ratings
            if (acc.AnzahlBewertungen__c != null) {
                score += Math.min(Integer.valueOf(acc.AnzahlBewertungen__c) / 10, 10); // 0–10 points
            }
            if (acc.DurchschnittBewertungen__c != null) {
                score += Math.min(Math.round(acc.DurchschnittBewertungen__c * 2), 10); // up to 10 points
            }

            // News articles
            if (!String.isBlank(acc.NewsArtikel__c)) {
                Integer articleCount = acc.NewsArtikel__c.split('\r\n').size();
                score += Math.min(articleCount * 2, 10);
            }

            // Employees (not very relevant)
            if (acc.NumberOfEmployees != null && acc.NumberOfEmployees > 0) {
                score += Math.min(acc.NumberOfEmployees / 10, 5);
            }

            // Opportunities (very relevant)
            Integer oppCount = oppCounts.containsKey(acc.Id) ? oppCounts.get(acc.Id) : 0;
            if (oppCount > 0) score += 10;

            // Vertriebspartnervereinbarung
            if (acc.Carestone_Vertriebsvereinbarung__c == true) score += 10;

            // WHS Maklerauftrag
            if (!String.isBlank(acc.WHS_Maklerauftrag__c) && acc.WHS_Maklerauftrag__c != 'Keine Vereinbarung') {
                score += 10;
            }

            acc.Score__c = Math.min(score, 100);
            toUpdate.add(acc);
        }

        if (!toUpdate.isEmpty()) update toUpdate;
    }
}