import { LightningElement, api, track, wire } from 'lwc';
import { MessageContext, publish } from 'lightning/messageService';
import IMMO_FINDER_APARTMENT_SELECTED from '@salesforce/messageChannel/ImmoFinderApartmentSelected__c';

const columns = [
    { label: 'Nummer', fieldName: 'Name', hideDefaultActions:"true", sortable: "true", cellAttributes: { alignment: 'left' }},
    { label: 'Kaufpreis', fieldName: 'Purchase_Price__c',sortable: "true", hideDefaultActions:"true", type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: 'Fläche', fieldName: 'FlaecheQmText__c', hideDefaultActions:"true", sortable: "true", cellAttributes: { alignment: 'left' }},
    { label: 'Preis m²', fieldName: 'Purchase_Price_sq_m__c', hideDefaultActions:"true", sortable: "true", type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: 'Miete pa', fieldName: 'Jahresmiete__c', hideDefaultActions:"true", sortable: "true", type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: 'Rendite', fieldName: 'RentalReturnFormulaVP__c', hideDefaultActions:"true", sortable: "true", type: 'percent',typeAttributes: { minimumFractionDigits: 2 }, cellAttributes: { alignment: 'left' }},
    { label: 'Überschuss/Aufwand p.m.', fieldName: 'costPerMonth', hideDefaultActions:"true", sortable: "true", type: 'currency',typeAttributes: { minimumFractionDigits: 2 }, cellAttributes: { alignment: 'left', class: {fieldName:'costColorClass'} }},
    { label: 'Status', fieldName: 'OeffentlicherStatus__c', type:'text', hideDefaultActions:"true", sortable: "true", cellAttributes: { alignment: 'left', class: {fieldName:'statusColorClass'} }},
];

export default class ImmoListCard extends LightningElement {
    columns = columns;
    privateImmobilie;
    eigenkapital;
    zinsen;
    @track
    tilgung;
    @track
    laufzeit;

    @track 
    hideCheckbox = false;

    financingOptionsValue = 'finanzierer';

    financingOptions = [
            { label: 'Eigenkapitalzahler', value: 'eigenkapitalzahler' },
            { label: 'Finanzierer', value: 'finanzierer' },
        ];

    @api 
    get immobilie() {
        return this.privateImmobilie;
    }
    get showBaufortschrittTab (){
        if(this.privateImmobilie.constructionBilder && this.privateImmobilie.constructionBilder.length > 0){
            if( Date.parse(this.privateImmobilie.immobilie.Completion__c)>=Date.now() || (!this.privateImmobilie.immobilie.Completion__c && Date.parse(this.privateImmobilie.immobilie.Arrival__c)>=Date.now())){
                return true;
            }
        }
        return false;
    }
    set immobilie(immobilie) {
        this.privateImmobilie = immobilie;
        this.handleImmobilienChange();
    }
    @track transferedApartments;
    @wire(MessageContext) messageContext;
    @track sortBy;
    @track sortDirection;

    // Variables used in connectedCallback
    // sets current Year
    currentYear = "" +new Date().getFullYear();
    // Result of comparison: currentYear to completedDate
    compareYear;
    // Date a property finished building or finishes building
    completedDate = "";
    // used for google maps location
    zoomLevel = 15;
    // controlling variable for the picture moda
    showPictureModal;
    
    // used for google maps location
    @track
    mapMarkers = [
        {
            location: {
                Street: '',
                City: '',
                Country: 'Germany',
            },
        }
    ];
    
    connectedCallback() {
        if(this.privateImmobilie != null && this.privateImmobilie.immobilie != null && this.privateImmobilie.immobilie.Property__c == 'Wohnimmobilie') {
            this.hideCheckbox = true;
            this.columns = [...columns].filter(col => col.fieldName != 'Jahresmiete__c' && col.fieldName != 'RentalReturnFormulaVP__c');
        }
    }

    get renditeMinIsSameAsRenditeMax() {
        return this.privateImmobilie != null && this.privateImmobilie.immobilie != null && this.privateImmobilie.immobilie.Max_Rendite__c == this.privateImmobilie.immobilie.Min_Rendite__c && this.privateImmobilie.immobilie.Property__c != 'Wohnimmobilie';
    }

    get renditeMinIsDifferentAsRenditeMax() {
        return this.privateImmobilie != null && this.privateImmobilie.immobilie != null && this.privateImmobilie.immobilie.Max_Rendite__c != this.privateImmobilie.immobilie.Min_Rendite__c && this.privateImmobilie.immobilie.Property__c != 'Wohnimmobilie';
    }

    get isWohnimmobilie() {
        return this.privateImmobilie != null && this.privateImmobilie.immobilie != null && this.privateImmobilie.immobilie.Property__c == 'Wohnimmobilie';
    }
    
    renderedCallback() {
        const hash = window.location.hash;
        if(hash) {
            const id = hash.replace('#', '');
            const immoDiv = this.template.querySelector('[data-id=' + id + ']');
            if(immoDiv != null) {
                immoDiv.scrollIntoView({behavior: "smooth", block: "center", inline: "nearest"});
            }
        } 
    }

    // publishes the Ids of the selected rows on the message Channel IMMO_FINDER_APARTMENT_SELECTED
    getSelectedID(event) {
        this.immoData = [];
        this.apartmentList = [];
        const selectedRows = event.detail.selectedRows;
        for (let i = 0; i < selectedRows.length; i++){
            this.apartmentList[i] = selectedRows[i];
        }
        this.immoData.push({'Id': this.privateImmobilie.immobilie.Id, 'Name': this.privateImmobilie.immobilie.Name,'apartmentList': this.apartmentList});
        const message = this.immoData;
        publish(this.messageContext, IMMO_FINDER_APARTMENT_SELECTED, message);
    }

    // toggles for the enlarged picture view
    closePictureModal(){
        this.showPictureModal = false;
    }

    openPictureModal(){
        this.showPictureModal = true;
    }

    // Toggle to show overview or detail view
    collapseCard(){
        if(this.template.querySelector('[data-card-id="1"]').style.display != "none"){
            this.template.querySelector('[data-card-id="1"]').style.display = "none";
            this.template.querySelector('[data-card-id="2"]').style.display = "";
        }else{
            this.template.querySelector('[data-card-id="1"]').style.display = "";
            this.template.querySelector('[data-card-id="2"]').style.display = "none"; 
        }
    }
    
    updateColumnSorting(event){
        let fieldName = event.detail.fieldName;
        let sortDirection = event.detail.sortDirection;
        // assign the values
        this.sortBy = fieldName;
        this.sortDirection = sortDirection;
        // call the custom sort method
        this.sortData(fieldName, sortDirection);
      }
      
      // Sorts the fields by number or text
      sortData(fieldName, sortDirection) {
        let sortResult = Object.assign([], this.transferedApartments);
        this.transferedApartments = sortResult.sort(function(a,b){
          if(a[fieldName] < b[fieldName])
            return sortDirection === 'asc' ? -1 : 1;
          else if(a[fieldName] > b[fieldName])
            return sortDirection === 'asc' ? 1 : -1;
          else
            return 0;
        })
      }

    handleImmobilienChange() {
        this.transferedApartments = this.deepCopyFunction(this.privateImmobilie.teilobjekte);

        // Sets the data for the google map call
        this.mapMarkers[0].location.Street = this.privateImmobilie.immobilie.Street__c;
        this.mapMarkers[0].location.City = this.privateImmobilie.immobilie.Place__c;

        // Formats date to only show year
        this.completedDate = this.privateImmobilie.immobilie.Completion__c;
        if(this.completedDate) {
            this.completedDate = this.completedDate.slice(0,4);
        }
        
        // Checks if property has finished building or is finishing in the current year
        // If true: wont display the "Fertiggestellt am:" field
        if(parseInt(this.currentYear) < parseInt(this.completedDate)){
            this.compareYear = true;
        }else{
            this.compareYear = false;
        }

        if(this.privateImmobilie.immobilie.PreSale__c) {
            this.hideCheckbox = true;
        }
    }

    handleFinancingOptionsChange(event) {
        this.financingOptionsValue = event.detail.value;
        if(this.financingOptionsValue == 'eigenkapitalzahler') {
            this.calculateEigenkapitalzahler();
        } else {
            this.calculateFinanzierer();
        }
    }

    calculateEigenkapitalzahler() {
        console.log('is here');
        const newarr = [];
        this.transferedApartments.forEach(function(item, idx) {
            console.log('is here 2');
            item.costPerMonth = item.Monthly_Rent__c - item.Cost_Admin__c/12 - item.Maintenance_sqm__c*item.Area_sq_m__c/12;
            newarr.push(item);
            console.log('cost per month', item.costPerMonth);
        });
        this.transferedApartments = newarr;
        console.log(this.transferedApartments);
    }

    calculateFinanzierer() {
        //(915.82-2*65.37/12-360/12)-(333024.90)*0.05/12
        const newarr = [];
        console.log('is here');
        const outerThis = this;
        this.transferedApartments.forEach(function(item, idx) {
            console.log('is here 2');
            if(outerThis.eigenkapital && outerThis.zinsen && outerThis.tilgung) {
                item.costPerMonth = item.Monthly_Rent__c - item.Cost_Admin__c/12 - item.Maintenance_sqm__c*item.Area_sq_m__c/12 - (item.Purchase_Price__c-outerThis.eigenkapital)*(1+outerThis.zinsen/100)*(outerThis.zinsen/100+outerThis.tilgung/100)/12;
            } else {
                item.costPerMonth = null;
            }
            if(item.costPerMonth != null && item.costPerMonth > 0) {
                item.costColorClass = 'slds-text-color_success';
            } else {
                item.costColorClass = 'slds-text-color_error';
            }
            newarr.push(item);
        });
        this.transferedApartments = newarr;
    }

    handleEigenkapitalChange(event) {
        this.eigenkapital = event.detail.value;
        this.calculateFinanzierer();
    }

    handleZinsenChange(event) {
        this.zinsen = event.detail.value;
        this.calculateFinanzierer();
    }

    handleTilgungChange(event) {
        this.tilgung = event.detail.value;
        this.calculateLaufzeit();
    }

    handleLaufzeitChange(event) {
        this.laufzeit = event.detail.value;
        this.calculateTilgung();
    }

    calculateTilgung() {
        if(this.zinsen && this.laufzeit) {
            const annuityZinsValue = this.zinsen/100+1;
            const annuityRate = 100000 * Math.pow(annuityZinsValue, this.laufzeit) * ((annuityZinsValue-1) / (Math.pow(annuityZinsValue, this.laufzeit)-1));
            const tilgungInPercent = (annuityRate - (100000 * this.zinsen / 100) ) / 100000 * 100;
            this.tilgung = Math.round(tilgungInPercent * 100) / 100;
            this.calculateFinanzierer();
        }
    }

    calculateLaufzeit() {
        if (this.zinsen && this.tilgung) {
            const zinsPercent = this.zinsen/100;
            const tilgungPercent = this.tilgung/100;
            //Formula from https://de.wikipedia.org/wiki/Annuit%C3%A4tendarlehen#Bestimmung_der_Laufzeit
            const laufzeitInJahren = Math.log(1+(zinsPercent)/tilgungPercent)/Math.log(zinsPercent+1);
            this.laufzeit = Math.round(laufzeitInJahren);
            this.calculateFinanzierer();
        }
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

      get betreiberLogoUrl() {
        let url = this.privateImmobilie.immobilie.BetreiberBetreiber_Logo__c;
        let imageId;
        if(url != null && url.includes("drive.google.") && url.endsWith("/view")) {
            imageId = url.slice(
                url.indexOf("/d/") + 3, 
                url.lastIndexOf("/view")
            );
        } else if(url != null && url.includes("?id=")) {
            imageId = url.split("?id=")[1];
        } 
        
        if(imageId) {
            return `https://drive.google.com/uc?export=view&id=${imageId}`;
        } else {
            return url;
        }
      }
}