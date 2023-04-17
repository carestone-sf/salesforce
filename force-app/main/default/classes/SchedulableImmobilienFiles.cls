global class SchedulableImmobilienFiles implements Schedulable, Database.AllowsCallouts {

    public static ConnectorService connectorService;
    public static Boolean validConnector { get; set; }
    public static ffhttp_GoogleDrive client;

    global void execute(SchedulableContext sc){
        List<Property__c> properties = [SELECT Id FROM Property__c WHERE Is_Public__c = true];
        List<Id> propertyIds = new List<Id>();
        for(Property__c property:properties) {
            propertyIds.add(property.Id);
        }
        prepareDocuments(propertyIds);
    }   

    @InvocableMethod(label='Google Drive synchronisieren')
    public static void prepareDocuments(List<Id> propertyIds) {
        // Sorry to whoever sees this
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();
        new ImmobilienBilder__c();

        for(Id propertyId:propertyIds) {
            getDocuments(propertyId);
        }
    }

    @future(callout=true)
    public static void getDocuments(id propertyId) {
        Property__c property = [SELECT Id, Collection_Id__c FROM Property__c WHERE Id = :propertyId];

        if(property.Collection_Id__c == null) {
            return;
        }
        List<ImmobilienDmsDatei__c> immobilienDateien = new List<ImmobilienDmsDatei__c>();

        ffhttp_GoogleDriveFiles files = getGoogleDriveClient().files();
    	ffhttp_GoogleDriveFiles.ListRequest listRequest = files.listRequest();
        listRequest.setFields('items(id,webContentLink,alternateLink,thumbnailLink,title,mimeType,fileExtension,modifiedDate)');
        listRequest.setQ('\'' + property.Collection_Id__c + '\' in parents');

        String thumbnailUrl = 'https://drive.google.com/thumbnail?authuser=0&sz=w320&id=';

        ffhttp_GoogleDriveModelFile.ItemList items = (ffhttp_GoogleDriveModelFile.ItemList)listRequest.execute();
        try{
            for(ffhttp_GoogleDriveModelFile child:(List<ffhttp_GoogleDriveModelFile>)items.getItems()) {

                ffhttp_GoogleDriveFiles.ListRequest innerListRequest = files.listRequest();
                innerListRequest.setFields('items(id,webContentLink,alternateLink,thumbnailLink,title,mimeType,fileExtension,modifiedDate)');
                innerListRequest.setQ('\'' + child.getId() + '\' in parents');
                
                ffhttp_GoogleDriveModelFile.ItemList innerItems = (ffhttp_GoogleDriveModelFile.ItemList)innerListRequest.execute();
                for(ffhttp_GoogleDriveModelFile innerChild:(List<ffhttp_GoogleDriveModelFile>)innerItems.getItems()) {
                    // Datei
                    if(innerChild.getMimeType() != 'application/vnd.google-apps.folder') {
                        ImmobilienDmsDatei__c immobilienDatei = new ImmobilienDmsDatei__c();
                        String fullTitle = innerChild.getTitle();
                        if(fullTitle.length() > 66) {
                            fullTitle = fullTitle.substring(0, 66);
                        }
                        String fileExtension = '.' + innerChild.getFileExtension();
                        if(!fullTitle.endsWith(fileExtension) && !String.isBlank(innerChild.getFileExtension())) {
                            fullTitle = fullTitle + fileExtension;
                        }
                        immobilienDatei.Name = fullTitle;
                        if(child.getTitle() == 'Bilder') {
                            immobilienDatei.DateiTyp__c = 'Bilder';
                        } else {
                            immobilienDatei.DateiTyp__c = 'Highlights';
                        }
                        immobilienDatei.DateiUrl__c = innerChild.getWebContentLink();
                        immobilienDatei.Immobilie__c = propertyId;
                        immobilienDatei.ParentOrdner__c = null;
                        immobilienDatei.PreviewUrl__c = innerChild.getAlternateLink();
                        immobilienDatei.ThumbnailUrl__c = thumbnailUrl + innerChild.getId();
                        immobilienDatei.MimeType__c = innerChild.getMimeType();
                        immobilienDatei.FileLastModifiedDate__c = innerChild.getModifiedDate();
                        immobilienDateien.add(immobilienDatei);
                    } else {
                        // Nur Dokumente haben Unterordner
                        ffhttp_GoogleDriveFiles.ListRequest documentsListRequest = files.listRequest();
                        documentsListRequest.setFields('items(id,webContentLink,alternateLink,thumbnailLink,title,mimeType,fileExtension,modifiedDate)');
                        documentsListRequest.setQ('\'' + innerChild.getId() + '\' in parents');

                        ffhttp_GoogleDriveModelFile.ItemList documentItems = (ffhttp_GoogleDriveModelFile.ItemList)documentsListRequest.execute();
                        for(ffhttp_GoogleDriveModelFile documentChild:(List<ffhttp_GoogleDriveModelFile>)documentItems.getItems()) {
                            ImmobilienDmsDatei__c immobilienDatei = new ImmobilienDmsDatei__c();
                            String fullTitle = documentChild.getTitle();
                            if(fullTitle.length() > 66) {
                                fullTitle = fullTitle.substring(0, 66);
                            }
                            String fileExtension = '.' + documentChild.getFileExtension();
                            if(!fullTitle.endsWith(fileExtension) && !String.isBlank(documentChild.getFileExtension())) {
                                fullTitle = fullTitle + fileExtension;
                            }
                            immobilienDatei.Name = fullTitle;
                            immobilienDatei.DateiTyp__c = 'Dokumente';
                            immobilienDatei.DateiUrl__c = documentChild.getWebContentLink();
                            immobilienDatei.Immobilie__c = propertyId;
                            immobilienDatei.ParentOrdner__c = innerChild.getTitle();
                            immobilienDatei.PreviewUrl__c = documentChild.getAlternateLink();
                            immobilienDatei.ThumbnailUrl__c = thumbnailUrl + documentChild.getId();
                            immobilienDatei.FileLastModifiedDate__c = documentChild.getModifiedDate();
                            immobilienDatei.MimeType__c = documentChild.getMimeType();
                            immobilienDateien.add(immobilienDatei);
                        }
                    }
                }
            }
        } catch(Exception e) { 
            System.debug(e); 
        }

        delete [SELECT Id FROM ImmobilienDmsDatei__c WHERE Immobilie__c = :propertyId];
        insert immobilienDateien;
    }

    public static ConnectorService getConnectorService()
    {
    	if (connectorService == null)
    	{	
    		try
    		{
	    		Connector__c c = 
	    		[
	    			SELECT 
	    				c.TokenType__c, c.RefreshToken__c, c.RefreshTokenRequested__c, c.Name, c.Id, c.AccessToken__c, 
					   	c.AccessTokenRequested__c, c.AccessTokenExpiry__c, c.Active__c, 
					   	ConnectorType__r.TokenEndpoint__c, ConnectorType__r.Scope__c, ConnectorType__r.ScopeRequired__c, 
					   	ConnectorType__r.RedirectUri__c, ConnectorType__r.Name, ConnectorType__r.Id, 
					   	ConnectorType__r.ExtraUrlParameters__c, ConnectorType__r.DeveloperName__c, 
					   	ConnectorType__r.ClientSecret__c, ConnectorType__r.ClientId__c, ConnectorType__r.CallbackURL__c, 
					   	ConnectorType__r.AuthorizationEndpoint__c
	    			FROM Connector__c c
	    			WHERE ConnectorType__r.Name =: 'Google Drive'
	    			LIMIT 1
	    		];
	    		
	    		if (c != null)
	    		{
	    			connectorService = new ConnectorService(c);
	    		}
    		}
    		catch (Exception ex)
    		{
    		}
    	}
    	return connectorService;
    }

    /**
     * Gets the Google Drive client
     */
    public static ffhttp_GoogleDrive getGoogleDriveClient()
    {
        ConnectorService connectorService = getConnectorService();
    	if (client == null)
    	{
            ffhttp_Client.ICredentials credentials = new ffhttp_Client.AccessTokenCredentials(connectorService.connector.TokenType__c,  connectorService.getAccessToken());
            client = new ffhttp_GoogleDrive(credentials);
    	}
    	return client;
    }

    // @future(callout=true)
    // public static void getDocuments(Id propertyId) {
    //     List<ImmobilienBilder__c> propertyImmobilienBilder = [SELECT Id, (SELECT Name FROM ImmobilienBilder__r) FROM ImmobilienBilder__c WHERE Immobilie__c = :propertyId];
    //     List<ContentVersion> bilderCvs = new List<ContentVersion>();
    //     if(propertyImmobilienBilder.size() == 0) {
    //         ImmobilienBilder__c newImmobilienBilder = new ImmobilienBilder__c();
    //         newImmobilienBilder.Name = 'Bilder';
    //         newImmobilienBilder.Immobilie__c = propertyId;
    //         propertyImmobilienBilder.add(newImmobilienBilder);
    //         insert propertyImmobilienBilder;   
    //     }

    //     List<String> imageNames = new List<String>();
    //     for(ImmobilienBild__c immobilienBild:propertyImmobilienBilder[0].ImmobilienBilder__r) {
    //         imageNames.add(immobilienBild.Name);
    //     }

    //     List<String> dmsImageNames = new List<String>();

    //     List<DMSController.OpenTextDocumentMeta> bilder = DMSController.getDocuments(propertyId + '_bilder');
    //     for(DMSController.OpenTextDocumentMeta bild:bilder) {
    //         dmsImageNames.add(bild.documentName);
    //         if(!imageNames.contains(bild.documentName) && bilderCvs.size() == 0) {
    //             DMSController.OpenTextDocument dmsDoc = DMSController.getDocument(bild.docNumber);
    //             ContentVersion cv = getContentVersionFromDmsDoc(dmsDoc);
    //             bilderCvs.add(cv);
    //         } 
    //     }
    //     insert bilderCvs;

    //     List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
    //     List<ContentVersion> insertedBilderCvs = new List<ContentVersion>();
    //     Map<Id, Id> contentDocumentIdToLinkedEntityId = new Map<Id, Id>();
    //     for(ImmobilienBilder__c newImmobilienBilder:propertyImmobilienBilder) {
    //         Id linkedEntityId = newImmobilienBilder.Id;
    //         List<Id> contentVersionIds = new List<Id>();
    //         for(ContentVersion cv:bilderCvs) {
    //             contentVersionIds.add(cv.Id);
    //         }

    //         insertedBilderCvs = [SELECT ContentDocumentId, Title FROM ContentVersion WHERE Id IN :contentVersionIds];
    //         for(ContentVersion cv:insertedBilderCvs) {
    //             ContentDocumentLink cdl = new ContentDocumentLink();
    //             cdl.ContentDocumentId = cv.ContentDocumentId;
    //             cdl.LinkedEntityId = linkedEntityId;
    //             cdl.Visibility = 'AllUsers';
    //             cdls.add(cdl);
    //             contentDocumentIdToLinkedEntityId.put(cv.ContentDocumentId, linkedEntityId);
    //         }
    //     }
    //     insert cdls;

    //     List<ContentDistribution> cdImgs = new List<ContentDistribution>();
    //     for(ContentVersion cv:insertedBilderCvs) {
    //         ContentDistribution cdImg = new ContentDistribution();
    //         cdImg.Name = cv.Title;
    //         cdImg.ContentVersionId = cv.Id;
    //         cdImg.PreferencesAllowViewInBrowser= true;
    //         cdImg.PreferencesLinkLatestVersion=true;
    //         cdImg.PreferencesNotifyOnVisit=false;
    //         cdImg.PreferencesPasswordRequired=false;
    //         cdImg.PreferencesAllowOriginalDownload= true;
    //         cdImgs.add(cdImg);
    //     }
    //     Database.insert(cdImgs, false);

    //     List<Id> cdImgIds = new List<Id>();
    //     for(ContentDistribution cd:cdImgs) {
    //         cdImgIds.add(cd.Id);
    //     }

    //     List<ContentDistribution> insertedCdImgs = [SELECT ContentDownloadUrl, ContentDocumentId, ContentVersion.Title FROM ContentDistribution WHERE Id IN :cdImgIds];
    //     List<ImmobilienBild__c> singleImmobilienBilder = new List<ImmobilienBild__c>();
    //     for(ContentDistribution insertedCdImg:insertedCdImgs) {
    //         ImmobilienBild__c singleImmobilienBild = new ImmobilienBild__c();
    //         singleImmobilienBild.Name = insertedCdImg.ContentVersion.Title;
    //         singleImmobilienBild.ImmobilienBilder__c = contentDocumentIdToLinkedEntityId.get(insertedCdImg.ContentDocumentId);
    //         singleImmobilienBild.BildUrl__c = insertedCdImg.ContentDownloadUrl;
    //         singleImmobilienBilder.add(singleImmobilienBild);
    //     }
    //     insert singleImmobilienBilder;
    // }

    // public static ContentVersion getContentVersionFromDmsDoc(DMSController.OpenTextDocument dmsDoc) {
    //     ContentVersion cv=new Contentversion();
    //     cv.title = dmsDoc.fileName;
    //     cv.PathOnClient = dmsDoc.fileName + '.' + dmsDoc.fileExtension;
    //     cv.versiondata=EncodingUtil.base64Decode(dmsDoc.fileContent);
    //     return cv;
    // }
}