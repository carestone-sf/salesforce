public without sharing class FinanceCalculator {

    public Berechnung__c c;
    public List<FinanceModule> financeModules;
    public Map<Integer, Map<String, Object>> cumulatedYearlyValues;
    public Map<Integer, Map<String, Object>> firstYearAfterPaymentValues;
    public List<Map<Integer, Map<String, Object>>> paginatedYearlyValues;

    public Date finanzierungsbeginn;
    public Integer firstYear = 99999;
    public Integer lastYear = 0;
    public Integer firstYearAfterPayment = 0;
    public Integer firstFullYear = 0;
    public Integer pages = 0;
    public Decimal sumSBetragplusFKreditsumme {get;set;}


    public FinanceCalculator() {

    }
    public List<Map<Integer, Map<String, Object>>> deepCopyExistingStructureList(List<Map<Integer, Map<String, Object>>> original){
        List<Map<Integer, Map<String, Object>>> deepCopy = new List<Map<Integer, Map<String, Object>>>();
        for (Map<Integer, Map<String, Object>> firstMap : original) {
            deepCopy.add(deepCopyExistingStructureMap(firstMap));
        }

        return deepCopy;
    }

    public Map<Integer, Map<String, Object>> deepCopyExistingStructureMap(Map<Integer, Map<String, Object>> original){
        Map<Integer, Map<String, Object>> firstMapDeepCopy = new Map<Integer, Map<String, Object>>();
        for (Integer firstKey : original.keySet()) {
            Map<String, Object> secondMapDeepCopy = new Map<String, Object>();
            for (String secondKey : original.get(firstKey).keySet()) {
                secondMapDeepCopy.put(secondKey, original.get(firstKey).get(secondKey));
            }
            firstMapDeepCopy.put(firstKey, secondMapDeepCopy);
        }
        return firstMapDeepCopy;
    }

    // public List<Map<Integer, Map<String, Object>>> roundPaginatedYearlyValues(List<Map<Integer, Map<String, Object>>> currentPaginatedYearlyValues){
    //     // List<Map<Integer, Map<String, Object>>> updatedPaginatedYearlyValues = new List<Map<Integer, Map<String, Object>>>();
    //     // updatedPaginatedYearlyValues.addAll(currentPaginatedYearlyValues);
    //     List<Map<Integer, Map<String, Object>>> updatedPaginatedYearlyValues = deepCopyExistingStructureList(currentPaginatedYearlyValues);
    //     for (Map<Integer, Map<String, Object>> pagYearlyValue : updatedPaginatedYearlyValues){
    //         for (Integer year : pagYearlyValue.keySet()){
    //             for (String value : pagYearlyValue.get(year).keySet()) {
    //                 try {
    //                     String roundValue = (String)pagYearlyValue.get(year).get(value);
    //                     roundValue = roundValue.replace('.', '');
    //                     roundValue = roundValue.replace(',', '.');
    //                     pagYearlyValue.get(year).put(value, Math.round(Decimal.valueOf(roundValue)).format());
    //                 } catch (Exception e) {
    //                     System.debug(e.getMessage());
    //                 }


    //             }
    //         }
    //     }
    //     return updatedPaginatedYearlyValues;
    // }
    public Map<Integer, String> calcSondertilgung(Id calculationId, List<Map<Integer, Map<String, Object>>> pagYearlyValues){
        List<Finanzierungsbaustein__c> fbs = [SELECT Id, Name, Art__c, Finanzierungsbeginn__c, Kreditsumme__c, LaufzeitInJahren__c, TilgungInPercent__c, Tilgungsbeginn__c, ZinsInPercent__c, ZinsbindungBis__c, (SELECT Name, JahrDerAuszahlung__c, Betrag__c FROM Sondertilgungen__r) FROM Finanzierungsbaustein__c WHERE Berechnung__c = :calculationId];
        List<Id> sonderId = new List<Id>();
        for (Finanzierungsbaustein__c f : fbs) {
            sonderId.add(f.id);
        }
        List<Sondertilgung__c> sondertilgungRelated = [SELECT Id, Name, CreatedById, JahrDerAuszahlung__c, Prozent__c, Betrag__c FROM Sondertilgung__c WHERE Finanzierungsbaustein__c in :sonderId];
        if (sondertilgungRelated.size() == 0 || sondertilgungRelated == null) {
            return null;
        }
        Map<Integer,String> res = new Map<Integer,String>();
        for (Sondertilgung__c s : sondertilgungRelated) {
            for (Map<Integer, Map<String, Object>> pagYearlyValue : pagYearlyValues) {

                for (Integer year : pagYearlyValue.keySet()) {
                    if (pagYearlyValue.get(Integer.valueOf(s.JahrDerAuszahlung__c)) != null && year == Integer.valueOf(s.JahrDerAuszahlung__c)) {

                        String creditSumStr = (String)pagYearlyValue.get(Integer.valueOf(s.JahrDerAuszahlung__c)).get('creditSumStartInEuro');
                        creditSumStr = creditSumStr.replace('.', '');
                        creditSumStr = creditSumStr.replace(',', '.');
                        Decimal sum = s.Betrag__c;
                        res.put(Integer.valueOf(s.JahrDerAuszahlung__c), sum.format());
                    }
                    else {
                        if (!res.containsKey(year)) {
                            res.put(year, '0');
                        }
                    }
                }

            }
        }
        return res;
    }
    public void initFinanceModules(Id calculationId) {
        this.c = [SELECT Id, Hauptimmobilie__r.Arrival__c, SteuernBerechnen__c, ZweiterKaeufer__c, Gesamtkosten__c, ZuVersteuerndesEinkommen__c, Kirchensteuer__c, Eigenkapital__c, Finanzierungsart__c, InstandhaltungProJahrGesamt__c, AfAProJahrGesamt__c, VerwaltungProJahrGesamt__c, Mietsteigerung__c, SteigerungInstandhaltung__c, SteigerungVerwaltung__c, (SELECT Apartment__r.Name, MieteProMonatInEuro__c FROM Berechnungs_Apartments__r) FROM Berechnung__c WHERE Id = :calculationId];
        Date today = Date.today();
        this.finanzierungsbeginn = this.c.Hauptimmobilie__r.Arrival__c;
        if(today > this.c.Hauptimmobilie__r.Arrival__c) {
            this.finanzierungsbeginn = today;
        }
        this.firstYear = this.finanzierungsbeginn.year();
        if(this.finanzierungsbeginn.day() == 1 && this.finanzierungsbeginn.month() == 1) {
            this.firstFullYear = this.finanzierungsbeginn.year();
            this.firstYearAfterPayment = this.firstFullYear;
        } else {
            this.firstFullYear = this.finanzierungsbeginn.year() + 1;
            this.firstYearAfterPayment = this.firstFullYear;
        }

        List<Finanzierungsbaustein__c> fbs = [SELECT Id, Name, Art__c, Finanzierungsbeginn__c, Kreditsumme__c, LaufzeitInJahren__c, TilgungInPercent__c, Tilgungsbeginn__c, ZinsInPercent__c, ZinsbindungBis__c, (SELECT Name, JahrDerAuszahlung__c, Betrag__c FROM Sondertilgungen__r) FROM Finanzierungsbaustein__c WHERE Berechnung__c = :calculationId];

        //Related to a Calculation (Berechnung__c) are “Finanzierungsbausteine” records
        for(Finanzierungsbaustein__c f:fbs){
            if(f.Kreditsumme__c != null){

            }
            //The “Finanzierungsbaustein” records might sometimes have 1-n related “Sondertilgung” records
            List<Sondertilgung__c> sondertilgungRelated = [SELECT Id, Name, CreatedById, Prozent__c, Betrag__c FROM Sondertilgung__c WHERE Finanzierungsbaustein__c = :f.Id];
            for(Sondertilgung__c s:sondertilgungRelated){
                if(s.Betrag__c != null) {
                    //If there are “Sondertilgung” records, a new column should be rendered in the PDF table, displaying the amount (“Betrag”) in the corresponding year (“Jahr der Auszahlung”)
                    this.sumSBetragplusFKreditsumme = s.Betrag__c + f.Kreditsumme__c;
                } else {
                    //For years without “Sondertilgung”, 0 € should be displayed
                    this.sumSBetragplusFKreditsumme = 0;
                }
            }
        }

        this.financeModules = new List<FinanceModule>();
        this.cumulatedYearlyValues = new Map<Integer, Map<String, Object>>();
        this.firstYearAfterPaymentValues = new Map<Integer, Map<String, Object>>();
        this.paginatedYearlyValues = new List<Map<Integer, Map<String, Object>>>();

        if(this.c.Finanzierungsart__c == 'Bar') {
            this.cumulateYearsCashPayment();
        } else {
            for(Finanzierungsbaustein__c f:fbs) {
                if(f.Art__c != 'Eigenkapital') {
                    this.financeModules.add(new financeModule(f));
                }
            }
            this.cumulateYearsFinancing();
        }
    }

    public Decimal calculateTaxesForCurrentYear(Decimal salary, Integer year) {
        Decimal taxes = 0;
        if(this.c.ZweiterKaeufer__c != null) {
            salary -= 9744;
        }
        if(salary < 9744) {
            taxes = 0;
        } else if(salary >= 9745 && salary <= 14753) {
            taxes = ( 995.21 * (salary-9744) / 10000 + 1400) * (salary-9744) / 10000;  
        } else if(salary >= 14754 && salary <= 57918) {
            taxes = ( 208.85 * (salary-14753) / 10000 + 2397) * (salary-14753) / 10000 + 950.96;
        } else if(salary >= 57919 && salary <= 274612) {
            taxes = 0.42 * salary - 9136.63;
        } else if(salary >= 274613) {
            taxes = 0.45 * salary - 17374.99;
        }
        if(this.c.Kirchensteuer__c) {
            taxes *= 1.09;
        }
        return taxes;
    }

    public void cumulateYearsFinancing() {
        
        for(FinanceModule fm:this.financeModules) {
            if(fm.firstFullYear > this.firstFullYear) {
                this.firstFullYear = fm.firstFullYear;
            }

            for(Integer year:fm.yearlyValues.keySet()) {
                if(year < this.firstYear) {
                    this.firstYear = year;
                }
                if(year > this.lastYear) {
                    this.lastYear = year;
                }

                Map<String, Object> currentYearValues = fm.yearlyValues.get(year);
                Map<String, Object> currentYearCumulatedValues = this.cumulatedYearlyValues.get(year);
    
                if(currentYearCumulatedValues == null) {
                    currentYearCumulatedValues = new Map<String, Object>();
                }
                // Pro Jahr
                // Zinsen gesamt
                Decimal interestInEuro = 0;
                if(currentYearCumulatedValues.get('interestInEuro') == null) {
                    interestInEuro = (Decimal)currentYearValues.get('interestInEuro');
                } else {
                    interestInEuro = (Decimal)currentYearCumulatedValues.get('interestInEuro') + (Decimal)currentYearValues.get('interestInEuro');
                } 
                currentYearCumulatedValues.put('interestInEuro', interestInEuro);

                // Tilgung gesamt
                Decimal repaymentInEuro = 0;
                if(currentYearCumulatedValues.get('repaymentInEuro') == null) {
                    repaymentInEuro = (Decimal)currentYearValues.get('repaymentInEuro');
                } else {
                    repaymentInEuro = (Decimal)currentYearCumulatedValues.get('repaymentInEuro') + (Decimal)currentYearValues.get('repaymentInEuro');
                }
                currentYearCumulatedValues.put('repaymentInEuro', repaymentInEuro);

                // Rate gesamt
                Decimal rateInEuro = 0;
                if(currentYearCumulatedValues.get('rateInEuro') == null) {
                    rateInEuro = (Decimal)currentYearValues.get('rateInEuro');
                } else {
                    rateInEuro = (Decimal)currentYearCumulatedValues.get('rateInEuro') + (Decimal)currentYearValues.get('rateInEuro');
                }
                currentYearCumulatedValues.put('rateInEuro', rateInEuro);

                // Darlehensstand start gesamt
                Decimal creditSumStartInEuro = 0;
                if(currentYearCumulatedValues.get('creditSumStartInEuro') == null) {
                    creditSumStartInEuro = (Decimal)currentYearValues.get('creditSumStartInEuro');
                } else {
                    creditSumStartInEuro = (Decimal)currentYearCumulatedValues.get('creditSumStartInEuro') + (Decimal)currentYearValues.get('creditSumStartInEuro');
                }
                currentYearCumulatedValues.put('creditSumStartInEuro', creditSumStartInEuro);

                // Darlehenststand Ende gesamt
                Decimal creditSumEndInEuro = 0;
                if(currentYearCumulatedValues.get('creditSumEndInEuro') == null) {
                    creditSumEndInEuro = (Decimal)currentYearValues.get('creditSumEndInEuro');
                } else {
                    creditSumEndInEuro = (Decimal)currentYearCumulatedValues.get('creditSumEndInEuro') + (Decimal)currentYearValues.get('creditSumEndInEuro');
                }
                currentYearCumulatedValues.put('creditSumEndInEuro', creditSumEndInEuro);
                this.cumulatedYearlyValues.put(year, currentYearCumulatedValues);
            }
        }

        Decimal factor = 1.0;
        Decimal cumulatedCost = 0;
        Integer yearsPassed = 0;
        calculateLiquidity(factor, cumulatedCost, yearsPassed);

        if(this.c.Finanzierungsart__c == 'Finanzierung') {
            this.firstYearAfterPayment = this.lastYear + 1;
        } 

        Map<String, Object> lastYearCumulatedValues = this.cumulatedYearlyValues.get(lastYear);
        Map<String, Object> currentYearCumulatedValues = new Map<String, Object>();
        if(lastYearCumulatedValues != null) {
            Decimal incomeInEuro = 0;
            Decimal expenditureInEuro = 0;
            Decimal overageInEuro = 0;

            if(yearsPassed > 0 && Math.mod(yearsPassed, 5) == 0) {
                factor *= 1.05;
            }
            // Mieteinnahmen pro Apartment
            Map<String, Decimal> apartmentNameToRent = (Map<String, Decimal>)lastYearCumulatedValues.get('apartments');
            for(String key:apartmentNameToRent.keySet()) {
                Decimal rent = apartmentNameToRent.get(key);
                if(Math.mod(yearsPassed, 5) == 0 && this.c.Mietsteigerung__c) {
                    rent *= factor;
                }
                apartmentNameToRent.put(key, rent);
                incomeInEuro += rent;
            }
            currentYearCumulatedValues.put('apartments', apartmentNameToRent);

            // Miete gesamt
            currentYearCumulatedValues.put('rentInEuro', incomeInEuro);

            Decimal instandhaltungInEuro = (Decimal)lastYearCumulatedValues.get('instandhaltungGesamtInEuro');
            if(Math.mod(yearsPassed, 5) == 0 && this.c.SteigerungInstandhaltung__c) {
                instandHaltungInEuro *= factor;
            }
            expenditureInEuro -= instandHaltungInEuro;
            currentYearCumulatedValues.put('instandhaltungGesamtInEuro', instandHaltungInEuro);

            lastYearCumulatedValues.get('verwaltungGesamtInEuro');
            Decimal verwaltungInEuro = (Decimal)lastYearCumulatedValues.get('verwaltungGesamtInEuro');
            if(Math.mod(yearsPassed, 5) == 0 && this.c.SteigerungInstandhaltung__c) {
                verwaltungInEuro *= factor;
            }
            expenditureInEuro -= verwaltungInEuro;
            currentYearCumulatedValues.put('verwaltungGesamtInEuro', verwaltungInEuro);

            // AfA in Euro gesamt
            Decimal afaInEuro = this.c.AfaProJahrGesamt__c;
            currentYearCumulatedValues.put('afaGesamtInEuro', afaInEuro);

            // vUndV in Euro gesamt
            Decimal interestInEuro = currentYearCumulatedValues.get('interestInEuro') != null ? (Decimal) currentYearCumulatedValues.get('interestInEuro') : 0;
            Decimal vUndVInEuro = incomeInEuro - afaInEuro - interestInEuro - verwaltungInEuro;
            currentYearCumulatedValues.put('vUndVGesamtInEuro', vUndVInEuro);

            // Steuern
            if(this.c.ZuVersteuerndesEinkommen__c != null) {
                Decimal taxableIncome = this.c.ZuVersteuerndesEinkommen__c;
                Decimal totalIncome = taxableIncome + vUndVInEuro;
                Decimal taxDifference = this.calculateTaxesForCurrentYear(taxableIncome, this.firstYearAfterPayment) - this.calculateTaxesForCurrentYear(totalIncome, this.firstYearAfterPayment);
                currentYearCumulatedValues.put('taxesInEuro', taxDifference);
                currentYearCumulatedValues.put('taxes', taxDifference);
                if(taxDifference < 0) {
                    expenditureInEuro += taxDifference;
                } else {
                    incomeInEuro += taxDifference;
                }
            } else {
                currentYearCumulatedValues.put('taxesInEuro', 0);
                currentYearCumulatedValues.put('taxes', 0);
            }

            overageInEuro = incomeInEuro + expenditureInEuro;

            currentYearCumulatedValues.put('overageGesamtInEuro', cumulatedCost);
            System.debug(cumulatedCost);
            Decimal percentageSelf = Math.abs((this.c.Eigenkapital__c - cumulatedCost) / this.c.Gesamtkosten__c * 100);
            percentageSelf = percentageSelf >= 100 ? 100 : percentageSelf;
            Decimal percentageTenant = 100-percentageSelf;
            currentYearCumulatedValues.put('percentageSelf', percentageSelf);
            currentYearCumulatedValues.put('percentageTenant', percentageTenant);
            currentYearCumulatedValues.put('incomeInEuro', incomeInEuro);
            currentYearCumulatedValues.put('expenditureInEuro', expenditureInEuro);
            currentYearCumulatedValues.put('yearlyOverageInEuro', overageInEuro);
            currentYearCumulatedValues.put('monthlyOverageInEuro', overageInEuro/12);
            currentYearCumulatedValues.put('interestInEuro', 0);
            currentYearCumulatedValues.put('repaymentInEuro', 0);
            Decimal eigenkapitalRendite = 0;
            if(this.c.Eigenkapital__c != null && this.c.Eigenkapital__c != 0) {
                eigenkapitalRendite = overageInEuro / this.c.Eigenkapital__c * 100;
            }
            currentYearCumulatedValues.put('eigenkapitalRendite', eigenkapitalRendite);
        } 

        this.firstYearAfterPaymentValues.put(firstYearAfterPayment, currentYearCumulatedValues);
    }

    public void cumulateYearsCashPayment() {
        Map<String, Object> currentYearCumulatedValues = new Map<String, Object>();
        Decimal incomeInEuro = 0;
        Decimal expenditureInEuro = 0;
        Decimal overageInEuro = 0;

        // Fill cumulatedYearlyValuesMap
        // Pro Jahr
        // Mieteinnahmen pro Apartment
        Map<String, Decimal> apartmentNameToRent = new Map<String, Decimal>();
        for(BerechnungsApartment__c ba:this.c.Berechnungs_Apartments__r) {
            Decimal rent = ba.MieteProMonatInEuro__c * 12;
            apartmentNameToRent.put(ba.Apartment__r.Name, rent);
            incomeInEuro += rent;
        }
        currentYearCumulatedValues.put('apartments', apartmentNameToRent);

        // Miete gesamt
        currentYearCumulatedValues.put('rentInEuro', incomeInEuro);

        // Verwaltung gesamt
        Decimal verwaltungInEuro = this.c.VerwaltungProJahrGesamt__c;
        expenditureInEuro -= verwaltungInEuro;
        currentYearCumulatedValues.put('verwaltungGesamtInEuro', verwaltungInEuro);

        // Instandhaltung gesamt
        Decimal instandHaltungInEuro = this.c.InstandhaltungProJahrGesamt__c;
        expenditureInEuro -= instandHaltungInEuro;
        currentYearCumulatedValues.put('instandhaltungGesamtInEuro', instandHaltungInEuro);

        // AfA in Euro gesamt
        Decimal afaInEuro = this.c.AfaProJahrGesamt__c;
        currentYearCumulatedValues.put('afaGesamtInEuro', afaInEuro);

        // vUndV in Euro gesamt
        Decimal interestInEuro = currentYearCumulatedValues.get('interestInEuro') != null ? (Decimal) currentYearCumulatedValues.get('interestInEuro') : 0;
        Decimal vUndVInEuro = incomeInEuro - afaInEuro - interestInEuro - verwaltungInEuro;
        currentYearCumulatedValues.put('vUndVGesamtInEuro', vUndVInEuro);

        // Steuern
        if(this.c.ZuVersteuerndesEinkommen__c != null) {
            Decimal taxableIncome = this.c.ZuVersteuerndesEinkommen__c;
            Decimal totalIncome = taxableIncome + vUndVInEuro;
            Decimal taxDifference = this.calculateTaxesForCurrentYear(taxableIncome, firstYearAfterPayment) - this.calculateTaxesForCurrentYear(totalIncome, firstYearAfterPayment);
            currentYearCumulatedValues.put('taxesInEuro', taxDifference);
            currentYearCumulatedValues.put('taxes', taxDifference);
            if(taxDifference < 0) {
                expenditureInEuro += taxDifference;
            } else {
                incomeInEuro += taxDifference;
            }
        } else {
            currentYearCumulatedValues.put('taxesInEuro', 0);
            currentYearCumulatedValues.put('taxes', 0);
        }

        // Einnahmen gesamt
        currentYearCumulatedValues.put('incomeInEuro', incomeInEuro);
        currentYearCumulatedValues.put('expenditureInEuro', expenditureInEuro);
        // Überschuss gesamt
        overageInEuro = incomeInEuro + expenditureInEuro;
        currentYearCumulatedValues.put('yearlyOverageInEuro', overageInEuro);
        currentYearCumulatedValues.put('monthlyOverageInEuro', overageInEuro/12);
        currentYearCumulatedValues.put('percentageSelf', 100);
        currentYearCumulatedValues.put('percentageTenant', 0);
        currentYearCumulatedValues.put('eigenkapitalRendite', 0);

        this.firstYearAfterPaymentValues.put(firstYearAfterPayment, currentYearCumulatedValues);

        for(Integer i = 0; i < 20; i++) {
            Map<String, Object> liquidityCurrentYearValues = new Map<String, Object>();
            liquidityCurrentYearValues.put('interestInEuro', 0);
            liquidityCurrentYearValues.put('repaymentInEuro', 0);
            liquidityCurrentYearValues.put('overageGesamtInEuro', 0);
            liquidityCurrentYearValues.put('percentageSelf', 0);
            liquidityCurrentYearValues.put('percentageTenant', 0);
            liquidityCurrentYearValues.put('creditSumStartInEuro', 0);
            liquidityCurrentYearValues.put('creditSumEndInEuro', 0);
            liquidityCurrentYearValues.put('rateInEuro', 0);
            liquidityCurrentYearValues.put('eigenkapitalRendite', 0);
            this.cumulatedYearlyValues.put(this.firstYear + i, liquidityCurrentYearValues);
        }
        Decimal factor = 1.0;
        Decimal cumulatedCost = 0;
        Integer yearsPassed = 0;
        calculateLiquidity(factor, cumulatedCost, yearsPassed);
    }

    public void calculateLiquidity(Decimal factor, Decimal cumulatedCost, Integer yearsPassed) {
        for(Integer year:this.cumulatedYearlyValues.keySet()) {
            Map<String, Object> currentYearCumulatedValues = this.cumulatedYearlyValues.get(year);
            Decimal incomeInEuro = 0;
            Decimal expenditureInEuro = 0;
            Decimal overageInEuro = 0;
            Integer daysWithRent = 360;

            if(yearsPassed > 0 && Math.mod(yearsPassed, 5) == 0) {
                factor *= 1.05;
            }

            if(yearsPassed == 0) {
                Date endOfFirstRentYear = Date.newInstance(this.finanzierungsbeginn.year(), 12, 31);
                daysWithRent = (this.finanzierungsbeginn.monthsBetween(endOfFirstRentYear)+1)*30;
            }

            // Pro Jahr
            // Mieteinnahmen pro Apartment
            Map<String, Decimal> apartmentNameToRent = new Map<String, Decimal>();
            for(BerechnungsApartment__c ba:this.c.Berechnungs_Apartments__r) {
                Decimal rent = ba.MieteProMonatInEuro__c * 12;
                if(this.c.MietSteigerung__c) {
                    rent *= factor;
                }
                rent = rent * daysWithRent/360;
                apartmentNameToRent.put(ba.Apartment__r.Name, rent);
                incomeInEuro += rent;
            }
            currentYearCumulatedValues.put('apartments', apartmentNameToRent);

            // Miete gesamt
            currentYearCumulatedValues.put('rentInEuro', incomeInEuro);

            // Verwaltung gesamt
            Decimal verwaltungInEuro = this.c.VerwaltungProJahrGesamt__c;
            if(this.c.SteigerungVerwaltung__c) {
                verwaltungInEuro *= factor;
            }
            verwaltungInEuro = verwaltungInEuro * daysWithRent/360;
            expenditureInEuro -= verwaltungInEuro;
            currentYearCumulatedValues.put('verwaltungGesamtInEuro', verwaltungInEuro);

            // Instandhaltung gesamt
            Decimal instandHaltungInEuro = this.c.InstandhaltungProJahrGesamt__c;
            if(this.c.SteigerungInstandhaltung__c) {
                instandHaltungInEuro *= factor;
            }
            instandHaltungInEuro = instandHaltungInEuro * daysWithRent/360;
            expenditureInEuro -= instandHaltungInEuro;
            currentYearCumulatedValues.put('instandhaltungGesamtInEuro', instandHaltungInEuro);

            // AfA in Euro gesamt
            Decimal afaInEuro = this.c.AfaProJahrGesamt__c * daysWithRent/360;
            currentYearCumulatedValues.put('afaGesamtInEuro', afaInEuro);

            // vUndV in Euro gesamt
            Decimal interestInEuro = currentYearCumulatedValues.get('interestInEuro') != null ? (Decimal) currentYearCumulatedValues.get('interestInEuro') : 0;
            Decimal vUndVInEuro = incomeInEuro - afaInEuro - interestInEuro - verwaltungInEuro;
            currentYearCumulatedValues.put('vUndVGesamtInEuro', vUndVInEuro);

            // Steuern
            if(this.c.ZuVersteuerndesEinkommen__c != null) {
                Decimal taxableIncome = this.c.ZuVersteuerndesEinkommen__c;
                Decimal totalIncome = taxableIncome + vUndVInEuro;
                Decimal taxDifference = this.calculateTaxesForCurrentYear(taxableIncome, year) - this.calculateTaxesForCurrentYear(totalIncome, year);
                currentYearCumulatedValues.put('taxesInEuro', taxDifference);
                currentYearCumulatedValues.put('taxes', taxDifference);
                if(taxDifference < 0) {
                    expenditureInEuro += taxDifference;
                } else {
                    incomeInEuro += taxDifference;
                }
            } else {
                currentYearCumulatedValues.put('taxesInEuro', 0);
                currentYearCumulatedValues.put('taxes', 0);
            }

            // Einnahmen gesamt
            currentYearCumulatedValues.put('incomeInEuro', incomeInEuro);
            // Ausgaben gesamt
            Decimal rateInEuro = (Decimal)currentYearCumulatedValues.get('rateInEuro');
            if(rateInEuro != null) {
                expenditureInEuro -= rateInEuro;
            }
            currentYearCumulatedValues.put('expenditureInEuro', expenditureInEuro);
            // Überschuss gesamt
            overageInEuro = incomeInEuro + expenditureInEuro;
            currentYearCumulatedValues.put('yearlyOverageInEuro', overageInEuro);
            currentYearCumulatedValues.put('monthlyOverageInEuro', overageInEuro/12);
            this.cumulatedYearlyValues.put(year, currentYearCumulatedValues);
            yearsPassed++;
            cumulatedCost += overageInEuro;
        }
    }

    public void formatValues() {
        for(Map<Integer, Map<String,Object>> currentCumulatedYearlyValues:this.paginatedYearlyValues) {
            formatCumulatedYearlyValues(currentCumulatedYearlyValues, 0);
        }
        formatCumulatedYearlyValues(this.cumulatedYearlyValues, 2);

        for(Integer year:this.firstYearAfterPaymentValues.keySet()) {
            Map<String, Object> currentYearValues = this.firstYearAfterPaymentValues.get(year);
            // Zinsen gesamt
            if(currentYearValues.get('interestInEuro') != null) {
                Decimal interestInEuro = (Decimal)currentYearValues.get('interestInEuro');
                currentYearValues.put('interestInEuro', interestInEuro.setScale(2, RoundingMode.HALF_UP).format());
            }

            if(currentYearValues.get('repaymentInEuro') != null) {
                // Tilgung gesamt
                Decimal repaymentInEuro = (Decimal)currentYearValues.get('repaymentInEuro');
                currentYearValues.put('repaymentInEuro', repaymentInEuro.setScale(2, RoundingMode.HALF_UP).format());
            }

            // Rate gesamt
            if(currentYearValues.get('rateInEuro') != null) {
                Decimal rateInEuro = (Decimal)currentYearValues.get('rateInEuro');
                currentYearValues.put('rateInEuro', rateInEuro.setScale(2, RoundingMode.HALF_UP).format());
            }

            // Darlehensstand start gesamt
            if(currentYearValues.get('creditSumStartInEuro') != null) {
                Decimal creditSumStartInEuro = (Decimal)currentYearValues.get('creditSumStartInEuro');
                currentYearValues.put('creditSumStartInEuro', creditSumStartInEuro.setScale(2, RoundingMode.HALF_UP).format());
            }

            // Darlehenststand Ende gesamt
            if(currentYearValues.get('creditSumEndInEuro') != null) {
                Decimal creditSumEndInEuro = (Decimal)currentYearValues.get('creditSumEndInEuro');
                currentYearValues.put('creditSumEndInEuro', creditSumEndInEuro.setScale(2, RoundingMode.HALF_UP).format());
            }

            // Mieteinnahmen pro Apartment
            Map<String, Decimal> apartmentNameToRent = (Map<String, Decimal>)currentYearValues.get('apartments');
            Map<String, String> newApartmentNameToRent = new Map<String, String>();
            for(String key:apartmentNameToRent.keySet()) {
                Decimal rent = apartmentNameToRent.get(key);
                newApartmentNameToRent.put(key, rent.setScale(2, RoundingMode.HALF_UP).format());
            }
            currentYearValues.put('apartments', newApartmentNameToRent);

            // Miete gesamt
            Decimal rentInEuro = (Decimal)currentYearValues.get('rentInEuro');
            currentYearValues.put('rentInEuro', rentInEuro.setScale(2, RoundingMode.HALF_UP).format());

            // Verwaltung gesamt
            Decimal verwaltungInEuro = (Decimal)currentYearValues.get('verwaltungGesamtInEuro');
            currentYearValues.put('verwaltungGesamtInEuro', verwaltungInEuro.setScale(2, RoundingMode.HALF_UP).format());

            // Instandhaltung gesamt
            Decimal instandHaltungInEuro = (Decimal)currentYearValues.get('instandhaltungGesamtInEuro');
            currentYearValues.put('instandhaltungGesamtInEuro', instandHaltungInEuro.setScale(2, RoundingMode.HALF_UP).format());

            // Afa gesamt
            Decimal afaInEuro = (Decimal)currentYearValues.get('afaGesamtInEuro');
            currentYearValues.put('afaGesamtInEuro', afaInEuro.setScale(2, RoundingMode.HALF_UP).format());

            // vUndV in Euro gesamt
            Decimal vUndVInEuro = (Decimal)currentYearValues.get('vUndVGesamtInEuro');
            currentYearValues.put('vUndVGesamtInEuro', vUndVInEuro.setScale(2, RoundingMode.HALF_UP).format());

            // Steuern
            if(currentYearValues.get('taxesInEuro') != null) {
                Decimal taxesInEuro = (Decimal)currentYearValues.get('taxesInEuro');
                currentYearValues.put('taxesInEuro', taxesInEuro.setScale(2, RoundingMode.HALF_UP).format());
            }

            // Einnahmen gesamt
            Decimal incomeInEuro = (Decimal)currentYearValues.get('incomeInEuro');
            currentYearValues.put('incomeInEuro', incomeInEuro.setScale(2, RoundingMode.HALF_UP).format());

            // Ausgaben gesamt
            Decimal expenditureInEuro = (Decimal)currentYearValues.get('expenditureInEuro');
            currentYearValues.put('expenditureInEuro', expenditureInEuro.setScale(2, RoundingMode.HALF_UP).format());

            // Überschuss gesamt
            Decimal overageInEuro = (Decimal)currentYearValues.get('yearlyOverageInEuro');
            currentYearValues.put('yearlyOverageInEuro', overageInEuro.setScale(2, RoundingMode.HALF_UP).format());

            // Überschuss gesamt pro Monat
            currentYearValues.put('monthlyOverageInEuro', (overageInEuro/12).setScale(2, RoundingMode.HALF_UP).format());

            // Überschuss gesamte Laufzeit 
            Decimal overageGesamtInEuro = (Decimal)currentYearValues.get('overageGesamtInEuro');
            if(overageGesamtInEuro != null) {
                currentYearValues.put('overageGesamtInEuro', overageGesamtInEuro.setScale(2, RoundingMode.HALF_UP).format());
            }

            // Überschuss gesamte Laufzeit 
            Decimal percentageSelf = (Decimal)currentYearValues.get('percentageSelf');
            if(percentageSelf != null) {
                currentYearValues.put('percentageSelf', percentageSelf.setScale(2, RoundingMode.HALF_UP).format());
            }

            // Überschuss gesamte Laufzeit 
            Decimal percentageTenant = (Decimal)currentYearValues.get('percentageTenant');
            if(percentageTenant != null) {
                currentYearValues.put('percentageTenant', percentageTenant.setScale(2, RoundingMode.HALF_UP).format());
            }

            // Eigenkapitalrendite 
            Decimal eigenkapitalRendite = (Decimal)currentYearValues.get('eigenkapitalRendite');
            if(eigenkapitalRendite != null) {
                currentYearValues.put('eigenkapitalRendite', eigenkapitalRendite.setScale(2, RoundingMode.HALF_UP).format());
            }

            this.firstYearAfterPaymentValues.put(year, currentYearValues);
        }

        for(FinanceModule fm:this.financeModules) {
            for(Integer year:fm.yearlyValues.keySet()) {
                Map<String, Object> currentYearValues = fm.yearlyValues.get(year);
                // Zinsen gesamt
                Decimal interestInEuro = (Decimal)currentYearValues.get('interestInEuro');
                currentYearValues.put('interestInEuro', interestInEuro.setScale(2, RoundingMode.HALF_UP).format());
    
                // Tilgung gesamt
                Decimal repaymentInEuro = (Decimal)currentYearValues.get('repaymentInEuro');
                currentYearValues.put('repaymentInEuro', repaymentInEuro.setScale(2, RoundingMode.HALF_UP).format());
    
                // Rate gesamt
                Decimal rateInEuro = (Decimal)currentYearValues.get('rateInEuro');
                currentYearValues.put('rateInEuro', rateInEuro.setScale(2, RoundingMode.HALF_UP).format());
    
                // Darlehensstand start gesamt
                Decimal creditSumStartInEuro = (Decimal)currentYearValues.get('creditSumStartInEuro');
                currentYearValues.put('creditSumStartInEuro', creditSumStartInEuro.setScale(2, RoundingMode.HALF_UP).format());
    
                // Darlehenststand Ende gesamt
                Decimal creditSumEndInEuro = (Decimal)currentYearValues.get('creditSumEndInEuro');
                currentYearValues.put('creditSumEndInEuro', creditSumEndInEuro.setScale(2, RoundingMode.HALF_UP).format());
            }
        }
    }

    public void formatCumulatedYearlyValues(Map<Integer, Map<String, Object>> currentCumulatedYearlyValues, Integer scale) {
        for(Integer year:currentCumulatedYearlyValues.keySet()) {
            Map<String, Object> currentYearCumulatedValues = currentCumulatedYearlyValues.get(year);
            // Zinsen gesamt
            Decimal interestInEuro = (Decimal)currentYearCumulatedValues.get('interestInEuro');
            currentYearCumulatedValues.put('interestInEuro', interestInEuro.setScale(scale, RoundingMode.HALF_UP).format());

            // Tilgung gesamt
            Decimal repaymentInEuro = (Decimal)currentYearCumulatedValues.get('repaymentInEuro');
            currentYearCumulatedValues.put('repaymentInEuro', repaymentInEuro.setScale(scale, RoundingMode.HALF_UP).format());

            // Rate gesamt
            Decimal rateInEuro = (Decimal)currentYearCumulatedValues.get('rateInEuro');
            currentYearCumulatedValues.put('rateInEuro', rateInEuro.setScale(scale, RoundingMode.HALF_UP).format());

            // Darlehensstand start gesamt
            Decimal creditSumStartInEuro = (Decimal)currentYearCumulatedValues.get('creditSumStartInEuro');
            currentYearCumulatedValues.put('creditSumStartInEuro', creditSumStartInEuro.setScale(scale, RoundingMode.HALF_UP).format());

            // Darlehenststand Ende gesamt
            Decimal creditSumEndInEuro = (Decimal)currentYearCumulatedValues.get('creditSumEndInEuro');
            currentYearCumulatedValues.put('creditSumEndInEuro', creditSumEndInEuro.setScale(scale, RoundingMode.HALF_UP).format());

            // Mieteinnahmen pro Apartment
            Map<String, Decimal> apartmentNameToRent = (Map<String, Decimal>)currentYearCumulatedValues.get('apartments');
            Map<String, String> newApartmentNameToRent = new Map<String, String>();
            for(String key:apartmentNameToRent.keySet()) {
                Decimal rent = apartmentNameToRent.get(key);
                newApartmentNameToRent.put(key, rent.setScale(scale, RoundingMode.HALF_UP).format());
            }
            currentYearCumulatedValues.put('apartments', newApartmentNameToRent);

            // Miete gesamt
            Decimal rentInEuro = (Decimal)currentYearCumulatedValues.get('rentInEuro');
            currentYearCumulatedValues.put('rentInEuro', rentInEuro.setScale(scale, RoundingMode.HALF_UP).format());

            // Verwaltung gesamt
            Decimal verwaltungInEuro = (Decimal)currentYearCumulatedValues.get('verwaltungGesamtInEuro');
            currentYearCumulatedValues.put('verwaltungGesamtInEuro', verwaltungInEuro.setScale(scale, RoundingMode.HALF_UP).format());

            // Instandhaltung gesamt
            Decimal instandHaltungInEuro = (Decimal)currentYearCumulatedValues.get('instandhaltungGesamtInEuro');
            currentYearCumulatedValues.put('instandhaltungGesamtInEuro', instandHaltungInEuro.setScale(scale, RoundingMode.HALF_UP).format());

            // Afa gesamt
            Decimal afaInEuro = (Decimal)currentYearCumulatedValues.get('afaGesamtInEuro');
            currentYearCumulatedValues.put('afaGesamtInEuro', afaInEuro.setScale(scale, RoundingMode.HALF_UP).format());

            // vUndV in Euro gesamt
            Decimal vUndVInEuro = (Decimal)currentYearCumulatedValues.get('vUndVGesamtInEuro');
            currentYearCumulatedValues.put('vUndVGesamtInEuro', vUndVInEuro.setScale(scale, RoundingMode.HALF_UP).format());

            // Steuern
            if(currentYearCumulatedValues.get('taxesInEuro') != null) {
                Decimal taxesInEuro = (Decimal)currentYearCumulatedValues.get('taxesInEuro');
                currentYearCumulatedValues.put('taxesInEuro', taxesInEuro.setScale(scale, RoundingMode.HALF_UP).format());
            }

            // Einnahmen gesamt
            Decimal incomeInEuro = (Decimal)currentYearCumulatedValues.get('incomeInEuro');
            currentYearCumulatedValues.put('incomeInEuro', incomeInEuro.setScale(scale, RoundingMode.HALF_UP).format());

            // Ausgaben gesamt
            Decimal expenditureInEuro = (Decimal)currentYearCumulatedValues.get('expenditureInEuro');
            currentYearCumulatedValues.put('expenditureInEuro', expenditureInEuro.setScale(scale, RoundingMode.HALF_UP).format());

            // Überschuss gesamt pro Jahr
            Decimal overageInEuro = (Decimal)currentYearCumulatedValues.get('yearlyOverageInEuro');
            currentYearCumulatedValues.put('yearlyOverageInEuro', overageInEuro.setScale(scale, RoundingMode.HALF_UP).format());

            // Überschuss gesamt pro Monat
            currentYearCumulatedValues.put('monthlyOverageInEuro', (overageInEuro/12).setScale(scale, RoundingMode.HALF_UP).format());
        }
    }

    public void generatePagination() {
        Integer pagebreak = 28;
        for(FinanceModule fm:this.financeModules) {
            Integer counter = 0;   
            Integer totalYears = fm.yearlyValues.keySet().size();
            Map<Integer, Map<String, Object>> currentYearlyValues = new Map<Integer, Map<String, Object>>();
            for(Integer year:fm.yearlyValues.keySet()) {
                Integer currentPage = (Integer)Math.floor(counter/pagebreak);
                Map<String,Object> yearlyValue = fm.yearlyValues.get(year);
                currentYearlyValues.put(year, yearlyValue);
                counter++;
                if(Math.mod(counter, pagebreak) == 0 || counter == totalYears) {
                    fm.paginatedYearlyValues.add(currentYearlyValues);         
                    currentYearlyValues = new Map<Integer, Map<String, Object>>();
                }
            }
            fm.pages = (Integer) Math.ceil(totalYears / pagebreak);
        }

        Integer counter = 0;   
        Map<Integer, Map<String, Object>> currentYearlyValues = new Map<Integer, Map<String, Object>>();
        Integer totalYears = cumulatedYearlyValues.keySet().size();
        Map<Integer, Map<String,Object>> cumulatedYearlyValuesCopy = deepCopyExistingStructureMap(cumulatedYearlyValues);
        for(Integer year:cumulatedYearlyValuesCopy.keySet()) {
            Integer currentPage = (Integer)Math.floor(counter/pagebreak);
            Map<String,Object> yearlyValue = cumulatedYearlyValuesCopy.get(year);
            currentYearlyValues.put(year, yearlyValue);
            counter++;
            if(Math.mod(counter, pagebreak) == 0 || counter == totalYears) {
                this.paginatedYearlyValues.add(currentYearlyValues);         
                currentYearlyValues = new Map<Integer, Map<String, Object>>();
            }
        }
        this.pages = (Integer) Math.ceil(totalYears / pagebreak);
    }

    public class FinanceModule {
        Map<Integer, Map<String, Object>> yearlyValues = new Map<Integer, Map<String, Object>>();
        List<Map<Integer, Map<String, Object>>> paginatedYearlyValues = new List<Map<Integer, Map<String, Object>>>();
        Integer pages;
        Finanzierungsbaustein__c f;
        Integer firstFullYear = 0;
         
        public Map<Integer, Map<String,Object>> getYearlyValues() {
            return this.yearlyValues;
        }

        public List<Map<Integer, Map<String, Object>>> getPaginatedYearlyValues() {
            return this.paginatedYearlyValues;
        }
        
        public Integer getPages() {
            return this.pages;
        }

        public Finanzierungsbaustein__c getF() {
            return this.f;
        }
    
        public FinanceModule(Finanzierungsbaustein__c f) {
            this.f = f;
            Map<Integer, Sondertilgung__c> yearToExtraRepaymentMap = new Map<Integer, Sondertilgung__c>();
            for(Sondertilgung__c sb:f.Sondertilgungen__r) {
                yearToExtraRepaymentMap.put(Integer.valueOf(sb.JahrDerAuszahlung__c), sb);
            } 

            if(f.Art__c == 'Annuitäten Darlehen') {
                this.calculateAnnuityLoan(f, yearToExtraRepaymentMap);
            } else if(f.Art__c == 'Endfälliges Darlehen') {
                this.calculateBulletLoan(f, yearToExtraRepaymentMap);
            } else if(f.Art__c == 'KfW Darlehen') {
                this.calculateAnnuityLoan(f, yearToExtraRepaymentMap);
            }
        }

        void calculateAnnuityLoan(Finanzierungsbaustein__c f, Map<Integer, Sondertilgung__c> yearToExtraRepaymentMap) {
            Integer startOfInterestYear = f.Finanzierungsbeginn__c.year();
            Integer startOfRepaymentYear = f.Tilgungsbeginn__c != null ? f.Tilgungsbeginn__c.year() : startOfInterestYear;
            Decimal annuityRate = (f.Kreditsumme__c * f.ZinsInPercent__c / 100) + (f.Kreditsumme__c * f.TilgungInPercent__c / 100);
            Decimal remainingCreditSum = f.Kreditsumme__c;
            Boolean isFirstFullYear = false;

            Integer currentYear = startOfInterestYear;
            while(remainingCreditSum > 0) {
                Map<String, Object> currentYearValues = new Map<String,Object>();
                Decimal interestInEuro = 0;
                Decimal repaymentInEuro = 0;
                Decimal rateInEuro = 0;
                Decimal afaInEuro = 0;

                currentYearValues.put('creditSumStartInEuro', remainingCreditSum);

                Integer daysInterest = 360;
                Integer daysRepayment = 360;

                // Erstes Jahr
                if(currentYear == startOfInterestYear) {
                    Date endOfInterest = Date.newInstance(startOfInterestYear, 12, 31);
                    daysInterest = (f.Finanzierungsbeginn__c.monthsBetween(endOfInterest)+1)*30;
                }
                
                if(currentYear == startOfRepaymentYear) {
                    Date endOfRepayment = Date.newInstance(startOfRepaymentYear, 12, 31);
                    if(f.Tilgungsbeginn__c != null) {
                        daysRepayment = (f.Tilgungsbeginn__c.monthsBetween(endOfRepayment)+1)*30;
                    } else {
                        daysRepayment = (f.Finanzierungsbeginn__c.monthsBetween(endOfRepayment)+1)*30;
                    }
                }

                // Erstes oder irgendein Jahr
                interestInEuro = remainingCreditSum * f.ZinsInPercent__c / 100 / 360 * daysInterest;
                if(currentYear >= startOfRepaymentYear) {
                    repaymentInEuro = annuityRate/360*daysRepayment-interestInEuro/daysInterest*daysRepayment;
                } 

                // Letztes Jahr
                if(remainingCreditSum - repaymentInEuro < 0) {
                    Date startOfEndYearInterest = Date.newInstance(currentYear, 01, 01);
                    Date endOfInterest = Date.newInstance(currentYear, f.Finanzierungsbeginn__c.month(), f.Finanzierungsbeginn__c.day())-1;
                    daysInterest = (startOfEndYearInterest.monthsBetween(endOfInterest)+1)*30;
                    if(daysInterest > 360) {
                        daysInterest = 360;
                    }
                    interestInEuro = remainingCreditSum * f.ZinsInPercent__c / 100 / 360 * daysInterest;
                    repaymentInEuro = remainingCreditSum;
                    remainingCreditSum = 0;
                } else {
                    remainingCreditSum -= repaymentInEuro;
                }

                currentYearValues.put('interestInEuro', interestInEuro);
                currentYearValues.put('repaymentInEuro', repaymentInEuro);
                rateInEuro = interestInEuro + repaymentInEuro;
                currentYearValues.put('rateInEuro', rateInEuro);

                Sondertilgung__c sb = yearToExtraRepaymentMap.get(currentYear);
                if(sb != null) {
                    remainingCreditSum -= sb.Betrag__c;
                    Map<String, Object> sbMap = new Map<String, Object>();
                    sbMap.put('amount', sb.Betrag__c);
                    sbMap.put('name', sb.Name);
                    currentYearValues.put('extraPayment', sbMap);
                }

                if(daysInterest == 360 && daysRepayment == 360 && currentYear > this.firstFullYear && !isFirstFullYear) {
                    this.firstFullYear = currentYear;
                    isFirstFullYear = true;
                }

                currentYearValues.put('creditSumEndInEuro', remainingCreditSum);
                this.yearlyValues.put(currentYear, currentYearValues);
                currentYear++;
            }
        }

        void calculateBulletLoan(Finanzierungsbaustein__c f, Map<Integer, Sondertilgung__c> yearToExtraRepaymentMap) {
            Integer startOfInterestYear = f.Finanzierungsbeginn__c.year();
            Integer years = Integer.valueOf(f.LaufzeitInJahren__c); 
            Decimal remainingCreditSum = f.Kreditsumme__c;
            Boolean isFirstFullYear = false;

            for(Integer currentYear = startOfInterestYear; currentYear < startOfInterestYear+years; currentYear++) {
                Map<String, Object> currentYearValues = new Map<String,Object>();
                Decimal interestInEuro = 0;
                Decimal repaymentInEuro = 0;
                Decimal rateInEuro = 0;

                currentYearValues.put('creditSumStartInEuro', remainingCreditSum);

                Integer daysInterest = 360;
                Integer daysRepayment = 360;

                // Erstes Jahr
                if(currentYear == startOfInterestYear) {
                    Date endOfInterest = Date.newInstance(startOfInterestYear, 12, 31);
                    daysInterest = (f.Finanzierungsbeginn__c.monthsBetween(endOfInterest)+1)*30;
                }
                
                // Erstes oder irgendein Jahr
                interestInEuro = remainingCreditSum * f.ZinsInPercent__c / 100 / 360 * daysInterest;
                
                if(currentYear == startOfInterestYear+years-1) {
                    repaymentInEuro = remainingCreditSum;
                }

                // Letztes Jahr
                if(remainingCreditSum - repaymentInEuro <= 0) {
                    Date startOfEndYearInterest = Date.newInstance(currentYear, 01, 01);
                    Date endOfInterest = Date.newInstance(currentYear, f.Finanzierungsbeginn__c.month(), f.Finanzierungsbeginn__c.day())-1;
                    daysInterest = (startOfEndYearInterest.monthsBetween(endOfInterest)+1)*30;
                    if(daysInterest > 360) {
                        daysInterest = 360;
                    }
                    interestInEuro = remainingCreditSum * f.ZinsInPercent__c / 100 / 360 * daysInterest;
                    remainingCreditSum = 0;
                }

                if(daysInterest == 360 && daysRepayment == 360 && currentYear > this.firstFullYear && !isFirstFullYear) {
                    this.firstFullYear = currentYear;
                    isFirstFullYear = true;
                }

                currentYearValues.put('interestInEuro', interestInEuro);
                currentYearValues.put('repaymentInEuro', repaymentInEuro);
                rateInEuro = interestInEuro + repaymentInEuro;
                currentYearValues.put('rateInEuro', rateInEuro);
                currentYearValues.put('creditSumEndInEuro', remainingCreditSum);
                this.yearlyValues.put(currentYear, currentYearValues);
            }
        }

        void calculateKfwLoan(Finanzierungsbaustein__c f, Map<Integer, Sondertilgung__c> yearToExtraRepaymentMap) {
            
        }

    }
}
