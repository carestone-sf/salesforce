@RestResource(urlMapping='/quote/*')
global without sharing class RestQuote {

    @HttpGet
    global static String getQuoteFromCalculation() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String calculationId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<Berechnung__c> calculations = [SELECT Id FROM Berechnung__c WHERE Id = :calculationId];
        Berechnung__c c;
        if(calculations.size() == 1) {
            c = calculations[0];

            PageReference pdf = Page.CalculationQuote;
            pdf.getParameters().put('id', c.Id);
            Blob body;
            try {
                body = pdf.getContentAsPDF();
            } catch (Exception e) {
                return null;
            }

            FinanceCalculator fc = new FinanceCalculator();
            fc.initFinanceModules(c.Id);
            if(fc.cumulatedYearlyValues.get(fc.firstFullYear) != null) {
                fc.c.LiquidityMonthlyFirstYear__c = (Decimal)fc.cumulatedYearlyValues.get(fc.firstFullYear).get('monthlyOverageInEuro');
                update fc.c;
            }

            String blobAsBase64 = EncodingUtil.base64Encode(body);
            return blobAsBase64;
        }
        return null;
    }

    global static void attachQuoteFromId(Id calculationId) {
        PageReference pdf = Page.CalculationQuote;
        pdf.getParameters().put('id', calculationId);
        Blob body;
        try {
            if(Test.isRunningTest()) { 
                body = blob.valueOf('Unit.Test');
              } else {
                body = pdf.getContentAsPDF();
              }
        } catch (Exception e) {
            return;
        }

        // Dateiname der CSV
        String fileName = 'Berechnung ' + date.today().day() + '.' + date.today().month() + '.' + date.today().year() + ' - ' + datetime.now().hour() + ':' + Datetime.now().minute() + '.pdf';

        User u = [SELECT IsActive,IsPortalEnabled,LastName FROM User WHERE Id = :UserInfo.getUserId()];
        ContentVersion file = new ContentVersion();
        file.VersionData = body;
        file.Title = fileName; 
        file.ContentLocation= 's';
        file.PathOnClient=fileName;
        Id angebotRecordTypeId = Schema.getGlobalDescribe().get('ContentVersion').getDescribe().getRecordTypeInfosByName().get('Vertriebsportal').getRecordTypeId();
        file.Typ__c = 'Angebot';
        file.RecordTypeId = angebotRecordTypeId;
        if(u.IsPortalEnabled) {
            Id networkId = [SELECT Id FROM Network LIMIT 1].Id;
            file.NetworkId = networkId;
        }
        insert file;
        
        List<ContentVersion> files = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :file.Id];

        if(files.size() > 0) {
            file = files[0];
            ContentDocumentLink cde = new ContentDocumentLink();
            cde.ContentDocumentId = file.ContentDocumentId;
            cde.LinkedEntityId = calculationId;
            insert cde;
        }

        FinanceCalculator fc = new FinanceCalculator();
        fc.initFinanceModules(calculationId);
        if(fc.cumulatedYearlyValues.get(fc.firstFullYear) != null) {
            fc.c.LiquidityMonthlyFirstYear__c = (Decimal)fc.cumulatedYearlyValues.get(fc.firstFullYear).get('monthlyOverageInEuro');
            update fc.c;
        }
    }

    @InvocableMethod(label='Angebot als PDF an Berechnung anhängen')
    public static void attachQuoteFromIdFlowAction(List<Id> calculationIds) {
        for(Id calculationId:calculationIds) {
            RestQuote.attachQuoteFromId(calculationId);
        }
    }

}