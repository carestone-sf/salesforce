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
    { label: 'Status', fieldName: 'OeffentlicherStatus__c', type:'text', hideDefaultActions:"true", sortable: "true", cellAttributes: { alignment: 'left', class: {fieldName:'statusColorClass'} }},
];

export default class ImmoListCard extends LightningElement {
    columns = columns;
    privateImmobilie;

    @track 
    hideCheckbox = false;

    @api 
    get immobilie() {
        return this.privateImmobilie;
    }
    get showBaufortschrittTab (){
        if(this.privateImmobilie.immobilie.BuildingProgressWebcam__c){
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
        this.transferedApartments = this.privateImmobilie.teilobjekte;

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