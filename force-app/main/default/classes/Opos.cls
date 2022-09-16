public without sharing class Opos {
    public Decimal soll;
    public Decimal haben;
    public Date zahldatum;
    public String bsnr;
    public Decimal betrag;
    
    public Opos(String soll, String haben, String zahldatum, String bsnr) {
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
    }
}