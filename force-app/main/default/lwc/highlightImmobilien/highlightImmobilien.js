import { LightningElement, wire } from 'lwc';
import getHighlightImmobilienApex from '@salesforce/apex/ImmobilienController.getHighlightImmobilien';

export default class HighlightImmobilien extends LightningElement {

    // Holds all public Property__c records including apartments
    immobilien;
    @wire(getHighlightImmobilienApex)
    loadImmobilien(result) {
        this.immobilien = result;
        if(this.immobilien.data) {
            const transformResult = this.transformResult(this.immobilien);
            this.immobilien = transformResult; 
            if(this.immobilien.data != null) {
                for(let i = 0; i < this.immobilien.data.length; i++) {
                    const immobilie = this.immobilien.data[i].immobilie;
                    immobilie.link = '/s/immobilien#' + immobilie.Id;
                }
            }
        }
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

}