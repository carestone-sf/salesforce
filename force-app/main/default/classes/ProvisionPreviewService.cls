public with sharing class ProvisionPreviewService {
    
    private static Decimal nvl(Decimal v) {
        return v == null ? 0 : v;
    }
    
    private static Decimal sumProvisionFields(Provision__c prov) {
        if (prov == null) return 0;
        
        Decimal sum = 0;
        sum += nvl(prov.Wert_Maklerprovision__c);
        sum += nvl(prov.WertMarketingzuschuss__c);
        sum += nvl(prov.AdditionalBrokerCommission__c);
        sum += nvl(prov.Wert_Verk_ufer_Beratungsprovision_m_R__c);
        sum += nvl(prov.Wert_Tippprovision__c);
        sum += nvl(prov.Wert_Overhead__c);
        sum += nvl(prov.Wert_Provision_Thoben__c);
        return sum;
    }
    
    private static Decimal calcOpenAmountFromCreditsOrFull(Provision__c prov, Decimal baseSum) {
        // If there are credits and some are unpaid -> sum unpaid credits.
        // If there are no credits at all -> open is full baseSum.
        // If all credits are paid -> open is 0 (and will be filtered out by caller).
        if (prov == null) return 0;
        
        if (prov.Gutschriften__r == null || prov.Gutschriften__r.isEmpty()) {
            return baseSum;
        }
        
        Decimal offeneSumme = 0;
        Boolean hasUnpaid = false;
        
        for (Gutschrift__c g : prov.Gutschriften__r) {
            if (g.Bezahlt__c == false) {
                offeneSumme += nvl(g.Provisionssumme__c);
                hasUnpaid = true;
            }
        }
        
        return hasUnpaid ? offeneSumme : 0;
    }
    
    private static String fullName(Contact c) {
        if (c == null) return null;
        String fn = c.FirstName;
        String ln = c.LastName;
        if (String.isBlank(fn) && String.isBlank(ln)) return null;
        if (String.isBlank(fn)) return ln;
        if (String.isBlank(ln)) return fn;
        return fn + ' ' + ln;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ProvisionPreviewDTO> getOpenBrokerProvisions(Id brokerContactId) {
        
        List<ProvisionPreviewDTO> result = new List<ProvisionPreviewDTO>();
        
        // Requesting broker/contact (used for ProvisionService broker-context)
        Contact broker = [
            SELECT
                Id,
                Email,
                Ist_Maklerbetreuer_WH__c,
                Gesch_ftsbeziehung__c,
                Maklerauftrag__c,
                AccountId,
                FirstName,
                LastName,
                VPRollen__c
            FROM Contact
            WHERE Id = :brokerContactId
            LIMIT 1
        ];
        
        Boolean hasAllProvisionRole =
            broker.VPRollen__c != null &&
            broker.VPRollen__c.contains('Alle Provisionen');
        
        Set<Id> relevantBrokerContactIds = new Set<Id>();
        Map<Id, Contact> brokerById = new Map<Id, Contact>();

        if (hasAllProvisionRole) {
            for (Contact c : [
                SELECT Id, FirstName, LastName, Email, Ist_Maklerbetreuer_WH__c, Gesch_ftsbeziehung__c, Maklerauftrag__c, AccountId
                FROM Contact
                WHERE AccountId = :broker.AccountId
                AND Gesch_ftsbeziehung__c NOT IN ('Interessent', 'Kunde')
            ]) {
                relevantBrokerContactIds.add(c.Id);
                brokerById.put(c.Id, c);
            }
        } else {
            relevantBrokerContactIds.add(broker.Id);
            brokerById.put(broker.Id, broker);
        }

        
        // Load opps INCLUDING provisions + credits (so we can handle open amounts based on credits)
        List<Opportunity> opps = [
            SELECT
                Id,
                StageName,
                Probability,
                ExterneProvisionenGeneriert__c,

                Notartermin__c,
                Provisionsbasis__c,
                MarketingzuschussNichtAusweisen__c,

                Potenzieller_Kunde__c,
                Potenzieller_Kunde__r.Name,

                Immobilie__c,
                Immobilie__r.Name,

                Appartement__c,
                Appartement__r.Name,

                Makler__c,
                Immobilienberater__c,
                Abrechnung_ber__c,
                AbrechnungUeberNurFuerGrundprovision__c,
                Verkaufsprovision_intern__c,

                Wert_Verk_ufer_Beratungsprovision_m_R__c,
                Wert_Maklerprovision__c,
                WertMarketingzuschuss__c,
                AdditionalBrokerCommission__c,

                TippgeberProvisionEmpfaenger__c,
                Wert_Tippprovision__c,

                Overhead_Empf_nger__c,
                Wert_Overhead__c,
                ClosingBonusInEuro__c,
                ClosingBonusInProzent__c,

                OwnerId,

                (SELECT
                    Id,
                    Kaufpreis__c,
                    Makler__c,
                    Wert_Maklerprovision__c,
                    WertMarketingzuschuss__c,
                    AdditionalBrokerCommission__c,
                    Wert_Verk_ufer_Beratungsprovision_m_R__c,
                    Wert_Tippprovision__c,
                    Wert_Overhead__c,
                    Wert_Provision_Thoben__c,
                    (SELECT Id, Provisionssumme__c, Bezahlt__c FROM Gutschriften__r WHERE GutschriftStorniert__c = false)
                 FROM Provisionen__r)
            FROM Opportunity
            WHERE StageName IN (
                'Kaufvertragsunterlagen verschickt',
                'KV wird fremd abgegeben',
                'Notartermin hat stattgefunden',
                'Geschlossene und gewonnene'
            )
            AND CreatedDate >= LAST_YEAR AND (Makler__c IN :relevantBrokerContactIds OR Immobilienberater__c IN :relevantBrokerContactIds OR Abrechnung_ber__c IN :relevantBrokerContactIds OR TippgeberProvisionEmpfaenger__c IN :relevantBrokerContactIds OR Overhead_Empf_nger__c IN :relevantBrokerContactIds) 
        ];
        
        // Build maps needed by ProvisionService (same as cold class)
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(opps);
        Map<Id, Opportunity> oldOppMap = new Map<Id, Opportunity>();
        ProvisionService ps = new ProvisionService(oppMap, oldOppMap, 'extern', null);
        
        // -------------------------------
        // 1) FORECAST PATH (cold class behavior)
        // -------------------------------
        for (Opportunity opp : opps) {
            
            if (opp.ExterneProvisionenGeneriert__c) continue;
            
            for (Id brokerId : relevantBrokerContactIds) {
                
                Contact forecastBroker = brokerById.get(brokerId);
                if (forecastBroker == null || forecastBroker.Ist_Maklerbetreuer_WH__c) continue;
                
                Provision__c provForecast =
                    ps.getProvisionExtern(opp, forecastBroker);
                
                if (provForecast == null) continue;
                
                Decimal sum = sumProvisionFields(provForecast);
                if (sum <= 0) continue;
                
                ProvisionPreviewDTO dto = new ProvisionPreviewDTO();
                dto.OpportunityId = opp.Id;
                dto.ErsterKaeuferName = opp.Potenzieller_Kunde__r?.Name;
                dto.ImmobilieName = opp.Immobilie__r?.Name;
                dto.ApartmentName = opp.Appartement__r?.Name;
                dto.StageName = opp.StageName;
                dto.Notartermin = opp.Notartermin__c;
                
                dto.Kaufpreis = provForecast.Kaufpreis__c;
                dto.Provisionssumme = sum;
                
                dto.ProvisionInProzent =
                    (provForecast.Kaufpreis__c != null && provForecast.Kaufpreis__c > 0)
                    ? (sum / provForecast.Kaufpreis__c) * 100
                    : 0;
                
                dto.Probability = opp.Probability;
                dto.WeightedProvision = sum * (opp.Probability / 100);
                dto.ProvisionDatum = opp.Notartermin__c;
                
                // Forecast broker = the broker used for calculation
                dto.BrokerName = fullName(forecastBroker);
                
                result.add(dto);
            }
        }
        
        // -------------------------------
        // 2) EXISTING PROVISIONS PATH (open/unpaid credits)
        //    Adds items for actual provisions, respecting relevantBrokerContactIds
        // -------------------------------
        for (Opportunity opp : opps) {
            if (opp.Provisionen__r == null || opp.Provisionen__r.isEmpty()) continue;
            
            for (Provision__c prov : opp.Provisionen__r) {
                
                // Only include provisions that belong to relevant brokers
                if (prov.Makler__c == null || !relevantBrokerContactIds.contains(prov.Makler__c)) {
                    continue;
                }
                
                Decimal baseSum = sumProvisionFields(prov);
                if (baseSum <= 0) continue;
                
                Decimal offeneSumme = calcOpenAmountFromCreditsOrFull(prov, baseSum);
                if (offeneSumme <= 0) continue;
                
                ProvisionPreviewDTO dto = new ProvisionPreviewDTO();
                dto.OpportunityId = opp.Id;
                dto.ErsterKaeuferName = opp.Potenzieller_Kunde__r?.Name;
                dto.ImmobilieName = opp.Immobilie__r?.Name;
                dto.ApartmentName = opp.Appartement__r?.Name;
                dto.StageName = opp.StageName;
                dto.Notartermin = opp.Notartermin__c;
                
                dto.Kaufpreis = prov.Kaufpreis__c;
                dto.Provisionssumme = offeneSumme;
                
                dto.ProvisionInProzent =
                    (prov.Kaufpreis__c != null && prov.Kaufpreis__c > 0)
                    ? (offeneSumme / prov.Kaufpreis__c) * 100
                    : 0;
                
                dto.Probability = opp.Probability;
                dto.WeightedProvision = offeneSumme * (opp.Probability / 100);
                dto.ProvisionDatum = opp.Notartermin__c;
                
                // Dynamic broker name from Provision.Makler__c
                dto.BrokerName = fullName(brokerById.get(prov.Makler__c));
                
                result.add(dto);
            }
        }
        
        return result;
    }
}