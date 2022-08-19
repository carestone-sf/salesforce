import { LightningElement,wire} from 'lwc';
import { MessageContext, publish } from 'lightning/messageService';
import getBerechnungSave from '@salesforce/apex/BerechnungController.getBerechnungSave'
import LOAD_LIST_UPDATE from '@salesforce/messageChannel/LoadListUpdate__c';

export default class rechnerLoadPicker extends LightningElement {

    saveListData;
  
    @wire(MessageContext) messageContext;

    // Columns displayed in the table
    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Erster Käufer', fieldName: 'ErsterKaeuferName'},
        { label: 'Zweiter Käufer', fieldName: 'ZweiterKaeuferName'},
        { label: 'erstellt am', fieldName: 'CreatedDate', type: 'date'},
    ];

    message;
    recordId;

    // Creates a list of Berechnung__c records queried by Apex Controller
    // used to display list in HTML
    @wire(getBerechnungSave)
    createSaveList(result) {
        if(result.data) {
            const transformResult = this.transformResult(result);
            this.saveListData = transformResult.data;
            for(let i = 0; i < this.saveListData.length; i++) {
                const Data = this.saveListData[i];
            }
        }
    }


    // Fetches the recordId of the selected row and publishes it on LOAD_LIST_UPDATE
    getSelectedID(event) {
        const selectedRows = event.detail.selectedRows;
        for (let i = 0; i < selectedRows.length; i++){
            const message = {recordId: selectedRows[i].Id};
            publish(this.messageContext, LOAD_LIST_UPDATE, message);
        }
    }


    // Recursively iterate over the data and manipulate relationships to flat values, e.g.:
    // Customer__r.Name -> CustomerName
    iterateData(data) {
        for(let i = 0; i < data.length; i++) {
            const currentData = data[i];
            
            for(let key in currentData) {
                if(key.indexOf('__r') > -1) {
                    var value = currentData[key];
                    if(Array.isArray(value)) {
                        currentData[key] = this.iterateData(value);
                    } else {
                        var relationship = key.replace('__r', '');
                        for(let innerKey in currentData[key]) {
                            const newKey = relationship + innerKey;
                            currentData[newKey] = currentData[key][innerKey];
                            if(innerKey == 'Name') {
                                const linkId = relationship + 'IdLink';
                                currentData[linkId] = '/s/detail/' + currentData[key]['Id'];
                            }
                        }
                        delete currentData[key];
                    }
                }
            }
        }
        return data;
    }

    transformResult(result) {
        const copy = this.deepCopyFunction(result);
        copy.data = this.iterateData(copy.data);
        return copy;
    }

    deepCopyFunction(inObject) {
        let outObject, value, key
      
        if (typeof inObject !== "object" || inObject === null) {
          return inObject // Return the value if inObject is not an object
        }
      
        // Create an array or object to hold the values
        outObject = Array.isArray(inObject) ? [] : {}
      
        for (key in inObject) {
          value = inObject[key]
      
          // Recursively (deep) copy for nested objects, including arrays
          outObject[key] = this.deepCopyFunction(value)
        }
      
        return outObject
      }
}