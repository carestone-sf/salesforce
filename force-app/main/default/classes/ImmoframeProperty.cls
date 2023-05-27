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
    public String propertyStatus;
    public boolean showOnWebsite;
    public boolean showOnImmoframe;
    public boolean inspectionByDekra;
    public String immoframeHeadline;
    public String description;
    public String locationDescription;
    // Currently always null, maybe not used
    //Decimal shareRefurbishmentSubstanceInPercent;
    public Decimal yieldInPercent;
    public String googleDriveFolderId;
    public String websiteHeaderImage;
    public ImmoframeImage image; 
    // Currently always null, maybe not used
    //public String highlight;
    public Decimal valuePlotInPercent;
    public String objectVideoLink;
    public String operatorDescription;
    public String operatorLogoUrl;
    public String operatorWebsiteUrl;
    public String operatorName;
    public Integer availableApartments;
    public Integer reservedApartments;
    public Integer soldApartments;
    public String infoLineOne;
    public String infoLineTwo;
    public Boolean isPublic;
    public Decimal minYieldInPercent;
    public Decimal maxYieldInPercent;
    public Decimal apartmentsMinPriceInEuro;
    public Decimal apartmentsMaxPriceInEuro;
    public Decimal apartmentsMinAreaInSqm;
    public Decimal apartmentsMaxAreaInSqm;
    public Date constructionDate;
    public String energyStandard;
    public String constructionProgressUrl;
    public String threeSixtyDegreeTourUrl;
    public String disruptorLogoOne;
    public String disruptorLogoTwo;
    public List<ImmoframeDocument> documents;
    public List<ImmoframeImage> images;
    public List<ImmoframeImage> floorPlans;
    public List<ImmoframeApartment> apartments;

    public ImmoframeProperty() {
        this.documents = new List<ImmoframeDocument>();
        this.images = new List<ImmoframeImage>();
        this.floorPlans = new List<ImmoframeImage>();
        this.apartments = new List<ImmoframeApartment>();
    }

    public class ImmoframeDocument {
        public String name;
        public String url;
        public String mimeType;
    }

    public class ImmoframeImage {
        // Example: https://drive.google.com/thumbnail?authuser=0&amp;sz=w1920&amp;id=1wMxGCT3QG3LmE304Bb7t9RzRhJz2lZpo
        public String fullSizeUrl;
        // Example: https://drive.google.com/thumbnail?authuser=0&amp;sz=w220&amp;id=1wMxGCT3QG3LmE304Bb7t9RzRhJz2lZpo
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