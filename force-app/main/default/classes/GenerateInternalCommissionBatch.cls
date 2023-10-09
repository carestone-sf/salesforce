global without sharing class GenerateInternalCommissionBatch implements Database.Batchable<sObject> {
    // month || quarter || year
    String schedule;

    global GenerateInternalCommissionBatch(String schedule) {
        this.schedule = schedule;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        Date todaysDate = Date.today();
        Integer thisMonth = todaysDate.month();
        Integer lastMonth = todaysDate.month() - 1;
        Integer thisYear = todaysDate.year();
        Integer lastYearOrThisYear = todaysDate.year();
        if(thisMonth == 1 && todaysDate.day() <= 10) {
            lastMonth = 12;
            lastYearOrThisYear -= 1;
        }
        Integer lastQuarter = getQuarterByMonth(lastMonth);
        String query = 'SELECT Id, Notartermin__c, Provision_Thoben__c, Makler__c, WertErfolgsabhaengigeProvision__c, Maklerbetreuer_WirtschaftsHaus__c, Immobilie__c, Appartement__c, Potenzieller_Kunde__c, Provisionsbasis__c, OwnerId, MarketingzuschussNichtAusweisen__c, Immobilienberater__c, Abrechnung_ber__c, AbrechnungUeberNurFuerGrundprovision__c, Wert_Verk_ufer_Beratungsprovision_m_R__c, Wert_Maklerprovision__c, WertMarketingzuschuss__c, AdditionalBrokerCommission__c, Verkaufsprovision_intern__c, TippgeberProvisionEmpfaenger__c, Wert_Tippprovision__c, Overhead_Empf_nger__c, Wert_Overhead__c, Wert_Provision_Thoben__c FROM Opportunity';
        if(this.schedule == 'month') {
            if(todaysDate.day() <= 10) {
                query += ' WHERE CALENDAR_MONTH(Notartermin__c) >= :lastMonth AND (CALENDAR_YEAR(Notartermin__c) = :thisYear OR CALENDAR_YEAR(Notartermin__c) = :lastYearOrThisYear)';
            } else if(todaysDate.day() > 10) {
                query += ' WHERE CALENDAR_MONTH(Notartermin__c) = :thisMonth AND (CALENDAR_YEAR(Notartermin__c) = :thisYear OR CALENDAR_YEAR(Notartermin__c) = :lastYearOrThisYear)';
            }
        } else if(this.schedule == 'quarter') {
            query += ' WHERE CALENDAR_QUARTER(Notartermin__c) = :lastQuarter AND (CALENDAR_YEAR(Notartermin__c) = :thisYear OR CALENDAR_YEAR(Notartermin__c) = :lastYearOrThisYear)';
        } else if(this.schedule == 'year') {
            query += ' WHERE CALENDAR_YEAR(Notartermin__c) = :lastYearOrThisYear';
        }

        query += ' AND StageName = \'Geschlossene und gewonnene\'';
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {
        Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>();
        for(Opportunity opp:scope){
            oppsMap.put(opp.Id, opp);
        }
        Map<Id, Opportunity> oldOpps = new Map<Id, Opportunity>();
        ProvisionService ps = new ProvisionService(oppsMap, oldOpps, 'intern', this.schedule);
        ps.upsertProvisionen();
    }  
    global void finish(Database.BatchableContext BC)
    {
    }

    public Integer getQuarterByMonth(Integer month) {
        return math.round((month+1)/3.0);
    }

}