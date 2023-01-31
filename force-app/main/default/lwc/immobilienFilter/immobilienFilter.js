import { LightningElement, track, wire } from 'lwc';
import getMaklerImmobilien from '@salesforce/apex/ImmobilienController.getMaklerImmobilien';
import { publish, MessageContext } from 'lightning/messageService';
import IMMOBILIEN_LIST_UPDATE_MESSAGE from '@salesforce/messageChannel/ImmobilienListUpdate__c';

export default class ImmobilienFilter extends LightningElement {
    searchTerm = '';
    immobilien;
    immobilienIds;
    originalImmobilien;

    // Values for the "Objektart" checkboxes
    objectTypeOptions = [
        { label: "Pflegeimmobilie", value: "Pflegeimmobilie" },
        { label: "Betreutes Wohnen", value: "Betreutes Wohnen" },
        { label: "Sonstiges", value: "Sonstiges" }
    ];
    objectTypeValue = ["Betreutes Wohnen", "Pflegeimmobilie", "Sonstiges"];

    // Values for the "Bauart" checkboxes
    constructionTypeOptions = [
        { label: "Neubau", value: "Neubau" },
        { label: "Bestand", value: "Bestand" }
    ]
    constructionTypeValue = ["Neubau", "Bestand"]

    // Values for the "Förderung" checkboxes
    mabvOptions = [
        { label: "KfW-40 (EE)", value: "KfW-40 (EE)" },
        { label: "KfW-40", value: "KfW-40" },
        { label: "KfW-55 (EE)", value: "KfW-55 (EE)" },
        { label: "KfW-55", value: "KfW-55" }
    ]
    mabvValue = ["KfW-40 (EE)", "KfW-40", "KfW-55 (EE)", "KfW-55"]

    // Values for "KfW" Radio button group
    kfwOptions = [
        { label: "Alle", value: "Alle" },
        { label: "Mit KfW", value: "Mit KfW" },
        { label: "Ohne KfW", value: "Ohne KfW" }
    ];
    kfwValue = 'Alle';

    @track
    statesOptions = [];
    statesValue = [];

    maxPurchasePrice = 0;
    minPurchasePrice = 9999999;
    maxRendite = 0;
    minRendite = 100;
    renditeValue = 100;
    rentStartDate = "2999-01-01";

    get kfwEnabled() {
        return this.kfwValue == "Mit KfW" || this.kfwValue == "Alle";
    }

    @wire(MessageContext) messageContext;
    @wire(getMaklerImmobilien)
    loadImmobilien(result) {
        this.immobilien = result;
        this.originalImmobilien = this.immobilien;
        if (result.data) {
            this.immobilien = this.transformResult(result);
            this.originalImmobilien = this.transformResult(result);
            this.getValues();
            const message = {
                immobilien: this.immobilien
            };
            publish(this.messageContext, IMMOBILIEN_LIST_UPDATE_MESSAGE, message);
        }
    }

    getValues() {
        for(let i = 0; i<this.immobilien.data.length; i++) {
            const currentImmobilie = this.immobilien.data[i].immobilie;
            // Immobilie Min Max Values
            // Rendite
            if(currentImmobilie.Rendite_in__c > this.maxRendite) {
                this.maxRendite = currentImmobilie.Rendite_in__c;
            }
            if(currentImmobilie.Rendite_in__c < this.minRendite) {
                this.minRendite = currentImmobilie.Rendite_in__c;
                this.renditeValue = this.minRendite;
            }
            // Rental Start
            if(new Date(currentImmobilie.Arrival__c) < new Date(this.rentStartDate)) {
                this.rentStartDate = currentImmobilie.Arrival__c;
            }

            const immobilienStates = [];
            if(currentImmobilie.State__c != null) {
                if(!this.statesValue.includes(currentImmobilie.State__c)) {
                    immobilienStates.push(currentImmobilie.State__c);
                    this.statesValue.push(currentImmobilie.State__c);
                }
            }
            for(let x = 0; x < immobilienStates.length; x++) {
                const state = { label: immobilienStates[x], value: immobilienStates[x]};
                this.statesOptions.push(state);
            }

            // Apartment Min Max Values
            const currentApartments = this.immobilien.data[i].teilobjekte;
            for(let z = 0; z < currentApartments.length; z++) {
                const currentApartment = currentApartments[z];
                if(currentApartment.Purchase_Price__c > this.maxPurchasePrice) {
                    this.maxPurchasePrice = currentApartment.Purchase_Price__c;
                }
                if(currentApartment.Purchase_Price__c < this.minPurchasePrice) {
                    this.minPurchasePrice = currentApartment.Purchase_Price__c;
                }
            }
        }
    }

   // Initiate manipulation of data 
   transformResult(result) {
    const copy = this.deepCopyFunction(result);
    copy.data = this.iterateData(copy.data);
    return copy;
}

// Recursively iterate over the data and manipulate relationships to flat values, e.g.:
// Customer__r.Name -> CustomerName
iterateData(data) {
    if(Array.isArray(data)) {
        for(let i = 0; i < data.length; i++) {
            const currentData = data[i];
            
            this.iterateDataCurrent(currentData);
        }
    } else {
        this.iterateDataCurrent(data);
    }
    return data;
}

iterateDataCurrent(currentData) {
    for(let key in currentData) {
        if(key.indexOf('__r') > -1 || key == 'immobilie') {
            var value = currentData[key];
            if(Array.isArray(value) || key == 'immobilie') {
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
        } else if(key.indexOf('__c') > -1) {
            let value = currentData[key];
            if(!isNaN(value)) {
                if(key.toLowerCase().indexOf('purchase_price') > -1) {
                    currentData[key] = Math.round(currentData[key]);
                } else if(key.toLowerCase().indexOf('zip_code') == -1) {
                    currentData[key] = Math.round(currentData[key] * 100) / 100;
                }
            }
        }
    }
}

    // Thanks stackoverflow
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


    // Handles changes to the search input
    handleSearchTermChange(event) {
		// Debouncing this method: do not update the reactive property as
		// long as this function is being called within a delay of 300 ms.
		window.clearTimeout(this.delayTimeout);
		this.searchTerm = event.target.value;
		this.delayTimeout = setTimeout(() => {
			this.handleFilters();
		}, 300);
    }

    // Handles changes to the "Objektart" Checkboxes
    handleObjectTypeChange(event) {
        this.objectTypeValue = event.detail.value;
		this.handleFilters();
    }

    // Handles changes to the "Bauart" Checkboxes
    handleConstructionTypeChange(event) {
        this.constructionTypeValue = event.detail.value;
		this.handleFilters();
    }

    // Handles changes to the "Förderung" Checkboxes
    handleMabvChange(event) {
        this.mabvValue = event.detail.value;
		this.handleFilters();
    }

    // Handles changes to the "KfW" radio button group
    handleKfwEnabledChange(event) {
        this.kfwValue = event.detail.value;
		this.handleFilters();
    }

    handleMinPurchasePriceChange(event) {
        // Debouncing this method: do not update the reactive property as
		// long as this function is being called within a delay of 300 ms.
		window.clearTimeout(this.delayTimeout);
		this.minPurchasePrice = event.target.value;
		this.delayTimeout = setTimeout(() => {
			this.handleFilters();
		}, 300);
    }

    handleMaxPurchasePriceChange(event) {
        // Debouncing this method: do not update the reactive property as
		// long as this function is being called within a delay of 300 ms.
		// This is to avoid a very large number of Apex method calls.
		window.clearTimeout(this.delayTimeout);
		this.maxPurchasePrice = event.target.value;
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		this.delayTimeout = setTimeout(() => {
			this.handleFilters();
		}, 300);
    }

    handleRenditeChange(event) {
        // Debouncing this method: do not update the reactive property as
		// long as this function is being called within a delay of 300 ms.
		window.clearTimeout(this.delayTimeout);
		this.renditeValue = event.target.value;
		this.delayTimeout = setTimeout(() => {
			this.handleFilters();
		}, 300);
    }

    handleRentStartDateChange(event) {
        this.rentStartDate = event.detail.value;
        this.handleFilters();
    }

    handleStateChange(event) {
        this.statesValue = event.detail.value;
        this.handleFilters();
    }

    // Handles any filter change and filters out immobilien list
    handleFilters() {
            let regEx = new RegExp(this.searchTerm, "i");
            this.immobilien.data = this.deepCopyFunction(this.originalImmobilien.data);
            this.immobilien.data = this.immobilien.data.filter((immobilieWrapper) => {
                const immobilie = immobilieWrapper.immobilie;
                const apartments = immobilieWrapper.teilobjekte;
                var isIncluded = true;
                if(immobilie.Name.search(regEx) == -1) {
                    isIncluded = false;
                }

                if(this.objectTypeValue.includes("Sonstiges") && immobilie.Property__c != "Betreutes Wohnen" && immobilie.Property__c != "Pflegeimmobilie") {
                    //isIncluded = true;
                } else if(!this.objectTypeValue.includes(immobilie.Property__c)) {
                    isIncluded = false;
                }

                if(this.kfwValue == 'Alle') {
                    //isIncluded = true;
                } else if(this.kfwValue == 'Mit KfW' && this.mabvValue.includes(immobilie.Foerderung__c)) {
                    //isIncluded = true;
                } else if(this.kfwValue == 'Ohne KfW' && immobilie.Foerderung__c == null) {
                    //isIncluded = true;
                } else {
                    isIncluded = false;
                }

                if(!this.constructionTypeValue.includes(immobilie.Bauart__c)) {
                    isIncluded = false;
                }

                if(immobilie.Rendite_in__c < this.renditeValue) {
                    isIncluded = false;
                }

                if(new Date(immobilie.Arrival__c) < new Date(this.rentStartDate)) {
                    isIncluded = false;
                }

                if(!this.statesValue.includes(immobilie.State__c)) {
                    isIncluded = false;
                }

                for(let i = 0; i < apartments.length; i++) {
                    if(apartments[i].Purchase_Price__c < this.minPurchasePrice || apartments[i].Purchase_Price__c > this.maxPurchasePrice) {
                        apartments.splice(i, 1);
                    }
                }

                if(apartments.length == 0) {
                    isIncluded = false;
                }

                return isIncluded;
            });

            const message = {
                immobilien: this.immobilien
            };
            publish(this.messageContext, IMMOBILIEN_LIST_UPDATE_MESSAGE, message);
    }
}