public without sharing class CalculationQuoteController {
    public final Berechnung__c calculation;
    public FinanceCalculator fc;
    public Map<String, Map<Integer, String>> calcSonder {get;set;}
    // The extension constructor initializes the private member
    // variable acct by using the getRecord method from the standard
    // controller.
    public CalculationQuoteController(ApexPages.StandardController stdController) {
        this.calculation = (Berechnung__c)stdController.getRecord();
        this.fc = new FinanceCalculator();
        this.fc.initFinanceModules(this.calculation.Id);
        this.fc.generatePagination();
        this.fc.calculateLiquiditySums();
        this.fc.calculateCreditInformation();
        this.fc.formatValues();
        this.calcSonder = this.fc.calcSondertilgung();
    }
 
    public List<FinanceCalculator.FinanceModule> getFinanceModules() {
        return this.fc.financeModules;
    }

    public Map<Integer, Map<String, Object>> getCumulatedYearlyValues() {
        return this.fc.cumulatedYearlyValues;
    }

    public Map<Integer, Map<String, Object>> getCumulatedYearlyValuesBezugsphase() {
        return this.fc.cumulatedYearlyValuesBezugsphase;
    }

    public List<Map<Integer, Map<String, Object>>> getPaginatedYearlyValues() {
        return this.fc.paginatedYearlyValues;
    }

    public List<Map<Integer, Map<String, Object>>> getPaginatedYearlyValuesForLiquidity() {
        return this.fc.paginatedYearlyValuesForLiquidity;
    }

    public Map<String, Object> getSumsForLiquidity() {
        return this.fc.sumsForLiquidity;
    }

    public Map<String, Object> getCreditInformation() {
        return this.fc.creditInformation;
    }

    public Map<Integer, Map<String, Object>> getFirstYearAfterPaymentValues() {
        return this.fc.firstYearAfterPaymentValues;
    }

    public Integer getPages() {
        return this.fc.pages;
    }

    public Integer getLiquidityPages() {
        return this.fc.liquidityPages;
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