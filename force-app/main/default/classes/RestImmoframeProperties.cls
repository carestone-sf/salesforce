@RestResource(urlMapping='/ImmoframeProperties')
global with sharing class RestImmoframeProperties {
    @HttpGet
    global static ImmoframeProperties getImmoframeProperties() {
        ImmoframeProperties immoframeProperties = new ImmoframeProperties();
        immoframeProperties.properties = ImmoframePropertiesService.getImmoframeProperties();
        return ImmoframeProperties;
    }

    global class ImmoframeProperties {
        global List<ImmoframeProperty> properties;
    }
}