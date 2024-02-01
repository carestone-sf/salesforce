public without sharing class FinanceCalculator {

    public Berechnung__c c;
    public AFA__c afa;
    public List<FinanceModule> financeModules;
    public Map<Integer, Map<String, Object>> cumulatedYearlyValues;
    public Map<Integer, Map<String, Object>> cumulatedYearlyValuesBezugsphase;
    public Map<Integer, Map<String, Object>> firstYearAfterPaymentValues;
    public List<Map<Integer, Map<String, Object>>> paginatedYearlyValues;
    public List<Map<Integer, Map<String, Object>>> paginatedYearlyValuesForLiquidity;
    Map<Id, Decimal> berechnungsApartmentToRestwert;
    public Map<String, Object> sumsForLiquidity;
    public Map<String, Object> creditInformation;
    public Integer liquidityPages = 0;

    public Date finanzierungsbeginn;
    public Integer firstYear = 99999;
    public Integer lastYear = 0;
    public Integer firstYearAfterPayment = 0;
    public Integer firstFullYear = 0;
    public Integer pages = 0;
    Decimal factor = 1.0;
    Decimal cumulatedCost = 0;
    Integer yearsPassed = 0;
    public Decimal sumSBetragplusFKreditsumme {get;set;}


    public FinanceCalculator() {

    }

    public Map<Integer, Map<String, Object>> deepCopyExistingStructure(Map<Integer, Map<String, Object>> original){
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

    public Map<String, Map<Integer,String>> calcSondertilgung(){
        List<Finanzierungsbaustein__c> fbs = [SELECT Id, Name, Art__c, Finanzierungsbeginn__c, Kreditsumme__c, LaufzeitInJahren__c, TilgungInPercent__c, Tilgungsbeginn__c, ZinsInPercent__c, ZinsbindungBis__c, (SELECT Name, JahrDerAuszahlung__c, Betrag__c FROM Sondertilgungen__r) FROM Finanzierungsbaustein__c WHERE Berechnung__c = :this.c.Id];
        List<Id> sonderId = new List<Id>();
        for (Finanzierungsbaustein__c f : fbs) {
            sonderId.add(f.id);
        }
        List<Sondertilgung__c> sondertilgungRelated = [SELECT Id, Name, CreatedById, JahrDerAuszahlung__c, Prozent__c, Finanzierungsbaustein__c, Betrag__c FROM Sondertilgung__c WHERE Finanzierungsbaustein__c in :sonderId];
        if (sondertilgungRelated.size() == 0 || sondertilgungRelated == null) {
            return null;
        }
        Map<String, Map<Integer,String>> res = new Map<String, Map<Integer,String>>();
        for (Sondertilgung__c s : sondertilgungRelated) {
            for(FinanceModule fm:this.financeModules) {
                for(Map<Integer, Map<String, Object>> pagYearlyValue:fm.paginatedYearlyValues) {
                    for (Integer year : pagYearlyValue.keySet()) {
                        Map<Integer, String> currMap = res.get(fm.f.Id);
                        if(currMap == null) {
                            currMap = new Map<Integer, String>();
                        }
                        if (pagYearlyValue.get(Integer.valueOf(s.JahrDerAuszahlung__c)) != null && year == Integer.valueOf(s.JahrDerAuszahlung__c) && fm.f.Id == s.Finanzierungsbaustein__c) {
                            Decimal sum = s.Betrag__c;
                            currMap.put(Integer.valueOf(s.JahrDerAuszahlung__c), getFormattedNumber(sum));
                            currMap.put(0, 'true');
                            res.put(fm.f.Id, currMap);
                        }
                        else {
                            currMap.put(year, '0,00');
                            res.put(fm.f.Id, currMap);
                        }
                    }
                }

                if(res.get(fm.f.Id)?.get(0) == null) {
                    Map<Integer, String> currMap = res.get(fm.f.Id);
                    if(currMap == null) {
                        currMap = new Map<Integer, String>();
                    }
                    currMap.put(0, 'false');
                    res.put(fm.f.Id, currMap);
                }
            }
        }
        return res;
    }

    public void initFinanceModules(Id calculationId) {
        this.c = [SELECT Id, Hauptimmobilie__r.Arrival__c, Afa__c, Finanzierung__c, TaxableIncomePension__c, BetrachtungszeitraumInJahren__c, ErsterKaeufer__c, ErsterKaeufer__r.BirthDate, ZweiterKaeufer__c, ZweiterKaeufer__r.BirthDate, Gesamtkosten__c, GrunderwerbsteuerGesamt__c, ZuVersteuerndesEinkommen__c, Kirchensteuer__c, Eigenkapital__c, Finanzierungsart__c, InstandhaltungProJahrGesamt__c, VerwaltungProJahrGesamt__c, Mietsteigerung__c, SteigerungInstandhaltung__c, SteigerungVerwaltung__c, SumPurchasePrice__c, SumPriceAdjustment__c, (SELECT Apartment__r.Name, MieteProMonatInEuro__c, MieteProJahrInEuro__c, AfAAussenanlagenProJahrInProzent__c, AfAAussenanlagenProJahrInEuro__c, AfASubstanzProJahrInProzent__c, AfASubstanzProJahrInEuro__c, Gesamtkosten__c, AFAGrundlage__c FROM Berechnungs_Apartments__r) FROM Berechnung__c WHERE Id = :calculationId];
        List<Afa__c> afas = [SELECT Id, (SELECT JahrVon__c, JahrBis__c, AFAInProzent__c, Berechnung__c FROM AfaWerte__r) FROM Afa__c WHERE Id = :this.c.Afa__c];
        if(afas.size() > 0) {
            this.afa = afas[0];
        }
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

        List<Finanzierungsbaustein__c> fbs = [SELECT Id, Name, Art__c, Finanzierungsbeginn__c, Kreditsumme__c, AunnitaetInEuro__C, LaufzeitInJahren__c, TilgungInPercent__c, TilgungInPercentText__c, Tilgungsbeginn__c, ZinsInPercent__c, ZinsInPercentText__c, ZinsbindungBis__c, (SELECT Name, JahrDerAuszahlung__c, Betrag__c FROM Sondertilgungen__r) FROM Finanzierungsbaustein__c WHERE Berechnung__c = :calculationId];

        this.financeModules = new List<FinanceModule>();
        this.cumulatedYearlyValues = new Map<Integer, Map<String, Object>>();
        this.cumulatedYearlyValuesBezugsphase = new Map<Integer, Map<String, Object>>();
        this.firstYearAfterPaymentValues = new Map<Integer, Map<String, Object>>();
        this.paginatedYearlyValues = new List<Map<Integer, Map<String, Object>>>();
        this.paginatedYearlyValuesForLiquidity = new List<Map<Integer, Map<String, Object>>>();
        this.berechnungsApartmentToRestwert = new Map<Id, Decimal>();

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

    @future
    public static void updateBerechnung(Decimal liquidityMonthlyFirstYear, Id berechnungId) {
        Berechnung__c b = new Berechnung__c();
        b.Id = berechnungId;
        b.LiquidityMonthlyFirstYear__c = liquidityMonthlyFirstYear;
        update b;
    }  

    public Decimal calculateTaxesForCurrentYear(Decimal salary, Integer year) {
        Decimal taxes = 0;
        if(this.c.ZweiterKaeufer__c != null) {
            salary -= 10908;
        }
        if(salary < 10908) {
            taxes = 0;
        } else if(salary >= 9745 && salary <= 14753) {
            taxes = ( 995.21 * (salary-10908) / 10000 + 1400) * (salary-10908) / 10000;  
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

    public Decimal calculateTaxDifferenceForCurrentYear(Decimal vUndVInEuro, Integer year) {
        Date dateInYear = Date.newInstance(year, Date.Today().month(), Date.today().day());
        Integer days = this.c.ErsterKaeufer__r.BirthDate.daysBetween(dateInYear); 
        Integer age = Integer.valueOf(days/365); 
        Decimal taxableIncome = this.c.ZuVersteuerndesEinkommen__c;
        Decimal totalIncome = taxableIncome + vUndVInEuro;
        if(age >= 67) {
            Decimal pensionTaxableIncomePercentage = TaxService.getPensionTaxPercentage(this.c.ErsterKaeufer__r.BirthDate.year()+67);
            taxableIncome = this.c.TaxableIncomePension__c * pensionTaxableIncomePercentage;
            totalIncome = (this.c.TaxableIncomePension__c + vUndVInEuro) * pensionTaxableIncomePercentage;
        }
        Decimal taxDifference = this.calculateTaxesForCurrentYear(taxableIncome, this.firstYearAfterPayment) - this.calculateTaxesForCurrentYear(totalIncome, this.firstYearAfterPayment);
        return taxDifference;
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

        
        calculateLiquidity(this.cumulatedYearlyValues);

        if(this.c.Finanzierungsart__c == 'Finanzierung') {
            this.firstYearAfterPayment = this.lastYear + 1;
        } 

        Map<String, Object> lastYearCumulatedValues = this.cumulatedYearlyValues.get(this.lastYear);
        Map<String, Object> currentYearCumulatedValues = new Map<String, Object>();
        Decimal firstYearAfterPaymentFactor = 1;
        if(lastYearCumulatedValues != null) {
            Decimal incomeInEuro = 0;
            Decimal expenditureInEuro = 0;
            Decimal overageInEuro = 0;

            if(yearsPassed > 0 && Math.mod(yearsPassed, 5) == 0) {
                firstYearAfterPaymentFactor *= 1.05;
            }
            // Mieteinnahmen pro Apartment
            Map<String, Decimal> apartmentNameToRent = (Map<String, Decimal>)lastYearCumulatedValues.get('apartments');
            for(String key:apartmentNameToRent.keySet()) {
                Decimal rent = apartmentNameToRent.get(key);
                if(Math.mod(yearsPassed, 5) == 0 && this.c.Mietsteigerung__c) {
                    rent *= firstYearAfterPaymentFactor;
                }
                apartmentNameToRent.put(key, rent);
                incomeInEuro += rent;
            }

            currentYearCumulatedValues.put('apartments', apartmentNameToRent);

            // Miete gesamt
            currentYearCumulatedValues.put('rentInEuro', incomeInEuro);

            Decimal instandhaltungInEuro = (Decimal)lastYearCumulatedValues.get('instandhaltungGesamtInEuro');
            if(Math.mod(yearsPassed, 5) == 0 && this.c.SteigerungInstandhaltung__c) {
                instandHaltungInEuro *= firstYearAfterPaymentFactor;
            }
            expenditureInEuro -= instandHaltungInEuro;
            currentYearCumulatedValues.put('instandhaltungGesamtInEuro', instandHaltungInEuro);

            lastYearCumulatedValues.get('verwaltungGesamtInEuro');
            Decimal verwaltungInEuro = (Decimal)lastYearCumulatedValues.get('verwaltungGesamtInEuro');
            if(Math.mod(yearsPassed, 5) == 0 && this.c.SteigerungInstandhaltung__c) {
                verwaltungInEuro *= firstYearAfterPaymentFactor;
            }
            expenditureInEuro -= verwaltungInEuro;
            currentYearCumulatedValues.put('verwaltungGesamtInEuro', verwaltungInEuro);

            // AfA in Euro gesamt
            Decimal afaInEuro = calculateAfa(1);
            currentYearCumulatedValues.put('afaGesamtInEuro', afaInEuro);

            // vUndV in Euro gesamt
            Decimal interestInEuro = currentYearCumulatedValues.get('interestInEuro') != null ? (Decimal) currentYearCumulatedValues.get('interestInEuro') : 0;
            Decimal vUndVInEuro = incomeInEuro - afaInEuro - interestInEuro - verwaltungInEuro;
            currentYearCumulatedValues.put('vUndVGesamtInEuro', vUndVInEuro);

            // Steuern
            if(this.c.ZuVersteuerndesEinkommen__c != null) {
                Decimal taxDifference = calculateTaxDifferenceForCurrentYear(vUndVInEuro, this.firstYearAfterPayment);
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

        for(Integer i = 0; i < 25; i++) {
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
            this.cumulatedYearlyValuesBezugsphase.put(this.firstYear + i + this.yearsPassed, liquidityCurrentYearValues);
        }
        calculateLiquidity(this.cumulatedYearlyValuesBezugsphase);

    }

    public void calculateCreditInformation() {
        this.creditInformation = new Map<String, Object>();

        Decimal interestInEuroTotal = 0;
        Decimal creditSumTotal = 0; 
        Decimal kfwTotal = 0;
        Decimal bankTotal = 0;
        Decimal bankInterestTotal = 0;
        Decimal kfwInterest = 0;
        for(FinanceModule f:this.financeModules) {
            interestInEuroTotal += f.f.Kreditsumme__c * f.f.ZinsInPercent__c / 100;
            creditSumTotal += f.f.Kreditsumme__c; 
            if(f.f.Name.toLowerCase().contains('kfw')) {
                this.creditInformation.put('kfwExists', 'true');
                kfwTotal += f.f.Kreditsumme__c;
                kfwInterest = f.f.ZinsInPercent__c;
                this.creditInformation.put('kfwInEuro', kfwTotal);
                this.creditInformation.put('kfwInterest', kfwInterest);
            } else {
                bankInterestTotal += f.f.Kreditsumme__c * f.f.ZinsInPercent__c / 100;
                bankTotal += f.f.Kreditsumme__c;
            }
        }

        if(this.creditInformation.get('kfwExists') == null) {
            this.creditInformation.put('kfwExists', 'false');
            this.creditInformation.put('kfwInEuro', 0);
            this.creditInformation.put('kfwInterest', 0);
        }

        Decimal interestInPercentTotal = 0;
        if(creditSumTotal != 0) {
            interestInPercentTotal = interestInEuroTotal/creditSumTotal*100;
        }

        Decimal interestInPercentBankTotal = 0;
        if(bankTotal != 0) {
            interestInPercentBankTotal = bankInterestTotal/bankTotal*100;
        }

        this.creditInformation.put('interestInPercentTotal', interestInPercentTotal);
        this.creditInformation.put('showMixedInterestRate', this.financeModules.size() > 1 ? 'true':'false');
        this.creditInformation.put('interestInPercentBankTotal', interestInPercentBankTotal);
        this.creditInformation.put('bankInEuro', bankTotal);

        Decimal costInEuroTotal = this.c.Gesamtkosten__c;
        Decimal ekInEuro = this.c.Eigenkapital__c;
        Decimal interestBauzeitInEuroTotal = 0;
        for(Integer i = 0;i<7;i++) {
            Decimal ek;
            Decimal kfw;
            Decimal bank;
            Decimal costSum;
            if(i == 0) {
                costSum = costInEuroTotal * 0.25;
                ek = ekInEuro;
                kfw = kfwTotal;
                bank = bankTotal;
            } else if(i == 1) {
                costSum = costInEuroTotal * 0.28;
            } else if(i == 2) {
                costSum = costInEuroTotal * 0.126;
            } else if(i == 3) {
                costSum = costInEuroTotal * 0.063;
            } else if(i == 4) {
                costSum = costInEuroTotal * 0.112;
            } else if(i == 5) {
                costSum = costInEuroTotal * 0.084;
            } else if(i == 6) {
                costSum = costInEuroTotal * 0.085;
            }

            if(i > 0) {
                ek = (Decimal)this.creditInformation.get('ekRemainingInEuro' + (i));
                kfw = (Decimal)this.creditInformation.get('kfwRemainingInEuro' + (i));
                bank = (Decimal)this.creditInformation.get('bankRemainingInEuro' + (i));
            }
             
            calculateCurrentRate(i + 1, ek, kfw, bank, costSum);

            Decimal interestInEuro = 0;
            Decimal currentBankInEuro = (Decimal)this.creditInformation.get('bankInEuro' + (i+1));
            Decimal currentKfwInEuro = (Decimal)this.creditInformation.get('kfwInEuro' + (i+1));
            if(currentBankInEuro != null) {
                interestInEuro += currentBankInEuro * interestInPercentBankTotal/100/12;
            }

            if(currentKfwInEuro != null) {
                interestInEuro += currentKfwInEuro * kfwInterest/100/12;
            }

            if(i == 0) {
                interestInEuro *= 10;
            } else if(i == 1) {
                interestInEuro *= 3;
            } else if(i == 2) {
                interestInEuro *= 4;
            } else if(i == 3) {
                interestInEuro *= 1;
            } else if(i == 4) {
                interestInEuro *= 5;
            } else if(i == 5) {
                interestInEuro *= 1;
            } else if(i == 6) {
                interestInEuro *= 3;
            }

            this.creditInformation.put('interestInEuro' + (i+1), interestInEuro);
            this.creditInformation.put('costSumInEuro' + (i+1), costSum);
            interestBauzeitInEuroTotal += interestInEuro;
        }

        this.creditInformation.put('interestBauzeitInEuroTotal', interestBauzeitInEuroTotal);
    }

    public void calculateCurrentRate(Integer rate, Decimal ek, Decimal kfw, Decimal bank, Decimal costSum) {
        Decimal costSumRemaining = costSum;
        if(ek > 0) {
            if(ek > costSum) {
                this.creditInformation.put('ekInEuro' + rate, costSum);
                this.creditInformation.put('ekRemainingInEuro' + rate, ek - costSum);
                costSumRemaining = 0;
            } else if(ek <= costSum) {
                this.creditInformation.put('ekInEuro' + rate, ek);
                this.creditInformation.put('ekRemainingInEuro' + rate, 0);
                costSumRemaining -= ek;
            }
        } else {
            this.creditInformation.put('ekRemainingInEuro' + rate, 0);
            this.creditInformation.put('ekInEuro' + rate, 0);
        }

        if(kfw > 0) {
            if(costSumRemaining > 0) {
                if(kfw > costSumRemaining) {
                    this.creditInformation.put('kfwInEuro' + rate, costSumRemaining);
                    this.creditInformation.put('kfwRemainingInEuro' + rate, kfw - costSumRemaining);
                    costSumRemaining = 0;
                } else if(kfw <= costSumRemaining) {
                    this.creditInformation.put('kfwInEuro' + rate, kfw);
                    this.creditInformation.put('kfwRemainingInEuro' + rate, 0);
                    costSumRemaining -= kfw;
                }
            } else {
                this.creditInformation.put('kfwInEuro' + rate, 0);
                this.creditInformation.put('kfwRemainingInEuro' + rate, kfw);
            }
        } else {
            this.creditInformation.put('kfwInEuro' + rate, 0);
            this.creditInformation.put('kfwRemainingInEuro' + rate, 0);
        }

        if(bank > 0) {
            if(costSumRemaining > 0) {
                if(bank > costSumRemaining) {
                    this.creditInformation.put('bankInEuro' + rate, costSumRemaining);
                    this.creditInformation.put('bankRemainingInEuro' + rate, bank - costSumRemaining);
                } else if(bank <= costSumRemaining) {
                    this.creditInformation.put('bankInEuro' + rate, bank);
                    this.creditInformation.put('bankRemainingInEuro' + rate, 0);
                }
            } else {
                this.creditInformation.put('bankInEuro' + rate, 0);
                this.creditInformation.put('bankRemainingInEuro' + rate, bank);
            }
        } else {
            this.creditInformation.put('bankInEuro' + rate, 0);
            this.creditInformation.put('bankRemainingInEuro' + rate, 0);
        }
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
        Decimal afaInEuro = calculateAfa(1);
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

        for(Integer i = 0; i < 25; i++) {
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
            this.cumulatedYearlyValuesBezugsphase.put(this.firstFullYear + i, liquidityCurrentYearValues);
            this.cumulatedYearlyValues = deepCopyExistingStructure(this.cumulatedYearlyValuesBezugsphase);
        }
        this.yearsPassed = 1;
        calculateLiquidity(this.cumulatedYearlyValuesBezugsphase);
        this.yearsPassed = 0;
        this.factor = 1;
        this.cumulatedCost = 0;
        this.berechnungsApartmentToRestwert = new Map<Id, Decimal>();
        calculateLiquidity(this.cumulatedYearlyValues);
    }

    public void calculateLiquidity(Map<Integer, Map<String, Object>> yearlyValuesMap) {
        // Somehow get the "Bezugsphase" in here...
        for(Integer year:yearlyValuesMap.keySet()) {
            Map<String, Object> currentYearCumulatedValues = yearlyValuesMap.get(year);
            Decimal incomeInEuro = 0;
            Decimal expenditureInEuro = 0;
            Decimal overageInEuro = 0;
            Integer daysWithRent = 360;

            if(yearsPassed > 0 && Math.mod(yearsPassed, 5) == 0) {
                this.factor *= 1.05;
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
                    rent *= this.factor;
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
                verwaltungInEuro *= this.factor;
            }
            verwaltungInEuro = verwaltungInEuro * daysWithRent/360;
            expenditureInEuro -= verwaltungInEuro;
            currentYearCumulatedValues.put('verwaltungGesamtInEuro', verwaltungInEuro);

            // Instandhaltung gesamt
            Decimal instandHaltungInEuro = this.c.InstandhaltungProJahrGesamt__c;
            if(this.c.SteigerungInstandhaltung__c) {
                instandHaltungInEuro *= this.factor;
            }
            instandHaltungInEuro = instandHaltungInEuro * daysWithRent/360;
            expenditureInEuro -= instandHaltungInEuro;
            currentYearCumulatedValues.put('instandhaltungGesamtInEuro', instandHaltungInEuro);

            // AfA in Euro gesamt
            Decimal privateFactor = (Decimal)daysWithRent/360;
            Decimal afaInEuro = calculateAfa(privateFactor);
            currentYearCumulatedValues.put('afaGesamtInEuro', afaInEuro);

            // vUndV in Euro gesamt
            Decimal interestInEuro = currentYearCumulatedValues.get('interestInEuro') != null ? (Decimal) currentYearCumulatedValues.get('interestInEuro') : 0;
            Decimal vUndVInEuro = incomeInEuro - afaInEuro - interestInEuro - verwaltungInEuro;
            currentYearCumulatedValues.put('vUndVGesamtInEuro', vUndVInEuro);

            // Steuern
            if(this.c.ZuVersteuerndesEinkommen__c != null) {
                Decimal taxDifference = calculateTaxDifferenceForCurrentYear(vUndVInEuro, year);
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
            yearlyValuesMap.put(year, currentYearCumulatedValues);
            this.yearsPassed++;
            this.cumulatedCost += overageInEuro;
        }
    }

    public void formatValues() {
        for(Map<Integer, Map<String,Object>> currentCumulatedYearlyValues:this.paginatedYearlyValues) {
            formatCumulatedYearlyValues(currentCumulatedYearlyValues, 0);
        }
        for(Map<Integer, Map<String,Object>> currentCumulatedYearlyValues:this.paginatedYearlyValuesForLiquidity) {
            formatCumulatedYearlyValues(currentCumulatedYearlyValues, 0);
        }
        formatCumulatedYearlyValues(this.cumulatedYearlyValues, 2);
        formatCumulatedYearlyValues(this.cumulatedYearlyValuesBezugsphase, 0);

        for(Integer year:this.firstYearAfterPaymentValues.keySet()) {
            Map<String, Object> currentYearValues = this.firstYearAfterPaymentValues.get(year);
            // Zinsen gesamt
            if(currentYearValues.get('interestInEuro') != null) {
                Decimal interestInEuro = (Decimal)currentYearValues.get('interestInEuro');
                currentYearValues.put('interestInEuro', getFormattedNumber(interestInEuro));
            }

            if(currentYearValues.get('repaymentInEuro') != null) {
                // Tilgung gesamt
                Decimal repaymentInEuro = (Decimal)currentYearValues.get('repaymentInEuro');
                currentYearValues.put('repaymentInEuro', getFormattedNumber(repaymentInEuro));
            }

            // Rate gesamt
            if(currentYearValues.get('rateInEuro') != null) {
                Decimal rateInEuro = (Decimal)currentYearValues.get('rateInEuro');
                currentYearValues.put('rateInEuro', getFormattedNumber(rateInEuro));
            }

            // Darlehensstand start gesamt
            if(currentYearValues.get('creditSumStartInEuro') != null) {
                Decimal creditSumStartInEuro = (Decimal)currentYearValues.get('creditSumStartInEuro');
                currentYearValues.put('creditSumStartInEuro', getFormattedNumber(creditSumStartInEuro));
            }

            // Darlehenststand Ende gesamt
            if(currentYearValues.get('creditSumEndInEuro') != null) {
                Decimal creditSumEndInEuro = (Decimal)currentYearValues.get('creditSumEndInEuro');
                currentYearValues.put('creditSumEndInEuro', getFormattedNumber(creditSumEndInEuro));
            }

            // Mieteinnahmen pro Apartment
            Map<String, Decimal> apartmentNameToRent = (Map<String, Decimal>)currentYearValues.get('apartments');
            Map<String, String> newApartmentNameToRent = new Map<String, String>();
            for(String key:apartmentNameToRent.keySet()) {
                Decimal rent = apartmentNameToRent.get(key);
                newApartmentNameToRent.put(key, getFormattedNumber(rent));
            }
            currentYearValues.put('apartments', newApartmentNameToRent);

            // Miete gesamt
            Decimal rentInEuro = (Decimal)currentYearValues.get('rentInEuro');
            currentYearValues.put('rentInEuro', getFormattedNumber(rentInEuro));

            // Verwaltung gesamt
            Decimal verwaltungInEuro = (Decimal)currentYearValues.get('verwaltungGesamtInEuro');
            currentYearValues.put('verwaltungGesamtInEuro', getFormattedNumber(verwaltungInEuro));

            // Instandhaltung gesamt
            Decimal instandHaltungInEuro = (Decimal)currentYearValues.get('instandhaltungGesamtInEuro');
            currentYearValues.put('instandhaltungGesamtInEuro', getFormattedNumber(instandHaltungInEuro));

            // Afa gesamt
            Decimal afaInEuro = (Decimal)currentYearValues.get('afaGesamtInEuro');
            currentYearValues.put('afaGesamtInEuro', getFormattedNumber(afaInEuro));

            // vUndV in Euro gesamt
            Decimal vUndVInEuro = (Decimal)currentYearValues.get('vUndVGesamtInEuro');
            currentYearValues.put('vUndVGesamtInEuro', getFormattedNumber(vUndVInEuro));

            // Steuern
            if(currentYearValues.get('taxesInEuro') != null) {
                Decimal taxesInEuro = (Decimal)currentYearValues.get('taxesInEuro');
                currentYearValues.put('taxesInEuro', getFormattedNumber(taxesInEuro));
            }

            // Einnahmen gesamt
            Decimal incomeInEuro = (Decimal)currentYearValues.get('incomeInEuro');
            currentYearValues.put('incomeInEuro', getFormattedNumber(incomeInEuro));

            // Ausgaben gesamt
            Decimal expenditureInEuro = (Decimal)currentYearValues.get('expenditureInEuro');
            currentYearValues.put('expenditureInEuro', getFormattedNumber(expenditureInEuro));

            // Überschuss gesamt
            Decimal overageInEuro = (Decimal)currentYearValues.get('yearlyOverageInEuro');
            currentYearValues.put('yearlyOverageInEuro', getFormattedNumber(overageInEuro));

            // Überschuss gesamt pro Monat
            currentYearValues.put('monthlyOverageInEuro', getFormattedNumber(overageInEuro/12));

            // Überschuss gesamte Laufzeit 
            Decimal overageGesamtInEuro = (Decimal)currentYearValues.get('overageGesamtInEuro');
            if(overageGesamtInEuro != null) {
                currentYearValues.put('overageGesamtInEuro', getFormattedNumber(overageGesamtInEuro));
            }

            // Überschuss gesamte Laufzeit 
            Decimal percentageSelf = (Decimal)currentYearValues.get('percentageSelf');
            if(percentageSelf != null) {
                currentYearValues.put('percentageSelf', getFormattedNumber(percentageSelf));
            }

            // Überschuss gesamte Laufzeit 
            Decimal percentageTenant = (Decimal)currentYearValues.get('percentageTenant');
            if(percentageTenant != null) {
                currentYearValues.put('percentageTenant', getFormattedNumber(percentageTenant));
            }

            // Eigenkapitalrendite 
            Decimal eigenkapitalRendite = (Decimal)currentYearValues.get('eigenkapitalRendite');
            if(eigenkapitalRendite != null) {
                currentYearValues.put('eigenkapitalRendite', getFormattedNumber(eigenkapitalRendite));
            }

            this.firstYearAfterPaymentValues.put(year, currentYearValues);
        }

        for(FinanceModule fm:this.financeModules) {
            for(Integer year:fm.yearlyValues.keySet()) {
                Map<String, Object> currentYearValues = fm.yearlyValues.get(year);
                // Zinsen gesamt
                Decimal interestInEuro = (Decimal)currentYearValues.get('interestInEuro');
                currentYearValues.put('interestInEuro', getFormattedNumber(interestInEuro));
    
                // Tilgung gesamt
                Decimal repaymentInEuro = (Decimal)currentYearValues.get('repaymentInEuro');
                currentYearValues.put('repaymentInEuro', getFormattedNumber(repaymentInEuro));
    
                // Rate gesamt
                Decimal rateInEuro = (Decimal)currentYearValues.get('rateInEuro');
                currentYearValues.put('rateInEuro', getFormattedNumber(rateInEuro));
    
                // Darlehensstand start gesamt
                Decimal creditSumStartInEuro = (Decimal)currentYearValues.get('creditSumStartInEuro');
                currentYearValues.put('creditSumStartInEuro', getFormattedNumber(creditSumStartInEuro));
    
                // Darlehenststand Ende gesamt
                Decimal creditSumEndInEuro = (Decimal)currentYearValues.get('creditSumEndInEuro');
                currentYearValues.put('creditSumEndInEuro', getFormattedNumber(creditSumEndInEuro));
            }
        }

        Decimal rentInEuro = (Decimal)this.sumsForLiquidity.get('rentInEuro');
        this.sumsForLiquidity.put('rentInEuro', getFormattedNumber(rentInEuro));

        Decimal interestInEuro = (Decimal)this.sumsForLiquidity.get('interestInEuro');
        this.sumsForLiquidity.put('interestInEuro', getFormattedNumber(interestInEuro));

        Decimal repaymentInEuro = (Decimal)this.sumsForLiquidity.get('repaymentInEuro');
        this.sumsForLiquidity.put('repaymentInEuro', getFormattedNumber(repaymentInEuro));

        Decimal verwaltungGesamtInEuro = Math.abs((Decimal)this.sumsForLiquidity.get('verwaltungGesamtInEuro'));
        this.sumsForLiquidity.put('verwaltungGesamtInEuro', getFormattedNumber(verwaltungGesamtInEuro));

        Decimal instandhaltungGesamtInEuro = Math.abs((Decimal)this.sumsForLiquidity.get('instandhaltungGesamtInEuro'));
        this.sumsForLiquidity.put('instandhaltungGesamtInEuro', getFormattedNumber(instandhaltungGesamtInEuro));

        Decimal taxesInEuro = Math.abs((Decimal)this.sumsForLiquidity.get('taxesInEuro'));
        this.sumsForLiquidity.put('taxesInEuro', getFormattedNumber(taxesInEuro));

        Decimal monthlyOverageInEuro = Math.abs((Decimal)this.sumsForLiquidity.get('monthlyOverageInEuro'));
        this.sumsForLiquidity.put('monthlyOverageInEuro', getFormattedNumber(monthlyOverageInEuro));

        Decimal yearlyOverageInEuro = Math.abs((Decimal)sumsForLiquidity.get('yearlyOverageInEuro'));
        sumsForLiquidity.put('yearlyOverageInEuro', getFormattedNumber(yearlyOverageInEuro));

        Decimal monthlyOverageInEuroTotal = Math.abs((Decimal)sumsForLiquidity.get('monthlyOverageInEuroTotal'));
        sumsForLiquidity.put('monthlyOverageInEuroTotal', getFormattedNumber(monthlyOverageInEuroTotal));

        Decimal yearlyOverageInEuroTotal = Math.abs((Decimal)sumsForLiquidity.get('yearlyOverageInEuroTotal'));
        sumsForLiquidity.put('yearlyOverageInEuroTotal', getFormattedNumber(yearlyOverageInEuroTotal));

        Decimal totalSalesValue = Math.abs((Decimal)sumsForLiquidity.get('totalSalesValue'));
        sumsForLiquidity.put('totalSalesValue', getFormattedNumber(totalSalesValue));

        Decimal creditSumEndInEuro = Math.abs((Decimal)sumsForLiquidity.get('creditSumEndInEuro'));
        sumsForLiquidity.put('creditSumEndInEuro', getFormattedNumber(creditSumEndInEuro));

        Decimal networthEndInEuro = Math.abs((Decimal)sumsForLiquidity.get('networthEndInEuro'));
        sumsForLiquidity.put('networthEndInEuro', getFormattedNumber(networthEndInEuro));

        Decimal interestInPercentTotal = Math.abs((Decimal)sumsForLiquidity.get('interestInPercentTotal'));
        sumsForLiquidity.put('interestInPercentTotal', getFormattedNumber(interestInPercentTotal));

        Decimal selfPercentTotal = Math.abs((Decimal)sumsForLiquidity.get('selfPercentTotal'));
        sumsForLiquidity.put('selfPercentTotal', getFormattedNumber(selfPercentTotal));

        Decimal interestBauzeitInEuroTotal = (Decimal)this.creditInformation.get('interestBauzeitInEuroTotal');
        this.creditInformation.put('interestBauzeitInEuroTotal', getFormattedNumber(interestBauzeitInEuroTotal));

        Decimal interestInPercentBankTotal = (Decimal)this.creditInformation.get('interestInPercentBankTotal');
        this.creditInformation.put('interestInPercentBankTotal', getFormattedNumber(interestInPercentBankTotal));

        interestInPercentTotal = (Decimal)this.creditInformation.get('interestInPercentTotal');
        this.creditInformation.put('interestInPercentTotal', getFormattedNumber(interestInPercentTotal));

        Decimal kfwInEuro = (Decimal)this.creditInformation.get('kfwInEuro');
        this.creditInformation.put('kfwInEuro', getFormattedNumber(kfwInEuro));

        Decimal kfwInterest = (Decimal)this.creditInformation.get('kfwInterest');
        this.creditInformation.put('kfwInterest', getFormattedNumber(kfwInterest));

        Decimal bankInEuro = (Decimal)this.creditInformation.get('bankInEuro');
        this.creditInformation.put('bankInEuro', getFormattedNumber(bankInEuro));

        for(Integer i = 0; i < 7; i++) {
            Decimal ekInEuro = (Decimal)this.creditInformation.get('ekInEuro' + (i+1));
            this.creditInformation.put('ekInEuro' + (i+1), getFormattedNumber(ekInEuro));

            kfwInEuro = (Decimal)this.creditInformation.get('kfwInEuro' + (i+1));
            this.creditInformation.put('kfwInEuro' + (i+1), getFormattedNumber(kfwInEuro));

            bankInEuro = (Decimal)this.creditInformation.get('bankInEuro' + (i+1));
            this.creditInformation.put('bankInEuro' + (i+1), getFormattedNumber(bankInEuro));

            interestInEuro = (Decimal)this.creditInformation.get('interestInEuro' + (i+1));
            this.creditInformation.put('interestInEuro' + (i+1), getFormattedNumber(interestInEuro));

            Decimal costSumInEuro = (Decimal)this.creditInformation.get('costSumInEuro' + (i+1));
            this.creditInformation.put('costSumInEuro' + (i+1), getFormattedNumber(costSumInEuro));
        }
    }

    public String getFormattedNumber(Decimal dec) {
        dec = dec.setScale(2, RoundingMode.HALF_UP);
        String amount;
        if(!dec.format().right(3).contains(',')) {
            return dec.format() + ',00';
        }else if(dec.format().right(2).contains(',')) {
            return dec.format() + '0';
        }else {
            return (String)dec.format();
        }
    }

    public void formatCumulatedYearlyValues(Map<Integer, Map<String, Object>> currentCumulatedYearlyValues, Integer scale) {
        for(Integer year:currentCumulatedYearlyValues.keySet()) {
            Map<String, Object> currentYearCumulatedValues = currentCumulatedYearlyValues.get(year);
            // Zinsen gesamt
            Decimal interestInEuro = (Decimal)currentYearCumulatedValues.get('interestInEuro');
            currentYearCumulatedValues.put('interestInEuro', getFormattedNumber(interestInEuro));

            // Tilgung gesamt
            Decimal repaymentInEuro = (Decimal)currentYearCumulatedValues.get('repaymentInEuro');
            currentYearCumulatedValues.put('repaymentInEuro', getFormattedNumber(repaymentInEuro));

            // Rate gesamt
            Decimal rateInEuro = (Decimal)currentYearCumulatedValues.get('rateInEuro');
            currentYearCumulatedValues.put('rateInEuro', getFormattedNumber(rateInEuro));

            // Darlehensstand start gesamt
            Decimal creditSumStartInEuro = (Decimal)currentYearCumulatedValues.get('creditSumStartInEuro');
            currentYearCumulatedValues.put('creditSumStartInEuro', getFormattedNumber(creditSumStartInEuro));

            // Darlehenststand Ende gesamt
            Decimal creditSumEndInEuro = (Decimal)currentYearCumulatedValues.get('creditSumEndInEuro');
            currentYearCumulatedValues.put('creditSumEndInEuro', getFormattedNumber(creditSumEndInEuro));

            // Mieteinnahmen pro Apartment
            Map<String, Decimal> apartmentNameToRent = (Map<String, Decimal>)currentYearCumulatedValues.get('apartments');
            Map<String, String> newApartmentNameToRent = new Map<String, String>();
            for(String key:apartmentNameToRent.keySet()) {
                Decimal rent = apartmentNameToRent.get(key);
                newApartmentNameToRent.put(key, getFormattedNumber(rent));
            }
            currentYearCumulatedValues.put('apartments', newApartmentNameToRent);

            // Miete gesamt
            Decimal rentInEuro = (Decimal)currentYearCumulatedValues.get('rentInEuro');
            currentYearCumulatedValues.put('rentInEuro', getFormattedNumber(rentInEuro));

            // Verwaltung gesamt
            Decimal verwaltungInEuro = (Decimal)currentYearCumulatedValues.get('verwaltungGesamtInEuro');
            currentYearCumulatedValues.put('verwaltungGesamtInEuro', getFormattedNumber(verwaltungInEuro));

            // Instandhaltung gesamt
            Decimal instandHaltungInEuro = (Decimal)currentYearCumulatedValues.get('instandhaltungGesamtInEuro');
            currentYearCumulatedValues.put('instandhaltungGesamtInEuro', getFormattedNumber(instandHaltungInEuro));

            // Afa gesamt
            Decimal afaInEuro = (Decimal)currentYearCumulatedValues.get('afaGesamtInEuro');
            currentYearCumulatedValues.put('afaGesamtInEuro', getFormattedNumber(afaInEuro));

            // vUndV in Euro gesamt
            Decimal vUndVInEuro = (Decimal)currentYearCumulatedValues.get('vUndVGesamtInEuro');
            currentYearCumulatedValues.put('vUndVGesamtInEuro', getFormattedNumber(vUndVInEuro));

            // Steuern
            if(currentYearCumulatedValues.get('taxesInEuro') != null) {
                Decimal taxesInEuro = (Decimal)currentYearCumulatedValues.get('taxesInEuro');
                currentYearCumulatedValues.put('taxesInEuro', getFormattedNumber(taxesInEuro));
            }

            // Einnahmen gesamt
            Decimal incomeInEuro = (Decimal)currentYearCumulatedValues.get('incomeInEuro');
            currentYearCumulatedValues.put('incomeInEuro', getFormattedNumber(incomeInEuro));

            // Ausgaben gesamt
            Decimal expenditureInEuro = (Decimal)currentYearCumulatedValues.get('expenditureInEuro');
            currentYearCumulatedValues.put('expenditureInEuro', getFormattedNumber(expenditureInEuro));

            // Überschuss gesamt pro Jahr
            Decimal overageInEuro = (Decimal)currentYearCumulatedValues.get('yearlyOverageInEuro');
            currentYearCumulatedValues.put('yearlyOverageInEuro', getFormattedNumber(overageInEuro));

            // Überschuss gesamt pro Monat
            currentYearCumulatedValues.put('monthlyOverageInEuro', getFormattedNumber(overageInEuro/12));
        }
    }

    public void calculateLiquiditySums() {
        Decimal rentTotal = 0;
        Decimal interestTotal = 0;
        Decimal repaymentTotal = 0;
        Decimal verwaltungTotal = 0;
        Decimal instandhaltungTotal = 0;
        Decimal taxTotal = 0;
        Decimal liquidityMonthlyAverage = 0;
        Decimal liquidityYearlyAverage = 0;
        Decimal liquidityMonthlyTotal = 0;
        Decimal liquidityYearlyTotal = 0;

        Integer counter = 0;
        for(Map<Integer, Map<String,Object>> yearValues:this.paginatedYearlyValuesForLiquidity) {
            for(Map<String,Object> currentYearlyValues:yearValues.values()){
                rentTotal += (Decimal) currentYearlyValues.get('rentInEuro');
                interestTotal += (Decimal) currentYearlyValues.get('interestInEuro');
                repaymentTotal += (Decimal) currentYearlyValues.get('repaymentInEuro');
                verwaltungTotal += (Decimal) currentYearlyValues.get('verwaltungGesamtInEuro');
                instandhaltungTotal += (Decimal) currentYearlyValues.get('instandhaltungGesamtInEuro');
                taxTotal += (Decimal) currentYearlyValues.get('taxesInEuro');
                liquidityMonthlyAverage += (Decimal) currentYearlyValues.get('monthlyOverageInEuro');
                liquidityYearlyAverage += (Decimal) currentYearlyValues.get('yearlyOverageInEuro');
                liquidityMonthlyTotal += (Decimal) currentYearlyValues.get('monthlyOverageInEuro');
                liquidityYearlyTotal += (Decimal) currentYearlyValues.get('yearlyOverageInEuro');
                counter++;
            }
        }

        if(counter == 0) {
            counter = 1;
        }

        liquidityMonthlyAverage = liquidityMonthlyAverage / counter;
        liquidityYearlyAverage = liquidityYearlyAverage / counter;

        sumsForLiquidity = new Map<String, Object>();
        sumsForLiquidity.put('rentInEuro', rentTotal);
        sumsForLiquidity.put('interestInEuro', interestTotal);
        sumsForLiquidity.put('repaymentInEuro', repaymentTotal);
        sumsForLiquidity.put('verwaltungGesamtInEuro', verwaltungTotal);
        sumsForLiquidity.put('instandhaltungGesamtInEuro', instandhaltungTotal);
        sumsForLiquidity.put('taxesInEuro', taxTotal);
        sumsForLiquidity.put('taxesInEuroClass', taxTotal < 0 ? 'negative-value' : '');
        sumsForLiquidity.put('monthlyOverageInEuro', liquidityMonthlyAverage);
        sumsForLiquidity.put('monthlyOverageInEuroClass', liquidityMonthlyAverage < 0 ? 'negative-value' : '');
        sumsForLiquidity.put('yearlyOverageInEuro', liquidityYearlyAverage);
        sumsForLiquidity.put('yearlyOverageInEuroClass', liquidityYearlyAverage < 0 ? 'negative-value' : '');
        sumsForLiquidity.put('monthlyOverageInEuroTotal', liquidityMonthlyTotal);
        sumsForLiquidity.put('monthlyOverageInEuroTotalClass', liquidityMonthlyTotal < 0 ? 'negative-value' : '');
        sumsForLiquidity.put('yearlyOverageInEuroTotal', liquidityYearlyTotal);
        sumsForLiquidity.put('yearlyOverageInEuroTotalClass', liquidityYearlyTotal < 0 ? 'negative-value' : '');
        // Verkaufswert Immobilie
        Decimal totalSalesValue = this.c.SumPurchasePrice__c * Math.pow((Double)1.05, (Double)Math.floor(getMaxYears() / 5));
        sumsForLiquidity.put('totalSalesValue', totalSalesValue);
        // Restschuld Darlehen 
        Decimal creditSumEndInEuro = (Decimal)this.cumulatedYearlyValues.get(this.firstYear+getMaxYears()-1).get('creditSumEndInEuro');
        sumsForLiquidity.put('creditSumEndInEuro', creditSumEndInEuro);
        Decimal networthEndInEuro = totalSalesValue - creditSumEndInEuro - this.c.Eigenkapital__c + liquidityYearlyTotal;
        sumsForLiquidity.put('networthEndInEuro', networthEndInEuro);
        Decimal interestInPercentTotal = calculateInterestForSavingComparison(networthEndInEuro+this.c.Eigenkapital__c+Math.abs(liquidityYearlyTotal), this.c.Eigenkapital__c, liquidityMonthlyAverage*-1, getMaxYears());
        sumsForLiquidity.put('interestInPercentTotal', interestInPercentTotal);
        sumsForLiquidity.put('maxYears', getMaxYears());
        // EK Rendite
        //Mietertrag – (Zinszahlungen + Verwaltungskosten) = Jahresreinertrag
        //(Jahresreinertrag / Eigenkapital) * 100 = Eigenkapitalrendite in Prozent
        Decimal selfPercentTotal = 0;
        if(this.c.Eigenkapital__c != null && this.c.Eigenkapital__c != 0) {
            selfPercentTotal = ((Decimal)this.cumulatedYearlyValues.get(this.firstYear+getMaxYears()-1).get('rentInEuro') - ((Decimal)this.cumulatedYearlyValues.get(this.firstYear+getMaxYears()-1).get('interestInEuro') + (Decimal)this.cumulatedYearlyValues.get(this.firstYear+getMaxYears()-1).get('verwaltungGesamtInEuro'))) / this.c.Eigenkapital__c * 100;
        }
        sumsForLiquidity.put('selfPercentTotal', selfPercentTotal);
    }   

    public Integer getMaxYears() {
        return (Integer)this.c.BetrachtungszeitraumInJahren__c > this.cumulatedYearlyValues.size() ? this.cumulatedYearlyValues.size() : (Integer)this.c.BetrachtungszeitraumInJahren__c;
    }

    public Decimal calculateInterestForSavingComparison(Decimal networthEnd, Decimal networthStart, Decimal savingsRate, Integer timeInYears) {
        Integer timeInMonths = timeInYears * 12;
        Decimal q = 1.0200000000000000000000000000;
        for(Integer i = 0; i < 15; i++) { 
            q = approximateNumber(q, networthStart, networthEnd, savingsRate, timeInMonths);
            System.debug(q);
        }
        Decimal interest = (q-1)*12;
        return ((1+interest/12).pow(12)-1)*100;
    }

    public Decimal approximateNumber(Decimal q, Decimal networthStart, Decimal networthEnd, Decimal savingsRate, Integer timeInMonths) {
        return q-(networthStart*q.pow((timeInMonths + 1))-(networthStart-savingsRate)*q.pow(timeInMonths)-networthEnd*(q-1)-savingsRate).divide(((timeInMonths +1)*networthStart*q.pow(timeInMonths)-timeInMonths*(networthStart-savingsRate)*q.pow((timeInMonths - 1))-networthEnd), 30);
    }

    public void generatePagination() {
        Integer pagebreak = 29;
        if(this.financeModules != null) {
            pagebreak = pagebreak - this.financeModules.size();
        }
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
        Map<Integer, Map<String,Object>> cumulatedYearlyValuesCopy = deepCopyExistingStructure(cumulatedYearlyValues);
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

        Integer pagebreakLiquidity = 22;
        counter = 0;   
        Map<Integer, Map<String, Object>> currentYearlyValuesLiqiduity = new Map<Integer, Map<String, Object>>();
        Map<Integer, Map<String,Object>> cumulatedYearlyValuesForLiquidityCopy = deepCopyExistingStructure(cumulatedYearlyValues);
        Decimal maxYears = this.c.BetrachtungszeitraumInJahren__c != null ? getMaxYears() : 20;
        for(Integer year:cumulatedYearlyValuesForLiquidityCopy.keySet()) {
            Integer currentPage = (Integer)Math.floor(counter/pagebreakLiquidity);
            Map<String,Object> yearlyValue = cumulatedYearlyValuesForLiquidityCopy.get(year);
            currentYearlyValuesLiqiduity.put(year, yearlyValue);
            counter++;
            if(Math.mod(counter, pagebreakLiquidity) == 0 || counter == maxYears) {
                this.paginatedYearlyValuesForLiquidity.add(currentYearlyValuesLiqiduity);         
                currentYearlyValuesLiqiduity = new Map<Integer, Map<String, Object>>();
            }
            if(maxYears == counter) {
                break;
            }
        }
        this.liquidityPages = (Integer) Math.ceil(totalYears / pagebreakLiquidity);
    }

    Decimal calculateAfa(Decimal privateFactor) {
        Decimal afaInEuro = 0;
        for(BerechnungsApartment__c ba:this.c.Berechnungs_Apartments__r) {
            if(this.yearsPassed <= Math.round(100/ba.AfAAussenanlagenProJahrInProzent__c)) {
                afaInEuro += ba.AfAAussenanlagenProJahrInEuro__c;
            }

            for(AfaWert__c afaWert:afa.AfaWerte__r) {
                if((this.yearsPassed+1) <= afaWert.JahrBis__c && (this.yearsPassed+1) >= afaWert.JahrVon__c) {
                    Decimal restwert = this.berechnungsApartmentToRestwert.get(ba.Id);
                    if(restwert == null) {
                        restwert = ba.AFAGrundlage__c;
                    }
                    if(afaWert.Berechnung__c == 'Restwert') {
                        afaInEuro += afaWert.AfaInProzent__c * restwert / 100;
                        restwert -= afaWert.AfaInProzent__c * restwert / 100 * privateFactor;
                    } else {
                        afaInEuro += afaWert.AfaInProzent__c * ba.AFAGrundlage__c / 100;
                        restwert -= afaWert.AfaInProzent__c * ba.AFAGrundlage__c / 100 * privateFactor;
                    }
                    this.berechnungsApartmentToRestwert.put(ba.Id, restwert);
                }
            }
        }
        return afaInEuro*privateFactor;   
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