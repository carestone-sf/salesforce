public without sharing class CalculationQuoteController {
    public final Berechnung__c calculation;
    public FinanceCalculator fc;
    
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public CalculationQuoteController(ApexPages.StandardController stdController) {
        this.calculation = (Berechnung__c)stdController.getRecord();
        this.fc = new FinanceCalculator();
        this.fc.initFinanceModules(this.calculation.Id);
        this.fc.formatValues();
        this.fc.generatePagination();
        if(this.fc.c.Finanzierungsart__c == 'Bar') {
            this.fc.cumulatedYearlyValues.put(this.fc.firstFullYear, new Map<String, Object>());
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('interestInEuro', '');
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('repaymentInEuro', 0);
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('apartments', new Map<String, Decimal>());
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('taxesInEuro', 0);
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('rentInEuro', 0);
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('taxes', 0);
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('overageGesamtInEuro', 0);
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('percentageSelf', 0);
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('percentageTenant', 0);
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('verwaltungGesamtInEuro', 0);
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('instandhaltungGesamtInEuro', 0);
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('afaGesamtInEuro', 0);
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('vUndVGesamtInEuro', 0);
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('incomeInEuro', '');
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('expenditureInEuro', '');
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('yearlyOverageInEuro', '');
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('monthlyOverageInEuro', '');
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('creditSumStartInEuro', '');
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('creditSumEndInEuro', '');
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('rateInEuro', '');
            this.fc.cumulatedYearlyValues.get(this.fc.firstFullYear).put('eigenkapitalRendite', 0);
        }
    }
 
    public List<FinanceCalculator.FinanceModule> getFinanceModules() {
        return this.fc.financeModules;
    }

    public Map<Integer, Map<String, Object>> getCumulatedYearlyValues() {
        return this.fc.cumulatedYearlyValues;
    }

    public List<Map<Integer, Map<String, Object>>> getPaginatedYearlyValues() {
        return this.fc.paginatedYearlyValues;
    }

    public Map<Integer, Map<String, Object>> getFirstYearAfterPaymentValues() {
        return this.fc.firstYearAfterPaymentValues;
    }

    public Integer getPages() {
        return this.fc.pages;
    }

    public Integer getFirstYear() {
        return this.fc.firstYear;
    }

    public Integer getLastYear() {
        return this.fc.lastYear;
    }

    public Integer getFirstFullYear() {
        return this.fc.firstFullYear;
    }

    public Integer getFirstYearAfterPayment() {
        return this.fc.firstYearAfterPayment;
    }
}