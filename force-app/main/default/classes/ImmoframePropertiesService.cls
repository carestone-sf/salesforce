public class ImmoframePropertiesService {

    public static List<ImmoframeProperty> getImmoframeProperties() {
        List<ImmoframeProperty> immoframeProperties = new List<ImmoframeProperty>();
        List<Property__c> properties = [SELECT Id, Name, In_Vorschau__c, Bauart__c, PressemeldungenIds__c, AehnlicheObjekteIds__c, ShowOnWebsite__c, Lagebeschreibung__c, DisruptorLogoTwo__c, DisruptorLogoOne__c, Vorschau_Appartements__c, InspectionByDekra__c, Url360DegreeTour__c, UrlConstructionProgress__c, ImmoframeHeadline__c, Fl_che_ab__c, Fl_che_bis__c, PropertyStatus__c, State__c, Place__c, Street__c, Zip_Code__c, Property__c, Description__c, Rendite_in__c, Website_Header_Bild__c, Collection_Id__c, Value_Plot__c, Objektvideo_Link__c, Betreiber__r.Betreiberinformationen__c, Betreiber__r.Betreiber_Logo__c, Betreiber__r.Website__c, Betreiber__r.Name, Freie_Appartments__c, Reservierte_Appartements__c, Verkaufte_Appartements__c, Infozeile_1__c, Infozeile_2__c, Is_Public__c, Min_Rendite__c, Max_Rendite__c, Preis_ab__c, Preis_bis__c, Completion__c, MaBV__c, (SELECT Id, OeffentlicherStatus__c, Name, Property__c, Purchase_Price__c, Purchase_Price_sq_m__c, Area_sq_m__c, Monthly_rent_sq_m__c, Monthly_Rent__c, Notary_And_Court_Costs_1_5__c, Maintenance_sqm__c, Cost_Admin__c, Depreciation_Value__c, Real_Estate_Transfer_Tax__c, Net_asset_value__c, Net_Asset_Value_AFA__c, Value_of_OIutdoor__c, Outdoor_AFA__c, Rental_return__c FROM Appartments__r), (SELECT Name, DateiTyp__c, DateiUrl__c, PreviewUrl__c, ThumbnailUrl__c, MimeType__c FROM ImmobilienDmsDateien__r) FROM Property__c WHERE Is_Public__c = true OR ShowOnWebsite__c = true];
        for(Property__c property:properties) {
            ImmoframeProperty immoframeProperty = new ImmoframeProperty();
            immoframeProperty.Id = property.Id;
            immoframeProperty.name = property.Name;
            immoframeProperty.inPreview = property.In_Vorschau__c;
            immoframeProperty.countPreviewApartments = property.Vorschau_Appartements__c != null ? Integer.valueOf(property.Vorschau_Appartements__c) : null;
            immoframeProperty.state = property.State__c;
            immoframeProperty.city = property.Place__c;
            immoframeProperty.street = property.Street__c;
            immoframeProperty.postalCode = property.Zip_Code__c;
            immoframeProperty.showOnImmoframe = property.Is_Public__c;
            immoframeProperty.showOnWebsite = property.ShowOnWebsite__c;
            immoframeProperty.propertyStatus = property.PropertyStatus__c;
            // Betreutes Wohnen || Pflegeimmobilie
            immoframeProperty.propertyType = property.Property__c; 
            immoframeProperty.constructionType = property.Bauart__c; 
            immoframeProperty.description = property.Description__c;
            immoframeProperty.locationDescription = property.Lagebeschreibung__c;
            // Currently always null, maybe not used
            //Decimal shareRefurbishmentSubstanceInPercent = property.;
            immoframeProperty.yieldInPercent = property.Rendite_in__c;
            immoframeProperty.googleDriveFolderId = property.Collection_Id__c;
            immoframeProperty.websiteHeaderImage = property.Website_Header_Bild__c;
            immoframeProperty.constructionProgressUrl = property.Url360DegreeTour__c;
            immoframeProperty.threeSixtyDegreeTourUrl = property.UrlConstructionProgress__c;
            // Currently always null, maybe not used
            //immoframeProperty.highlight = property.;
            immoframeProperty.valuePlotInPercent = property.Value_Plot__c;
            immoframeProperty.objectVideoLink = property.Objektvideo_Link__c;
            immoframeProperty.operatorDescription = property.Betreiber__r.Betreiberinformationen__c;
            immoframeProperty.operatorLogoUrl = property.Betreiber__r.Betreiber_Logo__c;
            immoframeProperty.operatorWebsiteUrl = property.Betreiber__r.Website__c;
            immoframeProperty.operatorName = property.Betreiber__r.Name;
            immoframeProperty.availableApartments = Integer.valueOf(property.Freie_Appartments__c);
            immoframeProperty.reservedApartments = Integer.valueOf(property.Reservierte_Appartements__c);
            immoframeProperty.soldApartments = Integer.valueOf(property.Verkaufte_Appartements__c);
            immoframeProperty.infoLineOne = property.Infozeile_1__c;
            immoframeProperty.infoLineTwo = property.Infozeile_2__c;
            immoframeProperty.pressReleaseTypo3Ids = property.PressemeldungenIds__c;
            immoframeProperty.similarPropertiesIds = property.AehnlicheObjekteIds__c;
            //immoframeProperty.isPublic = property.Is_Public__c;
            immoframeProperty.minYieldInPercent = property.Min_Rendite__c;
            immoframeProperty.maxYieldInPercent = property.Max_Rendite__c;
            immoframeProperty.apartmentsMinPriceInEuro = property.Preis_ab__c;
            immoframeProperty.apartmentsMaxPriceInEuro = property.Preis_bis__c;
            immoframeProperty.apartmentsMinAreaInSqm = property.Fl_che_ab__c;
            immoframeProperty.apartmentsMaxAreaInSqm = property.Fl_che_bis__c;
            immoframeProperty.constructionDate = property.Completion__c;
            immoframeProperty.energyStandard = property.MaBV__c;
            immoframeProperty.immoframeHeadline = property.ImmoframeHeadline__c;
            immoframeProperty.inspectionByDekra = property.InspectionByDekra__c;
            immoframeProperty.disruptorLogoOne = property.DisruptorLogoOne__c;
            immoframeProperty.disruptorLogoTwo = property.DisruptorLogoTwo__c;


            for(Appartment__c app:property.Appartments__r) {
                immoframeProperty.apartments.add(getAppInfo(app));
            }

            for(ImmobilienDmsDatei__c file:property.ImmobilienDmsDateien__r) {
                // DateiTyp__c = Bilder || Dokumente || Highlights
                if(file.name == 'logo.jpg') {
                    immoframeProperty.image = getImageInfo(file); 
                }
                if(file.DateiTyp__c == 'Bilder') {
                    immoframeProperty.images.add(getImageInfo(file));
                } else if(file.DateiTyp__c == 'Dokumente') {
                    immoframeProperty.documents.add(getDocumentInfo(file));
                } else if(file.DateiTyp__c == 'Grundrisse') {
                    immoframeProperty.floorPlans.add(getImageInfo(file));
                }
            }
            immoframeProperties.add(immoframeProperty);
        }
        return immoframeProperties;
    }

    public static ImmoframeProperty.ImmoframeApartment getAppInfo(Appartment__c app) {
        ImmoframeProperty.ImmoframeApartment immoframeApp = new ImmoframeProperty.ImmoframeApartment();
        immoframeApp.id = app.Id;
        immoframeApp.status = app.OeffentlicherStatus__c;
        immoframeApp.name = app.Name;
        immoframeApp.propertyId = app.Property__c;
        immoframeApp.purchasePriceInEuro = app.Purchase_Price__c;
        immoframeApp.areaInSqm = app.Area_sq_m__c;
        immoframeApp.monthlyRentPerSqmInEuro = app.Monthly_rent_sq_m__c;
        immoframeApp.monthlyRentInEuro = app.Monthly_Rent__c;
        immoframeApp.notaryAndCourtCostInEuro = app.Notary_And_Court_Costs_1_5__c;
        immoframeApp.yearlyMaintenancePerSqmInEuro = app.Maintenance_sqm__c;
        immoframeApp.yearlyAdministrationCostInEuro = app.Cost_Admin__c;
        immoframeApp.deprecationValueInEuro = app.Depreciation_Value__c;
        immoframeApp.realEstateTransferTaxInEuro = app.Real_Estate_Transfer_Tax__c;
        immoframeApp.netAssetValueInPercent = app.Net_asset_value__c;
        immoframeApp.netAssetValueAfaInPercent = app.Net_Asset_Value_AFA__c;
        immoframeApp.outdoorValueInPercent = app.Value_of_OIutdoor__c;
        immoframeApp.outdoorValueAfaInPercent = app.Outdoor_AFA__c;
        immoframeApp.purchasePricePerSqmInEuro = app.Purchase_Price_sq_m__c;
        immoframeApp.yieldInPercent = app.Rental_return__c;
        return immoframeApp;
    }

    public static ImmoframeProperty.ImmoframeImage getImageInfo(ImmobilienDmsDatei__c file) {
        ImmoframeProperty.ImmoframeImage immoframeImage = new ImmoframeProperty.ImmoframeImage();
        immoframeImage.fullSizeUrl = file.ThumbnailUrl__c.replace('w320', 'w1920');
        immoframeImage.thumbnailUrl = file.ThumbnailUrl__c.replace('w320', 'w220');
        return immoframeImage;
    }

    public static ImmoframeProperty.ImmoframeDocument getDocumentInfo(ImmobilienDmsDatei__c file) {
        ImmoframeProperty.ImmoframeDocument immoframeDocument = new ImmoframeProperty.ImmoframeDocument();
        immoframeDocument.mimeType = file.MimeType__c;
        immoframeDocument.name = file.Name;
        immoframeDocument.url = file.DateiUrl__c;
        return immoframeDocument;
    }

}