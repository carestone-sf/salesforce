global without sharing class DashboardRefresh implements Schedulable {

    global void execute(SchedulableContext sc) {
        DashboardRefresh.refreshDashboard('01Z67000000p0Yt');
        DashboardRefresh.refreshDashboard('01Z67000000kymx');
        DashboardRefresh.refreshDashboard('01Z67000000kywJEAQ');
    }

    @future(callout=true)
    public static void refreshDashboard(Id dashboardId){
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setMethod('PUT');
        req.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v35.0/analytics/dashboards/' + dashboardId);

        Http http = new Http();
        HttpResponse res = http.send(req);
    }
}