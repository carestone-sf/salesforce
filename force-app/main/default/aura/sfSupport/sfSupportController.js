({
	onInit : function(component, event, helper) {
        let urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({"url":"https://carestone-salesforce.atlassian.net/servicedesk/customer/portal/1/group/6/create/10"});
        urlEvent.fire();
	}
})