({
    helperMethod : function() {

    },

     startMyFlow: function(cmp, message) {
        var originalApartments = message._params.apartments;
        var apartments = [];
        for(let i = 0; i < originalApartments.length; i++) {
            if(originalApartments[i] != null) {
                apartments.push({Id: originalApartments[i].Id})
            }
        }

        var immobilieId = message._params.immobilieId;
        var inputVariables = [
        ];
        inputVariables.push({
            name : 'allSelectedApartments',
            type : 'SObject',
            value : apartments
        });
        inputVariables.push({
            name : 'immobilieId',
            type : 'String',
            value: immobilieId
        });

        var flow = cmp.find("myFlow");
        flow.startFlow("Berechnung_Erstellen_Bearbeiten", inputVariables);

        setTimeout(function() {
            if(cmp.get("v.flowStatus") == null) {
                $A.get('e.force:refreshView').fire();
                setTimeout(function() {
                    if(cmp.get("v.flowStatus") == null) {
                        cmp.find("myMessageChannel").publish(message._params);
                    }
                }, 1000);
            }
        }, 1000);
     }
})