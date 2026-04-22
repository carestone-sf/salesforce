global class SchedulableDownloadIntranetDashboard implements Schedulable {
    global void execute(SchedulableContext sc) {
        // URL to fetch the PNG (make sure https://carestone.lightning.force.com 
        // is whitelisted in Remote Site Settings)
        String pngUrl = 'https://carestone.my.salesforce.com/analytics/download/lightning-dashboard/01ZVi000001XjXFMA0.png';
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(pngUrl);
        
        // Include session ID for authentication, if required
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());

        HttpResponse response;
        try {
            response = http.send(request);
        } catch (Exception e) {
            System.debug('Error during PNG GET request: ' + e.getMessage());
            return; 
        }
        
        if (response.getStatusCode() == 200) {
            Blob pngBlob = response.getBodyAsBlob();
            
            // Create and insert Document record
            Document doc = new Document(
                Name       = 'dashboard_intranet.png',
                FolderId   = '00lVi0000022mXF', // change to your Folder ID
                Body       = pngBlob,
                ContentType = 'image/png',
                IsPublic   = false
            );
            
            try {
                insert doc;
                System.debug('Document inserted successfully with Id: ' + doc.Id);
            } catch (DmlException dme) {
                System.debug('Error inserting Document: ' + dme.getMessage());
            }
        } else {
            System.debug(
                'GET request returned status ' + response.getStatusCode() + 
                ', body: ' + response.getBody()
            );
        }
    }
}
