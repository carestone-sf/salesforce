({
    myAction : function(component, event, helper) {

    },
    statusChange : function (cmp, event) {
        console.log(event.getParam('status'));
        cmp.set("v.flowStatus", event.getParam('status'));
        if (event.getParam('status') === "FINISHED") {
        }
    },
    closeModal: function(cmp, event, helper) {
        // Set isModalOpen attribute to false  
        var modalFade = cmp.find("modalFade").getElement();
        var modalBackdrop = cmp.find("modalBackdrop").getElement();
        
        $A.util.removeClass(modalFade,'slds-fade-in-open');
        $A.util.removeClass(modalBackdrop,'slds-backdrop_open');
     },
     handleChanged: function(cmp, message, helper) {
        var modalFade = cmp.find("modalFade").getElement();
        var modalBackdrop = cmp.find("modalBackdrop").getElement();
        $A.util.addClass(modalFade,"slds-fade-in-open");
        $A.util.addClass(modalBackdrop,'slds-backdrop_open');
        helper.startMyFlow(cmp, message);
     }
})