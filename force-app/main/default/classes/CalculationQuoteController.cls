public without sharing class CalculationQuoteController {
    public final Berechnung__c calculation;
    public FinanceCalculator fc;
    public Map<Integer, String> calcSonder {get;set;}
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public CalculationQuoteController(ApexPages.StandardController stdController) {
        this.calculation = (Berechnung__c)stdController.getRecord();
        this.fc = new FinanceCalculator();
        this.fc.initFinanceModules(this.calculation.Id);
        this.fc.generatePagination();
        this.fc.formatValues();
        this.calcSonder = this.fc.calcSondertilgung(this.calculation.Id, getPaginatedYearlyValues());
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

    public Decimal getSumSBetragplusFKreditsumme() {
        return this.fc.sumSBetragplusFKreditsumme;
    }
}