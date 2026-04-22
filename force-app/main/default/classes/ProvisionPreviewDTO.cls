global class ProvisionPreviewDTO {
        @AuraEnabled global Id OpportunityId;
        @AuraEnabled global String ErsterKaeuferName;
        @AuraEnabled global String ImmobilieName;
        @AuraEnabled global String ApartmentName;
        @AuraEnabled global String StageName;
        @AuraEnabled global String BrokerName;

        @AuraEnabled global Decimal Kaufpreis;
        @AuraEnabled global Decimal Provisionssumme;
        @AuraEnabled global Decimal ProvisionInProzent;

        @AuraEnabled global Decimal Probability;
        @AuraEnabled global Decimal WeightedProvision;

        @AuraEnabled global Date ProvisionDatum;
        @AuraEnabled global Date Notartermin;
    }