public without sharing class Opos {
    public Decimal soll;
    public Decimal haben;
    public Date zahldatum;
    public String bsnr;
    public Decimal betrag;
    public String buchungstext;
    public String businessPartner;
    public String IBAN;
    public String BIC;

    
    public Opos(String soll, String haben, String zahldatum, String bsnr, String buchungstext, String beleginfo1, String beleginfo2, String beleginfo3) {
        this.soll = Decimal.valueOf(soll.replace('.', '').replace(',', '.'));
        this.haben = Decimal.valueOf(haben.replace('.', '').replace(',', '.'));
        this.betrag = this.soll > 0 ? this.soll : (this.haben * -1);
        if(zahldatum != null && zahldatum.startsWith('"') && zahldatum.endsWith('"')) {
            zahldatum = zahldatum.substring(1, zahldatum.length()-1);
        }
        if(zahldatum != null && !String.isBlank(zahldatum)) {
            Integer day = Integer.valueOf(zahldatum.substring(0, 2));
            Integer month = Integer.valueOf(zahldatum.substring(3, 5));
            Integer year = Integer.valueOf(zahldatum.substring(6, 10));
            this.zahldatum = Date.newInstance(year, month, day);
        }
        if(bsnr != null && bsnr.startsWith('"') && bsnr.endsWith('"')) {
            bsnr = bsnr.substring(1, bsnr.length()-1);
        }
        this.bsnr = bsnr;
        this.buchungstext = buchungstext;
        getTransactionInformation(beleginfo1);
        getTransactionInformation(beleginfo2);
        getTransactionInformation(beleginfo3);
    }

    /**
     * Extracts IBAN and Business Partner Information
     */
    public void getTransactionInformation(String beleginfo) {
        //Format IBAN: '...IBAN "DE84255914133156606504"...
        Integer indexIBANText = beleginfo.indexOf('IBAN "');
        if(indexIBANText > -1) {
            Integer indexIBANNumberStart = beleginfo.indexOf('"', indexIBANText);
            Integer indexIBANNumberEnd = beleginfo.indexOf('"', indexIBANNumberStart+1);
            this.IBAN = beleginfo.substring(indexIBANNumberStart+1,indexIBANNumberEnd);
        }
        //Format BIC: '...BIC "GENODEF1NIN"...'
        Integer indexBICText = beleginfo.indexOf('BIC "');
        if(indexBICText > -1) {
            Integer indexBICNumberStart = beleginfo.indexOf('"', indexBICText);
            Integer indexBICNumberEnd = beleginfo.indexOf('"', indexBICNumberStart+1);
            this.BIC = beleginfo.substring(indexBICNumberStart+1,indexBICNumberEnd);
        }

        //Format Gesch.Partner: '...Gesch.partner "CARESTONE PROJEKT I GMBH"...'
        Integer indexBusinessPartnerText = beleginfo.indexOf('Gesch.partner "');
        if(indexBusinessPartnerText > -1) {
            Integer indexBusinessPartnerNameStart = beleginfo.indexOf('"', indexBusinessPartnerText);
            Integer indexBusinessPartnerNameEnd = beleginfo.indexOf('"', indexBusinessPartnerNameStart+1);
            this.businessPartner = beleginfo.substring(indexBusinessPartnerNameStart+1,indexBusinessPartnerNameEnd);
        }
    }
}