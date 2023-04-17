public with sharing class ImmoframeProperty {
    public Id id;
    public String name;
    public Boolean inPreview;
    public Integer countPreviewApartments;
    public String state;
    public String city;
    public String street;
    public String postalCode;
    // Betreutes Wohnen || Pflegeimmobilie
    public String propertyType; 
    public String description;
    // Currently always null, maybe not used
    //Decimal shareRefurbishmentSubstanceInPercent;
    public Decimal yieldInPercent;
    public String googleDriveFolderId;
    public String websiteHeaderImage;
    // Is used or not?
    // public String image; 
    // Currently always null, maybe not used
    //public String highlight;
    public Decimal valuePlotInPercent;
    public String objectVideoLink;
    public String operatorDescription;
    public String operatorLogoUrl;
    public String operatorName;
    public Integer availableApartments;
    public Integer reservedApartments;
    public Integer soldApartments;
    public String infoLineOne;
    public String infoLineTwo;
    public Boolean isPublic;
    public Decimal maxYieldInPercent;
    public Decimal apartmentsMinPriceInEuro;
    public Decimal apartmentsMaxPriceInEuro;
    public Date constructionDate;
    public String energyStandard;
    public List<ImmoframeDocument> documents;
    public List<ImmoframeImage> images;
    public List<ImmoframeApartment> apartments;

    public ImmoframeProperty() {
        this.documents = new List<ImmoframeDocument>();
        this.images = new List<ImmoframeImage>();
        this.apartments = new List<ImmoframeApartment>();
    }

    public class ImmoframeDocument {
        public String name;
        public String url;
        // Aktuell nicht im System
        public String mimeType;
    }

    public class ImmoframeImage {
        //https://drive.google.com/thumbnail?authuser=0&amp;sz=w1920&amp;id=1wMxGCT3QG3LmE304Bb7t9RzRhJz2lZpo
        // Schauen wie wir es machen
        public String fullSizeUrl;
        //https://drive.google.com/thumbnail?authuser=0&amp;sz=w220&amp;id=1wMxGCT3QG3LmE304Bb7t9RzRhJz2lZpo
        // Schauen wie wir es machen
        public String thumbnailUrl;
    }

    public class ImmoframeApartment {
        public Id id;
        public String status;
        public String name;
        public Id propertyId;
        public Decimal purchasePriceInEuro;
        public Decimal areaInSqm;
        public Decimal monthlyRentPerSqmInEuro;
        public Decimal monthlyRentInEuro;
        public Decimal notaryAndCourtCostInEuro;
        public Decimal yearlyMaintenancePerSqmInEuro;
        public Decimal yearlyAdministrationCostInEuro;
        public Decimal deprecationValueInEuro;
        public Decimal realEstateTransferTaxInEuro;
        public Decimal netAssetValueInPercent;
        public Decimal netAssetValueAfaInPercent;
        public Decimal outdoorValueInPercent;
        public Decimal outdoorValueAfaInPercent;
        public Decimal purchasePricePerSqmInEuro;
        public Decimal yieldInPercent;
    }

}