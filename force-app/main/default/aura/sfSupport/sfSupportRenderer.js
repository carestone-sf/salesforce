({
    afterRender : function(component, helper){
        $A.get("e.force:closeQuickAction").fire();
    }
})