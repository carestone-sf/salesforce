public without sharing class DMSController {

    static String BASE_URL = 'http://217.7.51.143:9021/eDocs/json';

    public static String login() {
        String toDelete1;
        String toDelete2;
        String toDelete3;
        String toDelete4;
        String toDelete5;
        String toDelete6;
        String toDelete7;
        String toDelete8;
        String toDelete9;
        String toDelete10;
        String loginToken;
        String loginUrlWithParams = BASE_URL + '/login?library=CARESTONE&userid=SALESFORCE&password=SALESFORCE';

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(loginUrlWithParams);
        Http http = new Http();
        HttpResponse res = http.send(req);

        if(res.getStatusCode() != 200) {
            DmsException e = new DmsException();
            e.setMessage('Beim Verbinden zum DMS ist ein Fehler aufgetreten, response body: ' + res.getBody());
            throw e;
        }

        // Parse entire JSON response.
        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'DST')) {
                // Get the value.
                parser.nextToken();
                loginToken = parser.getText();
            }
        }

        return loginToken;
    }

    @AuraEnabled(cacheable=true)
    public static List<OpenTextDocumentMeta> getDocuments(String folderId, Integer cachebuster) {
        List<OpenTextDocumentMeta> openTextDocumentMetas = new List<OpenTextDocumentMeta>();
        String loginToken = DMSController.login();
        String urlWithParams = BASE_URL + '/getDocuments?dst=' + loginToken + '&id=' + folderId;

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(urlWithParams);
        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug(res.getBody());

        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
            // Start at the array
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    // Advance to the start object marker to
                    //  find next object.
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Read entire object
                        OpenTextDocumentMeta openTextDocumentMeta = (OpenTextDocumentMeta)parser.readValueAs(OpenTextDocumentMeta.class);
                        openTextDocumentMetas.add(openTextDocumentMeta);
                        // Skip the child start array and start object markers.
                        parser.skipChildren();
                    }
                }
            }
        }

        return openTextDocumentMetas;
    }

    @AuraEnabled(cacheable=true)
    public static OpenTextDocument getDocument(String docNumber) {
        OpenTextDocument openTextDocument = new OpenTextDocument();
        String loginToken = DMSController.login();
        String urlWithParams = BASE_URL + '/getDocument?dst=' + loginToken + '&id=' + docNumber;

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(urlWithParams);
        Http http = new Http();
        HttpResponse res = http.send(req);

        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
            // Start at the array
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    // Advance to the start object marker to
                    //  find next object.
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Read entire object
                        openTextDocument = (OpenTextDocument)parser.readValueAs(OpenTextDocument.class);
                        // Skip the child start array and start object markers.
                        parser.skipChildren();
                    }
                }
            }
        }

        return openTextDocument;
    }

    @AuraEnabled(cacheable=true)
    public static List<OpenTextDocumentTypes> getDocumentTypes(String folderId) {
        List<OpenTextDocumentTypes> OpenTextDocumentTypes = new List<OpenTextDocumentTypes>();
        String loginToken = DMSController.login();
        String urlWithParams = BASE_URL + '/getDocumenttypes?dst=' + loginToken + '&id=' + folderId;

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(urlWithParams);
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getBody());
        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
            // Start at the array
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    // Advance to the start object marker to
                    //  find next object.
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Read entire object
                        OpenTextDocumentTypes openTextDocumentType = (OpenTextDocumentTypes)parser.readValueAs(OpenTextDocumentTypes.class);
                        OpenTextDocumentTypes.add(openTextDocumentType);
                        // Skip the child start array and start object markers.
                        parser.skipChildren();
                    }
                }
            }
        }

        return OpenTextDocumentTypes;
    }

    @AuraEnabled
    public static void uploadDocument(String folderId, String base64EncodedContent, String jsonParams) {
        List<OpenTextDocumentTypes> OpenTextDocumentTypes = new List<OpenTextDocumentTypes>();
        String loginToken = DMSController.login();
        String urlWithParams = BASE_URL + '/uploadDocument?dst=' + loginToken + '&id=' + folderId + '&content=' + base64EncodedContent + '&parameter=' + EncodingUtil.urlEncode(jsonParams, 'UTF-8');

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(urlWithParams);
        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug(res.getBody());

        // JSONParser parser = JSON.createParser(res.getBody());
        // while (parser.nextToken() != null) {
        //     // Start at the array
        //     if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
        //         while (parser.nextToken() != null) {
        //             // Advance to the start object marker to
        //             //  find next object.
        //             if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
        //                 // Read entire object
        //                 OpenTextDocumentTypes openTextDocumentType = (OpenTextDocumentTypes)parser.readValueAs(OpenTextDocumentTypes.class);
        //                 OpenTextDocumentTypes.add(openTextDocumentType);
        //                 // Skip the child start array and start object markers.
        //                 parser.skipChildren();
        //             }
        //         }
        //     }
        // }
    }

    @AuraEnabled
    public static void uploadDocumentFromContentVersionId(String folderId, Id contentVersionId, String documentTypeId) {
        // Get info about our uploaded document 
        ContentVersion uploadedDocument = [SELECT Id, Title, ContentDocumentId, VersionData, FileType, PathOnClient FROM ContentVersion WHERE Id =: contentVersionId];
        String jsonParams = '{"documentType": ' + documentTypeId + ', "name": "' + uploadedDocument.PathOnClient + '"}';

        String base64Content = EncodingUtil.base64Encode(uploadedDocument.VersionData);

        List<OpenTextDocumentTypes> OpenTextDocumentTypes = new List<OpenTextDocumentTypes>();
        String loginToken = DMSController.login();
        String urlWithParams = BASE_URL + '/uploadDocument?dst=' + loginToken + '&id=' + folderId + '&parameter=' + EncodingUtil.urlEncode(jsonParams, 'UTF-8');

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(urlWithParams);
        req.setBodyAsBlob(uploadedDocument.VersionData);
        Http http = new Http();
        HttpResponse res = http.send(req);

        Database.delete(uploadedDocument.ContentDocumentId);

        // JSONParser parser = JSON.createParser(res.getBody());
        // while (parser.nextToken() != null) {
        //     // Start at the array
        //     if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
        //         while (parser.nextToken() != null) {
        //             // Advance to the start object marker to
        //             //  find next object.
        //             if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
        //                 // Read entire object
        //                 OpenTextDocumentTypes openTextDocumentType = (OpenTextDocumentTypes)parser.readValueAs(OpenTextDocumentTypes.class);
        //                 OpenTextDocumentTypes.add(openTextDocumentType);
        //                 // Skip the child start array and start object markers.
        //                 parser.skipChildren();
        //             }
        //         }
        //     }
        // }
    }

    @AuraEnabled
    public static Boolean createFolder(String folderId, String parentFolderId, String jsonParams) {
        List<OpenTextDocumentTypes> OpenTextDocumentTypes = new List<OpenTextDocumentTypes>();
        System.debug(jsonParams);
        String loginToken = DMSController.login();
        String urlWithParams = BASE_URL + '/createFolder?dst=' + loginToken + '&id=' + folderId + '&parentId=' + parentFolderId + '&parameter=' + EncodingUtil.urlEncode(jsonParams, 'UTF-8');

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(urlWithParams);
        Http http = new Http();
        HttpResponse res = http.send(req);
       

        Boolean success = false;
        Integer statusCode = res.getStatusCode();
        if(statusCode == 200) {
            success = true;
        }

        return success;

        // JSONParser parser = JSON.createParser(res.getBody());
        // while (parser.nextToken() != null) {
        //     // Start at the array
        //     if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
        //         while (parser.nextToken() != null) {
        //             // Advance to the start object marker to
        //             //  find next object.
        //             if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
        //                 // Read entire object
        //                 OpenTextDocumentTypes openTextDocumentType = (OpenTextDocumentTypes)parser.readValueAs(OpenTextDocumentTypes.class);
        //                 OpenTextDocumentTypes.add(openTextDocumentType);
        //                 // Skip the child start array and start object markers.
        //                 parser.skipChildren();
        //             }
        //         }
        //     }
        // }

        //return res;
    }

    @AuraEnabled
    public static Boolean createFolderFromRecordId(Id recordId, Boolean updateFolder, Boolean updateRecord) {
        String sObjectName = recordId.getSObjectType().getDescribe().getName();

        String jsonParams;
        String folderId = recordId;
        String parentFolderId = sObjectName;

        if(sObjectName == 'Property__c') {
            String queryStr = 'SELECT Name, Objektnummer__c, DMSFolderId__c, Street__c, Place__c, Zip_Code__c, AktenstatusDms__c, Bauart__c, Unternehmen__r.Name, Unternehmen__r.HRB_bei_Kapitalgesellschaften__c, Unternehmen__r.Datev_Mandantennummer__c FROM ' + sObjectName + ' WHERE Id = \'' + recordId + '\'';
            sObject record = Database.query(queryStr);

            String aktenstatusNumber;
            String aktenstatus = (String)record.get('AktenstatusDms__c');
            switch on aktenstatus {
                when 'Initial' {
                    aktenstatusNumber = '00';
                }
                when 'Immobilie angelegt' {
                    aktenstatusNumber = '01';
                }
                when 'Entwicklung (Akquise)' {
                    aktenstatusNumber = '02';
                }
                when 'Entwicklung (Aktiv)' {
                    aktenstatusNumber = '03';
                }
                when 'Entwicklung (Abgelehnt)' {
                    aktenstatusNumber = '04';
                }
                when 'Durchführung (Aktiv)' {
                    aktenstatusNumber = '05';
                }
                when 'Abwicklung (Aktiv)' {
                    aktenstatusNumber = '06';
                }
                when 'Durchführung (Abgeschlossen)' {
                    aktenstatusNumber = '07';
                }
                when 'Asset Management (Aktiv)' {
                    aktenstatusNumber = '08';
                }
                when 'Archiviert' {
                    aktenstatusNumber = '09';
                }
                
            }

            String objektNummer = !String.isBlank((String) record.get('Objektnummer__c')) ? (String) record.get('Objektnummer__c') : 'nn';

            jsonParams = '{';
            jsonParams += '"objektid": "' + record.get('Name') + ' (' + objektNummer + ')' + '",';
            jsonParams += '"objektname": "' + record.get('Name') + '",';
            jsonParams += '"plz": "' + record.get('Zip_Code__c') + '",';
            jsonParams += '"ort": "' + record.get('Place__c') + '",';
            jsonParams += '"strasse": "' + record.get('Street__c') + '",';
            jsonParams += '"projektart": "' + record.get('Bauart__c') + '",';
            jsonParams += '"projekttyp": "Vertrieb",';
            if(record.getSobject('Unternehmen__r') != null) {
                jsonParams += '"projektgesellschaft": "' + record.getSobject('Unternehmen__r').get('Name') + '",';
                jsonParams += '"projektgesellschafthrb": "' + record.getSobject('Unternehmen__r').get('HRB_bei_Kapitalgesellschaften__c') + '",';
                jsonParams += '"projektgesellschaftdatev": "' + record.getSobject('Unternehmen__r').get('Datev_Mandantennummer__c') + '",';
            }
            jsonParams += '"immobiliennummer": "' + record.get('Objektnummer__c') + '",';
            jsonParams += '"aktenstatus": "' + aktenstatusNumber + '",';
            if(aktenstatusNumber == '03' || aktenstatusNumber == '05' || aktenstatusNumber == '06' || aktenstatusNumber == '07' || aktenstatusNumber == '08' || aktenstatusNumber == '09') {
                jsonParams += '"vertriebsaktenstatus": "J"';
            }
            jsonParams += '}';
            parentFolderId = '1';
            folderId = (String)record.get('DMSFolderId__c');
        } else if(sObjectNAme == 'Appartment__c') {
            String queryStr = 'SELECT Name, Property__c, Property__r.Hauptimmobilie__c FROM ' + sObjectName + ' WHERE Id = \'' + recordId + '\'';
            sObject record = Database.query(queryStr);

            jsonParams = '{"name": "' + record.get('Name') + '"}';
            parentFolderId = (String) record.get('Property__c');
        } else if(sObjectNAme == 'Opportunity') {
            String queryStr = 'SELECT Name, IsClosed, IsWon, Appartement__c FROM ' + sObjectName + ' WHERE Id = \'' + recordId + '\'';
            sObject record = Database.query(queryStr);
            String oppStatus;
            if((Boolean) record.get('IsClosed') && (Boolean) record.get('isWon')) {
                oppStatus = 'gewonnen';
            } else if((Boolean) record.get('IsClosed') && !(Boolean) record.get('isWon')) {
                oppStatus = 'verloren';
            } else {
                oppStatus = 'offen';
            }

            jsonParams = '{';
            jsonParams += '"name": "' + record.get('Name') + '",';
            jsonParams += '"status": "' + oppStatus + '"';
            jsonParams += '}';
            parentFolderId = (String) record.get('Appartement__c');
        } else {
            String queryStr = 'SELECT Name FROM ' + sObjectName + ' WHERE Id = \'' + recordId + '\'';
            sObject record = Database.query(queryStr);

            // For all other sObject types we only need the name for the folder
            jsonParams = '{"name": "' + record.get('Name') + '"}';
        }

        if(updateFolder == true) {
            return DMSController.updateFolder(folderId, jsonParams);
        } else {
            Boolean success = DMSController.createFolder(folderId, parentFolderId, jsonParams);
            if(success && updateRecord) {
                List<SObject> sObjs = new List<SObject>();
                SObject sObj = recordId.getSObjectType().newSObject(recordId);
                sObj.put('DmsOrdnerErstellt__c', true);
                sObjs.add(sObj);
                
                if(sObjs.size() > 0) {
                    try {
                        update sObjs;
                    } catch(Exception e) {
                        System.debug(e);
                    }
                }
            }
            return success;
        }
    }

    @future(callout=true)
    public static void createFoldersFromRecordIdsFuture(List<Id> recordIds, Boolean updateFolder) {
        List<Id> successIds = new List<Id>();

        for(Id recordId:recordIds) {
            Boolean success = false;
            if(updateFolder == true) {
                success = DMSController.createFolderFromRecordId(recordId, true, false);
            } else {
                success = DMSController.createFolderFromRecordId(recordId, false, false);
            }
            if(success) {
                successIds.add(recordId);
            }
        }

        if(updateFolder == false) {
            List<SObject> sObjs = new List<SObject>();
            for(Id successId:successIds) {
                SObject sObj = successId.getSObjectType().newSObject(successId);
                sObj.put('DmsOrdnerErstellt__c', true);
                sObjs.add(sObj);
            }
            
            if(sObjs.size() > 0) {
                try {
                    update sObjs;
                } catch(Exception e) {
                    System.debug(e);
                }
            }
        }
    }

    @InvocableMethod(label='Create or Update DMS folder' description='Takes a list of ids.')
    public static List<Results> createUpdateFoldersFromRecordIdsApexAction(List<Requests> requests) {
        List<Id> recordIds = new List<Id>();
        Boolean updateFolder = false;
        List<Results> results = new List<Results>();

        for(Requests request: requests) {
            if(request.recordId != null) {
                recordIds.add(request.recordId);
            }
            if(request.updateFolder == true) {
                updateFolder = true;
            }
        }

        List<Id> futureIds = new List<Id>();
        if(recordIds.size() < 50) {
            DMSController.createFoldersFromRecordIdsFuture(recordIds, updateFolder);
        } else {
            for(Id recordId:recordIds) {
                futureIds.add(recordId);
                if(futureIds.size() == 50) {
                    DMSController.createFoldersFromRecordIdsFuture(futureIds, updateFolder);
                    futureIds.clear();
                } 
            }
        }

        for(Id recordId:recordIds) {
            Results res = new Results();
            res.success = true;
            results.add(res);
        }

        return results;
    }

    public class Requests {
        @InvocableVariable(label='Record id for Input' required=true)
        public Id recordId;

        @InvocableVariable(label='Update folder?' description='Set to true if you want to update the folder instead of creating a folder.')
        public Boolean updateFolder;
    }
      
    public class Results {
        @InvocableVariable(label='Records for Output' description='yourDescription' required=true)
        public Boolean success;
    }

    public static Boolean updateFolder(String folderId, String jsonParams) {
        List<OpenTextDocumentTypes> OpenTextDocumentTypes = new List<OpenTextDocumentTypes>();
        String loginToken = DMSController.login();
        String urlWithParams = BASE_URL + '/updateFolder?dst=' + loginToken + '&id=' + folderId + '&parameter=' + EncodingUtil.urlEncode(jsonParams, 'UTF-8');

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(urlWithParams);
        Http http = new Http();
        HttpResponse res = http.send(req);

        Boolean success = false;
        Integer statusCode = res.getStatusCode();
        if(statusCode == 200) {
            success = true;
        }

        return success;


        // JSONParser parser = JSON.createParser(res.getBody());
        // while (parser.nextToken() != null) {
        //     // Start at the array
        //     if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
        //         while (parser.nextToken() != null) {
        //             // Advance to the start object marker to
        //             //  find next object.
        //             if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
        //                 // Read entire object
        //                 OpenTextDocumentTypes openTextDocumentType = (OpenTextDocumentTypes)parser.readValueAs(OpenTextDocumentTypes.class);
        //                 OpenTextDocumentTypes.add(openTextDocumentType);
        //                 // Skip the child start array and start object markers.
        //                 parser.skipChildren();
        //             }
        //         }
        //     }
        // }
    }

    public class DmsException extends Exception {}
    
    public class OpenTextDocument {
        @AuraEnabled
        public String docNumber{get;set;}
        @AuraEnabled
        public String fileContent{get;set;}
        @AuraEnabled
        public String fileExtension{get;set;}
        @AuraEnabled
        public String fileName{get;set;}
    }

    public class OpenTextDocumentMeta {
        // for example MS Word
        @AuraEnabled
        public String application_id{get;set;}
        // the unique identifier for the document itself
        @AuraEnabled
        public String docNumber{get;set;}
        // name of the document
        @AuraEnabled
        public String documentName{get;set;}
        // id of the doctype in the sense of opentext
        @AuraEnabled
        public String documentType{get;set;}
        // the doctype name itself, e.g. "Bauplan" or "Reservierungsschein"
        @AuraEnabled
        public String documentTypeName{get;set;}
    }

    public class OpenTextDocumentTypes {
        // For example "Reservierungsschein"
        @AuraEnabled
        public String documentTypeName{get;set;}
        // For example "331" which can be the unique identifier for "Reservierungsschein"
        @AuraEnabled
        public String typeId{get;set;}
    }

    // Calls für Console
    //DMSController dms = new DMSController();
    //System.debug(DMSController.createFolder('a0L1l000003b3egEAA', '1', '{"objektid": "Immobilie 1 (482)", "objektname": "Immobilie 1", "plz": " 55239", "ort": "Gau-Odernheim", "strasse": "Bahnstr. 20", "projektart": "Neubau", "projekttyp": "Entwicklung", "projektgesellschaft": "Carestone Group GmbH", "projektgesellschafthrb": "217630", "projektgesellschaftdatev": "1234", "immobiliennummer": "482", "aktenstatus": "2"}').getBody());

}