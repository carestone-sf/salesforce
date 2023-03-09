import { LightningElement, api, track, wire } from 'lwc';

const columns = [
    { label: 'Nummer', fieldName: 'Name', hideDefaultActions:"true", sortable: "true", cellAttributes: { alignment: 'left' }},
    { label: 'Kaufpreis', fieldName: 'Purchase_Price__c',sortable: "true", hideDefaultActions:"true", type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: 'Fläche', fieldName: 'Area_sq_m__c', hideDefaultActions:"true", sortable: "true", cellAttributes: { alignment: 'left' }},
    { label: 'Preis m²', fieldName: 'Purchase_Price_sq_m__c', hideDefaultActions:"true", sortable: "true", type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: 'Miete pa', fieldName: 'Monthly_Rent__c', hideDefaultActions:"true", sortable: "true", type: 'currency', cellAttributes: { alignment: 'left' }},
    { label: 'Status', fieldName: 'Status__c', type:'text', hideDefaultActions:"true", sortable: "true", cellAttributes: { alignment: 'left' }},
];

export default class ImmobilienCard extends LightningElement {
    columns = columns;
    privateImmobilie;

    @api 
    get immobilie() {
        return this.privateImmobilie;
    }

    set immobilie(immobilie) {
        this.privateImmobilie = immobilie;
        this.handleImmobilienChange();
    }
    @track transferedApartments;
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
    mapMarkers = [
        {
            location: {
                Street: '',
                City: '',
                Country: 'Germany',
            },
        }];

    // toggles for the enlarged picture view
    closePictureModal(){
        this.showPictureModal = false;
    }

    openPictureModal(){
        this.showPictureModal = true;
    }

    // Toggle to show overview or detail view
    collapseCard(){
        if(this.template.querySelector('[data-id="1"]').style.display != "none"){
            this.template.querySelector('[data-id="1"]').style.display = "none";
            this.template.querySelector('[data-id="2"]').style.display = "";
        }else{
            this.template.querySelector('[data-id="1"]').style.display = "";
            this.template.querySelector('[data-id="2"]').style.display = "none"; 
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

    connectedCallback(){
        
    }

    handleImmobilienChange() {
        if(this.privateImmobilie && this.privateImmobilie.immobilie && this.privateImmobilie.teilobjekte) {
            this.transferedApartments = this.deepCopyFunction(this.privateImmobilie.teilobjekte);
            for(let i = 0;i < this.transferedApartments.length;i++){
                // sets rent for yearly rent by multiplying monthly rent with 12
                this.transferedApartments[i].Monthly_Rent__c = this.transferedApartments[i].Monthly_Rent__c*12;
                // add "m²" to area column
                this.transferedApartments[i].Area_sq_m__c = this.transferedApartments[i].Area_sq_m__c + "m²";
                // maps status__c to defined values
                switch (this.transferedApartments[i].Status__c) {
                    case "Available":
                        this.transferedApartments[i].Status__c = "frei"
                        break;
                    case "Sold":
                    case "Verkauft":
                        this.transferedApartments[i].Status__c = "verkauft"
                        break;
                    case "Reserved":
                    case "Kontingent":
                    case "Reservierungsvorbereitung":
                    case "Reservierung angefragt":
                    case "Kaufvertragsangebot abgegeben":
                    case "KV wird fremd abgegeben":
                    case "Kaufvertragsunterlagen verschickt -zweiseitig-":
                        this.transferedApartments[i].Status__c = "reserviert"
                        break;
                }
            }


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
}