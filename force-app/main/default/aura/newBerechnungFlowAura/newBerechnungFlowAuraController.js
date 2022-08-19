({
    myAction : function(component, event, helper) {
    },
    init : function (cmp) {
        var flow = cmp.find("flow");
        var inputVariables = [
        ];
        let pageRef = cmp.get("v.pageReference");
        let state = pageRef.state; // state holds any query params
        let base64Context = state.inContextOfRef;
        if ( base64Context.startsWith("1\.") ) {
            base64Context = base64Context.substring( 2 );
        }
        let addressableContext = JSON.parse( window.atob( base64Context ) );
        const parentId = addressableContext.attributes.recordId;
        cmp.set( "v.parentId", parentId);
        const recordId = cmp.get("v.recordId");

        if(recordId) {
            inputVariables.push({
                name : 'recordId',
                type : 'String',
                value : recordId
            });
        }
        if(recordId == null && parentId != null) {
            inputVariables.push({
                name : 'parentId',
                type : 'String',
                value : parentId
            });
        }
        flow.startFlow("Berechnung_Erstellen_Bearbeiten", inputVariables);
    },

    statusChange : function (cmp, event) {
        if (event.getParam('status') === "FINISHED") {
        }
    }
})