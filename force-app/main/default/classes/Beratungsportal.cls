public without sharing class Beratungsportal {
    static String BASE_URL = 'https://beratung.carestone.com';

    @future(callout=true)
    public static void createBeratungsportalUser(List<Id> conIds) {
        for(Id conId:conIds) {
            String urlWithParams = BASE_URL + '/?type=5001&sfid=' + conId;

            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(urlWithParams);
            Http http = new Http();
            HttpResponse res = http.send(req);
            System.debug(res.getBody());
        }
    }  

    @InvocableMethod(label='Beratungsportal Nutzer erstellen')
    public static void createBeratungsportalUserInvocable(List<Id> conIds) {
        Beratungsportal.createBeratungsPortalUser(conIds);
    }
}