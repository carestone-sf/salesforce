@RestResource(urlMapping='/provision-preview/*')
global with sharing class ProvisionPreviewRestService {

    @HttpGet
    global static List<ProvisionPreviewDTO> getOpenBrokerProvisions() {

        RestRequest req = RestContext.request;
        String brokerId = req.params.get('brokerContactId');

        if (String.isBlank(brokerId)) {
            throw new AuraHandledException('brokerContactId is required');
        }

        return ProvisionPreviewService.getOpenBrokerProvisions((Id) brokerId);
    }
}