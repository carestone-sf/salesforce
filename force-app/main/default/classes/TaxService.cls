public with sharing class TaxService {
    public TaxService() {

    }

    public static Decimal getPensionTaxPercentage(Integer year) {
        if(year < 2005) {
            return 0.5;
        } else if(year > 2040) {
            return 1;
        } else {
            return getPensionTaxPercentageMap().get(year);
        }
    }

    public static Map<Integer, Decimal> getPensionTaxPercentageMap() {
        Map<Integer, Decimal> pensionTaxPercentageMap = new Map<Integer, Decimal>();
        pensionTaxPercentageMap.put(2005, 0.5);
        pensionTaxPercentageMap.put(2006, 0.52);
        pensionTaxPercentageMap.put(2007, 0.54);
        pensionTaxPercentageMap.put(2008, 0.56);
        pensionTaxPercentageMap.put(2009, 0.58);
        pensionTaxPercentageMap.put(2010, 0.6);
        pensionTaxPercentageMap.put(2011, 0.62);
        pensionTaxPercentageMap.put(2012, 0.64);
        pensionTaxPercentageMap.put(2013, 0.66);
        pensionTaxPercentageMap.put(2014, 0.68);
        pensionTaxPercentageMap.put(2015, 0.7);
        pensionTaxPercentageMap.put(2016, 0.72);
        pensionTaxPercentageMap.put(2017, 0.74);
        pensionTaxPercentageMap.put(2018, 0.76);
        pensionTaxPercentageMap.put(2019, 0.78);
        pensionTaxPercentageMap.put(2020, 0.8);
        pensionTaxPercentageMap.put(2021, 0.81);
        pensionTaxPercentageMap.put(2022, 0.82);
        pensionTaxPercentageMap.put(2023, 0.83);
        pensionTaxPercentageMap.put(2024, 0.84);
        pensionTaxPercentageMap.put(2025, 0.85);
        pensionTaxPercentageMap.put(2026, 0.86);
        pensionTaxPercentageMap.put(2027, 0.87);
        pensionTaxPercentageMap.put(2028, 0.88);
        pensionTaxPercentageMap.put(2029, 0.89);
        pensionTaxPercentageMap.put(2030, 0.9);
        pensionTaxPercentageMap.put(2031, 0.91);
        pensionTaxPercentageMap.put(2032, 0.92);
        pensionTaxPercentageMap.put(2033, 0.93);
        pensionTaxPercentageMap.put(2034, 0.94);
        pensionTaxPercentageMap.put(2035, 0.95);
        pensionTaxPercentageMap.put(2036, 0.96);
        pensionTaxPercentageMap.put(2037, 0.97);
        pensionTaxPercentageMap.put(2038, 0.98);
        pensionTaxPercentageMap.put(2039, 0.99);
        pensionTaxPercentageMap.put(2040, 1);
        return pensionTaxPercentageMap;
    }
}