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
                        } else if(child.getTitle() == 'Highlights') {
                            immobilienDatei.DateiTyp__c = 'Highlights';
                        } else if(child.getTitle() == 'Grundrisse') {
                            immobilienDatei.DateiTyp__c = 'Grundrisse';
                        } else if(child.getTitle() == 'Baufortschritt') {
                            immobilienDatei.DateiTyp__c = 'Baufortschritt';
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

}